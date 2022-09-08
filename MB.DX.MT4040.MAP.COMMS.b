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
* <Rating>-77</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.ModelBank
    SUBROUTINE MB.DX.MT4040.MAP.COMMS(MAT HANDOFF.REC,ERR.MSG)
*-----------------------------------------------------------------------------
* This routine is attached to the mapping record of message 4040 on DX
* In the 9th position of the handoff record the commission details are returned
*
* Modification History:
* ---------------------
* 10/12/13 - Defect-851756 / Task-862025
*            Commission during settlement is displayed in the closeout message
*
* 04/06/15 - EN-1322379 / Tak-1328842
*            Incorporation of DX_ModelBank
*
*-----------------------------------------------------------------------------
* $INSERT I_COMMON
* $INSERT I_EQUATE  ;* Not Used anymore  ;* Not Used anymore
* $INSERT I_F.DX.TRANSACTION  ;* Not Used anymore  ;* Not Used anymore
* $INSERT I_F.DX.CLOSEOUT  ;* Not Used anymore
    $USING DX.Trade
    $USING DX.Closeout

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN

INITIALISE:
*----------
* Initialisation of variables and Open files

    TRANS.POS = ''
    TRANS.ID.LIST = ''        ;*List of transaction references involved in closeout
    INC.CNTR = 1    ;*Incremental counter

    RETURN

PROCESS:
*-------
* Transactions with commission posting as settlement are alone to be updated in handoff record
    TRANS.ID.LIST = HANDOFF.REC(5)<DX.Closeout.Closeout.CoTransId> ;*List of transactions involved in closeout process
    LOOP
        REMOVE DX.TRANS.ID FROM TRANS.ID.LIST SETTING TRANS.POS
    WHILE DX.TRANS.ID : TRANS.POS
        R.TRANS.REC = DX.Trade.Transaction.Read(DX.TRANS.ID, TRANS.ERR)
        * Before incorporation : CALL F.READ(FN.DX.TRANSACTION, DX.TRANS.ID, R.TRANS.REC, F.DX.TRANSACTION, TRANS.ERR)
        COMM.POST = R.TRANS.REC<DX.Trade.Transaction.TxChargeDate> ;*Commission posting time
        IF COMM.POST EQ 'SETTLEMENT' THEN
            GOSUB GET.COMMISSION.DETAILS
            INC.CNTR += 1 ;*Counter variable incremented to update each transaction information with multi-value
        END
    REPEAT

    RETURN

GET.COMMISSION.DETAILS:
*----------------------
* Commission information is updated in mutivalue-set for all the trades involved in closeout
* As the commissions are multivalue set by itself in a transaction the information is converted to sub-value

    HANDOFF.REC(9)<1,INC.CNTR> = R.TRANS.REC<DX.Trade.Transaction.TxSourceId>         ;*Trade reference
    HANDOFF.REC(9)<2,INC.CNTR> = LOWER(R.TRANS.REC<DX.Trade.Transaction.TxCommTyp>)   ;*Commission type
    HANDOFF.REC(9)<3,INC.CNTR> = LOWER(R.TRANS.REC<DX.Trade.Transaction.TxCommCde>)   ;*Commission code
    HANDOFF.REC(9)<4,INC.CNTR> = LOWER(R.TRANS.REC<DX.Trade.Transaction.TxCommCcy>)   ;*Commission currency
    GOSUB CHK.PRORATA         ;*Calculate commission for closed lots
    HANDOFF.REC(9)<5,INC.CNTR> = LOWER(R.TRANS.REC<DX.Trade.Transaction.TxCommAmt>)   ;*Commission amount
    HANDOFF.REC(9)<6,INC.CNTR> = LOWER(R.TRANS.REC<DX.Trade.Transaction.TxCaccAmt>)   ;*Commission amount in account currency
    HANDOFF.REC(9)<7,INC.CNTR> = LOWER(R.TRANS.REC<DX.Trade.Transaction.TxCommTax>)   ;*Tax on commission amount
    HANDOFF.REC(9)<8,INC.CNTR> = LOWER(R.TRANS.REC<DX.Trade.Transaction.TxCommAcc>)   ;*Commission account
    HANDOFF.REC(9)<9,INC.CNTR> = LOWER(R.TRANS.REC<DX.Trade.Transaction.TxCaccCcy>)   ;*Commission account currency
    HANDOFF.REC(9)<10,INC.CNTR> = LOWER(R.TRANS.REC<DX.Trade.Transaction.TxCommExc>)  ;*Exchange rate
    HANDOFF.REC(9)<11,INC.CNTR> = R.TRANS.REC<DX.Trade.Transaction.TxChargeDate>      ;*Commission post time

    RETURN

CHK.PRORATA:
*-----------
* Calculate the commission based on the closed lots
* Find the number of commisions involved in trade
    CNTR = 0
    CNTR = DCOUNT(R.TRANS.REC<DX.Trade.Transaction.TxCommAmt>,@VM)          ;*Count the different commissions available

* Find the number of closeouts involved and consider the latest closeout updated
    PTR = 0
    PTR = DCOUNT(R.TRANS.REC<DX.Trade.Transaction.TxTrasettlots>,@VM)
    PROPORTION.CLOSED = R.TRANS.REC<DX.Trade.Transaction.TxTrasettlots,PTR> / R.TRANS.REC<DX.Trade.Transaction.TxOriginalLots>       ;*Lots for which commission beeds to be calculated

* Calculate the commission amount and tax on commission for the closed lots
    FOR I = 1 TO CNTR
        R.TRANS.REC<DX.Trade.Transaction.TxCommAmt,I> = R.TRANS.REC<DX.Trade.Transaction.TxCommAmt,I> * PROPORTION.CLOSED
        R.TRANS.REC<DX.Trade.Transaction.TxCaccAmt,I> = R.TRANS.REC<DX.Trade.Transaction.TxCaccAmt,I> * PROPORTION.CLOSED
        R.TRANS.REC<DX.Trade.Transaction.TxCommTax,I> = R.TRANS.REC<DX.Trade.Transaction.TxCommTax,I> * PROPORTION.CLOSED
    NEXT I

    RETURN

*-----------------------------------------------------------------------------

    END
