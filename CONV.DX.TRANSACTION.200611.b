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

* Version n dd/mm/yy  GLOBUS Release No. 200611 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-31</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Trade
      SUBROUTINE CONV.DX.TRANSACTION.200611(DX.TRANSACTION.ID,R.DX.TRANSACTION,F.DX.TRANSACTION)
* Inserts the region code in a DX.TRANSACTION record.
* Also adds it to the DX.TRADE or DX.ORDER record as appropriate.
*----------------------------------------------------------------------------------------
* 18/09/06 - BG_100012218
*            Add REGION code to DX.TRANSACTION & DXTRADE.
*
* 08/11/06 - BG_100012401
*            DEBUG statement removed.
*
* 08/12/08 - BG_100021213
*            Conversion should call journal updates
*----------------------------------------------------------------------------------------

$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.DX.EXCHANGE.MASTER
$INSERT I_F.DX.ORD.VERSION.NO
$INSERT I_F.DX.ORDER
$INSERT I_F.DX.TRADE
$INSERT I_F.DX.TRANSACTION

      GOSUB INITIALISE
      GOSUB GET.REGION.ID.FROM.EXCHANGE ; * Gets the region from the exchange
      GOSUB SET.REGION.IN.TRANSACTION ; * Sets the region in the transaction record
      GOSUB UPDATE.TRADE.RECORD ; * Update the trade with the region
      GOSUB UPDATE.ORDER.RECORDS ; * Updates all versions of the order record
      CALL JOURNAL.UPDATE("") ; * we have to call this, since run.conversion.pgms does not call journal update
      RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise variables and Open files</desc>

*... initialise the exchange id.
      DX.EXCHANGE.MASTER.ID = R.DX.TRANSACTION<DX.TX.EXCHANGE.CODE>

*... initialise the DX.TRADE or DX.ORDER ids
      IF DX.TRANSACTION.ID[1,5] EQ 'DXTRA' THEN
         DX.TRADE.ID = FIELD(DX.TRANSACTION.ID, '.', 1)
      END ELSE
         DX.TRADE.ID = ''
      END

      IF DX.TRANSACTION.ID[1,5] EQ 'DXORD' THEN
         DX.ORDER.PREFIX = FIELD(DX.TRANSACTION.ID, '.', 1)
      END ELSE
         DX.ORDER.PREFIX = ''
      END

*... To hold the trade
      REGION.ID = ''
      R.DX.TRADE = ''

*... open files
      FN.DX.EXCHANGE.MASTER = 'F.DX.EXCHANGE.MASTER'
      F.DX.EXCHANGE.MASTER = ''
      CALL OPF(FN.DX.EXCHANGE.MASTER,F.DX.EXCHANGE.MASTER)

      IF DX.TRADE.ID THEN
         FN.DX.TRADE = 'F.DX.TRADE'
         F.DX.TRADE = ''
         CALL OPF(FN.DX.TRADE,F.DX.TRADE)
      END

      IF DX.ORDER.PREFIX THEN
         FN.DX.ORDER = 'F.DX.ORDER'
         F.DX.ORDER = ''
         CALL OPF(FN.DX.ORDER,F.DX.ORDER)
         FN.DX.ORD.VERSION.NO = 'F.DX.ORD.VERSION.NO'
         F.DX.ORD.VERSION.NO = ''
         CALL OPF(FN.DX.ORD.VERSION.NO,F.DX.ORD.VERSION.NO)
      END

      RETURN

*** </region>

*-----------------------------------------------------------------------------

*** <region name= GET.REGION.ID.FROM.EXCHANGE>
GET.REGION.ID.FROM.EXCHANGE:
*** <desc>Gets the region from the exchange</desc>
      CALL CACHE.READ('F.DX.EXCHANGE.MASTER',DX.EXCHANGE.MASTER.ID,R.DX.EXCHANGE.MASTER,YERR)
      REGION.ID = R.DX.EXCHANGE.MASTER<DX.EM.REGION>
      RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= SET.REGION.IN.TRANSACTION>
SET.REGION.IN.TRANSACTION:
*** <desc>Sets the region in the transaction record</desc>
      IF REGION.ID THEN
         R.DX.TRANSACTION<DX.TX.REGION> = REGION.ID
      END
      RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= UPDATE.TRADE.RECORD>
UPDATE.TRADE.RECORD:
*** <desc>Updates the trade with the region</desc>
      IF DX.TRADE.ID AND REGION.ID THEN
         CALL CACHE.READ(FN.DX.TRADE, DX.TRADE.ID, R.DX.TRADE, YERR)
         IF NOT(YERR) THEN
            IF R.DX.TRADE<DX.TRA.REGION> NE REGION.ID THEN
               R.DX.TRADE<DX.TRA.REGION> = REGION.ID
               CALL F.WRITE(FN.DX.TRADE, DX.TRADE.ID, R.DX.TRADE)
            END
         END
      END
      RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= UPDATE.ORDER.RECORDS>
UPDATE.ORDER.RECORDS:
*** <desc>Updates all versions of the order record</desc>
      IF DX.ORDER.PREFIX AND REGION.ID THEN
         DX.ORD.VERSION.NO.ID = DX.ORDER.PREFIX
         CALL CACHE.READ(FN.DX.ORD.VERSION.NO, DX.ORD.VERSION.NO.ID, R.DX.ORD.VERSION.NO, YERR)
         IF NOT(YERR) THEN
            LATEST.VERSION.NO = FIELD(R.DX.ORD.VERSION.NO<DX.OVNO.LATEST.ID>, '-', 2)
            IF NUM(LATEST.VERSION.NO) THEN
               FOR THIS.VERSION.NO = LATEST.VERSION.NO TO 0
                  DX.ORDER.ID = DX.ORDER.PREFIX :'-':THIS.VERSION.NO
                  GOSUB UPDATE.ORDER.RECORD
               NEXT THIS.VERSION.NO
            END
         END
      END
      RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= UPDATE.ORDER.RECORD>
UPDATE.ORDER.RECORD:
*** <desc>Update a single order record with the region</desc>
      CALL CACHE.READ(FN.DX.ORDER, DX.ORDER.ID, R.DX.ORDER, YERR)
      IF NOT(YERR) THEN
         IF R.DX.ORDER<DX.ORD.REGION> NE REGION.ID THEN
            R.DX.ORDER<DX.ORD.REGION> = REGION.ID
            CALL F.WRITE(FN.DX.ORDER, DX.ORDER.ID, R.DX.ORDER)
         END
      END
      RETURN
*** </region>

*fin

   END
