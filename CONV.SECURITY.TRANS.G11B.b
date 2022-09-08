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

* Version 7 16/05/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>237</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoSecurityPositionUpdate
      SUBROUTINE CONV.SECURITY.TRANS.G11B(ID,YREC,FILE)
**************************************************************************
* 13/05/2003 - GLOBUS_CI_10008894
*              CONVERSION.DETAIL Program should have field numbers
*              instead of field names
*
* 23/06/2004 - GLOBUS_CI_10020807
*              Correction done in previous pif CI_10008894
*
* 03/08/04 - CI_10021794
*            Entire routine has been re-written to do the following
*
* 1.         Book.cost and gross book cost in base currency is derived
*            from the  trade currency using the exchange rate in field EXCH.RATE.TRD.BASE

* 2.         Book.cost and gross book cost in reference currency is derived
*            from the base currency using the exchange rate in field EXCH.RATE.BASE.REF

* 3.         Book cost in security currency is dervied from base currency
*            using EXCH.RATE.SEC.BASE

* 4.         Previously, Profit and loss in reference ccy is derived
*            directly from profit and loss in sec ccy. Now changes have been made to
*            calculate profit and loss in reference ccy from the
*            base currency using the field EXCH.RATE.BASE.REF

**************************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.SC.TRANS.TYPE
*
      F.SECURITY.TRANS = ''
      FN.SECURITY.TRANS = 'F.SECURITY.TRANS'
      CALL OPF(FN.SECURITY.TRANS,F.SECURITY.TRANS)
*
      K.SECURITY.TRANS = ID
      R.SECURITY.TRANS = YREC
      IF NOT(YREC) THEN
         E = 'RECORD & NOT FOUND ON FILE & ' :FM:K.SECURITY.TRANS:VM:'F.SECURITY.TRANS'
         GOTO FATAL.ERROR
      END
*
      BOOK.COST.SEC = 0 ; BOOK.COST.REF = 0 ; BOOK.COST.BSE = 0
      GR.COST.SEC.CCY = 0 ; GR.COST.REF.CCY = 0 ; GR.COST.BSE.CCY = 0
*

      SEC.BOOK.COST = R.SECURITY.TRANS<32> - R.SECURITY.TRANS<24>
      REF.BOOK.COST = R.SECURITY.TRANS<32> - R.SECURITY.TRANS<24>
      BASE.BOOK.COST = R.SECURITY.TRANS<32> - R.SECURITY.TRANS<24>
*
      GR.SEC.BOOK.COST = R.SECURITY.TRANS<19>
      GR.REF.BOOK.COST = R.SECURITY.TRANS<20>
      GR.BASE.BOOK.COST = R.SECURITY.TRANS<20>
*
      TRD.CCY = R.SECURITY.TRANS<15>
      REF.CCY = R.SECURITY.TRANS<36>

      BSE.CCY = LCCY
*
      BOOK.COST.SEC = SEC.BOOK.COST
      GR.COST.SEC.CCY = GR.SEC.BOOK.COST
*
* CALC FOR BASE CURRENCY
*-----------------------
      IF BSE.CCY NE TRD.CCY THEN
         EXCHANGE = '' ; DIFF = '' ; LCY.AMT = '' ; RTN.CODE = '' ; CCY.MKT = 1 ; BASE.CCY = ''
         CCY1 = TRD.CCY
         CCY2 = BSE.CCY
         AMT1 = BASE.BOOK.COST
         AMT2 = ''
         EXCHANGE = R.SECURITY.TRANS<38>
         CALL EXCHRATE(CCY.MKT,CCY1,AMT1,CCY2,AMT2,BASE.CCY,EXCHANGE,DIFF,LCY.AMT,RTN.CODE)
         BOOK.COST.BSE = AMT2
*
         DIFF = '' ; LCY.AMT = '' ; RTN.CODE = '' ; CCY.MKT = 1 ; BASE.CCY = ''
         AMT1 = GR.BASE.BOOK.COST
         AMT2 = ''
         CALL EXCHRATE(CCY.MKT,CCY1,AMT1,CCY2,AMT2,BASE.CCY,EXCHANGE,DIFF,LCY.AMT,RTN.CODE)
         GR.COST.BSE.CCY = AMT2
      END ELSE
         BOOK.COST.BSE = BASE.BOOK.COST
         GR.COST.BSE.CCY = GR.BASE.BOOK.COST
      END
* CALC FOR REFERENCE.CURRENCY
*----------------------------
      IF BSE.CCY NE REF.CCY THEN
         EXCHANGE = '' ; DIFF = '' ; LCY.AMT = '' ; RTN.CODE = '' ; CCY.MKT = 1 ; BASE.CCY = ''
         CCY1 = BSE.CCY
         CCY2 = REF.CCY
         AMT1 = BOOK.COST.BSE
         AMT2 = ''
         EXCHANGE = R.SECURITY.TRANS<40>
         CALL EXCHRATE(CCY.MKT,CCY1,AMT1,CCY2,AMT2,BASE.CCY,EXCHANGE,DIFF,LCY.AMT,RTN.CODE)
         BOOK.COST.REF = AMT2
*
         DIFF = '' ; LCY.AMT = '' ; RTN.CODE = '' ; CCY.MKT = 1 ; BASE.CCY = ''
         AMT1 = GR.COST.BSE.CCY
         AMT2 = ''
         CALL EXCHRATE(CCY.MKT,CCY1,AMT1,CCY2,AMT2,BASE.CCY,EXCHANGE,DIFF,LCY.AMT,RTN.CODE)
         GR.COST.REF.CCY = AMT2
      END ELSE
         BOOK.COST.REF = BOOK.COST.BSE
         GR.COST.REF.CCY = GR.COST.BSE.CCY
      END
*
* CALCULATION FOR BOOK COST IN SEC CCY
*
      SEC.CCY = R.SECURITY.TRANS<13>
      IF SEC.CCY NE BSE.CCY THEN
         EXCHANGE = '' ; DIFF = '' ; LCY.AMT = '' ; RTN.CODE = '' ; CCY.MKT = 1 ; BASE.CCY = ''
         CCY1 = SEC.CCY
         CCY2 = BSE.CCY
         AMT1 = ''
         AMT2 = BOOK.COST.BSE
         EXCHANGE = R.SECURITY.TRANS<37>
         CALL EXCHRATE(CCY.MKT,CCY1,AMT1,CCY2,AMT2,BASE.CCY,EXCHANGE,DIFF,LCY.AMT,RTN.CODE)
         BOOK.COST.SEC = AMT1
      END ELSE
         BOOK.COST.SEC = BOOK.COST.BSE
      END

*
      DR.CODE = "" ; CR.CODE = "" ; TRANS.KEY = ""
      CALL DBR("SC.TRA.CODE":FM:SC.TRN.SECURITY.DR.CODE:FM:".A",R.SECURITY.TRANS<11>,TRANS.KEY)      ; * CI_10019774

      CALL DBR("SC.TRANS.TYPE":FM:SC.TRN.SECURITY.DR.CODE:FM:".A",TRANS.KEY,DR.CODE)
      CALL DBR("SC.TRANS.TYPE":FM:SC.TRN.SECURITY.CR.CODE:FM:".A",TRANS.KEY,CR.CODE)
*

      IF R.SECURITY.TRANS<11> = CR.CODE THEN
         R.SECURITY.TRANS<69> = BOOK.COST.SEC
         R.SECURITY.TRANS<70> = BOOK.COST.REF
         R.SECURITY.TRANS<71> = BOOK.COST.BSE
*
         R.SECURITY.TRANS<72> = GR.COST.SEC.CCY
         R.SECURITY.TRANS<73> = GR.COST.REF.CCY
         R.SECURITY.TRANS<74> = GR.COST.BSE.CCY
      END ELSE
         R.SECURITY.TRANS<69> = BOOK.COST.SEC * (-1)
         R.SECURITY.TRANS<70> = BOOK.COST.REF * (-1)
         R.SECURITY.TRANS<71> = BOOK.COST.BSE * (-1)
*
         R.SECURITY.TRANS<72> = GR.COST.SEC.CCY * (-1)
         R.SECURITY.TRANS<73> = GR.COST.REF.CCY * (-1)
         R.SECURITY.TRANS<74> = GR.COST.BSE.CCY * (-1)
*
      END

*
      PROF.LOSS.REF = 0

      IF R.SECURITY.TRANS<49> AND R.SECURITY.TRANS<49> NE '0.00' THEN
         IF BSE.CCY NE REF.CCY THEN
            EXCHANGE = '' ; DIFF = '' ; LCY.AMT = '' ; RTN.CODE = '' ; CCY.MKT = 1 ; BASE.CCY = ''
            CCY1 = BSE.CCY
            CCY2 = REF.CCY
            AMT1 = R.SECURITY.TRANS<49>
            AMT2 = ''
            EXCHANGE = R.SECURITY.TRANS<40>
            CALL EXCHRATE(CCY.MKT,CCY1,AMT1,CCY2,AMT2,BASE.CCY,EXCHANGE,DIFF,LCY.AMT,RTN.CODE)
            PROF.LOSS.REF = AMT2
         END ELSE
            PROF.LOSS.REF = R.SECURITY.TRANS<49>
         END
      END
      R.SECURITY.TRANS<75> = PROF.LOSS.REF

*
      YREC = R.SECURITY.TRANS
*
GET.NEXT:
      RETURN
FATAL.ERROR:
      RETURN
   END
