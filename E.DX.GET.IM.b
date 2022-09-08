* @ValidationCode : MjotMTUxNTE4MDk2NDpjcDEyNTI6MTU0Mjc3ODQ1MzM4NDprYXJ0aGlrZXlhbmthbmRhc2FteTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MDcuMjAxODA2MjEtMDIyMTotMTotMQ==
* @ValidationInfo : Timestamp         : 21 Nov 2018 11:04:13
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : karthikeyankandasamy
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201807.20180621-0221
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 3 02/06/00  GLOBUS Release No. 200512 09/12/05
*-----------------------------------------------------------------------------
* <Rating>-80</Rating>
*-----------------------------------------------------------------------------
$PACKAGE DX.ModelBank
SUBROUTINE E.DX.GET.IM(RETURN.ARRAY)
*-----------------------------------------------------------------------------
* Program Description : Get Initial Margin for DX.EXCH.IM Enquiry
*-----------------------------------------------------------------------------
* Modification History :
*
* 22/02/07 - EN_10003209
*            Use DAS
*
* 21/08/08 - BG_100019614 - aleggett@temenos.com
*            Convert CACHE.READs and CACHE.DBRs for non-parameter tables to F.READs
*            Cache should only be used for small tables of static data.  Overuse of
*            cache adversely affects system performance.
*
* 04/06/15 - EN-1322379 / Tak-1328842
*            Incorporation of DX_ModelBank
** 01/11/18 -  Enhancement:2822501 Task: 2829280
*             Componentization - II - Private Wealth
*--------------------------------------------------------------------------

    $USING DX.Trade
    $USING DX.Revaluation
    $USING DX.Position
    $USING EB.Reports
    $USING DX.Foundation
    $USING EB.DataAccess
*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB MAIN.PROCESS

RETURN

*-----------------------------------------------------------------------------
INITIALISE:

* Local variables

    NUM.EXCHANGES = 0
    NUM.PORTFOLIOS = 0
    PORT.LIST = ''
    EXCH.NO = ''
    EXCH.IM.CCY = ''
    EXCH.IM.AMT = ''

    OPCODES = EB.Reports.getDLogicalOperands()

* Translate Operand Codes into Operands

    SELECTION.OPRTRS = ''
    NUM.OPCODES = DCOUNT(OPCODES,@FM)
    FOR OPCODE.NO = 1 TO NUM.OPCODES
        OPCODE = OPCODES<OPCODE.NO>
        SELECTION.OPRTRS<OPCODE.NO> = EB.Reports.getOperandList()<OPCODE>
    NEXT OPCODE.NO

    SELECTION.FIELDS = EB.Reports.getDFields()
    SELECTION.VALUES = EB.Reports.getDRangeAndValue()

* Get list of all ids in DX.REP.POSITION

    DX.REP.POSITION.LIST.LOCAL = EB.DataAccess.dasAllId
    THE.ARGS = ''
    FILE.SUFFIX = ''
    EB.DataAccess.Das('DX.REP.POSITION', DX.REP.POSITION.LIST.LOCAL, THE.ARGS, FILE.SUFFIX)

RETURN

*-----------------------------------------------------------------------------
MAIN.PROCESS:

    LOOP
        REMOVE DX.REP.POSITION.ID FROM DX.REP.POSITION.LIST.LOCAL SETTING DX.REP.POSITION.MARK
    WHILE DX.REP.POSITION.ID : DX.REP.POSITION.MARK

        R.DX.REP.POSITION = ''
        YERR = ''

        R.DX.REP.POSITION = DX.Position.RepPosition.Read(DX.REP.POSITION.ID, YERR)
* Before incorporation : CALL F.READ(tmp.FN.DX.REP.POSITION,DX.REP.POSITION.ID,R.DX.REP.POSITION,tmp.F.DX.REP.POSITION,YERR) ; * BG_100019614 S/E


        VALID = @FALSE
        ID.LOCAL = DX.REP.POSITION.ID
        REF.APP = 'DX.REP.POSITION'

* Check that DX.REP.POSITION record matches enquiry selection criteria

        DX.Foundation.EbEnqCheckCriteria(ID.LOCAL,REF.APP,SELECTION.FIELDS,SELECTION.OPRTRS,SELECTION.VALUES,VALID)

        IF VALID THEN

* Get Customer and List of Exchanges

            CUSTOMER = R.DX.REP.POSITION<DX.Position.RepPosition.RpCustomer>

            PORTFOLIO = R.DX.REP.POSITION<DX.Position.RepPosition.RpPortfolio>
            LOCATE PORTFOLIO IN PORT.LIST BY 'AR' SETTING PORT.POS ELSE
                INS PORTFOLIO BEFORE PORT.LIST<PORT.POS>
                NUM.PORTFOLIOS += 1
            END

            EXCHANGE.CODE = R.DX.REP.POSITION<DX.Position.RepPosition.RpExchangeCode>
            LOCATE EXCHANGE.CODE IN EXCH.NO BY 'AR' SETTING EXCH.POS ELSE
                INS EXCHANGE.CODE BEFORE EXCH.NO<EXCH.POS>
                NUM.EXCHANGES += 1
            END

        END

    REPEAT

    GOSUB GET.EXCHANGE.DATA

    GOSUB SORT.DATA

RETURN

*-----------------------------------------------------------------------------
GET.EXCHANGE.DATA:

* Get Initial Margin data for customer from each exchange

    FOR PORT.POS = 1 TO NUM.PORTFOLIOS
        FOR EXCH.POS = 1 TO NUM.EXCHANGES
            PORTFOLIO = PORT.LIST<PORT.POS>
            EXCH.CODE = EXCH.NO<EXCH.POS>
            DX.RV.LAST.CUST.UPDATE.ID = PORTFOLIO:"*":EXCH.CODE
            R.DX.RV.LAST.CUST.UPDATE = ''
            YERR = ''
            R.DX.RV.LAST.CUST.UPDATE = DX.Revaluation.RvLastCustUpdate.Read(DX.RV.LAST.CUST.UPDATE.ID, YERR) ; * BG_100019614 S/E
* Before incorporation : CALL F.READ(FN.DX.RV.LAST.CUST.UPDATE,DX.RV.LAST.CUST.UPDATE.ID,R.DX.RV.LAST.CUST.UPDATE,F.DX.RV.LAST.CUST.UPDATE,YERR) ; * BG_100019614 S/E

            IF NOT(YERR) THEN
                DX.TRANSACTION.ID = R.DX.RV.LAST.CUST.UPDATE
                GOSUB EXTRACT.DATA
            END
        NEXT EXCH.POS
    NEXT PORT.POS

RETURN

*-----------------------------------------------------------------------------
EXTRACT.DATA:

* Store the totals for each exchange, per currency

    LOCATE EXCH.CODE IN EXCH.NO BY 'AR' SETTING EXCH.POS THEN
        R.DX.TRANSACTION = DX.Trade.Transaction.Read(DX.TRANSACTION.ID, YERR) ; * BG_100019614 S/E
* Before incorporation : CALL F.READ(FN.DX.TRANSACTION,DX.TRANSACTION.ID,R.DX.TRANSACTION,F.DX.TRANSACTION,YERR) ; * BG_100019614 S/E
        IF NOT(YERR) THEN
            DX.REVALUE.SUMMARY.ID = R.DX.TRANSACTION<DX.Trade.Transaction.TxSourceId>:"*":CUSTOMER
            R.DX.REVALUE.SUMMARY = DX.Revaluation.RevalueSummary.Read(DX.REVALUE.SUMMARY.ID, YERR) ; * BG_100019614 S/E
* Before incorporation : CALL F.READ(FN.DX.REVALUE.SUMMARY,DX.REVALUE.SUMMARY.ID,R.DX.REVALUE.SUMMARY,F.DX.REVALUE.SUMMARY,YERR) ; * BG_100019614 S/E
            CCY = R.DX.REVALUE.SUMMARY<DX.Revaluation.RevalueSummary.RvsCurrency>
            AMT = R.DX.REVALUE.SUMMARY<DX.Revaluation.RevalueSummary.RvsInitialMargin>
            LOCATE CCY IN EXCH.IM.CCY<EXCH.POS,1> BY 'AL' SETTING EXCY.POS THEN
                EXCH.IM.AMT<EXCH.POS> += AMT
            END ELSE
                INS CCY BEFORE EXCH.IM.CCY<EXCH.POS,EXCY.POS>
                INS AMT BEFORE EXCH.IM.AMT<EXCH.POS,EXCY.POS>
            END
        END
    END

RETURN

*-----------------------------------------------------------------------------
SORT.DATA:

* Sort data for output to enquiry in order of currency then exchange

    RETURN.ARRAY = ''
    SORTING.ARRAY = ''
    NUM.EXCHANGES = DCOUNT(EXCH.NO,@FM)
    FOR EXCH.POS = 1 TO NUM.EXCHANGES
        EXCH = EXCH.NO<EXCH.POS>
        NUM.EXCYS = DCOUNT(EXCH.IM.CCY<EXCH.POS>,@VM)
        FOR EXCY.POS = 1 TO NUM.EXCYS
            CCY = EXCH.IM.CCY<EXCH.POS,EXCY.POS>
            AMT = EXCH.IM.AMT<EXCH.POS,EXCY.POS>
            DATASTRING = EXCH:"*":CCY:"*":AMT
            SORTSTRING = FMT(EXCH.POS,'R%4'):FMT(EXCY.POS,'R%4')
            LOCATE SORTSTRING IN SORTING.ARRAY BY 'AR' SETTING POS ELSE
                INS SORTSTRING BEFORE SORTING.ARRAY<POS>
                INS DATASTRING BEFORE RETURN.ARRAY<POS>
            END
        NEXT EXCY.POS
    NEXT EXCH.POS

RETURN
*-----------------------------------------------------------------------------
*
END
