* @ValidationCode : MjotNDg0NzkwNzE2OkNwMTI1MjoxNjA3MDc5MTQzNjk4OnZrcHJhdGhpYmE6ODowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMS4yMDIwMTAyOS0xNzU0OjExNzoxMDM=
* @ValidationInfo : Timestamp         : 04 Dec 2020 16:22:23
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vkprathiba
* @ValidationInfo : Nb tests success  : 8
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 103/117 (88.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-128</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.LIMIT.DETAILS(ENQ.DATA)
*
* Subroutine Type : API
* Attached to     : Enquiry AA.DETAILS.LIMIT.DETAILS
* Attached as     : BUILD ROUTINE
* Primary Purpose : Return the right LIMIT id based on the incoming Arrangement ref.
*
*
* Incoming:
* ---------
*
* 1. ARRANGEMENT.ID  : Arrangement ID
*
* Outgoing:
* ---------
*
* 1. LIMIT.ID        : Limit ID
*
* Error Variables:
* ----------------
*
* 1. ENQ.ERROR    : Return Error Message
*
*-----------------------------------------------------------------------------------
* Modification History:
*
* 06 Jan 2014 - Sathish PS
*               New Development
*
* 09/09/15 - Task : 1447056
*            Enhancement : 1434821
*            Get the GL Custoemr by calling AA.GET.ARRANGEMENT.CUSTOMER routine.
*
* 24/02/17 - Defect : 2024964
*            Task   : 2031544
*            Gets the GL customer by calling AA.GET.ARRANGEMENT.CONDITIONS and AA.GET.ARRANGEMENT.CUSTOMER
*
* 03/11/17 - Defect : 2327433
*            Task   : 2330334
*            Limit/collateral details are not displayed in the overview screen for the future dated arrangements
*
* 31/10/17 - Enhancement : 2262448
*            Task        : 2262451
*            Changes made as part of Joint Owned Loans SI
*            Call the GetLimitStructure with the Limit Customer
*
* 26/02/18 - Enhancement : 2472003
*            Task        : 2472006
*            Return arrangement id to SEL.ARR.ID - new S type field in LIMIT
*
*27/11/18-   Defect:2870123
*            Task:2874247
*            The New customer details is not updated in limit while launching arrangement in  overview after customer change activity.
*
*09/01/2020 - Task  : 3524197
*            Defect : 3501899
*            Limit details not displayed on the overview screen, if limit key was attached
*
* 09/11/2020 - Enhancement  : 4066240
*              Task         : 4066243
*              Handle New Limit key in AA
*-----------------------------------------------------------------------------------
    $USING AA.ModelBank
    $USING AA.Framework
    $USING LI.GroupLimit
    $USING LI.LimitTransaction
    $USING LI.Config
    $USING AA.Customer
    $USING EB.SystemTables


    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB CHECK.PRELIM.CONDITIONS
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

    IF RETURN.ERROR THEN
        ENQ.ERROR = RETURN.ERROR
    END

RETURN          ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:
    
    LIMIT.KEY = ""  ;* Initialise the variable
    IF LIMIT.REF<2> THEN    ;* If limit.ref<2> holds limit key. If it exists then get the limit key.
        LIMIT.KEY = LIMIT.REF<2>
        LIMIT.REF = LIMIT.REF<1>
    END
    
    GROUP.KEY = "" ; RET.ERROR = ""
    LI.GroupLimit.GetCustomerGroup(CUSTOMER.ID, LIMIT.REF, GROUP.KEY, RET.ERROR)
    BEGIN CASE
        CASE GROUP.KEY
            LimitIdDetails<1> = GROUP.KEY
            LimitIdDetails<2> = LIMIT.REF
            LimitIdDetails<3> = LIMIT.SERIAL
            LimitIdDetails<4> = CUSTOMER.ID
            LI.Config.GetLimitReference('', LimitIdDetails, '', '', OutDetails, ErrorDetails, '', '')   ;* API to format the Limit reference(Handled Numeric old id and Alphanumeric new id)
            LIMIT.ID.LIST = OutDetails<LI.Config.FormattedLimitId>
        CASE LIMIT.KEY
            LIMIT.ID.LIST = LIMIT.KEY ;* If limit key is available then directly assign the key to Limit id list
        CASE 1  ;* Get the Limit id with LimitCustomer
            LI.LimitTransaction.GetLimitStructure(LIMIT.CUSTOMER,LIMIT.REF, LIMIT.SERIAL, LIMIT.ID.LIST, RET.ERROR)
    END CASE

    ! Get the LIMIT Record
    GOSUB GET.LIMIT.RECORD

RETURN          ;* from PROCESS
*-----------------------------------------------------------------------------------
GET.LIMIT.RECORD:

    LIMIT.ID = LIMIT.ID.LIST<1>
    R.LIMIT = "" ; ERR.LIMIT = ""
    R.LIMIT = LI.Config.Limit.Read(LIMIT.ID, ERR.LIMIT)
    IF R.LIMIT THEN
        ENQ.DATA<4,ARR.ID.POS> = LIMIT.ID
        LOCATE "SEL.ARR.ID" IN ENQ.DATA<2,1> SETTING SEL.POS THEN
            ENQ.DATA<4,SEL.POS> = ARRANGEMENT.ID ;* pass the arrangement id to SEL.ARR.ID selection field
        END
    END ELSE
        RETURN.ERROR = "AA-MB.LI.REC.MISS.FILE"
        RETURN.ERROR<2,1> = LIMIT.ID
        RETURN.ERROR<2,2> = FN.LIMIT.LOC
        LIMIT.ID = ""
        PROCESS.GOAHEAD = 0
    END

RETURN
*-----------------------------------------------------------------------------------
* <New Subroutines>

* </New Subroutines>
*-----------------------------------------------------------------------------------*
*//////////////////////////////////////////////////////////////////////////////////*
*////////////////P R E  P R O C E S S  S U B R O U T I N E S //////////////////////*
*//////////////////////////////////////////////////////////////////////////////////*
INITIALISE:

    PROCESS.GOAHEAD = 1
    LIMIT.ID = ""
    RETURN.ERROR = ""
    LIMIT.REF = ""
    LIMIT.SERIAL = ""
    CUSTOMER.ID = ""
    LIMIT.CUSTOMER = ""

RETURN          ;* From INITIALISE
*-----------------------------------------------------------------------------------
OPEN.FILES:

    FN.LIMIT.LOC = "F.LIMIT" ; F.LIMIT.LOC = ""
    FN.AA.ARRANGEMENT = "F.AA.ARRANGEMENT" ; F.AA.ARRANGEMENT = ""
    FN.ACCOUNT = "F.ACCOUNT" ; F.ACCOUNT = ""

RETURN          ;* From OPEN.FILES
*-----------------------------------------------------------------------------------
CHECK.PRELIM.CONDITIONS:
*
* Check for any Pre requisite conditions - like the existence of a record/parameter etc
* if not, set PROCESS.GOAHEAD to 0
*
    LOOP.CNT = 1 ; MAX.LOOPS = 4
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO

        BEGIN CASE
            CASE LOOP.CNT EQ 1
                GOSUB GET.ARRANGEMENT.ID

            CASE LOOP.CNT EQ 2
                ! Get the Arrangement Record for the Customer Number
                GOSUB ARRANGEMENT.VALIDATIONS

            CASE LOOP.CNT EQ 3
                ! Get the Limit Property
                GOSUB GET.LIMIT.REF.SERIAL

            CASE LOOP.CNT EQ 4
                ! Validations on Limit Reference and Serial Number
                GOSUB LIMIT.REF.SERIAL.VALIDATIONS

        END CASE
        LOOP.CNT += 1
    REPEAT

RETURN          ;* From CHECK.PRELIM.CONDITIONS
*-----------------------------------------------------------------------------------
GET.ARRANGEMENT.ID:

    ARR.ID.POS = ""
    LOCATE "@ID" IN ENQ.DATA<2,1> SETTING ARR.ID.POS THEN
        ARRANGEMENT.ID = ENQ.DATA<4,ARR.ID.POS>
    END ELSE
        PROCESS.GOAHEAD = 0
        RETURN.ERR0R = "AA-E.LIMIT.DETAILS.NO.ARRANGEMENT.ID"
    END

RETURN
*-----------------------------------------------------------------------------------
ARRANGEMENT.VALIDATIONS:

    GOSUB GET.ARRANGEMENT.RECORD
    EFF.DATE = ""
    IF NOT(R.ARRANGEMENT) THEN
        PROCESS.GOAHEAD = 0
        RETURN.ERROR = 'AA-E.LIMIT.DETAILS.AA.ARRANGEMENT.REC.MISSING'
    END ELSE
    
* During enquiry launch, system should not rely on common variables.
* Hence instead of fetching customer record from AA.GET.PROPERTY.RECORD which relies on common variable inside AA.GET.ARRANGEMENT.CUSTOMER,


        ARRANGEMENT.STATUS= R.ARRANGEMENT<AA.Framework.Arrangement.ArrArrStatus>  ;*arrangement status

        IF ARRANGEMENT.STATUS EQ "AUTH-FWD" THEN
            EFF.DATE = R.ARRANGEMENT<AA.Framework.Arrangement.ArrStartDate>          ;*when the arrangement is fordward dated EFF.DATE is arrangement start date else EFF.DATE is current date
        END

        RCustomer = ''   ;* stores customer record
        AA.Framework.GetArrangementConditions(ARRANGEMENT.ID, "CUSTOMER", "", EFF.DATE, "", RCustomer, "")  ;* get customer record
        RCustomer = RAISE(RCustomer)    ;* raise the record
    
        AA.Customer.GetArrangementCustomer(ARRANGEMENT.ID, "", RCustomer, "", LIMIT.CUSTOMER, CUSTOMER.ID, RET.ERROR)  ;* returns the arrangement customer

    END

RETURN
*-----------------------------------------------------------------------------------
GET.LIMIT.REF.SERIAL:

    AA.ModelBank.EAaGetLimitRef(ARRANGEMENT.ID, LIMIT.REF, LIMIT.SERIAL, RETURN.ERROR)
    IF RETURN.ERROR THEN
        PROCESS.GOAHEAD = 0
    END

RETURN
*-----------------------------------------------------------------------------------
LIMIT.REF.SERIAL.VALIDATIONS:

    IF LIMIT.REF THEN
        IF NOT(LIMIT.SERIAL) THEN
            RETURN.ERROR = "AA-E.LIMIT.DETAILS.NO.LIMIT.SERIAL.IN.LIMIT.PROPERTY"
        END
    END ELSE
        PROCESS.GOAHEAD = 0
        RETURN.ERROR = "AA-E.LIMIT.DETAILS.NO.LIMIT.REF.IN.LIMIT.PROPERTY"
    END

RETURN
*-----------------------------------------------------------------------------------
GET.ARRANGEMENT.RECORD:

    R.ARRANGEMENT = "" ; ERR.ARRANGEMENT = ""
    R.ARRANGEMENT = AA.Framework.Arrangement.Read(ARRANGEMENT.ID, ERR.ARRANGRMENT)
RETURN
*-----------------------------------------------------------------------------------
END
