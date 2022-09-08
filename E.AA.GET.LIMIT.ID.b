* @ValidationCode : MjoxOTk2MjA2NDgxOkNwMTI1MjoxNjA1Njk5NjEzOTc3OnZrcHJhdGhpYmE6NDowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMS4yMDIwMTAyOS0xNzU0OjcyOjY2
* @ValidationInfo : Timestamp         : 18 Nov 2020 17:10:13
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vkprathiba
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 66/72 (91.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-128</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.LIMIT.ID
*
*--------------------------------------------------------------------------------
*** <region name= Program Description>
***
*  This routine will get the limit id by using arrangement id.
*
*** </region>
*--------------------------------------------------------------------------------

*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
* Input
*
* Output
*
*** </region>
*--------------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Change descriptions</desc>
* Modification History :
*
* 03/11/2016 - Task : 1902891
*              Enhancement : 1864620
*              Get the Limit id of the arrangement.
*
* 31/10/17 - Enhancement : 2262448
*			 Task		 : 2262451
*			 Changes made as part of Joint Owned Loans SI
*			 Call the GetLimitStructure with the Limit Customer
*
* 09/11/2020 - Enhancement  : 4066240
*              Task         : 4066243
*              Handle New Limit key in AA
*** </region>
*--------------------------------------------------------------------------------
*
*** <region name= Inserts>
*** <desc>Inserts used in the sub-routine</desc>

    $USING AL.ModelBank
    $USING AA.ModelBank
    $USING LI.GroupLimit
    $USING LI.LimitTransaction
    $USING LI.Config
    $USING AA.Customer
    $USING EB.Reports
    $USING EB.SystemTables
    $USING AA.Framework

*** </region>
*--------------------------------------------------------------------------------

*** <region name= Main Program block>
*** <desc>Main processing logic</desc>

    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB CHECK.PRELIM.CONDITIONS
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

    IF RETURN.ERROR THEN
        ENQ.ERROR = RETURN.ERROR
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc>Initialise the local variables here</desc>
INITIALISE:

    PROCESS.GOAHEAD = 1
    LIMIT.ID = ""
    RETURN.ERROR = ""
    LIMIT.REF = ""
    LIMIT.SERIAL = ""
    CUSTOMER.ID = ""
    LIMIT.CUSTOMER = ""

RETURN
*** </region>
*-----------------------------------------------------------------------------------

*** <region name= Open Files>
*** <desc>Open the Limit & Account files</desc>
OPEN.FILES:

    FN.LIMIT.LOC = "F.LIMIT" ; F.LIMIT.LOC = ""
    FN.AA.ARRANGEMENT = "F.AA.ARRANGEMENT" ; F.AA.ARRANGEMENT = ""
    FN.ACCOUNT = "F.ACCOUNT" ; F.ACCOUNT = ""

RETURN
*** </region>
*-----------------------------------------------------------------------------------

*** <region name= CHeck Prelim Conditions>
*** <desc>Check Prelim Conditions</desc>
CHECK.PRELIM.CONDITIONS:
*
* Check for any Pre requisite conditions - like the existence of a record/parameter etc
* if not, set PROCESS.GOAHEAD to 0
*
    LOOP.CNT = 1 ; MAX.LOOPS = 3
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


        END CASE
        LOOP.CNT += 1
    REPEAT

RETURN
*** </region>
*-----------------------------------------------------------------------------------

*** <region name= Process>
*** <desc>Main processing logic</desc>
PROCESS:

    GROUP.KEY = "" ; RET.ERROR = ""
    LI.GroupLimit.GetCustomerGroup(CUSTOMER.ID, LIMIT.REF, GROUP.KEY, RET.ERROR)
    
    IF GROUP.KEY THEN
        LimitIdDetails<1> = GROUP.KEY
        LimitIdDetails<2> = LIMIT.REF
        LimitIdDetails<3> = LIMIT.SERIAL
        LimitIdDetails<4> = CUSTOMER.ID
        LI.Config.GetLimitReference('', LimitIdDetails, '', '', OutDetails, ErrorDetails, '', '')   ;* API to format the Limit reference(Handled Numeric old id and Alphanumeric new id)
        LIMIT.ID.LIST = OutDetails<LI.Config.FormattedLimitId>
    END ELSE
        LI.LimitTransaction.GetLimitStructure(LIMIT.CUSTOMER,LIMIT.REF, LIMIT.SERIAL, LIMIT.ID.LIST, RET.ERROR)
    END
            
** Get the LIMIT Record
    GOSUB GET.LIMIT.RECORD

RETURN
*** </region>
*-----------------------------------------------------------------------------------

*** <region name= Get Limit Record>
*** <desc>Get Limit record from the disk/desc>
GET.LIMIT.RECORD:

    LIMIT.ID = LIMIT.ID.LIST<1>
    R.LIMIT = "" ; ERR.LIMIT = ""
    R.LIMIT = LI.Config.Limit.Read(LIMIT.ID, ERR.LIMIT)
    IF R.LIMIT THEN
        EB.Reports.setOData(LIMIT.ID);* Assign beneficial owner to enquiry common vaiable O.DATA
    END ELSE
        PROCESS.GOAHEAD = 0
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------------

*** <region name= Get Arrangement Id>
*** <desc>Get the arrangement id from enquiry selection fields</desc>
GET.ARRANGEMENT.ID:

    ARRANGEMENT.ID = EB.Reports.getOData()  ;* Assign arrangement id which given as Input

RETURN
*** </region>
*-----------------------------------------------------------------------------------

*** <region name= Arrangement Validations>
*** <desc>Get the arrangement Customer</desc>
ARRANGEMENT.VALIDATIONS:

*During enquiry launch, system should not rely on common variables.
*Hence instead of fetching customer record from AA.GET.PROPERTY.RECORD which relies on common variable inside AA.GET.ARRANGEMENT.CUSTOMER,
*get record by calling AA.GET.ARRANGEMENT.CONDITIONS by reading the record from the database.

    EFF.DATE = EB.SystemTables.getToday()

    RCustomer = ""  ;* stores customer record
    AA.Framework.GetArrangementConditions(ARRANGEMENT.ID, "CUSTOMER", "", EFF.DATE, "", RCustomer, "")  ;* get customer record
    RCustomer = RAISE(RCustomer)    ;* raise the record

    AA.Customer.GetArrangementCustomer(ARRANGEMENT.ID, "", RCustomer, "", LIMIT.CUSTOMER, CUSTOMER.ID, RET.ERROR)

RETURN
*** </region>
*-----------------------------------------------------------------------------------

*** <region name= Get Limit Ref Serial>
*** <desc>Get Limit Serial number</desc>
GET.LIMIT.REF.SERIAL:

    AA.ModelBank.EAaGetLimitRef(ARRANGEMENT.ID, LIMIT.REF, LIMIT.SERIAL, RETURN.ERROR)
    
    IF RETURN.ERROR THEN
        PROCESS.GOAHEAD = 0
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------------

END
