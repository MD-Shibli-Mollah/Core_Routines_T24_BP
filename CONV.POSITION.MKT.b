* @ValidationCode : Mjo2MTQ5NDM5Njg6Q3AxMjUyOjE2MTY2NTA0NTA3MzQ6c2l2YXJhbmphbmltOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDguMjAyMDA3MzEtMTE1MTotMTotMQ==
* @ValidationInfo : Timestamp         : 25 Mar 2021 11:04:10
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sivaranjanim
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version :  DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 1 13/04/00  GLOBUS Release No. G14.0.00 03/07/03
*-----------------------------------------------------------------------------
* <Rating>-43</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.CurrencyPosition
SUBROUTINE CONV.POSITION.MKT(ACCOUNT.ID,R.ACCOUNT)
*-----------------------------------------------------------------------------
* Mutli-threaded Close of Business routine
*
* Raise position entries to move the currency market to the account market.
*
*-----------------------------------------------------------------------------
* Modification History:
*
* 23/01/08 - CI_10053396 / CI_10053456
*            New routine
*
* 15/03/21 - Defect 4275895 / Task 4285406
*            PACS00925110-NDF Revaluation reversals from Wrong Account on Switch off of Revaluation Booking.
*
*----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_EOD.AC.CONV.ENTRY.COMMON
    $INSERT I_F.ACCOUNT
    $INSERT I_F.STMT.ENTRY
*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB READ.AEF
    IF R.ACCT.ENT.FWD # '' THEN
        GOSUB PROCESS.AEF
    END

RETURN

*------------------------------------------------------------------------------
*
INITIALISE:
*---------*

    R.ACCT.ENT.FWD = ''
    ID.NEW = ACCOUNT.ID

RETURN

*-----------------------------------------------------------------------------
*
READ.AEF:
*-------*

    R.ACCT.ENT.FWD = '' ; ERR = ''

    CALL F.READ(FN.ACCT.ENT.FWD,ID.NEW,R.ACCT.ENT.FWD, F.ACCT.ENT.FWD, ERR)

RETURN

*------------------------------------------------------------------------------
*
PROCESS.AEF:
*----------*

    YNO = DCOUNT(R.ACCT.ENT.FWD,FM)

    FOR I = 1 TO YNO

        STMT.ENTRY.ID = R.ACCT.ENT.FWD<I>
        IF STMT.ENTRY.ID[1,1] = 'F' THEN
            CONTINUE
        END
        CALL F.READ(FN.STMT.ENTRY, STMT.ENTRY.ID , R.STMT.ENTRY, F.STMT.ENTRY,'')
        IF R.STMT.ENTRY<AC.STE.CURRENCY.MARKET> = R.ACCOUNT<9> THEN   ;* AC.CURRENCY.MARKET
            CONTINUE
        END

        IF R.STMT.ENTRY<AC.STE.AMOUNT.FCY> THEN
            YR.ENTRY = R.STMT.ENTRY
            YR.ENTRY<AC.STE.AMOUNT.FCY> = R.STMT.ENTRY<AC.STE.AMOUNT.FCY> * -1
            YR.ENTRY<AC.STE.AMOUNT.LCY> = R.STMT.ENTRY<AC.STE.AMOUNT.LCY> * -1
            GOSUB LOAD.POSITION

* Repost against account currency market
            YR.ENTRY = R.STMT.ENTRY
            YR.ENTRY<AC.STE.CURRENCY.MARKET> = R.ACCOUNT<9>
            GOSUB LOAD.POSITION

        END

    NEXT I

RETURN

*---------------------------------------------------------------------------------
*
LOAD.POSITION:
*------------*

    IF YR.ENTRY<AC.STE.AMOUNT.FCY> NE "" THEN     ;* We have a foreign entry
        IF NOT(YR.ENTRY<AC.STE.RECORD.STATUS> = "REVE" AND YR.ENTRY<AC.STE.REVERSAL.MARKER> = "") THEN        ;* No call req
            AMOUNT.1 = YR.ENTRY<AC.STE.AMOUNT.FCY>
            AMOUNT.2 = YR.ENTRY<AC.STE.AMOUNT.LCY> * -1
            CURRENCY.1 = YR.ENTRY<AC.STE.CURRENCY>
            CURRENCY.2 = LCCY
            LOCAL.CCY.1 = YR.ENTRY<AC.STE.AMOUNT.LCY>
            LOCAL.CCY.2 = AMOUNT.2
            CCY.MKT = YR.ENTRY<AC.STE.CURRENCY.MARKET>
            VALUE.DATE = YR.ENTRY<AC.STE.VALUE.DATE>
            SYSTEMID = YR.ENTRY<AC.STE.SYSTEM.ID>
            NARRATIVE = ""
            NARRATIVE<1,2> = SYSTEMID
            IF YR.ENTRY<AC.STE.OUR.REFERENCE> # '' THEN
                OUR.REF = YR.ENTRY<AC.STE.OUR.REFERENCE>
            END ELSE
                OUR.REF = YR.ENTRY<AC.STE.TRANS.REFERENCE>
            END

            RETURN.CODE = ""
*
            CALL CURRENCY.POSITION ("","","",
            YR.ENTRY<AC.STE.DEPARTMENT.CODE>,
            YR.ENTRY<AC.STE.COMPANY.CODE>,
            "TR","TR","00",CCY.MKT,
            CURRENCY.1 , CURRENCY.2 ,
            AMOUNT.1 , AMOUNT.2 ,
            VALUE.DATE,
            VALUE.DATE,
            OUR.REF,
            "",
            LOCAL.CCY.1,
            LOCAL.CCY.2,
            NARRATIVE,"",
            RETURN.CODE)
*
        END
    END


RETURN
