* @ValidationCode : MjotMjEwNDM0OTU1OkNwMTI1MjoxNTYwNzU1MDcxNTY2OmdvdmluZGFwYW5kZXk6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwNy4yMDE5MDUzMS0wMzE0OjIyOjIw
* @ValidationInfo : Timestamp         : 17 Jun 2019 12:34:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : govindapandey
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 20/22 (90.9%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190531-0314
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE EB.ModelBank

SUBROUTINE E.DO.QUERY.UXP(customResponsDataOut)
    
    $USING EB.Reports
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
* 04/02/2019    Enhancement 2687491 / Task 2963069  : UXPB Migration to IRIS R18 - NOFILE enquiry
*-----------------------------------------------------------------------------
    
    GOSUB init
    
    BEGIN CASE
        CASE action EQ 'RESOLVE'
            EB.ModelBank.EGetSwitchResourceUxp(requestData, customResponsDataOut)
        CASE action EQ 'GET.MNU'
            EB.ModelBank.EGetMenuUxp(requestData, customResponsDataOut)
        CASE action EQ 'GET.COS'
            EB.ModelBank.EGetCosUxp(requestData, customResponsDataOut)
        CASE 1
            RETURN
    END CASE
RETURN
    
*** <region name= init>
init:
*** <desc> </desc>

    requestData = ''
    action = ''
    
    LOCATE 'REQUEST.DATA' IN EB.Reports.getDFields()<1> SETTING appPos THEN
        requestData = EB.Reports.getDRangeAndValue()<appPos>
    END
    
    LOCATE 'ACTION' IN EB.Reports.getDFields()<2> SETTING appPos THEN
        action = EB.Reports.getDRangeAndValue()<appPos>
    END
    
    customResponsDataOut = ''
RETURN

*** </region>

END
