* @ValidationCode : Mjo5OTk5NjQxODk6Y3AxMjUyOjE2MDExODc4MDE0NzQ6c2Fpa3VtYXIubWFra2VuYTozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA4LjIwMjAwNzMxLTExNTE6ODE6Nzg=
* @ValidationInfo : Timestamp         : 27 Sep 2020 11:53:21
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : saikumar.makkena
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 78/81 (96.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AB.ModelBank
SUBROUTINE E.AA.DETAILS.BUNDLE.ACCRUE(ENQ.ARRAY)
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Program Description </desc>
**
*
* Nofile routine used to return bundle arrangement participant account balances
*
* @uses I_ENQUIRY.COMMON
* @class
* @package retaillending.AA
* @stereotype subroutine
* @author sivakumark@temenos.com
*
**
*** </region>
*------------------------------------------------------------------------
*** <region name= MODIFICATION HISTORY>
*
* 05/09/2014 - Task : 1077380
*              Enhancement 1052773
*              New Routine
*
*
* 13/06/17 - Enhancement : 2148615
*            Task : 2231452
*            Value markers in BunArrangements in PRODUCT.BUNDLE is changed to SM
*
* 14/09/17 - Enhancement : 2267387
*            Task : 2272632
*            To return Available balance at first in ENQ.ARRAY.
*
* 06/09/19 - Defect : 3320836/ Task :3322960
*            Linked arrangement all Interest property's accrual details of the linked
*            arrangements are displayed in the bundle overview screen.
*
* 14/09/20 - Enhancement 3934727 / Task 3940554
*            Reference of EB.CONTRACT.BALANCES is changed from RE to BF
*** <desc>Changes done in the sub-routine<</desc>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING AA.ProductBundle
    $USING AA.Framework
    $USING AA.ProductFramework
    $USING AR.ModelBank
    $USING EB.SystemTables
    $USING EB.Reports
    $USING BF.ConBalanceUpdates
    $USING RE.ConBalanceUpdates
    $USING AA.InterestCompensation


*** </region>
*----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>

    GOSUB PROCESS

RETURN
*** </region>
*------------------------------------------------------------------------------------------------------------

*** <region name= Main Process>
*** <desc>Main Process</desc>
PROCESS:


    LOCATE 'ARRANGEMENT.ID' IN EB.Reports.getEnqSelection()<2,1> SETTING ARRPOS THEN
        ARR.ID = EB.Reports.getEnqSelection()<4,ARRPOS>          ;* Pick the Arrangement Id
    END


    CHECK.DATE = EB.SystemTables.getToday()

    ARR.INFO = ARR.ID:@FM:'':@FM:'':@FM:'':@FM:'':@FM:''
    AA.Framework.GetArrangementProperties(ARR.INFO, CHECK.DATE, R.ARRANGEMENT, PROP.LIST)

    CLASS.LIST = ''
    AA.ProductFramework.GetPropertyClass(PROP.LIST, CLASS.LIST)       ;* Find their Property classes

* Get the Product bundle property ID,
    PB.PROPERTY = ""
    LOCATE 'PRODUCT.BUNDLE' IN CLASS.LIST<1,1> SETTING PROD.POS THEN
        PB.PROPERTY = PROP.LIST<1,PROD.POS>
    END

* Get the Interest compensation property ID ,
    IC.PROPERTY = ""
    LOCATE 'INTEREST.COMPENSATION' IN CLASS.LIST<1,1> SETTING PROD.POS THEN
        IC.PROPERTY = PROP.LIST<1,PROD.POS>
    END

*  Get the Product bundle property record ,

    AA.ProductFramework.GetPropertyRecord('', ARR.ID, PB.PROPERTY, CHECK.DATE, 'PRODUCT.BUNDLE', '', R.PRODUCT.BUNDLE , REC.ERR)

    ARRANGEMENT.IDS = R.PRODUCT.BUNDLE<AA.ProductBundle.ProductBundle.BunArrangement>
    MASTER.ARRANGEMENTS = R.PRODUCT.BUNDLE<AA.ProductBundle.ProductBundle.BunMasterArrangement>
    PB.PRODUCT.GROUPS = R.PRODUCT.BUNDLE<AA.ProductBundle.ProductBundle.BunProductGroup>
    PB.PRODUCTS = R.PRODUCT.BUNDLE<AA.ProductBundle.ProductBundle.BunProduct>

* Get the Interest compensation property Record ,

    AA.ProductFramework.GetPropertyRecord('', ARR.ID, IC.PROPERTY, CHECK.DATE, 'INTEREST.COMPENSATION', '', R.INTEREST.COMPENSATION , REC.ERR)

    FOR PRD.CNT = 1 TO DCOUNT(ARRANGEMENT.IDS,@VM);*to fetch the total no of Product Groups
        GOSUB PROCESS.ARRANGEMENT
    NEXT PRD.CNT

RETURN
*** </region>
*------------------------------------------------------------------------------------------------------------

*** <region name=.Process Arrangement>
*** <desc>Process Arrangement</desc>
PROCESS.ARRANGEMENT:

    FOR CNT = 1 TO DCOUNT(ARRANGEMENT.IDS<1,PRD.CNT>,@SM)

        ARRANGE.ID = ARRANGEMENT.IDS<1,PRD.CNT,CNT>
        R.ARRANGEMENT = ''
        ARR.INFO = ARRANGE.ID:@FM:'':@FM:'':@FM:'':@FM:'':@FM:''
        AA.Framework.GetArrangementProperties(ARR.INFO, CHECK.DATE, R.ARRANGEMENT, PROP.LIST)
        ARR.PRODUCT = R.ARRANGEMENT<AA.Framework.Arrangement.ArrProduct>
        ARR.PRODUCT.GROUP = R.ARRANGEMENT<AA.Framework.Arrangement.ArrProductGroup>


        PB.PRODUCT.GROUP = PB.PRODUCT.GROUPS<1,PRD.CNT,1>

        INT.COMP.PROPERTIES = ""

        LOCATE ARRANGE.ID IN MASTER.ARRANGEMENTS SETTING VM.POS THEN
            MASTER.TYPE = "RECIPIENT"
        END ELSE
            MASTER.TYPE = "DONOR"
        END

        IF PB.PRODUCT.GROUP ELSE ;* If product alone defined in product bundle then take product group from AA.PRODUCT file.
            LOCATE ARR.PRODUCT IN PB.PRODUCTS<1,PRD.CNT,1> SETTING PRODUCT.POS THEN
                PB.PRODUCT.GROUP = ARR.PRODUCT.GROUP
            END
        END

* Check Linked arrangement product group  matches with Recipient or donor product group
* if matched then get respective product group properties to compare with linked arrangement properties.

        BEGIN CASE

            CASE MASTER.TYPE EQ "RECIPIENT"
                IF PB.PRODUCT.GROUP EQ R.INTEREST.COMPENSATION<AA.InterestCompensation.InterestCompensation.IcompRecipientProduct> THEN
                    INT.COMP.PROPERTIES = R.INTEREST.COMPENSATION<AA.InterestCompensation.InterestCompensation.IcompRecipientProperty>
                END
            CASE MASTER.TYPE EQ "DONOR"
                LOCATE PB.PRODUCT.GROUP IN R.INTEREST.COMPENSATION<AA.InterestCompensation.InterestCompensation.IcompDonorProduct,1> SETTING DON.PRD.POS THEN
                    INT.COMP.PROPERTIES = R.INTEREST.COMPENSATION<AA.InterestCompensation.InterestCompensation.IcompDonorProperty,DON.PRD.POS>
                    CHANGE @SM TO @VM IN INT.COMP.PROPERTIES
                END
        END CASE


        WORKING.BALANCE = ''  ;*to store available balance

        GOSUB GET.AVAILABLE.BALANCE ; *To get available balance from ECB
        ENQ.ARRAY<-1> = ARRANGE.ID:"*":"AVL":"*":WORKING.BALANCE:"*":MASTER.TYPE  ;* Display available balance first
        CLASS.LIST = ''
        AA.ProductFramework.GetPropertyClass(PROP.LIST, CLASS.LIST)   ;* Find their Property classes

        FOR INT.CNT = 1 TO DCOUNT(CLASS.LIST,@VM)
            PROP.CLASS = CLASS.LIST<1,INT.CNT>
            IF PROP.CLASS EQ "INTEREST" THEN

                INTEREST.PROPERTY = PROP.LIST<1,INT.CNT>
** If the arrangement interest properties exists in the donor or receipient property in interest
** compensation arrangement property record then only we need to get and dispaly the data's in the enquiry.
                LOCATE INTEREST.PROPERTY IN INT.COMP.PROPERTIES<1,1> SETTING INT.POS THEN
                    EB.Reports.setOData(ARRANGE.ID:"-":INTEREST.PROPERTY)
                    AR.ModelBank.EAaAccruedInterest()
                    ENQ.ARRAY<-1> = " ":"*":INTEREST.PROPERTY:"*":EB.Reports.getOData()
                    EB.Reports.setOData('')
                END
            END
        NEXT INT.CNT
    NEXT CNT

RETURN
*** </region>
*------------------------------------------------------------------------------------------------------------
*** <region name= GET.AVAILABLE.BALANCE>
GET.AVAILABLE.BALANCE:
*** <desc>To get available balance from ECB </desc>

    AA.Framework.GetArrangementAccountId(ARRANGE.ID, ACCOUNT.ID, ACC.CCY, RET.ERROR)  ;*to get account id of the arrangement
    R.EB.CONTRACT.BALANCES = BF.ConBalanceUpdates.EbContractBalances.Read(ACCOUNT.ID, RET.ERR)
    WORKING.BALANCE = R.EB.CONTRACT.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbWorkingBalance>

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
