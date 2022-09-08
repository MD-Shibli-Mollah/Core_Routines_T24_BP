* @ValidationCode : Mjo1Njk2NjIxNjA6Q3AxMjUyOjE1OTM0MDg1MzM4NjI6cnZhcmFkaGFyYWphbjoxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA2LjIwMjAwNTI3LTA0MzU6NTo1
* @ValidationInfo : Timestamp         : 29 Jun 2020 10:58:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rvaradharajan
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 5/5 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE ST.ModelBank
SUBROUTINE E.GET.FIRST.MULTI.VALUE
*-----------------------------------------------------------------------------
* <desc>
* Program Description
* -------------------
* It will return the first multi value position from the output
* </desc>
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 29/06/2020 - Enhancement 3810259 / Task 3810269
*              Conversion routine to get the first multi value position from the ODATA
*-----------------------------------------------------------------------------
    
    $USING EB.Reports
    
    OdataFullVal = ''
    OdataVal = ''
    
    OdataFullVal = EB.Reports.getOData()
    OdataVal = OdataFullVal<1,1>
    EB.Reports.setOData(OdataVal)       ;* returns the first multi value position
    
END
