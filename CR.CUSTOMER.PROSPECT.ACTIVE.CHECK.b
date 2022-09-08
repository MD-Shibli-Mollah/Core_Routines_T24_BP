* @ValidationCode : MjoxMTYwMDg2NjgyOkNwMTI1MjoxNTg5MTk0NTc1MDI3OnJnb3V0aGFtOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MTAuMjAxOTA5MjAtMDcwNzo3MDo2Mw==
* @ValidationInfo : Timestamp         : 11 May 2020 16:26:15
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rgoutham
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 63/70 (90.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-59</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CR.Operational
SUBROUTINE CR.CUSTOMER.PROSPECT.ACTIVE.CHECK(ALLOW.CUSTOMER.ACTIVATE)

*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*
** Check prospect customer update allowed for application.Include application
** name in common variable CR$BLOCKED.APP.LIST to block application to
** update prspect customer to active customer.
** Outgoing variable:
**
** ALLOW.CUSTOMER.ACTIVATE - Setting this variable will activate prospect customer
**
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Change descriptions</desc>
* Modification History :
*
*
* 23/03/19 - Defect:3040602/Task:3051581
*            Local template to be added to BUILD.CR.BLOCKED.APPLICATION.LIST
*
* 02/04/2019 - Defect 2575330 / Task 2602877
*              Block activating customer from prospect when product line is consent and cust.component in CR.CONTACT.LOG.PARAM is CK.CONSENT
*
* 11/05/20 - Defect:3728775/Task:3737934
*            Change read to cache read on CR.OPPORTUNITY.PARAMETER
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>Inserts used in the sub-routine</desc>

    $USING EB.SystemTables
    $USING CR.Operational
    $USING AA.Framework
    $USING AA.ProductFramework
    $USING AA.ProductManagement
    $USING EB.API
    $USING AF.Framework

*** </region>
*-----------------------------------------------------------------------------
* Common variable used to store list od application names which do not
* update customer status
    COM/CRBLOCK/CR$BLOCKED.APP.LIST

    GOSUB INITIALISE
    GOSUB FETCH.BLOCK.FIELD.DETAILS
    IF NOT(CR$BLOCKED.APP.LIST) THEN
        GOSUB BUILD.CR.BLOCKED.APPLICATION.LIST
    END
    GOSUB CHECK.FOR.CONSENT.ARRANGEMENT
    GOSUB CHECK.CUSTOMER.UPDATE.APPLICATION

RETURN

*-----------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc>Define field names and its attributes here</desc>
INITIALISE:

    ALLOW.CUSTOMER.ACTIVATE = ""
    PropClass = ''
    Product = ''
    ProductGroupId = ''
    AAProductGroupRec = ''
    ProductLine = ''
    AAProductLineRec = ''
    ConsentCheck = ""
    ArrangementId = ""
    
RETURN

*
*** </region>
*-----------------------------------------------------------------------------
FETCH.BLOCK.FIELD.DETAILS:
    
* Load CR Opportunity Parameter

    YERR = ''
    CR.PARAM.REC = ''          ;* To hold the values read from CR.OPPORTUNITY.PARAMETER
    
    CR.PARAM.REC = CR.Operational.OpportunityParameter.CacheRead('SYSTEM', YERR)
    
    IF CR.PARAM.REC THEN
        BLOCKED.ITEMS = CR.PARAM.REC<CR.Operational.OpportunityParameter.OpParamBlockCrItems>
        BLOCKED.ITEMS = RAISE(BLOCKED.ITEMS)    ;* Raise to FM
    END
    

RETURN
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= BUILD.CR.BLOCKED.APPLICATION.LIST>
*** <desc>If the application is blocked to update customer status then add
*** here with CR$BLOCKED.APP.LIST</desc>
BUILD.CR.BLOCKED.APPLICATION.LIST:

    CR$BLOCKED.APP.LIST = ""
    CR$BLOCKED.APP.LIST<-1> = "CUSTOMER"          ;* not for customer input
    CR$BLOCKED.APP.LIST<-1> = "PW.PROCESS"        ;* return for pw.process application
    
    IF BLOCKED.ITEMS THEN
        BLOCKED.ITEMS.CNT = DCOUNT(BLOCKED.ITEMS,@FM)
        FOR I = 1 TO BLOCKED.ITEMS.CNT
            CR$BLOCKED.APP.LIST<-1> = BLOCKED.ITEMS<I>
        NEXT I
    END

RETURN
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= BUILD.CR.BLOCKED.APPLICATION.LIST>
*** <desc>Check the application name in CR$BLOCKED.APP.LIST list.
*** If present then block the app to update customer status</desc>
CHECK.CUSTOMER.UPDATE.APPLICATION:

    BEGIN CASE
        CASE EB.SystemTables.getApplication()[1,3] EQ "CR."      ;* just return for CR type applications
        CASE EB.SystemTables.getApplication()[1,6] EQ "AA.SIM"   ;* return for simulation of arrangements
        CASE ConsentCheck EQ 1    ;*return for consent arrangements
        CASE 1
            LOCATE EB.SystemTables.getApplication() IN CR$BLOCKED.APP.LIST<1> SETTING POS ELSE ;* Not blocked
                IF EB.SystemTables.getVFunction() MATCHES "C":@VM:"I"   THEN         ;* copying or inputting
                    ALLOW.CUSTOMER.ACTIVATE = 1
                END
            END
    END CASE
RETURN
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CHECK.FOR.CONSENT.ARRANGEMENT>
*** <desc> </desc>
CHECK.FOR.CONSENT.ARRANGEMENT: ;*do not change customer status to active incase of a consent arrangement
    
    
    productId = 'AA'
    isInstalled = ''
    EB.API.ProductIsInCompany(productId, isInstalled)
    IF NOT(isInstalled) THEN
        RETURN
    END

    AA.Framework.CurrentActivityId(ArrangementId)
    application = EB.SystemTables.getApplication()
    IF NOT(ArrangementId) AND application EQ 'AA.ARRANGEMENT.ACTIVITY' THEN     ;* as ArrangementId will not be set for parent AA
        ArrangementId = AF.Framework.getC_arractivityid()
    END

    IF NOT(ArrangementId) THEN ;*neither parent, nor child AA
        RETURN
    END
    AAProductRec = AF.Framework.getProductRecord()
    ProductGroupId = AAProductRec<AA.ProductManagement.ProductCatalog.PrdProductGroup>
    AAProductGroupRec = AA.ProductFramework.ProductGroup.CacheRead(ProductGroupId, Err)
    ProductLine = AAProductGroupRec<AA.ProductFramework.ProductGroup.PgProductLine>     ;*get product line from product group
    IF ProductLine EQ "CONSENT" THEN
        ConsentCheck = 1 ;*set consent check flag to 1 in case of consent arrangements
    END

RETURN
*** </region>

END
