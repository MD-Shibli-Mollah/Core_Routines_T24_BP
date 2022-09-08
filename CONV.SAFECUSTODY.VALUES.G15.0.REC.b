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

*
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScfConfig
      SUBROUTINE CONV.SAFECUSTODY.VALUES.G15.0.REC(ID,R.RECORD,F.YFILE)
*-----------------------------------------------------------------------------
* Conversion details record routine to change the PERFORM.ACCRUAL field from
* YES to MONTHLY
*-----------------------------------------------------------------------------
* Modification History:
*
* 27/04/04 - GLOBUS_BG_10002210
*            New routine
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE

      NO.VMS = DCOUNT(R.RECORD<25>,VM)
      FOR VM.CNT = 1 TO NO.VMS
         IF R.RECORD<25,VM.CNT> = 'YES' THEN
            R.RECORD<25,VM.CNT> = 'MONTHLY'
         END
      NEXT VM.CNT

      RETURN

END
