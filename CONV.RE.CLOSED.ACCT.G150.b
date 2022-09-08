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

*-----------------------------------------------------------------------------
* <Rating>-105</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.AccountClosure
    SUBROUTINE CONV.RE.CLOSED.ACCT.G150
*
* 28/10/04 - EN_10002358
*            raise accounting entries to reverse CRF's
*            raised against other currency markets for deleted ACCOUNTS.
*
* 20/12/04 - BG_100007803
*            LOAD.COMPANY is not done by the CONVERSION, routine changed
*            to cater for multi-company.
*
* 03/10/06 - CI_10044524 / RE - HD0614748
*            SAVE.ID.COMPANY variable not initialised.
*
* 01/10/07 - CI_LOO51649
*            Pass the currency market in the entry.
*            Use the currency market from the account for EXCHRATE
*
* 18/06/07 - CI_10056147/HD0805956
*            When reversal entries are rasied against other currency markets,
*            balancing entries are raised against account's currency market instead of raising
*            reversal entries to account's currency market. This is done to avoid rounding differences
*            which resulted in transaction journal imbalance.
*
* 01/11/08 - BG_100020316
*            Marked I_F.RE.CLOSED.ACCT to OB and removed the insert from this file.
*
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.ACCOUNT

***   Main processing   ***
*     ---------------     *
*
* Loop through each company
*
    EQU RE.RCA.CURRENCY TO 1
    EQU RE.RCA.TOT.BALANCE TO 2
    EQU RE.RCA.ACCOUNT.NO TO 3
    EQU RE.RCA.ACCT.BALANCE TO 4
    EQU RE.RCA.AC.CLOSE.DATE TO 5
    EQU RE.RCA.CUSTOMER TO 6
    EQU RE.RCA.AC.CRF.FLD TO 7
    EQU RE.RCA.AC.CRF.VAL TO 8

    COMMAND = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
    COMPANY.LIST = ''
    CALL EB.READLIST(COMMAND, COMPANY.LIST, '', '', '')
    SAVE.ID.COMPANY = ID.COMPANY
    LOOP
        REMOVE K.COMPANY FROM COMPANY.LIST SETTING COMP.MARK
    WHILE K.COMPANY:COMP.MARK

        IF K.COMPANY <> ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
        END
*
* Check whether product is installed
*

        GOSUB INITIALISE

        GOSUB SELECT.ACCOUNTS

        IF SEL.LIST # '' THEN
            GOSUB PROCESS.ACCOUNTS
        END


    REPEAT

*Restore back ID.COMPANY if it has changed.

    IF ID.COMPANY <> SAVE.ID.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)
    END

    RETURN


*---------*
INITIALISE:
*---------*

    FN.RE.CLOSED.ACCT = 'F.RE.CLOSED.ACCT'
    F.RE.CLOSED.ACCT = ''
    CALL OPF(FN.RE.CLOSED.ACCT,F.RE.CLOSED.ACCT)

    FN.RE.CLOSED.ACCT.CONCAT = 'F.RE.CLOSED.ACCT.CONCAT'
    F.RE.CLOSED.ACCT.CONCAT = ''
    CALL OPF(FN.RE.CLOSED.ACCT.CONCAT,F.RE.CLOSED.ACCT.CONCAT)

    FN.AC.CONV.ENTRY = 'F.AC.CONV.ENTRY'
    F.AC.CONV.ENTRY = ''
    CALL OPF(FN.AC.CONV.ENTRY,F.AC.CONV.ENTRY)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.ACCOUNT.HIS = 'F.ACCOUNT$HIS'
    F.ACCOUNT.HIS = ''
    CALL OPF(FN.ACCOUNT.HIS,F.ACCOUNT.HIS)

    SEL.LIST = ''
    ACCOUNT.ID = ''

    RETURN

*--------------*
SELECT.ACCOUNTS:
*--------------*

    SEL.STMT = 'SELECT ':FN.RE.CLOSED.ACCT
    SEL.LIST = ""
    SELECTED = ""
    RET.CODE = ""
    CALL EB.READLIST(SEL.STMT, SEL.LIST, '', SELECTED, RET.CODE)
    RETURN

*---------------*
PROCESS.ACCOUNTS:
*---------------*

    LOOP
        REMOVE RE.CLOSED.ACCT.ID FROM SEL.LIST SETTING MORE
    WHILE RE.CLOSED.ACCT.ID:MORE

        GOSUB READ.RE.CLOSED.ACCT

        NO.ACCOUNTS = DCOUNT(R.RE.CLOSED.ACCT<RE.RCA.ACCOUNT.NO>,VM)
        FOR ACC.POS = 1 TO NO.ACCOUNTS
            ACCOUNT.ID = R.RE.CLOSED.ACCT<RE.RCA.ACCOUNT.NO,ACC.POS>
            GOSUB READ.ACCOUNT
            IF CCY.MKT <> R.ACCOUNT<9> THEN
                AMT = R.RE.CLOSED.ACCT<RE.RCA.ACCT.BALANCE,ACC.POS>
                GOSUB REVERSE.CRF
            END
            GOSUB UPDATE.CONCAT
        NEXT ACC.POS
        GOSUB WRITE.AC.CONV.ENTRY
        GOSUB DELETE.RE.CLOSED.ACCT
    REPEAT

    RETURN


*------------------*
READ.RE.CLOSED.ACCT:
*------------------*

    R.RE.CLOSED.ACCT = ''
    YERR = ''
    RETRY = ""
    READ R.RE.CLOSED.ACCT FROM F.RE.CLOSED.ACCT,RE.CLOSED.ACCT.ID ELSE
        R.RE.CLOSED.ACCT = ''
    END

    NO.DOTS = COUNT(RE.CLOSED.ACCT.ID,'.') + 1
    CONSOL.KEY = FIELD(RE.CLOSED.ACCT.ID,'.',1,NO.DOTS-1)
    CRF.TYPE = FIELD(RE.CLOSED.ACCT.ID,'.',NO.DOTS,1)
    CCY = FIELD(RE.CLOSED.ACCT.ID,'.',4,1)
    CCY.MKT = FIELD(RE.CLOSED.ACCT.ID,'.',2,1)

    ACTG.ENTRYS = ''
    STMT.ENTRY = ''


    RETURN


*----------*
REVERSE.CRF:
*----------*

    STMT.ENTRY = ''
    STMT.ENTRY<AC.STE.OUR.REFERENCE> = ACCOUNT.ID
    STMT.ENTRY<AC.STE.COMPANY.CODE> = ID.COMPANY
    STMT.ENTRY<AC.STE.SYSTEM.ID> = 'AC'
    STMT.ENTRY<AC.STE.CRF.TYPE> = CRF.TYPE
    STMT.ENTRY<AC.STE.CRF.TXN.CODE> = 'APP'
    STMT.ENTRY<AC.STE.CURRENCY> = CCY
    STMT.ENTRY<AC.STE.CURRENCY.MARKET> = CCY.MKT
    IF CCY = LCCY THEN
        STMT.ENTRY<AC.STE.AMOUNT.LCY> = AMT * -1  ;* AC.MKT.ACTUAL.BAL
    END ELSE
        STMT.ENTRY<AC.STE.AMOUNT.FCY> = AMT * -1  ;* AC.MKT.ACTUAL.BAL

        GOSUB CALC.EXCHRATE
        STMT.ENTRY<AC.STE.AMOUNT.LCY> = OUT.AMT
    END

    STMT.ENTRY<AC.STE.CONSOL.KEY> = CONSOL.KEY

    ACTG.ENTRYS<-1> = LOWER(STMT.ENTRY)

*Raise balancing entry against account's currency market.

    STMT.ENTRY<AC.STE.AMOUNT.LCY> = STMT.ENTRY<AC.STE.AMOUNT.LCY> * -1
    IF STMT.ENTRY<AC.STE.AMOUNT.FCY> # "" THEN
        STMT.ENTRY<AC.STE.AMOUNT.FCY> = STMT.ENTRY<AC.STE.AMOUNT.FCY> * -1
    END
    STMT.ENTRY<AC.STE.CURRENCY.MARKET> = R.ACCOUNT<9>
    STMT.ENTRY<AC.STE.CONSOL.KEY> = R.ACCOUNT<72>
    ACTG.ENTRYS<-1> = LOWER(STMT.ENTRY)


    RETURN


*--------------------*
DELETE.RE.CLOSED.ACCT:
*--------------------*

    DELETE F.RE.CLOSED.ACCT,RE.CLOSED.ACCT.ID

    RETURN

*------------*
CALC.EXCHRATE:
*------------*

    CCY.MKT.USE = R.ACCOUNT<9>
    IF CCY.MKT.USE = '' THEN
        CCY.MKT.USE = 1
    END
    OUT.CCY = LCCY
    EXCH.RATE = ""
    OUT.AMT = ""
    IN.CCY = CCY
    IN.AMT = STMT.ENTRY<AC.STE.AMOUNT.FCY>
    CALL EXCHRATE(CCY.MKT.USE, IN.CCY, IN.AMT, OUT.CCY, OUT.AMT, "", EXCH.RATE, "", "", "")

    RETURN

*--------------*
READ.ACCOUNT:
*--------------*

    READ R.ACCOUNT FROM F.ACCOUNT,ACCOUNT.ID ELSE
        READ.FAILED = ''
        R.ACCOUNT.HIS = ''
        HIS.ID = ACCOUNT.ID
        CALL EB.READ.HISTORY.REC(F.ACCOUNT.HIS,HIS.ID,R.ACCOUNT.HIS,READ.FAILED)
        IF NOT(READ.FAILED) THEN
            R.ACCOUNT = R.ACCOUNT.HIS
        END ELSE
            R.ACCOUNT = ''
        END
    END

    RETURN



*------------*
UPDATE.CONCAT:
*------------*

    RE.CLOSED.ACCT.CONCAT.ID = ACCOUNT.ID:'.':R.RE.CLOSED.ACCT<RE.RCA.AC.CLOSE.DATE,ACC.POS>

    R.RE.CLOSED.ACCT.CONCAT = ""
    YERR = ''
    RETRY = ""

    READ R.RE.CLOSED.ACCT.CONCAT FROM F.RE.CLOSED.ACCT.CONCAT,RE.CLOSED.ACCT.CONCAT.ID ELSE
        R.RE.CLOSED.ACCT.CONCAT = ''
    END

    LOCATE RE.CLOSED.ACCT.ID IN R.RE.CLOSED.ACCT.CONCAT<1> SETTING POS THEN
        DEL R.RE.CLOSED.ACCT.CONCAT<POS>
    END

    IF R.RE.CLOSED.ACCT.CONCAT = '' THEN
        DELETE F.RE.CLOSED.ACCT.CONCAT,RE.CLOSED.ACCT.CONCAT.ID
    END ELSE
        WRITE R.RE.CLOSED.ACCT.CONCAT ON F.RE.CLOSED.ACCT.CONCAT,RE.CLOSED.ACCT.CONCAT.ID
    END

    RETURN

*------------------*
WRITE.AC.CONV.ENTRY:
*------------------*

    R.AC.CONV.ENTRY = ACTG.ENTRYS
    AC.CONV.ENTRY.ID = 'ACCCLOSED.AC.':RE.CLOSED.ACCT.ID

    WRITE R.AC.CONV.ENTRY ON F.AC.CONV.ENTRY,AC.CONV.ENTRY.ID

    RETURN

END
