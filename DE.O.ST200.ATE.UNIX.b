* @ValidationCode : MjoyNDA1ODYyMjQ6Q3AxMjUyOjE1NzkxNjc5ODY2MDA6eWdyYWphc2hyZWU6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAxLjIwMTkxMjEzLTA1NDA6LTE6LTE=
* @ValidationInfo : Timestamp         : 16 Jan 2020 15:16:26
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ygrajashree
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202001.20191213-0540
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 21 07/06/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>13128</Rating>
*-----------------------------------------------------------------------------
$PACKAGE DE.Interface
SUBROUTINE DE.O.ST200.ATE.UNIX

* Interface module for outward SWIFT

* Switch   : ST200

* Protocol : ATE (Asynchronous Terminal Emulation)

* Host     : GENERIC UNIX

************************************************************************

* This routine processes outward SWIFT messages from GLOBUS to ST200 and
* deals with switch level responses to those messages.

* Modification history

* Based on original DE.O.CC.SWIFT code from P9955 to ST200. The front end
* comms have been changed for the Unix environment.
*
* Developed in London, this routine is the generic connection routine for
* ST200 using ATE protocol.
*
* N.B. Some of the commands used in this routine have been found to work
*      only with the latest version of Universe 5.4 and beyond.
*
*
* This version written by M.J.Ramsey in London in April 1991
*
* Modified April 1991 (GB9100068) for new controlling fields in DE.PARM
*
* Modified May   1991 (GB9100099) for SWIFT II network syntax
*
* Note : With regard to SWIFT II the initial cutover changes in this code
*        were designed to deal with the transition period where clients
*        are divided between the two networks. The processing therefore
*        depends on the parameter file flag DE.PAR.SWIFT.NETWORK. In time
*        the SWIFT I network will cease to exist completely in terms of
*        support. Eventually these conditions may be removed from the
*        code leaving only SWIFT II syntax.
*
* 29/04/92 - GB92000391
*            Don't use DE.PARM to hold the sequence numbers use
*            LOCKING. Use machine date and not system date when
*            allocating incoming id.
*
* 01/07/92 - GB9200584
*            Diversion of selected message types to ascii disk files
*            for onward transfer to other packages such as nostro recon
*
* GB9301815 - 16-12-93 & GB9400703
*           - Merge of Aura Interface from BDG
*
* 10-02-94 - GB9400073
*            Use new routine DE.UPDATE.FICHE.FILES to update standard
*            fiche files
*            Delivery fiche files are redundant
*
* 26-01-96 - GB9401252
*            Include date and time in sent stamp for Telex Header
*            Previously only time
*
* 24/04/96 - GB9600508
*            Modify the subroutine UPDATE.HEADER.ERROR such that
*            the header is updated with 'PDE' regardless of
*            whether or not an error is received (ie no reply is received)
*
* 25/09/96 - GB9601350
*            The retry times etc are hard coded and are not long enough
*            in high vol area therefore incorporate change made at
*            Standard Bank.
*
* 19/03/97 - GB9700330
*            Remove DE.O.MSG.COUNT and DE.I.MSG.COUNT files - these are
*            now obsolete
*
* 17/11/97 - GB9701309
*            When starting up check to see if there is an ACK waiting to come
*            back. This can happen when the ST200 times out due to too much
*            traffic. When we start St200 will send an ACK for the last msg
*            Globus sent which was not acknowledged.
*            The ACK returned is then of sequence with the messages globus sends
*            as it will resend the previously failed message on startup.
*            If a mesage of a higher priority has appeared in the meantime the
*            situation is worse as the high priority message is 'lost;
*
* 01/06/98 - GB9800591
*            If a message is sent to the ST200, but no response is
*            received, the program re-checks for the next message to send
*            rather than trying to resend the current message.  Thus, a
*            message can queue-jump, resulting in messages being lost and
*            duplicate messages being sent.
*
* 14/10/98 - GB9801269
*            If the outward carrier program stops and is then restarted,
*            the last message which was being sent is then sent again
*            (to avoid "queue jumping").  However, no check is done to
*            see whether the message has been held or deleted in the
*            meantime.  Put this check in!
*
* 06/03/00 - GB9901561
*            To solve the problem of checking the crash time
*            against the Delivery key.
*
*17/05/00 - Jbase changes.
*           Key word changes were made.
*
* 25/04/01 - GB0101155
*            Problem with DE.SWIFT.DIVERSION when being used and
*            multiple messages are added to a single output record.
*
* 28/06/02 - CI_10002470
*            Write DE.MSG.AUDIT key even if we encounter SEQ errors.
*
* 25/08/04 - BG_100007070
*            Pass on the phantom name while calling the routine,
*            DE.COMMON.INITIALISATION.  Its used to read the records
*            of F.DE.PHANTOM.
*
* 21/08/06 - EN_10003048
*            DE.O.HISTORY.QUEUE file re-structure
*
* 06/12/07 - BG_100016192
*            Converted SELECT statement to a call to DAS for executing a query.
*
* 15/09/10 - 42147: Amend Infrastructure routines to use the Customer Service API's
*
* 30/09/15 - Enhancement 1265068
*		   - Task 1469274
*		   - Changes done to support incorporation
*
* 16/10/15 - Enhancement 1265068/ Task 1504013
*          - Routine incorporated
*
* 16/01/20 - Task 3538382
*	     	 Correction for regression errors
************************************************************************
    $USING DE.Config
    $USING DE.Reports
    $USING EB.Utility
    $USING EB.SystemTables
    $USING DE.API
    $USING ST.Customer
    $USING EB.DataAccess
    $USING DE.Interface
    $USING DE.Outward
    $USING ST.Config
    $USING DE.ModelBank
    $USING DE.Clearing
    $INSERT I_CustomerService_Address
    $INSERT I_CustomerService_SWIFTDetails
    $INSERT I_CustomerService_DataField
    $INSERT I_CustomerService_AddressIDDetails
    DIM R.PARM(DE.Config.Parm.ParDim+9), R.HEAD(EB.SystemTables.SysDim), R.AUDIT(DE.Config.MsgAudit.AdtDim+9), C.AUDIT(DE.Config.MsgAudit.AdtDim+9)
    INTERACTIVE = ''
    EQU TRUE TO 1
    EQU FALSE TO 0
    TERM.REASON = "Normal"
    INTERACTIVE = 'DE.O.CC.SWIFT'       ;* BG_100007070 -s/e
    DE.API.CommonInitialisation(INTERACTIVE)
    PROGRAM.TERMINATING = FALSE
    ER = FALSE
    ANSWER = ''
    R.KEY = 'UNSET'
    PRTY.KEY = ''
    MISN = 'UNSET'
    OUT.SEQ.KEY = "OUT-SWIFT"
    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
    CRLF = CHARX(013):CHARX(010)
    FFFF = CHARX(012):CHARX(012)
    SOH = CHARX(001)
    ETX = CHARX(003)
    DATA.ACC.NAME = EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfDataAccName>
    DE.Clearing.setRSysLog(DE.Reports.Syslog.SysCarrier, "SWIFT")
    DE.Clearing.setRSysLog(DE.Reports.Syslog.SysLineNo, "1")
    DE.Clearing.setRSysLog(DE.Reports.Syslog.SysText, "")
    DE.Clearing.setRSysLog(DE.Reports.Syslog.SysInOut, "O")
    NO.RECS = 0
    RCV.TIMEOUT = 0
    RCV.RETRIES = 0
    SND.TIMEOUT = 1
    SND.RETRIES = 60
    MESSAGE.DIVERTED = 0
    RESEND.MESSAGE = ''
*
* Open the voc file
*
    F.VOC = ""
    OPEN "","VOC" TO F.VOC ELSE
        DE.Reports.SqMsg('PROGRAM CANNOT BE RUN - VOC FILE OPEN FAILED',1)
        RETURN
    END
    R.VOC = ""
    READ R.VOC FROM F.VOC,'F.COMM.BUFFER' ELSE
        DE.Reports.SqMsg('PROGRAM CANNOT BE RUN - COMM BUFFER OPEN FAILED',1)
        RETURN
    END
    COMMFILE = R.VOC<2>
    F.COMM.BUFFER = ''
    FILE.NAME = 'F.COMM.BUFFER':@FM:'NO.FATAL.ERROR'
    EB.DataAccess.Opf(FILE.NAME,F.COMM.BUFFER)
    IF EB.SystemTables.getEtext() THEN
        DE.Reports.SqMsg('PROGRAM CANNOT BE RUN - COMM BUFFER OPEN FAILED',1)
        RETURN
    END
*
* Open the SWIFT diversion file and see if there are any instructions to
* divert certain message types. The file will be selected and the list
* of divertable messages built once only at startup.
*
    DIVERT.LIST = ''

    DIVERT.LIST = 'ALL.IDS'
    THE.ARGS=''
    TABLE.SUFFIX=''
    EB.DataAccess.Das('DE.SWIFT.DIVERSION',DIVERT.LIST,THE.ARGS,TABLE.SUFFIX)

    CONVERT @FM TO @VM IN DIVERT.LIST     ;* BG_100016192

    IF DIVERT.LIST = '' THEN DIVERSIONS = 0 ELSE DIVERSIONS = 1
    IF DIVERSIONS THEN
*
* If diversions are defined then make sure their files can be opened OK
*
        NO.DIVERTED.MESSAGES = DCOUNT(DIVERT.LIST<1>,@VM)    ;* BG_100016192
        FOR DIVERT.COUNT = 1 TO NO.DIVERTED.MESSAGES

            R.DIVERT = ''
            DE.SWIFT.DIVERSION.ID = DIVERT.LIST<1,DIVERT.COUNT>
            R.DIVERT = DE.Config.SwiftDiversion.Read(DE.SWIFT.DIVERSION.ID, '')
            R.VOC = ''
            READ R.VOC FROM F.VOC,R.DIVERT<DE.Config.SwiftDiversion.SdOutwardFile> ELSE
                DE.Reports.SqMsg('DIVERSION TABLE ':DE.SWIFT.DIVERSION.ID:' CONTAINS NON-EXISTENT FILENAME ':R.DIVERT<DE.Config.SwiftDiversion.SdOutwardFile>,1)
                RETURN
            END
            F.DIVERT = ''
            OPEN '',R.DIVERT<DE.Config.SwiftDiversion.SdOutwardFile> TO F.DIVERT ELSE
                DE.Reports.SqMsg('DIVERSION FILE ':R.DIVERT<DE.Config.SwiftDiversion.SdOutwardFile>:' CANNOT BE OPENED',1)
                RETURN
            END
            DIVERT.LIST<DE.Config.SwiftDiversion.SdDivertAddress+1,-1> = R.DIVERT<DE.Config.SwiftDiversion.SdDivertAddress>
            DIVERT.LIST<DE.Config.SwiftDiversion.SdDivertFormat+1,-1> = R.DIVERT<DE.Config.SwiftDiversion.SdDivertFormat>
            DIVERT.LIST<DE.Config.SwiftDiversion.SdOutwardFile+1,-1> = R.DIVERT<DE.Config.SwiftDiversion.SdOutwardFile>
            DIVERT.LIST<DE.Config.SwiftDiversion.SdOutwardRecord+1,-1> = R.DIVERT<DE.Config.SwiftDiversion.SdOutwardRecord>
            DIVERT.LIST<DE.Config.SwiftDiversion.SdUseCustAddress+1,-1> = R.DIVERT<DE.Config.SwiftDiversion.SdUseCustAddress>
            DIVERT.LIST<DE.Config.SwiftDiversion.SdAddDelimiters+1,-1> = R.DIVERT<DE.Config.SwiftDiversion.SdAddDelimiters>
            DIVERT.LIST<DE.Config.SwiftDiversion.SdTrailerFormat+1,-1> = R.DIVERT<DE.Config.SwiftDiversion.SdTrailerFormat>

        NEXT DIVERT.COUNT
    END
    DE.Interface.CommBuffer.Delete('SWIFT.OUT')
    DE.Interface.CommBuffer.Delete('SWIFT.OUT.REC')
*
* Open the remote journal parameter file and read the system record
* If the system is a remote standby then all outgoing swift messages
* should be checked against the sent swift file.
*
*   R.REMOTE = ""

* Application remote journal parameter has been made obselete. Hence commenting the code.
*  R.REMOTE = EB.Foundation.RemoteJournalParameter.Read('SYSTEM','')
*  SYSMODE = R.REMOTE<EB.Foundation.RemJnlParam.RjpSystemMode>
*
* Check that shutdown carrier control on parameter file is blank or 'C'
*
    R.PARM.REC = DE.Config.Parm.Read('SYSTEM.STATUS', '')
    MATPARSE R.PARM FROM R.PARM.REC
    LOCATE 'SWIFT' IN R.PARM(DE.Config.Parm.ParOutwardCarriers)<1,1> SETTING CARRIER.POS ELSE
        DE.Reports.SqMsg('PROGRAM CANNOT BE RUN - CARRIER NOT AVAILABLE',1)
        RETURN
    END
    IF R.PARM(DE.Config.Parm.ParShutOutCarr)<1,CARRIER.POS> THEN
        IF R.PARM(DE.Config.Parm.ParShutOutCarr)<1,CARRIER.POS> <> 'C' THEN
            IF R.PARM(DE.Config.Parm.ParShutOutCarr)<1,CARRIER.POS> = 'A' THEN DE.Reports.SqMsg('PROGRAM CANNOT BE RUN - ALREADY ACTIVE',1)
            ELSE
                DE.Reports.SqMsg('PROGRAM CANNOT BE RUN - CARRIER SHUTDOWN',1)
                IF R.PARM(DE.Config.Parm.ParShutOutCarr)<1,CARRIER.POS> <> 'E' THEN
LCK01:
                    ER = ''
                    DE.Config.ParmLock('SYSTEM.STATUS',R.PARM.REC,ER,'E','')
                    MATPARSE R.PARM FROM R.PARM.REC
                    IF ER = 'RECORD LOCKED' THEN
                        EB.SystemTables.setText('FILE=F.DE.PARM ID=SYSTEM.STATUS')
                        EB.DataAccess.Lck1()
                        GOTO LCK01
                    END
                    R.PARM(DE.Config.Parm.ParShutOutCarr)<1,CARRIER.POS> = 'C'
                    MATBUILD R.PARM.REC FROM R.PARM
                    DE.Config.ParmWrite('SYSTEM.STATUS',R.PARM.REC,'')
                END
            END
            RETURN
        END
    END
*
* Update status on parameter file to 'A' - active
*
LCK2:
    DE.Config.ParmLock('SYSTEM.STATUS',R.PARM.REC,ER,'E','')
    MATPARSE R.PARM FROM R.PARM.REC
    IF ER = 'RECORD LOCKED' THEN
        EB.SystemTables.setText('FILE=F.DE.PARM ID=SYSTEM.STATUS')
        EB.DataAccess.Lck1()
        GOTO LCK2
    END
    R.PARM(DE.Config.Parm.ParShutOutCarr)<1,CARRIER.POS> = 'A'
    MATBUILD R.PARM.REC FROM R.PARM
    DE.Config.ParmWrite('SYSTEM.STATUS',R.PARM.REC,'')
*
* Setup field debug to determine whether to display messages
*
    DE.Clearing.setVDebug(0)
    IF INTERACTIVE THEN
        IF R.PARM(DE.Config.Parm.ParDebug) = 'Y' THEN DE.Clearing.setVDebug(1)
    END
*
* Determine the connection type to SWIFT. This may be 1 for SWIFT I
* (to be phased out) or 2 for SWIFT II. There may also be an extension
* of 'T' denoting a test and training connection.
*
    IF R.PARM(DE.Config.Parm.ParSwiftNetwork)[1,1] = '1' THEN NETWORK = 1 ELSE NETWORK = 2
    IF R.PARM(DE.Config.Parm.ParSwiftNetwork)[1] = 'T' THEN TRAINING = 1 ELSE TRAINING = 0

    DEVNAM = FIELD(R.PARM(DE.Config.Parm.ParSwiftLinecomm),',',1)
    DEVNAM = FMT(DEVNAM,'2"0"R')
    IF DE.Clearing.getVDebug() THEN EXECUTE 'COMO ON DE.O.CC.SWIFT'
*
    IF DE.Clearing.getVDebug() THEN CRT 'DE.O.ST200.ATE.UNIX RUNNING'
*
* Open files

    F.DE.SYSLOG.LOC = "" ; EB.DataAccess.Opf("F.DE.SYSLOG",F.DE.SYSLOG.LOC)
    DE.Clearing.setFDeSysLog(F.DE.SYSLOG.LOC)
*
    DE.Reports.WriteSyslog(0,'ST200 Outward message handler started.')

* Attempt to exchange startup message with the controller process
*
    BUFFER = ''
    BUFFER = DE.Interface.CommBuffer.ReadU('SWIFT.ACTIVE', ER, 'E')
    IF ER ='RECORD LOCKED' THEN
        EB.DataAccess.FRelease('F.COMM.BUFFER','','')
        IF DE.Clearing.getVDebug() THEN PRINT 'DE.SWIFT.LINE.HANDLER communications process active'
    END ELSE
        IF ER THEN
            EB.DataAccess.FRelease('F.COMM.BUFFER','','')
            IF DE.Clearing.getVDebug() THEN CRT 'DE.SWIFT.LINE.HANDLER was not active - starting it now'
            ERR.MSG = ''
            DE.Interface.SwiftStartup(ERR.MSG)
            IF ERR.MSG THEN
                REPLY = ERR.MSG
                GOSUB BADRC
                TERM.REASON = "NO HANDLER"
                GOTO V$EXIT
            END
            SLEEP 10
        END
    END
    SLEEP 5
*
* Read the SPF to see if there is a crash time.  If there is, every
* record will have to be checked against the time on the SPF
*

    CRASH.TIME = EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfRecvDateTime>
*
* Set operating mode to batch (in case any calling subroutines use
*

    tmp=EB.SystemTables.getRSpfSystem(); tmp<EB.SystemTables.Spf.SpfOpMode>='B'; EB.SystemTables.setRSpfSystem(tmp)
*
** Read the COMM.BUFFER to see if there is any message which was sent but received
** no acknowledgement from the last session. This is held in the record 'CURRENT.MESSAGE'
** which is normally deleted when either an ACK or NAK is received.
*
    RESEND.CURR.MSG = ''      ;* Set if needs to be resent
    CURR.MSG = ''
    CURR.MSG = DE.Interface.CommBuffer.Read('CURRENT.MESSAGE', '')
    IF CURR.MSG THEN
*
** Read the reponse buffer
** Only attempt this if there is a message sent but awaiting a reply
** In this case there will be something in CURRENT.MESSAGE
** If there is no reply we should try
** to resend the message with a PDE indicator as it has probably not
** beenm received by ST200
*
        R.KEY = CURR.MSG<1>   ;* Header / message key
        PRTY.KEY = CURR.MSG<2>          ;* Priority of message
*
* Check that message should still be sent (that it has been deleted or
* set to repair)
*
        PRI.ID = PRTY.KEY:'-':R.KEY
        R.PRI = ''; READ.ERR = ''
        R.PRI = DE.Config.OPriSwift.Read(PRI.ID, READ.ERR)
        IF NOT(READ.ERR) THEN
            DE.Reports.WriteSyslog(98,'ST200 Outward message handler. Checking for reply to & MISN  &^.':R.KEY:'@':CURR.MSG<3>)
            GOSUB PROCESSING
            IF CURR.MSG THEN
                CURR.MSG = '' ;* Treat as though new message in the queue
                R.HEAD(DE.Config.IHeader.HdrPosDupEntry)<1,R.KEY['.',2,1]> = "PDE"          ;* Set the PDE marker
                RESEND.CURR.MSG = 1     ;* If a successful response CURR.MSG will be cleared
                DE.Reports.WriteSyslog(97,'ST200 Outward message handler. Resending message & MISN  &^.':R.KEY:'@':CURR.MSG<3>)
                GOSUB PROCESSING
            END
        END ELSE
            CURR.MSG = ''
        END
*
    END
    RESEND.CURR.MSG = ''      ;* Message has been re-sent process as normal
    PROGRAM.TERMINATING = FALSE         ;* Reset in case message has been resent
*
* Main processing loop.
* ---------------------
    LOOP
        LOOP
            GOSUB CHECK.SYSTEM.SHUTDOWN
            IF STOP.STATUS = 'U' THEN
                TERM.REASON = "Normal"
                GOTO V$EXIT
            END
*
* Resend the last message, unless it was sent or diverted successfully,
* was already sent or a NAK was received
*
            IF RESEND.MESSAGE THEN
                R.KEY = RESEND.MESSAGE
            END ELSE
                CARR.QUEUE.FILE = 'F.DE.O.PRI.SWIFT'
                IF NOT(SAVE.R.KEY) THEN
                    DE.Outward.CheckForMsgToSend(CARR.QUEUE.FILE,R.KEY,PRTY.KEY)
                    SAVE.R.KEY = R.KEY
                END
                R.KEY = FIELD(SAVE.R.KEY<1>,"-",2)
            END
            RESEND.MESSAGE = R.KEY
            IF SAVE.R.KEY THEN SAVE.R.KEY = DELETE(SAVE.R.KEY,1,0,0)
*
        WHILE R.KEY
            TERM.REASON = "Normal"
            GOSUB UPDATE.PHANTOM.LOG
            GOSUB PROCESSING
            IF PROGRAM.TERMINATING THEN GOTO V$EXIT
        REPEAT
    WHILE STOP.STATUS = 'A'
        IF DE.Clearing.getVDebug() THEN
            DE.Reports.SqYonMsg('DO YOU WISH TO CONTINUE',ANSWER)
            IF ANSWER = 'NO' THEN GOTO V$EXIT
        END ELSE
            CALL !SLEEP$(1000*R.PARM(DE.Config.Parm.ParWaitTime))
            TERM.REASON = "Normal"
            GOSUB UPDATE.PHANTOM.LOG
        END
    REPEAT
*
V$EXIT:
    IF DE.Clearing.getVDebug() THEN CRT 'Detaching... '
*
* Log termination.
*
    DE.Reports.WriteSyslog(99,'ST200 Outward message handler stopped.')
LCK12:
    DE.Config.ParmLock('SYSTEM.STATUS',R.PARM.REC,ER,'E','')
    MATPARSE R.PARM FROM R.PARM.REC
    IF ER = 'RECORD LOCKED' THEN
        EB.SystemTables.setText('FILE=F.DE.PARM ID=SYSTEM.STATUS')
        EB.DataAccess.Lck1()
        GOTO LCK12
    END
    LOCATE 'SWIFT' IN R.PARM(DE.Config.Parm.ParOutwardCarriers)<1,1> SETTING CARRIER.POS ELSE DE.Reports.WriteSyslog(99,'SWIFT missing from DE.PAR.OUTWARD.CARRIERS')
    R.PARM(DE.Config.Parm.ParShutOutCarr)<1,CARRIER.POS> = 'C'
    MATBUILD R.PARM.REC FROM R.PARM
    DE.Config.ParmWrite('SYSTEM.STATUS',R.PARM.REC,'')
    GOSUB UPDATE.PHANTOM.LOG
    IF DE.Clearing.getVDebug() THEN CRT 'PROGRAM TERMINATING. Press any key to continue... '
    IF DE.Clearing.getVDebug() THEN INPUT ANS,1
*
* Set operating mode back to "O" - on-line
*
    tmp=EB.SystemTables.getRSpfSystem(); tmp<EB.SystemTables.Spf.SpfOpMode>='O'; EB.SystemTables.setRSpfSystem(tmp)
    IF DE.Clearing.getVDebug() THEN EXECUTE 'COMO OFF'
RETURN
*************************************************************************
*
PROCESSING:
*
* Read the header and message records
*
    HDR.KEY = FIELD(R.KEY,'.',1)
    AV1 = FIELD(R.KEY,'.',2)
    EB.SystemTables.setAv(AV1)
*
    R.HEAD.REC = DE.Config.OHeader.Read(HDR.KEY, '')
    MATPARSE R.HEAD FROM R.HEAD.REC
    R.MSG = DE.ModelBank.OMsgSwift.Read(R.KEY, '')

*
* Remove error message from header record if there has been a prior error
* in carrier control
*
    R.HEAD(DE.Config.OHeader.HdrMsgErrorCode)<1,AV1> = ''
*
* If crash time is after the time from the key, message must be flagged
* as a PDE.  However, if message exists on F.DE.SENT.SWIFT, the
* message should not be sent as it has already been received
* sucessfully.
*
    MESSAGE.ALREADY.SENT = 0
    R.TEMPKEY = R.KEY[2,8]:R.KEY[15,5]  ;** GB9901561
    IF CRASH.TIME > R.TEMPKEY THEN    ;** GB9901561
        MESSAGE.ALREADY.SENT = 1
        R.SENT = DE.Config.SentSwift.Read(R.KEY, ER)
        IF ER THEN
            MESSAGE.ALREADY.SENT = 0
            R.HEAD(DE.Config.IHeader.HdrPosDupEntry)<1,AV1> = 'PDE'
        END
    END


    IF MESSAGE.ALREADY.SENT THEN
*
* Message already sent.  Update the header record
*
        R.HEAD(DE.Config.IHeader.HdrMsgDisp)<1,AV1> = 'ACK'
        R.HEAD(DE.Config.OHeader.HdrSendStamp)<1,AV1> = 'BEFORE CRASH AT ':OCONV(CRASH.TIME[9,5],'MTS')
        R.HEAD(DE.Config.IHeader.HdrFromAddress)<1,AV1> = R.SENT<1>
        MATBUILD R.HEAD.REC FROM R.HEAD
        DE.Config.OHeaderWrite(HDR.KEY,R.HEAD.REC,'')
*
* Write secondary key to SRN
*
        DE.ModelBank.SrnWrite(R.KEY,R.SENT<1>,'')
*
* Delete the message the ACK relates to from the outward message file
*
        DE.ModelBank.OMsgDelete(R.KEY,'')
*
* Add message details to history file if appropiate
*
        GOSUB UPDATE.HISTORY
        IF R.PARM(DE.Config.Parm.ParMaintainHistory) = 'Y' THEN
            MATBUILD R.HEAD.REC FROM R.HEAD
            DE.Config.OHeaderArchWrite(HDR.KEY,R.HEAD.REC,'')
        END
*
* Remove key from the priority file
*
        GOSUB DELETE.PRIORITY.KEY
        RESEND.MESSAGE = ''   ;* Do not resend message - already sent
*
    END ELSE
*
* Message should be sent out
*
* GB9200584 - Check for diversions to disk files
*
        IF DIVERSIONS THEN GOSUB DIVERSION.PROCESSING
        IF MESSAGE.DIVERTED THEN RETURN
*
* Allocate the next MSN number
* Unless there is a current message due to lack of response from the
* ST200
*
        IF CURR.MSG THEN
            MISN = R.HEAD(DE.Config.IHeader.HdrCarSeqNo)<1,AV1>          ;* Already allocated
        END ELSE
            MISN = EB.SystemTables.Locking.Read(OUT.SEQ.KEY, '')
        END
*
        IF LEN(MISN) < 5 THEN MISN = STR("0",5 - LEN(MISN)):MISN
        IF DE.Clearing.getVDebug() THEN CRT MISN
*
        AUDIT.KEY = 'S.O.':FMT(MISN,'5"0"R')
        GOSUB READ.AUDIT
        IF NOT(R.AUDIT(DE.Config.MsgAudit.AdtRecordArchived)) AND NOT(CURR.MSG) THEN
            DE.Reports.WriteSyslog(9,'ST200 Outward message handler. Unarchived audit file record & encountered ^.':AUDIT.KEY)
            TERM.REASON = 'ERR 9 AUDIT'
            PROGRAM.TERMINATING = TRUE
            RETURN
        END
        MAT R.AUDIT = ''
*
* Update header record with MISN
*
        R.HEAD(DE.Config.IHeader.HdrCarSeqNo)<1,AV1> = MISN
        MATBUILD R.HEAD.REC FROM R.HEAD
        DE.Config.OHeaderWrite(HDR.KEY,R.HEAD.REC,'')
*
* Add ST200 header to message
*
        EB.SystemTables.setMessage('#MF':MISN:R.MSG)
*
* Add trailer, with PDE if necessary
*
        MESSAGE.VAL = EB.SystemTables.getMessage()
        IF NETWORK = 1 THEN
            IF R.HEAD(DE.Config.IHeader.HdrPosDupEntry)<1,AV1> THEN
                IF INDEX("369",R.HEAD(DE.Config.IHeader.HdrMessageType)[1,1],1) THEN
                    MESSAGE.VAL = MESSAGE.VAL:"-PDE":CRLF
                END ELSE
                    MESSAGE.VAL = MESSAGE.VAL:CRLF:"-AUT/1234":CRLF:"PDE":CRLF
                END
            END ELSE
                IF INDEX("369",R.HEAD(DE.Config.IHeader.HdrMessageType)[1,1],1) THEN
                    MESSAGE.VAL = MESSAGE.VAL:CRLF:"-"
                END ELSE
                    MESSAGE.VAL = MESSAGE.VAL:CRLF:"-AUT/1234":CRLF
                END
            END
            EB.SystemTables.setMessage(MESSAGE.VAL)
        END ELSE
*
* Insert the user message reference for later retrieval from the audit
* file. This is subfield 108 of block 3.
*
            MESSAGE.VAL = EB.SystemTables.getMessage()
            POS = INDEX(MESSAGE.VAL,'108:xxxxx',1)
            IF POS THEN
                MESSAGE.VAL = MESSAGE.VAL[1,POS+3]:MISN:MESSAGE.VAL[POS+9,LEN(MESSAGE.VAL)]
                EB.SystemTables.setMessage(MESSAGE.VAL)
            END
            MESSAGE.VAL = EB.SystemTables.getMessage()
            IF R.HEAD(DE.Config.IHeader.HdrPosDupEntry)<1,AV1> THEN
                MESSAGE.VAL = MESSAGE.VAL:"{5:"
                EB.SystemTables.setMessage(MESSAGE.VAL)
                MESSAGE.VAL = EB.SystemTables.getMessage()
                IF TRAINING THEN MESSAGE.VAL = MESSAGE.VAL:"{TNG:}"
                EB.SystemTables.setMessage(MESSAGE.VAL)
                MESSAGE.VAL = EB.SystemTables.getMessage()
                MESSAGE.VAL = MESSAGE.VAL:"{PDE:}}"
                EB.SystemTables.setMessage(MESSAGE.VAL)
            END ELSE
                MESSAGE.VAL = EB.SystemTables.getMessage()
                IF TRAINING THEN MESSAGE.VAL = MESSAGE.VAL:"{5:{TNG:}}"
                EB.SystemTables.setMessage(MESSAGE.VAL)
            END
        END
*
* Take copy of message and store it in f.fiche.de.msg for fiching
* sometime.
*
        MESSAGE.VAL = EB.SystemTables.getMessage()
        IF NOT(CURR.MSG) OR RESEND.CURR.MSG THEN
            IF EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfMicroficheOutput> = 'Y' THEN         ;* Fiche output?
                DE.Outward.UpdateFicheFiles(R.KEY,MAT R.HEAD,MESSAGE.VAL)
            END
*
* Send the message & check for a response.
*
            BUFFER = MESSAGE.VAL:FFFF
*
        END ELSE
            BUFFER = ''       ;* Check for repsonse only
        END
*
        REPLY = ""
        RCV.TIMEOUT = 1
        RCV.RETRIES = 120
*
** Write the message to be processed to the CURRENT.MESSAGE record
** in COMM.BUFFER. The layout of this record is
** <1> Key
** <2> Priority
** <3> MISN
** <4> Globus Date
** <5> Date Time
*
        CURR.MSG = ''
        CURR.MSG<1> = R.KEY ; CURR.MSG<2> = PRTY.KEY ; CURR.MSG<3> = MISN
        CURR.MSG<4> = EB.SystemTables.getToday() ; CURR.MSG<5> = TIMEDATE()
        DE.Interface.CommBuffer.Write('CURRENT.MESSAGE', CURR.MSG)
*
        GOSUB ST200O
        IF DE.Clearing.getVDebug() THEN CRT 'RECEIVED'
        IF DE.Clearing.getVDebug() THEN CRT REPLY
*
** If there is no reply leave the current message record
** otherwise delete it as it has been acknowledged by SWIFT
*
        IF REPLY THEN
            DE.Interface.CommBuffer.Delete('CURRENT.MESSAGE')
            CURR.MSG = ''
        END
*
        SWITCH.ACK.NAK = REPLY[10,3]
        IF DE.Clearing.getVDebug() THEN CRT 'SWITCH.ACK.NAK=':SWITCH.ACK.NAK
*
* Continue processing according to the response
*
        BEGIN CASE
*
* If no reply, log error and exit.
*
            CASE REPLY = ""
                DE.Reports.WriteSyslog(6,'ST200 Outward message handler error. No reply. Failing message was: SRN (Key)= & MISN= &.^':R.KEY:'@':MISN)
                GOSUB UPDATE.HEADER.ERROR
                RETURN
*
* If reply begins "*** ERROR ***", error occured, write to system log
*
            CASE REPLY[1,13] = "*** ERROR ***"
                IF LEN(REPLY)>14 THEN
                    DE.Reports.WriteSyslog(2,'ST200 Outward message handler error : & Failing message was: SRN (Key)= & MISN= &^':REPLY:'@':R.KEY:'@':MISN)
                END
                GOSUB UPDATE.HEADER.ERROR
                RETURN
*
*
* If reply begins "#MF", returned MISN should be numeric
*
            CASE REPLY[1,3] = "#MF"
                REPLY.MISN = REPLY[4,5]
                IF NOT(NUM(REPLY.MISN)) THEN
                    GOSUB UPDATE.HEADER.ERROR
                    RETURN
                END
*
* Response is an E (error response).  Error handling depends on returned
* error code and whether returned MISN matches MISN
*
                BEGIN CASE
                    CASE REPLY[9,1] = "E"
                        IF SWITCH.ACK.NAK = '' THEN
                            R.HEAD(DE.Config.OHeader.HdrMsgErrorCode)<1,AV1> = 'ST200 ERROR CODE INCOMPLETE'
                        END ELSE
                            R.HEAD(DE.Config.OHeader.HdrMsgErrorCode)<1,AV1> = '&#':SWITCH.ACK.NAK
                        END
*
* If the error code is HDR, TID, TLR, LEN, AUT or CRC, then check that
* the received MISN matches the sent MISN
*
                        IF INDEX('HDR*TID*TLR*LEN*CRC*AUT',SWITCH.ACK.NAK,1) THEN
                            IF REPLY.MISN <> MISN THEN
                                DE.Reports.WriteSyslog(4,'ST200 Outward message handler. Unexpected response sequence number received: & expected: &. Failing message was: SRN (Key)= &^':REPLY.MISN:'@':MISN:'@':R.KEY)
                                GOSUB UPDATE.MISN
                                GOSUB UPDATE.HEADER.ERROR
                                RETURN
                            END
*
* If the error code does not match one of the error codes above, check
* whether the error code is FMT or SEQ
*
                        END ELSE
                        END
*
* Error code is a defined error code
*
                        DE.Reports.WriteSyslog(5,'ST200 Outward message handler. Invalid response received: & Failing message was: SRN (Key)= & MISN= &^':REPLY:'@':R.KEY:'@':MISN)
*
* If error code is not SEQ, add the message to the repair file and
* remove the key from the priority file.  This message will have to
* be resubmitted before it can be resent to ST200.
*
                        IF SWITCH.ACK.NAK <> 'SEQ' THEN
                            GOSUB UPDATE.REPAIR
                            GOSUB DELETE.PRIORITY.KEY
                            RESEND.MESSAGE = '' ;* Do not resend message - error
                            GOSUB UPDATE.HEADER.ERROR
                        END
                        ELSE
* Here we have a MISN sequence number error (ESEQ). This we can recover
* from and so do. *SEQ*
                            R.HEAD(DE.Config.OHeader.HdrMsgErrorCode)<1,AV1> = ''
                            AUDIT.KEY.FROM.NUM = MISN
                            MISN = REPLY[13,5]
                            IF MISN = 99999
                            THEN AUDIT.KEY.TO.NUM = 2
                            ELSE AUDIT.KEY.TO.NUM = MISN+2
                            AUDIT.KEY.PREFIX = 'S.O.'
                            GOSUB CHECK.AUDIT.RECORDS:
                            IF NOT(ALL.ARCHIVED)
                            THEN
                                DE.Reports.WriteSyslog(9,'ST200 Outward message handler. Unarchived audit file record & encountered resetting MISN^.':SEQ.NUM)
                                TERM.REASON = 'ERR 9 AUDIT'
                                PROGRAM.TERMINATING = TRUE
                                RETURN
                            END
                            IF DE.Clearing.getVDebug() THEN CRT 'ESEQ RECEIVED, MISN RESET TO: ':MISN
                            DE.Reports.WriteSyslog(1,'ST200 Outward message handler SEQ error. MISN reset from & to &. Failing message was: SRN (Key)= &^':AUDIT.KEY.FROM.NUM:'@':MISN:'@':R.KEY)
                        END
                        GOSUB UPDATE.MISN
                        GOSUB UPDATE.HEADER.ERROR
                        RETURN
*
                    CASE REPLY[9,4] = "QRDY" OR REPLY[9,4] = "QVER"
*
* Received response is a Q (sucess)
*
* Write record to history file key if history maintenance is required
*
                        GOSUB UPDATE.HISTORY
*
* Update delivery header file
*
                        R.HEAD(DE.Config.IHeader.HdrMsgDisp)<1,AV1> = "WACK"
                        R.HEAD(DE.Config.OHeader.HdrMsgErrorCode)<1,AV1> = ''

                        DIETER.DT = ''
                        PRIME.DT = DATE()
                        ST.Config.DieterDate(DIETER.DT,PRIME.DT,'')
                        R.HEAD(DE.Config.OHeader.HdrSendStamp)<1,AV1> = DIETER.DT:' ':OCONV(TIME(),'MTS')
                        MATBUILD R.HEAD.REC FROM R.HEAD
                        DE.Config.OHeaderWrite(HDR.KEY,R.HEAD.REC,'')
*
* Write header to header archive file if history maintenance is required
*
                        IF R.PARM(DE.Config.Parm.ParMaintainHistory) = 'Y' THEN
                            MATBUILD R.HEAD.REC FROM R.HEAD
                            DE.Config.OHeaderArchWrite(HDR.KEY,R.HEAD.REC,'')
                        END
*
* Increment MISN and update on parameter file
*
                        GOSUB UPDATE.MISN
*
* Remove message key from priority file
*
                        GOSUB DELETE.PRIORITY.KEY
                        RESEND.MESSAGE = ''     ;* Do not resend message - sent successfully
*
* Add an entry to the awaiting acknowledgement queue
*
                        AWAK.ID = 'SWIFT-':R.KEY; R.AWAK = ''
                        DE.Config.OAwakWrite(AWAK.ID, R.AWAK,'')
                        RETURN
*
                    CASE 1
*
* Error - undefined response
*
                        GOSUB UNDEF.RSP
                        RETURN
*
                END CASE
            CASE 1
*
* Error - undefined response
*
                GOSUB UNDEF.RSP
                RETURN
        END CASE
    END
RETURN
*
* UNDEF.RSP - Undefined response received from ST200.
* ---------------------------------------------------
UNDEF.RSP:
    DE.Reports.WriteSyslog(7,'ST200 Outward message handler. Invalid response received: &. Failing message was: SRN (Key)= &. MISN= &^':REPLY:'@':R.KEY:'@':MISN)
    R.HEAD(DE.Config.IHeader.HdrPosDupEntry)<1,AV1> = "PDE"
    GOSUB UPDATE.MISN
    GOSUB UPDATE.HEADER.ERROR
RETURN
*
* Update the delivery header with the error message.  Alse update the
* system log with the error message and terminate the program.
* -----------------------------------------------------------------
UPDATE.HEADER.ERROR:
    IF R.HEAD(DE.Config.OHeader.HdrMsgErrorCode)<1,AV1> THEN
        R.HEAD(DE.Config.IHeader.HdrMsgDisp)<1,AV1> = "REPAIR"
    END

    IF NOT(CURR.MSG) THEN     ;* If retrying for response don't set PDE
        R.HEAD(DE.Config.IHeader.HdrPosDupEntry)<1,AV1> = "PDE"
    END

    MATBUILD R.HEAD.REC FROM R.HEAD
    DE.Config.OHeaderWrite(HDR.KEY,R.HEAD.REC,'')
* We can recover from MISN sequence number errors as ST200 tells us what
* should be being used. For anything else we must terminate. *SEQ*
    IF SWITCH.ACK.NAK # 'SEQ' THEN
        TERM.REASON = 'CAR ERROR'
        PROGRAM.TERMINATING = TRUE
        RETURN
    END
*
* Read the parameter file to determine whether to shutdown the carrier
* -------------------------------------------------------------------
CHECK.SYSTEM.SHUTDOWN:
    SAVE.R.KEY = ''
    R.PARM.REC = DE.Config.Parm.Read('SYSTEM.STATUS', '')
    MATPARSE R.PARM FROM R.PARM.REC
    STOP.STATUS = R.PARM(DE.Config.Parm.ParShutOutCarr)<1,CARRIER.POS>
RETURN
*
* Increment MISN and update on parameter file and update audit file for this MISN.
* ---------------------------------------------
UPDATE.MISN:
    GOSUB WRITE.AUDIT
    IF MISN = 99999 THEN MISN = 1 ELSE MISN = MISN + 1
    MISN = STR("0",5 - LEN(MISN)):MISN
LCK8:
    OUT.COUNT = ""
    EB.DataAccess.FRelease('F.LOCKING',OUT.SEQ.KEY,'')
    EB.SystemTables.LockingLock(OUT.SEQ.KEY,OUT.COUNT,ER,'E','')
    IF ER = 'RECORD LOCKED' THEN
        EB.SystemTables.setText("LOCKING RECORD LOCKED ":OUT.SEQ.KEY)
        EB.DataAccess.Lck1()
        GOTO LCK8
    END ELSE NULL
    EB.SystemTables.LockingWrite(OUT.SEQ.KEY,MISN,'')
RETURN
*
*----------------------------------------------------------------------
WRITE.AUDIT:
*===========
*
    IF DE.Clearing.getVDebug() THEN CRT 'Updating MISN'
    R.AUDIT(DE.Config.MsgAudit.AdtHeaderFileKey)=HDR.KEY
    R.AUDIT(DE.Config.MsgAudit.AdtHeaderFileMvOffset)=AV1
    R.AUDIT(DE.Config.MsgAudit.AdtDateTimeStamp) = EB.SystemTables.getRDates(EB.Utility.Dates.DatToday):OCONV(TIME(),'MTS')
    R.AUDIT(DE.Config.MsgAudit.AdtSwitchAckNak)=SWITCH.ACK.NAK
    R.AUDIT(DE.Config.MsgAudit.AdtSwitchErrCode)=REPLY[13,LEN(REPLY)]
    R.AUDIT(DE.Config.MsgAudit.AdtCarrier)='SW'
    MATBUILD R.AUDIT.REC FROM R.AUDIT
    DE.Config.MsgAuditWrite(AUDIT.KEY,R.AUDIT.REC,'')
*
RETURN
*
*-----------------------------------------------------------------------
*
* Remove key from the priority file
* ---------------------------------------------
DELETE.PRIORITY.KEY:
    ADD.OR.DEL = 1
    PRI.ID = PRTY.KEY:'-':R.KEY
    CARR.FILE.QUEUE = 'F.DE.O.PRI.SWIFT'
    DE.Outward.UpdatePriQueue(CARR.FILE.QUEUE,PRI.ID,ADD.OR.DEL)

RETURN
*
* Update the history files if history maintenance is required
* ---------------------------------------------
UPDATE.HISTORY:
    IF R.PARM(DE.Config.Parm.ParMaintainHistory) = 'Y' THEN
*
        DE.Config.OHistoryWrite(R.KEY,R.MSG,'')
*
* Add key to history queue
*
        V$DATE = R.KEY[2,8]
*Change the code to restructure the DE.O.HISTORY.QUEUE format to avoid locking
        Q.ID = ''
        Q.ID = R.KEY:"-":V$DATE
        DE.Config.OHistoryQueueWrite(Q.ID,V$DATE,'')
    END
RETURN
*
* Routine to send output to ST200 and process response
* ----------------------------------------------------
ST200O:
    IF BUFFER = '' THEN GOTO ST200I
    IF DE.Clearing.getVDebug() THEN CRT 'Sending... ':CRLF:BUFFER[1,LEN(BUFFER)-2]:CRLF
    REPLY = ''
    RETRY = 1
103:
    R.MESS = ''
    R.MESS = DE.Interface.CommBuffer.ReadU('SWIFT.OUT', ER, 'E')
    IF ER = 'RECORD LOCKED' THEN
        IF DE.Clearing.getVDebug() THEN PRINT 'SWIFT.OUT buffer locked on retry ':RETRY
        RETRY += 1
        IF RETRY > SND.RETRIES THEN
            R.MESS = ''
            EB.DataAccess.FRelease('F.COMM.BUFFER','SWIFT.OUT','')
            REPLY = '*** ERROR *** SWIFT.OUT buffer locked after ':RCV.RETRIES:' retries'
            RETURN
        END ELSE
            SLEEP SND.TIMEOUT
            GOTO 103
        END
    END
    R.MESS := BUFFER
    DE.Interface.CommBuffer.Write('SWIFT.OUT', R.MESS)
    EB.DataAccess.FRelease('F.COMM.BUFFER','SWIFT.OUT','')
    SLEEP SND.TIMEOUT

ST200I:
    RETRY = 1
    REPLY = ''
    LOOP
    WHILE RETRY <= RCV.RETRIES DO
104:
        V$CHARS = ''
        R.MESS = DE.Interface.CommBuffer.ReadU('SWIFT.OUT.REC', ER, 'E')
        IF ER = 'RECORD LOCKED' THEN
            IF DE.Clearing.getVDebug() THEN PRINT 'SWIFT.OUT.RES buffer locked after retry ':RETRY
            RETRY += 1
            IF RETRY > RCV.RETRIES THEN
                EB.DataAccess.FRelease('F.COMM.BUFFER','SWIFT.OUT.REC','')
                REPLY = '*** ERROR *** SWIFT.OUT buffer locked after ':RCV.RETRIES:' retries'
                RETURN
            END ELSE
                SLEEP RCV.TIMEOUT
                GOTO 104
            END
        END ELSE
            IF ER THEN
                V$CHARS = ''
                IF RETRY > RCV.RETRIES THEN
                    EB.DataAccess.FRelease('F.COMM.BUFFER','SWIFT.OUT.REC','')
                    REPLY = ''
                    RETURN
                END ELSE
                    IF DE.Clearing.getVDebug() THEN PRINT 'Reading comm buffer SWIFT.OUT.RES try ':RETRY:' reply is : ':REPLY
                    RETRY += 1
                    EB.DataAccess.FRelease('F.COMM.BUFFER','SWIFT.OUT.REC','')
                    SLEEP RCV.TIMEOUT
                    GOTO 104
                END
            END
        END
        IF V$CHARS THEN
            REPLY := V$CHARS
            V$CHARS = ''
            DE.Interface.CommBuffer.Write('SWIFT.OUT.REC', R.MESS)
            IF DE.Clearing.getVDebug() AND REPLY THEN CRT 'Received : ':REPLY
            RETURN
        END
        IF DE.Clearing.getVDebug() THEN PRINT 'Reading comm buffer SWIFT.OUT.RES try ':RETRY:' reply is : ':REPLY
        RETRY += 1
        EB.DataAccess.FRelease('F.COMM.BUFFER','SWIFT.OUT.REC','')
        SLEEP RCV.TIMEOUT
    REPEAT
    EB.DataAccess.FRelease('F.COMM.BUFFER','SWIFT.OUT.REC','')
RETURN
*
* BADRC - Report invalid BD$ RCs
* ------------------------------
BADRC:
    DE.Reports.WriteSyslog(3,'ST200 Outward message handler error: & Failing message was: SRN (Key)= & MISN= &^':REPLY:'@':R.KEY:'@':MISN)
    IF DE.Clearing.getVDebug() THEN CRT REPLY
RETURN
*
* Check audit records between old and new seq num are all archived.
* ---------------------------------------------------------------------
CHECK.AUDIT.RECORDS:
    ALL.ARCHIVED = FALSE
    IF DE.Clearing.getVDebug() THEN DE.Reports.SqYonMsg('Check & from & to &. ':@FM:AUDIT.KEY.PREFIX:@VM:AUDIT.KEY.FROM.NUM:@VM:AUDIT.KEY.TO.NUM,ANSWER)
    IF ANSWER = 'NO' THEN
        ALL.ARCHIVED = TRUE
        C.AUDIT.KEY = AUDIT.KEY.PREFIX:FMT(AUDIT.KEY.FROM.NUM,'5"0"R')
        RETURN
    END
    IF DE.Clearing.getVDebug() THEN
        CRT 'Checking switch sequence numbers against audit file. Please be patient. Press any key to exit.'
        INPUT ANSWER,-1
        IF ANSWER THEN
            INPUT ANSWER,1    ;* FLUSH IT
            CRT 'Cancelled.'
            RETURN
        END
    END
    IF AUDIT.KEY.FROM.NUM > AUDIT.KEY.TO.NUM THEN
        SAVED.SEQ.NUM = AUDIT.KEY.TO.NUM          ;* ALLOW FOR WRAP AROUND
        AUDIT.KEY.TO.NUM = 99999
        WRAP = TRUE
    END ELSE
        WRAP = FALSE
    END
    LOOP
        CRT 'AUDIT.KEY.FROM.NUM=':AUDIT.KEY.FROM.NUM:' AUDIT.KEY.TO.NUM=':AUDIT.KEY.TO.NUM:' WRAP=':WRAP
*
        FOR SEQ.NUM = AUDIT.KEY.FROM.NUM TO AUDIT.KEY.TO.NUM
            C.AUDIT.KEY = AUDIT.KEY.PREFIX:FMT(SEQ.NUM,'5"0"R')
            C.AUDIT.REC = DE.Config.MsgAudit.Read(C.AUDIT.KEY, ER)
            MATPARSE C.AUDIT FROM C.AUDIT.REC
            IF ER THEN ELSE C.AUDIT(DE.Config.MsgAudit.AdtRecordArchived)=TRUE        ;* ITS ALREADY GONE
            IF DE.Clearing.getVDebug() THEN IF NOT(MOD(C.AUDIT.KEY[5,5],20)) THEN CRT 'Checking F.DE.MSG.AUDIT, ':C.AUDIT.KEY:'. Archived flag = ':C.AUDIT(DE.Config.MsgAudit.AdtRecordArchived)
            IF NOT(C.AUDIT(DE.Config.MsgAudit.AdtRecordArchived)) THEN RETURN
        NEXT SEQ.NUM
    WHILE WRAP
        AUDIT.KEY.FROM.NUM = 1
        AUDIT.KEY.TO.NUM = SAVED.SEQ.NUM
        WRAP = FALSE
    REPEAT
    ALL.ARCHIVED = TRUE
RETURN
*
************************************************************************
*
UPDATE.PHANTOM.LOG:
*
* Subroutine to update the phantom log with detai ls of the reason for
* the stop and the last activity time if still running OK.
*
    R.PHANT = ''
    DE.API.PhantomLogLock("DE.O.CC.SWIFT",R.PHANT,'','','')
    IF TERM.REASON THEN R.PHANT<DE.API.PhantomLog.PhlLastTermination> = TERM.REASON
    ELSE R.PHANT<DE.API.PhantomLog.PhlLastTermination> = 'Normal'
    R.PHANT<DE.API.PhantomLog.PhlLastActivity> = OCONV(DATE(),'D2 E'):" ":OCONV(TIME(),'MTS')
    R.PHANT<DE.API.PhantomLog.PhlPhantomNo> = @USERNO
    DE.API.PhantomLogWrite("DE.O.CC.SWIFT",R.PHANT,'')
RETURN
*
*-----------------------------------------------------------------------
UPDATE.REPAIR:
*=============
*
    R.REPAIR = R.KEY
    DE.Outward.UpdateORepair(R.REPAIR,'')
*
RETURN
*
************************************************************************
DIVERSION.PROCESSING:
*********************
* Subroutine to allow for diversion of certain SWIFT message types to a
* disk file in a specific format for onward transfer to reconciliation
* packages etc. A diverted message is treated as complete (ACK) status
* and is moved to history etc. This normally done only after a SWIFT
* network ACK is received by the inward message handler. Sequence no's
* remain unaffected by diversions.
*
    MESSAGE.DIVERTED = 0
    LOCATE R.HEAD(DE.Config.IHeader.HdrMessageType) IN DIVERT.LIST<1,1> SETTING DIVERT ELSE DIVERT = 0
    IF NOT(DIVERT) THEN RETURN
    IF R.HEAD(DE.Config.IHeader.HdrToAddress)<1,AV1> <> DIVERT.LIST<DE.Config.SwiftDiversion.SdDivertAddress+1,DIVERT> THEN RETURN
    F.DIVERT = ''
    OPEN '',DIVERT.LIST<DE.Config.SwiftDiversion.SdOutwardFile+1,DIVERT> TO F.DIVERT ELSE
        TERM.REASON = 'DIVERT FILE'
        PROGRAM.TERMINATING = TRUE
        PRINT "Diversion file open failure on ":DIVERT.LIST<DE.Config.SwiftDiversion.SdOutwardFile+1,DIVERT>
        RETURN
    END
*
* Add ST200 header to message
*
    EB.SystemTables.setMessage('#MF99999':R.MSG)
*
* Add trailer, with PDE if necessary
*
    IF NETWORK = 1 THEN
        IF R.HEAD(DE.Config.IHeader.HdrPosDupEntry)<1,AV1> THEN
            IF INDEX("369",R.HEAD(DE.Config.IHeader.HdrMessageType)[1,1],1) THEN
                EB.SystemTables.setMessage(EB.SystemTables.getMessage():CRLF:"-PDE":CRLF)
            END ELSE
                EB.SystemTables.setMessage(EB.SystemTables.getMessage():CRLF:"-AUT/1234":CRLF:"PDE":CRLF)
            END
        END ELSE
            IF INDEX("369",R.HEAD(DE.Config.IHeader.HdrMessageType)[1,1],1) THEN
                EB.SystemTables.setMessage(EB.SystemTables.getMessage():CRLF:"-")
            END ELSE
                EB.SystemTables.setMessage(EB.SystemTables.getMessage():CRLF:"-AUT/1234":CRLF)
            END
        END
    END ELSE
*
* Insert the user message reference for later retrieval from the audit
* file. This is subfield 108 of block 3.
*
        POS = INDEX(EB.SystemTables.getMessage(),'108:xxxxx',1)
        IF POS THEN
            EB.SystemTables.setMessage(EB.SystemTables.getMessage()[1,POS+3]:MISN:EB.SystemTables.getMessage()[POS+9,LEN(EB.SystemTables.getMessage())])
        END
        IF R.HEAD(DE.Config.IHeader.HdrPosDupEntry)<1,AV1> THEN
            EB.SystemTables.setMessage(EB.SystemTables.getMessage():"{5:")
            IF TRAINING THEN EB.SystemTables.setMessage(EB.SystemTables.getMessage():"{TNG:}")
            EB.SystemTables.setMessage(EB.SystemTables.getMessage():"{PDE:}}")
        END ELSE
            IF TRAINING THEN EB.SystemTables.setMessage(EB.SystemTables.getMessage():"{5:{TNG:}}")
        END
    END
*
* Take copy of message and store it in f.fiche.de.msg for fiching
* sometime.
*
* GB9400073
    IF EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfMicroficheOutput> = 'Y' THEN       ;* Fiche output?
*         WRITE MESSAGE TO F.FICHE.DE.MSG,R.KEY
        MESSAGE.VAL = EB.SystemTables.getMessage()
        DE.Outward.UpdateFicheFiles(R.KEY,MAT R.HEAD,MESSAGE.VAL)
    END
    R.HEAD(DE.Config.IHeader.HdrCarSeqNo)<1,AV1> = '99999'
*
* Divert the message into the specified record in the file
*
* Add any special formatting necessary for the destination.
*
    BEGIN CASE
        CASE DIVERT.LIST<DE.Config.SwiftDiversion.SdDivertFormat+1,DIVERT> NE ''
            IF DIVERT.LIST<DE.Config.SwiftDiversion.SdUseCustAddress+1,DIVERT> = 'Y' THEN

                keyDetails = ''
                keyDetails<AddressIDDetails.customerKey> = R.HEAD(DE.Config.IHeader.HdrCustomerNo)
                keyDetails<AddressIDDetails.preferredLang> = EB.SystemTables.getLngg()
                keyDetails<AddressIDDetails.companyCode> = R.HEAD(DE.Config.IHeader.HdrCusCompany)
                keyDetails<AddressIDDetails.addressNumber> = 1
                address = ''
                CALL CustomerService.getSWIFTAddress(keyDetails, address)
                IF EB.SystemTables.getEtext() = '' THEN
                    delivery.address = address<SWIFTDetails.code>
                    YNEW.SWIFT.ADD = delivery.address
                    IF LEN(YNEW.SWIFT.ADD) = 11 THEN
                        YNEW.SWIFT.ADD = YNEW.SWIFT.ADD[1,8]:"X":YNEW.SWIFT.ADD[9,3]
                    END ELSE
                        YNEW.SWIFT.ADD = FMT(YNEW.SWIFT.ADD,'12"X"L')
                    END
                END ELSE
                    customerKey = R.HEAD(DE.Config.IHeader.HdrCustomerNo)
                    fieldName = 'CUS.MNEMONIC'
                    fieldNumber = ST.Customer.Customer.EbCusMnemonic
                    fieldOption = ''
                    dataField = ''
                    CALL CustomerService.getProperty(customerKey,fieldName,fieldNumber,fieldOption,dataField)
                    IF EB.SystemTables.getEtext() = '' THEN
                        customerMnemonic = dataField<DataField.enrichment>
                    END ELSE ;* error handling
                        customerMnemonic = ''
                        EB.SystemTables.setEtext('')
                    END
                    YNEW.SWIFT.ADD = customerMnemonic
                    YNEW.SWIFT.ADD = FMT(YNEW.SWIFT.ADD,'12" "L')
                END
                YSWIFT.POS = INDEX(EB.SystemTables.getMessage(),DIVERT.LIST<DE.Config.SwiftDiversion.SdDivertAddress+1,DIVERT>,1)
                EB.SystemTables.setMessage(EB.SystemTables.getMessage()[1,YSWIFT.POS-1]:YNEW.SWIFT.ADD:EB.SystemTables.getMessage()[YSWIFT.POS+LEN(DIVERT.LIST<DE.Config.SwiftDiversion.SdDivertAddress+1,DIVERT>),LEN(EB.SystemTables.getMessage())])
            END
            IF DIVERT.LIST<DE.Config.SwiftDiversion.SdTrailerFormat+1,DIVERT> THEN
                EB.SystemTables.setMessage(EB.SystemTables.getMessage():DIVERT.LIST<DE.Config.SwiftDiversion.SdTrailerFormat+1,DIVERT>)
            END
            IF DIVERT.LIST<DE.Config.SwiftDiversion.SdAddDelimiters+1,DIVERT> = 'Y' THEN
                EB.SystemTables.setMessage(SOH:EB.SystemTables.getMessage():ETX)
            END
            MESSAGE.VAL = EB.SystemTables.getMessage()
            DIVERT.KEY = DIVERT.LIST<DE.Config.SwiftDiversion.SdOutwardRecord+1,DIVERT>
            IF INDEX(DIVERT.KEY,'<DATE>',1) NE 0 THEN
                START.POS = INDEX(DIVERT.KEY,'<DATE>',1)
                END.POS = START.POS + 6
                IF START.POS = 1 THEN
                    DIVERT.KEY = EB.SystemTables.getToday():DIVERT.KEY[END.POS,999]
                END ELSE
                    FIRST.PART = DIVERT.KEY[1,START.POS-1]
                    SECOND.PART = DIVERT.KEY[END.POS,999]
                    DIVERT.KEY = FIRST.PART:EB.SystemTables.getToday():SECOND.PART
                END
            END
            R.DIVERT = ''
            READU R.DIVERT FROM F.DIVERT,DIVERT.KEY ELSE R.DIVERT = ''
            CONVERT @VM TO CRLF IN R.DIVERT ;* GB0101155 S/E
            R.DIVERT := MESSAGE.VAL:CRLF
            WRITE R.DIVERT TO F.DIVERT,DIVERT.KEY
        CASE 1
            NULL
    END CASE
    AV1 = EB.SystemTables.getAv()
    R.HEAD(DE.Config.IHeader.HdrMsgDisp)<1,AV1> = 'ACK'
    R.HEAD(DE.Config.OHeader.HdrSendStamp)<1,AV1> = 'DIVERTED TO DISKFILE ':DIVERT.LIST<DE.Config.SwiftDiversion.SdOutwardFile+1,DIVERT>
    R.HEAD(DE.Config.OHeader.HdrDelRcvStamp)<1,AV1> = OCONV(DATE(),'D2E'):' ':OCONV(TIME(),'MTS')
    MATBUILD R.HEAD.REC FROM R.HEAD
    DE.Config.OHeaderWrite(HDR.KEY,R.HEAD.REC,'')
*
* Delete the message the ACK relates to from the outward message file
*
    DE.ModelBank.OMsgDelete(R.KEY,'')
*
* Add message details to history file if appropiate
*
    GOSUB UPDATE.HISTORY
    IF R.PARM(DE.Config.Parm.ParMaintainHistory) = 'Y' THEN
        MATBUILD R.HEAD.REC FROM R.HEAD
        DE.Config.OHeaderArchWrite(HDR.KEY,R.HEAD.REC,'')
    END

*
* Remove key from the priority file
*
    GOSUB DELETE.PRIORITY.KEY
    RESEND.MESSAGE = ''       ;* Do not resend message - diverted
    MESSAGE.DIVERTED = 1
RETURN
*
*------------------------------------------------------------------------
READ.AUDIT:
*==========
** Read the audit record
**
LCK25:
    DE.Config.MsgAuditLock(AUDIT.KEY,R.AUDIT.REC,ER,'E','')
    MATPARSE R.AUDIT FROM R.AUDIT.REC
    IF ER = 'RECORD LOCKED' THEN
        EB.SystemTables.setText('FILE=F.DE.MSG.AUDIT ID=':AUDIT.KEY)
        EB.DataAccess.Lck1()
        GOTO LCK25
    END ELSE
        IF ER THEN
            MAT R.AUDIT = TRUE
        END
    END
*
RETURN
*
END
