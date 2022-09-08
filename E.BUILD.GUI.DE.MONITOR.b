* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 4 15/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>8024</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DE.ModelBank
    SUBROUTINE E.BUILD.GUI.DE.MONITOR(TONY)
*
* This routine runs as a stand alone screen display of current delivery
* phantom activity. Display on screen includes the phantom process name
* user number, termination reason, last activity, and a count of messages
* in the queues associated with each phantom
*
* Details for each phantom are extracted from the appropriate record on
* the phantom log file F.DE.PHANTOM.LOG.
*
* 21/04/92 - GB9200262
*            Merge Hypo pifs HY9200616, HY9200614 Show the incoming
*            messages waiting to be processed by FT
*
* 25/01/94 - GB9400099
*            Make function keys soft
*            Call .CLEARING phantom and not SIC
*
* 03/03/97 - GB9500791
*            Check the DE.CARRIER file for interfaces, if generic is
*            specified on DE.PARM
*
*            Generic will not actually be specified on DE.PARM - the id
*            of the carrier file will be.  Read the carrier file to
*            determine whether generic processing is used.
*
* 24/05/04 - EN_10002277
*            Enhancement -- Remove mapping phantom and handle mapping
*            process directly from handoff routine, i.e., make part of
*            the contract/transaction online processing.
*            - Routines APPLICAITON.HANDOFF, DE.O.MAP.MESSAGES have undergone
*              changes and new subroutines introduced
*            - Change in F.DE.O.PRI/F.DE.I.PRI file structure to have the list of all
*              delivery ids prefixed with the priority like U-D... or N-D...
*              (no more separate records for U,N,P priority)
*            - Change in F.DE.O.REPAIR file to have the list of all delivery ref
*              under repair (no more separate record with id = 'Repair')
*
* 25/08/04 - BG_100007070
*            Bug fix in EN-2277 w.r.t record count in F.DE.I.REPAIR.
*
* 30/11/04 - BG_100007698
*            Changes have been made for the SWIFT messages processed by GENERIC module for
*            both IN & OUT messages.
*
* 20/12/04 - BG_100007801
*            Bug fix for SWIFT msg changes processed thru GENERIC module
*
* 05/08/05 - EN_10002607
*            Now the ID of DE.O.HOLD.FILE will be DeliveryId.Num. Each
*            record will have three fields STATUS, DATE and TIME.
*            STATUS may contain values HOLD, HOLD <Date> or HOLD <time>.
*
* 09/02/07 - CI_10047115
*            As DE.O.PRI/DE.I.PRI becomes obsolete counting of unformatted
*            records should be done based on <CARRIER>.OUT.LIST and <CARRIER>.IN.LIST.
*
* 06/03/07 - EN_10003245
*            Data Access Service - FT - Application Changes
*
* 26/03/10 - Task 34373
*            As DE.I.PRI.FT becomes obselete, should delete the OPF of the file.
*
* 27/10/10 - CI_10071830
*            Ref : 102553
*            Assign correct value to THE.LIST else system is fataling out while running
*            the DE.MONITOR enquiry.
*
* 07/06/11 - SI: 149434
*            Marking DE.O.CC.PRINT obsolete.
*
* 13/03/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
* 16/03/15 - Defect:1250871 / Task: 1252690
*            !HUSHIT is not supported in TAFJ, hence changed to use HUSHIT().
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
*12/10/15 -  Enhancement 1265068
*         -  Task 1497940
*		     Incorporation of HUSHIT
*
************************************************************************
    $USING EB.SystemTables
    $USING EB.Desktop
    $USING DE.API
    $USING DE.Config
    $USING EB.Service
    $USING EB.DataAccess
    $USING EB.API
    $USING DE.ModelBank
    $USING EB.DatInterface
    $INSERT I_DAS.TSA.STATUS

    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
    EQUATE F1 TO C.U
    EQUATE F2 TO C.B
    EQUATE F3 TO C.F
    EQUATE F4 TO C.E
    EQUATE F5 TO C.V
    EQUATE F6 TO C.W
    EQUATE F7 TO CHARX(029)
    EQUATE F8 TO CHARX(030)
************************************************************************
*
* MODIFICATION HISTORY...
*
* Written 08 06 88 by M.J.Ramsey
*
************************************************************************
*
* Read parameter file
*

    F.DE.PARM = ''
    EB.DataAccess.Opf("F.DE.PARM",F.DE.PARM)
    DIM R.PAR(DE.Config.Parm.ParDim)
    MATREAD R.PAR FROM F.DE.PARM,"SYSTEM.STATUS" ELSE MAT R.PAR = ''
*
* Open files
*
    F.DE.O.TELEX.BATCH = '' ; EB.DataAccess.Opf("F.DE.O.TELEX.BATCH",F.DE.O.TELEX.BATCH)
    F.DE.O.TESTKEY = '' ; EB.DataAccess.Opf("F.DE.O.TESTKEY",F.DE.O.TESTKEY)
    F.DE.PHANTOM.LOG = '' ; EB.DataAccess.Opf("F.DE.PHANTOM.LOG",F.DE.PHANTOM.LOG)
    F.DE.CARRIER = '' ; EB.DataAccess.Opf('F.DE.CARRIER',F.DE.CARRIER)
    F.TSA.STATUS.LOC = '' ; EB.DataAccess.Opf("F.TSA.STATUS",F.TSA.STATUS.LOC)         ;* BG_100007698 S/E
    FN.GUI.DE.MONITOR = 'F.GUI.DE.MONITOR' ; F.GUI.DE.MONITOR = '' ; EB.DataAccess.Opf(FN.GUI.DE.MONITOR, F.GUI.DE.MONITOR)
*
* Initialise variables
*
    NO.OLD.RECS = 0
    TABLE.NAME = 'GUI.DE.MONITOR'
    THE.LIST = 'ALL.IDS'
    TABLE.SUFFIX = ''
    THE.ARGS = ''
    EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
    NO.OLD.RECS = DCOUNT(THE.LIST,@FM)
*
    OUTWARD.LIST = ''
    INWARD.LIST = ''
    PROCESS.LIST = ''
    FLAGLIST = ''
    TERM.REASON = ''
    ACTIVITY.LIST= ''
    QUEUE.COUNT = ''
    QUEUE.LIST = ''
    USERNO.LIST = ''
    TEMP = ''
    LINE = ''
    IN.MON = "Enabled"
    OUT.MON = "Enabled"
    REFRESH.TIME = 30
    PARAMFLAG = ''
    R.PRTY = ''
    PRTY.KEY = ''
    TOPLINE = STR('-',78)
    PRTY.KEY<1> = 'N'
    PRTY.KEY<2> = 'P'
    PRTY.KEY<3> = 'U'
    PRTY.KEY<4> = 'I'
    PRTY.KEY<5> = 'C'
    EB.SystemTables.setTControlword(C.U : @FM : C.B : @FM : C.F : @FM : C.E : @FM : C.V)

    OUTWARD.LIST<1> = "FORMATTING"      ;* EN_10002277 -s
    PROCESS.LIST<1> = "DE.O.SELECT.NEXT.MESSAGE"
    OUTWARD.LIST<2> = "TIMECHECK"
    PROCESS.LIST<2> = "DE.MM.TIMECHECK" ;* EN_10002277 -e
*
* Build list of inward and outward carriers. For each carrier located
* from the list in DE.PARM open the appropriate carrier file.
*
    CARRIER.LIST = R.PAR(DE.Config.Parm.ParOutwardCarriers)
    CONVERT @VM TO @FM IN CARRIER.LIST
*
    MAX.CARRIERS = DCOUNT(CARRIER.LIST,@FM)
    FOR CARRIER.COUNT = 1 TO MAX.CARRIERS
        CARRIER = CARRIER.LIST<CARRIER.COUNT>
        READ R.CARRIER FROM F.DE.CARRIER,CARRIER ELSE R.CARRIER = ''
            *
            BEGIN CASE
                    *
                    * If GENERIC is specified, get valid generic interfaces from DE.CARRIER
                    *
                CASE R.CARRIER<DE.Config.Carrier.CarrCarrierModule> = 'GENERIC'
                    OUTWARD.LIST<-1> = CARRIER:'.O (G)'   ;* BG_100007698 S/E
                    PROCESS.LIST<-1> = 'DE.CC.GENERIC'
                    *
                CASE CARRIER = 'TELEX'
                    OUTWARD.LIST<-1> = "TELEX"
                    PROCESS.LIST<-1> = "DE.CC.TELEX"
                    F.DE.O.PRI.TELEX = '' ; EB.DataAccess.Opf("F.DE.O.PRI.TELEX",F.DE.O.PRI.TELEX)
                    *
                CASE CARRIER = 'PRINT'
                    *
                CASE CARRIER = 'SWIFT'
                    OUTWARD.LIST<-1> = "SWIFT"
                    PROCESS.LIST<-1> = "DE.O.CC.SWIFT"
                    FN.DE.O.PRI.SWIFT = 'F.DE.O.PRI.SWIFT'
                CASE CARRIER = 'SIC'
                    OUTWARD.LIST<-1> = "SIC"
                    PROCESS.LIST<-1> = "DE.O.CC.CLEARING"
                    FN.DE.O.PRI.SIC = 'F.DE.O.PRI.SIC'
            END CASE
        NEXT CARRIER.COUNT
        *
        OUTCOUNT = COUNT(OUTWARD.LIST,@FM) + 1

        INWARD.LIST<1> = "FORMATTING"
        PROCESS.LIST<-1> = "DE.I.SELECT.NEXT.MESSAGE"

        F.DE.I.TESTKEY = '' ; EB.DataAccess.Opf("F.DE.I.TESTKEY",F.DE.I.TESTKEY)
        CARRIER.LIST = R.PAR(DE.Config.Parm.ParInwardCarriers)
        CONVERT @VM TO @FM IN CARRIER.LIST
        LOCATE "SWIFT" IN CARRIER.LIST<1> SETTING POS ELSE POS = 0
        IF POS THEN
            INWARD.LIST<-1> = "SWIFT"
            PROCESS.LIST<-1> = "DE.I.CC.SWIFT"
            * BG_100007698 S
            SW.CARR = "SWIFT"
            READ R.CARRIER FROM F.DE.CARRIER, SW.CARR ELSE R.CARRIER = ''
                IF R.CARRIER AND R.CARRIER<DE.Config.Carrier.CarrCarrierModule> = 'GENERIC' THEN
                    INWARD.LIST<-1> = SW.CARR:'.IN (G)'
                    PROCESS.LIST<-1> = 'DE.CC.GENERIC'
                END

            END
            LOCATE "EUCLID" IN CARRIER.LIST<1> SETTING POS ELSE POS = 0
            IF POS THEN
                INWARD.LIST<-1> = "EUCLID"
                PROCESS.LIST<-1> = "DE.I.CC.EUCLID"
                F.DE.INWARD.EUCLID = '' ; EB.DataAccess.Opf("F.DE.INWARD.EUCLID",F.DE.INWARD.EUCLID)
            END
            *      IF SIC.TRUE  THEN
            LOCATE "SIC"IN CARRIER.LIST<1> SETTING POS ELSE POS = 0
            IF POS THEN
                INWARD.LIST<-1> = "SIC"
                PROCESS.LIST<-1> = "DE.I.CC.CLEARING"
            END
***!      INCOUNT = COUNT(INWARD.LIST,@FM) + 1
            INCOUNT = COUNT(INWARD.LIST,@FM)+(INWARD.LIST NE "")
            PROC.COUNT = OUTCOUNT + INCOUNT

            *
            * MAIN PROCESSING LOOP
            *
            EXIT.CALL = 0
            COUNTER = 'AUTO'
            GOSUB MONITOR
            RETURN

************************************************************************
            *
************************************************************************
            *
MONITOR:
            *
            * Runs the monitor loop. The monitor will refresh every REFRESH.TIME in
            * seconds when running in auto mode. Hitting any key will toggle the
            * mode to manual. In manual mode any key strike will refresh the screen
            * In either mode F1 leaves the monitor and returns to menu.
            *

            RES = ''
            RES2 = ''
            RES3 = ''
LE.MONS:
            GOSUB BUILD.ELEMENTS
            GOSUB DISPLAY.SCREEN
            RETURN
            *
            *
************************************************************************
            *
************************************************************************
            *
            *
************************************************************************
            *
BUILD.ELEMENTS:

            *
            LINE = ''
            WARNING.LINE = ''
            WARNING = 0
            FOR PROCNUM = 1 TO OUTCOUNT
                *
                * Read phantom log for this process
                *
                READ R.PHANT FROM F.DE.PHANTOM.LOG,PROCESS.LIST<PROCNUM> ELSE R.PHANT = ''
                    MATREAD R.PAR FROM F.DE.PARM,"SYSTEM.STATUS" ELSE MAT R.PAR = ''

                    *
                    * If Outward monitor is enabled add elements of Outward phantoms
                    *

                    IF OUT.MON = "Enabled" THEN
                        BEGIN CASE
                                *
                                * oUOutward unformatted DE.O.SELECT.NEXT.MESSAGE
                                * Includes testkey,batching,held queues
                                *
                            CASE PROCNUM = 1  ;* EN_10002277 -s/e

                                PARAMFLAG = R.PAR(DE.Config.Parm.ParShutdownOutward)
                                ADD.TIME = 120
                                Q.NAME = "Unformat  : "
                                * EN_10002277 -s
                                SEL.OUT.LIST.CNT = 0    ;* CI_10047115 S
                                TABLE.NAME = 'DE.CARRIER'
                                THE.LIST = 'ALL.IDS'
                                TABLE.SUFFIX = ''
                                THE.ARGS = ''
                                EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
                                SEL.DE.LIST = THE.LIST
                                SEL.DE.CNT = DCOUNT(SEL.DE.LIST,@FM)
                                IF SEL.DE.LIST  THEN
                                    FOR SEL.DE.COUNT = 1 TO SEL.DE.CNT
                                        SEL.CNT = 0
                                        SEL.CMD = "SELECT ":"F.":SEL.DE.LIST<SEL.DE.COUNT>:".OUT.LIST"
                                        EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', SEL.CNT, RET.CODE)
                                        SEL.OUT.LIST.CNT += SEL.CNT
                                    NEXT SEL.DE.COUNT
                                END
                                Q.COUNT = SEL.OUT.LIST.CNT        ;* CI_10047115 E
                                * EN_10002277 -e
                                ELEM.NUM = PROCNUM
                                GOSUB EXTRACT.ELEMENTS
                                CT = 0
                                QUEUE.LIST<PROCNUM,2> = "Testkey   : "
                                FOR V$NUM = 1 TO 3
                                    READ R.PRTY FROM F.DE.O.TESTKEY,PRTY.KEY<V$NUM> ELSE R.PRTY = ''
                                        CT = CT + COUNT(R.PRTY<1>,@VM) + (R.PRTY<1> NE '')
                                    NEXT V$NUM
                                    QUEUE.COUNT<PROCNUM,2> = CT
                                    CT = 0
                                    QUEUE.LIST<PROCNUM,3> = "Batching  : "
                                    TABLE.NAME = 'DE.O.TELEX.BATCH'
                                    THE.LIST = 'ALL.IDS'
                                    THE.ARGS = ''
                                    TABLE.SUFFIX = ''
                                    EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
                                    LOOP
                                        REMOVE ID FROM THE.LIST SETTING ID.POS
                                    WHILE ID DO
                                        READ R.PRTY FROM F.DE.O.TELEX.BATCH,ID ELSE R.PRTY = ''
                                            CT = CT + COUNT(R.PRTY<2>,@VM) + (R.PRTY<2> NE '')
                                        REPEAT
                                        QUEUE.COUNT<PROCNUM,3> = CT

                                        QUEUE.LIST<PROCNUM,4> = "Repair    : "
                                        * EN_10002277 -s
                                        SEL.CNT = 0
                                        TABLE.NAME = 'DE.O.REPAIR'
                                        THE.LIST = 'ALL.IDS'
                                        TABLE.SUFFIX = ''
                                        THE.ARGS = ''
                                        EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
                                        SEL.LIST = THE.LIST
                                        SEL.CNT = DCOUNT(SEL.LIST,@FM)
                                        QUEUE.COUNT<PROCNUM,4> = SEL.CNT
                                        * EN_10002277 -e

                                        *
                                        * Held messages DE.MM.TIMECHECK
                                        *
                                    CASE PROCNUM = 2  ;* EN_10002277 -s/e

                                        PARAMFLAG = R.PAR(DE.Config.Parm.ParShutdownTimecheck)
                                        ADD.TIME = 60
                                        Q.NAME = "Held      : "
                                        CT = 0
                                        TABLE.NAME = 'DE.O.HOLD.KEY'
                                        TABLE.SUFFIX = ''
                                        THE.LIST = 'ALL.IDS'
                                        THE.ARGS = ''
                                        EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
                                        KEYLIST = THE.LIST
                                        CT = DCOUNT(KEYLIST,@FM)
                                        Q.COUNT = CT
                                        ELEM.NUM = PROCNUM
                                        GOSUB EXTRACT.ELEMENTS

                                        *
                                        * Formatted telexes DE.CC.TELEX
                                        *
                                    CASE OUTWARD.LIST<PROCNUM> = 'TELEX'

                                        LOCATE 'TELEX' IN R.PAR(DE.Config.Parm.ParOutwardCarriers)<1,1> SETTING TX.POS ELSE NULL
                                        PARAMFLAG = R.PAR(DE.Config.Parm.ParShutOutCarr)<1,TX.POS>
                                        ADD.TIME = 120
                                        Q.NAME = "Telex     : "
                                        CT = 0
                                        FOR V$NUM = 1 TO 3
                                            READ R.PRTY FROM F.DE.O.PRI.TELEX,PRTY.KEY<V$NUM> ELSE R.PRTY = ''
                                                CT = CT + COUNT(R.PRTY,@FM) + (R.PRTY NE '')
                                            NEXT V$NUM
                                            Q.COUNT = CT
                                            ELEM.NUM = PROCNUM
                                            GOSUB EXTRACT.ELEMENTS

                                            *
                                            * Formatted telexes DE.CC.SIC
                                            *
                                        CASE OUTWARD.LIST<PROCNUM> = 'SIC'

                                            LOCATE 'SIC' IN R.PAR(DE.Config.Parm.ParOutwardCarriers)<1,1> SETTING TX.POS ELSE NULL
                                            PARAMFLAG = R.PAR(DE.Config.Parm.ParShutOutCarr)<1,TX.POS>
                                            ADD.TIME = 120
                                            Q.NAME = "SIC       : "
                                            CT = 0
                                            FN.DE.O.PRI.CC = FN.DE.O.PRI.SIC
                                            GOSUB GET.PRI.QUEUE.LIST
                                            Q.COUNT = KEY.COUNT
                                            ELEM.NUM = PROCNUM
                                            GOSUB EXTRACT.ELEMENTS

                                            *
                                            * Formatted swift outward DE.O.CC.SWIFT
                                            *
                                        CASE OUTWARD.LIST<PROCNUM> = 'SWIFT'

                                            LOCATE "SWIFT" IN R.PAR(DE.Config.Parm.ParOutwardCarriers)<1,1> SETTING SW.POS ELSE NULL
                                            PARAMFLAG = R.PAR(DE.Config.Parm.ParShutOutCarr)<1,SW.POS>
                                            ADD.TIME = 30
                                            Q.NAME = "Swift     : "
                                            CT = 0
                                            FN.DE.O.PRI.CC = FN.DE.O.PRI.SWIFT
                                            GOSUB GET.PRI.QUEUE.LIST
                                            Q.COUNT = KEY.COUNT
                                            ELEM.NUM = PROCNUM
                                            GOSUB EXTRACT.ELEMENTS
                                            *
                                            * Formatted generic messages, e.g. SWIFT (G)
                                            *
                                        CASE INDEX(OUTWARD.LIST<PROCNUM>,'(G)',1)

                                            CARRIER = FIELD(OUTWARD.LIST<PROCNUM>,' ',1)
                                            IF INDEX(CARRIER,'.',1) THEN CARRIER = FIELD(CARRIER,'.',1)     ;* BG_100007698 S/E
                                            LOCATE CARRIER IN R.PAR(DE.Config.Parm.ParOutwardCarriers)<1,1> SETTING SW.POS THEN
                                            * BG_100007698 S
                                            IF CARRIER = 'SWIFT' THEN

                                                GENERIC.ACTIVE.FLAG = 0
                                                TABLE.NAME = 'TSA.STATUS'
                                                THE.LIST = DAS.CURRENT$SERVICE
                                                THE.ARGS = 'DE.CC.GENERIC.OUT'
                                                TABLE.SUFFIX = ''
                                                EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
                                                STATUS.LIST = THE.LIST
                                                LOOP
                                                    REMOVE ID.STATUS FROM STATUS.LIST SETTING MORE
                                                WHILE ID.STATUS:MORE
                                                    READ STATUS.REC FROM F.TSA.STATUS.LOC, ID.STATUS ELSE READ.ERR = 'Y'
                                                        IF STATUS.REC<EB.Service.TsaStatus.TsTssAgentStatus> = 'RUNNING' THEN
                                                            GENERIC.ACTIVE.FLAG = 1
                                                        END
                                                    REPEAT

                                                    IF GENERIC.ACTIVE.FLAG THEN
                                                        PARAMFLAG = 'A'
                                                    END ELSE
                                                        PARAMFLAG = 'C'
                                                    END
                                                END ELSE
                                                    PARAMFLAG = R.PAR(DE.Config.Parm.ParShutOutCarr)<1,SW.POS>
                                                END
                                                * BG_100007698 E
                                                ADD.TIME = 30
                                                Q.NAME = "Generic   : "
                                                CT = 0
                                                *
                                                * Open priority file for carrier specified
                                                *
                                                FN.DE.O.PRI.CARRIER = 'F.DE.O.PRI.':CARRIER; F.DE.O.PRI.CARRIER = ''
                                                EB.DataAccess.Opf(FN.DE.O.PRI.CARRIER,F.DE.O.PRI.CARRIER)
                                                FN.DE.O.PRI.CC = FN.DE.O.PRI.CARRIER
                                                GOSUB GET.PRI.QUEUE.LIST
                                                Q.COUNT = KEY.COUNT
                                                ELEM.NUM = PROCNUM
                                                GOSUB EXTRACT.ELEMENTS
                                            END

                                    END CASE

                                    *
                                    * Add lines of information for display on screen
                                    *
                                    TEMP = STR(' ',80)
                                    TEMP[1,12] = FMT(OUTWARD.LIST<PROCNUM>,'12L')
                                    TEMP[13,1] = FMT(FLAGLIST<PROCNUM>,'1L')
                                    TEMP[18,6] = FMT(USERNO.LIST<PROCNUM>,'6L')
                                    TEMP[26,15] = FMT(TERM.REASON<PROCNUM>,'15L')
                                    TEMP[43,19] = FMT(ACTIVITY.LIST<PROCNUM>,'19L')
                                    TEMP[62,17] = FMT(QUEUE.LIST<PROCNUM,1>:QUEUE.COUNT<PROCNUM,1>,'17L')
                                    LINE<-1> = TEMP
                                    *
                                    * Add any additional associated queues as seperate lines after main one
                                    *
                                    IF INDEX(QUEUE.LIST<PROCNUM>,@VM,1) THEN
                                        CTR = COUNT(QUEUE.LIST<PROCNUM>,@VM) + 1
                                        FOR QNUM = 2 TO CTR
                                            TEMP = STR(' ',80)
                                            TEMP[62,17] = QUEUE.LIST<PROCNUM,QNUM>:QUEUE.COUNT<PROCNUM,QNUM>
                                            LINE<-1> = TEMP
                                        NEXT QNUM
                                    END
                                END
                            NEXT PROCNUM
                            *
                            * Regardless of how many outward carriers have been displayed finally
                            * add the AWAK queue count.
                            *
                            CT = 0
                            KEY.LIST = ''; NO.OF.KEYS = ''
                            TABLE.NAME = 'DE.O.AWAK'
                            THE.LIST = 'ALL.IDS'
                            THE.ARGS = ''
                            TABLE.SUFFIX = ''
                            EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
                            KEY.LIST = THE.LIST
                            NO.OF.KEYS = DCOUNT(KEY.LIST,@FM)
                            CT = NO.OF.KEYS

                            IF IN.MON = "Enabled" THEN
                                TEMP = "Inward Phantoms ":STR('-',40):SPACE(24)
                            END ELSE
                                TEMP = STR(' ',80)
                            END
                            TEMP[62,17] = "Wait ack  : ":CT
                            LINE<-1> = TEMP

                            *
                            * If inward monitor is enabled add elements of inward phantoms
                            *

                            IF IN.MON = "Enabled" THEN
                                FOR PROCNUM = 1 TO INCOUNT
                                    *
                                    * Read phantom log for this process
                                    *
                                    READ R.PHANT FROM F.DE.PHANTOM.LOG,PROCESS.LIST<PROCNUM+OUTCOUNT> ELSE R.PHANT = ''
                                        MATREAD R.PAR FROM F.DE.PARM,"SYSTEM.STATUS" ELSE MAT R.PAR = ''

                                        BEGIN CASE

                                                *
                                                * Inward unformatted DE.I.SELECT.NEXT.MESSAGE
                                                *
                                            CASE PROCNUM = 1

                                                PARAMFLAG = R.PAR(DE.Config.Parm.ParShutdownInward)
                                                ADD.TIME = 120
                                                Q.NAME = "Unformat  : "
                                                CT = 0
                                                * EN_10002277 -s
                                                SEL.IN.LIST.CNT = 0     ;* CI_10047115 S
                                                TABLE.NAME = 'DE.CARRIER'
                                                THE.LIST = 'ALL.IDS'
                                                TABLE.SUFFIX = ''
                                                THE.ARGS = ''
                                                EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
                                                SEL.DE.LIST = THE.LIST
                                                SEL.DE.CNT = DCOUNT(SEL.DE.LIST,@FM)
                                                IF SEL.DE.LIST  THEN
                                                    FOR SEL.DE.COUNT = 1 TO SEL.DE.CNT
                                                        SEL.CNT = 0
                                                        SEL.CMD = "SELECT ":"F.":SEL.DE.LIST<SEL.DE.COUNT>:".IN.LIST"
                                                        EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', SEL.CNT, RET.CODE)
                                                        SEL.IN.LIST.CNT += SEL.CNT
                                                    NEXT SEL.DE.COUNT
                                                END
                                                Q.COUNT = SEL.IN.LIST.CNT         ;* CI_10047115 E
                                                * EN_10002277 -e
                                                ELEM.NUM = PROCNUM+OUTCOUNT
                                                GOSUB EXTRACT.ELEMENTS
                                                CT = 0
                                                QUEUE.LIST<PROCNUM+OUTCOUNT,2> = "Testkey   : "
                                                FOR V$NUM = 1 TO 3
                                                    READ R.PRTY FROM F.DE.I.TESTKEY,PRTY.KEY<V$NUM> ELSE R.PRTY = ''
                                                        CT = CT + COUNT(R.PRTY<1>,@VM) + (R.PRTY<1> NE '')
                                                    NEXT V$NUM
                                                    QUEUE.COUNT<PROCNUM+OUTCOUNT,2> = CT
                                                    CT = 0
                                                    QUEUE.LIST<PROCNUM+OUTCOUNT,3> = "Repair    : "
                                                    SEL.CNT = 0
                                                    TABLE.NAME = 'DE.I.REPAIR'
                                                    THE.LIST = 'ALL.IDS'
                                                    THE.ARGS = ''
                                                    TABLE.SUFFIX = ''
                                                    EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
                                                    SEL.LIST = THE.LIST
                                                    SEL.CNT = DCOUNT(SEL.LIST,@FM)
                                                    QUEUE.COUNT<PROCNUM+OUTCOUNT,3> = SEL.CNT   ;* BG_100007070 - s/e
                                                    *
                                                    * Inward swift DE.I.CC.SWIFT
                                                    *
                                                CASE INWARD.LIST<PROCNUM> = 'SWIFT'

                                                    LOCATE 'SWIFT' IN R.PAR(DE.Config.Parm.ParInwardCarriers)<1,1> SETTING SW.POS ELSE NULL
                                                    PARAMFLAG = R.PAR(DE.Config.Parm.ParShutInCarrier)<1,SW.POS>
                                                    ADD.TIME = 30
                                                    Q.NAME = "Swift     : "
                                                    CT = 0
                                                    Q.COUNT = CT
                                                    ELEM.NUM = PROCNUM+OUTCOUNT
                                                    GOSUB EXTRACT.ELEMENTS

                                                    * BG_100007698 S
                                                    *
                                                    * Inward swift generic messages, e.g. SWIFT.IN (G)
                                                    *
                                                CASE INDEX(INWARD.LIST<PROCNUM>,'(G)',1)

                                                    SW.CARRIER = FIELD(INWARD.LIST<PROCNUM>,' ',1)
                                                    IF INDEX(SW.CARRIER,'.',1) THEN SW.CARRIER = FIELD(SW.CARRIER,'.',1)
                                                    LOCATE SW.CARRIER IN R.PAR(DE.Config.Parm.ParOutwardCarriers)<1,1> SETTING SW.POS THEN

                                                    IF SW.CARRIER = 'SWIFT' THEN

                                                        GENERIC.ACTIVE.FLAG = 0
                                                        TABLE.NAME = 'TSA.STATUS'
                                                        THE.LIST = DAS.CURRENT$SERVICE
                                                        THE.ARGS = 'DE.CC.GENERIC.IN'
                                                        TABLE.SUFFIX = ''
                                                        EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
                                                        STATUS.LIST = THE.LIST
                                                        LOOP
                                                            REMOVE ID.STATUS FROM STATUS.LIST SETTING MORE
                                                        WHILE ID.STATUS:MORE
                                                            READ STATUS.REC FROM F.TSA.STATUS.LOC, ID.STATUS ELSE READ.ERR = 'Y'
                                                                IF STATUS.REC<EB.Service.TsaStatus.TsTssAgentStatus> = 'RUNNING' THEN
                                                                    GENERIC.ACTIVE.FLAG = 1
                                                                END
                                                            REPEAT

                                                            IF GENERIC.ACTIVE.FLAG THEN
                                                                PARAMFLAG = 'A'
                                                            END ELSE
                                                                PARAMFLAG = 'C'
                                                            END
                                                        END
                                                        ADD.TIME = 30
                                                        Q.NAME = "Generic   : "
                                                        CT = 0
                                                        *
                                                        * Open DE.I.MSG.'INTERFACE' file for getting the list
                                                        R.CARR = ''         ;* BG_100007801 S
                                                        READ R.CARR FROM F.DE.CARRIER,SW.CARRIER ELSE R.CARR = ''
                                                            IF R.CARR THEN SW.INTERFACE = R.CARR<DE.Config.Carrier.CarrInterface>

                                                            FN.DE.I.MSG.INT = 'F.DE.I.MSG.':SW.INTERFACE      ;* BG_100007801 E
                                                            F.DE.I.MSG.INT = ''
                                                            EB.DataAccess.Opf(FN.DE.I.MSG.INT,F.DE.I.MSG.INT)
                                                            SEL.CMD = '' ; KEY.LIST = '' ; NO.OF.KEYS = ''
                                                            SEL.CMD = 'SELECT F.DE.I.MSG.':SW.INTERFACE       ;* BG_100007801 S/E
                                                            EB.DataAccess.Readlist(SEL.CMD,KEY.LIST,'',NO.OF.KEYS,'')
                                                            KEY.CNT +=NO.OF.KEYS
                                                            Q.COUNT = KEY.CNT
                                                            ELEM.NUM = PROCNUM+OUTCOUNT
                                                            GOSUB EXTRACT.ELEMENTS
                                                        END
                                                        * BG_100007698 E

                                                        *
                                                        * Inward euclid DE.I.CC.EUCLID
                                                        *
                                                    CASE INWARD.LIST<PROCNUM> = 'EUCLID'

                                                        LOCATE 'EUCLID' IN R.PAR(DE.Config.Parm.ParInwardCarriers)<1,1> SETTING EU.POS ELSE NULL
                                                        PARAMFLAG = R.PAR(DE.Config.Parm.ParShutInCarrier)<1,EU.POS>
                                                        ADD.TIME = 60
                                                        Q.NAME = "Euclid    : "
                                                        CT = 0
                                                        SELECT F.DE.INWARD.EUCLID
                                                        LOOP
                                                            READNEXT ID ELSE ID = ''
                                                            WHILE ID DO
                                                                CT += 1
                                                            REPEAT
                                                            Q.COUNT = CT
                                                            ELEM.NUM = PROCNUM+OUTCOUNT
                                                            GOSUB EXTRACT.ELEMENTS

                                                            *
                                                            * Formatted telexes DE.CC.SIC
                                                            *
                                                        CASE INWARD.LIST<PROCNUM> = 'SIC'

                                                            LOCATE 'SIC' IN R.PAR(DE.Config.Parm.ParInwardCarriers)<1,1> SETTING TX.POS ELSE NULL
                                                            PARAMFLAG = R.PAR(DE.Config.Parm.ParShutInCarrier)<1,TX.POS>
                                                            ADD.TIME = 120
                                                            Q.NAME = "SIC       : "
                                                            CT = 0
***!                  SELECT F.DE.I.PRI.FTSIC
                                                            EB.DatInterface.Hushit(1)
                                                            EXECUTE "SELECT F.DE.I.PRI.FTSIC"
                                                            CT = @SYSTEM.RETURN.CODE
                                                            CLEARSELECT
                                                            EB.DatInterface.Hushit(0)

                                                            Q.COUNT = CT
                                                            ELEM.NUM = PROCNUM+ OUTCOUNT
                                                            GOSUB EXTRACT.ELEMENTS

                                                    END CASE

                                                    *
                                                    * Add lines of information for display on screen
                                                    *
                                                    TEMP = STR(' ',80)
                                                    TEMP[1,12] = FMT(INWARD.LIST<PROCNUM>,'12L')
                                                    TEMP[13,1] = FMT(FLAGLIST<PROCNUM+OUTCOUNT>,'1L')
                                                    TEMP[18,6] = FMT(USERNO.LIST<PROCNUM+OUTCOUNT>,'6L')
                                                    TEMP[26,15] = FMT(TERM.REASON<PROCNUM+OUTCOUNT>,'15L')
                                                    TEMP[43,19] = FMT(ACTIVITY.LIST<PROCNUM+OUTCOUNT>,'19L')
                                                    TEMP[62,17] = FMT(QUEUE.LIST<PROCNUM+OUTCOUNT,1>:QUEUE.COUNT<PROCNUM+OUTCOUNT,1>,'17L')
                                                    LINE<-1> = TEMP
                                                    *
                                                    ** Add any associated queues after main line
                                                    *
                                                    IF INDEX(QUEUE.LIST<PROCNUM+OUTCOUNT>,@VM,1) THEN
                                                        CTR = COUNT(QUEUE.LIST<PROCNUM+OUTCOUNT>,@VM) + 1
                                                        FOR QNUM = 2 TO CTR
                                                            TEMP = STR(' ',80)
                                                            TEMP[62,17] = QUEUE.LIST<PROCNUM+OUTCOUNT,QNUM>:QUEUE.COUNT<PROCNUM+OUTCOUNT,QNUM>
                                                            LINE<-1> = TEMP
                                                        NEXT QNUM
                                                    END
                                                NEXT PROCNUM
                                            END
                                            RETURN
************************************************************************
                                            *
DISPLAY.SCREEN:
                                            X = 0
                                            LOOP
                                                X +=1
                                            WHILE LINE<X> <> ''
                                                TEMP = LINE<X>
                                                R.TEMP = ''
                                                R.TEMP<1> = TEMP[1,12]
                                                R.TEMP<2> = TEMP[13,1]
                                                R.TEMP<3> = TEMP[18,6]
                                                R.TEMP<4> = TEMP[26,15]
                                                R.TEMP<5> = TEMP[43,19]
                                                LAST.BIT = TEMP[62,17]
                                                R.TEMP<6> = FIELD(LAST.BIT, ':',1)
                                                R.TEMP<7> = FIELD(LAST.BIT, ':',2)
                                                IF R.TEMP<1>[1,6] = 'Inward' THEN
                                                    R.TEMP<1> = 'Inward Phantoms'
                                                    R.TEMP<2> = ''
                                                    R.TEMP<3> = ''
                                                    R.TEMP<4> = ''
                                                    R.TEMP<5> = ''
                                                END
                                                WRITE R.TEMP ON F.GUI.DE.MONITOR, X
                                                REPEAT
                                                *
                                                * Other items included here not from the original DE.MONITOR code!
                                                *
                                                X += 1
                                                R.TEMP = ''
                                                R.TEMP<1> = "Other Queues"
                                                WRITE R.TEMP ON F.GUI.DE.MONITOR, X
                                                    *
                                                    * Ps Queue
                                                    TABLE.NAME = 'PS.QUEUE'
                                                    THE.LIST = 'ALL.IDS'
                                                    TABLE.SUFFIX = ''
                                                    THE.ARGS = ''
                                                    EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
                                                    NO.PSQ = DCOUNT(THE.LIST,@FM)
                                                    X += 1
                                                    R.TEMP = ''
                                                    R.TEMP<1> = "PS.QUEUE"
                                                    R.TEMP<7> = NO.PSQ
                                                    WRITE R.TEMP ON F.GUI.DE.MONITOR, X
                                                        *
                                                        * Get rid of any old records
                                                        *
                                                        IF NO.OLD.RECS >= X THEN
                                                            FOR I = X TO NO.OLD.RECS
                                                                DELETE F.GUI.DE.MONITOR, I
                                                                NEXT I
                                                            END
                                                            RETURN
************************************************************************
                                                            *
DISPLAY.TIME:

                                                            TEMP.TIME = OCONV(TIME(),'MTS')
                                                            TEMP.DATE = OCONV(DATE(),'D4 E')
                                                            RETURN
                                                            *
************************************************************************
                                                            *
EXTRACT.ELEMENTS:
                                                            *
                                                            ACTIVITY.LIST<ELEM.NUM> = R.PHANT<DE.API.PhantomLog.PhlLastActivity>
                                                            QUEUE.COUNT<ELEM.NUM> = Q.COUNT
                                                            *
                                                            * If phantom status flag has changed since last checked
                                                            *
                                                            IF PARAMFLAG <> FLAGLIST<ELEM.NUM> THEN
                                                                *
                                                                * If phantom now active erase last termination reason.
                                                                * If phantom now closed assign the termination reason in the log and
                                                                * give a warning if this was not "Normal".
                                                                *
                                                                IF PARAMFLAG = 'A' THEN
                                                                    TERM.REASON<ELEM.NUM> = ''
                                                                END ELSE
                                                                    TERM.REASON<ELEM.NUM> = R.PHANT<DE.API.PhantomLog.PhlLastTermination>
                                                                    IF TERM.REASON<ELEM.NUM> <> "Normal" THEN WARNING = 1 ELSE WARNING = 0
                                                                END
                                                                FLAGLIST<ELEM.NUM> = PARAMFLAG

                                                            END ELSE
                                                                *
                                                                * Phantom status has not changed since last read
                                                                *
                                                                * If phantom is active but the last activity is many eons in the past
                                                                * and the number of messages in the queue has not changed then warn user
                                                                *
                                                                IF PARAMFLAG = 'A' AND TIME()-ICONV(ACTIVITY.LIST<ELEM.NUM>[10,8],'MTS') > R.PAR(DE.Config.Parm.ParWaitTime)*60+ADD.TIME THEN
                                                                    WARNING = 1
                                                                END ELSE
                                                                    WARNING = 0
                                                                END
                                                            END
                                                            *
                                                            * If Phantom now closed erase the user number
                                                            *
                                                            IF FLAGLIST<ELEM.NUM> <> 'C' THEN USERNO.LIST<ELEM.NUM> = R.PHANT<DE.API.PhantomLog.PhlPhantomNo> ELSE USERNO.LIST<ELEM.NUM> = ''
                                                            QUEUE.LIST<ELEM.NUM> = Q.NAME
                                                            *
                                                            * If the warning flag is on then display the warning with a bell
                                                            *
                                                            IF WARNING THEN
                                                                IF R.PHANT<DE.API.PhantomLog.PhlLastTermination> <> "Normal" THEN
                                                                    TERM.REASON<ELEM.NUM> = R.PHANT<DE.API.PhantomLog.PhlLastTermination>
                                                                END ELSE
                                                                    TERM.REASON<ELEM.NUM> = "Abnormal"
                                                                END
                                                                IF ELEM.NUM <= OUTCOUNT THEN
                                                                    WARNING.LINE = EB.Desktop.getSReverseVideoOn():CHARX(7):"WARNING - ":OUTWARD.LIST<ELEM.NUM>:" - Possible abnormal condition":EB.Desktop.getSReverseVideoOff():EB.Desktop.getSClearEol()
                                                                END ELSE
                                                                    WARNING.LINE = EB.Desktop.getSReverseVideoOn():CHARX(7):"WARNING - ":INWARD.LIST<ELEM.NUM-OUTCOUNT>:" - Possible abnormal condition":EB.Desktop.getSReverseVideoOff():EB.Desktop.getSClearEol()
                                                                END
                                                            END ELSE
                                                                *
                                                                * If no warning clear the old warning and reason
                                                                *
                                                                IF FLAGLIST<ELEM.NUM> = "A" THEN TERM.REASON<ELEM.NUM> = ''
                                                            END
                                                            RETURN
GET.PRI.QUEUE.LIST:
****************
                                                            P.KEY = '';  P.KEY<1> = 'U'; P.KEY<2> = 'P'; P.KEY<3> = 'N'
                                                            KEY.COUNT = 0
                                                            FOR V$NUM = 1 TO 3
                                                                SEL.CMD = ''; KEY.LIST = '';NO.OF.KEYS = ''
                                                                SEL.CMD = 'SELECT ':FN.DE.O.PRI.CC:' WITH @ID LIKE ':P.KEY<V$NUM>:'-...'
                                                                EB.DataAccess.Readlist(SEL.CMD,KEY.LIST,'',NO.OF.KEYS,'')
                                                                KEY.COUNT +=NO.OF.KEYS
                                                            NEXT V$NUM
                                                            RETURN
                                                        END
