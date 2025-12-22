
;----------------------------------------------------------------------
;                       SCSI commands
;----------------------------------------------------------------------
; Key:  M = Command implementation is mandatory.
;       O = Command implementation is optional.
;       Z = Command implementation is device type specific.


; general commands

SC_MODE_SELECT_6              = $15 ; Z
SC_COPY                       = $18 ; O
SC_MODE_SENSE_6               = $1A ; O
SC_RECEIVE_DIAGNOSTIC_RES     = $1C ; O
SC_SEND_DIAGNOSTIC            = $1D ; M
SC_COMPARE                    = $39 ; O
SC_COPY_AND_VERIFY            = $3A ; O
SC_WRITE_BUFFER               = $3B ; O
SC_READ_BUFFER                = $3C ; O
SC_CHANGE_DEFINITION          = $40 ; O
SC_LOG_SELECT                 = $4C ; O
SC_LOG_SENSE                  = $4D ; O
SC_MODE_SELECT_10             = $55 ; Z
SC_MODE_SENSE_10              = $5A ; O

; block device commands

SC_TEST_UNIT_READY            = $00 ; M
SC_REZERO_UNIT                = $01 ; O
SC_REQUEST_SENSE              = $03 ; M
SC_FORMAT_UNIT                = $04 ; M
SC_REASSIGN_BLOCKS            = $07 ; O
SC_READ_6                     = $08 ; M
SC_WRITE_6                    = $0A ; O
SC_SEEK_6                     = $0B ; O
SC_INQUIRY                    = $12 ; M
SC_RESERVE                    = $16 ; M
SC_RELEASE                    = $17 ; M
SC_START_STOP_UNIT            = $1B ; O
SC_PREVENT_ALLOW_MEDIUM_RVAL  = $1E ; O
SC_READ_CAPACITY              = $25 ; M
SC_READ_10                    = $28 ; M
SC_WRITE_10                   = $2A ; O
SC_SEEK_10                    = $2B ; O
SC_WRITE_AND_VERIFY           = $2E ; O
SC_VERIFY                     = $2F ; O
SC_SEARCH_DATA_HIGH           = $30 ; O
SC_SEARCH_DATA_EQUAL          = $31 ; O
SC_SEARCH_DATA_LOW            = $32 ; O
SC_SET_LIMITS                 = $33 ; O
SC_PRE_FETCH                  = $34 ; O
SC_SYNCHRONIZE_CACHE          = $35 ; O
SC_LOCK_UNLOCK_CACHE          = $36 ; O
SC_READ_DEFECT_DATA           = $37 ; O
SC_READ_LONG                  = $3E ; O
SC_WRITE_LONG                 = $3F ; O
SC_WRITE_SAME                 = $41 ; O



;----------------------------------------------------------------------
;                  SCSI structure definitions.
;----------------------------------------------------------------------

; ------------- SCSI Command Descriptor Block (CDB) --------------------

; 6 byte command block

      STRUCTURE group_0,0
	BYTE	grp0_opcode		; command code
	BYTE	grp0_lun		; logical unit number
	STRUCT	grp0_params,3		; command specific parameters
	BYTE	grp0_reserved;		; reserved byte
	LABEL	grp0_sizeof


; -------------------- SCSI Sense Data Block --------------------

      STRUCTURE sns_block,0
	BYTE	sns_errcode		; error code
					; bit 7 = valid
					; bits 0-6 = error code
					; (070h current, 071h deferred)
	BYTE	sns_segment		; segment number
	BYTE	sns_skey		; sense key
					; bit 6 = EOM
					; bit 5 = ILI
					; bit 0-3 = sense key
	STRUCT	sns_info,4		; information bytes
					; (remaining bytes if ILI set)
	BYTE	sns_length		; additional sense length ($0a)
	STRUCT	sns_specific,4		; command specific information
	BYTE	sns_scode		; additional sense code
	BYTE	sns_scodequal		; additional sense code qualifier
	BYTE	sns_frucode		; field replaceable unit code
	STRUCT	sns_skspec,3		; sense key specific bytes
        LABEL	sns_sizeof


; -------------------- SCSI Inquiry Data Block --------------------

      STRUCTURE inquire_block,0
	BYTE	inq_devtype		; device type
	BYTE	inq_devqual		; device type qualifier
	BYTE	inq_version		; version codes
	BYTE	inq_format		; data format codes
	BYTE	inq_length		; additional data length
	STRUCT	inq_reserved_1,2	; reserved bytes
	BYTE	inq_capable		; capability bit flags
	STRUCT	inq_vendid,8		; vendor ID field
	STRUCT	inq_prodid,16		; product ID field
	STRUCT	inq_revlev,4		; product revision level
	STRUCT	inq_reserved_2,60	; more reserved bytes
        LABEL	inq_sizeof



; ----------------------------------------------------------------------
; SCSI sense key values.
; ----------------------------------------------------------------------

SK_NO_SENSE		= $00		; no sense data
SK_NOT_READY		= $02		; SCSI unit not ready
SK_MEDIUM_ERROR		= $03		; medium error (paper feed)
SK_HARDWARE_ERROR	= $04		; unrecoverable hardware error
SK_ILLEGAL_REQUEST	= $05		; illegal parameter in CDB
SK_UNIT_ATTENTION	= $06		; target has been reset
SK_ABORTED_COMMAND	= $0b		; target aborted command


;----------------------------------------------------------------------
;                    Equates and defines.
;----------------------------------------------------------------------

SDM_VALID 	= $80		; mask for sense data valid bit
SDM_ERRCODE	= $01		; mask for sense data error code
SDM_EOM		= $40		; mask for sense data EOM bit
SDM_ILI		= $20		; mask for sense data ILI bit
SDM_SKEY	= $07		; mask for sense data sense key

IDM_PTYPE	= $01ff		; mask for inquiry peripheral type
IDM_PTQUAL	= $0e00		; mask for inquiry peripheral qualifier
IDM_DTQUAL	= $07ff		; mask for inquiry device qualifier
IDM_DATAFMT	= $07		; mask for inquiry response format

