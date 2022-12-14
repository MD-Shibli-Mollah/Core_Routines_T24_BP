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

* Version 4 07/06/01  GLOBUS Release No. 200511 21/10/05
*-----------------------------------------------------------------------------
* <Rating>-54</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScfConfig
      SUBROUTINE CONV.SCSK.GROUP.COND.G7.1
*
* This routine was written as part of the Management Fees development
* HSJ0119 - PIF GB9600237.
*
*************************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.SPF
*************************************************************************
*
      GOSUB INITIALISE
*
      COMMAND = 'SELECT ':FN.SCSK.GROUP.CONDITION
      CALL EB.READLIST(COMMAND, RECORD.LIST, '', V$NUM, CODE)
*
      LOOP
         REMOVE RECORD.ID FROM RECORD.LIST SETTING RECORD.POS
      WHILE RECORD.ID : RECORD.POS
         GOSUB PROCESS.LIVE.RECORD
      REPEAT
*
      COMMAND = 'SELECT ':FN.SCSK.GROUP.CONDITION$NAU
      CALL EB.READLIST(COMMAND, RECORD.LIST, '', V$NUM, CODE)
*
      LOOP
         REMOVE RECORD.ID FROM RECORD.LIST SETTING RECORD.POS
      WHILE RECORD.ID : RECORD.POS
         GOSUB PROCESS.UNAU.RECORD
      REPEAT
*
      COMMAND = 'SELECT ':FN.SCSK.GROUP.CONDITION$HIS
      CALL EB.READLIST(COMMAND, RECORD.LIST, '', V$NUM, CODE)
*
      LOOP
         REMOVE RECORD.ID FROM RECORD.LIST SETTING RECORD.POS
      WHILE RECORD.ID : RECORD.POS
         GOSUB PROCESS.HIS.RECORD
      REPEAT
*
* Processing done so return.
*
      RETURN
*
*----------
INITIALISE:
*----------
* Open the SCSK.GROUP.CONDITION here.
*
      FN.SCSK.GROUP.CONDITION = 'F.SCSK.GROUP.CONDITION'
      F.SCSK.GROUP.CONDITION = ''
      CALL OPF(FN.SCSK.GROUP.CONDITION, F.SCSK.GROUP.CONDITION)
*
      FN.SCSK.GROUP.CONDITION$NAU = 'F.SCSK.GROUP.CONDITION$NAU'
      F.SCSK.GROUP.CONDITION$NAU = ''
      CALL OPF(FN.SCSK.GROUP.CONDITION$NAU, F.SCSK.GROUP.CONDITION$NAU)
*
      FN.SCSK.GROUP.CONDITION$HIS = 'F.SCSK.GROUP.CONDITION$HIS'
      F.SCSK.GROUP.CONDITION$HIS = ''
      CALL OPF(FN.SCSK.GROUP.CONDITION$HIS, F.SCSK.GROUP.CONDITION$HIS)
*
      F.SAFECUSTODY.VALUES = ''
      CALL OPF('F.SAFECUSTODY.VALUES',F.SAFECUSTODY.VALUES)
      R.SAFECUSTODY.VALUES = ''
      CALL F.READ('F.SAFECUSTODY.VALUES',ID.COMPANY,R.SAFECUSTODY.VALUES,F.SAFECUSTODY.VALUES,ETEXT)
      IF ETEXT THEN
         ETEXT = ''
         SC.POSN = ''
      END ELSE
         LOCATE 'SC' IN R.SAFECUSTODY.VALUES<1,1> SETTING SC.POSN ELSE
            SC.POSN = ''
         END
      END
*
      RETURN
*
*-------------------
PROCESS.LIVE.RECORD:
*-------------------
* Read the record from the file.

      READ R.SCSK.GROUP.CONDITION FROM F.SCSK.GROUP.CONDITION, RECORD.ID THEN
*
* Update the record
*
         IF SC.POSN THEN
            R.SCSK.GROUP.CONDITION<10> = R.SAFECUSTODY.VALUES<14,SC.POSN>
            CONVERT SM TO VM IN R.SCSK.GROUP.CONDITION<10>
            R.SCSK.GROUP.CONDITION<11> = R.SAFECUSTODY.VALUES<15,SC.POSN>
            CONVERT SM TO VM IN R.SCSK.GROUP.CONDITION<11>
            R.SCSK.GROUP.CONDITION<12> = R.SAFECUSTODY.VALUES<16,SC.POSN>
            CONVERT SM TO VM IN R.SCSK.GROUP.CONDITION<12>
            R.SCSK.GROUP.CONDITION<13> = R.SAFECUSTODY.VALUES<17,SC.POSN>
            CONVERT SM TO VM IN R.SCSK.GROUP.CONDITION<13>
            R.SCSK.GROUP.CONDITION<14> = R.SAFECUSTODY.VALUES<18,SC.POSN>
            CONVERT SM TO VM IN R.SCSK.GROUP.CONDITION<14>
            R.SCSK.GROUP.CONDITION<15> = R.SAFECUSTODY.VALUES<19,SC.POSN>
            CONVERT SM TO VM IN R.SCSK.GROUP.CONDITION<15>
         END
         DELETE F.SCSK.GROUP.CONDITION, RECORD.ID
         RECORD.ID := '.19800101'
*
* And write the record.
*
         WRITE R.SCSK.GROUP.CONDITION ON F.SCSK.GROUP.CONDITION, RECORD.ID
         YFILE = 'F.SCAC.SCSK.CONDITION'
         CONCAT.ID = FIELD(RECORD.ID,'.',1)
         CONCAT.REC = '19800101'
         SAVE.SPF = R.SPF.SYSTEM<SPF.OP.MODE> ; R.SPF.SYSTEM<SPF.OP.MODE> = "B"
         CALL CONCAT.FILE.UPDATE(YFILE,CONCAT.ID,CONCAT.REC,'I','AL')
         R.SPF.SYSTEM<SPF.OP.MODE> = SAVE.SPF
      END
*
      RETURN
*
*-------------------
PROCESS.UNAU.RECORD:
*-------------------
* Read the record from the file.
*
      READ R.SCSK.GROUP.CONDITION FROM F.SCSK.GROUP.CONDITION$NAU, RECORD.ID THEN
*
* Update the record
*
         IF SC.POSN THEN
            R.SCSK.GROUP.CONDITION<10> = R.SAFECUSTODY.VALUES<14,SC.POSN>
            CONVERT SM TO VM IN R.SCSK.GROUP.CONDITION<10>
            R.SCSK.GROUP.CONDITION<11> = R.SAFECUSTODY.VALUES<15,SC.POSN>
            CONVERT SM TO VM IN R.SCSK.GROUP.CONDITION<11>
            R.SCSK.GROUP.CONDITION<12> = R.SAFECUSTODY.VALUES<16,SC.POSN>
            CONVERT SM TO VM IN R.SCSK.GROUP.CONDITION<12>
            R.SCSK.GROUP.CONDITION<13> = R.SAFECUSTODY.VALUES<17,SC.POSN>
            CONVERT SM TO VM IN R.SCSK.GROUP.CONDITION<13>
            R.SCSK.GROUP.CONDITION<14> = R.SAFECUSTODY.VALUES<18,SC.POSN>
            CONVERT SM TO VM IN R.SCSK.GROUP.CONDITION<14>
            R.SCSK.GROUP.CONDITION<15> = R.SAFECUSTODY.VALUES<19,SC.POSN>
            CONVERT SM TO VM IN R.SCSK.GROUP.CONDITION<15>
         END
         DELETE F.SCSK.GROUP.CONDITION$NAU, RECORD.ID
         RECORD.ID := '.19800101'
*
* And write the record.
*
         WRITE R.SCSK.GROUP.CONDITION ON F.SCSK.GROUP.CONDITION$NAU, RECORD.ID
      END
*
      RETURN
*
*-------------------
PROCESS.HIS.RECORD:
*-------------------
* Read the record from the file.
*
      READ R.SCSK.GROUP.CONDITION FROM F.SCSK.GROUP.CONDITION$HIS, RECORD.ID THEN
*
* Update the record
*
         IF SC.POSN THEN
            R.SCSK.GROUP.CONDITION<10> = R.SAFECUSTODY.VALUES<14,SC.POSN>
            CONVERT SM TO VM IN R.SCSK.GROUP.CONDITION<10>
            R.SCSK.GROUP.CONDITION<11> = R.SAFECUSTODY.VALUES<15,SC.POSN>
            CONVERT SM TO VM IN R.SCSK.GROUP.CONDITION<11>
            R.SCSK.GROUP.CONDITION<12> = R.SAFECUSTODY.VALUES<16,SC.POSN>
            CONVERT SM TO VM IN R.SCSK.GROUP.CONDITION<12>
            R.SCSK.GROUP.CONDITION<13> = R.SAFECUSTODY.VALUES<17,SC.POSN>
            CONVERT SM TO VM IN R.SCSK.GROUP.CONDITION<13>
            R.SCSK.GROUP.CONDITION<14> = R.SAFECUSTODY.VALUES<18,SC.POSN>
            CONVERT SM TO VM IN R.SCSK.GROUP.CONDITION<14>
            R.SCSK.GROUP.CONDITION<15> = R.SAFECUSTODY.VALUES<19,SC.POSN>
            CONVERT SM TO VM IN R.SCSK.GROUP.CONDITION<15>
         END
         DELETE F.SCSK.GROUP.CONDITION$HIS, RECORD.ID
         NEW.ID = FIELD(RECORD.ID,';',1)
         NEW.NO = FIELD(RECORD.ID,';',2)
         RECORD.ID = NEW.ID:'.19800101;':NEW.NO
*
* And write the record.
*
         WRITE R.SCSK.GROUP.CONDITION ON F.SCSK.GROUP.CONDITION$HIS, RECORD.ID
      END
*
      RETURN
   END
