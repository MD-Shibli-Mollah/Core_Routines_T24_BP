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

* Version 3 02/06/00  GLOBUS Release No. G11.0.00 29/06/00
*-----------------------------------------------------------------------------
* <Rating>-167</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Accounting
    SUBROUTINE CONV.POST.CR.DB.ENTRIES(ID.DX.TRANS.BALANCES, R.DX.TRANS.BALANCES, FN.DX.TRANS.BALANCES)
*-----------------------------------------------------------------------------
* Program Description
*
* Originally written as CONV.DX.TRANS.BALANCES.G131 to back out all
* DXOPTBUY, DXOPTSELL, DXFUTBUY and DXFUTSEL and repost with a CR or DB
* appended depending on the value.
* Modified to call CONV.GEN.UOV.CORRECTION.ENTRIES and post with the
* correct transaction code 'NEW' or 'UOV'.
*-----------------------------------------------------------------------------
* Modification History :
*
* 4-03-08 - RTC 11177
*           Files that are converted twice in a conversion pgms record.
*
* 20/07/12 - Defect 416776 / Task 446861
*            During conversion the system posting the entries with improper CONSOL.KEY.
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DX.TRANS.BALANCES
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.DX.TRANSACTION
    $INSERT I_F.DX.EVENT.TYPE
*-----------------------------------------------------------------------------

    GOSUB INITIALISE

    NO.TRANS.EVENTS = DCOUNT(R.DX.TRANS.BALANCES<DX.BAL.TRANS.EVENT>,VM)
    THIS.TRANS.EVENT = 1

* Get the transaction information.

    ID.DX.TRANSACTION = R.DX.TRANS.BALANCES<DX.BAL.TRANSACTION.ID>
    R.DX.TRANSACTION = ''
    YERR = ''
    CALL F.READ(FN.DX.TRANSACTION,ID.DX.TRANSACTION,R.DX.TRANSACTION,F.DX.TRANSACTION,YERR)

    ID.DX.TRADE = FIELD(ID.DX.TRANSACTION,'.', 1)

    IDS.KEY = ID.DX.TRANS.BALANCES:"*":ID.DX.TRANSACTION:"*":ID.DX.TRADE
* IDS.KEY will hold the ids of DX.TRANS.BALANCES, DX.TRANSACTION & DX.TRADE which is used for generating
* CONSOL.KEY.

    MAT R.DX.TRADE = ""
    YERR = ''

    SIZE = C$SYSDIM
    CALL F.MATREAD(FN.DX.TRADE, ID.DX.TRADE ,MAT R.DX.TRADE,SIZE,F.DX.TRADE,YERR)

    LOOP WHILE THIS.TRANS.EVENT <= NO.TRANS.EVENTS DO

        TRANSACTION.CODE = "???????????????????"
        REVERSAL = @FALSE

        THIS.EVENT = R.DX.TRANS.BALANCES<DX.BAL.TRANS.EVENT,THIS.TRANS.EVENT>
        THIS.CRFTYP = R.DX.TRANS.BALANCES<DX.BAL.EVENT.CRFTYP,THIS.TRANS.EVENT>
        LAST.TWO.CHARS = THIS.CRFTYP[2]
        IF THIS.EVENT = "UO" THEN
            * DO NOTHING
        END ELSE
            * We need to process any other entry and assign a CR or DB to the key
            IF LAST.TWO.CHARS MATCHES CREDIT:VM:RIGHT.SUFFIX THEN     ;* BG_100017373 -S/E
                * DO NOTHING, this has already been converted
            END ELSE
                GOSUB PROCESS.EVENT     ;* Process the current event entry and generate the appropriate accounting entries
            END

        END
        THIS.TRANS.EVENT += 1 ;* Increment to move to the next trans event
    REPEAT
    UOV.ENTRIES = ''
    CALL CONV.GEN.UOV.CORRECTION.ENTRIES(ID.DX.TRANS.BALANCES, R.DX.TRANS.BALANCES, FN.DX.TRANS.BALANCES, UOV.ENTRIES)
    IF UOV.ENTRIES THEN
        FULL.ENTRY.LIST<-1> = UOV.ENTRIES
    END
    IF FULL.ENTRY.LIST # '' THEN

        ID.NEW = THIS.OUR.REF
        V = DX.BAL.CONSOL.KEY
        MAT R.NEW = MAT R.DX.TRADE

        CALL EB.ACCOUNTING("DX", "SAO", FULL.ENTRY.LIST, @FALSE)

    END




    RETURN

*-----------------------------------------------------------------------------
INITIALISE:
    FN.DX.TRANSACTION = 'F.DX.TRANSACTION'
    F.DX.TRANSACTION = ''
    CALL OPF(FN.DX.TRANSACTION,F.DX.TRANSACTION)

    FN.DX.TRADE = 'F.DX.TRADE'
    F.DX.TRADE = ''
    CALL OPF(FN.DX.TRADE,F.DX.TRADE)

    FN.DX.EVENT.TYPE = 'F.DX.EVENT.TYPE'
    F.DX.EVENT.TYPE = ''
    CALL OPF(FN.DX.EVENT.TYPE,F.DX.EVENT.TYPE)

    FULL.ENTRY.LIST = ""

    DIM R.DX.TRADE(C$SYSDIM)

    CREDIT = "CR"
    DEBIT  = "DR"   ;* BG_100017373 - S
    RIGHT.SUFFIX = 'DB'       ;* BG_100017373 - E

    REVERSAL.EVENTS = "CS":VM:"CC":VM:"CD":VM:"CR"

    RETURN

*-----------------------------------------------------------------------------
*

*-----------------------------------------------------------------------------

*** <region name= PROCESS.EVENT>
PROCESS.EVENT:
*** <desc>Process the current event entry and generate the appropriate accounting entries</desc>

* THIS.EVENT = R.DX.TRANS.BALANCES<DX.BAL.TRANS.EVENT,THIS.TRANS.EVENT> ; Setup outside the routine
    FROM.AMOUNT = R.DX.TRANS.BALANCES<DX.BAL.EVENT.POST,THIS.TRANS.EVENT>
    FROM.CCY = R.DX.TRANS.BALANCES<DX.BAL.CURRENCY>
    TO.CCY   = LCCY

    GOSUB CCY.CONVERT         ;* Convert CCY Amts

    THIS.FROM.AMOUNT = FROM.AMOUNT
    THIS.TO.AMOUNT = TO.AMT

    CALL EB.ROUND.AMOUNT(LCCY,THIS.TO.AMOUNT,"","")

    THIS.AMOUNT = THIS.TO.AMOUNT * -1
    THIS.AMOUNT.FCY = FROM.AMOUNT * -1
    THIS.EXCHRATE = EXCHANGE.RATE
    THIS.FROM.CCY = FROM.CCY

    THIS.CRFTYP = R.DX.TRANS.BALANCES<DX.BAL.EVENT.CRFTYP,THIS.TRANS.EVENT>
    THIS.CRB.MAT = R.DX.TRANS.BALANCES<DX.BAL.CRB.MATURITY>
    THIS.VALUE.DATE = R.DX.TRANS.BALANCES<DX.BAL.EVENT.DATE,THIS.TRANS.EVENT>
    THIS.CUSTOMER = R.DX.TRANS.BALANCES<DX.BAL.CUSTOMER>
    THIS.NARRATIVE = "Correction Entry - "
    THIS.DAO = R.DX.TRANSACTION<DX.TX.DEPT.ACCT.OFFICER>
    THIS.CATEGORY = R.DX.TRANS.BALANCES<DX.BAL.PRODUCT.CAT>
    THIS.OUR.REF = ID.DX.TRANS.BALANCES
    THIS.TRANS.REF = ID.DX.TRADE
    THIS.CONSOL.KEY = R.DX.TRANS.BALANCES<DX.BAL.CONSOL.KEY>

    GOSUB REVERSE.OLD.ENTRY   ;* Reverse the old CRF entry

    GOSUB POST.NEW.ENTRY      ;* Post the new CRF entry with the adapted CRFTYP

    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= RAISE.ENTRY>
RAISE.ENTRY:
*** <desc>Raise a basic stub accounting entry.</desc>
    ENTRY = ""
*
    ENTRY<AC.STE.ACCOUNT.NUMBER> = ""
    ENTRY<AC.STE.COMPANY.CODE> = ID.COMPANY
    ENTRY<AC.STE.AMOUNT.LCY> = THIS.AMOUNT
    ENTRY<AC.STE.TRANSACTION.CODE> = TRANSACTION.CODE
    ENTRY<AC.STE.THEIR.REFERENCE> = THIS.CUSTOMER
    ENTRY<AC.STE.NARRATIVE> = THIS.NARRATIVE:R.DX.EVENT.TYPE<DX.ET.DESCRIPTION>
    ENTRY<AC.STE.PL.CATEGORY> = ""
    ENTRY<AC.STE.CUSTOMER.ID> = THIS.CUSTOMER
    ENTRY<AC.STE.ACCOUNT.OFFICER> = THIS.DAO
    ENTRY<AC.STE.PRODUCT.CATEGORY> = THIS.CATEGORY
    ENTRY<AC.STE.VALUE.DATE> = THIS.VALUE.DATE
    ENTRY<AC.STE.CURRENCY> = THIS.FROM.CCY
    ENTRY<AC.STE.AMOUNT.FCY> = THIS.AMOUNT.FCY
    ENTRY<AC.STE.EXCHANGE.RATE> = THIS.EXCHRATE
    ENTRY<AC.STE.POSITION.TYPE> = "TR"  ;* TEMP
    ENTRY<AC.STE.OUR.REFERENCE> = THIS.OUR.REF
    ENTRY<AC.STE.CURRENCY.MARKET> = "1" ;* TEMP
    ENTRY<AC.STE.DEPARTMENT.CODE> = THIS.DAO
    ENTRY<AC.STE.TRANS.REFERENCE> = THIS.TRANS.REF
    ENTRY<AC.STE.SYSTEM.ID> = "DX"
    ENTRY<AC.STE.BOOKING.DATE> = TODAY

    ENTRY<AC.STE.CRF.TYPE> = THIS.CRFTYP
    ENTRY<AC.STE.CRF.TXN.CODE> = "NEW"
    ENTRY<AC.STE.CRF.MAT.DATE> = THIS.CRB.MAT
    ENTRY<AC.STE.CONTRACT.BAL.ID> = IDS.KEY
    ENTRY<AC.STE.CONSOL.KEY> = THIS.CONSOL.KEY
    IF REVERSAL THEN
        ENTRY<AC.STE.REVERSAL.MARKER> = "R"
    END

    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= GENERATE.NEW.CRF.TYPE>
GENERATE.NEW.CRF.TYPE:
*** <desc>Generates the new crf type from the current one, and include the CR/DB component.</desc>

    FIRST.CRFTYP = R.DX.TRANS.BALANCES<DX.BAL.EVENT.CRFTYP,1>
    IF THIS.CRFTYP = "" OR LAST.TWO.CHARS EQ 'DR' THEN      ;* BG_100017373 - S
        IF LAST.TWO.CHARS MATCHES CREDIT:@VM:DEBIT THEN
            FIRST.CRFTYP = FIRST.CRFTYP[1,LEN(FIRST.CRFTYP)-2]        ;* BG_100017373 - E
        END
        THIS.CRFTYP = FIRST.CRFTYP
    END

    BASIC.EVENTS = "CI":@VM:"SR"

    IF (THIS.AMOUNT + 0) > 0 THEN
        * This is a credit, unless a reversal entry is being passed or a reversal of a settlement(which is a reversal of a reversal)
        * Amount is +ve
        IF THIS.EVENT MATCHES BASIC.EVENTS THEN
            * Its a credit
            THIS.CRFTYP := CREDIT
        END ELSE
            * Its a debit
            THIS.CRFTYP := RIGHT.SUFFIX ;* BG_100017373 - S/E
        END

    END ELSE
        * This is a credit, unless a reversal entry is being passed or a reversal of a settlement(which is a reversal of a reversal)
        * Amount is -ve
        IF THIS.EVENT MATCHES BASIC.EVENTS THEN
            * Its a debit
            THIS.CRFTYP := RIGHT.SUFFIX ;* BG_100017373 - S/E
        END ELSE
            * Its the reversal of a debit
            THIS.CRFTYP := CREDIT
        END

    END

    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= GENERATE.TRANSACTON.CODE>
GENERATE.TRANSACTON.CODE:
*** <desc>Generates the TRANSACTION.CODE from the DX.EVENT.TYPE</desc>
* THIS.EVENT = R.DX.TRANS.BALANCES<DX.BAL.TRANS.EVENT,THIS.TRANS.EVENT> ; Setup outside the routine

    ID.DX.EVENT.TYPE = THIS.EVENT

    R.DX.EVENT.TYPE = ''
    YERR = ''
    CALL F.READ(FN.DX.EVENT.TYPE,ID.DX.EVENT.TYPE,R.DX.EVENT.TYPE,F.DX.EVENT.TYPE,YERR)

    IF REVERSAL THEN
        IF THIS.AMOUNT+0 > 0 THEN
            TRANSACTION.CODE = R.DX.EVENT.TYPE<DX.ET.DR.TRANSACTION>
        END ELSE
            TRANSACTION.CODE = R.DX.EVENT.TYPE<DX.ET.CR.TRANSACTION>
        END
    END ELSE
        IF THIS.AMOUNT+0 > 0 THEN
            TRANSACTION.CODE = R.DX.EVENT.TYPE<DX.ET.CR.TRANSACTION>
        END ELSE
            TRANSACTION.CODE = R.DX.EVENT.TYPE<DX.ET.DR.TRANSACTION>
        END
    END


    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= REVERSE.OLD.ENTRY>
REVERSE.OLD.ENTRY:
*** <desc>Reverse the old CRF entry</desc>
    REVERSAL = @TRUE
    GOSUB GENERATE.TRANSACTON.CODE      ;* Generates the TRANSACTION.CODE from the DX.EVENT.TYPE

    GOSUB RAISE.ENTRY         ;* Raise a basic stub accounting entry.

    FULL.ENTRY.LIST<-1> = LOWER(ENTRY)
    GOSUB GENERATE.UNIQUE.BAL.KEY

    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= POST.NEW.ENTRY>
POST.NEW.ENTRY:
*** <desc>Post the new CRF entry with the adapted CRFTYP</desc>
    REVERSAL = @FALSE

    GOSUB GENERATE.TRANSACTON.CODE      ;* Generates the TRANSACTION.CODE from the DX.EVENT.TYPE

    THIS.EXCHRATE = EXCHANGE.RATE

    GOSUB GENERATE.NEW.CRF.TYPE         ;* Generates the new crf type from the current one, and include the CR/DB component.

    GOSUB GENERATE.UNIQUE.BAL.KEY

    R.DX.TRANS.BALANCES<DX.BAL.EVENT.POST,THIS.TRANS.EVENT> = THIS.AMOUNT
    R.DX.TRANS.BALANCES<DX.BAL.EVENT.CRFTYP,THIS.TRANS.EVENT> = THIS.CRFTYP
    R.DX.TRANS.BALANCES<11,THIS.TRANS.EVENT> = UNQ.BAL.KEY


    GOSUB RAISE.ENTRY

    FULL.ENTRY.LIST<-1> = LOWER(ENTRY)

    RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= CCY.CONVERT>
CCY.CONVERT:
*** <desc>Convert CCY Amts</desc>
    O.CCY.BUY = TO.CCY
    O.CCY.SELL = FROM.CCY
    O.SELL.AMOUNT = FROM.AMOUNT

    CCY.MKT = "1"
    CCY.BUY = TO.CCY
    TO.AMT = ""
    CCY.SELL = FROM.CCY
    SELL.AMT = FROM.AMOUNT+0
    BASE.CCY = ""
    EXCHANGE.RATE = ""
    DIFFERENCE =""
    LCY.AMT = ""
    RETURN.CODE = ""

    CALL EXCHRATE(CCY.MKT,CCY.BUY,TO.AMT,CCY.SELL,SELL.AMT,BASE.CCY,EXCHANGE.RATE,DIFFERENCE,LCY.AMT,RETURN.CODE)
    RETURN.CODE = RETURN.CODE<1>
    IF RETURN.CODE = 'ERR' OR ETEXT # '' OR E # '' THEN
        E = " DX.RTN.CANT.SET.EXCH.RATE":FM:O.CCY.BUY:VM:O.CCY.SELL:VM:O.SELL.AMOUNT
    END
    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= GENERATE.UNIQUE.BAL.KEY>

GENERATE.UNIQUE.BAL.KEY:

*** <desc>Generate a unique balance key to ensure were not double positing anything to the DX.TRANS.BALANCES file.</desc>

    UNQ.KEY = FIELD(ID.DX.TRANS.BALANCES,".",1)
    REVERSAL = 0
    IF THIS.EVENT[1,2] MATCHES REVERSAL.EVENTS THEN
        REVERSAL = 1
    END

    UNQ.BAL.KEY = UNQ.KEY:"/":THIS.EVENT[1,2]:"/":THIS.CRFTYP:"/":TODAY:"/":REVERSAL:"/COR"

    RETURN

*** </region>


    END
