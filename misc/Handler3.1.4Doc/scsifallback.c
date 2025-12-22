/*
** This file defines fallback functions for
** direct SCSI transport
*/

#include <exec/types.h>
#include <exec/io.h>
#include <devices/trackdisk.h>
#include <devices/scsidisk.h>
#include <devices/newstyle.h>
#include <dos/filehandler.h>
#include <clib/exec_protos.h>
#include <pragmas/exec_sysbase_pragmas.h>
#include <string.h>
#include "scsistructs.h"

struct ExecBase *SysBase;

/*
** The following structures are assumed to be allocated 
** outside of this source:
*/
struct IOStdReq *diskreq;
struct SCSICmd *scsicmd;

/*
** Some flags
*/
BOOL superfloppy; /* set if this is a floppy or a superfloppy */
BOOL usetd64;     /* use td64 command set */
BOOL usensd;      /* use nsd command set */
BOOL usescsi;     /* use scsi command set */

UBYTE bytes_block_sh; /* The amount of shift from the block number to the byte number */
UBYTE lunmask;        /* the LUN, given by ((unit / 10) % 10) << 5 */

/*
** The following structures are directly transmitted over the
** SCSI bus. Some host adapters may require them in special
** memory regions to ensure working DMA transfer.
** It is thus necessary to allocate them in
** the memory type indicated in fssm_Env->de_BufMemType.
** This allocation is not shown here (but simple to do).
** Using C mechanisms to create these objects, e.g. placing
** them "on the stack" or "in the data hunk" is thus discouraged.
*/

struct SCSI6Cmd *scsi6cmd;           /* a SCSI command, 6 byte version */
struct SCSI10Cmd *scsi10cmd;         /* a SCSI command, 10 byte version */
struct SCSIModeSense *scsimodesense; /* SCSI mode sense information, i.e. error information */
struct SCSIExtendedSense *scsiextendedsense;
struct SCSICapacity *scsicapacity;   /* the result of READ_CAPACITY */
struct SCSIInquiry *scsiinquiry;     /* the result of INQUIRY */

/**********************************************************************
*   GetSCSIGeometry()
*   use SCSI commands to retrieve the drive geometry
*   returns the total number of blocks.
*   Note that we are currently limited to 2^32-1 blocks here.
**********************************************************************/
ULONG GetSCSIGeometry(struct DosEnvec *fssm_env)
{
  ULONG totalblocks = 0;
  ULONG blocksize   = 0;
  ULONG heads       = 0;
  ULONG cylinders   = 0;
  ULONG tracks;
  UWORD i;

  diskreq->io_Command = HD_SCSICMD;
  diskreq->io_Offset  = 0;
  diskreq->io_Data    = scsicmd;
  diskreq->io_Length  = sizeof(*scsicmd);
  scsicmd->scsi_Data              = NULL;
  scsicmd->scsi_Length            = 0;
  scsicmd->scsi_Command           = (UBYTE *)scsi6cmd;
  scsicmd->scsi_CmdLength         = sizeof(*scsi6cmd);
  scsicmd->scsi_Flags             = SCSIF_AUTOSENSE;
  scsicmd->scsi_SenseData         = (UBYTE *)scsiextendedsense;
  scsicmd->scsi_SenseLength       = sizeof(*scsiextendedsense);
  scsi6cmd->scsi6_Cmd             = SCSI_TEST_UNIT_READY;
  scsi6cmd->scsi6_Lun             = lunmask;
  scsi6cmd->scsi6_Block           = 0;
  scsi6cmd->scsi6_BlockCnt        = 0;
  scsi6cmd->scsi6_Control         = 0;

  /*
  ** First test whether the device works at all.
  */
  if (DoIO((struct IORequest *)diskreq))
    return 0;
  if (scsicmd->scsi_Status != SSTS_GOOD && scsicmd->scsi_Status != SSTS_INTERMEDIATE)
    return 0;
  
  /*
  ** INQUIRY the device
  */
  scsi6cmd->scsi6_Cmd             = SCSI_INQUIRY;
  scsi6cmd->scsi6_Block           = 0;
  scsi6cmd->scsi6_BlockCnt        = sizeof(struct SCSIInquiry);
  scsicmd->scsi_Flags             = SCSIF_READ | SCSIF_AUTOSENSE;
  scsicmd->scsi_Data              = (UWORD *)scsiinquiry;
  scsicmd->scsi_Length            = sizeof(*scsiinquiry);
  
  if (DoIO((struct IORequest *)diskreq))
    return 0;
  
  if (scsicmd->scsi_Actual < 2)
    return 0;
  
  if (scsiinquiry->sci_Status >> 5)
    return 0;
  
  /*
  ** Check the device class
  */
  switch(scsiinquiry->sci_Status & 0x1f) {
  case 0:
  case 1:
  case 4:
  case 5:
  case 7:
    break;
  default:
    return 0;
  }
  
  /*
  ** Try a mode sense 
  */
  scsi6cmd->scsi6_Cmd             = SCSI_MODE_SENSE;
  scsi6cmd->scsi6_Block           = 0x3f00; /* all pages */
  scsi6cmd->scsi6_BlockCnt        = sizeof(*scsimodesense);
  scsicmd->scsi_Flags             = SCSIF_READ | SCSIF_AUTOSENSE;
  scsicmd->scsi_Data              = (UWORD *)scsimodesense;
  scsicmd->scsi_Length            = sizeof(*scsimodesense);
  
  if (DoIO((struct IORequest *)diskreq) == 0) {
    if (scsicmd->scsi_Status == SSTS_GOOD || scsicmd->scsi_Status == SSTS_INTERMEDIATE) {
      if (scsicmd->scsi_Actual >= sizeof(struct SCSIPageHeader) + sizeof(struct SCSIBlockDescriptor)) {
	struct SCSIPageHeader *scph = (struct SCSIPageHeader *)scsimodesense;
	if (scph->spch_BlockDescriptorLength >= sizeof(struct SCSIBlockDescriptor)) {
	  if (scph->spch_ModeDataLength >= sizeof(struct SCSIPageHeader)) {
	    struct SCSIBlockDescriptor *scbd = (struct SCSIBlockDescriptor *)(scph + 1);
	    
	    totalblocks = scbd->scbd_NumberOfBlocks & 0xffffff;
	    if (totalblocks == 0xffffff)
	      totalblocks = 0;
	    blocksize   = scbd->scbd_BlockLength    & 0xffffff;
	  }
	}
      }
    }
  }
  
  /*
  ** Try a READ_CAPACITY
  */
  scsicmd->scsi_Command        = (UBYTE *)scsi10cmd;
  scsicmd->scsi_CmdLength      = sizeof(*scsi10cmd);
  scsicmd->scsi_Data           = (UWORD *)scsicapacity;
  scsicmd->scsi_Length         = sizeof(*scsicapacity);
  scsicmd->scsi_Flags          = SCSIF_READ | SCSIF_AUTOSENSE;  
  scsi10cmd->scsi10_Cmd        = SCSI_READ_CAPACITY;
  scsi10cmd->scsi10_Block      = 0;
  scsi10cmd->scsi10_reserved   = 0;
  scsi10cmd->scsi10_BlockCntHi = 0;
  scsi10cmd->scsi10_BlockCntLo = 0;
  scsi10cmd->scsi10_Control    = 0;
  
  if (DoIO((struct IORequest *)diskreq) == 0) {
    if (scsicmd->scsi_Status == SSTS_GOOD || scsicmd->scsi_Status == SSTS_INTERMEDIATE) {
      if (scsicmd->scsi_Actual >= sizeof(struct SCSICapacity)) {
	if (scsicapacity->scc_BlockLength) {
	  blocksize = scsicapacity->scc_BlockLength;
	} else {
	  blocksize = 512;
	}
	if (scsicapacity->scc_Block && scsicapacity->scc_Block != 0xffffffff) {
	  totalblocks = scsicapacity->scc_Block + 1; /* This is actually the last block */
	}
      }
    }
  }
  
  if (totalblocks == 0 || blocksize == 0)
    return 0;

  /*
  ** Filter out odd cases we cannot support:
  ** block sizes not divisible by 4, and block
  ** sizes that are not powers of 2.
  */
  if (blocksize & 3)
    return 0;
  if (blocksize & (blocksize - 1))
    return 0;
  
  /*
  ** Try a mode sense to get the rigid disk page 
  */
  scsi6cmd->scsi6_Cmd             = SCSI_MODE_SENSE;
  scsi6cmd->scsi6_Block           = 0x0400; /* the rigid disk page */
  scsi6cmd->scsi6_BlockCnt        = sizeof(*scsimodesense);
  scsicmd->scsi_Flags             = SCSIF_READ | SCSIF_AUTOSENSE;
  scsicmd->scsi_Data              = (UWORD *)scsimodesense;
  scsicmd->scsi_Length            = sizeof(*scsimodesense);
  scsicmd->scsi_Command           = (UBYTE *)scsi6cmd;
  scsicmd->scsi_CmdLength         = sizeof(*scsi6cmd);

  /*
  ** Extract the disk geometry from the Rigid disk page
  */
  if (DoIO((struct IORequest *)diskreq) == 0) {
    if (scsicmd->scsi_Status == SSTS_GOOD || scsicmd->scsi_Status == SSTS_INTERMEDIATE) {
      if (scsicmd->scsi_Actual >= sizeof(struct SCSIPageHeader)) {
	struct SCSIPageHeader *scph = (struct SCSIPageHeader *)scsimodesense;
	if (scph->spch_ModeDataLength >= 4 + sizeof(struct SCSIPageHeader) + sizeof(struct SCSIPage)) {
	  if (scph->spch_BlockDescriptorLength >= sizeof(struct SCSIBlockDescriptor)) {
	    struct SCSIBlockDescriptor *scbd = (struct SCSIBlockDescriptor *)(scph + 1);
	    struct SCSIPage *scpg = (struct SCSIPage *)((UBYTE *)(scbd) + scph->spch_BlockDescriptorLength);
	    if (scsicmd->scsi_Actual >= 4 + scph->spch_BlockDescriptorLength +
		sizeof(struct SCSIPage) + sizeof(struct SCSIPageHeader) &&
		(scpg->scp_PageCode & 0x3f) == 0x04 && (scpg->scp_PageLength >= 4)) {
	      struct RigidDiskPage *rdp = (struct RigidDiskPage *)(scpg + 1);
	      cylinders = (rdp->rgp_NumberOfCylinders[0] << 16) |
		  (rdp->rgp_NumberOfCylinders[1] << 8) | rdp->rgp_NumberOfCylinders[2];
	      heads     = rdp->rgp_NumberOfHeads;
	    }
	  }
	}
      }
    }
  }
  /*
  ** If the number of heads or number of cylinders is unknown,
  ** try to make a best guess
  */
  if (heads == 0 || cylinders == 0) {
    ULONG tracksecs;
    for(i = 16;i > 0;i--) {
      if (totalblocks % i == 0) {
	heads = i;
	break;
      }
    }
    tracksecs = totalblocks / i;
    
    for(i = 256;i > 0;i--) {
      if (tracksecs % i == 0) {
	cylinders = i;
	break;
      }
    }
  }
  
  tracks = cylinders * heads;
  if (tracks == 0)
    tracks = 1;
  /*
  ** Insert the data we've got
  */
  fssm_env->de_HighCyl        = cylinders - 1;
  fssm_env->de_BlocksPerTrack = totalblocks / tracks;
  fssm_env->de_Surfaces       = heads;
  fssm_env->de_SizeBlock      = blocksize >> 2;

  return totalblocks;
}

/*
 * Compute from the environment the shift between bytes and
 * blocks count. Returns 0 on error (all assuming that
 * 1-byte sectors do not make a lot of sense...
 */
UBYTE ComputeBlockShift(struct DosEnvec *fssm_env)
{
  ULONG bs = fssm_env->de_SizeBlock;
  UBYTE sh = 2; /* Note that bs is in LONGs, not BYTEs */
  /*
  ** Get the block shift. If this is not
  ** a power of two, we do not support it.
  */
  if (bs == 0 || (bs & (bs - 1)))
    return 0;
  
  while(bs >>= 1)
    sh++;

  return sh;
}


/**********************************************************************
 * Update the drive geometry from the disk. Here I assume that
 * there is no other source of information, so only TD_GETGEOMETRY
 * or the SCSI fallback is available.
 * Returns the total number of sectors on success, or 0 on failure.
 **********************************************************************/
ULONG UpdateDriveGeometry(struct DosEnvec *fssm_env)
{
  ULONG totalsectors = 0;
  
  if (superfloppy && fssm_env->de_LowCyl == 0) {
    if (usescsi) {
      totalsectors = GetSCSIGeometry(fssm_env);
    } else {
      struct DriveGeometry dg;
      diskreq->io_Data    = (APTR)&dg;
      diskreq->io_Length  = sizeof(dg);
      diskreq->io_Command = TD_GETGEOMETRY;
      if (!DoIO((struct IORequest *)diskreq)) {
	/*
	** Filter out odd cases 
	*/
	if (dg.dg_SectorSize & 3)
	  return 0;
	fssm_env->de_HighCyl        = (dg.dg_Cylinders)-1;
	fssm_env->de_BlocksPerTrack = dg.dg_TrackSectors;
	fssm_env->de_Surfaces       = dg.dg_Heads;
	fssm_env->de_BufMemType     = dg.dg_BufMemType;
	fssm_env->de_SizeBlock      = dg.dg_SectorSize >> 2;
	totalsectors                = dg.dg_TotalSectors;
      }
    }
  }

  if (totalsectors) {
    /*
    ** Get the block shift. If this is not
    ** a power of two, we do not support it.
    */
    bytes_block_sh = ComputeBlockShift(fssm_env);
    if (bytes_block_sh == 0)
      return 0;
  }
  
  return totalsectors;
}


/********
* InitIORequest() -- Initialize the IO or SCSI command to read or write the indicated block to the indicated buffer.
* This fills diskreq with an IORequest that reads minnumblocks starting at block tblock into tmemory if write = 0,
* otherwise it prepares the IORequest to write the blocks from memory to the device.
* The IORequest still needs to be send.
* Note further that your handler is responsible to ensure that numblocks << bytes_block_sh is smaller than
* fssm_Env->de_MaxTransfer. If not, the transfer has to be split up into multiple chunks.
* Also, if (tmemory & fssm->de_Mask) != tmemory, IO has to go from/to an additional buffer of memory 
* type fssm->de_BufMemType.
* This logic is *not* shown here, and it is assumed that the necessary precautions for this are already
* taken.
********/

void InitIORequest(UBYTE *tmemory,ULONG tblock,ULONG numblocks,int write)
{
  if (usescsi) {
    diskreq->io_Command = HD_SCSICMD;
    diskreq->io_Offset  = 0;
    diskreq->io_Data    = scsicmd;
    diskreq->io_Length  = sizeof(*scsicmd);
    scsicmd->scsi_Data           = (UWORD *)tmemory;
    scsicmd->scsi_Length         = numblocks << bytes_block_sh;
    scsicmd->scsi_Command        = (UBYTE *)scsi10cmd;
    scsicmd->scsi_CmdLength      = sizeof(*scsi10cmd);
    scsicmd->scsi_Flags          = ((write)?(SCSIF_WRITE):(SCSIF_READ)) | SCSIF_AUTOSENSE;
    scsicmd->scsi_SenseData      = (UBYTE *)scsiextendedsense;
    scsicmd->scsi_SenseLength    = sizeof(*scsiextendedsense);
    scsi10cmd->scsi10_Cmd        = (write)?(SCSI_WRITE10):(SCSI_READ10);
    scsi10cmd->scsi10_Lun        = lunmask;
    scsi10cmd->scsi10_Block      = tblock;
    scsi10cmd->scsi10_reserved   = 0;
    scsi10cmd->scsi10_BlockCntHi = numblocks >> 8;
    scsi10cmd->scsi10_BlockCntLo = numblocks;
    scsi10cmd->scsi10_Control    = 0;
  } else {
    diskreq->io_Data    = tmemory;
    diskreq->io_Offset  = tblock    << bytes_block_sh;
    diskreq->io_Length  = numblocks << bytes_block_sh;
    
    if (usetd64) {
      diskreq->io_Actual  = tblock >> (32 - bytes_block_sh);
      diskreq->io_Command = (write)?(TD_WRITE64):(TD_READ64);
    } else if (usensd) {
      diskreq->io_Actual  = tblock >> (32 - bytes_block_sh);
      diskreq->io_Command = (write)?(NSCMD_TD_WRITE64):(NSCMD_TD_READ64);
    } else {
      diskreq->io_Command = (write)?(CMD_WRITE):(CMD_READ);
    }
  }
}

/********
*   InterpretSCSISense() -- Convert the SCSI ASC/ASCQ code pair into an error that follows the TD convention.
*   Use this function to translate an error returning from an HD_SCSICMD to a trackdisk style error.
********/

BYTE InterpretSCSISense(void)
{
  UWORD code = (scsiextendedsense->exs_ASC << 8) | scsiextendedsense->exs_ASCQ;

  switch(code) {
  case 0x5300:
  case 0x3f00:
  case 0x3a00:
  case 0x5302:
  case 0x2800:
  case 0x5a00:
  case 0x5a01:
    return TDERR_DiskChanged;
  case 0x1300:
  case 0x1200:
  case 0x1600:
  case 0x1900:
  case 0x1903:
  case 0x1902:
  case 0x1901:
  case 0x1c02:
  case 0x1000:
  case 0x1d00:
  case 0x110a:
  case 0x1103:
  case 0x0100:
  case 0x1100:
  case 0x1104:
  case 0x110b:
  case 0x110c:
  case 0x1401:
  case 0x1400:
    return TDERR_NoSecHdr;
  case 0x3002:
  case 0x3001:
  case 0x3000:
  case 0x3100:
    return TDERR_BadDriveType;
  case 0x2500:
    return TDERR_BadUnitNum;
  case 0x1500:
  case 0x1501:
  case 0x1502:
  case 0x0600:
  case 0x0200:
  case 0x0900:
    return TDERR_SeekError;
  case 0x5a02:
  case 0x0300:
  case 0x2700:
  case 0x0c02:
    return TDERR_WriteProt;
  default:
    return TDERR_NotSpecified;
  }
}

/*
** Multiply two 32 bit numbers with a 32 bit result.
** In case the multiplication would overflow, return
** 0. In this particular application, this indicates
** an "impossible" result and can be used as an 
** error indicator.
*/
ULONG Mult32(ULONG a,ULONG b)
{
  UWORD ah = a >> 16;
  UWORD al = a;
  UWORD bh = b >> 16;
  UWORD bl = b;
  ULONG m,l;

  if (ah && bh)
    return 0;

  /*
  ** The middle term
  */
  m = al * bh + ah * bl;
  if (m >> 16)
    return 0;

  /*
   * The low-order term
   */
  l   = al * bl;
  m <<= 16;

  if ((l += m) < m)
    return 0;
  
  return l;
}


/*
** Given the file system enviroment vector,
** Update the command style, i.e. whether this is
** SCSI, TD64 or NSD.
** Returns a success indicator.
*/
BOOL UpdateCommandStyle(struct FileSysStartupMsg *fssm)
{
  struct DosEnvec *fssm_Env = BADDR(fssm->fssm_Unit);
  const char *device        = BADDR(fssm->fssm_Device);

  /*
  ** go for regular trackdisk by default
  */
  usescsi     = FALSE;
  usetd64     = FALSE;
  usensd      = FALSE;
  superfloppy = FALSE;

  /*
  ** Set the superfloppy flag, dependent on the device
  ** name and the superfloppy flag. The device name
  ** is guaranteed to be a BPTR to a NUL-terminated
  ** BSTR. trackdisk and carddisk are two hardcoded
  ** cases (but probably not "super").
  */
  if ((fssm_Env->de_Interleave & ENVF_SUPERFLOPPY) ||
      !strcmp(device + 1,"trackdisk.device") ||
      !strcmp(device + 1,"carddisk.device"))
    superfloppy = TRUE;
  
  /*
  ** If scsi is enabled, use that and nothing else
  */
  if (fssm_Env->de_Interleave & ENVF_SCSIDIRECT) {
    usescsi = TRUE;
    /* Compute from the unit the lunmask that
    ** needs to go into the scsi commands
    */
    lunmask   = ((fssm->fssm_Unit / 10) % 10);
    if (lunmask > 7)
      return FALSE;
    lunmask <<= 5;
  } else {
    ULONG enddisk;
    UBYTE bytes_block_sh = ComputeBlockShift(fssm_Env);
    if (bytes_block_sh == 0)
      return FALSE; /* bummer! */
    /*
    ** Multiply such that we get 0 in case of an overflow.
    ** if the first addition overflows, we get 0, too.
    ** If one of the factors is 0, there is a problem, too.
    */
    enddisk = Mult32(Mult32(fssm_Env->de_HighCyl+1,fssm_Env->de_Surfaces),
		     fssm_Env->de_BlocksPerTrack);
    if (enddisk == 0)
      return FALSE;
    
    if (enddisk >= (1UL << (32 -  bytes_block_sh))) {
      /* Yup, 64bit required */
      if (fssm_Env->de_Interleave & ENVF_DISABLENSD) {
	/* Do not even attempt to run an NSD query, use TD64 directly. */
	usetd64 = TRUE;
      } else {
	struct NSDeviceQueryResult query;
	/* Otherwise, attempt to check for NSD
	 */
	diskreq->io_Data    = (APTR)&query;
	diskreq->io_Length  = sizeof(query);
	diskreq->io_Command = NSCMD_DEVICEQUERY;
	query.nsdqr_SizeAvailable     = 0;
	query.nsdqr_SupportedCommands = NULL;
	if (DoIO((struct IORequest *)diskreq) == 0) {
	  /* Ok, this device speaks at least NSD. */
	  if (diskreq->io_Actual >= 16) {
	    /* Need at least 16 bytes for the query */
	    if (diskreq->io_Actual == query.nsdqr_SizeAvailable) {
	      /* Ok, the size is indicated correctly */
	      if(query.nsdqr_DeviceType == NSDEVTYPE_TRACKDISK) {
		UWORD *cmds = query.nsdqr_SupportedCommands;
		while(*cmds) {
		  if (*cmds == NSCMD_TD_READ64) {
		    /* Finally. Is NSD64 */
		    usensd = TRUE;
		  }
		  cmds++;
		}
	      }
	    }
	  }
	}
	/*
	** if any of the above did not work, use TD64
	*/
	if (!usensd)
	  usetd64 = TRUE;
      }
    }
  }

  return TRUE;
}
