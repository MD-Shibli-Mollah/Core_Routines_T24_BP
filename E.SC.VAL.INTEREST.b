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

* Version 6 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-3</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoReports
    SUBROUTINE E.SC.VAL.INTEREST
*
************************************************************
*
*    SUBROUTINE TO CALCULATE INTEREST VALUE
*
*
* 23-07-2015 - 1415959
*             Incorporation of components
************************************************************
*

    $USING EB.Reports

*
*
    tmp.O.DATA = EB.Reports.getOData()
    IF NOT(tmp.O.DATA) THEN
        EB.Reports.setOData(tmp.O.DATA)
        EB.Reports.setOData('')
    END ELSE
        tmp.O.DATA = EB.Reports.getOData()
        EB.Reports.setOData(FMT(tmp.O.DATA,'15R'))
        EB.Reports.setOData(tmp.O.DATA)
    END
*
    RETURN
    END
