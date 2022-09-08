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

* Version 3 15/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>894</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoFoundation
      SUBROUTINE CONV.EXCH.RATES.8809
*
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.CURRENCY
$INSERT I_F.DATES
$INSERT I_F.COMPANY
*
      F.SC.VAL.EXCH.RATES = ''
      CALL OPF('F.SC.VAL.EXCH.RATES',F.SC.VAL.EXCH.RATES)
*
      THIS.MONTH = TODAY[5,2]
      FOR I = 1 TO 12
         THIS.MONTH -= 1
         IF THIS.MONTH LE 0 THEN THIS.MONTH += 12
         THIS.MONTH = FMT(THIS.MONTH,'2"0"R')
*
         SELECT F.CURRENCY
*
         RATES.ARRAY = ''
         R.CCY.KEYS = ''
         LOOP
            READNEXT K.CURRENCY ELSE NULL
         WHILE K.CURRENCY DO
            R.CURRENCY = '' ; ETEXT = ''
            CALL F.READ('F.CURRENCY',K.CURRENCY,R.CURRENCY,F.CURRENCY,ETEXT)
            IF ETEXT THEN E = 'RECORD & NOT FOUND ON FILE &':FM:K.CURRENCY:VM:'F.CURRENCY' ; GOTO FATAL
*
            MID.REVAL.RATE = R.CURRENCY<EB.CUR.MID.REVAL.RATE>
            LOCATE '1' IN R.CURRENCY<EB.CUR.CURRENCY.MARKET,1> SETTING MRK.POS ELSE NULL
            MID.RATE = MID.REVAL.RATE<1,MRK.POS>
*
            IF MID.RATE = '' THEN MID.RATE = 1
            RATES.ARRAY<1,-1> = MID.RATE
            R.CCY.KEYS<1,-1> = K.CURRENCY
*
         REPEAT
*
         IF R.CCY.KEYS THEN
            RECORD = ''
            RECORD<1> = R.CCY.KEYS
            RECORD<2> = RATES.ARRAY
*
            READ R.DUMMY FROM F.SC.VAL.EXCH.RATES, THIS.MONTH:R.COMPANY(EB.COM.LOCAL.CURRENCY) ELSE
               WRITE RECORD TO F.SC.VAL.EXCH.RATES,THIS.MONTH:R.COMPANY(EB.COM.LOCAL.CURRENCY)
            END
         END
*
*
* GENERATE CROSS RATES FOR ALL OTHER CURRENCIES
*
*
         ALL.CCY = R.CCY.KEYS
         COUNT.CCY = COUNT(R.CCY.KEYS,VM) + (R.CCY.KEYS # '')
         LOOP UNTIL ALL.CCY<1> = '' DO
*
            CCY1 = ALL.CCY<1,1>
            RECORD = ''
            FOR X = 1 TO COUNT.CCY
               CCY2 = R.CCY.KEYS<1,X>
               GOSUB CONVERT.AMTS
*
               RECORD<1,-1> = CCY2
               RECORD<2,-1> = XCHANGE
*
            NEXT X
*
            READ R.DUMMY FROM F.SC.VAL.EXCH.RATES, THIS.MONTH:CCY1 ELSE
               WRITE RECORD TO F.SC.VAL.EXCH.RATES,THIS.MONTH:CCY1
            END
            DEL ALL.CCY<1,1>
*
         REPEAT
*
*
      NEXT I
*
*
      RETURN
*---------------
CONVERT.AMTS:
*---------------
*
      E="" ; ETEXT="" ; RET.CODE=""
      Y3 = '' ; Y5 = '' ; LOCAL.EQUIVALENT = ''
      AMT.1 = '' ; AMT.2 = '' ; XCHANGE = '' ; CCY.MKT = 1
      IF CCY1 # CCY2 THEN
         CALL EXCHRATE(CCY.MKT,CCY1,AMT.1,CCY2,AMT.2,Y3,XCHANGE,Y5,LOCAL.EQUIVALENT,RET.CODE)
         IF ETEXT > "" THEN
            E=ETEXT
            GOTO FATAL
         END
      END ELSE XCHANGE = 1
      RETURN
*
*
FATAL:
      BATCH.DETAILS<1> = 0
      BATCH.DETAILS<2> = E
      TEXT = E
      CALL FATAL.ERROR(' CONV.EXCH.RATES.8809')
*
   END
