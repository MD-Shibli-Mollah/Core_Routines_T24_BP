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
* <Rating>-110</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.BalanceUpdates
    SUBROUTINE CONV.ACCOUNT.MKT.G150(ACCOUNT.ID,R.ACCOUNT,FN.ACCOUNT)
*
* 21/10/04 - EN_10002358
*            Clear MKT fields and raise accounting entries to reverse CRF's
*            raised against other currency markets.
*
* 20/12/04 - BG_10007803
*            LOAD.COMPANY is not done, so open file with the mnemonic.
*
* 05/12/05 - CI_10037072
*            Include CURRENT.MARKET on entries.
*
* 04/09/07 - CI_10051180
*            An account with different currency market balance, after upgrade
*            first COB creates mismatch.Incorrect argument passed to the
*            routine RE.GET.ACCT.SIGN
*
* 29/10/07 - CI_10051676
*            Raising spec entries to move the acct.ent.today balances of account
*            in different market to account market.
*
* 23/01/08 - CI_10053396 // CI_10053457
*            Check ACCT.ENT.FWD file for entries, so that position movements can be raised
*            to transfer the amonts to the account market.
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.STMT.ENTRY


***   Main processing   ***
*     ---------------     *

    IF FN.ACCOUNT['$',2,1] = '' THEN    ;* Live file
        GOSUB PROCESS.ACCOUNTS
    END
    GOSUB CLEAR.MKT.FIELDS


    RETURN

*---------------*
PROCESS.ACCOUNTS:
*---------------*

    CRF.TYPE = ''
    ACTG.ENTRYS = ''
    CALL.ACC = 0
    ENTRY.POS = 1
    STMT.ENTRY = ''
    AET.FLAG = ''   ;* Initialise ACCT.ENT.TODAY FLAG
    AEF.FLAG = 0
    GOSUB ACCOUNT.CRF.TYPE
    GOSUB CONV.ACCT.ENT.TODAY
    IF R.ACCOUNT<73> # '' THEN
        GOSUB REVERSE.CRF
    END

    GOSUB CHECK.ACCT.ENT.FWD

    IF CALL.ACC THEN
        GOSUB WRITE.AC.CONV.ENTRY
    END

    RETURN

*----------*
REVERSE.CRF:
*----------*

    MKT.CNT = DCOUNT(R.ACCOUNT<73>,VM)  ;* AC.BALANCE.CCY.MKT

    FOR MKT.POS = 1 TO MKT.CNT
        IF R.ACCOUNT<73,MKT.POS> = R.ACCOUNT<9> THEN        ;* AC.CURRENCY.MARKET
            CONTINUE
        END
        GOSUB BUILD.ENTRY.ARRAY
    NEXT MKT.POS

    RETURN

BUILD.ENTRY.ARRAY:
*-----------------

    STMT.ENTRY = ''
    STMT.ENTRY<AC.STE.OUR.REFERENCE> = ACCOUNT.ID
    STMT.ENTRY<AC.STE.COMPANY.CODE> = ID.COMPANY
    STMT.ENTRY<AC.STE.SYSTEM.ID> = 'AC'
    STMT.ENTRY<AC.STE.CRF.TYPE> = CRF.TYPE
    STMT.ENTRY<AC.STE.CRF.TXN.CODE> = 'APP'
    STMT.ENTRY<AC.STE.CURRENCY> = R.ACCOUNT<8>    ;* AC.CURRENCY
    IF R.ACCOUNT<8> = LCCY THEN         ;* AC.CURRENCY
        IF AET.FLAG THEN
            STMT.ENTRY<AC.STE.AMOUNT.LCY> = R.STMT.ENTRY<AC.STE.AMOUNT.LCY> * -1
        END ELSE
            STMT.ENTRY<AC.STE.AMOUNT.LCY> = R.ACCOUNT<74,MKT.POS> * -1          ;* AC.MKT.ACTUAL.BAL
        END

    END ELSE
        IF AET.FLAG THEN
            STMT.ENTRY<AC.STE.AMOUNT.FCY> = R.STMT.ENTRY<AC.STE.AMOUNT.FCY> * -1

* In case of Acct.ent.today entry processing, populate the lcy amount from the entry, instead of
* calling the EXCHRATE to arrive at for each market, to avoid lcy amount difference rising out
* of different rates in Transaction and CCY table. Revaluation will post the adjustment entries
* finally for the single market.
            STMT.ENTRY<AC.STE.AMOUNT.LCY> = R.STMT.ENTRY<AC.STE.AMOUNT.LCY> * -1
            STMT.ENTRY<AC.STE.EXCHANGE.RATE> = R.STMT.ENTRY<AC.STE.EXCHANGE.RATE>

        END ELSE
            STMT.ENTRY<AC.STE.AMOUNT.FCY> = R.ACCOUNT<74,MKT.POS> * -1          ;* AC.MKT.ACTUAL.BAL
            GOSUB CALC.EXCHRATE
            STMT.ENTRY<AC.STE.EXCHANGE.RATE> = EXCH.RATE
            STMT.ENTRY<AC.STE.AMOUNT.LCY> = OUT.AMT
        END
    END
    IF NOT(AET.FLAG) THEN
        CONSOL.KEY = R.ACCOUNT<72>      ;* AC.CONSOL.KEY
        CONVERT '.' TO VM IN CONSOL.KEY
        CONSOL.KEY<1,2> = R.ACCOUNT<73,MKT.POS>   ;* AC.BALANCE.CCY.MKT
        CONVERT VM TO '.' IN CONSOL.KEY
        STMT.ENTRY<AC.STE.CONSOL.KEY> = CONSOL.KEY
    END
    IF AET.FLAG THEN
        STMT.ENTRY<AC.STE.CURRENCY.MARKET> = R.STMT.ENTRY<AC.STE.CURRENCY.MARKET>
        STMT.ENTRY<AC.STE.DEALER.DESK> = R.STMT.ENTRY<AC.STE.DEALER.DESK>
    END ELSE
        STMT.ENTRY<AC.STE.CURRENCY.MARKET> = R.ACCOUNT<73,MKT.POS>    ;* CI_10037072
    END

    ACTG.ENTRYS<-1> = LOWER(STMT.ENTRY)

***   Raise against ACCOUNT Currency Market   ***

    IF STMT.ENTRY<AC.STE.AMOUNT.FCY> # '' THEN
        STMT.ENTRY<AC.STE.AMOUNT.FCY> = STMT.ENTRY<AC.STE.AMOUNT.FCY> * -1
        STMT.ENTRY<AC.STE.AMOUNT.LCY> = STMT.ENTRY<AC.STE.AMOUNT.LCY> * -1
    END ELSE
        STMT.ENTRY<AC.STE.AMOUNT.LCY> = STMT.ENTRY<AC.STE.AMOUNT.LCY> * -1
    END
    STMT.ENTRY<AC.STE.CONSOL.KEY> = R.ACCOUNT<72> ;* AC.CONSOL.KEY
    STMT.ENTRY<AC.STE.CURRENCY.MARKET> = R.ACCOUNT<9>       ;* CI_10037072

    ACTG.ENTRYS<-1> = LOWER(STMT.ENTRY)
    CALL.ACC = 1

    RETURN
*---------------*
CLEAR.MKT.FIELDS:
*---------------*

    R.ACCOUNT<73> = ''        ;* AC.BALANCE.CCY.MKT
    R.ACCOUNT<74> = ''        ;* AC.MKT.ACTUAL.BAL
    R.ACCOUNT<75> = ''        ;* AC.MKT.CLEAR.BAL

    RETURN

*---------------*
ACCOUNT.CRF.TYPE:
*---------------*

    IF R.ACCOUNT<143> THEN    ;* AC.CONTINIGENT.INT
        DBTYPE = "OFFDB"
        CRTYPE = "OFFCR"
    END ELSE
        DBTYPE = "DEBIT"
        CRTYPE = "CREDIT"
    END

    BEGIN CASE
    CASE R.ACCOUNT<17>[1,1] = "S"       ;* AC.INT.NO.BOOKING

        IF R.ACCOUNT<143> THEN          ;* AC.CONTINGENT.INT
            CRF.TYPE = "OFFSUSP"
        END ELSE
            CRF.TYPE = "SUSPENS"
        END
    CASE R.ACCOUNT<23> < 0    ;* AC.OPEN.ACTUAL.BAL
        CRF.TYPE = DBTYPE
    CASE R.ACCOUNT<23> > 0    ;* AC.OPEN.ACTUAL.BAL
        CRF.TYPE = CRTYPE
    CASE 1
* get closing sign of account balance for zero balances
*
        CRF.TYPE = ''
        Y.CRF.KEY = R.ACCOUNT<72>       ;* AC.CONSOL.KEY
        Y.AC.NO = ACCOUNT.ID
        IF Y.CRF.KEY THEN
            CALL RE.GET.ACCT.SIGN(Y.CRF.KEY,Y.AC.NO,CRF.TYPE)
        END
        IF CRF.TYPE = '' THEN
            CRF.TYPE = CRTYPE
        END
    END CASE

    RETURN

*------------*
CALC.EXCHRATE:
*------------*

    OUT.CCY = LCCY
    EXCH.RATE = ""
    OUT.AMT = ""
    IN.CCY = R.ACCOUNT<8>     ;* AC.CURRENCY
    IN.AMT = STMT.ENTRY<AC.STE.AMOUNT.FCY>
    CCY.MKT = R.ACCOUNT<73,MKT.POS>     ;* AC.BALANCE.CCY.MKT
    CALL EXCHRATE(CCY.MKT, IN.CCY, IN.AMT, OUT.CCY, OUT.AMT, "", EXCH.RATE, "", "", "")

    RETURN

*------------------*
WRITE.AC.CONV.ENTRY:
*------------------*

    FN.AC.CONV.ENTRY = FN.ACCOUNT[".",1,1]:'.AC.CONV.ENTRY' ;*BG_100007803

    F.AC.CONV.ENTRY = ''
    CALL OPF(FN.AC.CONV.ENTRY,F.AC.CONV.ENTRY)

    AC.CONV.ENTRY.ID = 'ACCMKT.AC.':ACCOUNT.ID
    R.AC.CONV.ENTRY = ''

    R.AC.CONV.ENTRY = ACTG.ENTRYS

    WRITE R.AC.CONV.ENTRY ON F.AC.CONV.ENTRY,AC.CONV.ENTRY.ID         ;* BG_100007803

    RETURN
*--------------------*
CONV.ACCT.ENT.TODAY:
*--------------------*
    FN.ACCT.ENT.TODAY = 'F.ACCT.ENT.TODAY' ; F.ACCT.ENT.TODAY =''
    CALL OPF(FN.ACCT.ENT.TODAY,F.ACCT.ENT.TODAY)

    FN.STMT.ENTRY = 'F.STMT.ENTRY' ; F.STMT.ENTRY = ''
    CALL OPF(FN.STMT.ENTRY, F.STMT.ENTRY)

    R.ACCT.ENT.TODAY = '' ; ERR = '' ;  R.STMT.ENTRY = ''

    CALL F.READ(FN.ACCT.ENT.TODAY,ACCOUNT.ID,R.ACCT.ENT.TODAY, F.ACCT.ENT.TODAY, ERR)

    IF ERR THEN
        ERR = ''
        RETURN
    END

    NO.OF.ENTRIES = DCOUNT(R.ACCT.ENT.TODAY,FM)
    FOR YNO = 1 TO NO.OF.ENTRIES

        CALL F.READ(FN.STMT.ENTRY, R.ACCT.ENT.TODAY<YNO> , R.STMT.ENTRY, F.STMT.ENTRY,'')
        IF R.STMT.ENTRY<AC.STE.CURRENCY.MARKET> = R.ACCOUNT<9> THEN   ;* AC.CURRENCY.MARKET
            CONTINUE
        END
        STMT.ENTRY = ''
        AET.FLAG = 1          ;* set the flag
        GOSUB BUILD.ENTRY.ARRAY
        AET.FLAG = ''         ;* Reset the flag

    NEXT YNO

    RETURN
*---------------------------------------------------------------

CHECK.ACCT.ENT.FWD:
*-----------------*

    FN.ACCT.ENT.FWD = 'F.ACCT.ENT.FWD' ; F.ACCT.ENT.FWD =''
    CALL OPF(FN.ACCT.ENT.FWD,F.ACCT.ENT.FWD)

    CALL F.READ(FN.ACCT.ENT.FWD,ACCOUNT.ID,R.ACCT.ENT.FWD, F.ACCT.ENT.FWD, ERR)

    IF ERR THEN
        ERR = ''
    END ELSE
        ACTG.ENTRYS<-1> = 'ACCT.ENT.FWD'
        CALL.ACC = 1
    END

    RETURN

END
