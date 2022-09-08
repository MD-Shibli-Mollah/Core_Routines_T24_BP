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

* Version 4 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>459</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.SystemTables
      SUBROUTINE CONV.FILE.CONTROL.G9(RECORD.ID, YREC, FILE.NAME)
*
$INSERT I_COMMON
$INSERT I_EQUATE
*
** This is the standard record conversion routine
** The id and record selected in FILE.NAME is passed.
** At this point any new fields will have been added, any old
** fields will have been removed.
** FILE.NAME contains the full name.
** No write of the record is required as this is performed in
** the main routine.
*
** Add modifications here to exsiting record
** Do NOT use insert positions unless the conversion
** is run AFTER installing releases.
*
*
      GOSUB INITIALISATION

! First check if the CO.CODE is in the 18th field of the file.
! If it is, clear out fields 11 and 12 and exit the program

      IF YREC<18> MATCHES "2A7N" THEN
         YREC<11> = '' ; YREC<12> = ''
         GOSUB PROG.ABORT
      END

! We can initialise all the fields greater than 10 and load up a
! 'dummy' set of Audit fields but this would mean that we will
! loose information in some old File Control records as to who
! created the records...
! So now check if any field greater than 10 till the end of the
! record contains an Inputter/Authoriser type of data and if so
! move the data in those fields to the correct Inputter and
! Authoriser field positions.

      YPROC.REQD = 0
      FOR YFLD = 10 TO 17
         IF YREC<YFLD> MATCHES "0X'_'0X" THEN      ; ! Look for the Underscore character
            YINPUTTER = YREC<YFLD> ; YREC<YFLD> = ''
            YAUTHORISER = YREC<YFLD+2> ; YREC<YFLD+2> = ''
            IF NOT(YAUTHORISER MATCHES "0X'_'0X") THEN YAUTHORISER = CONV.AUTHORISER
            YDATE.TIME = YREC<YFLD+1> ; YREC<YFLD+1> = ''
            IF NOT(YDATE.TIME MATCHES "10N") THEN YDATE.TIME = CONV.DATE.TIME
            YCURR.NO = YREC<YFLD-1> ; YREC<YFLD-1> = ''
            IF NOT(YCURR.NO MATCHES "0N") THEN YCURR.NO = '1'
            YCO.CODE = YREC<YFLD+3> ; YREC<YFLD+3> = ''
            IF NOT(YCO.CODE MATCHES "2A7N") THEN YCO.CODE = ID.COMPANY
            YDEPT = YREC<YFLD+4> ; YREC<YFLD+4> = ''
            IF NOT(YDEPT MATCHES "1N") THEN YDEPT = '1'
            YFLD = 17                    ; ! To get out of the loop
            YPROC.REQD = 1
         END
      NEXT YFLD

      IF YPROC.REQD THEN
         YREC<14> = YCURR.NO
         YREC<15> = YINPUTTER
         YREC<16> = YDATE.TIME
         YREC<17> = YAUTHORISER
         YREC<18> = YCO.CODE
         YREC<19> = YDEPT
         YREC<20> = ''
         YREC<21> = ''

         YREC<11> = '' ; YREC<12> = ''
         GOSUB PROG.ABORT
      END

! If the CO.CODE does not exist anywhere on the record, clear out
! fields 11 and 12 and add the audit fields to the record.
! The 'Hard Coded' Audit fields will have the Inputter as
! '1_CONV.FILE.CONTROL.G9' and the authoriser as the person running
! the Conversion program

      YREC<14> = '1'                     ; ! Curr No
      YREC<15> = CONV.INPUTTER
      YREC<16> = CONV.DATE.TIME
      YREC<17> = CONV.AUTHORISER
      YREC<18> = ID.COMPANY              ; ! Co Code
      YREC<19> = '1'                     ; ! Dept Code
      YREC<20> = ''                      ; ! Auditor
      YREC<21> = ''                      ; ! Audit Date Time


      YREC<11> = '' ; YREC<12> = ''

      RETURN
!----------------------------------------------------------------
INITIALISATION:
!-------------

      CONV.INPUTTER = '1_CONV.FILE.CONTROL.G9'
      CONV.AUTHORISER = '1_':OPERATOR
      X = OCONV(DATE(),"D-")
      CONV.DATE.TIME = X[9,2]:X[1,2]:X[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]
      RETURN
!----------------------------------------------------------------
PROG.ABORT:
!---------

      RETURN TO PROG.ABORT

      RETURN
!----------------------------------------------------------------

   END
