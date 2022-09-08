* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------------
* <Rating>-151</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.AI.LAST.N.TXNS.BUILD(ENQ.DATA)
*-----------------------------------------------------------------------------------
* MODIFICATION HISTORY:
************************
* 25/10/11 - En- 99120 / Task - 156274
*            Improvement odf stmt.enquiries
*
* 28/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*--------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.Reports
    $USING AC.AccountOpening
    $USING EB.API
    $USING AA.Framework
*-----------------------------------------------------------------------------------
*
    GOSUB INITIALISE
    GOSUB CHECK.PRELIM.CONDITIONS
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

    RETURN
*-----------------------------------------------------------------------------------
INITIALISE:
*---------
    PROCESS.GOAHEAD = 1
    STORED.ENTRIES.LIST = ""
    LOCATE.FIELD.MANDATORY = ""
    LOCATE.DEFAULT.VALUE = ""
    LOCATE.FIELD.NUMERIC = ""
    TXN.DATE = ""
    ORIG.ACCOUNT.NUMBER = ""

    RETURN
*-----------------------------------------------------------------------------------
CHECK.PRELIM.CONDITIONS:
*
    LOOP.CNT = 1 ; MAX.LOOPS = 8
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO

        BEGIN CASE
            CASE LOOP.CNT EQ 1
                GOSUB GET.ACCOUNT

            CASE LOOP.CNT EQ 2
                GOSUB GET.REQUIRED.ENTRY.COUNT

            CASE LOOP.CNT EQ 3
                GOSUB GET.MAX.HISTORY.MONTHS

            CASE LOOP.CNT EQ 4
                GOSUB CHECK.PROCESSING.DATE.FLAG

            CASE LOOP.CNT EQ 5
                GOSUB GET.IN.START.DATE
                GOSUB VALIDATE.IN.START.DATE          ;! Against the Max threshold we can go back in history

            CASE LOOP.CNT EQ 6
                GOSUB GET.IN.END.DATE

            CASE LOOP.CNT EQ 7
                GOSUB LOAD.ACCOUNT.RECORD

            CASE LOOP.CNT EQ 8
                GOSUB GET.ACTIVITY.MONTHS

        END CASE

        IF EB.Reports.getEnqError() THEN
            PROCESS.GOAHEAD = 0
        END

        LOOP.CNT += 1

    REPEAT

    RETURN          ;* From CHECK.PRELIM.CONDITIONS
*-----------------------------------------------------------------------------------
GET.ACCOUNT:

    LOCATE.FIELD = "ACCT.ID"
    LOCATE.FIELD.MANDATORY = 1
    GOSUB GET.VALUE

    IF NOT(EB.Reports.getEnqError()) THEN
        ACCOUNT.NUMBER = LOCATE.VALUE
    END

    RETURN
*-----------------------------------------------------------------------------------
GET.REQUIRED.ENTRY.COUNT:

    LOCATE.FIELD = "NO.OF.ENTRIES"
    LOCATE.FIELD.NUMERIC = 1
    LOCATE.DEFAULT.VALUE = 10
    GOSUB GET.VALUE

    IF NOT(EB.Reports.getEnqError()) THEN
        REQUIRED.ENTRY.COUNT = LOCATE.VALUE
    END

    RETURN
*------------------------------------------------------------------------------------
GET.MAX.HISTORY.MONTHS:

    LOCATE.FIELD = "MAX.HISTORY.MONTHS"
    LOCATE.FIELD.NUMERIC = 1
    LOCATE.DEFAULT.VALUE = 12
    GOSUB GET.VALUE

    IF NOT(EB.Reports.getEnqError()) THEN
        MAX.HISTORY.MONTHS = LOCATE.VALUE
    END

    RETURN
*-----------------------------------------------------------------------------------
CHECK.PROCESSING.DATE.FLAG:

    ! In case the list needs to be returned based on PROCESSING.DATE
    LOCATE.FIELD = "TXN.DATE"
    LOCATE.DEFAULT.VALUE = "BOOK"
    GOSUB GET.VALUE
    IF NOT(EB.Reports.getEnqError()) THEN
        TXN.DATE = LOCATE.VALUE
    END

    RETURN
*-----------------------------------------------------------------------------------
GET.IN.START.DATE:

    IN.START.DATE = ""
    LOCATE.FIELD = "IN.START.DATE"
    GOSUB GET.VALUE
    IF NOT(EB.Reports.getEnqError()) THEN
        IN.START.DATE = LOCATE.VALUE
    END

    RETURN
*-----------------------------------------------------------------------------------
VALIDATE.IN.START.DATE:

    IF IN.START.DATE THEN
        ! Assuming TODAY is 2000 05 11 and IN.START.DATE is 1999 10 31

        ! 2000
        MAX.HISTORY.YYYY = EB.SystemTables.getToday()[1,4]
        ! 05
        MAX.HISTORY.MM = EB.SystemTables.getToday()[5,2]
        ! -1
        MAX.HISTORY.MM = MAX.HISTORY.MM - 6
        IF MAX.HISTORY.MM LE 0 THEN
            ! 1999
            MAX.HISTORY.YYYY = MAX.HISTORY.YYYY - 1
            ! 12 + (-1) = 11
            MAX.HISTORY.MM = 12 + MAX.HISTORY.MM
            ! (19)99 GT (20)10
            IF MAX.HISTORY.YYYY[3,2] GT EB.SystemTables.getToday()[3,2] THEN
                ! 20 - 1 = 19
                MAX.HISTORY.YYYY[1,2] = MAX.HISTORY.YYYY[1,2] - 1
            END
        END
        ! 1999 11 11
        MAX.HISTORY.DATE = MAX.HISTORY.YYYY : STR("0",2-LEN(MAX.HISTORY.MM)) : MAX.HISTORY.MM : EB.SystemTables.getToday()[7,2]
        ! 1999 10 31 LT 1999 11 11 and will result in an error
        IF IN.START.DATE LT MAX.HISTORY.DATE THEN
            EB.Reports.setEnqError("EB-RMB1.START.DATE.OUT.OF.RANGE")
            tmp=EB.Reports.getEnqError(); tmp<2,1>=MAX.HISTORY.MONTHS; EB.Reports.setEnqError(tmp)
        END
    END

    RETURN
*-----------------------------------------------------------------------------------
GET.IN.END.DATE:

    IN.END.DATE = ""
    LOCATE.FIELD = "IN.END.DATE"
    GOSUB GET.VALUE
    IF NOT(EB.Reports.getEnqError()) THEN
        IN.END.DATE = LOCATE.VALUE
        IF NOT(IN.END.DATE) AND IN.START.DATE THEN
            IN.END.DATE = EB.SystemTables.getToday()
        END
    END

    RETURN
*-----------------------------------------------------------------------------------
GET.VALUE:

    LOCATE.VALUE = ""
    LOCATE LOCATE.FIELD IN ENQ.DATA<2,1> SETTING FLD.FOUND.POS THEN
    IF ENQ.DATA<3,FLD.FOUND.POS> EQ "EQ" THEN
        LOCATE.VALUE = ENQ.DATA<4,FLD.FOUND.POS>
    END ELSE
        EB.Reports.setEnqError("EB-RMB1.OPERAND.MUST.BE.EQ.FOR.":LOCATE.FIELD)
    END
    END ELSE
    IF LOCATE.FIELD.MANDATORY THEN
        EB.Reports.setEnqError("EB-RMB1.":LOCATE.FIELD:".MANDATORY")
    END
    END
*
    BEGIN CASE
        CASE LOCATE.FIELD.NUMERIC
            IF LOCATE.VALUE AND NOT(NUM(LOCATE.VALUE)) THEN
                EB.Reports.setEnqError("EB-RMB1.":LOCATE.FIELD:".NOT.NUMERIC")
            END

        CASE NOT(LOCATE.VALUE)
            LOCATE.VALUE = LOCATE.DEFAULT.VALUE
    END CASE

    LOCATE.FIELD.MANDATORY = ""
    LOCATE.FIELD.NUMERIC = ""
    LOCATE.DEFAULT.VALUE = ""

    RETURN
*-----------------------------------------------------------------------------------
LOAD.ACCOUNT.RECORD:

    R.ACCOUNT.RECORD = "" ; ERR.AC = ""
    R.ACCOUNT.RECORD = AC.AccountOpening.tableAccount(ACCOUNT.NUMBER, ERR.AC)
    IF ERR.AC THEN
        EB.Reports.setEnqError("EB-RMB1.REC.MISS.FILE")
        tmp=EB.Reports.getEnqError(); tmp<2,1>=ACCOUNT.NUMBER
        tmp<2,2>='F.ACCOUNT'; EB.Reports.setEnqError(tmp)
    END

    RETURN
*-----------------------------------------------------------------------------------
GET.ACTIVITY.MONTHS:

    IF NOT(IN.START.DATE) THEN
        ACCT.ACTIVITY.MONTHS = ""
        *
        * This will return the list of YYYYMMs when there has been any activity on the account
        * in an FM delimited array (as stored in EB.CONTRACT.BALANCES)
        *

        IF R.ACCOUNT.RECORD<AC.AccountOpening.Account.ArrangementId> THEN ;*For arrangement account
            ARRANGEMENT.ID = R.ACCOUNT.RECORD<AC.AccountOpening.Account.ArrangementId>
            * To get the CUR ACCOUNT balance type,  a dummy AA.ITEM.REF is passed with 6th part as "DIRECT".
            DUMMY.AA.ITEM.REF = "*****DIRECT*" ;* Arguments of AA.GET.BALANCE.TYPE is changed, so added the required arguments
            AA.Framework.GetBalanceType('ACCOUNT', ARRANGEMENT.ID, BALANCE.TYPE, DUMMY.AA.ITEM.REF,'','',RET.ERROR)  ;* Get the CUR Balance type for Account property class
            IF BALANCE.TYPE THEN
                ORIG.ACCOUNT.NUMBER = ACCOUNT.NUMBER
                ACCOUNT.NUMBER = ACCOUNT.NUMBER:'.':BALANCE.TYPE
            END
        END

        EB.API.GetActivityDates(ACCOUNT.NUMBER,ACCT.ACTIVITY.MONTHS)
        IF NOT(ACCT.ACTIVITY.MONTHS) THEN
            PROCESS.GOAHEAD = 0
        END

        IF ORIG.ACCOUNT.NUMBER THEN
            ACCOUNT.NUMBER = ORIG.ACCOUNT.NUMBER  ;*Resume the original account number
        END
    END

    RETURN
*-----------------------------------------------------------------------------------
PROCESS:
*------
    BEGIN CASE

        CASE IN.START.DATE AND IN.END.DATE
            LOCATE 'IN.START.DATE' IN ENQ.DATA<2,1> SETTING START.POS THEN
            DEL ENQ.DATA<2,START.POS>
            DEL ENQ.DATA<3,START.POS>
            DEL ENQ.DATA<4,START.POS>
        END
        LOCATE 'IN.END.DATE' IN ENQ.DATA<2,1> SETTING END.POS THEN
        DEL ENQ.DATA<2,END.POS>
        DEL ENQ.DATA<3,END.POS>
        DEL ENQ.DATA<4,END.POS>
    END
    ENQ.DATA<2,-1> = "BOOKING.DATE"
    ENQ.DATA<3,-1> = "RG"
    ENQ.DATA<4,-1> = IN.START.DATE:@SM:IN.END.DATE

    CASE 1
    NO.OF.ACTIVITY.MONTHS = DCOUNT(ACCT.ACTIVITY.MONTHS,@FM)
    ENQ.DATA<2,-1> = "ACTIVITY.MONTHS"
    ENQ.DATA<3,-1> = "EQ"
    ENQ.DATA<4,-1> = LOWER(LOWER(ACCT.ACTIVITY.MONTHS))
    END CASE

    RETURN
*-----------------------------------------------------------------------------------

    END
