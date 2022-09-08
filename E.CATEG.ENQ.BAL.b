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

* Version 2 25/10/00  GLOBUS Release No. G11.0.00 29/06/00
*-----------------------------------------------------------------------------
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.CATEG.ENQ.BAL
*-----------------------------------------------------------------------------
*
    $USING EB.Reports
*
    YRMTH = EB.Reports.getOData()
    LOCATE YRMTH IN EB.Reports.getYrMthBal()<1,1> BY "AR" SETTING YPOS THEN
    EB.Reports.setOData(EB.Reports.getYrMthBal()<2,YPOS>)
    END ELSE                           ; * For the last balance use RUNNING.BALANCE
    EB.Reports.setOData(EB.Reports.getYrunningBal())
    END
*
    RETURN
*-----------------------------------------------------------------------------
    END
