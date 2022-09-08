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
* <Rating>-22</Rating>
*-----------------------------------------------------------------------------
*
    $PACKAGE DX.Fees
      SUBROUTINE CONV.DX.COMMISSION.R08.200712(DX.COMMISSION.ID,R.DX.COMMISSION,FN.DX.COMMISSION)
*-----------------------------------------------------------------------------
* Template record routine, to be used as a basis for building a RECORD.ROUTINE
* to be run as part of the CONVERSION.DETAILS record.
*
* Conversion of DX.COMMISSION
*
* Removes extra multivalue from corrupted model bank record ---100322
*
*-----------------------------------------------------------------------------
* Modification History:
*
* 15/01/2008 - BG_100016290 - aleggett@temenos.com
*              Created
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE

      IF DX.COMMISSION.ID = "---100322" THEN
         GOSUB EQUATE.FIELDS
         GOSUB AMEND.FIELD.DATA
      END

      RETURN
      
*-----------------------------------------------------------------------------
EQUATE.FIELDS:

* Equate field numbers to position manually, do no use $INSERT

      EQU payRecieveFldPos TO 8
      EQU checkAgainstField TO 9

      RETURN

*-----------------------------------------------------------------------------
AMEND.FIELD.DATA:

* Strip out excess multivalues from field in error.

      actualFieldCount = DCOUNT(R.DX.COMMISSION<checkAgainstField>,VM)
      payRecieveFldCnt = DCOUNT(R.DX.COMMISSION<payRecieveFldPos>,VM)

      IF payRecieveFldCnt GT actualFieldCount THEN

         newFldContent = ''
         FOR fldno = 1 TO actualFieldCount
            newFldContent<1,fldno> = R.DX.COMMISSION<payRecieveFldPos,fldno>
         NEXT fldno

         R.DX.COMMISSION<payRecieveFldPos> = newFldContent

      END

      RETURN

*-----------------------------------------------------------------------------
   END
