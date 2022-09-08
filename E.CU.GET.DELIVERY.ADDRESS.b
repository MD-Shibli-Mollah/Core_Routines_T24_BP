* @ValidationCode : MjotNzE1MjY2NTg4OkNwMTI1MjoxNTgyMDk4NTExMDY5OnN0YW51c2hyZWU6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMy4yMDIwMDIxMi0wNjQ2OjkyOjcy
* @ValidationInfo : Timestamp         : 19 Feb 2020 13:18:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : stanushree
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 72/92 (78.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.20200212-0646
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-71</Rating>
*-----------------------------------------------------------------------------
$PACKAGE ST.ModelBank

SUBROUTINE E.CU.GET.DELIVERY.ADDRESS(ID.LIST)
*
******************************************************************************
*
*   Incoming
*
*   Outgoing
*   ID.LIST - Contains records to be displayed in the following format
*             CUSTOMER.ID*ADDRESS*CARRIER.
*             The ADDRESS component will be Street address if CARRIER is PRINT,
*             Phone number if carrier is SMS, Email address if it is EMAIL and
*             so on.,
*
******************************************************************************
*
*   Modification History
*
* 09/08/10 - Enhancement 43265, Task 43268
*              Customer Services
*
* 23/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 02/05/17 - Enhancement 1765879 / Task 2106068
*            Routine is not processed if DE product is not installed in the current company
*
* 05/08/19 - Enhancement 3257457 / Task 3257461
*            Direct access to DE.ADDRESS,DE.PRODUCT, ROUTING removed
*
* 17/09/19 - Enhancement 3357571 / Task 3357573
*            Changes done for Movement of contact preferences to a separate Master Data Module from Delivery
*
******************************************************************************
*
    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.DataAccess
    $USING ST.Customer
    $USING DE.Config
    $USING EB.API
    $USING DE.API
    $USING ST.CustomerService
    $USING ST.CompanyCreation
    $USING PY.Config
    $USING PF.Config
  
*
    GOSUB INITIALISE
*
    IF NOT(EB.Reports.getEnqError()) THEN
        GOSUB PROCESS
    END
*
RETURN
*
**** <region name= INITIALISE>
*** <desc>Initialise the necassary variables </desc>
*
***********
INITIALISE:
***********
*
    deInstalled = ''
    EB.API.ProductIsInCompany('DE', deInstalled)

    IF NOT(deInstalled) THEN
        EB.Reports.setEnqError('EB-PRODUCT.NOT.INSTALLED')
        RETURN
    END

    ER = ''
    CARRIER = ''
    R.ADDRESS = ''
    R.DE.MESSAGE = ''
    CUS.ID = ''
    DE.MSG.ID= ''

    LOCATE 'CUSTOMER' IN EB.Reports.getDFields() SETTING CUS.POS THEN
        CUS.ID = EB.Reports.getDRangeAndValue()<CUS.POS>       ;* get the customer id
    END

    LOCATE 'MESSAGE.ID' IN EB.Reports.getDFields() SETTING MSG.POS THEN
        DE.MSG.ID = EB.Reports.getDRangeAndValue()<MSG.POS>    ;* get the message id
    END

*
    IF NOT(CUS.ID) THEN
        EB.Reports.setEnqError('CUSTOMER ID NOT SUPPLIED')
        RETURN
    END
*
    IF NOT(DE.MSG.ID) THEN
        EB.Reports.setEnqError('MESSAGE ID NOT SUPPLIED')
        RETURN
    END
*
*
    YR.CUST = ST.Customer.tableCustomer(CUS.ID,ER)
    IF ER THEN
        EB.Reports.setEnqError('CUSTOMER RECORD NOT FOUND')
        RETURN
    END
*
    EB.DataAccess.CacheRead('F.DE.MESSAGE',DE.MSG.ID,R.DE.MESSAGE,ER)
    IF ER THEN
        EB.Reports.setEnqError('DE.MESSAGE RECORD NOT FOUND')
        RETURN
    END
*
RETURN
*
*** </region>
*
*** <region name= PROCESS>
*** <desc>Main Process </desc>
*
********
PROCESS:
********
 
;* Setting up the Parameter of API DetermineCarrier
    companyId = EB.SystemTables.getIdCompany() ;* customer id
    cusCompany = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCustomerCompany) ;*customer Company Id
    customer = CUS.ID ;* Keeping null, To fetch account specific record.
    account = '';* Account Id
    msgType = DE.MSG.ID ;* message type
    applic =  '' ;* Application name
    prodKey = '' ;* Outparam
    DE.API.DetermineCarrier(companyId,cusCompany,customer,account,msgType,applic,prodKey,R.DE.PRODUCT,ER) ;* API call to get the DE.PROCUCT record
    
    IF ER THEN
        EB.Reports.setEnqError('PRODUCT RECORD ':PROD.KEY:' NOT FOUND')
        RETURN
    END
*
    CARRIER.IDS = R.DE.PRODUCT<PF.Config.Product.PrdCarrAddNo>
    NO.OF.CAR = DCOUNT(CARRIER.IDS,@VM)

    FOR CAR.CNT = 1 TO NO.OF.CAR
        CARRIER.ADDR.NO = R.DE.PRODUCT<PF.Config.Product.PrdCarrAddNo,CAR.CNT>
        CARRIER = FIELD(CARRIER.ADDR.NO,'.',1)
        ADDR.NO = FIELD(CARRIER.ADDR.NO,'.',2)
        GOSUB GET.CARRIER
        GOSUB GET.DE.ADDRESS
    NEXT
*
RETURN
*
*** </region>
*
**** <region name= GET.DE.ADDRESS>
*** <desc>Get the corressponding address </desc>
*
***************
GET.DE.ADDRESS:
***************
*
    FLD.CNT =''
    ADDRESS =''
    R.ADDRESS = ''
    ADDRESS.ID = EB.SystemTables.getIdCompany() : '.C-' : CUS.ID : '.' : CARRIER.ADDR.NO
    R.ADDRESS = PY.Config.tableAddress(ADDRESS.ID, ER)
    
    BEGIN CASE
        CASE CARRIER  EQ 'PRINT'
            FOR I = PY.Config.Address.AddBranchnameTitle TO PY.Config.Address.AddCountry
                IF R.ADDRESS<I> THEN
                    FLD.CNT +=1
                    ADDRESS<1,FLD.CNT> = R.ADDRESS<I>
                END
            NEXT I

        CASE CARRIER EQ 'SWIFT' OR CARRIER EQ 'TELEX'
            ADDRESS = R.ADDRESS<PY.Config.Address.AddDeliveryAddress>

        CASE CARRIER EQ 'EMAIL'
            ADDRESS = R.ADDRESS<PY.Config.Address.AddEmail1>

        CASE CARRIER EQ 'SMS'
            ADDRESS = R.ADDRESS<PY.Config.Address.AddSms1>

        CASE 1
            ADDRESS = R.ADDRESS<PY.Config.Address.AddBranchnameTitle>

    END CASE

    ID.LIST<-1> = CUS.ID:'*':CARRIER:'*':ADDRESS
*
RETURN
*
*** </region>
*
*** <region name= GET.CARRIER>
*** <desc>Read Carrier record </desc>
*
***************
GET.CARRIER:
***************
*
    R.CARRIER = ''
    EB.DataAccess.CacheRead('F.DE.CARRIER',CARRIER,R.CARRIER,ER)
    CARRIER.ADDR.NO = R.CARRIER<DE.Config.Carrier.CarrAddress>:'.':ADDR.NO
*
RETURN
*
*** </region>
*-----------------------------------------------------------------------------
END
