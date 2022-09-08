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
* <Rating>-32</Rating>
*-----------------------------------------------------------------------------
* Subroutine Type : Subroutine

* Attached as     : Conversion Routine

* Primary Purpose : To return the Bill Ids given Arrangement Id

* Change History  :

* Version         : First Version

* Author          : vhariharane@temenos.com

************************************************************
*MODIFICATION HISTORY
*
* 05/01/09 - BG_100021512
*            Arguments changed for SIM.READ.
* 04/03/11 - Task - 166099
*            Defect - 164216
*            multiple binoculars button for a single bill
*
* 25/03/14  - Task : 948832
*             Defect : 919187
*     Enquiry enhanced to support .HIST files as well for AA.BILL.DETAILS & AA.ACCOUNT.DETAILS
************************************************************
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.GET.BILLS.CONVERSION
************************************************************

    $USING AA.PaymentSchedule
    $USING EB.Reports
    $USING EB.DatInterface
    $USING EB.DataAccess


****************************
*
    GOSUB INITIALISE
    GOSUB PROCESS
*
    RETURN
****************************
INITIALISE:
*

    ARR.ID = EB.Reports.getOData()['%',1,1]
    SIM.REF = EB.Reports.getOData()['%',2,1]
*
    R.AC.DETAILS.SIM = ''

    FN.AA.ACCOUNT.DETAILS = "F.":EB.Reports.getREnq()<2>
    FN.AA.BILL.DETAILS = CHANGE(FN.AA.ACCOUNT.DETAILS,"AA.ACCOUNT.DETAILS","AA.BILL.DETAILS")

    IF SIM.REF THEN
        EB.DatInterface.SimRead(SIM.REF, FN.AA.ACCOUNT.DETAILS, ARR.ID, R.AC.DETAILS.SIM, "", "", RET.ERR)
    END ELSE
        EB.DataAccess.FRead(FN.AA.ACCOUNT.DETAILS, ARR.ID, R.AC.DETAILS.SIM, F.AA.AC, RET.ERR)
    END
*
    RETURN
**********************
PROCESS:
**********************

    PROCESS.END = ''
    RET.ID = ''
    RET.DT = ''
    BILLS = R.AC.DETAILS.SIM<AA.PaymentSchedule.AccountDetails.AdBillId>
    BILL.PAY.DT = R.AC.DETAILS.SIM<AA.PaymentSchedule.AccountDetails.AdBillPayDate>
    NO.DT = DCOUNT(BILLS,@VM)
    FOR LOOP.CNT = 1 TO NO.DT
        BILL.IDS = BILLS<1,LOOP.CNT>
        PAY.DT = BILL.PAY.DT<1,LOOP.CNT>
        NO.BILLS = DCOUNT(BILL.IDS,@SM)
        FOR CNT.BILL = 1 TO NO.BILLS
            TEMP.RET.DT<1,NO.DT-LOOP.CNT+1,NO.BILLS-CNT.BILL+1> = PAY.DT
            BILL.ID = BILL.IDS<1,1,CNT.BILL>
            GOSUB CHECK.SIM
            RET.ID<1,NO.DT-LOOP.CNT+1,NO.BILLS-CNT.BILL+1> = BILL.ID
            RET.ACT.REF<1,NO.DT-LOOP.CNT+1,NO.BILLS-CNT.BILL+1> = R.AC.DETAILS.SIM<AA.PaymentSchedule.AccountDetails.AdActivityRef,LOOP.CNT,CNT.BILL>
            RET.BILL.DT<1,NO.DT-LOOP.CNT+1,NO.BILLS-CNT.BILL+1> = R.AC.DETAILS.SIM<AA.PaymentSchedule.AccountDetails.AdBillDate,LOOP.CNT,CNT.BILL>
            RET.BILL.TYP<1,NO.DT-LOOP.CNT+1,NO.BILLS-CNT.BILL+1> = R.AC.DETAILS.SIM<AA.PaymentSchedule.AccountDetails.AdBillType,LOOP.CNT,CNT.BILL>
            RET.PAY.MET<1,NO.DT-LOOP.CNT+1,NO.BILLS-CNT.BILL+1> = R.AC.DETAILS.SIM<AA.PaymentSchedule.AccountDetails.AdPayMethod,LOOP.CNT,CNT.BILL>
            RET.BILL.ST<1,NO.DT-LOOP.CNT+1,NO.BILLS-CNT.BILL+1> = R.AC.DETAILS.SIM<AA.PaymentSchedule.AccountDetails.AdBillStatus,LOOP.CNT,CNT.BILL>
            RET.SET.ST<1,NO.DT-LOOP.CNT+1,NO.BILLS-CNT.BILL+1> = R.AC.DETAILS.SIM<AA.PaymentSchedule.AccountDetails.AdSetStatus,LOOP.CNT,CNT.BILL>
            RET.AGE.ST<1,NO.DT-LOOP.CNT+1,NO.BILLS-CNT.BILL+1> = R.AC.DETAILS.SIM<AA.PaymentSchedule.AccountDetails.AdAgingStatus,LOOP.CNT,CNT.BILL>
            RET.AGE.DT<1,NO.DT-LOOP.CNT+1,NO.BILLS-CNT.BILL+1> = R.AC.DETAILS.SIM<AA.PaymentSchedule.AccountDetails.AdNxtAgeDate,LOOP.CNT,CNT.BILL>
            RET.CHS.DT<1,NO.DT-LOOP.CNT+1,NO.BILLS-CNT.BILL+1> = R.AC.DETAILS.SIM<AA.PaymentSchedule.AccountDetails.AdChaserDate,LOOP.CNT,CNT.BILL>
        NEXT CNT.BILL
        RET.DT<1,NO.DT-LOOP.CNT+1> = PAY.DT
    NEXT LOOP.CNT
*
    R.AC.DETAILS.SIM<AA.PaymentSchedule.AccountDetails.AdBillId> = RET.ID
    R.AC.DETAILS.SIM<AA.PaymentSchedule.AccountDetails.AdBillPayDate> = TEMP.RET.DT
*    R.AC.DETAILS.SIM<AA.AD.BILL.PAY.DATE> = RET.DT
    R.AC.DETAILS.SIM<AA.PaymentSchedule.AccountDetails.AdActivityRef> = RET.ACT.REF
    R.AC.DETAILS.SIM<AA.PaymentSchedule.AccountDetails.AdBillDate> = RET.BILL.DT
    R.AC.DETAILS.SIM<AA.PaymentSchedule.AccountDetails.AdBillType> = RET.BILL.TYP
    R.AC.DETAILS.SIM<AA.PaymentSchedule.AccountDetails.AdPayMethod> = RET.PAY.MET
    R.AC.DETAILS.SIM<AA.PaymentSchedule.AccountDetails.AdBillStatus> = RET.BILL.ST
    R.AC.DETAILS.SIM<AA.PaymentSchedule.AccountDetails.AdSetStatus> = RET.SET.ST
    R.AC.DETAILS.SIM<AA.PaymentSchedule.AccountDetails.AdAgingStatus> = RET.AGE.ST
    R.AC.DETAILS.SIM<AA.PaymentSchedule.AccountDetails.AdNxtAgeDate> = RET.AGE.DT
    R.AC.DETAILS.SIM<AA.PaymentSchedule.AccountDetails.AdChaserDate> = RET.CHS.DT

    FOR CNT.LOOP = AA.PaymentSchedule.AccountDetails.AdBillPayDate TO AA.PaymentSchedule.AccountDetails.AdChaserDate
        CONVERT @SM TO @VM IN R.AC.DETAILS.SIM<CNT.LOOP>
    NEXT CNT.LOOP

    EB.Reports.setRRecord(R.AC.DETAILS.SIM)
    EB.Reports.setVmCount(DCOUNT(R.AC.DETAILS.SIM<AA.PaymentSchedule.AccountDetails.AdBillPayDate>,@VM))
    EB.Reports.setSmCount(0);* All  SM values are converted to VM. so the SM count is reset as "0".

    RETURN
******************************************
CHECK.SIM:

    SIM.FLG = ''

    IF SIM.REF THEN
        R.BILLS = ''
        EB.DatInterface.SimRead(SIM.REF,FN.AA.BILL.DETAILS,BILL.ID, R.BILLS, "", SIM.FLG, RET.ERR)
        IF SIM.FLG THEN
            BILL.ID = BILL.ID:'%':SIM.REF
        END
    END
*
    RETURN
******************************************
    END
