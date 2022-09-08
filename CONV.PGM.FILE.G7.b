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
* <Rating>169</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.SystemTables
      SUBROUTINE CONV.PGM.FILE.G7
*************************************************************************
* CONV.PGM.FILE.G7
*
* This routines selects all of the records on the PGM.FILE which have
* anything in field. This was the old field RUN.INFO which some
* conversion routines updated. This routine copies the data from the
* old RUN.INFO field (field 9) and copies it into the DESCRIPTION field
* (field 7).
*
*************************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
*************************************************************************

      GOSUB INITIALISE

      LOOP
         REMOVE RECORD.ID FROM RECORD.LIST SETTING RECORD.POS
      WHILE RECORD.ID : RECORD.POS

         GOSUB PROCESS.RECORD

      REPEAT

* Processing done do return.

      RETURN

INITIALISE:

* Open the PGM.FILE here.

      FN.PGM.FILE = 'F.PGM.FILE'
      F.PGM.FILE = ''
      CALL OPF(FN.PGM.FILE, F.PGM.FILE)


* And the VOC here.

      OPEN '', 'VOC' TO F.VOC
         ELSE F.VOC = ''

* Read the VOC entry for field 9 (F9).

      READ R.VOC FROM F.VOC, 'F9'
      ELSE

* If it doesn't exist create it. This is used in the select statement.

         R.VOC = ''
         R.VOC<1> = 'D'
         R.VOC<2> = '2'
         R.VOC<3> = ''
         R.VOC<4> = ''
         R.VOC<5> = '15T'
         R.VOC<6> = 'S'
         WRITE R.VOC ON F.VOC, 'F9'
      END

* Now select records which have this field not nul

      COMMAND = 'SELECT F.PGM.FILE WITH F9 NE ""'
      CALL EB.READLIST(COMMAND, RECORD.LIST, '', V$NUM, CODE)

      RETURN

PROCESS.RECORD:

* Read the record from the file.

      READ R.PGM.FILE FROM F.PGM.FILE, RECORD.ID
         ELSE R.PGM.FILE = ''

* Append the RUN.INFO the the description of the record.

      RUN.INFO = R.PGM.FILE<9>
      R.PGM.FILE<7, -1> = RUN.INFO

* Then null the RUN.INFO

      R.PGM.FILE<9> = ''

* And write the record.

      WRITE R.PGM.FILE ON F.PGM.FILE, RECORD.ID

      RETURN
   END
