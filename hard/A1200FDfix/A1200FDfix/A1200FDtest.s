ExecBase           = $4
Disable            = -120
Enable             = -126
Forbid             = -132
Insert             = -234
Remove             = -252
FindTask           = -294
Wait               = -318
GetMsg             = -372
ReplyMsg           = -378
WaitPort           = -384
CloseLibrary       = -414
OpenLibrary        = -552
CloseWindow        = -72
ModifyIDCMP        = -150
IntuiTextLength    = -330
LockPubScreen      = -510
UnlockPubScreen    = -516
EasyRequestArgs    = -588
OpenWindowTagList  = -606
CreateGadgetA      = -30
FreeGadgets        = -36
GT_SetGadgetAttrsA = -42
GT_GetIMsg         = -72
GT_ReplyIMsg       = -78
GT_RefreshWindow   = -84
CreateContext      = -114
GetVisualInfoA     = -126
FreeVisualInfo     = -132
pr_MsgPort         = 92
pr_CLI             = 172
UserPort           = 86
Class              = 20
IAddress           = 28
Font               = 40
Width              = 8
Height             = 10
GadgetID           = 38
IntrList           = 364
TaskReady          = 406
tc_State           = 15
TAG_USER           = $80000000
TAG_END            = 0
WA_Dummy           = TAG_USER+99
WA_IDCMP           = WA_Dummy+$07
WA_Gadgets         = WA_Dummy+$09
WA_Title           = WA_Dummy+$0B
WA_InnerWidth      = WA_Dummy+$13
WA_InnerHeight     = WA_Dummy+$14
WA_DragBar         = WA_Dummy+$1F
WA_DepthGadget     = WA_Dummy+$20
WA_CloseGadget     = WA_Dummy+$21
WA_Activate        = WA_Dummy+$26
WA_WBenchWindow    = WA_Dummy+$28
WA_GimmeZeroZero   = WA_Dummy+$2E
IDCMP_CLOSEWINDOW  = $00000200
IDCMP_INTUITICKS   = $00400000
IDCMP_GADGETUP     = $00000040
ta_YSize           = 4
ITextFont          = 8
IText              = 12
ng_LeftEdge        = 0
ng_Width           = 4
ng_Height          = 6
ng_GadgetText      = 8
ng_TextAttr        = 12
ng_VisualInfo      = 22
BUTTON_KIND        = 1
TEXT_KIND          = 13
PLACETEXT_IN       = $0010
GT_TagBase         = TAG_USER+$80000
GTTX_Border        = GT_TagBase+57
GTTX_Text          = GT_TagBase+11
GA_Dummy           = TAG_USER+$30000
GA_Disabled        = GA_Dummy+$000E

Start:
  lea     InitialSP(pc),a0
  move.l  sp,(a0)
  movea.l ExecBase,a6
  suba.l  a1,a1
  jsr     FindTask(a6)
  movea.l d0,a4
  tst.l   pr_CLI(a4)
  bne.s   OpenAll
  lea     pr_MsgPort(a4),a0
  jsr     WaitPort(a6)
  lea     pr_MsgPort(a4),a0
  jsr     GetMsg(a6)
  lea     WBenchMsg(pc),a0
  move.l  d0,(a0)

OpenAll:
  lea     IntuitionName(pc),a1
  moveq   #36,d0
  jsr     OpenLibrary(a6)
  lea     IntuitionBase(pc),a0
  move.l  d0,(a0)
  beq     ErrorOpenIntuition
  lea     GadToolsName(pc),a1
  moveq   #36,d0
  jsr     OpenLibrary(a6)
  lea     GadToolsBase(pc),a0
  move.l  d0,(a0)
  beq     ErrorOpenGadTools
  lea     TrackDiskName(pc),a1
  jsr     FindTask(a6)
  lea     TrackDiskTask(pc),a0
  move.l  d0,(a0)
  beq     ErrorFindTrackDisk
  movea.l IntuitionBase(pc),a6
  suba.l  a0,a0
  jsr     LockPubScreen(a6)
  lea     PubScrPtr(pc),a0
  move.l  d0,(a0)
  beq     ErrorLockPubScr
  lea     IntText(pc),a0
  move.l  d0,a1
  move.l  Font(a1),ITextFont(a0)
  move.l  #ButtonGadgText,IText(a0)
  jsr     IntuiTextLength(a6)
  lea     ButtonGadgTextLength(pc),a0
  add.w   d0,(a0)
  lea     IntText(pc),a0
  move.l  #TextGadgText3,IText(a0)
  jsr     IntuiTextLength(a6)
  lea     TextGadgTextLength(pc),a0
  add.w   d0,(a0)
  movea.l GadToolsBase(pc),a6
  movea.l PubScrPtr(pc),a0
  suba.l  a1,a1
  jsr     GetVisualInfoA(a6)
  lea     VInfo(pc),a0
  move.l  d0,(a0)
  beq     ErrorGetVInfo
  lea     GadgContext(pc),a0
  jsr     CreateContext(a6)
  lea     GadgContext(pc),a0
  move.l  d0,(a0)
  beq     ErrorCreateContext
  lea     ButtonNewGadg(pc),a1
  move.l  PubScrPtr(pc),a0
  move.l  Font(a0),ng_TextAttr(a1)
  move.l  ng_TextAttr(a1),a0
  move.w  ta_YSize(a0),d0
  addq.w  #6,d0
  move.w  d0,ng_Height(a1)
  move.l  VInfo(pc),ng_VisualInfo(a1)
  move.w  ButtonGadgTextLength(pc),ng_Width(a1)
  move.l  #BUTTON_KIND,d0
  move.l  GadgContext(pc),a0
  suba.l  a2,a2
  jsr     CreateGadgetA(a6)
  lea     ButtonGadg(pc),a0
  move.l  d0,(a0)
  beq     ErrorCreateButtonGadg
  move.l  d0,a0
  lea     TextNewGadg(pc),a1
  lea     ButtonNewGadg(pc),a2
  move.w  Width(a0),d0
  add.w   d0,ng_LeftEdge(a1)
  move.l  ng_TextAttr(a2),ng_TextAttr(a1)
  move.w  ng_Height(a2),ng_Height(a1)
  move.l  ng_VisualInfo(a2),ng_VisualInfo(a1)
  move.w  TextGadgTextLength(pc),ng_Width(a1)
  move.l  #TEXT_KIND,d0
  lea     TextGadgTagList(pc),a2
  jsr     CreateGadgetA(a6)
  lea     TextGadg(pc),a0
  move.l  d0,(a0)
  beq     ErrorCreateTextGadg
  movea.l IntuitionBase(pc),a6
  lea     WinTagList(pc),a1
  move.l  GadgContext(pc),4(a1)
  move.l  ButtonGadg(pc),a0
  moveq   #30,d0
  add.w   Width(a0),d0
  move.l  TextGadg(pc),a0
  add.w   Width(a0),d0
  move.l  d0,12(a1)
  moveq   #20,d0
  add.w   Height(a0),d0
  move.l  d0,20(a1)
  suba.l  a0,a0
  jsr     OpenWindowTagList(a6)
  lea     WinPtr(pc),a0
  move.l  d0,(a0)
  beq     ErrorOpenWin
  movea.l GadToolsBase(pc),a6
  movea.l d0,a0
  suba.l  a1,a1
  jsr     GT_RefreshWindow(a6)

Main:
  movea.l ExecBase,a6
  moveq   #-1,d0
  jsr     Wait(a6)
  tst.l   d0
  beq.s   Main
CheckMsg:
  movea.l GadToolsBase(pc),a6
  movea.l WinPtr(pc),a0
  movea.l UserPort(a0),a0
  jsr     GT_GetIMsg(a6)
  tst.l   d0
  beq.s   Main
  movea.l d0,a1
  move.l  Class(a1),d2
  move.l  IAddress(a1),a2
  jsr     GT_ReplyIMsg(a6)
CheckCloseWindow:
  cmp.l   #IDCMP_CLOSEWINDOW,d2
  bne.s   CheckIntuiTicks
  bra     CloseAll
CheckIntuiTicks:
  cmp.l   #IDCMP_INTUITICKS,d2
  bne     CheckGadgetUp
  lea     Checking(pc),a0
  tst.b   (a0)
  beq     CheckMsg
  lea     DelayTime(pc),a0
  addq.w  #1,(a0)
  cmp.w   #100,(a0)
  beq     ErrorReadyKeepsInactive
  btst    #5,$BFE001
  bne     CheckMsg
  moveq   #0,d0
  move.w  (a0),d0
  divu    #10,d0
  lea     TextGadgText31(pc),a0
  move.b  d0,(a0)
  add.b   #'0',(a0)
  swap    d0
  lea     TextGadgText32(pc),a0
  move.b  d0,(a0)
  add.b   #'0',(a0)
  movea.l TextGadg(pc),a0
  movea.l WinPtr(pc),a1
  suba.l  a2,a2
  lea     TextGadgTagList3(pc),a3
  jsr     GT_SetGadgetAttrsA(a6)
TurnMotorOff:
  movea.l ButtonGadg(pc),a0
  movea.l WinPtr(pc),a1
  lea     ButtonGadgTagList1(pc),a3
  jsr     GT_SetGadgetAttrsA(a6)
  lea     Checking(pc),a0
  clr.b   (a0)
  movea.l IntuitionBase(pc),a6
  movea.l WinPtr(pc),a0
  move.l  #IDCMP_CLOSEWINDOW|IDCMP_INTUITICKS|IDCMP_GADGETUP,d0
  jsr     ModifyIDCMP(a6)
  lea     DelayTime(pc),a0
  clr.w   (a0)
  move.b  #$FF,$BFD100
  nop
  nop
  move.b  #$F7,$BFD100
  nop
  nop
  move.b  BFD100(pc),$BFD100
  movea.l ExecBase,a6
  jsr     Disable(a6)
  movea.l TrackDiskTask(pc),a1
  jsr     Remove(a6)
  lea     TaskReady(a6),a0
  movea.l TrackDiskTask(pc),a1
  suba.l  a2,a2
  jsr     Insert(a6)
  movea.l TrackDiskTask(pc),a1
  move.b  #3,tc_State(a1)
  jsr     Enable(a6)
  bra     CheckMsg
CheckGadgetUp:
  cmp.l   #IDCMP_GADGETUP,d2
  bne     CheckMsg
  move.w  GadgetID(a2),d3
  bne     CheckMsg
  movea.l a2,a0
  movea.l WinPtr(pc),a1
  suba.l  a2,a2
  lea     ButtonGadgTagList2(pc),a3
  jsr     GT_SetGadgetAttrsA(a6)
  movea.l TextGadg(pc),a0
  movea.l WinPtr(pc),a1
  lea     TextGadgTagList2(pc),a3
  jsr     GT_SetGadgetAttrsA(a6)
  lea     Checking(pc),a0
  move.b  #1,(a0)
  movea.l IntuitionBase(pc),a6
  movea.l WinPtr(pc),a0
  move.l  #IDCMP_INTUITICKS|IDCMP_GADGETUP,d0
  jsr     ModifyIDCMP(a6)
  movea.l ExecBase,a6
  jsr     Disable(a6)
  movea.l TrackDiskTask(pc),a1
  jsr     Remove(a6)
  lea     IntrList(a6),a0
  movea.l TrackDiskTask(pc),a1
  suba.l  a2,a2
  jsr     Insert(a6)
  movea.l TrackDiskTask(pc),a1
  move.b  #8,tc_State(a1)
  jsr     Enable(a6)
  lea     BFD100(pc),a0
  move.b  $BFD100,(a0)
  nop
  nop
  move.b  #$7F,$BFD100
  nop
  nop
  move.b  #$77,$BFD100
  bra     CheckMsg

CloseAll:
  movea.l IntuitionBase(pc),a6
  movea.l WinPtr(pc),a0
  jsr     CloseWindow(a6)
FreeGadgs:
  movea.l GadToolsBase(pc),a6
  movea.l GadgContext(pc),a0
  jsr     FreeGadgets(a6)
FreeVInfo:
  movea.l GadToolsBase(pc),a6
  movea.l VInfo(pc),a0
  jsr     FreeVisualInfo(a6)
UnlockPubScr:
  movea.l IntuitionBase(pc),a6
  suba.l  a0,a0
  movea.l PubScrPtr(pc),a1
  jsr     UnlockPubScreen(a6)
CloseGadTools:
  movea.l ExecBase,a6
  movea.l GadToolsBase(pc),a1
  jsr     CloseLibrary(a6)
CloseIntuition:
  movea.l ExecBase,a6
  movea.l IntuitionBase(pc),a1
  jsr     CloseLibrary(a6)
Exit:
  move.l  WBenchMsg(pc),d0
  tst.l   d0
  beq.s   ByeBye
  movea.l ExecBase,a6
  jsr     Forbid(a6)
  movea.l WBenchMsg(pc),a1
  jsr     ReplyMsg(a6)
ByeBye:
  movea.l InitialSP(pc),sp
  moveq   #0,d0
  rts

ErrorReadyKeepsInactive:
  lea     ErrorReadyKeepsInactiveES(pc),a1
  bsr     ErrorRequest
  movea.l GadToolsBase(pc),a6
  movea.l TextGadg(pc),a0
  movea.l WinPtr(pc),a1
  suba.l  a2,a2
  lea     TextGadgTagList1(pc),a3
  jsr     GT_SetGadgetAttrsA(a6)
  bra     TurnMotorOff
ErrorOpenWin:
  lea     ErrorOpenWinES(pc),a1
  bsr     ErrorRequest
  bra     FreeGadgs
ErrorCreateTextGadg:
  lea     ErrorCreateTextGadgES(pc),a1
  bsr     ErrorRequest
  bra     FreeGadgs
ErrorCreateButtonGadg:
  lea     ErrorCreateButtonGadgES(pc),a1
  bsr     ErrorRequest
  bra     FreeGadgs
ErrorCreateContext:
  lea     ErrorCreateContextES(pc),a1
  bsr     ErrorRequest
  bra     FreeVInfo
ErrorGetVInfo:
  lea     ErrorGetVInfoES(pc),a1
  bsr     ErrorRequest
  bra     UnlockPubScr
ErrorLockPubScr:
  lea     ErrorLockPubScrES(pc),a1
  bsr     ErrorRequest
  bra     CloseGadTools
ErrorFindTrackDisk:
  lea     ErrorFindTrackDiskES(pc),a1
  bsr     ErrorRequest
  bra     CloseGadTools
ErrorOpenGadTools:
  lea     ErrorOpenGadToolsES(pc),a1
  bsr     ErrorRequest
  bra     CloseIntuition
ErrorOpenIntuition:
  bra     Exit

ErrorRequest:
  movea.l IntuitionBase(pc),a6
  suba.l  a0,a0
  suba.l  a2,a2
  suba.l  a3,a3
  jmp     EasyRequestArgs(a6)

VersionStr:
  dc.b '$VER: A1200FDtest 1.0 (06.02.1996)',0
A1200FDtestStr:
  dc.b 'A1200FDtest',0
IntuitionName:
  dc.b 'intuition.library',0
GadToolsName:
  dc.b 'gadtools.library',0
TrackDiskName:
  dc.b 'trackdisk.device',0
ButtonGadgText:
  dc.b 'Start',0
TextGadgText1:
  dc.b 'written by Christian Sauer',0
TextGadgText2:
  dc.b 'Checking...',0
TextGadgText3:
  dc.b '_MTR0 v _SEL0 -> _RDY delay time: '
TextGadgText31:
  dc.b '0.'
TextGadgText32:
  dc.b '0 s',0
ErrorGetVInfoText:
  dc.b 'Unable to get visual-info!',0
ErrorLockPubScrText:
  dc.b 'Unable to lock public-screen!',0
ErrorOpenGadToolsText:
  dc.b 'Unable to open gadtools.library!',0
ErrorCreateContextText:
  dc.b 'Unable to create context!',0
ErrorCreateButtonGadgText:
  dc.b 'Unable to create button-gadget!',0
ErrorCreateTextGadgText:
  dc.b 'Unable to create text-gadget!',0
ErrorOpenWinText:
  dc.b 'Unable to open window!',0
ErrorFindTrackDiskText:
  dc.b 'Unable to find trackdisk.device!',0
ErrorReadyKeepsInactiveText:
  dc.b 'Ready-signal keeps inactive!',0
OKStr:
  dc.b 'OK',0
Checking:
  dc.b 0
BFD100:
  dc.b 0
  even
InitialSP:
  dc.l 0
WBenchMsg:
  dc.l 0
IntuitionBase:
  dc.l 0
GadToolsBase:
  dc.l 0
TrackDiskTask:
  dc.l 0
PubScrPtr:
  dc.l 0
VInfo:
  dc.l 0
GadgContext:
  dc.l 0
DelayTime:
  dc.w 0
ErrorGetVInfoES:
  dc.l 20,0,A1200FDtestStr,ErrorGetVInfoText,OKStr
ErrorLockPubScrES:
  dc.l 20,0,A1200FDtestStr,ErrorLockPubScrText,OKStr
ErrorOpenGadToolsES:
  dc.l 20,0,A1200FDtestStr,ErrorOpenGadToolsText,OKStr
ErrorCreateContextES:
  dc.l 20,0,A1200FDtestStr,ErrorCreateContextText,OKStr
ErrorCreateButtonGadgES:
  dc.l 20,0,A1200FDtestStr,ErrorCreateButtonGadgText,OKStr
ErrorCreateTextGadgES:
  dc.l 20,0,A1200FDtestStr,ErrorCreateTextGadgText,OKStr
ErrorOpenWinES:
  dc.l 20,0,A1200FDtestStr,ErrorOpenWinText,OKStr
ErrorFindTrackDiskES:
  dc.l 20,0,A1200FDtestStr,ErrorFindTrackDiskText,OKStr
ErrorReadyKeepsInactiveES:
  dc.l 20,0,A1200FDtestStr,ErrorReadyKeepsInactiveText,OKStr
ButtonNewGadg:
  dc.w 10,10,0,0
  dc.l ButtonGadgText,0
  dc.w 0
  dc.l PLACETEXT_IN,0,0
ButtonGadgTagList1:
  dc.l GA_Disabled,0
  dc.l TAG_END,0
ButtonGadgTagList2:
  dc.l GA_Disabled,1
  dc.l TAG_END,0
TextNewGadg:
  dc.w 20,10,0,0
  dc.l 0,0
  dc.w 1
  dc.l 0,0,0
TextGadgTagList:
  dc.l GTTX_Border,1
TextGadgTagList1:
  dc.l GTTX_Text,TextGadgText1
  dc.l TAG_END,0
TextGadgTagList2:
  dc.l GTTX_Text,TextGadgText2
  dc.l TAG_END,0
TextGadgTagList3:
  dc.l GTTX_Text,TextGadgText3
  dc.l TAG_END,0
ButtonGadg:
  dc.l 0
TextGadg:
  dc.l 0
ButtonGadgTextLength:
  dc.w 12
TextGadgTextLength:
  dc.w 12
IntText:
  dc.w 0,0,0,0
  dc.l 0,0,0
WinPtr:
  dc.l 0
WinTagList:
  dc.l WA_Gadgets,0
  dc.l WA_InnerWidth,0
  dc.l WA_InnerHeight,0
  dc.l WA_IDCMP,IDCMP_CLOSEWINDOW|IDCMP_INTUITICKS|IDCMP_GADGETUP
  dc.l WA_Title,A1200FDtestStr
  dc.l WA_DepthGadget,1
  dc.l WA_CloseGadget,1
  dc.l WA_DragBar,1
  dc.l WA_Activate,1
  dc.l WA_WBenchWindow,1
  dc.l WA_GimmeZeroZero,1
  dc.l TAG_END,0
  end

