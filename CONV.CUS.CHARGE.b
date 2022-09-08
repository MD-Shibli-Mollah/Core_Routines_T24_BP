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
* <Rating>266</Rating>
*-----------------------------------------------------------------------------
* Version 4 02/06/00  GLOBUS Release No. G10.2.01 25/02/00

    $PACKAGE ST.ChargeConfig
      SUBROUTINE CONV.CUS.CHARGE
*   06 OCT 92
*    Convert existing CUSTOMER.CHARGE records for new fields

$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.CUSTOMER.CHARGE

*************************************************************************

      GOSUB INITIALISE                   ; * Special Initialising

*************************************************************************

* Main Program Loop

      LOOP
         Z += 1
         YSELFILE.NAME = FIELD(YFILE.LIST,":",Z)
         YFILE.NAME = 'F.':YSELFILE.NAME
      UNTIL YSELFILE.NAME = "" DO
         F.CUSTOMER.CHARGE = ''
         CALL OPF(YFILE.NAME,F.CUSTOMER.CHARGE)
         *
         SELECT.STATEMENT = 'SELECT F':R.COMPANY(3):'.':YSELFILE.NAME
         YSTO.ID.LIST = ""
         CALL EB.READLIST(SELECT.STATEMENT, YSTO.ID.LIST, "", "", "")
         PREVIOUS.REC = ""
         Y.END = ""
         LOOP
            YSTO = YSTO.ID.LIST<1>
         UNTIL YSTO = "" OR Y.END = "END" DO
            DEL YSTO.ID.LIST<1>
            NEW.REC = ""
            PREVIOUS.REC = ""
            ETEXT = ''
            READU PREVIOUS.REC FROM F.CUSTOMER.CHARGE,YSTO ELSE PREVIOUS.REC = ""
            YCOUNT.MV = COUNT(PREVIOUS.REC,FM) + 1
            IF YCOUNT.MV < (START.FIELD+NO.OF.FIELDS) THEN
               NEW.REC = PREVIOUS.REC
               FOR X = START.FIELD TO EN.FIELD STEP - 1
                  NEW.REC = REPLACE(NEW.REC,X+NO.OF.FIELDS;PREVIOUS.REC<X>)
                  NEW.REC = REPLACE(NEW.REC,X;"")
               NEXT X
               CRT CRT.KEY.POS:YSTO
               WRITE NEW.REC TO F.CUSTOMER.CHARGE,YSTO
            END ELSE
               RELEASE F.CUSTOMER.CHARGE,YSTO
               IF ETEXT THEN CALL EXCEPTION.LOG('S','FT','CONV.CUS.CHARGE','','','','F.CUSTOMER.CHARGE',YSTO,'','','')
            END
         REPEAT

MAIN.REPEAT:
      REPEAT

V$EXIT:
      RETURN                             ; * From main program

*************************************************************************
*                      S u b r o u t i n e s                            *
*************************************************************************

INITIALISE:

*
      Z = 0
      NO.OF.FIELDS = 2
      START.FIELD = 20
      EN.FIELD = 12
      YFILE.LIST = 'CUSTOMER.CHARGE:CUSTOMER.CHARGE$NAU:CUSTOMER.CHARGE$HIS'
      CRT.DIS.MESS = "NOW UPDATING CUSTOMER.CHARGE: "
      CRT.DIS.POS = @(10,12)
      CRT.KEY.POS = @(40,12)
      CRT CRT.DIS.POS:CRT.DIS.MESS

      RETURN

*************************************************************************

   END
