* @ValidationCode : MjotODc3NzE4MDcwOkNwMTI1MjoxNTk5NjQyMDI2NDIyOmFuaXR0YXBhdWw6NDowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNi4yMDIwMDUyNy0wNDM1OjU4OjU4
* @ValidationInfo : Timestamp         : 09 Sep 2020 14:30:26
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : anittapaul
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 58/58 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-88</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.LIMIT.REF(ARRANGEMENT.ID, LIMIT.REFERENCE, LIMIT.SERIAL, RETURN.ERROR)
*
* Subroutine Type : ENQUIRY
* Attached to     : AA.OVERVIEW-SUBHEADING.LIMIT.COLLATERAL
* Attached as     : BUILD.ROUTINE
* Primary Purpose : Routine to fetch the LIMIT.REFERNCE & LIMIT.SERIAL for the
*                   Supplied Arrangement ID
*
*
* Incoming:
* ---------
* 1. ARRANGEMENT.ID : Arrangement ID
*
* Outgoing:
* ---------
* 1. LIMIT.REFERENCE : Limit Reference
* 2. LIMIT.SERIAL    : Limit Serial Number
*
* Error Variables:
* ----------------
* 1. RETURN.ERROR    : Return Error
*
*-----------------------------------------------------------------------------------
* Modification History:
*
* 15 Nov 2013 - Sathish PS
*               New Development
*
*09/01/2020 - Task  : 3524197
*            Defect : 3501899
*            If limit key available in account record then pass LIMIT.REFERENCE<2> as limit key
*
* 25/08/2020 - Task        : 3930267
*              Enhancement : 3930273
*              Skip read to account table if account id starts with AA for microservices and get the limit record from limit property.
*-----------------------------------------------------------------------------------

    $USING EB.Reports
    $USING AA.Framework
    $USING AA.Limit
    $USING AC.AccountOpening
    
    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB CHECK.PRELIM.CONDITIONS
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

RETURN          ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:

    ACCOUNT.NO = R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkedApplId>
    IF ACCOUNT.NO[1,2] EQ "AA" THEN ;* when account id is arrangement id skip the read to account table and get the limit details for limit from limit property.
        LIMIT.RECORD = ""
        AA.Framework.GetArrangementConditions(ARRANGEMENT.ID, "LIMIT", "", "", "", LIMIT.RECORD, "")
        LIMIT.RECORD = RAISE(LIMIT.RECORD)
        LIMIT.KEY = LIMIT.RECORD<AA.Limit.Limit.LimLimit>
        LIMIT.REFERENCE = LIMIT.RECORD<AA.Limit.Limit.LimLimitReference>
        LIMIT.SERIAL = LIMIT.RECORD<AA.Limit.Limit.LimLimitSerial>
        IF LIMIT.KEY THEN
            LIMIT.REFERENCE<2> = LIMIT.KEY
        END
    END ELSE
        R.ACCOUNT = AC.AccountOpening.Account.Read(ACCOUNT.NO, ERR.ACCOUNT)
        IF R.ACCOUNT THEN
            LIMIT.KEY = R.ACCOUNT<AC.AccountOpening.Account.LimitKey>   ;* Get the Limit key
            LIMIT.REF.IN.RECORD = R.ACCOUNT<AC.AccountOpening.Account.LimitRef>
            LIMIT.REFERENCE = LIMIT.REF.IN.RECORD['.',1,1]
            LIMIT.SERIAL = LIMIT.REF.IN.RECORD['.',2,1]
            IF LIMIT.KEY THEN   ;* If limit key is available then assign the value in LIMIT.REFERENCE<2> to display the correct limit details
                LIMIT.REFERENCE<2> = LIMIT.KEY
            END
        END
    END
    !
    !    PROPERTY.CLASS = "LIMIT"
    !    R.AA.LIMIT = ""
    !    RET.ERROR = ""
    !    CALL AA.GET.PROPERTY.RECORD("", ARRANGEMENT.ID, "","", PROPERTY.CLASS, "",R.AA.LIMIT , RET.ERROR)
    !    IF RET.ERROR THEN
    !        RETURN.ERROR = RET.ERROR
    !        PROCESS.GOAHEAD = 0
    !    END ELSE
    !        LIMIT.REFERENCE = R.AA.LIMIT<AA.Limit.Limit.LimLimitReference>
    !        LIMIT.SERIAL = R.AA.LIMIT<AA.Limit.Limit.LimLimitSerial>
    !    END
    ! Also tried with SIM.READ...need to discuss with Ram/Sankar...
    !    FILE.NAME = 'F.AA.ARR.LIMIT'
    !    CALL SIM.READ(SIM.REF, FILE.NAME, ARRANGEMENT.ID, R.AA.LIMIT, "", "", "")
    !    LIMIT.REFERENCE = R.AA.LIMIT<AA.Limit.Limit.LimLimitReference>
    !    LIMIT.SERIAL = R.AA.LIMIT<AA.Limit.Limit.LimLimitSerial>
    ! Obviously doing something wrong - the above doesnt seem to work - so trying from Account record for now.

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
    LIMIT.REFERENCE = ""
    LIMIT.SERIAL = ""
    LIMIT.KEY   = ""
    RETURN.ERROR = ""

RETURN          ;* From INITIALISE
*-----------------------------------------------------------------------------------
OPEN.FILES:

    FN.AA.ARRANGEMENT = "F.AA.ARRANGEMENT" ; F.AA.ARRANGEMENT = ""
    FN.ACCOUNT.LOC = "F.ACCOUNT" ; F.ACCOUNT.LOC = ""

RETURN          ;* From OPEN.FILES
*-----------------------------------------------------------------------------------
CHECK.PRELIM.CONDITIONS:
*
* Check for any Pre requisite conditions - like the existence of a record/parameter etc
* if not, set PROCESS.GOAHEAD to 0

    LOOP.CNT = 1 ; MAX.LOOPS = 1
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO

        BEGIN CASE
            CASE LOOP.CNT EQ 1
                GOSUB GET.ARRANGEMENT.RECORD
                IF NOT(R.ARRANGEMENT) THEN
                    RETURN.ERROR = '1-AA.ARRANGEMENT.REC.MISSING'
                    PROCESS.GOAHEAD = 0
                END

        END CASE
        LOOP.CNT += 1
    REPEAT

RETURN          ;* From CHECK.PRELIM.CONDITIONS
*-----------------------------------------------------------------------------------
GET.ARRANGEMENT.RECORD:

    R.ARRANGEMENT = ""
    ERR.ARRANGEMENT = ""
    R.ARRANGEMENT = AA.Framework.Arrangement.Read(ARRANGEMENT.ID, ERR.ARRANGEMENT)

RETURN
*-----------------------------------------------------------------------------------
END
