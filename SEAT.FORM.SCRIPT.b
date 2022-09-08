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

*-----------------------------------------------------------------------------
* <Rating>-136</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SE.TestFramework
    SUBROUTINE SEAT.FORM.SCRIPT
**************************************************************************
** Routine to populate the SEAT.SCRIPTS with respective application fields
** and values. This routine has to be attached to the AFTER.UNAU.RTN field
** in the version named <APPLICATION>,SEAT. The user has to input the
** required transaction using this version for the SEAT.SCRIPTS to get
** populated in the SEAT.SCRIPTS file in IHLD
**************************************************************************
* MODIFICATION.HISTORY:
***********************
*  14/04/2008 - CI_10054701
*               The common variable PGM.TYPE has been modified to have the string
*               ".IDA" before calling the routine GET.NEXT.ID for generating the ID
*               for the new record in SEAT.SCRIPTS file.
*
* 25/06/2008 - CI_10056323
*              Changes done to update the SCHEDULE details in the seat scripts
* 09/06/09 - BG_100023950
*            Open the file using READ or CACHE.READ ; instead of F.READ [because we are out of transaction boundary]
*
***************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SEAT.SCRIPTS
    $INSERT I_F.STANDARD.SELECTION
    $INSERT I_F.LD.LOANS.AND.DEPOSITS
    $INSERT I_F.FOREX
    $INSERT I_F.PGM.FILE
    $INSERT I_F.SPF
*****************************************************

    GOSUB INITIALISE
    GOSUB READ.STD.SELECTION
    GOSUB PROCESS
    GOSUB SPL.PROCESSING      ;** For LD Schedules/FOREX SWAP
    GOSUB WRITE.SCRIPT

    RETURN
****************************************************
INITIALISE:
**********
    LD.SCHED.FLAG = ''  ;
    FX.SW.FLAG = '';
    SWAP.REF.NO = '' ;
    R.SEAT.SCRIPTS = ''

    APPL.NAME = APPLICATION
    APPL.ID = ID.NEW

    FN.SEAT.SCRIPTS = 'F.SEAT.SCRIPTS$NAU'
    F.SEAT.SCRIPTS = ''
    CALL OPF(FN.SEAT.SCRIPTS,F.SEAT.SCRIPTS)

    FN.PGM.FILE = 'F.PGM.FILE'
    F.PGM.FILE = ''
    CALL OPF(FN.PGM.FILE, F.PGM.FILE)

    RETURN

************************
READ.STD.SELECTION:
************************

* Get the Standard Selection of the application

    STD.SEL.REC = ''
    MATBUILD STD.SEL.REC FROM R.NEW

    IF LD.SCHED.FLAG EQ 'Y' AND APPL.NAME EQ 'LD.SCHEDULE.DEFINE' THEN
        FN.APPLICATION = "F." : APPL.NAME: '$NAU'
        F.APPLICATION = ""
        APPL.ID = ID.NEW
        CALL OPF(FN.APPLICATION, F.APPLICATION)
        READ R.APPLICATION FROM F.APPLICATION,APPL.ID ELSE
            APP.ERR = 'READ ERROR'
        END
        STD.SEL.REC = R.APPLICATION
    END

    IF LD.SCHED.FLAG EQ '' AND FX.SW.FLAG EQ '' THEN
        GOSUB CHECK.LD.FX
    END
    STANDARD.SEL= ""
    CALL GET.STANDARD.SELECTION.DETS(APPL.NAME, STANDARD.SEL)

    LAST.FLD.POS = ''
    LOCATE 'AUDIT.DATE.TIME' IN STANDARD.SEL<SSL.SYS.FIELD.NAME,1> SETTING LAST.FLD.POS THEN
        LAST.FLD.NO = STANDARD.SEL<SSL.SYS.FIELD.NO,LAST.FLD.POS>
    END

    RETURN
****************************************************
PROCESS:
*******

    YFLD.POS = 0 ;    FIELD.NAME = '' ;    FIELD.VAL = '' ;    FIELD.INPUT = ''

    LOOP
        YYFLD.POS = '' ; YFLD.NAME = '' ; YFLD.VAL = '' ; YERR = '' ; MV.POS = '' ;  SV.POS = ''; NOINPUT.FLAG = '' ;
        YFLD.POS += 1
        IF YFLD.POS EQ (LAST.FLD.NO - 8) THEN
            EXIT
        END
        LOCATE YFLD.POS IN STANDARD.SEL<SSL.SYS.FIELD.NO,1> SETTING YYFLD.POS ELSE
            YERR = 1
        END
        IF YERR EQ 1 AND APPL.NAME EQ 'LD.LOANS.AND.DEPOSITS' AND YFLD.POS EQ '116' THEN
            YERR = ''
        END
    WHILE NOT(YERR) DO
        NOINPUT.FLAG = STANDARD.SEL<SSL.SYS.VAL.PROG,YYFLD.POS>
        NOINPUT.FLAG = (FIELD(NOINPUT.FLAG,"&",3,2)= 'NOINPUT')
        IF  NOINPUT.FLAG THEN
            CONTINUE
        END

* Dont include Language fields and include only Data Fields
        IF STANDARD.SEL<SSL.SYS.LANG.FIELD,YYFLD.POS> NE "N" OR STANDARD.SEL<SSL.SYS.TYPE,YYFLD.POS> NE "D" THEN
            CONTINUE
        END

        YFLD.NAME = STANDARD.SEL<SSL.SYS.FIELD.NAME,YYFLD.POS>

* Dont include LOCAL.REF fields, RESERVED fields, OVERRIDES and STATEMENT.NOS fields
        IF YFLD.NAME EQ 'LOCAL.REF' OR YFLD.NAME[1,8] EQ 'RESERVED' OR  YFLD.NAME EQ 'OVERRIDE' OR YFLD.NAME EQ 'STATEMENT.NOS' THEN
            CONTINUE          ;* Don't include Local ref fields
        END

        IF APPLICATION EQ 'SEC.TRADE' AND YFLD.NAME EQ "BR.TRD.TIME" THEN
            CONTINUE          ;* Dont include BR.TRD.TIME field for SEC.TRADE
        END

        IF STANDARD.SEL<SSL.SYS.SINGLE.MULT,YYFLD.POS> = "M" THEN
            GOSUB MULTI.VALUE.PROCESS
        END ELSE
            GOSUB SINGLE.VALUE.PROCESS
        END

    REPEAT

    CONVERT FM TO VM IN FIELD.NAME
    CONVERT FM TO VM IN FIELD.VAL
    CONVERT FM TO VM IN FIELD.INPUT

* To use the core routine GET.NEXT.ID, for generating the ID for the script
* the variables APPLICATION and FULL.FNAME
* need to re-assigned to SEAT.SCRIPTS and not the current application
* by calling COMMON.SAVE and restored using COMMON.RESTORE


    CALL COMMON.SAVE
    APPLICATION = 'SEAT.SCRIPTS'
    FULL.FNAME = 'F.SEAT.SCRIPTS'
    PGM.TYPE := ".IDA"
    SST.ID = ''
    CALL GET.NEXT.ID(SST.ID,'F')
    SST.ID = COMI
    CALL COMMON.RESTORE

    R.SEAT.SCRIPTS<EB.STC.COMPANY.CODE> = ID.COMPANY
    R.SEAT.SCRIPTS<EB.STC.SCRIPT.STATUS> = 'ACTIVE'
    R.SEAT.SCRIPTS<EB.STC.SCRIPT.SOURCE> = 'MANUAL TEST'
    R.SEAT.SCRIPTS<EB.STC.ALTERNATE.REF> = ID.NEW
    R.SEAT.SCRIPTS<EB.STC.APPLICATION> = APPLICATION

    YAPPLICATION = APPLICATION
    R.PGM = '' ;
    PGM.ERR = ''
    CALL CACHE.READ(FN.PGM.FILE, YAPPLICATION, R.PGM, PGM.ERR)
    R.SEAT.SCRIPTS<EB.STC.PRODUCT.CODE> = R.PGM<EB.PGM.PRODUCT>

    R.SEAT.SCRIPTS<EB.STC.SCRIPT.GROUP> = 'NEW'
    R.SEAT.SCRIPTS<EB.STC.VERSION> = APPLICATION : ",SEAT"
    R.SEAT.SCRIPTS<EB.STC.FUNCTION> = V$FUNCTION
    R.SEAT.SCRIPTS<EB.STC.TXN.ID> = ID.NEW
    R.SEAT.SCRIPTS<EB.STC.CREATED.BY> = OPERATOR
    R.SEAT.SCRIPTS<EB.STC.RECORD.STATUS> = 'IHLD'

    IF LD.SCHED.FLAG EQ '' AND FX.SW.FLAG EQ '' THEN
        R.SEAT.SCRIPTS<EB.STC.FIELD.NAME> = FIELD.NAME
        R.SEAT.SCRIPTS<EB.STC.FIELD.VALUE> = FIELD.VAL
        R.SEAT.SCRIPTS<EB.STC.FIELD.INPUT> = FIELD.INPUT
    END
    RETURN
********************
MULTI.VALUE.PROCESS:
********************

    FOR MV.POS = 1 TO DCOUNT(STD.SEL.REC<YFLD.POS>,@VM)
        GOSUB SUB.VALUE.PROCESS
    NEXT MV.POS
    RETURN

*****************
SUB.VALUE.PROCESS:
*****************

    FOR SV.POS = 1 TO DCOUNT(STD.SEL.REC<YFLD.POS,MV.POS>,@SM)

        IF STD.SEL.REC<YFLD.POS,MV.POS,SV.POS> EQ '0' THEN
            CONTINUE
        END
        IF STD.SEL.REC<YFLD.POS,MV.POS,SV.POS> NE '' THEN   ;* Only update fields having value(not Null)
            FIELD.NAME<-1> = YFLD.NAME : ":" : MV.POS : ":" : SV.POS
            IF APPL.NAME EQ 'LD.SCHEDULE.DEFINE' AND YFLD.NAME EQ 'AMOUNT' THEN
                FIELD.VAL<-1> = LD.CCY:STD.SEL.REC<YFLD.POS,MV.POS,SV.POS>
            END ELSE
                GOSUB PROCESS.FX.SUB.VALUE
            END
            FIELD.INPUT<-1> = 'YES'
        END
    NEXT SV.POS
    RETURN

*--------------------
PROCESS.FX.SUB.VALUE:
*---------------------
    IF APPL.NAME EQ 'FOREX' AND FX.FIRST.FLAG EQ 'NO' THEN
        FIELD.VAL<-1> = '_':STD.SEL.REC<YFLD.POS,MV.POS,SV.POS>
    END ELSE
        FIELD.VAL<-1> = STD.SEL.REC<YFLD.POS,MV.POS,SV.POS>
    END
    RETURN

*--------------------
SINGLE.VALUE.PROCESS:
*--------------------

    MV.POS = 1 ;
    SV.POS = 1
    IF STD.SEL.REC<YFLD.POS,MV.POS,SV.POS> NE '' THEN       ;* Only update fields having value(not Null)
        FIELD.NAME<-1> = YFLD.NAME : ":" : MV.POS : ":" : SV.POS
        IF APPL.NAME EQ 'FOREX' AND FX.FIRST.FLAG EQ 'NO' THEN
            FIELD.VAL<-1> = '_':STD.SEL.REC<YFLD.POS,MV.POS,SV.POS>
        END ELSE
            FIELD.VAL<-1> = STD.SEL.REC<YFLD.POS,MV.POS,SV.POS>
        END
        FIELD.INPUT<-1> = 'YES'
    END

    RETURN
**********************
SPL.PROCESSING:
**********************
* The LD Transactions which might have Schedules have to be processed

    IF LD.SCHED.FLAG EQ 'Y' THEN

        APPL.NAME = 'LD.SCHEDULE.DEFINE'
        LD.FIELD.NAME = FIELD.NAME
        LD.FIELD.VAL = FIELD.VAL
        LD.FIELD.INPUT = FIELD.INPUT
        GOSUB READ.STD.SELECTION
        GOSUB PROCESS
        R.SEAT.SCRIPTS<EB.STC.FIELD.NAME> = LD.FIELD.NAME:@VM:'//':FIELD.NAME
        R.SEAT.SCRIPTS<EB.STC.FIELD.VALUE> = LD.FIELD.VAL:@VM:FIELD.VAL
        R.SEAT.SCRIPTS<EB.STC.FIELD.INPUT> = LD.FIELD.INPUT:@VM:FIELD.INPUT
    END

* The SWAP type FOREX contract has to be handled seperately

    IF FX.SW.FLAG EQ 'Y' THEN
        FX.FIRST.FLAG = 'NO'
        APPL.ID = SWAP.REF.NO
        SWAP.FIELD.NAME = FIELD.NAME
        SWAP.FIELD.VAL = FIELD.VAL
        SWAP.FIELD.INPUT = FIELD.INPUT
        GOSUB READ.STD.SELECTION
        GOSUB PROCESS
        R.SEAT.SCRIPTS<EB.STC.FIELD.NAME> = SWAP.FIELD.NAME:@VM:FIELD.NAME
        R.SEAT.SCRIPTS<EB.STC.FIELD.VALUE> = SWAP.FIELD.VAL:@VM:FIELD.VAL
        R.SEAT.SCRIPTS<EB.STC.FIELD.INPUT> = SWAP.FIELD.INPUT:@VM:FIELD.INPUT
    END
    RETURN


*******************
CHECK.LD.FX:
*******************

* To check whether the transaction is an LD with schedules
* or a SWAP type FOREX contract

    IF APPL.NAME EQ 'LD.LOANS.AND.DEPOSITS' THEN

        IF STD.SEL.REC<LD.DEFINE.SCHEDS> EQ 'YES' THEN
            LD.SCHED.FLAG = 'Y'
            LD.CCY = STD.SEL.REC<LD.CURRENCY>
        END
    END

    IF APPL.NAME EQ 'FOREX' THEN
        IF STD.SEL.REC<FX.DEAL.TYPE> EQ 'SW' THEN
            SWAP.REF.NO = STD.SEL.REC<FX.SWAP.REF.NO,2>
            FX.SW.FLAG = 'Y'
            FX.FIRST.FLAG = 'YES'
        END
    END
    RETURN

*****************************************************
WRITE.SCRIPT:
************
* Write the formed script into F.SEAT.SCRIPTS

    WRITE R.SEAT.SCRIPTS TO F.SEAT.SCRIPTS, SST.ID
    RETURN
****************************************************
END
