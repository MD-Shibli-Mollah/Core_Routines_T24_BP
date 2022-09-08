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

* Version 4 15/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>239</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MI.Entries
      SUBROUTINE CONV.MI.AUTO.ENTRY.MONTH.G7.2
*************************************************************************
*
* Routine to populate the MI.AUTO.ENTRY.MONTH file with records
* which are on the MI.AUTO.ENTRY file. Initially for use for clients
* pre G7.2 but can be used as a rebuild of the MI.AUTO.ENTRY.MONTH
* file in case of corruption
*
*************************************************************************
*
* 10/03/97 - GB9700284
*            Modifications to process the files in all compnaies.
*
*************************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_CONV.COMMON
$INSERT I_F.MI.AUTO.ENTRY
$INSERT I_F.COMPANY
*************************************************************************
*
      SAVE.ID.COMPANY = ID.COMPANY
*
* Loop through each company
*
* GB9701190 - Not for Conslidation and Reporting companies
      COMMAND = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
      COMPANY.LIST = ''
      CALL EB.READLIST(COMMAND, COMPANY.LIST, '','','')
      LOOP
         REMOVE K.COMPANY FROM COMPANY.LIST SETTING COMP.MARK
      WHILE K.COMPANY : COMP.MARK
*
         IF K.COMPANY <> ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
         END
*
* Decide if the product is installed, and if so run the process.
*
         LOCATE 'MI' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING FOUND.POS THEN
*
            GOSUB INITIALISE
*
            GOSUB PROCESS.RECORDS
*
         END
*
* Processing for this company now complete.
*
      REPEAT
*
* Processing now complete for all companies.
* Change back to the original company if we have changed.
*
      IF ID.COMPANY <> SAVE.ID.COMPANY THEN
         CALL LOAD.COMPANY(SAVE.ID.COMPANY)
      END

      RETURN
*
*************************************************************************
*
INITIALISE:
*
* Open files here
*
      FN.MI.AUTO.ENTRY = 'F.MI.AUTO.ENTRY'
      F.MI.AUTO.ENTRY = ''
      CALL OPF(FN.MI.AUTO.ENTRY, F.MI.AUTO.ENTRY)
*
      FN.MI.AUTO.ENTRY.MONTH = 'F.MI.AUTO.ENTRY.MONTH'
      F.MI.AUTO.ENTRY.MONTH = ''
      CALL OPF(FN.MI.AUTO.ENTRY.MONTH, F.MI.AUTO.ENTRY.MONTH)
*
      COMMAND = 'SELECT ' : FN.MI.AUTO.ENTRY : ' BY GEN.SYS.ID BY VALUE.DATE'
      CALL EB.READLIST(COMMAND, MI.AUTO.ENTRY.LIST, '', '', '')
*
      TOTAL.NUM = DCOUNT(MI.AUTO.ENTRY.LIST, FM)
      OVER.COUNT = 0
      RETURN

*
*************************************************************************
*
PROCESS.RECORDS:
*
* Loop through each record.
*
      CURRENT.FILE = ''
      OLD.FILE = ''
      SEQ.NO = 0
      R.MI.AUTO.ENTRY.MONTH = ''
      OLD.VALUE.DATE = ''
      RECORD.NO = 0
*
      LOOP
         REMOVE MI.AUTO.ENTRY.ID FROM MI.AUTO.ENTRY.LIST SETTING AUTO.MARK
      WHILE MI.AUTO.ENTRY.ID : AUTO.MARK

         READ R.MI.AUTO.ENTRY FROM F.MI.AUTO.ENTRY, MI.AUTO.ENTRY.ID
            ELSE R.MI.AUTO.ENTRY = ''

         RECORD.NO += 1
         OVER.COUNT += 1

         CURRENT.FILE = R.MI.AUTO.ENTRY<MI.AUTO.GEN.SYS.ID>
         VALUE.DATE = R.MI.AUTO.ENTRY<MI.AUTO.VALUE.DATE>
         IF NOT(VALUE.DATE) THEN
            VALUE.DATE = R.MI.AUTO.ENTRY<MI.AUTO.BOOKING.DATE>
         END
*
         IF CURRENT.FILE <> OLD.FILE AND OLD.FILE THEN
            GOSUB CHANGE.FILE
         END ELSE
            IF OLD.VALUE.DATE[1,6] <> VALUE.DATE[1,6] AND OLD.VALUE.DATE THEN
               GOSUB WRITE.RECORD
               RECORD.NO = 1
               SEQ.NO = 0
            END
            R.MI.AUTO.ENTRY.MONTH<RECORD.NO> = MI.AUTO.ENTRY.ID
            IF RECORD.NO = 200 THEN GOSUB WRITE.RECORD
         END


         OLD.VALUE.DATE = VALUE.DATE
         OLD.FILE = CURRENT.FILE
      REPEAT
      IF R.MI.AUTO.ENTRY.MONTH THEN GOSUB WRITE.RECORD

      RETURN
*
*************************************************************************
*
WRITE.RECORD:
      MESSAGE = 'PROCESSED ' : OVER.COUNT : ' OF ' : TOTAL.NUM
      CALL SF.CLEAR(1,7, MESSAGE)
      IF VALUE.DATE[1,6] = OLD.VALUE.DATE[1,6] THEN
         MI.AUTO.ENTRY.MONTH.ID = CURRENT.FILE : '*' : VALUE.DATE[1,6] : '*' : SEQ.NO
      END ELSE
         MI.AUTO.ENTRY.MONTH.ID = CURRENT.FILE : '*' : OLD.VALUE.DATE[1,6] : '*' : SEQ.NO
      END
      WRITE R.MI.AUTO.ENTRY.MONTH ON F.MI.AUTO.ENTRY.MONTH, MI.AUTO.ENTRY.MONTH.ID
      SEQ.NO += 1
      R.MI.AUTO.ENTRY.MONTH = ''
      RECORD.NO = 0

      RETURN
*
*************************************************************************
*
CHANGE.FILE:
*
* Write out current record.
*
      MI.AUTO.ENTRY.MONTH.ID = OLD.FILE : '*' : VALUE.DATE[1,6] : '*' : SEQ.NO
      WRITE R.MI.AUTO.ENTRY.MONTH ON F.MI.AUTO.ENTRY.MONTH, MI.AUTO.ENTRY.MONTH.ID
      R.MI.AUTO.ENTRY.MONTH = MI.AUTO.ENTRY.ID
      SEQ.NO = 0
      RECORD.NO = 1
      MESSAGE = 'PROCESSED ' : OVER.COUNT : ' OF ' : TOTAL.NUM
      CALL SF.CLEAR(1,7, MESSAGE)

      RETURN
*
*************************************************************************
*
   END
