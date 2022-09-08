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
* <Rating>-33</Rating>
*-----------------------------------------------------------------------------
      $PACKAGE RE.ConBalanceUpdates
      SUBROUTINE CONV.ACCOUNT.EXPOSURE.G150
*-----------------------------------------------------------------------------
* Template file routine, to be used as a basis for building a FILE.ROUTINE
* to be run as part of the CONVERSION.DETAILS record.
* This routine should only be used to do such things as change record keys etc
* where ever possible use the RECORD.ROUTINE to convert/populate record data fields.
*-----------------------------------------------------------------------------
* Modification History:
*
* 20/12/04 - EN_10002375
*            Move the dates from ACCOUNT.EXPOSURE to a new field on ACCOUNT.
*            Delete the old ACCOUNT.EXPOSURE record
*
* 04/12/07 - CI_10052758
*            Replace the I_F equate with the field position.
*            - AC.EXPOSURE.DATES replaced with 168.
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE

* Equate field numbers to position manually, do no use $INSERT
      EQU SUFFIXES TO 3
      EQU FILE.CONTROL.CLASS TO 6
      EQU AC.EXPOSURE.DATES TO 168

      SAVE.ID.COMPANY = ID.COMPANY

*
      COMMAND = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
      COMPANY.LIST = ''
      CALL EB.READLIST(COMMAND, COMPANY.LIST, '', '', '')

      LOOP
         REMOVE K.COMPANY FROM COMPANY.LIST SETTING MORE.COMPANIES
      WHILE K.COMPANY:MORE.COMPANIES

         IF K.COMPANY NE ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
         END

         GOSUB INITIALISE

         GOSUB SELECT.ACCOUNT.EXPOSURE

         IF SEL.LIST # '' THEN
            GOSUB PROCESS.ACCOUNT.EXPOSURE
         END

      REPEAT

      IF ID.COMPANY NE SAVE.ID.COMPANY THEN
         CALL LOAD.COMPANY(SAVE.ID.COMPANY)
      END

      RETURN

*---------*
INITIALISE:
*---------*
* open files etc



      FN.ACCOUNT.EXPOSURE = 'F.ACCOUNT.EXPOSURE'
      F.ACCOUNT.EXPOSURE = ''
      CALL OPF(FN.ACCOUNT.EXPOSURE,F.ACCOUNT.EXPOSURE)

      FN.ACCOUNT = 'F.ACCOUNT'
      F.ACCOUNT = ''
      CALL OPF(FN.ACCOUNT,F.ACCOUNT)

      RETURN

*----------------------*
SELECT.ACCOUNT.EXPOSURE:
*----------------------*

      EX.STMT = 'SELECT ':FN.ACCOUNT.EXPOSURE

      SEL.LIST = "" ; SYS.ERROR = ""
      NO.OF.RECS = ''

      CALL EB.READLIST(EX.STMT, SEL.LIST, "", NO.OF.RECS, SYS.ERROR)

      RETURN

*-----------------------*
PROCESS.ACCOUNT.EXPOSURE:
*-----------------------*

      LOOP
         REMOVE ACCOUNT.EXPOSURE.ID FROM SEL.LIST SETTING MORE

      WHILE ACCOUNT.EXPOSURE.ID:MORE DO


         R.ACCOUNT.EXPOSURE = ''

         READ R.ACCOUNT.EXPOSURE FROM F.ACCOUNT.EXPOSURE, ACCOUNT.EXPOSURE.ID ELSE
            CONTINUE
         END

         ACCOUNT.ID = ACCOUNT.EXPOSURE.ID
         R.ACCOUNT = ''
         READ R.ACCOUNT FROM F.ACCOUNT,ACCOUNT.ID ELSE
            CONTINUE
         END

         NEW.LINE = LOWER(R.ACCOUNT.EXPOSURE)
         R.ACCOUNT<AC.EXPOSURE.DATES> = NEW.LINE

         WRITE R.ACCOUNT ON F.ACCOUNT,ACCOUNT.ID
         DELETE F.ACCOUNT.EXPOSURE,ACCOUNT.EXPOSURE.ID
      REPEAT

      RETURN


   END
