* @ValidationCode : MjotMTQ4OTY0MTY1MzpDcDEyNTI6MTU2MDIzODk5NDkyNDpzaXZha3VtYXJrOjM6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxOTAxLjIwMTgxMjIzLTAzNTM6ODE6NzA=
* @ValidationInfo : Timestamp         : 11 Jun 2019 13:13:14
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sivakumark
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 70/81 (86.4%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201901.20181223-0353
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-118</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.LIMIT(ARRANGEMENT.ID, LIMIT.ID.LIST, R.LIMIT, RETURN.ERROR)
*
* Subroutine Type : PROCEDURE
* Attached as     : Procedure Call
* Primary Purpose : Given the Arrangment ref, get the LIMIT Property, build the
*                   LIMIT ID and return it.
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
* 1. RETURN.ERROR    : Return Error Message
*
*-----------------------------------------------------------------------------------
* Modification History:
*
* 15 Nov 2013 - Sathish PS
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
* 31/10/17 - Enhancement : 2262448
*			 Task		 : 2262451
*			 Changes made as part of Joint Owned Loans SI
*			 Call the GetLimitStructure with the Limit Customer
*
**-----------------------------------------------------------------------------------

    $USING AA.ModelBank
    $USING AA.Framework
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

RETURN          ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:

    LI.LimitTransaction.GetLimitStructure(LIMIT.CUSTOMER,LIMIT.REF, LIMIT.SERIAL, LIMIT.ID.LIST, RET.ERROR)
 
    ! Get the LIMIT Record
    GOSUB GET.LIMIT.RECORD

RETURN          ;* from PROCESS
*-----------------------------------------------------------------------------------
GET.LIMIT.RECORD:

    LIMIT.ID = LIMIT.ID.LIST<1>
    R.LIMIT = "" ; ERR.LIMIT = ""
    R.LIMIT = LI.Config.Limit.Read(LIMIT.ID, ERR.LIMIT)
    IF NOT(R.LIMIT) THEN
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
    LIMIT.CUSTOMER = "" ;* stores Limit Customers of the Arrangement

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
    LOOP.CNT = 1 ; MAX.LOOPS = 3
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO

        BEGIN CASE
            CASE LOOP.CNT EQ 1
                ! Arrangement ID, Get the Arrangement Record for the Customer Number
                GOSUB ARRANGEMENT.VALIDATIONS

            CASE LOOP.CNT EQ 2
                ! Get the Limit Property
                GOSUB GET.LIMIT.REF.SERIAL

            CASE LOOP.CNT EQ 3
                ! Validations on Limit Reference and Serial Number
                GOSUB LIMIT.REF.SERIAL.VALIDATIONS

        END CASE
        LOOP.CNT += 1
    REPEAT

RETURN          ;* From CHECK.PRELIM.CONDITIONS
*-----------------------------------------------------------------------------------
ARRANGEMENT.VALIDATIONS:

    IF ARRANGEMENT.ID EQ "" THEN
        PROCESS.GOAHEAD = 0
        RETURN.ERR0R = "1-NO.ARRANGEMENT.ID"
    END ELSE
        GOSUB GET.ARRANGEMENT.RECORD
        IF NOT(R.ARRANGEMENT) THEN
            PROCESS.GOAHEAD = 0
            RETURN.ERROR = '2-AA.ARRANGEMENT.REC.MISSING'
        END ELSE
        
* During enquiry launch, system should not rely on common variables.
* Hence instead of fetching customer record from AA.GET.PROPERTY.RECORD which relies on common variable inside AA.GET.ARRANGEMENT.CUSTOMER,
* get record by calling AA.GET.ARRANGEMENT.CONDITIONS by reading the record from the database.

            EFF.DATE = EB.SystemTables.getToday()

            RCustomer = ''   ;* stores customer record
            AA.Framework.GetArrangementConditions(ARRANGEMENT.ID, "CUSTOMER", "", EFF.DATE, "", RCustomer, "")  ;* get customer record
            RCustomer = RAISE(RCustomer)    ;* raise the record
    
            AA.Customer.GetArrangementCustomer(ARRANGEMENT.ID, "", RCustomer, "", LIMIT.CUSTOMER, CUSTOMER.ID, RET.ERROR)  ;* returns the arrangement customer
        
        END
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
            RETURN.ERROR = "4-NO.LIMIT.SERIAL.IN.LIMIT.PROPERTY"
        END
    END ELSE
        PROCESS.GOAHEAD = 0
        RETURN.ERROR = "3-NO.LIMIT.REF.IN.LIMIT.PROPERTY"
    END

RETURN
*-----------------------------------------------------------------------------------
GET.ARRANGEMENT.RECORD:

    R.ARRANGEMENT = "" ; ERR.ARRANGEMENT = ""
    R.ARRANGEMENT = AA.Framework.Arrangement.Read(ARRANGEMENT.ID, ERR.ARRANGRMENT)
RETURN
*-----------------------------------------------------------------------------------
END
