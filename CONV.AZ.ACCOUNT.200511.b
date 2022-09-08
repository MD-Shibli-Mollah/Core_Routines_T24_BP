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
* <Rating>-21</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AZ.Contract
    SUBROUTINE CONV.AZ.ACCOUNT.200511(AZ.ID,AZ.REC,YFILE.REC)
*
* 19/09/05 - CI_10035225
*            New conversion routine to update AZ>CURR.HIST.NO and AZ.SCHEDULES>CURR.HIST.NO.
*
* 21/10/05 - CI_10035875/CI_10035876
*            A new field ORIG.INTEREST.RATE is added in AZ.ACCOUNT which will hold the interest
*            rate as of value date of the contract. Conversion is to update the interest rate for
*            existing contracts also.
*
* 26/12/05 - CI_10037651
*            OPF's for the AZ files are read along with the company Mnemonics so that conversion
*            is being run correctly as per the company.
*
* 23/01/06 - CI_10038463
*            Inorder to improve performance, only updation of Original
*            interest rate is done here.Updation of CURR.HIST.NO is
*            moved to new conversion CONV.AZ.HIST.FILES.R05
*
* 30/11/06 - CI_10045823
*            Swap the field values
*
* 14/12/07 - CI_10052953
*            IF TYPE.I or TYPE.N schedule is updated with "0" ACCR.INT ,then it leads to
*            wrong calculation of next TYPE.I amount.So ACCR.INT field is made null,if ACCR.INT
*            is updated as "0" in TYPE.I & TYPE.N amt.
*
**************************************************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE

*
    EQU AZ.SLS.DATE TO 2,
    AZ.SLS.TYPE.B TO 3,
    AZ.SLS.TYPE.B.SYS TO 4,
    AZ.SLS.TYPE.P TO 5,
    AZ.SLS.TYPE.I TO 6,
    AZ.SLS.TYPE.C TO 7,
    AZ.SLS.TYPE.N TO 18,
    AZ.SLS.TYPE.R TO 22,
    AZ.SLS.ONLINE.AMT TO 46,
    AZ.SLS.ACCR.INT TO 37,
    AZ.REPAYMENT.TYPE TO 48

    GOSUB OPEN.FILES
    GOSUB PROCESS
    RETURN

*-----------
OPEN.FILES:
*-----------
    U.MNE = ''      ;* CI _10037651/S
    U.MNE = FIELD(YFILE.REC,".",1)      ;* CI_10037651/E

    FN.AZ.SCHEDULES = U.MNE:'.AZ.SCHEDULES' ; FV.AZ.SCHEDULES = ''    ;* CI_10037651 S/E
    CALL OPF(FN.AZ.SCHEDULES,FV.AZ.SCHEDULES)
    RETURN
*
*------------
INIT.VARS:
*------------
*Intialising
    PTYPE =  0
    V.ITYPE =  0
    CTYPE = 0
    BTYPE = 0
    ONLINE.AMT.TYPE = 0
    BSYS.TYPE = 0
    NTYPE = 0
    RTYPE = 0

    RETURN

*-------------------
GET.TYPE.SCH:
*-------------------
*Type of sch.
    IF (R.AZ.SCHEDULES<AZ.SLS.TYPE.B,NO.SCH>)  NE  '' THEN
        BTYPE = 1
    END
    IF (R.AZ.SCHEDULES<AZ.SLS.TYPE.B.SYS,NO.SCH>) NE ''  THEN
        BSYS.TYPE = 1
    END
    IF (R.AZ.SCHEDULES<AZ.SLS.TYPE.P,NO.SCH>) NE '' THEN
        PTYPE = 1
    END
    IF (R.AZ.SCHEDULES<AZ.SLS.TYPE.I,NO.SCH>) NE '' THEN
        V.ITYPE = 1
    END
    IF (R.AZ.SCHEDULES<AZ.SLS.TYPE.C,NO.SCH>) NE  '' THEN
        CTYPE =1
    END
    IF (R.AZ.SCHEDULES<AZ.SLS.TYPE.N,NO.SCH>) NE '' THEN
        NTYPE =1
    END
    IF (R.AZ.SCHEDULES<AZ.SLS.TYPE.R,NO.SCH>) NE ''  THEN
        RTYPE = 1
    END
    IF (R.AZ.SCHEDULES<AZ.SLS.ONLINE.AMT,NO.SCH>) NE ''  THEN
        ONLINE.AMT.TYPE = 1
    END

    RETURN
*
*-------
PROCESS:
*-------
*
    R.AZ.SCHEDULES = ''  ; AZ.SCH.ERR = '' ; WRITE.FLAG = 0
    READ R.AZ.SCHEDULES FROM FV.AZ.SCHEDULES, AZ.ID    THEN
        AZ.REC<99> = R.AZ.SCHEDULES<22,1>
    END

* CI_10045823 - S// In R05, Field number 100 is having the value of Principal increase and decrease amount.
* But in R07, field number 105 is holding this values. So here swap the amount from 100 to 105
* and nullifying the 100th field.
    AZ.REC<105> = AZ.REC<100>
    AZ.REC<100> = ''          ;* CI_10045823 - S

    IF AZ.REC<AZ.REPAYMENT.TYPE> EQ  'CREDIT-CARD'  THEN    ;* CI_10052953 S
        RETURN
    END
    IF R.AZ.SCHEDULES THEN
        NO.OF.SCHDLES = DCOUNT(R.AZ.SCHEDULES<AZ.SLS.DATE> , VM)
        FOR NO.SCH = 2 TO NO.OF.SCHDLES ;* first sch date without considering value date.
            GOSUB INIT.VARS
            GOSUB GET.TYPE.SCH
            IF V.ITYPE OR (CTYPE OR NTYPE  AND NOT(RTYPE OR BTYPE OR PTYPE OR ONLINE.AMT.TYPE OR BSYS.TYPE) ) THEN
                IF R.AZ.SCHEDULES<AZ.SLS.ACCR.INT,NO.SCH>  NE  "0"   THEN
                    RETURN
                END
                GOSUB PROCESS.ACCR.INT
                EXIT
            END
        NEXT NO.SCH

    END   ;* CI_10052953 E

    RETURN

*----------------------------
PROCESS.ACCR.INT:
*----------------------------
    CHK.SCH =  NO.SCH
    FOR NO.SCH = CHK.SCH TO NO.OF.SCHDLES         ;* first sch date without considering value date.
        GOSUB INIT.VARS
        GOSUB GET.TYPE.SCH
        BEGIN CASE
        CASE V.ITYPE
            R.AZ.SCHEDULES<AZ.SLS.ACCR.INT,NO.SCH> =  ""
            WRITE.FLAG  = 1

        CASE RTYPE OR BTYPE OR ONLINE.AMT.TYPE OR BSYS.TYPE OR PTYPE

        CASE NTYPE OR CTYPE
            R.AZ.SCHEDULES<AZ.SLS.ACCR.INT,NO.SCH> =  ""
            WRITE.FLAG =1
        END CASE

    NEXT NO.SCH

    IF WRITE.FLAG THEN
        WRITE R.AZ.SCHEDULES TO FV.AZ.SCHEDULES,AZ.ID
    END

    RETURN

END
