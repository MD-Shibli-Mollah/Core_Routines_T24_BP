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

* Version 5 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-3</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoReports
    SUBROUTINE E.SC.HOLD.BAL.FMT
*
************************************************************
*
*     SUBROUTINE TO CALCULATE AVERAGE COST PRICE
*
*
* 22/6/15 - 1322379 Task:1336841
*           Incorporation of components
************************************************************
*
    $USING EB.Reports
    
*
******************************************************************
*
    VAL = EB.Reports.getOData()
    IF EB.Reports.getRRecord()<8> # '' THEN
        VAL = FMT(VAL,'16R,')
    END ELSE
        VAL = ''
    END
*
    EB.Reports.setOData(VAL)
*
    RETURN
    END
