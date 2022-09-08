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

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-40</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScfConfig
      SUBROUTINE CONV.SAFECUSTODY.VALUES.G7
*
* This routine was written as part of the Management Fees development
* HSJ0119 - PIF GB9600237. It sets the fields COMPANY.CALC and
* COMPANY.POST to 'Y' and the field INT.ROUND.UP to 'N'.
*
*************************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
*************************************************************************
*
      GOSUB INITIALISE
*
      COMMAND = 'SELECT F.SAFECUSTODY.VALUES'
      CALL EB.READLIST(COMMAND, RECORD.LIST, '', V$NUM, CODE)
*
      LOOP
         REMOVE RECORD.ID FROM RECORD.LIST SETTING RECORD.POS
      WHILE RECORD.ID : RECORD.POS
         GOSUB PROCESS.LIVE.RECORD
      REPEAT
*
      COMMAND = 'SELECT F.SAFECUSTODY.VALUES$NAU'
      CALL EB.READLIST(COMMAND, RECORD.LIST, '', V$NUM, CODE)
*
      LOOP
         REMOVE RECORD.ID FROM RECORD.LIST SETTING RECORD.POS
      WHILE RECORD.ID : RECORD.POS
         GOSUB PROCESS.UNAU.RECORD
      REPEAT
*
* Processing done so return.
*
      RETURN
*
*----------
INITIALISE:
*----------
* Open the SAFECUSTODY.VALUES here.
*
      FN.SAFECUSTODY.VALUES = 'F.SAFECUSTODY.VALUES'
      F.SAFECUSTODY.VALUES = ''
      CALL OPF(FN.SAFECUSTODY.VALUES, F.SAFECUSTODY.VALUES)
*
      FN.SAFECUSTODY.VALUES$NAU = 'F.SAFECUSTODY.VALUES$NAU'
      F.SAFECUSTODY.VALUES$NAU = ''
      CALL OPF(FN.SAFECUSTODY.VALUES$NAU, F.SAFECUSTODY.VALUES$NAU)
*
      RETURN
*
*-------------------
PROCESS.LIVE.RECORD:
*-------------------
* Read the record from the file.

      READ R.SAFECUSTODY.VALUES FROM F.SAFECUSTODY.VALUES, RECORD.ID THEN
*
* Update the record
*
         VM.COUNT = DCOUNT(R.SAFECUSTODY.VALUES<1>,VM)
         FOR CT = 1 TO VM.COUNT
            R.SAFECUSTODY.VALUES<5,CT> = 'Y'
            R.SAFECUSTODY.VALUES<6,CT> = 'Y'
            R.SAFECUSTODY.VALUES<13,CT> = 'N'
         NEXT CT
*
* And write the record.
*
         WRITE R.SAFECUSTODY.VALUES ON F.SAFECUSTODY.VALUES, RECORD.ID
      END
*
      RETURN
*
*-------------------
PROCESS.UNAU.RECORD:
*-------------------
* Read the record from the file.
*
      READ R.SAFECUSTODY.VALUES FROM F.SAFECUSTODY.VALUES$NAU, RECORD.ID THEN
*
* Update the record
*
         VM.COUNT = DCOUNT(R.SAFECUSTODY.VALUES<1>,VM)
         FOR CT = 1 TO VM.COUNT
            R.SAFECUSTODY.VALUES<5,CT> = 'Y'
            R.SAFECUSTODY.VALUES<6,CT> = 'Y'
            R.SAFECUSTODY.VALUES<13,CT> = 'N'
         NEXT CT
*
* And write the record.
*
         WRITE R.SAFECUSTODY.VALUES ON F.SAFECUSTODY.VALUES$NAU, RECORD.ID
      END
*
      RETURN
   END
