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
* <Rating>-72</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Accounting
    SUBROUTINE CONV.DX.TRANS.BALANCES.R7(DX.TRANS.BAL.ID,R.DX.TRANS.BAL,F.DX.TRANS.BALANCES)
*-----------------------------------------------------------------------------
*Deletes the DX.TRANS.BALANCES record if id does not have a corresponding RE.CONTRACT.BALANCES record.
*Otherwise it corrects the CRF types and reposts the entries.
*-----------------------------------------------------------------------------

*** <region name= INSERT>
*** <desc>Inserts </desc>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DX.TRANS.BALANCES
    $INSERT I_F.DX.TRANSACTION
*** </region>

    GOSUB INITIALISE          ;*Initialise variables and Open files.
    GOSUB PROCESS.RECORD      ;*Conversion processing.

    RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise variables and Open files. </desc>
*The number of events to check.
    NUM.OF.EVENTS = DCOUNT(R.DX.TRANS.BAL<DX.BAL.EVENT.DATE>, VM)

*Has there been a problem reading DX.TRANSACTION?
    TX.READ.ERROR = ''

*Initialise the transaction id.
    DX.TRANSACTION.ID = ''

*Open files.

    FN.DX.TRANSACTION = 'F.DX.TRANSACTION'
    F.DX.TRANSACTION = ''
    CALL OPF(FN.DX.TRANSACTION,F.DX.TRANSACTION)

    FN.RE.CONTRACT.BALANCES = 'F.RE.CONTRACT.BALANCES'
    F.RE.CONTRACT.BALANCES = ''
    CALL OPF(FN.RE.CONTRACT.BALANCES,F.RE.CONTRACT.BALANCES)

    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS.RECORD>
PROCESS.RECORD:
*** <desc>Conversion processing. </desc>

    R.RE.CONTRACT.BALANCES = ''
    YERR = ''
    CALL F.READ(FN.RE.CONTRACT.BALANCES,DX.TRANS.BAL.ID,R.RE.CONTRACT.BALANCES,F.RE.CONTRACT.BALANCES,YERR)
    IF YERR THEN
*If there is no corresponding RE.CONTRACT.BALANCES record then delete this record.
        CALL F.DELETE(F.DX.TRANS.BALANCES, DX.TRANS.BAL.ID)
    END ELSE
*Correct the CRF types.
        GOSUB CORRECT.CRF.TYPES         ;*Correct the CRF types.
*Reverse DXOPTBUY, DXOPTSELL, DXFUTBUY and DXFUTSELL.. and repost with CR or DB appended to CRF type
*also reverse DXUOVDB and repost as DXUOVDB.
        CALL CONV.POST.CR.DB.ENTRIES(DX.TRANS.BAL.ID, R.DX.TRANS.BAL, F.DX.TRANS.BALANCES)
    END

    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= CORRECT.CRF.TYPES>
CORRECT.CRF.TYPES:
*** <desc>Correct the CRF types. </desc>

*Itterate through all events.
    FOR EVENT.NUM = 1 TO NUM.OF.EVENTS

*Assign related set of variables.
        TRANS.EVENT = R.DX.TRANS.BAL<DX.BAL.TRANS.EVENT, EVENT.NUM>
        EVENT.DATE = R.DX.TRANS.BAL<DX.BAL.EVENT.DATE, EVENT.NUM>
        EVENT.POST = R.DX.TRANS.BAL<DX.BAL.EVENT.POST, EVENT.NUM>
        EVENT.CRFTYP = R.DX.TRANS.BAL<DX.BAL.EVENT.CRFTYP, EVENT.NUM>

*The two possibilities that we are checking for is when the CRF type is either null or DXUOV and should not be.
        BEGIN CASE
        CASE EVENT.CRFTYP EQ ''
            GOSUB GET.CORRECT.CRF.TYPE  ;*Rebuilds the CRF type based on the transaction type.
        CASE EVENT.CRFTYP[1,5] EQ 'DXUOV' AND TRANS.EVENT NE 'UO'
*Should be a CI type with wrong CRF type.
            GOSUB GET.CORRECT.CRF.TYPE
        END CASE
    NEXT EVENT.NUM

    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= GET.CORRECT.CRF.TYPE>
GET.CORRECT.CRF.TYPE:
*** <desc>Rebuilds the CRF type based on the transaction type. </desc>
    IF NOT(DX.TRANSACTION.ID) THEN
        DX.TRANSACTION.ID = R.DX.TRANS.BAL<DX.BAL.TRANSACTION.ID>
        CALL CACHE.READ('F.DX.TRANSACTION', DX.TRANSACTION.ID,R.DX.TRANSACTION, TX.READ.ERROR)
    END
    IF NOT(TX.READ.ERROR) THEN
*This is a DX application.
        CRF.TYPE = 'DX'
        IF TRANS.EVENT EQ 'UO' THEN
*UO events are handled here.
            CRF.TYPE := 'UOV'
            IF R.DX.TRANSACTION<DX.TX.UOPT.PANDL.REF.CCY> LT 0 THEN
*Debit CRF type.
                CRF.TYPE := 'DB'
            END ELSE
*Credit CRF type.
                CRF.TYPE := 'CR'
            END
        END ELSE
*All other events are handled this way.
            IF R.DX.TRANSACTION<DX.TX.CALL.PUT> NE "" THEN
*It is an Option.
                CRF.TYPE := "OPT"
            END ELSE
*It is a Future
                CRF.TYPE := "FUT"
            END

            IF R.DX.TRANSACTION<DX.TX.BUY.SELL> = "BUY" THEN
*It is a Buy.
                CRF.TYPE := "BUY"
            END ELSE
*It is a Sell.
                CRF.TYPE := "SELL"
            END
        END
*The only real update is CRF.TYPE but might as well make sure that everything aligns.
        R.DX.TRANS.BAL<DX.BAL.TRANS.EVENT, EVENT.NUM> = TRANS.EVENT
        R.DX.TRANS.BAL<DX.BAL.EVENT.DATE, EVENT.NUM> = EVENT.DATE
        R.DX.TRANS.BAL<DX.BAL.EVENT.POST, EVENT.NUM> = EVENT.POST
        R.DX.TRANS.BAL<DX.BAL.EVENT.CRFTYP, EVENT.NUM> = CRF.TYPE
    END

    RETURN
*** </region>
END
