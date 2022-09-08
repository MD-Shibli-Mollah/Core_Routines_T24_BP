* @ValidationCode : MjotMjA0MTk5Njg1NDpDcDEyNTI6MTU1Njc4ODE4NTI1NjpyZGVlcGlnYToyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTA0LjIwMTkwMzEwLTA0MTI6OTo5
* @ValidationInfo : Timestamp         : 02 May 2019 14:39:45
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 9/9 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201904.20190310-0412
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.ScoReports
SUBROUTINE E.SC.VAL.FORMAT
*-----------------------------------------------------------------------------
* This routine will be invoked as part of SC.VAL.COST enquiry, if ODATA is 0,
* then it will be displayed as BLANK, else the original value will be formatted. 
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 10/04/19 - SI: 2908608/ Enhancement:3021699 /Task:3110428
*             Maintain Portfolio Value - To format the PENDING.NOMINAL 
*             in SC.POS.ASSET
*-----------------------------------------------------------------------------
    $USING EB.Reports
    
    tmp.O.DATA = EB.Reports.getOData()
    IF NOT(tmp.O.DATA) THEN
        EB.Reports.setOData('')
    END ELSE
        tmp.O.DATA = EB.Reports.getOData()
        FORMAT.NOM = FMT(tmp.O.DATA,'25R,')
        EB.Reports.setOData(FORMAT.NOM)
    END
    
RETURN

END
