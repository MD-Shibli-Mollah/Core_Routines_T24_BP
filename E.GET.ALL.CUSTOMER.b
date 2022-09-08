* @ValidationCode : MjoyMDQ2Mzk1Nzc2OkNwMTI1MjoxNjA4MjE2MzQzMzIxOlZhbmthd2FsYUhlZXI6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMi4yMDIwMTEyOC0wNjMwOjEwMzoxMDM=
* @ValidationInfo : Timestamp         : 17 Dec 2020 20:15:43
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : VankawalaHeer
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 103/103 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201128-0630
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AC.ModelBank
SUBROUTINE E.GET.ALL.CUSTOMER
*-----------------------------------------------------------------------------
* <desc>
* Program Description
* -------------------
* In case of legacy account returns all the primary customers and joints holders of the account
* In case of arrangement account will return all the customers
* </desc>
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 29/06/2020 - Enhancement 3810259 / Task 3810269
*              Conversion routine to get all the secondary customers for an account
*
* 01/07/2020 - Enhancement 3810259 / Task 3831439
*              All the customers are returned with flag set to determine PRIMARY/SECONDARY and also the
*              relation code and customer role is returned
*
* 14/12/2020 - Enahancement 4133912 / Task 4133924
*              Logic added to retrieve customer basic details such as contactDetails , address
*              returned for the each of the customer defined for the selected Account
*-----------------------------------------------------------------------------
    
    $USING EB.Reports
    $USING AC.AccountOpening
    $USING AA.ProductFramework
    $USING EB.SystemTables
    $USING AA.Customer
    $USING ST.Customer

    GOSUB INITIALISE ; *initialise all the variables

    GOSUB PROCESS ; *get the customer details for the arrangement & non-arrangement accounts

RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>initialise all the variables </desc>

    AccNum = ''
    AccRecord = ''
    CustomerId = ''
    ArrangementId = ''
    CustomersList = ''
    RelationCodes = ''
    CustomerRoles = ''
    PrimaryRole = ''
    SecondaryCusCnt = ''
    SecondaryCustomer = ''
    RelationCode = ''
    CustomerRole = ''
    CusDetails = ''
    OutData = ''
    CountArray = ''
    PrimaryCustomerType = ''
    SecondaryCustomerType = ''
    MultiPos = ''
    MaxVmCount = ''
    CustomerRec = ''
    FinalOutData = ''
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>get the customer details for the arrangement & non-arrangement accounts</desc>
    
    AccNum = EB.Reports.getOData()
    AccRecord = AC.AccountOpening.Account.CacheRead(AccNum, Error)
    CustomerId = AccRecord<AC.AccountOpening.Account.Customer>
    ArrangementId = AccRecord<AC.AccountOpening.Account.ArrangementId>
    
    customerRec = ''
    PropertyDate = EB.SystemTables.getToday()
    
    IF NOT(ArrangementId) THEN      ;*if not an arragement account read the joint holder deatils as secondary customer
        CustomersList = AccRecord<AC.AccountOpening.Account.JointHolder>
        RelationCodes = AccRecord<AC.AccountOpening.Account.RelationCode>
    END ELSE
        AA.ProductFramework.GetPropertyRecord('', ArrangementId, '', PropertyDate, "CUSTOMER", '', customerRec, '')
        CustomersList = customerRec<AA.Customer.Customer.CusCustomer>
        CustomerRoles = customerRec<AA.Customer.Customer.CusCustomerRole>
        LOCATE CustomerId IN CustomersList<1,1> SETTING Pos THEN      ;* get all the customer except primary customer
            PrimaryRole = CustomerRoles<1,Pos>
            DEL CustomersList<1,Pos>
            DEL CustomerRoles<1,Pos>
        END
    END
    
    GOSUB GET.MAX.COUNT.FOR.CUS.DETAILS ; *Get the maximum VM count for the customer details retrived from te customer Record
    
    GOSUB GET.PRIMARY.CUS.DETAILS ; *Retrieve primary customer details
    
    SecondaryCusCnt = DCOUNT(CustomersList,@VM)
    
    FOR CustomerPos = 1 TO SecondaryCusCnt
        CustomerId = CustomersList<1,CustomerPos>
        RelationCode = RelationCodes<1,CustomerPos>
        CustomerRole = CustomerRoles<1,CustomerPos>
        GOSUB GET.MAX.COUNT.FOR.CUS.DETAILS ; *Get the maximum VM count for the customer details retrived from te customer Record
        GOSUB GET.SECONDARY.CUS.DETAILS ; *Retrieve secondary customer details
    NEXT CustomerPos
    
    EB.Reports.setOData(FinalOutData<1,EB.Reports.getVc()>)
    EB.Reports.setVmCount(DCOUNT(FinalOutData,@VM))
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.MAX.COUNT.FOR.CUS.DETAILS>
GET.MAX.COUNT.FOR.CUS.DETAILS:
*** <desc>Get the maximum VM count for the customer details retrived from te customer Record</desc>

    CustomerRec = ST.Customer.Customer.CacheRead(CustomerId, Error) ;*Get the customer Record of the account
    
    IF NOT(Error) THEN ;*If customerRecord then fetch all the multivalue fields data in an array 'OutData'
        OutData<1> = CustomerRec<ST.Customer.Customer.EbCusPhoneOne>
        OutData<2> = CustomerRec<ST.Customer.Customer.EbCusEmailOne>
        OutData<3> = CustomerRec<ST.Customer.Customer.EbCusPostCode>
        OutData<4> = CustomerRec<ST.Customer.Customer.EbCusStreet>
        OutData<5> = CustomerRec<ST.Customer.Customer.EbCusTownCountry>
        OutData<6> = CustomerRec<ST.Customer.Customer.EbCusEmploymentStatus>
        OutData<7> = CustomerRec<ST.Customer.Customer.EbCusTaxId>
        OutData<8> = CustomerRec<ST.Customer.Customer.EbCusContactType>
        OutData<9> = CustomerRec<ST.Customer.Customer.EbCusIddPrefixPhone>
        OutData<10> = CustomerRec<ST.Customer.Customer.EbCusContactData>
        PrimaryCustomerType = "PRIMARY"
        SecondaryCustomerType = "SECONDARY"

        GOSUB GET.MAX.VM.COUNT ;*
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.MAX.VM.COUNT>
GET.MAX.VM.COUNT:
*** <desc> </desc>

    CountArray = ''

    CountArray<-1> = DCOUNT(OutData<1>,@VM)
    CountArray<-1> = DCOUNT(OutData<2>,@VM)
    CountArray<-1> = DCOUNT(OutData<3>,@VM)
    CountArray<-1> = DCOUNT(OutData<4>,@VM)
    CountArray<-1> = DCOUNT(OutData<5>,@VM)
    CountArray<-1> = DCOUNT(OutData<6>,@VM)
    CountArray<-1> = DCOUNT(OutData<7>,@VM)
    CountArray<-1> = DCOUNT(OutData<8>,@VM)
    CountArray<-1> = DCOUNT(OutData<9>,@VM)
    CountArray<-1> = DCOUNT(OutData<10>,@VM)

    MaxVmCount = MAXIMUM(CountArray) ;*Get the maximum VM count of all the multivalue field data
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.PRIMARY.CUS.DETAILS>
GET.PRIMARY.CUS.DETAILS:
*** <desc>Retrieve primary customer details</desc>

*If maxVMCount is null i.e contact data's are not available in the respective customer record then
*return primaryRole and customerId with customerType specified as PRIMARY
*If MaxVMCount is present then return customer contact details with customerRole and cusType

    IF NOT(MaxVmCount) THEN
        FinalOutData<1,-1> = CustomerId : '*' : '' :'*' :  PrimaryRole :'*' : "PRIMARY"
    END ELSE
        FOR MultiPos = 1 TO MaxVmCount
            FinalOutData<1,-1> = CustomerId<1,MultiPos> : '*' : '' :'*' :  PrimaryRole<1,MultiPos> :'*' : PrimaryCustomerType<1,MultiPos>:'*':OutData<1,MultiPos> : '*' : OutData<2,MultiPos> :'*' :  OutData<3,MultiPos> :'*' :  OutData<4,MultiPos>:'*': OutData<5,MultiPos>:'*': OutData<6,MultiPos>:'*': OutData<7,MultiPos>:'*': OutData<8,MultiPos>:'*': OutData<9,MultiPos>:'*': OutData<10,MultiPos>
        NEXT MultiPos
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.SECONDARY.CUS.DETAILS>
GET.SECONDARY.CUS.DETAILS:
*** <desc>Retrieve secondary customer details</desc>

*If maxVMCount is null i.e contact data's are not available in the respective customer record then
*return primaryRole and customerId with customerType specified as SECONDARY
*If MaxVMCount is present then return customer contact details with customerRole and cusType

    IF NOT(MaxVmCount) THEN
        FinalOutData<1,-1> = CustomerId : '*' : RelationCode:'*' : CustomerRole :'*':"SECONDARY"
    END ELSE
        FOR MultiPos = 1 TO MaxVmCount ;*Loop through each multivalue
            FinalOutData<1,-1> = CustomerId<1,MultiPos> : '*' : RelationCode<1,MultiPos> :'*' : CustomerRole<1,MultiPos> :'*':SecondaryCustomerType<1,MultiPos>:'*':OutData<1,MultiPos> : '*' : OutData<2,MultiPos> :'*' :  OutData<3,MultiPos> :'*' :  OutData<4,MultiPos>:'*': OutData<5,MultiPos>:'*': OutData<6,MultiPos>:'*': OutData<7,MultiPos>:'*': OutData<8,MultiPos>:'*': OutData<9,MultiPos>:'*': OutData<10,MultiPos>
        NEXT MultiPos
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
