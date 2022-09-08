* @ValidationCode : MjotNjM1NzAzMjc5OkNwMTI1MjoxNTg5MzU0OTM0OTQ2OmRsYXZhbnlhOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMi4yMDIwMDExNy0yMDI2Oi0xOi0x
* @ValidationInfo : Timestamp         : 13 May 2020 12:58:54
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : dlavanya
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
* Subroutine Type : Subroutine

* Attached as     : Conversion Routine

* Primary Purpose : To return the PROPERTIES given Bill Details PAY.PROPERTY

* Change History  :

* Version         : First Version

* Author          : ssudhakar@temenos.com 

*-----------------------------------------------------------
*MODIFICATION HISTORY
*
* 31/05/16 - Task :1749172
*            Defect : 1749068 
*            In Arrangement Overview Screen, Type not displayed in the Overview of Bills for charges where Tax is collected.
*
* 19/03/2020 - Enhancement  :  3634982
*              Task :  3634985
*              Changes are to differentiate TAX property from SKIM property.
*-----------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.BILL.PAY.PROPERTY
*-----------------------------------------------------------

    $USING EB.Reports
*-----------------------------------------------------------

    GOSUB PROCESS

RETURN
*-----------------------------------------------------------
PROCESS:
********

    PROP.WITH.TAX = EB.Reports.getOData()

    IF FIELD(PROP.WITH.TAX,"-",2) AND FIELD(PROP.WITH.TAX,"-",2) NE 'SKIM' THEN ;* Check if its not a SKIM property
        PAY.PROPERTY = FIELD(PROP.WITH.TAX,"-",1)
    END ELSE
        PAY.PROPERTY = PROP.WITH.TAX
    END

    EB.Reports.setOData(PAY.PROPERTY)

RETURN
*-----------------------------------------------------------
END
