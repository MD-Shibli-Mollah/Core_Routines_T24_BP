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
* <Rating>-8</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.FIND.TXN.VER
************************************
* Modification History
*
* 20/11/14 - Task 1171853
*            Defect 1169324
*            Conversion routine attached to the enquiry AA.DETAILS.ACTIVITY.LOG.PENDING.FIN
*            Retuning Corresponding Version to be opened
*
* 19/12/14 - Task 1203655
*            Defect 1203590
*            By default AAA application should be opened
*
* 12/05/16 - Task - 1728351
*            Defect - 1725749
*            AC.CHARGE.REQUEST process has been included in this routine
*
************************************
*
$USING EB.Reports

*
************************************
    TXN.ID = EB.Reports.getOData()
*
************************************

    BEGIN CASE
    CASE TXN.ID[1,3] EQ "TFS"
        EB.Reports.setOData("TELLER.FINANCIAL.SERVICES")
    CASE TXN.ID AND NUM(TXN.ID) EQ 1
        EB.Reports.setOData("PAYMENT.STOP")
    CASE TXN.ID[1,2] EQ "TT"
        EB.Reports.setOData("TELLER")
    CASE TXN.ID[1,2] EQ "PD"
        EB.Reports.setOData("PD.PAYMENT.DUE")
    CASE TXN.ID[1,2] EQ "LD"
        EB.Reports.setOData("LD.LOANS.AND.DEPOSITS")
    CASE TXN.ID[1,2] EQ "MD"
        EB.Reports.setOData("MD.DEAL")
    CASE TXN.ID[1,2] EQ "TF"
        EB.Reports.setOData("LETTER.OF.CREDIT")
    CASE TXN.ID[1,2] EQ "FT"
        EB.Reports.setOData("FUNDS.TRANSFER")
    CASE TXN.ID[1,3] EQ "CHG"
        EB.Reports.setOData("AC.CHARGE.REQUEST")
    CASE 1
        EB.Reports.setOData("AA.ARRANGEMENT.ACTIVITY,AA")
    END CASE
*
************************************
    RETURN
*
************************************
END
