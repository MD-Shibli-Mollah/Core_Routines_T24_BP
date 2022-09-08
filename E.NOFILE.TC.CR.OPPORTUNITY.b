* @ValidationCode : MjotMTU3OTEwNTAzOkNwMTI1MjoxNTUyMDM5MDExNDgwOnNtdWdlc2g6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwMi4wOjg4Ojg0
* @ValidationInfo : Timestamp         : 08 Mar 2019 15:26:51
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smugesh
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 84/88 (95.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201902.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-89</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CR.Channels
SUBROUTINE E.NOFILE.TC.CR.OPPORTUNITY(RETURN.ARRAY)
*-----------------------------------------------------------------------------
* Description
*--------------------
*  This routine is used to display the List of opportunity available for customer and the related details.
*-------------------

* Routine type       : Nofile
* Attached To        : STANDARD.SELECTION>NOFILE.TC.CR.OPPORTUNITY
* IN Parameters      : NA
* Out Parameters     : RETURN.ARRAY
*                     OPPORTUNITY.ID,OPPR.PRODUCT,OPPR.DIRECTION,OPPR.CAMPAIGN.ID
*                     OPPR.GEN.ID,OPPR.DEF.ID,OPPR.STATUS,OPPR.PROB.SUCCESS,IMAGE.ID,AD.IMAGE.TYPE
*                     AD.MEDIA.TYPE,IMAGE.AD.ID,AD.IMAGE.DETAIL.TYPE,AD.DETAIL.MEDIA.TYPE
*
*-----------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 26/05/16 - Enhancement - 1694533 / Task - 1748326
*            TCIB16 Product Development
*
*-----------------------------------------------------------------------------------------------------------------
    $INSERT I_DAS.CR.OPPORTUNITY
    $INSERT I_DAS.IM.DOCUMENT.IMAGE

    $USING EB.SystemTables
    $USING CR.Operational
    $USING IM.Foundation
    $USING ST.CompanyCreation
    $USING EB.DataAccess
    $USING EB.Reports

*
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB CHECK.IM.INSTALLED
    GOSUB PROCESS
*
RETURN
*---------------------------------------------------------------------------------------
INIT:
*---
* Initialise Required Variables

    CUSTOMER.ID ='' ;* To get customer Id
    R.CR.OPPORTUNITY =''
    R.LANG = ''
    ERR.CR.OPPOR =''
    ERR.DOC.IMG =''
    OPPR.CURR.NO = ''
*
RETURN
*----------------------------------------------------------------------------------------
OPENFILES:
*--------
* Open Required Files

*
RETURN
*-----------------------------------------------------------------------------------------
CHECK.IM.INSTALLED:
*-----------------
* Check for IM component

    IM.INSTALLED = ''
    IF EB.SystemTables.getApplication() NE "BATCH" AND EB.SystemTables.getApplication() NE "TSA.SERVICE" THEN   ;*Don't do while installing the product.
        LOCATE 'IM' IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING IM.INSTALLED ELSE
            IM.INSTALLED = ''
        END
        IF IM.INSTALLED THEN  ;* To get Image Document File Name if IM installed
            F.IM.DOCUMENT.IMAGE =''
            R.DOC.IMG =''
        END
    END

RETURN
*----------------------------------------------------------------------------------------
PROCESS:
*------
* To get Customer Opportunity Related details and Document Image Details

    LOCATE 'CUSTOMER' IN EB.Reports.getDFields()<1> SETTING CUS.POS THEN
        CUSTOMER.ID = EB.Reports.getDRangeAndValue()<CUS.POS>  ;* To get Customer number
    END
    LOCATE 'LANGUAGE' IN EB.Reports.getDFields()<1> SETTING LANG.POS THEN
        LANG.ID = EB.Reports.getDRangeAndValue()<LANG.POS>     ;* To get Language
    END

    R.LANG = EB.SystemTables.Language.Read(LANG.ID, READ.ERR)       ;*Read language file to get mnemonic of it.
    LANG.MNEMONIC = R.LANG<EB.SystemTables.Language.LanMnemonic>

    THE.LIST = dasRealTimeOpportunityforCustomer  ;* To get selection for CR Opportunity related to below arguments

    THE.ARGS<1> = '"ASK.ME.LATER" "COMMUNICATED.BUT.NOT.RESPONDED" "NOT.COMMUNICATED.YET" "PENDING"'
    THE.ARGS<2> = CUSTOMER.ID
    THE.ARGS<3> = "INBOUND"
    THE.ARGS<4> = ""

    TABLE.SUFFIX=''
    EB.DataAccess.Das('CR.OPPORTUNITY',THE.LIST,THE.ARGS,TABLE.SUFFIX)         ;* To get Selected customer CR opportunity Id's
    LOOP
        REMOVE OPPR.ID FROM THE.LIST SETTING OPPR.POS
    WHILE OPPR.ID : OPPR.POS  ;* To get CR Opportunity Id from List
        R.CR.OPPORTUNITY = CR.Operational.Opportunity.Read(OPPR.ID, ERR.CR.OPPOR)       ;* To get CR opportunity Record
        OPPORTUNITY.ID = OPPR.ID        ;* To get CR Opportunity Id
        OPPR.PRODUCT = R.CR.OPPORTUNITY<CR.Operational.Opportunity.OpProduct>      ;* To get CR Opportunity Product
        OPPR.DIRECTION = R.CR.OPPORTUNITY<CR.Operational.Opportunity.OpDirection>  ;* To get CR Opportunity Direction
        OPPR.CAMPAIGN.ID = R.CR.OPPORTUNITY<CR.Operational.Opportunity.OpCampaignId>        ;* To get CR Opportunity Campaign Id
        OPPR.GEN.ID = R.CR.OPPORTUNITY<CR.Operational.Opportunity.OpOpGenrId>    ;* To get Cr Opportunity Generator Id
        OPPR.DEF.ID = R.CR.OPPORTUNITY<CR.Operational.Opportunity.OpOpporDefId>  ;* To get CR Opportunity Definition Id
        OPPR.STATUS = R.CR.OPPORTUNITY<CR.Operational.Opportunity.OpOpporStatus>  ;* To get CR Opportunity Status
        OPPR.PROB.SUCCESS = R.CR.OPPORTUNITY<CR.Operational.Opportunity.OpProbSuccess>
        OPPR.CURR.NO = R.CR.OPPORTUNITY<CR.Operational.Opportunity.OpCurrNo> ; *To get the curr number

        IF IM.INSTALLED THEN
            GOSUB GET.IMAGE.DETAILS
        END
* To form return array with opportunity and Image Document
        RETURN.ARRAY<-1> = OPPORTUNITY.ID:'*':OPPR.PRODUCT:'*':OPPR.DIRECTION:'*':OPPR.CAMPAIGN.ID:'*':OPPR.GEN.ID:'*':OPPR.DEF.ID:'*':OPPR.STATUS:'*':OPPR.PROB.SUCCESS:'*':IMAGE.ID:'*':AD.IMAGE.TYPE:'*':AD.MEDIA.TYPE:'*':IMAGE.AD.ID:'*':AD.IMAGE.DETAIL.TYPE:'*':AD.DETAIL.MEDIA.TYPE:'*':OPPR.CURR.NO
    REPEAT
*
RETURN
*---------------------------------------------------------------------------------------------------------------------------------
GET.IMAGE.DETAILS:
*----------------
* Get language specific images

    IMAGE.ID = ""
    AD.IMAGE.TYPE = ""
    AD.MEDIA.TYPE = ""
    IMAGE.AD.ID = ""
    AD.IMAGE.DETAIL.TYPE = ""
    AD.DETAIL.MEDIA.TYPE = ""
    SHORT.DESC = LANG.MNEMONIC:"_":"..."

    THE.IMG.LIST= dasDocumentImageRef   ;* To get the selection criteria for Image Document
    THE.IMG.ARGS=OPPR.DEF.ID:@FM:SHORT.DESC:@FM:'ADVERT':@VM:'ADVERTDETAIL'
    TABLE.IMG.SUFFIX=''
    EB.DataAccess.Das('IM.DOCUMENT.IMAGE',THE.IMG.LIST,THE.IMG.ARGS,TABLE.IMG.SUFFIX)    ;* To get Image Document Id for the CR Opportunity Product

    LOOP
        REMOVE IMG.ID FROM THE.IMG.LIST SETTING IMG.POS
    WHILE IMG.ID : IMG.POS
        R.DOC.IMG = IM.Foundation.DocumentImage.Read(IMG.ID, ERR.DOC.IMG)          ;* To get IM.DOCUMENT.IMAGE record
        IMAGE.TYPE = R.DOC.IMG<IM.Foundation.DocumentImage.DocImageType> ;* To get Image Type
        IF IMAGE.TYPE EQ "ADVERT" THEN
            IMAGE.ID = IMG.ID
            AD.IMAGE.TYPE = IMAGE.TYPE
            AD.MEDIA.TYPE = R.DOC.IMG<IM.Foundation.DocumentImage.DocMultiMediaType>        ;* To get Multi Media Type
        END
        IF IMAGE.TYPE EQ "ADVERTDETAIL" THEN
            IMAGE.AD.ID = IMG.ID
            AD.IMAGE.DETAIL.TYPE = IMAGE.TYPE
            AD.DETAIL.MEDIA.TYPE = R.DOC.IMG<IM.Foundation.DocumentImage.DocMultiMediaType> ;* To get Multi Media Type
        END
    REPEAT

RETURN
END
