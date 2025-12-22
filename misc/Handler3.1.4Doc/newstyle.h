/*
** $Id: newstyle.h,v 1.1 2005-08-27 09:23:03 obarthel Exp $
**

** Declarations for the New Style Command interface and the 64 bit
** tracdisk extensions.
** Unfortunately we don't have them in the general OS includes yet!
*/
#ifndef	SCSIDISK_NEWSTYLE_I
 #define	SCSIDISK_NEWSTYLE	1
 
 #ifndef		NSCMD_DEVICEQUERY
        // Define general new style handling

/* ------------------------------------------------------------------------
** Simple additions that are missing from the global V40 exec include io.i
** for support of the NewStyleDevice standard.
** Both were introduced for V43 (contact heinz@amiga.de)
*/

#define			NSCMD_DEVICEQUERY	0x4000

// The result
struct NSDeviceQueryResult
{
	/*
	** Standard information
	*/
	ULONG	nsdqr_DevQueryFormat;						// this is type 0
	ULONG	nsdqr_SizeAvailable;						// bytes available

	/*
	** Common information (READ ONLY!)
	*/
	UWORD	nsdqr_DeviceType;							// what the device does
	UWORD	nsdqr_DeviceSubType;						// depends on the main type
	APTR	nsdqr_SupportedCommands;					// 0 terminated list of cmds

	// May be extended in the future! Check SizeAvailable!
//	 LABEL nsdqr_SIZEOF
};

// For nsdqr_DeviceType
#define			NSDEVTYPE_UNKNOWN		 	0			// No suitable category, anything
#define			NSDEVTYPE_GAMEPORT			1			// like gameport.device
#define			NSDEVTYPE_TIMER				2			// like timer.device
#define			NSDEVTYPE_KEYBOARD			3			// like keyboard.device
#define			NSDEVTYPE_INPUT				4			// like input.device
#define			NSDEVTYPE_TRACKDISK		  	5			// like trackdisk.device
#define			NSDEVTYPE_CONSOLE		 	6			// like console.device
#define			NSDEVTYPE_SANA2				7			// A >=SANA2R2 networking device
#define			NSDEVTYPE_AUDIOARD			8			// like audio.device
#define			NSDEVTYPE_CLIPBOARD	  		9			// like clipboard.device
#define			NSDEVTYPE_PRINTER		 	10  		// like printer.device
#define			NSDEVTYPE_SERIAL		  	11  		// like serial.device
#define			NSDEVTYPE_PARALLEL			12  		// like parallel.device

// ------------------------------------------------------------------------

  #ifndef		NSCMD_TD_READ64

// Trackdisk specific new style device commands
   #define			NSCMD_TD_READ64	  			0xc000
   #define			NSCMD_TD_WRITE64	 		0xc001
   #define			NSCMD_TD_SEEK64	  			0xc002
   #define			NSCMD_TD_FORMAT64			0xc003

   // Alias to set the upper 32 bits for a 64 bit request
   #define			IO_HIGHOFFSET		 		IO_ACTUAL

  #endif		// NSCMD_TD_READ64

 #endif	 		// NSCMD_DEVICEQUERY

#endif			// SCSIDISK_NEWSTYLE_I
