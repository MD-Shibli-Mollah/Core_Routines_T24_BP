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

* Version 6 28/03/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>171</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.Contract
      SUBROUTINE CONV.DRAW.PROVISION(DR.ID, R.DR, F.DR)

$INSERT I_COMMON
$INSERT I_EQUATE

      EQU TF.DR.DRAW.CURRENCY TO 2
      EQU TF.DR.DOCUMENT.AMOUNT TO 3
      EQU TF.DR.DRAWDOWN.ACCOUNT TO 17
      EQU TF.DR.FULLY.UTILISED TO 85
      EQU TF.DR.PROV.AMT.REL TO 103
      EQU TF.DR.PROV.EXCH.RATE TO 133
      EQU TF.DR.COVERED.AMOUNT TO 134
      EQU TF.DR.PROV.REL.LC.CCY TO 161
      EQU TF.DR.PROV.REL.DOC.CCY TO 162
      EQU TF.DR.DATE.TIME TO 176

      EQU TF.LC.LC.CURRENCY TO 20
      EQU TF.LC.CURRENCY.MARKET TO 24
      EQU TF.LC.PROVIS.PERCENT TO 144
      EQU TF.LC.PROVIS.ACC TO 142
      EQU TF.LC.CREDIT.PROVIS.ACC TO 157

      EQU AC.CURRENCY TO 8
      EQU EB.CUR.MID.REVAL.RATE TO 14
      EQU EB.CUR.CURRENCY.MARKET TO 12

      R.LC = ''
      YERR = ''
      F.LC = ''
      FN.LC = 'F.LETTER.OF.CREDIT'
      CALL OPF(FN.LC, F.LC)
      LC.ID = DR.ID[1,12]

      CALL F.READ(FN.LC, LC.ID, R.LC, F.LC, YERR)
      IF YERR THEN
         PRINT "CANNOT FILE THE LC RECORD ":LC.ID
         GOTO PROG.ABORT
      END

      IF NOT(R.LC<TF.LC.PROVIS.ACC>) THEN RETURN

      FU.FLG = R.DR<TF.DR.FULLY.UTILISED>
      DOC.CCY = R.DR<TF.DR.DRAW.CURRENCY>
      REIMB.AC = R.DR<TF.DR.DRAWDOWN.ACCOUNT>

      LC.CCY = R.LC<TF.LC.LC.CURRENCY>
      MKT.CCY = R.LC<TF.LC.CURRENCY.MARKET>
      CRPRO.AC = R.LC<TF.LC.CREDIT.PROVIS.ACC>
      DBPRO.AC = R.LC<TF.LC.PROVIS.ACC>
      PRO.PCT = R.LC<TF.LC.PROVIS.PERCENT>
      PRO.DOC.CCY = R.DR<TF.DR.DOCUMENT.AMOUNT> * PRO.PCT/100
      COVER.AMT = R.DR<TF.DR.PROV.AMT.REL>
      PRO.CCY = ''
      PRO.LC.CCY = ''                    ; *GB0100892
      CALL DBR("ACCOUNT":FM:AC.CURRENCY, CRPRO.AC, PRO.CCY)

      XCCY = LC.CCY
      GOSUB GET.HISTORIC.RATE
      LC.LOCAL.RATE = XRATE

      XCCY = PRO.CCY
      GOSUB GET.HISTORIC.RATE
      PRO.LOCAL.RATE = XRATE

      IF LC.LOCAL.RATE > PRO.LOCAL.RATE AND PRO.LOCAL.RATE < 1 THEN
         XCH.RATE = PRO.LOCAL.RATE / LC.LOCAL.RATE
      END ELSE
         XCH.RATE = LC.LOCAL.RATE * PRO.LOCAL.RATE
      END
      CALL EXCHRATE(MKT.CCY, PRO.CCY, PROV.AMT.REL, LC.CCY,
         PRO.LC.CCY, "", XCH.RATE, "", "", YRET)

      *// Start updating DRAWINGS record
      CALL EB.ROUND.AMOUNT(PRO.CCY, COVER.AMT, "1", "")
      R.DR<TF.DR.COVERED.AMOUNT> = COVER.AMT
      CALL EB.ROUND.AMOUNT(DOC.CCY, PRO.DOC.CCY, "1", "")
      R.DR<TF.DR.PROV.REL.DOC.CCY> = PRO.DOC.CCY
      CALL EB.ROUND.AMOUNT(LC.CCY, PRO.LC.CCY, "1", "")
      R.DR<TF.DR.PROV.REL.LC.CCY> = PRO.LC.CCY
      R.DR<TF.DR.PROV.EXCH.RATE> = XCH.RATE
      RETURN
*
GET.HISTORIC.RATE:
      XRATE = ''
*      IF R.DR<TF.DR.DATE.TIME>[1,2] = '00' THEN
*         DOC.TXN.DATE = "20":R.DR<TF.DR.DATE.TIME>[1,6]
*      END ELSE
*         DOC.TXN.DATE = "19":R.DR<TF.DR.DATE.TIME>[1,6]
*      END
*      CCY.REC = ''
*      CALL GET.CCY.HISTORY(DOC.TXN.DATE, XCCY, CCY.REC, CCY.RET)
*      LOCATE MKT.CCY IN CCY.REC<EB.CUR.CURRENCY.MARKET,1> SETTING CPOS THEN
*         XRATE = CCY.REC<EB.CUR.MID.REVAL.RATE, CPOS>
*      END
      RETURN
*
PROG.ABORT:
      RETURN TO PROG.ABORT
      RETURN
   END
