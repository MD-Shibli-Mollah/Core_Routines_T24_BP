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

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE IC.ModelBank
    SUBROUTINE E.INFO.ACCT.PREM.NEXT.LEVEL
*
* This subroutine will decide the next level enquiry
* for INFO.ACCT.PREMIUM
*

    $USING IC.ModelBank
    $USING EB.Reports
*
    NEXT.APP = ""
    NEXT.SEL1 = ""
    NEXT.SEL2 = ""
*
    CAP.DATE = ""
    ACCOUNT.NO = EB.Reports.getOData()
    LOCATE "CAP.DATE" IN EB.Reports.getEnqSelection()<2,1> SETTING CAP.POS THEN
    CAP.DATE = EB.Reports.getEnqSelection()<4,CAP.POS>
    END
    NEXT.APP = "PREMIUM.DETAILS"
    NEXT.SEL1 = "ACCOUNT.NO EQ ":ACCOUNT.NO
    IF CAP.DATE # "" THEN
        NEXT.SEL2 = "CAP.DATE EQ ":CAP.DATE
    END

    EB.Reports.setOData(NEXT.APP:">":NEXT.SEL1:">":NEXT.SEL2)

*
    RETURN
    END
