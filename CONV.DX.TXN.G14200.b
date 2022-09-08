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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Trade
SUBROUTINE CONV.DX.TXN.G14200(DX.TXN.ID,R.TXN.REC,YFILE)

$INSERT I_COMMON
$INSERT I_EQUATE

      ID.CONV.DETAILS = "CONV.DX.TXN.G14005"
      R.CONV.DETAILS.140 = ''
      ER1 = ''
      CALL CACHE.READ('F.CONVERSION.DETAILS',ID.CONV.DETAILS,R.CONV.DETAILS.140,ER1)

      ID.CONV.DETAILS = "CONV.DX.TXN.G14102"
      R.CONV.DETAILS.141 = ''
      ER2 = ''
      CALL CACHE.READ('F.CONVERSION.DETAILS',ID.CONV.DETAILS,R.CONV.DETAILS.141,ER2)

      IF NOT(R.CONV.DETAILS.140) AND NOT(R.CONV.DETAILS.141) THEN
          INS "" BEFORE R.TXN.REC<50>
          INS "" BEFORE R.TXN.REC<51>
      END

  RETURN
END
