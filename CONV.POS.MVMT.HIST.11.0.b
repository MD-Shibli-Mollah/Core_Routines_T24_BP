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

* Version 2 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>438</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.CurrencyPosition
      SUBROUTINE CONV.POS.MVMT.HIST.11.0
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.POS.MVMT.TODAY
*
*************************************************************************
* Add total records for each SYSTEM.ID (only for EOD records)
*
      FN.POS.MVMT.HIST = 'F.POS.MVMT.HIST'
      F.POS.MVMT.HIST = ''
      CALL OPF(FN.POS.MVMT.HIST, F.POS.MVMT.HIST)

      SEL.COM = 'SELECT ' : FN.POS.MVMT.HIST : ' WITH SYSTEM.STATUS EQ "B"'
      HIST.LIST = ''
      CALL EB.READLIST(SEL.COM, HIST.LIST, '', '', '')

      LOOP
         REMOVE HIST.ID FROM HIST.LIST SETTING H.MARK
      WHILE HIST.ID : H.MARK
         HIST.REC = ''
         READ HIST.REC FROM F.POS.MVMT.HIST, HIST.ID THEN
            YSYS.ID = HIST.REC<PSE.SYSTEM.ID>

            IF YSYS.ID = '' OR YSYS.ID[1,2] = "IC" THEN
               OUR.REF = HIST.REC<PSE.OUR.REFERENCE>

               IF OUR.REF EQ 'I&C' THEN
                  YSYS.ID = 'IC'
               END ELSE
                  YSYS.ID = HIST.REC<PSE.OUR.REFERENCE>[1,2]
               END
            END

            TOT.ID = FIELD(HIST.ID, '*', 1) : '*' : YSYS.ID : '*' : FIELD(HIST.ID, '*', 3, 999)

            READ YTOT.REC FROM F.POS.MVMT.HIST, TOT.ID ELSE YTOT.REC = ''

            YTOT.REC<PSE.TRANSACTION.CODE> = "EOD"
            YTOT.REC<PSE.POSITION.KEY> = HIST.REC<PSE.POSITION.KEY>
            YTOT.REC<PSE.COMPANY.CODE> = HIST.REC<PSE.COMPANY.CODE>
            YTOT.REC<PSE.CURRENCY> = HIST.REC<PSE.CURRENCY>
            YTOT.REC<PSE.VALUE.DATE> = HIST.REC<PSE.VALUE.DATE>
            YTOT.REC<PSE.POSITION.TYPE> = HIST.REC<PSE.POSITION.TYPE>
            YTOT.REC<PSE.CURRENCY.MARKET> = HIST.REC<PSE.CURRENCY.MARKET>
            YTOT.REC<PSE.SYSTEM.ID> = YSYS.ID
            YTOT.REC<PSE.SYSTEM.STATUS> = "C"
            YTOT.REC<PSE.OTHER.CCY> = HIST.REC<PSE.OTHER.CCY>
            YTOT.REC<PSE.DEALER.DESK> = HIST.REC<PSE.DEALER.DESK>

            YTOT.REC<PSE.AMOUNT.LCY> += HIST.REC<PSE.AMOUNT.LCY>
            YTOT.REC<PSE.AMOUNT.FCY> += HIST.REC<PSE.AMOUNT.FCY>
            YTOT.REC<PSE.OTHER.AMOUNT> += HIST.REC<PSE.OTHER.AMOUNT>

            AMT.FCY = YTOT.REC<PSE.AMOUNT.FCY>
            AMT.LCY = YTOT.REC<PSE.AMOUNT.LCY>
            AMT.OTHER = YTOT.REC<PSE.OTHER.AMOUNT>
            YCCY = YTOT.REC<PSE.CURRENCY>
            YCCY.OTHER = YTOT.REC<PSE.OTHER.CCY>
            MKT = YTOT.REC<PSE.CURRENCY.MARKET>

            IF AMT.FCY EQ 0 OR AMT.LCY EQ 0 THEN
               YTOT.REC<PSE.EXCHANGE.RATE> = ''
            END ELSE
               EXCH.RATE = ''
               CALL CALC.ERATE.LOCAL(AMT.LCY, YCCY, AMT.FCY, EXCH.RATE)
               YTOT.REC<PSE.EXCHANGE.RATE> = EXCH.RATE
            END

            IF YCCY = LCCY THEN
               SELL.AMT = ABS(AMT.LCY)
            END ELSE
               SELL.AMT = ABS(AMT.FCY)
            END

            CROSS.RATE = ''
            CALL EXCHRATE(MKT, YCCY.OTHER, ABS(AMT.OTHER), YCCY, SELL.AMT, '', CROSS.RATE, '', '', '')

            YTOT.REC<PSE.CROSS.RATE> = ABS(CROSS.RATE)
            WRITE YTOT.REC TO F.POS.MVMT.HIST, TOT.ID
         END
      REPEAT

      SEL.COM = 'SELECT ' : FN.POS.MVMT.HIST : ' WITH SYSTEM.ID EQ ""'
      HIST.LIST = ''
      CALL EB.READLIST(SEL.COM, HIST.LIST, '', '', '')

      LOOP
         REMOVE HIST.ID FROM HIST.LIST SETTING H.MARK
      WHILE HIST.ID : H.MARK
         HIST.REC = ''
         READ HIST.REC FROM F.POS.MVMT.HIST, HIST.ID THEN
            OUR.REF = HIST.REC<PSE.OUR.REFERENCE>

            IF OUR.REF EQ 'I&C' THEN
               YSYS.ID = 'IC'
            END ELSE
               YSYS.ID = HIST.REC<PSE.OUR.REFERENCE>[1,2]
            END
         END
      REPEAT

      RETURN

   END
