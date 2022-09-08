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

* Version 3 15/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>440</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.LocalReferences
      SUBROUTINE CONV.LOCAL.TABLE.G12.2(ID, R.LOCAL.TABLE, F.LOCAL.TABLE)
*
* For each existing EB.LTA.DECIS.FIELD convert the field number to the
* field name.
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.LOCAL.TABLE
*
*************************************************************************
*
* For each LOCAL.TABLE record convert table no to name
*
      AV.COUNT = COUNT(R.LOCAL.TABLE<EB.LTA.DECIS.FIELD>,VM)+1
      FOR AV = 1 TO AV.COUNT
         YAPPL = ''
         YAPPL = R.LOCAL.TABLE<EB.LTA.APPLICATION,AV> ; SS.REC = ''
         IF YAPPL THEN
            CALL GET.STANDARD.SELECTION.DETS(YAPPL, SS.REC)
            AS.COUNT = COUNT(R.LOCAL.TABLE<EB.LTA.DECIS.FIELD>,SM)+1
            FOR AS = 1 TO AS.COUNT
               TEMP.FIELD.NO = R.LOCAL.TABLE<EB.LTA.DECIS.FIELD,AV,AS>
               IF TEMP.FIELD.NO THEN
                  NO.LOOPS = COUNT(TEMP.FIELD.NO,'/')+1
                  IF NO.LOOPS = 1 THEN NO.LOOPS = ''
                  IF NO.LOOPS THEN
                     FOR XX = 1 TO NO.LOOPS
                        IN.FIELD.NO = FIELD(TEMP.FIELD.NO,'/',XX)
                        FIELD.NAME = '' ; YAF = '' ; YAV = '' ; YAS = ''
                        ERR.MSG = ''
                        CALL FIELD.NUMBERS.TO.NAMES(IN.FIELD.NO,SS.REC,FIELD.NAME,DATA.TYPE,ERR.MSG)
                        IF XX = 1 THEN
                           YFLD = FIELD.NAME:'/'
                        END ELSE
                           YFLD := FIELD.NAME
                        END
                     NEXT XX
                  END ELSE               ; * No '/'
                     FIELD.NAME = '' ; YAF = '' ; YAV = '' ; YAS = ''
                     ERR.MSG = ''
                     CALL FIELD.NUMBERS.TO.NAMES(TEMP.FIELD.NO,SS.REC,FIELD.NAME,DATA.TYPE,ERR.MSG)
                     YFLD = FIELD.NAME
                  END
                  R.LOCAL.TABLE<EB.LTA.DECIS.FIELD,AV,AS> = YFLD
               END
            NEXT AS
         END
      NEXT AV
*
      RETURN
*
   END
