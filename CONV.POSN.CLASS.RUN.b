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

* Version 6 15/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>1471</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PM.Config
      SUBROUTINE CONV.POSN.CLASS.RUN

* PIF GB9200341 Introduce code to prevent rerun corruption
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY
$INSERT I_F.PM.POSN.CLASS
*
***BUILD REF TABLE
*
      F.PM.AC.PARAM = ''
      F.PM.DLY.POSN.CLASS = ''
      F.PM.PARAMETER = ''
      F.POSITION.CAPTURE = ''
      F.PM.POSN.CLASS = ''
      F.PM.POSN.INV.REF = ''
      F.PM.POSN.REAL.TIME = ''
      F.PM.POSN.REFERENCE = ''
      F.PM.SC.PARAM = ''
      F.PM.SC.PARAM$NAU = ''
      F.PM.SC.PARAM.INV = ''
      CONV.TABLE = ""
      FILE.PM.AC.PARAM = "F.PM.AC.PARAM"
      FILE.PM.DLY.POSN.CLASS = "F.PM.DLY.POSN.CLASS"
      FILE.PM.PARAMETER = "F.PM.PARAMETER"
      FILE.PM.POSITION.CAPTURE = "F.PM.POSITION.CAPTURE"
      FILE.PM.POSN.CLASS = "F.PM.POSN.CLASS"
      FILE.PM.POSN.INV.REF = "F.PM.POSN.INV.REF"
      FILE.PM.POSN.REAL.TIME = "F.PM.POSN.REAL.TIME"
      FILE.PM.POSN.REFERENCE = "F.PM.POSN.REFERENCE"
      FILE.PM.SC.PARAM = "F.PM.SC.PARAM.INV"
      FILE.PM.SC.PARAM$NAU = "F.PM.SC.PARAM$NAU"
      FILE.PM.SC.PARAM.INV = "F.PM.SC.PARAM.INV"
      CALL OPF(FILE.PM.AC.PARAM,F.PM.AC.PARAM)
      CALL OPF(FILE.PM.DLY.POSN.CLASS,F.PM.DLY.POSN.CLASS)
      CALL OPF(FILE.PM.PARAMETER,F.PM.PARAMETER)
      CALL OPF(FILE.PM.POSITION.CAPTURE,F.PM.POSITION.CAPTURE)
      CALL OPF(FILE.PM.POSN.CLASS,F.PM.POSN.CLASS)
      CALL OPF(FILE.PM.POSN.INV.REF,F.PM.POSN.INV.REF)
      CALL OPF(FILE.PM.POSN.REAL.TIME,F.PM.POSN.REAL.TIME)
      CALL OPF(FILE.PM.POSN.REFERENCE,F.PM.POSN.REFERENCE)
      CALL OPF(FILE.PM.SC.PARAM,F.PM.SC.PARAM)
      CALL OPF(FILE.PM.SC.PARAM.INV,F.PM.SC.PARAM.INV)
      EOF = 0
      X = 0
      EXECUTE "SELECT ":FILE.PM.POSN.CLASS
      EXECUTE "SAVE.LIST POSN.CONV"
      EXECUTE "GET.LIST POSN.CONV"
      LOOP
         READNEXT ID ELSE EOF = 1
      UNTIL EOF
         IF LEN(ID) LT 5 THEN
            X += 1
            CONV.TABLE<1,X> = ID
            READ POSN.REC FROM F.PM.POSN.CLASS,ID THEN
               NEW.ID = POSN.REC<PM.PC.PRODUCT>:ID
               CONV.TABLE<2,X> = NEW.ID
               WRITE POSN.REC TO F.PM.POSN.CLASS,NEW.ID
               DELETE F.PM.POSN.CLASS,ID
            END
         END
      REPEAT
*
*RECREATE KEYS TO PM.DLY.POSN.CLASS
      EOF = 0
      EXECUTE "SELECT ":FILE.PM.DLY.POSN.CLASS
      EXECUTE "SAVE.LIST POSN.CONV"
      EXECUTE "GET.LIST POSN.CONV"
      LOOP
         READNEXT ID ELSE EOF = 1
      UNTIL EOF
         READ POSN.REC FROM F.PM.DLY.POSN.CLASS,ID THEN
            OLD.CLASS = FIELD(ID,'.',1)
            LOCATE OLD.CLASS IN CONV.TABLE<1,1> SETTING POSN ELSE
               GOTO GET.NEXT.DLY.REC
            END

            NEW.ID = CONV.TABLE<2,POSN>:'.':FIELD(ID,'.',2,99)
            WRITE POSN.REC TO F.PM.DLY.POSN.CLASS,NEW.ID
            DELETE F.PM.DLY.POSN.CLASS,ID
         END
GET.NEXT.DLY.REC:
      REPEAT
*
*RECREATE KEYS TO PM.POSN.INV.REF
      EOF = 0
      EXECUTE "SELECT ":FILE.PM.POSN.INV.REF
      EXECUTE "SAVE.LIST POSN.CONV"
      EXECUTE "GET.LIST POSN.CONV"
      LOOP
         READNEXT ID ELSE EOF = 1
      UNTIL EOF
         READ POSN.REC FROM F.PM.POSN.INV.REF,ID THEN
            OLD.CLASS = FIELD(ID,'.',1)
            LOCATE OLD.CLASS IN CONV.TABLE<1,1> SETTING POSN ELSE
               GOTO GET.NEXT.INV.REC
            END

            NEW.ID = CONV.TABLE<2,POSN>:'.':FIELD(ID,'.',2,99)
            WRITE POSN.REC TO F.PM.POSN.INV.REF,NEW.ID
            DELETE F.PM.POSN.INV.REF,ID
         END
GET.NEXT.INV.REC:
      REPEAT
*
* REPLACE TXN REFERENCE WITH NEW KEYS
      EOF = 0
      EXECUTE "SELECT ":FILE.PM.POSN.REAL.TIME
      LOOP
         READNEXT ID ELSE EOF = 1
      UNTIL EOF
         X = 0
         READ POSN.REC FROM F.PM.POSN.REAL.TIME,ID THEN
            LOOP
               X+= 1
               TXN = POSN.REC<9,X>
            UNTIL NOT(TXN)
               OLD.CLASS = FIELD(TXN,'.',1)
               LOCATE OLD.CLASS IN CONV.TABLE<1,1> SETTING POSN THEN
                  POSN.REC<9,X> = CONV.TABLE<2,POSN>:'.':FIELD(TXN,'.',2,99)
               END
            REPEAT
            WRITE POSN.REC TO F.PM.POSN.REAL.TIME,ID
         END
      REPEAT
*
*EXCHANGE OLD FOR NEW CLASS CODES PM.AC.PARAM
      EOF = 0
      EXECUTE "SELECT ":FILE.PM.AC.PARAM
      LOOP
         READNEXT ID ELSE EOF = 1
      UNTIL EOF
         READ POSN.REC FROM F.PM.AC.PARAM,ID THEN
            X = 0
            LOOP
               X+= 1
               OLD.CLASS = POSN.REC<5,X>
            UNTIL NOT(OLD.CLASS)
               LOCATE OLD.CLASS IN CONV.TABLE<1,1> SETTING POSN THEN
                  POSN.REC<5,X> = CONV.TABLE<2,POSN>
               END
            REPEAT
            WRITE POSN.REC TO F.PM.AC.PARAM,ID
         END
      REPEAT
*
*EXCHANGE OLD FOR NEW CLASS CODES PM.POSITION.CAPTURE
      EOF = 0
      EXECUTE "SELECT ":FILE.PM.POSITION.CAPTURE
      LOOP
         READNEXT ID ELSE EOF = 1
      UNTIL EOF
         READ POSN.REC FROM F.PM.POSITION.CAPTURE,ID THEN
            OLD.CLASS = POSN.REC<8>
            LOCATE OLD.CLASS IN CONV.TABLE<1,1> SETTING POSN THEN
               POSN.REC<8> = CONV.TABLE<2,POSN>
            END
            WRITE POSN.REC TO F.PM.POSITION.CAPTURE,ID
         END
      REPEAT
*
*EXCHANGE OLD FOR NEW CLASS CODES PM.POSN.REFERENCE
      EOF = 0
      EXECUTE "SELECT ":FILE.PM.POSN.REFERENCE
      LOOP
         READNEXT ID ELSE EOF = 1
      UNTIL EOF
         READ POSN.REC FROM F.PM.POSN.REFERENCE,ID THEN
            X = 0
            LOOP
               X+= 1
               OLD.CLASS = POSN.REC<10,X>
            UNTIL NOT(OLD.CLASS)
               LOCATE OLD.CLASS IN CONV.TABLE<1,1> SETTING POSN THEN
                  POSN.REC<10,X> = CONV.TABLE<2,POSN>
               END
            REPEAT
            WRITE POSN.REC TO F.PM.POSN.REFERENCE,ID
         END
      REPEAT
*
*EXCHANGE OLD FOR NEW CLASS CODES PM.PARAMETER
      EOF = 0
      EXECUTE "SELECT ":FILE.PM.PARAMETER
      LOOP
         READNEXT ID ELSE EOF = 1
      UNTIL EOF
         X = 0
         READ POSN.REC FROM F.PM.PARAMETER,ID THEN
            Z = ''
            Z<1> = 5
            Z<2> = 6
            Z<3> = 7
            Z<4> = 8
            Z<5> = 9
            Z<6> = 15
            Z<7> = 16
            Z<8> = 22
            FOR Y = 1 TO 8
               OLD.CLASS = POSN.REC<Z<Y>>
               LOCATE OLD.CLASS IN CONV.TABLE<1,1> SETTING POSN THEN
                  POSN.REC<Z<Y>> = CONV.TABLE<2,POSN>
               END
            NEXT Y
*
            FOR Y = 19 TO 20
               X = 0
               LOOP
                  X+= 1
                  OLD.CLASS = POSN.REC<Y,X>
               UNTIL NOT(OLD.CLASS)
                  LOCATE OLD.CLASS IN CONV.TABLE<1,1> SETTING POSN THEN
                     POSN.REC<Y,X> = CONV.TABLE<2,POSN>
                  END
               REPEAT
            NEXT Y
            WRITE POSN.REC TO F.PM.PARAMETER,ID
         END
      REPEAT
*
*Copy records on to hold.
*
      EXECUTE "SELECT ":FILE.PM.SC.PARAM
      EXECUTE "SAVE.LIST POSN.CONV"
      EXECUTE "GET.LIST POSN.CONV"
      LOOP
         READNEXT ID ELSE EOF = 1
      UNTIL EOF
         READ POSN.REC FROM F.PM.SC.PARAM,ID THEN
            WRITE POSN.REC TO F.PM.SC.PARAM$NAU,ID
         END
      REPEAT
*
* Clear file to allow rebuild.
*
      EXECUTE "SELECT ":FILE.PM.SC.PARAM.INV
      EXECUTE "SAVE.LIST POSN.CONV"
      EXECUTE "GET.LIST POSN.CONV"
      LOOP
         READNEXT ID ELSE EOF = 1
      UNTIL EOF
         DELETE F.PM.SC.PARAM.INV,ID
      REPEAT
*
      RETURN
   END
