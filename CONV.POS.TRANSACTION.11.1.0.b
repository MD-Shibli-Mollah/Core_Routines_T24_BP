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

* Version 3 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>200</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.CurrencyPosition
      SUBROUTINE CONV.POS.TRANSACTION.11.1.0(POS.ID, POS.RECORD, POS.FILE)
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.FOREX
$INSERT I_F.POS.TRANSACTION
*
*************************************************************************
* Fill new CURRENCY.MARKET and old DEALER.DESK field
*
      NEW.MARKET = ''
      NEW.DESK = ''

      IF TRIM(POS.ID)[1,2] = 'FX' THEN
         CALL DBR("FOREX":FM:FX.CURRENCY.MARKET, TRIM(POS.ID)[1,12], NEW.MARKET)
         CALL DBR("FOREX":FM:FX.DEALER.DESK, TRIM(POS.ID)[1,12], NEW.DESK)
         ETEXT = ""                      ; * GB0001250
      END ELSE
         SEC.PART = FIELD(POS.ID, '-', 2)
         NEW.MARKET = SEC.PART[1, 1]
         NEW.DESK = SEC.PART[4, 2]
      END

      IF NOT(NEW.DESK) THEN NEW.DESK = '0'
      IF NOT(NEW.MARKET) THEN NEW.MARKET = '1'

      IF NUM(NEW.DESK) AND (LEN(NEW.DESK) < 2) THEN
         NEW.DESK = '0' : NEW.DESK
      END

      POS.RECORD<POS.TXN.DEALER.DESK> = NEW.DESK
      POS.RECORD<POS.TXN.CURRENCY.MARKET> = NEW.MARKET

      RETURN

   END
