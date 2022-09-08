* @ValidationCode : MjoxMTEwNDY3Nzg3OmNwMTI1MjoxNTk5NjM5OTYyNTI2OnNhaWt1bWFyLm1ha2tlbmE6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMi4yMDIwMDExNy0yMDI2Ojk1OjUx
* @ValidationInfo : Timestamp         : 09 Sep 2020 13:56:02
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : saikumar.makkena
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 51/95 (53.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE PV.Config

*-----------------------------------------------------------------------------
*
* Modification History :
*
* 13/11/18 - Defect 2827221 / Task 2852475
*            Customised routine to be released from Dev for creating demo data for Provision details for AA
*
* 01/10/19 - Task 3367725
*            API changes to return Class Details for Overdraft accounts, Facility and SL Loans
*
* 01/10/19 - Task 3411527
*            Api changes to return the correct classification when NAB status is set.
*            To return the classifcation for Arrangement contracts based on contractual days when overduestatus not present.
*
* 31/01/20 - Enhancement 3543337 / Task 3543340
*            API changes for BL provisioning classification
*
*-----------------------------------------------------------------------------
SUBROUTINE PV.MB.GET.CLASSIFICATION(APP.NAME,CONT.ID,R.CONTRACT,RETURN.CLASS,CLASS.ERR)

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER
    $INSERT I_F.COUNTRY
    $INSERT I_F.LD.LOANS.AND.DEPOSITS
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.PD.CAPTURE
    $INSERT I_F.MM.MONEY.MARKET
    $INSERT I_F.SL.LOANS
    $INSERT I_F.FACILITY
    $INSERT I_F.LIMIT
    $INSERT I_F.BL.REGISTER

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN

*--------------------------------------------------------------------------
PROCESS:

    IF OD.STATUS EQ "" AND CONTRACT.VAL.DATE THEN
        GOSUB PROCESS.BASED.ON.DAYS ; * Process the contract and return the classification based on the contractual days, if OD status not found.
        RETURN
    END
    BEGIN CASE

        CASE OD.STATUS MATCHES "GRA":@VM:"GRC":@VM:"CUR"
            RETURN.CLASS = 'STANDARD'

        CASE OD.STATUS MATCHES "PDO":@VM:"OD1":@VM:"OD2":@VM:"DEL"
            RETURN.CLASS = 'WATCHLIST'

        CASE OD.STATUS MATCHES "NAB":@VM:"WOF"
            RETURN.CLASS = 'WRITEOFF'
        CASE 1
            RETURN.CLASS = 'STANDARD'

    END CASE
RETURN
*--------------------------------------------------------------------------
INITIALISE:

    OD.STATUS = ""
    RETURN.CLASS = ""
    TODAY.DATE = TODAY
    CONTRACT.DUE.DAYS = ''

    IF APP.NAME[1,2] EQ 'LD' THEN
        CONTRACT.VAL.DATE = R.CONTRACT<LD.VALUE.DATE>
        OD.STATUS = R.CONTRACT<LD.OVERDUE.STATUS>
    END

    IF NUM(CONT.ID) THEN
        AA.ID = R.CONTRACT<AC.ARRANGEMENT.ID>
        IF NOT(AA.ID) THEN
            CONTRACT.VAL.DATE = R.CONTRACT<AC.OPENING.DATE>
            OD.STATUS = R.CONTRACT<AC.OVERDUE.STATUS>
        END ELSE
            FN.ARR = "F.AA.ACCOUNT.DETAILS"
            F.ARR = ""
            CALL OPF(FN.ARR, F.ARR)
            CALL F.READ(FN.ARR, AA.ID , R.ARR ,F.ARR ,ERR)
            CONTRACT.VAL.DATE = R.ARR<AA.AD.VALUE.DATE>
            IF NOT(CONTRACT.VAL.DATE) THEN
                FN.ARR = "F.AA.ARRANGEMENT"
                F.ARR = ""
                CALL OPF(FN.ARR, F.ARR)
                CALL F.READ(FN.ARR, AA.ID , R.ARR ,F.ARR ,ERR)
                CONTRACT.VAL.DATE = R.ARR<AA.ARR.PROD.EFF.DATE>
            END
        END
    END

    IF CONT.ID[1,2] EQ "AA" THEN

        FN.APP = "F.AA.ACCOUNT.DETAILS"
        F.APP = ""
        CALL OPF(FN.APP,F.APP)
        
        CALL F.READ(FN.APP,CONT.ID,R.REC,F.APP,ERR)
        OD.STATUS = R.REC<AA.AD.ARR.AGE.STATUS>
        CONTRACT.VAL.DATE = R.REC<AA.AD.VALUE.DATE>
        
    END

    IF APP.NAME[1,2] EQ 'SL' THEN
        CONTRACT.VAL.DATE = R.CONTRACT<SL.LN.VALUE.DATE>
        OD.STATUS = R.CONTRACT<SL.LN.OVERDUE.STATUS>
    END
    IF APP.NAME[1,2] EQ 'FA' THEN
        CONTRACT.VAL.DATE = R.CONTRACT<FAC.VALUE.DATE>
        OD.STATUS = R.CONTRACT<FAC.OVERDUE.STATUS>
    END
    IF APP.NAME[1,2] EQ  'LI' THEN
        CONTRACT.VAL.DATE = "20200417"
    END
    
    IF APP.NAME[1,2] EQ 'BL' THEN
        CONTRACT.VAL.DATE = R.CONTRACT<BL.REG.START.DATE>
        OD.STATUS = R.CONTRACT<BL.REG.OVERDUE.STATUS>
    END
    
RETURN

*-----------------------------------------------------------------------------

PROCESS.BASED.ON.DAYS:

    CALL CDD('',CONTRACT.VAL.DATE,TODAY.DATE,CONTRACT.DUE.DAYS)
    
    BEGIN CASE
        CASE CONTRACT.DUE.DAYS GE 0 AND CONTRACT.DUE.DAYS LT 2
            RETURN.CLASS = 'STANDARD'

        CASE CONTRACT.DUE.DAYS GE 2 AND CONTRACT.DUE.DAYS LT 3
            RETURN.CLASS = 'WATCHLIST'

        CASE CONTRACT.DUE.DAYS GE 3
            RETURN.CLASS = 'WRITEOFF'

    END CASE

RETURN

*-----------------------------------------------------------------------------


END

