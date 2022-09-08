* @ValidationCode : MjotMTQ0NzczMTk5OTpDcDEyNTI6MTU2NjQwODAyMzM3NTpzbWl0aGFiaGF0OjU6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDguMjAxOTA3MjMtMDI1MTo4Mzo4Mw==
* @ValidationInfo : Timestamp         : 21 Aug 2019 22:50:23
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smithabhat
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 83/83 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.20190723-0251
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-5</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CL.ModelReport
SUBROUTINE E.CL.ACCOUNT.OVERDRAWN.DETAILS(EnqList)
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
* This Enquiry used to display the Account Overdrawn Details for Accounts Arrangement for customer from Collection Item
*** <doc>
*
* @author smithabhat@temenos.com
* @stereotype template
* @uses NOFILE.CL.ACCOUNT.OVERDRAWN.DETAILS
* @package retaillending.CL
*
*** </doc>
*** <region name= Arguments>
*** <desc>Input and output arguments required for the sub-routine</desc>
* Arguments
*
* Input :
*
*
*
*
* Output
*
*  ENQ.LIST - Return the Account's Arrangement Overdrawn Details from Collection Item
*
*** </region>
*** <region name= Modification History>
*** <desc>Changes done in the sub-routine</desc>
* Modification History :
*-----------------------------------------------------------------------------
* 08/07/19 -  Task        - 3221938
*             Enhancement - 2886910
*             NoFile Enquiry Routine to display Account Overdrawn Details from Collection Item
*
* ----------------------------------------------------------------------------
*** <region name= INSERTS>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING AA.Framework
    $USING CL.Contract
    $USING EB.Reports
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING ST.Customer
    $USING AC.AccountOpening
    $USING AA.ProductManagement
  
*** </region>
*** <region name= Main section>
*** <desc>main control logic in the sub-routine</desc>

    GOSUB Initialise
    GOSUB Process

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>File variables and local variables</desc>
Initialise:

    FN.CL.COLLECTOR = "F.CL.COLLECTOR"
    F.CL.COLLECTOR = ""
    EB.DataAccess.Opf(FN.CL.COLLECTOR,F.CL.COLLECTOR)

    EnqList = ""
    CIArray = ""

RETURN
*** </region>
*--------------------------------------------------------------------------
*** <region name= Process>
*** <desc>Main Process</desc>
Process:

    GOSUB CheckUserId ;* Check collector user Id
    
    IF NOT(NoOfRecs) THEN
        EB.Reports.setEnqError('Current User doesnt belongs to Collector')
        RETURN
    END

* Get the Arrangement ID from the Enquiry input.
    LOCATE "ARRANGEMENT.ID" IN EB.Reports.getDFields()<1> SETTING ArrPos THEN
        ContractId= EB.Reports.getDRangeAndValue()<ArrPos>
    END ELSE
        ContractId = ""
    END
    
* Get the Customer ID from the Enquiry input.
    LOCATE "CUSTOMER.ID" IN EB.Reports.getDFields()<1> SETTING CusPos THEN
        CustomerId= EB.Reports.getDRangeAndValue()<CusPos>
    END ELSE
        CustomerId = ""
    END
    
* If Arrangement Id or Customer Id is not given in input Raise Error
    IF NOT(ContractId) OR NOT(CustomerId) THEN
        EB.Reports.setEnqError('Customer and Arrangement Id are mandatory')
    END
    
    IF ContractId AND CustomerId THEN
        RArrangement = ''
        AA.Framework.GetArrangement(ContractId, RArrangement, RetError) ;* Get the Arrangement Record

        IF RArrangement EQ '' THEN ;* Check if Arrangement Id is invalid
            EB.Reports.setEnqError('Invalid Arrangement ID')
            RETURN
        END
    
        IF RArrangement<AA.Framework.Arrangement.ArrProductLine> NE 'ACCOUNTS' THEN ;* Arrangement should belong to Accounts Product Line
            EB.Reports.setEnqError('Invalid Accounts Arrangement ID')
            RETURN
        END
    END

    GOSUB GetCollectionItem

RETURN
*** </region>
*--------------------------------------------------------------------------
*** <region name= GetCollectionItem>
*** <desc>Get the collection item for Contract</desc>
GetCollectionItem:

    RClCollectionItem = "" ;* Initialise Collection Item Record
    CollItemReadErr = "" ;* Initialise Return Error
    RClCollectionItem = CL.Contract.CollectionItem.Read(CustomerId, CollItemReadErr) ;* Get the Collection Item
    
    GOSUB FormArray ;* Form return Array

RETURN
*** </region>
*--------------------------------------------------------------------------
*** <region name= FORM.ARRAY>
*** <desc>Main and Other Actions Performance</desc>
FormArray:

    IF RClCollectionItem THEN
        LOCATE ContractId IN RClCollectionItem<CL.Contract.CollectionItem.CitUlContractRef,1> SETTING ContractPos THEN
            GOSUB GetArrangementDetails ;* Get the Arrangement Details of the contract
            GOSUB GetAccountDetails ;* Get the Account Details of the contract
            CIArray = CustomerId:"*":CustomerName:"*":Product:"*":AccountStartDate:"*":ContractId:"*":RClCollectionItem<CL.Contract.CollectionItem.CitAccountNumber,ContractPos>:"*"
            CIArray := RClCollectionItem<CL.Contract.CollectionItem.CitOdCurrency,ContractPos>:"*":RClCollectionItem<CL.Contract.CollectionItem.CitLcyOdAmount,ContractPos>:"*":
            CIArray := LegacyId:"*":IBANId:"*":RClCollectionItem<CL.Contract.CollectionItem.CitOdStartDate,ContractPos>:"*":RClCollectionItem<CL.Contract.CollectionItem.CitOdStatus,ContractPos>:"*":RClCollectionItem<CL.Contract.CollectionItem.CitOdAmount,ContractPos>
        END
    END
     
    IF CIArray THEN ;* Return EnqList
        EnqList = CIArray
    END
        
RETURN
*** </region>
*--------------------------------------------------------------------------
*** <region name= Get Arrangement Details>
*** <desc>Get the Arrangement Details of the contract</desc>
GetArrangementDetails:

    ProductId = RArrangement<AA.Framework.Arrangement.ArrProduct> ;*  Get the Product Id from Arrangement Record
    ProductRecord = AA.ProductManagement.Product.Read(ProductId, Error) ;* Get the product record
    Product = ProductRecord<AA.ProductManagement.Product.PdtDescription> ;* Get the product description
    
    RCustomer = ST.Customer.Customer.Read(CustomerId, Error) ;* Get the Customer record
    CustomerName = RCustomer<ST.Customer.Customer.EbCusShortName> ;* Get the customer name
    
    AccountStartDate = RArrangement<AA.Framework.Arrangement.ArrStartDate> ;* Get the Account Start Date from Arrangement

RETURN
*** </region>
*--------------------------------------------------------------------------
*** <region name= GetAccountDetails>
*** <desc>Get the Account Details of the contract</desc>
GetAccountDetails:
    
    AccountNumber = RClCollectionItem<CL.Contract.CollectionItem.CitAccountNumber,ContractPos> ;* Get the Account Number for Arrangement id
    AccountRecord = AC.AccountOpening.Account.Read(AccountNumber, RetError) ;* Get the Account record
    
    LegacyId = ''
    IBANId = ''
    LOCATE 'LEGACY' IN AccountRecord<AC.AccountOpening.Account.AltAcctType,1> SETTING LegacyPos THEN
        LegacyId = AccountRecord<AC.AccountOpening.Account.AltAcctId,LegacyPos> ;* Get the Legacy Account id
    END
    
    LOCATE 'T24.IBAN' IN AccountRecord<AC.AccountOpening.Account.AltAcctType,1> SETTING IbanPos THEN
        IBANId = AccountRecord<AC.AccountOpening.Account.AltAcctId,IbanPos> ;* Get the T24 IBAN Account id
    END

RETURN 
*** </region>
*--------------------------------------------------------------------------
*** <region name= CheckUserId>
*** <desc>Check collector user Id</desc>
CheckUserId:

    SelCmd = "SELECT ":FN.CL.COLLECTOR:" WITH COLLECTOR.USER EQ ":'"':EB.SystemTables.getOperator():'"'
    SelList = ""
    SelErr = ""
    NoOfRecs = ""
    EB.DataAccess.Readlist(SelCmd,SelList,"",NoOfRecs,SelErr)
    
RETURN
*** </region>
*--------------------------------------------------------------------------
END
