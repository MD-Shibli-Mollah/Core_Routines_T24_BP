* @ValidationCode : MjoxNjIzMDY2NDg6Q3AxMjUyOjE1NDIwMDc5NzUzMjY6cnZhaXNoYWxpOjE6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxODEwLjIwMTgwOTA2LTAyMzI6MjU6MjU=
* @ValidationInfo : Timestamp         : 12 Nov 2018 13:02:55
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rvaishali
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 25/25 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201810.20180906-0232
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.ORGANIZATION.CODE(ReturnArray)
*-----------------------------------------------------------------------------
*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
*
*** This routine returns the list of Organization Code for a given Organization Level
*
*** </region>
*-----------------------------------------------------------------------------
* @uses         : EB.DataAccess.Readlist
* @access       : private
* @stereotype   : subroutine
* @author       : rvaishali@temenos.com
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
*** Arguments
*
* @ReturnArray - returns OrganizationCode under its Organization level   [Output]
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History :
*
* 2/11/18 -  Enhancement : 2743166
*            Task : 2839875
*            Routine to return OrganizationCode under its Organization level
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>Common variables and file inserts</desc>
* Inserts
*-----------------------------------------------------------------------------

    $USING AA.ModelBank
    $USING EB.Reports
    $USING EB.DataAccess
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Process Logic>
*** <desc>Program Control</desc>

    GOSUB Initialise                ;* To initialise the required variables
    GOSUB GetData                   ;* To get the required data
    IF OrganizationLevel THEN
        GOSUB Process               ;* Main proces to get Organization Code
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>To initialise the required variables </desc>
Initialise:
    
    OrganizationLevel = ""
    OrgCodeList       = ""
    ReturnArray       = ""
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
** <region name= GetData>
*** <desc>To get the required data </desc>
GetData:
    
    LOCATE 'ORGANIZATION.LEVEL' IN EB.Reports.getEnqSelection()<2,1> SETTING LevelPos THEN
        OrganizationLevel = EB.Reports.getEnqSelection()<4,LevelPos>          ;* Pick the Organization level specified in selection
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main Process>
*** <desc>Main proces to get Organization Code </desc>
Process:
    
    SelectCommand = "SELECT F.ST.ORGANIZATION.CODE"
    EB.DataAccess.Readlist(SelectCommand, OrgCodeList, "", "", "")
    OrgCodeListCnt = DCOUNT(OrgCodeList,@FM)
    
    FOR ListCnt = 1 TO OrgCodeListCnt
        Level = FIELD(OrgCodeList<ListCnt>,'*',1)
        
        IF OrganizationLevel EQ Level THEN
            Code  = FIELD(OrgCodeList<ListCnt>,'*',2)
            ReturnArray<-1> = Code
        END
         
    NEXT ListCnt
    
RETURN
*** </region>
*--------------------------------------------------
END
