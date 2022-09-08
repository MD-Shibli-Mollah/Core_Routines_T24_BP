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
* <Rating>-3</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PD.Config
      SUBROUTINE CONV.PD.PARAMETER.G12.2(PDP.ID,PD.RECORD,F.PD.PARAMETER)

* This Conversion routine is to convert all the PD.PARAMETER records
* which are of AC category and to the format of AC-Category.

$INSERT I_COMMON
$INSERT I_EQUATE

      IF LEN(PDP.ID) = '4' AND NUM(PDP.ID) THEN
         SAVE.PD.RECORD = PD.RECORD      ; * Save the record.
         CALL OPF(F.PD.PARAMETER,FV.PD.PARAMETER)  ; * Get the file pointer
         DELETE FV.PD.PARAMETER, PDP.ID  ; * Delete the record with Category as Id.
         PDP.ID = 'AC-':PDP.ID
         PD.RECORD = SAVE.PD.RECORD
      END
      RETURN
   END
