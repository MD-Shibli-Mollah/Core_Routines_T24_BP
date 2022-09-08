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
* <Rating>-5</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.FIND.AC.SWEEP.ID
************************************
* Modification History
*
* 20/11/14 - Task 1174298
*            Defect 1171660
*            Conversion routine attached to the enquiry AA.DETAILS.ACTIVITY.LOG.FIN
*            Retuning Corresponding AC.ACCOUNT.LINK @ID
*
************************************

    $USING EB.Delivery
    $USING RS.Sweeping
    $USING EB.Reports

*
************************************

    AC.LINK.ERR = ''
    ACSW.VALID = '' ; ACSW.INSTALLED = '' ; COMP.ACSW = '' ; ERR.MSG = ''
    EB.Delivery.ValProduct('RS',ACSW.VALID,ACSW.INSTALLED,COMP.ACSW,ERR.MSG)

    IF ACSW.VALID AND ACSW.INSTALLED AND COMP.ACSW THEN
        F.AC.ACCOUNT.LINK.CONCAT = ""

        tmp.O.DATA = EB.Reports.getOData()
        AC.LINK.ID = FIELD(tmp.O.DATA,'-',1)
        EB.Reports.setOData(tmp.O.DATA)

        R.AC.LINK = RS.Sweeping.AcAccountLinkConcat.Read(AC.LINK.ID, AC.LINK.ERR)
        IF R.AC.LINK THEN
            EB.Reports.setOData(R.AC.LINK<1>)
        END
    END
    RETURN
*
************************************
    END
