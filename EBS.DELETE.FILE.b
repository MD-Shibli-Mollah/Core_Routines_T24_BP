* @ValidationCode : MjotMzIxNzM0MDc3OmNwMTI1MjoxNDc5MTE1NzkyNDEyOmtoYWxpZG1kOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE2MTIuMjAxNjExMDItMTE0MjotMTotMQ==
* @ValidationInfo : Timestamp         : 14 Nov 2016 14:59:52
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : khalidmd
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201612.20161102-1142
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 8 15/05/01  GLOBUS Release No. 200511 31/10/05  
*-----------------------------------------------------------------------------
* <Rating>291</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.SystemTables
      SUBROUTINE EBS.DELETE.FILE(FILES,DATA.OR.DICT,ERR.MSG)
*
* EBS.DELETE.FILE - Deletes GLOBUS files.
*
* 22/04/97 - GB9700440
*            Program re-written (was never amended for the change in the
*            GLOBUS directory structure or for the change from PRIMOS to
*            UNIX)
*
* 05/06/98 - GB9800613
*            Make all operating system calls via central routine.
*
* 11/08/05 - EN_10002614
*            RETURN st missing from PERFORM.DELETE para
*
* 03/11/16 - Task 1909014 / Defect 1890176
*            FROM.TYPE files removal from external database when corresponding record is Reversed.
*
*******************************
* Variables
*
* IN:
*
* FILES            Array of the names of all files to be deleted
*                  Passed as either the name of the file.control record,
*                  in which case the live, unauthorised and history
*                  files will be deleted for the current company,
*                  or the actual file name to be deleted.
* DATA.OR.DICT     Whether the data or dictionary file is to be deleted.
*                  This is used in the same way as in the uniVerse
*                  DELETE.FILE command.  Care should be taken when
*                  deleting dictionaries, as they can be shared between
*                  files.
*
* OUT:
*
* ERR.MSG          Error message
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY
$INSERT I_F.FILE.CONTROL
*
*========================================================================
*
      GOSUB INITIALISATION
*
      IF ERR.MSG = '' THEN

*
         FOR FILE.COUNT = 1 TO MAX.FILES
*
            FILE.NAME = FILES<FILE.COUNT>
            IF MAX.DATA.OR.DICT > 1 THEN
               D.OR.D = DATA.OR.DICT<FILE.COUNT>
            END ELSE D.OR.D = DATA.OR.DICT
*
            GOSUB DELETE.FILE
*
         NEXT FILE.COUNT

      END
*
      RETURN

*========================================================================
*                    S U B R O U T I N E S
*========================================================================
*
INITIALISATION:
*
* Perform initialisation
*
      ERR.MSG = ''
      MAX.FILES = DCOUNT(FILES,FM)
      MAX.DATA.OR.DICT = DCOUNT(DATA.OR.DICT,FM)
      MNE = R.COMPANY(EB.COM.MNEMONIC)
      SUFFIX.LIST = '':FM:'$NAU':FM:'$HIS'
      SQ = "'"
      DQ = '"'
*
      OPEN '','VOC' TO VOC ELSE
         ERR.MSG = 'CANNOT OPEN VOC'
         RETURN
      END
*
      RETURN
*
*************************************************************************
*
DELETE.FILE:
*
* Delete GLOBUS files
*
* If the file name exists on FILE.CONTROL, add the company mnemonic (if
* appropriate) and file suffixes
*
      R.FILE.CONTROL = ''
      READ R.FILE.CONTROL FROM F.FILE.CONTROL,FILE.NAME THEN
         IF R.FILE.CONTROL<EB.FILE.CONTROL.CLASS> = 'INT' THEN
            PREFIX = 'F.'
         END ELSE PREFIX = 'F':MNE:'.'
*
         FOR IDX = 1 TO 3
            SUFFIX = SUFFIX.LIST<IDX>
            GOSUB PERFORM.DELETE
         NEXT IDX
*
      END ELSE
*
* If the FILE.CONTROL record does not exist, use the file name passed
*
         PREFIX = ''
         SUFFIX = ''
         IDX = 1
         GOSUB PERFORM.DELETE
      END
*
      RETURN
*
*************************************************************************
*
PERFORM.DELETE:
*
* Physically delete the data file, the dictionary and the VOC entry,
* as required
*
      FILE = PREFIX:FILE.NAME:SUFFIX
*
      READ R.VOC FROM VOC, FILE THEN
*
* Delete the dictionary, if required, if this is the first prefix for the
* file
*
         IF D.OR.D <> 'DATA' THEN
            IF IDX = 1 THEN
               UNIX.DICTIONARY = R.VOC<3>          ; * Dictionary pathname
               PRINT "Removing ":FILE:" ":UNIX.DICTIONARY
* GB9800613 s
               RETURN.CODE = ""
               RESULT = ""
               SH.RM = "REMOVE"
               PARAMETER = UNIX.DICTIONARY
               CALL SYSTEM.CALL(SH.RM,"",PARAMETER,RESULT,RETURN.CODE)
               STATUS rSpfStatus FROM F.SPF ELSE rSpfStatus = ''
                   DB.TYPE = rSpfStatus<21>                      ;* Get database type
                     IF DB.TYPE[1,1] EQ "X" THEN
                     DEL.CMD="DELETE.FILE ":FILE               ;* delete when external database.
                     EXECUTE DEL.CMD CAPTURING DEL.RESULT
                   END               
* GB9800613 e
               DELETE VOC, "F.":FILE.NAME          ; * Dictionary only pointer
            END
         END
*
* Delete the data file, if required
*
         IF D.OR.D <> 'DICT' THEN

            UNIX.ID = R.VOC<2>
            PRINT "Removing ":FILE:" ":UNIX.ID     ; * Tell them about it
* GB9800613 s
            RETURN.CODE = ""
            RESULT = ""
            SH.RM = "REMOVE_R"
            PARAMETER = UNIX.ID
            CALL SYSTEM.CALL(SH.RM,"",PARAMETER,RESULT,RETURN.CODE)
  
* GB9800613 e
         END
*
* Delete the VOC entry, if required
*
         IF D.OR.D = '' THEN
            DELETE VOC, FILE             ; * Zap from voc
         END
      END

      RETURN

   END
