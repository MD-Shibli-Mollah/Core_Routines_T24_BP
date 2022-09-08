* @ValidationCode : MjoxMDM0NjEyNTgyOkNwMTI1MjoxNTgyMDM0OTMyODM1OnN0YW51c2hyZWU6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAzLjIwMjAwMjEyLTA2NDY6LTE6LTE=
* @ValidationInfo : Timestamp         : 18 Feb 2020 19:38:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : stanushree
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.20200212-0646
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


* Version 22 07/06/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>15508</Rating>
*-----------------------------------------------------------------------------
$PACKAGE DE.Interface
SUBROUTINE DE.I.ST200.ATE.UNIX
*
* Interface module for inward SWIFT
*
* Switch   : ST200
*
* Protocol : ATE (Asynchronous Terminal Emulation)
*
* Host     : GENERIC UNIX
*
************************************************************************
* This routine processes inward SWIFT messages from ST200 to GLOBUS and
* also forwards SRN level acknowledgements from outgoing messages.
*
* Modification history
*
* Based on original DE.I.CC.SWIFT code from P9955 to ST200. The front end
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
* Modified May   1991 (GB9100099) for SWIFT II capability
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
*
* 01/07/92 - GB9200584
*            Diversion of selected message types to ascii disk files
*            for onward transfer to other packages such as nostro recon
*
* GB9301815 - 16-12-93
*           - Merge of Aura Interface from BDG
*
* 18/11/94 - GB9401261
*            Cater for STTX ACK
*
* 31/05/96 - GB9600715
*            When out puting the record for SWIFT diversion the SOH and ETXX
*            are not being added because they are being added to the variable
*            MESSAGE rather than REPLY, which is the one written away.
*
* 18/03/97 - GB9700325
*            When an ACK is received, the "to.address" on the header
*            record is overwritten by the "from.address".  This error
*            was introduced in G6.1.00.
*
* 19/03/97 - GB9700330
*            Remove DE.O.MSG.COUNT and DE.I.MSG.COUNT files - these are
*            now obsolete
*
* 04/08/97 - GB9700885
*            call DE.GET.KEY to return unique key which includes @USERNO
*
* 09/03/99 - GB9900319 / G99910039 / G9990055
*            Translate receiver's SWIFT address into Globus Company code.
*
* 15/06/00 - GB0001458
*            Change equ for ORN from 9 to 15
*
* 11/05/01 - GB0101307
*            Amend program to call a new subroutine DE.BUILD.DIVERT.LIST
*            instead of duplicating code. Allow 'DIVERTED' messages to
*            pass through for further processing
*
* 16/05/03 - EN_10001784
*            OSN Numbers.  Introduce OSN numbers in the DE.SENT.SWIFT
*            application.
*
* 25/08/04 - BG_100007070
*            Pass on the phantom name while calling the routine,
*            DE.COMMON.INITIALISATION.  Its used to read the records
*            of F.DE.PHANTOM.
*
* 21/08/06 - EN_10003048
*            DE.O.HISTORY.QUEUE file re-structure
*
* 15/09/10 - 42147: Amend Infrastructure routines to use the Customer Service API's
*
* 30/09/15 - Enhancement 1265068
*		   - Task 1469274
*		   - Routine Incorporated
*
* 16/01/20 - Task 3538382
*	     	 Correction for regression errors
************************************************************************
    $USING DE.Config
    $USING EB.Utility
    $USING DE.Reports
    $USING EB.SystemTables
    $USING DE.API
    $USING EB.DataAccess
    $USING DE.Interface
    $USING DE.Outward
    $USING EB.TransactionControl
    $USING DE.ModelBank
    $USING DE.Clearing
    $USING PY.Config

    $INSERT I_CustomerService_AddressIDDetails
    $INSERT I_CustomerService_SWIFTDetails

*
*
    EQU TRUE TO 1
    EQU FALSE TO 0
    V1 = ''
    DEFFUN CHARX(V1)

    DIM R.PARM(DE.Config.Parm.ParDim+9), R.HEAD(EB.SystemTables.SysDim), AR.HEAD(EB.SystemTables.SysDim), R.AUDIT(DE.Config.MsgAudit.AdtDim+9)
    RCV.TIMEOUT =1  ;* 10 Secs in tenths
    RCV.RETRIES = 15
    PROGRAM.TERMINATING = FALSE
    ER = FALSE
    ANSWER = ''
*
    INTERACTIVE = ''
    TERM.REASON = "Normal"
    INTERACTIVE = 'DE.I.CC.SWIFT'       ;* BG_100007070 -s/e
    DE.API.CommonInitialisation(INTERACTIVE)
*
    CRLF = CHARX(013):CHARX(010)
    FFFF = CHARX(012):CHARX(012)
    CR = CHARX(013)
    LF = CHARX(010)
    SOH = CHARX(001)
    ETX = CHARX(003)
    DE.Clearing.setRSysLog(DE.Reports.Syslog.SysCarrier, "SWIFT")
    DE.Clearing.setRSysLog(DE.Reports.Syslog.SysInOut, "I")
    DE.Clearing.setRSysLog(DE.Reports.Syslog.SysLineNo, "1")
    DE.Clearing.setRSysLog(DE.Reports.Syslog.SysText, "")
    RCV.TIMEOUT = 1
    RCV.RETRIES = 15
    SND.TIMEOUT = 1
    SND.RETRIES = 5
    OUT.SEQ.KEY = "OUT-SWIFT"
    IN.SEQ.KEY = "IN-SWIFT"
    MESSAGE.DIVERTED = 0
    ALLOW.PASS.THRU = 0
*
* Open the voc file
*
    F.VOC = ""
    OPEN "","VOC" TO F.VOC ELSE STOP "CANT OPEN VOC FILE"
    R.VOC = ""
    READ R.VOC FROM F.VOC,"F.COMM.BUFFER" ELSE R.VOC = ""
    COMMFILE = R.VOC<2>
*
* Open UNIX communications buffer
*

    DE.Interface.CommBuffer.Delete("SWIFT.IN.RES")
    DE.Interface.CommBuffer.Delete("SWIFT.IN")
*
* GB9200584
*
* Open the SWIFT diversion file and see if there are any instructions to
* divert certain message types. The file will be selected and the list
* of divertable messages built once only at startup.
*
    DE.Interface.BuildDivertList(DIVERT.LIST,DIVERSIONS)
*
* END GB9200584
*
*
* Open the parameter file
*
    F.JOURNAL.LOC = '' ; EB.DataAccess.Opf("F.JOURNAL",F.JOURNAL.LOC)
    EB.SystemTables.setFJournal(F.JOURNAL.LOC)
*
* Check that shutdown carrier control on parameter file is blank or 'C'
*
    MAT R.PARM = ''
    ER = ''
    R.PARM.DYN = DE.Config.Parm.Read('SYSTEM.STATUS', ER)
    MATPARSE R.PARM FROM R.PARM.DYN
    EB.SystemTables.setEtext('')
    LOCATE 'SWIFT' IN R.PARM(DE.Config.Parm.ParInwardCarriers)<1,1> SETTING CARRIER.POS ELSE
        DE.Reports.SqMsg('Carrier not available. Program cannot be run.',0)
        RETURN
    END
    IF R.PARM(DE.Config.Parm.ParShutInCarrier)<1,CARRIER.POS> THEN
        IF R.PARM(DE.Config.Parm.ParShutInCarrier)<1,CARRIER.POS> <> 'C' THEN
            IF R.PARM(DE.Config.Parm.ParShutInCarrier)<1,CARRIER.POS> = 'A' THEN DE.Reports.SqMsg('Program already active.',0)
            ELSE
                DE.Reports.SqMsg('Carrier closing down. Program cannot be run.',0)
                IF R.PARM(DE.Config.Parm.ParShutInCarrier)<1,CARRIER.POS> <> 'E' THEN
LCK01:
                    MAT R.PARM = ''
                    DE.Config.ParmLock('SYSTEM.STATUS', R.PARM.DYN, ER, 'E','')
                    MATPARSE R.PARM FROM R.PARM.DYN
                    IF ER EQ 'RECORD LOCKED' THEN
                        EB.SystemTables.setText('F.DE.PARM, SYSTEM.STATUS')
                        EB.DataAccess.Lck1()
                        GOTO LCK01
                    END ELSE
                    	EB.SystemTables.setEtext('')
                    END
                    R.PARM(DE.Config.Parm.ParShutInCarrier)<1,CARRIER.POS> = 'C'
                    MATBUILD R.PARM.DYN FROM R.PARM
                    DE.Config.ParmWrite('SYSTEM.STATUS', R.PARM.DYN,'')
                END
            END
            RETURN
        END
    END
*
* Update status on parameter file to 'A' - active
*
LCK2:
    MAT R.PARM = ''
    ER = ''
    DE.Config.ParmLock('SYSTEM.STATUS', R.PARM.DYN, ER, 'E', '')
    MATPARSE R.PARM FROM R.PARM.DYN
    IF ER EQ 'RECORD LOCKED' THEN
        EB.SystemTables.setText('F.DE.PARM, SYSTEM.STATUS')
        EB.DataAccess.Lck1()
        GOTO LCK2
    END ELSE
    	EB.SystemTables.setEtext('')
    END
    R.PARM(DE.Config.Parm.ParShutInCarrier)<1,CARRIER.POS> = 'A'
    MATBUILD R.PARM.DYN FROM R.PARM
    DE.Config.ParmWrite('SYSTEM.STATUS', R.PARM.DYN,'')
    TERM.REASON = "Normal"
    GOSUB UPDATE.PHANTOM.LOG
*
* Setup debug field to determine whether to print messages
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
    IF DE.Clearing.getVDebug() THEN EXECUTE 'COMO ON DE.I.CC.SWIFT'
*
* Open files
*
    F.DE.SYSLOG.LOC = "" ; EB.DataAccess.Opf("F.DE.SYSLOG",F.DE.SYSLOG.LOC)
    DE.Clearing.setFDeSysLog(F.DE.SYSLOG.LOC)
*
* HD9401305
*



* Set operating mode to batch (in case any calling subroutines use
* R.READ, R.WRITE, etc.)
*
    tmp=EB.SystemTables.getRSpfSystem(); tmp<EB.SystemTables.Spf.SpfOpMode>='B'; EB.SystemTables.setRSpfSystem(tmp)
*
    IF DE.Clearing.getVDebug() THEN CRT 'DE.I.ST200.ATE.UNIX RUNNING'
    DE.Reports.WriteSyslog(0,'ST200 Inward message handler started.')
*
* Attempt to exchange startup message with the controller process
*
    BUFFER = ''
    ER = ''
    DE.Interface.CommBufferLock('SWIFT.ACTIVE', BUFFER, ER, 'E', '')
    EB.SystemTables.setEtext('')
    IF ER EQ 'RECORD LOCKED' THEN
        IF DE.Clearing.getVDebug() THEN PRINT 'DE.SWIFT.LINE.HANDLER communications process active'
        EB.DataAccess.FRelease('F.COMM.BUFFER', '', '')
    END ELSE
    	IF ER THEN
        	EB.DataAccess.FRelease('F.COMM.BUFFER', '', '')
        	IF DE.Clearing.getVDebug() THEN CRT 'DE.SWIFT.LINE.HANDLER was not active - starting it now'
        	ERR.MSG = ''
        	DE.Interface.SwiftStartup(ERR.MSG)
        	IF ERR.MSG THEN
            	REPLY = ERR.MSG
            	GOSUB BADRC
            	TERM.REASON = "NO HANDLER"
            	GOTO V$EXIT
        	END
        END
        SLEEP 10
    END
    SLEEP 5
*
* Main processing loop.
* ---------------------
    LOOP
*
* Get an incoming message if any
*
        REPLY = ""
        REPLY.LENGTH = 0
        FIRSTR = TRUE
        IF DE.Clearing.getVDebug() THEN CRT 'Each dot is one read of the line. Press any key to terminate the program.'
        LOOP
            GOSUB CHECK.SYSTEM.SHUTDOWN
            IF PROGRAM.TERMINATING THEN GOTO V$EXIT
            IF DE.Clearing.getVDebug() THEN
                IF FIRSTR THEN
                    CRT 'Receiving'
                    FIRSTR = FALSE
                END ELSE CRT '.':
            END
            REPLY = ""
            GOSUB ST200I
        WHILE REPLY = ""
            IF DE.Clearing.getVDebug() THEN
                INPUT YN,-1
                IF YN THEN
                    CRT ''
                    INPUT YN,1          ;* FLUSH IT
                    GOTO V$EXIT
                END
            END
            SLEEP R.PARM(DE.Config.Parm.ParWaitTime)
            GOSUB UPDATE.PHANTOM.LOG
        REPEAT
        IF DE.Clearing.getVDebug() THEN CRT ''          ;* New line
*
* Perform basic conversion on input.
*
        IF DE.Clearing.getVDebug() THEN CRT REPLY
        OUTPUT.REPLY = REPLY
        IF OUTPUT.REPLY = '' THEN
            OUTPUT.REPLY = '""'
        END ELSE
            CONVERT CR TO @VM IN OUTPUT.REPLY
            CONVERT LF TO '' IN OUTPUT.REPLY
        END
*
* Allocate the next sequence number
*
        IN.COUNT = ""
        ER = ''
        IN.COUNT = EB.SystemTables.Locking.Read(IN.SEQ.KEY, ER)
        EB.SystemTables.setEtext('')
        SOSN = FMT(IN.COUNT,"5'0'R")
        IF DE.Clearing.getVDebug() THEN CRT 'SOSN=':SOSN
*
        AUDIT.KEY = 'S.I.':SOSN
LCK25:
        ER = ''
        DE.Config.MsgAuditLock(AUDIT.KEY, R.AUDIT.DYN, ER, 'E', '')
        MATPARSE R.AUDIT FROM R.AUDIT.DYN
        IF ER EQ 'RECORD LOCKED' THEN
            EB.SystemTables.setText('F.DE.MSG.AUDIT, ':AUDIT.KEY)
            EB.DataAccess.Lck1()
            GOTO LCK25
        END ELSE
            MAT R.AUDIT = TRUE
            EB.SystemTables.setEtext('')
        END
        IF NOT(R.AUDIT(DE.Config.MsgAudit.AdtRecordArchived)) THEN
            DE.Reports.WriteSyslog(2,'ST200 Inward message handler. Unarchived audit file record & encountered.^':AUDIT.KEY)
            TERM.REASON = 'ERR 2 AUDIT'
            GOSUB SEND.NAK
            GOTO V$EXIT
        END
        MAT R.AUDIT = ''
*
* Continue processing according to response
*
        IF REPLY[1,3] = "#ST" THEN
*
* Check received sequence number matches expected sequence number
*
            RCV.SEQ.NUM = REPLY[4,5]
            IF RCV.SEQ.NUM <> SOSN THEN
                DE.Reports.WriteSyslog(104,'ST200 Inward message handler. Unexpected message sequence number received: & expected: &.^':RCV.SEQ.NUM:'@':SOSN)
                TERM.REASON = 'ERR 104 SEQ'
                GOTO V$EXIT
            END
*
* Determine if input is a message or a logical acknowledgment
*
            IF NETWORK = 1 THEN
                CARRIER.ACK.NAK = REPLY[11,3]
            END ELSE
                BEGIN CASE
                    CASE INDEX(REPLY,'{451:0}{108:',1)
                        CARRIER.ACK.NAK = 'ACK'
                    CASE INDEX(REPLY,'{451:0}{311:ACK',1)       ;* STTX ack
                        CARRIER.ACK.NAK = 'ACK'
                    CASE INDEX(REPLY,'{451:1}',1)
                        CARRIER.ACK.NAK = 'NAK'
                    CASE 1
                        CARRIER.ACK.NAK = 'MSG'
                END CASE
            END
            IF DE.Clearing.getVDebug() THEN PRINT 'CARRIER.ACK.NAK = ':CARRIER.ACK.NAK
            MSG.TYPE = ''
            BEGIN CASE
                CASE CARRIER.ACK.NAK = 'ACK'
                    GOSUB CARRIER.ACK
                CASE CARRIER.ACK.NAK = 'NAK'
                    GOSUB CARRIER.NAK
                CASE 1
                    CARRIER.ACK.NAK = 'MSG'
                    GOSUB INCOMING.SWIFT.MESSAGE
            END CASE
        END ELSE
*
* Invalid response - write to system log.
* ST200
*
            DE.Reports.WriteSyslog(108,'ST200 Inward message handler. Invalid message received: &.^':OUTPUT.REPLY)
            TERM.REASON = 'ERR 108 MESSAGE'
            PROGRAM.TERMINATING = TRUE
        END
*
* Prompt for manual exit
*
        IF DE.Clearing.getVDebug() THEN
            DE.Reports.SqYonMsg('Do you wish to process another message',ANSWER)
            IF ANSWER = 'NO' THEN
                PROGRAM.TERMINATING = TRUE
                TERM.REASON = 'USER STOP'
            END
        END
    UNTIL PROGRAM.TERMINATING
    REPEAT
*
* Unique exit point to ensure tidy termination.
*
V$EXIT:
    IF DE.Clearing.getVDebug() THEN CRT ''
    IF DE.Clearing.getVDebug() THEN
        PRINT "Press any key to continue..."
        INPUT ANS,1
    END
    IF DE.Clearing.getVDebug() THEN CRT 'Detaching... '
    BUFFER = "*** SHUTDOWN ***":FFFF
    GOSUB ST200O
*
* Log termination.
*
LCK14:
    MAT R.PARM = ''
    ER = ''
    DE.Config.ParmLock('SYSTEM.STATUS', R.PARM.DYN, ER, 'E', '')
    MATPARSE R.PARM FROM R.PARM.DYN
    IF ER EQ 'RECORD LOCKED' THEN
        EB.SystemTables.setText('F.DE.PARM, SYSTEM.STATUS')
        EB.DataAccess.Lck1()
        GOTO LCK14
    END ELSE
        EB.SystemTables.setEtext('')
    END
    R.PARM(DE.Config.Parm.ParShutInCarrier)<1,CARRIER.POS> = 'C'
    MATBUILD R.PARM.DYN FROM R.PARM
    DE.Config.ParmWrite('SYSTEM.STATUS', R.PARM.DYN, '')
    DE.Reports.WriteSyslog(101,'ST200 Inward message handler stopped.')
    GOSUB UPDATE.PHANTOM.LOG
    IF DE.Clearing.getVDebug() THEN EXECUTE 'COMO OFF'
*
* Set operating mode back to 'O' - online
*
    tmp=EB.SystemTables.getRSpfSystem(); tmp<EB.SystemTables.Spf.SpfOpMode>='O'; EB.SystemTables.setRSpfSystem(tmp)
RETURN
*
*************************************************************************
*
* Carrrier ACK.
*
* Positive acknowledgment - format
*
* ACK/hhmm/SRNcrlf
*
* where SRN = SWIFT system reference number (19 chars)
* -----------------------------------------------------------------------
CARRIER.ACK:
    GOSUB COMMON.CARRIER.ACK.NAK.BIT
    IF PROGRAM.TERMINATING THEN RETURN
*
* Update header record
*
* PIF GB9500945
* Set the msg.disp field to ACK or ACK MANUALLY SENT
    AV1 = EB.SystemTables.getAv()
    BEGIN CASE
        CASE R.HEAD(DE.Config.IHeader.HdrMsgDisp)<1,AV1>[1,1] = 'W'
            R.HEAD(DE.Config.IHeader.HdrMsgDisp)<1,AV1> = R.HEAD(DE.Config.IHeader.HdrMsgDisp)<1,AV1>[2,99]
        CASE R.HEAD(DE.Config.IHeader.HdrMsgDisp)<1,AV1>[1,6] = ""
            R.HEAD(DE.Config.IHeader.HdrMsgDisp)<1,AV1> = "ACK - MANUALLY SENT"
* HD9502368 / GB9500977
* Remove the message ID from the REPAIR queue
            ADD.OR.DEL = 1
            R.REPAIR = R.KEY
            DE.Outward.UpdateORepair(R.REPAIR,ADD.OR.DEL)
* End HD9502368 / GB9500977
    END CASE
    IF NETWORK = 1 THEN
        R.HEAD(DE.Config.IHeader.HdrDelRcvStamp)<1,AV1> = OCONV(TIME(),'MTS')
        R.HEAD(DE.Config.IHeader.HdrFromAddress)<1,AV1> = REPLY[20,19]
    END ELSE
        R.HEAD(DE.Config.IHeader.HdrDelRcvStamp)<1,AV1> = REPLY[INDEX(REPLY,'{177:',1)+5,10]
        R.HEAD(DE.Config.IHeader.HdrFromAddress)<1,AV1> = REPLY[INDEX(REPLY,'{1:F21',1)+6,12]
    END
    MATBUILD R.HEAD.DYN FROM R.HEAD
    DE.Config.OHeaderWrite(HDR.KEY, R.HEAD.DYN, '')

*
* Update the F.DE.O.HEADER.ARCH if MAINTAIN.HISTORY=Y in DE.PARM
* HD9401305
*

    IF R.PARM(DE.Config.Parm.ParMaintainHistory) = 'Y' THEN
        BEGIN CASE
            CASE AR.HEAD(DE.Config.IHeader.HdrMsgDisp)<1,AV1>[1,1] = 'W'
                AR.HEAD(DE.Config.IHeader.HdrMsgDisp)<1,AV1> = AR.HEAD(DE.Config.IHeader.HdrMsgDisp)<1,AV1>[2,99]
            CASE AR.HEAD(DE.Config.IHeader.HdrMsgDisp)<1,AV1>[1,6] = "REPAIR"
                AR.HEAD(DE.Config.IHeader.HdrMsgDisp)<1,AV1> = "ACK - MANUALLY SENT"
        END CASE
        IF NETWORK = 1 THEN
            AR.HEAD(DE.Config.IHeader.HdrDelRcvStamp)<1,AV1> = OCONV(TIME(),'MTS')
            AR.HEAD(DE.Config.IHeader.HdrFromAddress)<1,AV1> = REPLY[20,19]
        END ELSE
            AR.HEAD(DE.Config.IHeader.HdrDelRcvStamp)<1,AV1> = REPLY[INDEX(REPLY,'{177:',1)+5,10]
            AR.HEAD(DE.Config.IHeader.HdrFromAddress)<1,AV1> = REPLY[INDEX(REPLY,'{1:F21',1)+6,12]
        END
        MATBUILD AR.HEAD.DYN FROM AR.HEAD
        DE.Config.OHeaderArchWrite(HDR.KEY, AR.HEAD.DYN, '')
    END


*
* Write secondary key to SRN
*
    IF NETWORK = 1 THEN
        DE.ModelBank.SrnWrite(REPLY[20, 19],R.KEY:'.':O.AUDIT.KEY,'')
    END ELSE
        REC.ID = REPLY[INDEX(REPLY,'{1:F21',1)+6,22]
        DE.ModelBank.SrnWrite(REC.ID, R.KEY:'.':O.AUDIT.KEY,'')
    END
*
* Delete the message the ACK relates to from the outbound message file
*
    DE.ModelBank.OMsgSwiftDelete(R.KEY, '')
*
* Update the sent file with the delivery key.message number
*
    tmp=EB.SystemTables.getRSpfSystem(); tmp<EB.SystemTables.Spf.SpfOpMode>='O'; EB.SystemTables.setRSpfSystem(tmp)
** EN_10001784 -S
    DEL.KEY = REPLY[20,19]
    OSN.NO = REPLY[INDEX(REPLY,'{1:F21',1)+23,6]
    R.REC = DEL.KEY:@FM:OSN.NO
*      CALL F.WRITE("F.DE.SENT.SWIFT",R.KEY,REPLY[20,19])
    DE.Config.SentSwiftWrite(R.KEY, R.REC, '')
** EN_10001784 -E
    EB.TransactionControl.JournalUpdate(R.KEY)
    tmp=EB.SystemTables.getRSpfSystem(); tmp<EB.SystemTables.Spf.SpfOpMode>='B'; EB.SystemTables.setRSpfSystem(tmp)
    GOSUB SEND.ACK
RETURN
*
* Carrier NAK
*
* Negative acknowledgment - format
*
* NAK/hhmm/SRN/error code(/error code)(/error code)/SWIFT action code
*
* or
* NAK/hhmm/pseudo SRN/override key/H10
* -----------------------------------------------------------------------
CARRIER.NAK:
    GOSUB COMMON.CARRIER.ACK.NAK.BIT
    IF PROGRAM.TERMINATING THEN RETURN
*
* Update header record.  If message has been resubmitted or rerouted, it
* will become just RESUBMITTED or REROUTED, otherwise it will go into
* repair.
*
    AV1 = EB.SystemTables.getAv()
    IF FIELD(R.HEAD(DE.Config.IHeader.HdrMsgDisp)<1,AV1>,'-',2) THEN
        IF R.HEAD(DE.Config.IHeader.HdrMsgDisp)<1,AV1>[1,1] = 'W' THEN R.HEAD(DE.Config.IHeader.HdrMsgDisp)<1,AV1> = FIELD(R.HEAD(DE.Config.IHeader.HdrMsgDisp)<1,AV1>,'-',2)
        MATBUILD R.HEAD.DYN FROM R.HEAD
        DE.Config.OHeaderWrite(HDR.KEY, R.HEAD.DYN, '')
    END ELSE
        R.HEAD(DE.Config.IHeader.HdrMsgDisp)<1,AV1> = "REPAIR"
        IF NETWORK = 1 THEN
            R.HEAD(DE.Config.IHeader.HdrFromAddress)<1,AV1> = REPLY[20,19]
            ERROR.CODES = REPLY[40,2000]
            ERROR.CODES = FIELD(ERROR.CODES,CRLF,1)
        END ELSE
            R.HEAD(DE.Config.IHeader.HdrFromAddress)<1,AV1> = REPLY[15,12]
            ERROR.CODES = REPLY[INDEX(REPLY,'{405:',1)+5,3]
        END
        IF ERROR.CODES = '' THEN
            R.HEAD(DE.Config.IHeader.HdrMsgErrorCode)<1,AV1> = 'NAK - ERROR CODE NOT FOUND'
        END ELSE
            R.HEAD(DE.Config.IHeader.HdrMsgErrorCode)<1,AV1> = "NAK &#":ERROR.CODES
        END
        MATBUILD R.HEAD.DYN FROM R.HEAD
        DE.Config.OHeaderWrite(HDR.KEY, R.HEAD.DYN, '')
*
* Write message to repair file
*
        R.REPAIR = R.KEY
        DE.Outward.UpdateORepair(R.REPAIR,'')

* End HD9502368 / GB9500977
    END
    GOSUB SEND.ACK
RETURN
*
* Positive or negative acknowledgment - both have a trailer of
*
* MFID:nnnnn MT:yyy.......
*
* where nnnnn is the MISN number
* -----------------------------------------------------------------------
COMMON.CARRIER.ACK.NAK.BIT:
*
* Extract data from msg.
*
    IF NETWORK = 1 THEN
        SRN.POS = INDEX(REPLY,'/',2)+1
        SRN.KEY = REPLY[SRN.POS,19]
        CARRIER.SEQ.NUM = SRN.KEY[5]
*
* Get audit file key.
*
        IF MSG.TYPE = '067' THEN
            TRAILER.POS = INDEX(REPLY,"-SYS",1)
            IF TRAILER.POS = 0 THEN
                DE.Reports.WriteSyslog(110,'ST200 Inward message handler. Garbled MT067 received: &.^':OUTPUT.REPLY)
                TERM.REASON = 'ERR 110 MESSAGE'
                PROGRAM.TERMINATING = TRUE
                RETURN
            END
            ER = ''
            R.KEY = DE.ModelBank.Srn.Read(SRN.KEY, ER)
            IF ER THEN
                DE.Reports.WriteSyslog(110,'ST200 Inward message handler. MT067 received but SRN.KEY= & missing from F.DE.SRN.^':SRN.KEY)
                TERM.REASON = 'ERR 110 MESSAGE'
                PROGRAM.TERMINATING = TRUE
                RETURN
            END
            O.AUDIT.KEY = R.KEY[9]
        END ELSE
            TRAILER.POS = INDEX(REPLY,"MFID",1)
            IF TRAILER.POS = 0 THEN
                DE.Reports.WriteSyslog(110,'ST200 Inward message handler. Garbled carrier ACK/NAK received: &.^':OUTPUT.REPLY)
                TERM.REASON = 'ERR 110 MESSAGE'
                PROGRAM.TERMINATING = TRUE
                RETURN
            END
            ALT.KEY = REPLY[TRAILER.POS + 5,5]
            O.AUDIT.KEY = 'S.O.':ALT.KEY
        END
*
* Extract error codes if any.
*
        ERR.POS = SRN.POS+20
        CARRIER.ERR.TXT = REPLY[ERR.POS,TRAILER.POS-ERR.POS-2]

    END ELSE

*
* SWIFT II
*
        SRN.POS = INDEX(REPLY,'{1:F21',1)+6
        SRN.KEY = REPLY[SRN.POS,22]
        CARRIER.SEQ.NUM = REPLY[INDEX(REPLY,'{108:',1)+5,5]
*
* Get audit file key.
*
        BEGIN CASE
            CASE MSG.TYPE = '015' OR MSG.TYPE = '019'
                TRAILER.POS = INDEX(REPLY,"{SYS",1)
                IF TRAILER.POS = 0 THEN
                    DE.Reports.WriteSyslog(110,'ST200 Inward message handler. Garbled MT067 received: &.^':OUTPUT.REPLY)
                    TERM.REASON = 'ERR 110 MESSAGE'
                    PROGRAM.TERMINATING = TRUE
                    RETURN
                END
                ER = ''
                R.KEY = DE.ModelBank.Srn.Read(SRN.KEY, ER)
                IF ER THEN
                    DE.Reports.WriteSyslog(110,'ST200 Inward message handler. MT067 received but SRN.KEY= & missing from F.DE.SRN.^':SRN.KEY)
                    TERM.REASON = 'ERR 110 MESSAGE'
                    PROGRAM.TERMINATING = TRUE
                    RETURN
                END
                O.AUDIT.KEY = R.KEY[9]
                CARRIER.ERR.TXT = 'UNDELIVERED ':MSG.TYPE:' RECEIVED'
            CASE 1
                MUR.POS = INDEX(REPLY,"{108:",1)
                IF MUR.POS = 0 THEN
                    DE.Reports.WriteSyslog(110,'ST200 Inward message handler. Garbled carrier ACK/NAK received: &.^':OUTPUT.REPLY)
                    TERM.REASON = 'ERR 110 MESSAGE'
                    PROGRAM.TERMINATING = TRUE
                    RETURN
                END
                ALT.KEY = REPLY[MUR.POS+5,5]
                O.AUDIT.KEY = 'S.O.':ALT.KEY
                CARRIER.ERR.TXT = ''
        END CASE
*
* Extract error codes if any.
*
        ERR.POS = INDEX(REPLY,'{405:',1)
        IF ERR.POS THEN CARRIER.ERR.TXT = REPLY[ERR.POS+5,INDEX(REPLY[ERR.POS+5,LEN(REPLY)],'}',1)-(ERR.POS+5)]
    END
*
* Get existing audit file record.
*
LCK27:
    ER = ''
    DE.Config.MsgAuditLock(O.AUDIT.KEY, R.AUDIT.DYN, ER, 'E', '')
    MATPARSE R.AUDIT FROM R.AUDIT.DYN
    IF ER EQ 'RECORD LOCKED' THEN
        EB.SystemTables.setText('F.DE.MSG.AUDIT, ':O.AUDIT.KEY)
        EB.DataAccess.Lck1()
        GOTO LCK27
    END ELSE
        IF ER THEN
            MAT R.AUDIT = ''
            TERM.REASON = 'ERR 203 AUDIT'
*
* GB9200126 - Following two lines to correct locking problem
*
            EB.DataAccess.FRelease('F.DE.MSG.AUDIT', O.AUDIT.KEY, '')
            GOSUB SEND.ACK
            PROGRAM.TERMINATING = TRUE
            DE.Reports.WriteSyslog(203,'ST200 Inward message handler. Carrier ACK/NAK received for MISN= & but audit file record & missing.^':ALT.KEY:'@':O.AUDIT.KEY)
            RETURN
        END
    END
*
* Get the corresponding header record.
*
    HDR.KEY = R.AUDIT(DE.Config.MsgAudit.AdtHeaderFileKey)
    EB.SystemTables.setAv(R.AUDIT(DE.Config.MsgAudit.AdtHeaderFileMvOffset))
    R.KEY = HDR.KEY:'.':EB.SystemTables.getAv()
    ER = ''
    R.HEAD.DYN = ''
    R.HEAD.DYN = DE.Config.OHeader.Read(HDR.KEY, ER)
    MATPARSE R.HEAD FROM R.HEAD.DYN
    IF ER THEN
        MAT R.HEAD = ''
        EB.SystemTables.setEtext('')
        DE.Reports.WriteSyslog(210,'ST200 Inward message handler. Message & not on header file &.^':HDR.KEY:'@':REPLY)
        TERM.REASON = 'ERR 210 HEADER'
        PROGRAM.TERMINATING = TRUE
        RETURN
    END
*
* Get the corresponding header record from the DE.O.HEADER.ARCH file.
* HD9401305

    IF R.PARM(DE.Config.Parm.ParMaintainHistory) = 'Y' THEN
        ER = ''
        AR.HEAD.DYN = DE.Config.OHeaderArch.Read(HDR.KEY, ER)
        MATPARSE AR.HEAD FROM AR.HEAD.DYN
        IF ER THEN
            MAT AR.HEAD = ''
            EB.SystemTables.setEtext('')
            DE.Reports.WriteSyslog(210,'ST200 Inward message handler. Message & not on header arch. file &.^':HDR.KEY:'@':REPLY)
            TERM.REASON = 'ERR 210 HEADER.ARCH'
            PROGRAM.TERMINATING = TRUE
            RETURN
        END
    END
*
* Update audit record with ACK/NAK details.
*
    R.AUDIT(DE.Config.MsgAudit.AdtCarrierSeqNum)<-1> = CARRIER.SEQ.NUM
    R.AUDIT(DE.Config.MsgAudit.AdtCarrierAckNak)<-1> = CARRIER.ACK.NAK
    R.AUDIT(DE.Config.MsgAudit.AdtCarrierErrorText)<-1> = CARRIER.ERR.TXT
    MATBUILD R.AUDIT.DYN FROM R.AUDIT
    DE.Config.MsgAuditWrite(O.AUDIT.KEY, R.AUDIT.DYN, '')
*
* Delete the message key from the AWAK file
*
    AWAK.ID = 'SWIFT-':R.KEY; R.AWAK = '';AWAK.ERR = ''
    R.AWAK = DE.Config.OAwak.Read(AWAK.ID, AWAK.ERR)

    IF NOT(AWAK.ERR) THEN
        DE.Config.OAwakDelete(AWAK.ID, '')
    END ELSE
        DE.Reports.WriteSyslog(203,'ST200 Inward message handler. AWAK record & missing.^':R.KEY)
    END
RETURN
*
* Incoming SWIFT message.
*
* Message received - format begins
*
* hhmm ORNcrlfhhmm SRNcrlfmmm ppcrlf....
*
* where hhmm = output/input time
*       mmm = SWIFT message type
*       pp = SWIFT message priority
*       ORN = SWIFT output reference number
*       SRN = SWIFT system reference number
* -----------------------------------------------------------------------
INCOMING.SWIFT.MESSAGE:
*
* Seperate fields from message
*
    IF NETWORK = 1 THEN
        WORK.FIELD = FIELD(REPLY,CRLF,2)
        WORK.FIELD = WORK.FIELD[2,2000]
        REC.TIME = WORK.FIELD[1,4]
        ORN = WORK.FIELD[6,2000]
        CARRIER.SEQ.NUM = ORN[5]
        CARRIER.ERR.TXT = ''
        WORK.FIELD = FIELD(REPLY,CRLF,3)
        WORK.FIELD = WORK.FIELD[2,2000]
        SENT.TIME = WORK.FIELD[1,4]
        SRN = WORK.FIELD[6,2000]
        WORK.FIELD = FIELD(REPLY,CRLF,4)
        WORK.FIELD = WORK.FIELD[2,2000]
        MSG.TYPE = WORK.FIELD[1,3]
        PRIORITY = WORK.FIELD[5,2]
        END.POS = INDEX(REPLY,CRLF,4)
        EB.SystemTables.setMessage(REPLY[END.POS + 2,2000])
    END ELSE
        WORK.FIELD = REPLY[INDEX(REPLY,'{2:',1)+3,LEN(REPLY)]
        SENT.TIME = WORK.FIELD[43,4]
        ORN = WORK.FIELD[15,28]         ;* GB0001458 S/E
        CARRIER.SEQ.NUM = REPLY[4,5]
        CARRIER.ERR.TXT = ''
        REC.TIME = WORK.FIELD[5,4]
        SRN = REPLY[15,22]
        MSG.TYPE = WORK.FIELD[2,3]
        PRIORITY = WORK.FIELD[47,1]
        START.OF.MESSAGE = '{4:':CRLF
        END.POS = INDEX(REPLY,START.OF.MESSAGE,1)
        EB.SystemTables.setMessage(REPLY[END.POS+5,2000])
    END
*
* Check fields are valid (e.g. right length and numeric if appropiate)
*
    IF NETWORK = 1 THEN
        IF LEN(ORN) > 19 OR LEN(SRN) > 19 OR LEN(REC.TIME) > 4 OR LEN(SENT.TIME) > 4 OR LEN(MSG.TYPE) > 3 OR LEN(PRIORITY) > 2 OR NOT(NUM(REC.TIME)) OR NOT(NUM(SENT.TIME)) OR NOT(NUM(MSG.TYPE)) OR NOT(NUM(PRIORITY)) OR NOT(NUM(ORN[1,2])) OR NOT(NUM(ORN[15,5])) OR NOT(NUM(SRN[1,2])) OR NOT(NUM(SRN[15,5])) THEN
            GOSUB CHECK.CANCELLATION
            IF NOT(CAN.ACK.SENT) THEN
                DE.Reports.WriteSyslog(110,'ST200 Inward message handler. Invalid incoming SWIFT message received: &.^':OUTPUT.REPLY)
                TERM.REASON = 'ERR 110 MESSAGE'
                PROGRAM.TERMINATING = TRUE
            END
            CAN.ACK.SENT = FALSE
            RETURN
        END
    END ELSE
*
* If received message trailer contains SAI then this message has failed
* authentication on the ST200 and will be waiting there on the REAUTH
* queue. Options from there either ignore or reforward it to us with a
* new aut result or bypassed aut trailer SAB. Either way we ignore SAI.
*
        IF INDEX(REPLY,"{SAI:",1) THEN
            DE.Reports.WriteSyslog(111,"ST200 Inward message handler. SAI trailer found in incoming message MT":MSG.TYPE:". SRN=":SRN:" ignored.")
            HDR.KEY = ''
            GOSUB SEND.ACK
            RETURN
        END
        IF LEN(ORN) > 28 OR LEN(SRN) > 22 OR LEN(REC.TIME) > 4 OR LEN(SENT.TIME) > 4 OR LEN(MSG.TYPE) > 3 OR LEN(PRIORITY) > 2 OR NOT(NUM(REC.TIME)) OR NOT(NUM(SENT.TIME)) OR NOT(NUM(MSG.TYPE)) THEN
            IF DE.Clearing.getVDebug() THEN
                PRINT 'ORN = ':ORN
                PRINT 'SRN = ':SRN
                PRINT 'REC = ':REC.TIME
                PRINT 'SNT = ':SENT.TIME
                PRINT 'MSG = ':MSG.TYPE
                PRINT 'PRI = ':PRIORITY
            END
            GOSUB CHECK.CANCELLATION
            IF NOT(CAN.ACK.SENT) THEN
                DE.Reports.WriteSyslog(110,'ST200 Inward message handler. Invalid incoming SWIFT message received: &.^':OUTPUT.REPLY)
                TERM.REASON = 'ERR 110 MESSAGE'
                PROGRAM.TERMINATING = TRUE
            END
            CAN.ACK.SENT = FALSE
            RETURN
        END
    END
*
    IF NETWORK = 1 THEN
        BEGIN CASE
            CASE PRIORITY = "01"
                PRTY.KEY = "U"
            CASE PRIORITY = "11" OR PRIORITY = "12"
                PRTY.KEY = "P"
            CASE 1
                PRTY.KEY = "N"
        END CASE
    END ELSE
        IF PRIORITY = 'U' THEN PRTY.KEY = 'U' ELSE PRTY.KEY = 'N'
    END
*
* If message type is an MT067, then message is processed as for a NAK.
*
    IF MSG.TYPE = '067' OR MSG.TYPE = '015' OR MSG.TYPE = '019' THEN
        CARRIER.ACK.NAK = 'NAK'
        GOSUB COMMON.CARRIER.ACK.NAK.BIT
*
* Update header record
*
        AV1 = EB.SystemTables.getAv()
        R.HEAD(DE.Config.IHeader.HdrMsgDisp)<1,AV1> = 'REPAIR'
        IF NETWORK = 1 THEN
            R.HEAD(DE.Config.IHeader.HdrFromAddress)<1,AV1> = EB.SystemTables.getMessage()[10,19]
            ERROR.CODES = EB.SystemTables.getMessage()[30,2000]
            ERROR.CODES = FIELD(ERROR.CODES,CRLF,1)
        END ELSE
            R.HEAD(DE.Config.IHeader.HdrFromAddress)<1,AV1> = REPLY[15,12]
            ERROR.CODES = REPLY[INDEX(REPLY,'{405:',1)+5,3]
        END
        IF ERROR.CODES = '' THEN
            R.HEAD(DE.Config.IHeader.HdrMsgErrorCode)<1,AV1> = 'NAK - ERROR CODE NOT FOUND'
        END ELSE
            R.HEAD(DE.Config.IHeader.HdrMsgErrorCode)<1,AV1> = 'NAK &#':ERROR.CODES
        END
        MATBUILD R.HEAD.DYN FROM R.HEAD
        DE.Config.OHeaderWrite(HDR.KEY, R.HEAD.DYN, '')
*
* Write message to repair file
*
        R.REPAIR= R.KEY
        DE.Outward.UpdateORepair(R.REPAIR,'')
    END ELSE
*
* Build header record
*
        MAT R.HEAD = ""
        R.HEAD(DE.Config.IHeader.HdrMessageType) = MSG.TYPE
        R.HEAD(DE.Config.IHeader.HdrCarrierAddressNo) = "SWIFT.1"
        R.HEAD(DE.Config.IHeader.HdrDisposition) = "UNFORMATTED"
        R.HEAD(DE.Config.IHeader.HdrFromAddress) = ORN
        R.HEAD(DE.Config.IHeader.HdrDelRcvStamp) = REC.TIME[1,2]:':':REC.TIME[3,2]:':00'
        R.HEAD(DE.Config.IHeader.HdrToAddress) = SRN
        R.HEAD(DE.Config.IHeader.HdrSendStamp) = SENT.TIME[1,2]:':':SENT.TIME[3,2]:':00'
        R.HEAD(DE.Config.IHeader.HdrCarSeqNo) = REPLY[4,5]
        R.HEAD(DE.Config.IHeader.HdrPriority) = PRTY.KEY
        IF NETWORK <> 1 THEN
            IF INDEX(REPLY,'{SPD:',1) OR INDEX(REPLY,'{PDE:',1) OR INDEX(REPLY,'{PDM:',1) THEN R.HEAD(DE.Config.IHeader.HdrPosDupEntry) = 'PDE'
        END
* GB9900319 +
*
* Sender's Details - translate into customer number & cutomer company code
*
*
* Get customer number from the from address file by looking up the
* address concatfile.
* Customer type addresses are stripped of the logical terminal code in position 9.
*
        ADDRESS.CON.KEY = ORN[1,8]:ORN[10,3]
        ER1 = ''
        R.ADDRESS = PY.Config.SwiftAddress.Read(ADDRESS.CON.KEY, ER1)
        IF ER1 THEN
            ADDRESS.CON.KEY = ADDRESS.CON.KEY[1,8]
            R.HEAD(DE.Config.IHeader.HdrFromAddress) := '  ':ADDRESS.CON.KEY
            R.ADDRESS = ''
            R.ADDRESS = PY.Config.SwiftAddress.Read(ADDRESS.CON.KEY, ER1)
*
* See if the sender's id exists on the SWIFT book
*
            ADDRESS.CON.KEY = ORN[1,8]:ORN[10,3]
            ER2 = ''
            R.BOOK = DE.Config.SwiftBook.Read(ADDRESS.CON.KEY, ER2)
            IF ER2 THEN
                ADDRESS.CON.KEY = ORN[1,8]
                R.BOOK = ''
                R.BOOK = DE.Config.SwiftBook.Read(ADDRESS.CON.KEY, ER2)
            END
            R.HEAD(DE.Config.IHeader.HdrCustomerNo) = R.BOOK<1>
        END
        EB.SystemTables.setEtext('')
    END

    IF R.ADDRESS THEN
        IF FIELD(R.ADDRESS<1>,'.',2)[1,2] = 'C-' THEN
            R.HEAD(DE.Config.IHeader.HdrCusCompany) = FIELD(R.ADDRESS<1>,'.',1)
            R.HEAD(DE.Config.IHeader.HdrCustomerNo) = FIELD(R.ADDRESS<1>,'.',2)[3,99]
        END
    END
*
* Receiver's Details - company code
*
* Company type addresses are 9 or 12 characters including a logical terminal
* code in position 9.
    ADDRESS.CON.KEY = SRN[1,12]
    ER = ''
    R.ADDRESS = PY.Config.SwiftAddress.Read(ADDRESS.CON.KEY, ER)
    IF ER THEN
        ADDRESS.CON.KEY = ADDRESS.CON.KEY[1,9]
        R.HEAD(DE.Config.IHeader.HdrFromAddress) := '  ':ADDRESS.CON.KEY
        R.ADDRESS = ''
        R.ADDRESS = PY.Config.SwiftAddress.Read(ADDRESS.CON.KEY, ER)
    END
    EB.SystemTables.setEtext('')
    IF R.ADDRESS THEN
        R.HEAD(DE.Config.IHeader.HdrCompanyCode) = FIELD(R.ADDRESS<1>,'.',1)
    END
    IF R.HEAD(DE.Config.IHeader.HdrCompanyCode) = "" THEN
        R.HEAD(DE.Config.IHeader.HdrCompanyCode) = R.HEAD(DE.Config.IHeader.HdrCusCompany)
    END
* GB9900319 -
*
* Add control fields to the end of the header record
*
    R.HEAD(DE.Config.IHeader.HdrCurrNo) = 1
    R.HEAD(DE.Config.IHeader.HdrInputter) = '1_SYSTEM'
    TEMP.TIME = OCONV(TIME(),'MT')
    TEMP.DATE = OCONV(DATE(),'D2 E')
    R.HEAD(DE.Config.IHeader.HdrDateTime) = TEMP.DATE[7,2]:TEMP.DATE[4,2]:TEMP.DATE[1,2]:TEMP.TIME[1,2]:TEMP.TIME[4,2]
    R.HEAD(DE.Config.IHeader.HdrAuthoriser) = '1_SYSTEM'
    R.HEAD(DE.Config.IHeader.HdrCoCode) = R.HEAD(DE.Config.IHeader.HdrCompanyCode)
    R.HEAD(DE.Config.IHeader.HdrDeptCode) = R.HEAD(DE.Config.IHeader.HdrDepartment)
    EB.SystemTables.setAv(1)
*
* Obain date/time key and write header and message records
*
    V$KEY = ''  ;* GB9700885
    DE.API.GetKey(V$KEY)          ;* GB9700885
    R.KEY = "R":V$KEY     ;* GB9700885
    HDR.KEY = R.KEY
    IF DE.Clearing.getVDebug() THEN CRT R.KEY
*
* Write message to input history file providing history maintenance is
* required
*
    IF R.PARM(DE.Config.Parm.ParMaintainHistory) THEN
*
        DE.Config.IHistoryWrite(R.KEY, REPLY, '')
*
* Add key to history queue
*
        V$DATE = R.KEY[2,8]
*SMIJU S
*Change the code to restructure the DE.I.HISTORY.QUEUE format to avoid locking
        Q.ID = ''
        Q.ID = R.KEY:"-":V$DATE
        DE.Config.IHistoryQueueWrite(Q.ID, V$DATE, '')
    END
*
* GB9200584 - Check for diversions to disk files
*
    IF DIVERSIONS THEN GOSUB DIVERSION.PROCESSING
    IF NOT(MESSAGE.DIVERTED) OR ALLOW.PASS.THRU THEN
        R.HEAD(DE.Config.IHeader.HdrBankDate) = EB.SystemTables.getToday()
        MATBUILD R.HEAD.DYN FROM R.HEAD
        DE.Config.IHeaderWrite(HDR.KEY, R.HEAD.DYN, '')
        tmp.MESSAGE = EB.SystemTables.getMessage()
        DE.ModelBank.IMsgWrite(R.KEY, tmp.MESSAGE,'')
*
* Add key to appropiate priority record
*
LCK11:
        R.PRTY = ""
        ER = ''
        DE.Config.IPriLock(PRTY.KEY, R.PRTY, ER, 'E', '')
        IF ER EQ 'RECORD LOCKED' THEN
            EB.SystemTables.setText('F.DE.I.PRI, PRTY.KEY')
            EB.DataAccess.Lck1()
            GOTO LCK11
        END ELSE
            EB.SystemTables.setEtext('')
        END
        R.PRTY<-1> = R.KEY
        DE.Config.IPriWrite(PRTY.KEY, R.PRTY, '')

    END
*
* Add record to header archive file providing history maintenance is
* required
*
    IF R.PARM(DE.Config.Parm.ParMaintainHistory) THEN
        MATBUILD R.HEAD.DYN FROM R.HEAD
        DE.Config.IHeaderArchWrite(R.KEY, R.HEAD.DYN, '')
    END
    GOSUB SEND.ACK
RETURN
*
* Check for system shutdown
* -------------------------
CHECK.SYSTEM.SHUTDOWN:
*
* Read the parameter file to determine whether to shutdown the carrier
*
    R.PARM.DYN = DE.Config.Parm.Read('SYSTEM.STATUS', ER)
    MATPARSE R.PARM FROM R.PARM.DYN
    IF ER THEN
        MAT R.PARM = ''
        EB.SystemTables.setEtext('')
        PROGRAM.TERMINATING = TRUE
        TERM.REASON = 'SYS ERROR'
    END
    IF R.PARM(DE.Config.Parm.ParShutInCarrier)<1,CARRIER.POS> # 'A' THEN
        PROGRAM.TERMINATING = TRUE
        TERM.REASON = ''
    END
    R.CHECK = ""
    ER = ''
    DE.Interface.CommBufferLock("SWIFT.ACTIVE", R.CHECK, ER, 'E', '')
    IF ER EQ 'RECORD LOCKED' THEN
        EB.DataAccess.FRelease('F.COMM.BUFFER', "SWIFT.ACTIVE", '')
    END ELSE
        IF ER THEN
            F.COMM.BUFFERPROGRAM.TERMINATING = TRUE
            TERM.REASON = "HANDLER DOWN"
            DE.Reports.WriteSyslog(102,'ST200 Inward message handler error. The protocol handler has died.')
        END
    END
RETURN
*
* Send ACK response to ST200
* -----------------------------------------------------------------------
SEND.ACK:
    BUFFER = "#ST":SOSN:"RCVD":FFFF
    GOSUB ST200O
    IF PROGRAM.TERMINATING THEN RETURN
    GOSUB UPDATE.SOSN
RETURN
*
* Send NAK Response to ST200
* -----------------------------------------------------------------------
SEND.NAK:
    BUFFER = "#ST":SOSN:"ERR":FFFF
    GOSUB ST200O
    IF PROGRAM.TERMINATING THEN RETURN
    GOSUB UPDATE.SOSN
RETURN
*
* BADRC - Report invalid BD$ RCs
* ------------------------------
BADRC:
    DE.Reports.WriteSyslog(0,'ST200 Inward message handler error: &^':REPLY)
    IF DE.Clearing.getVDebug() THEN CRT REPLY
RETURN
*
* Update SOSN and message audit file.
* N.B. For carrier ACK/NAKs, most fields refer to the ACKd or NAKd msg.
* -----------------------------------------------------------------------
UPDATE.SOSN:
    MAT R.AUDIT = ''
    IF HDR.KEY[1,1] = 'R' THEN
        R.AUDIT(DE.Config.MsgAudit.AdtHeaderFileKey)=HDR.KEY
        R.AUDIT(DE.Config.MsgAudit.AdtHeaderFileMvOffset)=EB.SystemTables.getAv()
        R.AUDIT(DE.Config.MsgAudit.AdtDateTimeStamp) = EB.SystemTables.getRDates(EB.Utility.Dates.DatToday):FMT(INT(TIME()),'7"0"R')
        R.AUDIT(DE.Config.MsgAudit.AdtCarrier)='SW'
        R.AUDIT(DE.Config.MsgAudit.AdtCarrierSeqNum) = CARRIER.SEQ.NUM
        R.AUDIT(DE.Config.MsgAudit.AdtCarrierAckNak) = CARRIER.ACK.NAK
        R.AUDIT(DE.Config.MsgAudit.AdtCarrierErrorText) = CARRIER.ERR.TXT
        MATBUILD R.AUDIT.DYN FROM R.AUDIT
        DE.Config.MsgAuditWrite(AUDIT.KEY, R.AUDIT.DYN, '')
    END ELSE
        EB.DataAccess.FRelease('F.DE.MSG.AUDIT', AUDIT.KEY, '')
    END
    IF SOSN = 99999
    THEN SOSN = STR('0',5)
    ELSE SOSN = FMT(SOSN+1,'5"0"R')
LCK91:
    IN.COUNT = ""
        
    EB.DataAccess.FRelease('F.LOCKING', IN.SEQ.KEY, '')
    ER = ''
    IN.COUNT = ''
    EB.SystemTables.LockingLock(IN.SEQ.KEY, IN.COUNT, ER, 'E', '')
    IF ER EQ 'RECORD LOCKED' THEN
        EB.SystemTables.setText("LOCKING RECORD LOCKED ":IN.SEQ.KEY)
        EB.DataAccess.Lck1()
        GOTO LCK91
    END ELSE
        EB.SystemTables.setEtext('')
    END
    EB.SystemTables.LockingWrite(IN.SEQ.KEY, SOSN, '')
RETURN
*
************************************************************************
*
CHECK.CANCELLATION:
*
* If an incoming message fails inward format checks it may be a
* cancellation instruction generated by a manual cancellation from the
* VRQ of the ST200. If this is the case then we acknowledge this and
* increment the SOSN and continue processing.
*
    CAN.ACK.SENT = 0

    keyDetails = ''
    keyDetails<AddressIDDetails.customerKey> = ''
    keyDetails<AddressIDDetails.preferredLang> = EB.SystemTables.getLngg()
    keyDetails<AddressIDDetails.companyCode> = EB.SystemTables.getIdCompany()
    keyDetails<AddressIDDetails.addressNumber> = 1
    address = ''
    CALL CustomerService.getSWIFTAddress(keyDetails, address)
    IF EB.SystemTables.getEtext() = '' THEN
        deliveryAddress = address<SWIFTDetails.code>
    END ELSE ;* Error processing
        DE.Reports.WriteSyslog(198,'ST200 Inward message handler. Company SWIFT address missing.')
        RETURN
    END

    IF NETWORK = 1 THEN
        CONVERT CRLF TO @FM IN REPLY
        IF REPLY<2>[1,LEN(deliveryAddress)] = deliveryAddress THEN
            TXN.POS = INDEX(REPLY,':20:',1)
            TEMP = REPLY[TXN.POS+4,LEN(REPLY)]
            TXN.REF = FIELD(TEMP,@FM,1)
            IF DE.Clearing.getVDebug() THEN
                PRINT 'CANCELLATION MESSAGE RECEIVED - SEND BACK ACK (Y/NO) ':
                DE.Reports.WriteSyslog(197,'ST200 Inward message handler. Cancellation message received from ST200 as & for &.^':REPLY[1,8]:'@':TXN.REF)
                INPUT ANS
                IF ANS = 'Y' OR ANS = 'y' THEN
                    GOSUB SEND.CAN.ACK
                END
            END ELSE
                DE.Reports.WriteSyslog(197,'ST200 Inward message handler. Cancellation message received from ST200 as & for &.^':REPLY[1,8]:'@':TXN.REF)
                GOSUB SEND.CAN.ACK
            END
        END
    END ELSE
        IF REPLY[INDEX(REPLY,'{1:F01',1)+6,LEN(deliveryAddress)] = deliveryAddress THEN
            TXN.POS = INDEX(REPLY,':20:',1)
            TEMP = REPLY[TXN.POS+4,LEN(REPLY)]
            TXN.REF = FIELD(TEMP,CRLF,1)
            IF DE.Clearing.getVDebug() THEN
                PRINT 'CANCELLATION MESSAGE RECEIVED - SEND BACK ACK (Y/NO) ':
                DE.Reports.WriteSyslog(197,'ST200 Inward message handler. Cancellation message received from ST200 as & for &.^':REPLY[1,8]:'@':TXN.REF)
                INPUT ANS
                IF ANS = 'Y' OR ANS = 'y' THEN
                    GOSUB SEND.CAN.ACK
                END
            END ELSE
                DE.Reports.WriteSyslog(197,'ST200 Inward message handler. Cancellation message received from ST200 as & for &.^':REPLY[1,8]:'@':TXN.REF)
                GOSUB SEND.CAN.ACK
            END
        END
    END
RETURN
*
************************************************************************
*
SEND.CAN.ACK:
*
* Special case for sending ACK to received cancellation message
*
    CAN.ACK.SENT = TRUE
    CARRIER.ACK.NAK = 'NAK'
    DE.Reports.WriteSyslog(199,'ST200 Inward message handler. ACK sent to cancellation message')
    BUFFER = REPLY[1,8]:'RCVD':FFFF
    GOSUB ST200O
*
    HDR.KEY = 'CANCELLATION'
    EB.SystemTables.setAv('')
    GOSUB UPDATE.SOSN
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
    ER = ''
    DE.API.PhantomLogLock("DE.I.CC.SWIFT", R.PHANT, ER, 'E', '')
    EB.SystemTables.setEtext('')
    IF TERM.REASON THEN R.PHANT<DE.API.PhantomLog.PhlLastTermination> = TERM.REASON
    ELSE R.PHANT<DE.API.PhantomLog.PhlLastTermination> = 'Normal'
    R.PHANT<DE.API.PhantomLog.PhlLastActivity> = OCONV(DATE(),'D2 E'):" ":OCONV(TIME(),'MTS')
    R.PHANT<DE.API.PhantomLog.PhlPhantomNo> = @USERNO
    DE.API.PhantomLogWrite("DE.I.CC.SWIFT", R.PHANT, '')
RETURN
*
************************************************************************
*
ST200O:
*
* Routine to handle output of characters to the ST200 via comm buffer
*
    IF DE.Clearing.getVDebug() THEN CRT 'Sending... ':CRLF:BUFFER[1,LEN(BUFFER)-2]:CRLF
    REPLY = ''
    RETRY = 1
103:
    R.MESS = ''
    ER = ''
    DE.Interface.CommBufferLock('SWIFT.IN', R.MESS, ER, 'E', '')
    IF ER EQ 'RECORD LOCKED' THEN
        IF DE.Clearing.getVDebug() THEN PRINT 'SWIFT.IN buffer locked on retry ':RETRY
        RETRY += 1
        IF RETRY > SND.RETRIES THEN
            R.MESS = ''
            EB.DataAccess.FRelease('F.COMM.BUFFER', 'SWIFT.IN', '')
            REPLY = '*** ERROR *** SWIFT.IN buffer locked after ':RCV.RETRIES:' retries'
            RETURN
        END ELSE
            SLEEP SND.TIMEOUT
            GOTO 103
        END
    END ELSE
        IF ER THEN
            EB.SystemTables.setEtext('')
            R.MESS = ''
        END
    END
        
    R.MESS := BUFFER
    DE.Interface.CommBufferWrite('SWIFT.IN', R.MESS, '')
    EB.DataAccess.FRelease('F.COMM.BUFFER', 'SWIFT.IN', '')
    BUFFER = ''
RETURN
*
************************************************************************
*
ST200I:
*
* Routine to handle reception of characters from ST200 via comm buffer
*
    RETRY = 1
    REPLY = ''
104:
    V$CHARS = ''
    ER = ''
    DE.Interface.CommBufferLock('SWIFT.IN.RES', V$CHARS, ER, 'E', '')
    IF ER EQ 'RECORD LOCKED' THEN
        IF DE.Clearing.getVDebug() THEN PRINT 'SWIFT.IN.RES buffer locked after retry ':RETRY
        RETRY += 1
        IF RETRY > RCV.RETRIES THEN
            EB.DataAccess.FRelease('F.COMM.BUFFER', 'SWIFT.IN.RES', '')
            REPLY = '*** ERROR *** SWIFT.IN.RES buffer locked after ':RCV.RETRIES:' retries'
            RETURN
        END ELSE
            SLEEP RCV.TIMEOUT
            GOTO 104
        END
    END ELSE
        IF ER THEN
            V$CHARS = ''
            IF RETRY > RCV.RETRIES THEN
                EB.DataAccess.FRelease('F.COMM.BUFFER', 'SWIFT.IN.RES', '')
                REPLY = ''
                RETURN
            END ELSE
                RETRY += 1
                EB.DataAccess.FRelease('F.COMM.BUFFER', 'SWIFT.IN.RES', '')
                SLEEP RCV.TIMEOUT
                GOTO 104
            END
        END
    END
    IF V$CHARS THEN
        FFPOS = INDEX(V$CHARS,FFFF,1)
        IF FFPOS THEN
            REPLY = V$CHARS[1,FFPOS-1]
            V$CHARS = V$CHARS[FFPOS+2,LEN(V$CHARS)]
            DE.Interface.CommBufferWrite('SWIFT.IN.RES', V$CHARS, '')
            IF DE.Clearing.getVDebug() THEN CRT 'Received : ':REPLY
            RETURN
        END
    END
    EB.DataAccess.FRelease('F.COMM.BUFFER', 'SWIFT.IN.RES', '')

    EB.DataAccess.FRelease('F.COMM.BUFFER', 'SWIFT.IN.RES', '')
RETURN
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
    ALLOW.PASS.THRU = 0
    LOCATE R.HEAD(DE.Config.IHeader.HdrMessageType) IN DIVERT.LIST<1,1> SETTING DIVERT ELSE DIVERT = 0
    IF NOT(DIVERT) THEN RETURN
    F.DIVERT = ''
    OPEN '',DIVERT.LIST<DE.Config.SwiftDiversion.SdInwardFile+1,DIVERT> TO F.DIVERT ELSE
        TERM.REASON = 'DIVERT FILE'
        PROGRAM.TERMINATING = TRUE
        GOSUB UPDATE.PHANTOM.LOG
        PRINT "Diversion file open failure on ":DIVERT.LIST<DE.Config.SwiftDiversion.SdInwardFile+1,DIVERT>
        RETURN
    END
*
* Divert the message into the specified record in the file
*
* Add any special formatting necessary for the destination.
*
    BEGIN CASE
        CASE DIVERT.LIST<DE.Config.SwiftDiversion.SdDivertFormat+1,DIVERT> NE ''
            IF DIVERT.LIST<DE.Config.SwiftDiversion.SdAddDelimiters+1,DIVERT> = 'Y' THEN
* Pif GB9600715 Change MESSAGE to REPLY
                REPLY = SOH:REPLY:ETX
            END
            DIVERT.KEY = DIVERT.LIST<DE.Config.SwiftDiversion.SdInwardRecord+1,DIVERT>
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
                NO.SPECIALS = DCOUNT(DIVERT.LIST<DE.Config.SwiftDiversion.SdInSpecialIf+1,DIVERT>,@SM)
                FOR S = 1 TO NO.SPECIALS
                    IF INDEX(REPLY,DIVERT.LIST<DE.Config.SwiftDiversion.SdInSpecialIf+1,DIVERT,S>,1) THEN
                        DIVERT.KEY = DIVERT.LIST<DE.Config.SwiftDiversion.SdSpecialRecord+1,DIVERT>
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
                    END
                NEXT S
            END
            R.DIVERT = ''
            READU R.DIVERT FROM F.DIVERT,DIVERT.KEY ELSE R.DIVERT = ''
            R.DIVERT := REPLY:CRLF
            WRITE R.DIVERT TO F.DIVERT,DIVERT.KEY
        CASE 1
            NULL
    END CASE
*
    ALLOW.PASS.THRU = DIVERT.LIST<DE.Config.SwiftDiversion.SdAllowPassThru+1,DIVERT>
*
    AV1 = EB.SystemTables.getAv()
    R.HEAD(DE.Config.IHeader.HdrMsgDisp)<1,AV1> = 'ACK'
    R.HEAD(DE.Config.IHeader.HdrDisposition) = 'FORMATTED'
    IF ALLOW.PASS.THRU THEN
        R.HEAD(DE.Config.IHeader.HdrSendStamp)<1,AV1> = 'COPIED TO DISKFILE ':DIVERT.LIST<DE.Config.SwiftDiversion.SdInwardFile+1,DIVERT>
    END ELSE
        R.HEAD(DE.Config.IHeader.HdrSendStamp)<1,AV1> = 'DIVERTED TO DISKFILE ':DIVERT.LIST<DE.Config.SwiftDiversion.SdInwardFile+1,DIVERT>
    END
    R.HEAD(DE.Config.IHeader.HdrDelRcvStamp)<1,AV1> = OCONV(DATE(),'D2E'):' ':OCONV(TIME(),'MTS')
    R.HEAD(DE.Config.IHeader.HdrBankDate) = EB.SystemTables.getToday()
    MATBUILD R.HEAD.DYN FROM R.HEAD
    DE.Config.IHeaderWrite(HDR.KEY, R.HEAD.DYN, '')
    MESSAGE.DIVERTED = 1
RETURN
END
