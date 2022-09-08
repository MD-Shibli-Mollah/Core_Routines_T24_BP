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
* <Rating>142</Rating>
*-----------------------------------------------------------------------------
* Version 2 22/05/01  GLOBUS Release No. 200508 30/06/05
*********************************************************************
    $PACKAGE MD.Contract
      SUBROUTINE CONV.MD.BEN.G10(ID,R.RECORD,FN.FILE)
*********************************************************************
*
** 15/06/99 - GB9900813
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.MD.DEAL
*
** This routine builds the MD.BENEFICIARY file
** for existing deals. It selects the MD.DEAL
** file, and updates the MD.BENEFICIARY file for
** the BENEF.CUST.1 field.
*
* Establish file type i.e. LIVE, NAU or HIS

      FILE.SUFFIX = FIELD(FN.FILE,'$',2)

* Do nothing if file is found to be NAU OR HIS.

      IF FILE.SUFFIX NE '' THEN

      END ELSE

* If file is LIVE, process if deal 'status' is not mature.

         IF R.RECORD<36> = 'MAT' OR R.RECORD <36> = 'LIQ' THEN

* NB - All fields on the record = referenced via field
* NUMBER, as opposed to field NAME, as this is a CONVERSION routine.

         END ELSE

* If there is input to the BENEF.CUST.1 field on the
* MD.DEAL file, then read in, and update,
* the MD.BENEFICIARY file.

            BENEF.NO = R.RECORD<20>

* 'BENEF.NO' = the BENEF.CUST.1 field on the MD RECORD.

            IF BENEF.NO NE '' THEN

               FN.MD.BENEF = 'F.MD.BENEFICIARY'
               F.MD.BENEF = ''

               CALL OPF(FN.MD.BENEF,F.MD.BENEF)

               R.MD.BENEF = ''
               ER = ''

               CALL F.READ(FN.MD.BENEF,BENEF.NO,R.MD.BENEF,F.MD.BENEF,ER)

               LOCATE ID IN R.MD.BENEF<1> BY 'AR' SETTING POS ELSE NULL

               INS ID BEFORE R.MD.BENEF<POS>

               WRITE R.MD.BENEF TO F.MD.BENEF,BENEF.NO

            END
         END
      END

      RETURN

   END
