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

* Version 3 30/08/00  GLOBUS Release No. G14.1.00 13/11/03
*-----------------------------------------------------------------------------
* <Rating>2331</Rating>
*-----------------------------------------------------------------------------
      SUBROUTINE CONV.CHAR.SEQ(PROG.NAME,REC,ERROR.FLAG)
*
*********************************************************
*
* Change control
*
* 03/06/00 - GB0001694
*            CONV.CHAR.SEQ does not convert all the CHAR() and
*            SEQ() if there is more than one CHAR() or SEQ() in
*            single line.
* 14/07/00 - GB0001834
*            Change SUBROUTINE to PROGRAM and RETURN TO STOP
*
* 21/08/00 - GB0002100
*            Changes made to make JBASE.CONVERSION as the main program.
*            The read/write operations are now shifted to JBASE.CONVERSION
*
* 25/09/01 - GLOBUS_EN_10000183
*            CONV.CHAR.SEQ does not convert CHAR() and SEQ() if
*            it is immd after '('. So changes are made such that, it
*            converts even after '('.
*
* 10/09/03 - GLOBUS_CI_10012503
*            Fix to Convert CHAR() if it is immediately after a comma(,).
*            Ref : HD0311291
*
***************************************************************

      GOSUB INITIALISE

      GOSUB PREPARE.LIST

      GOSUB SCAN.PROG

* End of this routine.

      RETURN                             ; * GB0002100
*
INITIALISE:
*
      CHAR.SPC.LIST = ''
      SEQ.SPC.LIST = ''
      CNT = 0
      ERROR.FLAG = ''
      PROGRAM.CHANGED = ''
      EQU VM TO CHAR(253)
      YTEXT = ''
      PR.TEXT = '' ; DIM.PR.TEXT = ''
      CORR.TEXT = ''
      LIST.DIM.STMT = ''
*List for CHAR() and CHARS()
      CHAR.SPC.LIST<-1> = ':'
      CHAR.SPC.LIST<-1> = ' '
      CHAR.SPC.LIST<-1> = '<'
      CHAR.SPC.LIST<-1> = '>'
      CHAR.SPC.LIST<-1> = '='
      CHAR.SPC.LIST<-1> = '('            ; * GLOBUS_EN_10000183 S/E
      CHAR.SPC.LIST<-1> = ','            ; * GLOBUS_CI_10012503 - S/E

*List for SEQ() and SEQS()
      SEQ.SPC.LIST<-1> = '('             ; * GLOBUS_EN_10000183 S/E
      SEQ.SPC.LIST<-1> = ':'
      SEQ.SPC.LIST<-1> = ' '
      SEQ.SPC.LIST<-1> = '<'
      SEQ.SPC.LIST<-1> = '>'
      SEQ.SPC.LIST<-1> = '+'
      SEQ.SPC.LIST<-1> = '-'
      SEQ.SPC.LIST<-1> = '*'
      SEQ.SPC.LIST<-1> = '/'
      SEQ.SPC.LIST<-1> = '='


      RETURN

*
PREPARE.LIST:
*

* An list of programs can be added for each string or word checked, so that these
* programs are not searched for the string it is attached.
* THE USAGE:
*  PR.TEXT<-1> = '><':'*':'TESTSAT.4':VM:'TESTSAT.3'
* Here programs TESTSAT.4 and TESTSAT.3 will not be checked for '><'
* The programs are seperated by VM and the string and programs is seperated by
* '*'. Any exception programs must be used in included in the same manner
*
*
* The following is used to check if the words are used
* E.g. PR.TEXT<-1> = ' WRITE ' ; CORR.TEXT<-1> = ' Use F.WRITE instead or use ON ERROR clause.'
*
      PR.TEXT<-1> = 'CHAR(':'*':'OVERLAY.EX' ; CORR.TEXT<-1> = ' Use CHARX() instead of CHAR().'
      PR.TEXT<-1> = 'CHARS(':'*':'OVERLAY.EX' ; CORR.TEXT<-1> = ' Use CHARX() instead of CHAR().'
      PR.TEXT<-1> = 'SEQ(':'*':'OVERLAY.EX' ; CORR.TEXT<-1> = ' Use SEQX() instead of SEQ().'
      PR.TEXT<-1> = 'SEQS(':'*':'OVERLAY.EX' ; CORR.TEXT<-1> = ' Use SEQX() instead of SEQ().'
* The following is used to check if the words are used IN DIM
*
* E.g.      DIM.PR.TEXT<-1> = ' FIELD(' ; CORR.TEXT<-1> = ' Keyword used as variable. Instead use ':'Field('
*
      NO.OF.LINES = DCOUNT(REC,@FM)
      NO.OF.TEXTS = DCOUNT(PR.TEXT,@FM)
      NO.OF.DIM.TEXTS = DCOUNT(DIM.PR.TEXT,@FM)
      RETURN

*

*
*-----------------------------------------------------------------
*
SCAN.PROG:
*
*
      FOR L = 1 TO NO.OF.LINES
         TRIM.LINE = TRIM(REC<L>)
*
* Ignore comments
*
         IF TRIM.LINE[1,1] = '*' OR TRIM.LINE[1,1] = '!' OR TRIM.LINE[1,4] = 'REM ' THEN CONTINUE
*
*
* Check for semicolons.
*
*         IF INDEX(REC<L>,';',1) THEN
*            GOSUB CHECK.FOR.SEMICOLON
*         END
*
**
*
         IF TRIM.LINE[1,3] = 'DIM' OR TRIM.LINE[1,3] = 'COM' THEN
            LIST.DIM.STMT<-1> = REC<L>
            FOR T = 1 TO NO.OF.DIM.TEXTS
               IF INDEX(REC<L>, DIM.PR.TEXT<T>, 1) THEN
* This section will be used in future.
                  PRINT
               END
*
            NEXT T
         END ELSE
            FOR T = 1 TO NO.OF.TEXTS
*
* Though we have these restrictions, we have certain programs that has
* to compiled inspite of these errors. This code checks if the
* text selected for scaning need not be scaned for a particular program
*
               PROG.FOUND = ''
               SPC.PROG.LIST = ''
               SPC.PROG.LIST = FIELD(PR.TEXT<T>,'*',2)
               YTEXT = FIELD(PR.TEXT<T>,'*',1)
               LOCATE PROG.NAME IN SPC.PROG.LIST<1,1> SETTING PROG.FOUND ELSE PROG.FOUND = ''
               IF PROG.FOUND THEN CONTINUE
*
**
*
               DISP.ERR.FLAG = 1
               LINE.CNT = ''
               STRING.CHANGED = ''       ; * GB0001694
               IF INDEX(REC<L>, YTEXT, 1) THEN
                  LOOP
* GB0001694 S
                     IF STRING.CHANGED THEN
                        STRING.CHANGED = ''
                     END ELSE
                        LINE.CNT = LINE.CNT + 1
                     END
* GB0001694 E
                     STR.POS = INDEX(REC<L>, YTEXT, LINE.CNT)
                  WHILE STR.POS
                     BEGIN CASE
                        CASE YTEXT[1,4] = 'CHAR'
                           CH.BEFORE.YTEXT = REC<L>[STR.POS-1,1]
                           LOCATE CH.BEFORE.YTEXT IN CHAR.SPC.LIST<1> SETTING CH.BEFORE.FOUND ELSE CH.BEFORE.FOUND = ''
                           IF CH.BEFORE.FOUND THEN
                              PROGRAM.CHANGED = 1
                              STRING.CHANGED = 1   ; * GB0001694
                              REC<L> = REC<L>[1,STR.POS+LEN(YTEXT)-2]:'X':REC<L>[STR.POS+LEN(YTEXT)-1,LEN(REC<L>)+3]
                           END
                        CASE YTEXT[1,3] = 'SEQ'
                           CH.BEFORE.YTEXT = REC<L>[STR.POS-1,1]
                           LOCATE CH.BEFORE.YTEXT IN SEQ.SPC.LIST<1> SETTING CH.BEFORE.FOUND ELSE CH.BEFORE.FOUND = ''
                           IF CH.BEFORE.FOUND THEN
                              PROGRAM.CHANGED = 1
                              STRING.CHANGED = 1   ; * GB0001694
                              REC<L> = REC<L>[1,STR.POS+LEN(YTEXT)-2]:'X':REC<L>[STR.POS+LEN(YTEXT)-1,LEN(REC<L>)+3]
                           END

                     END CASE
                  REPEAT
               END
*
            NEXT T
         END
      NEXT L
*
      ERROR.FLAG = PROGRAM.CHANGED

      RETURN
**
*
CHECK.FOR.SEMICOLON:
*-------------------
*
* This para checks if semicolons, if used, are used as end of sentence.
* E.g. ABC = 100 ; DEF = 50
* If it is used as end of sentence then the code following the ';' is
* taken as next line.
*
* NOTE : This is not done for statements starting with DIM.
*
      YTEXT = ';'
      GOSUB CHECK.WITHIN.QUOTES
*
      IF STRING.WITHIN.QUOTES = 0 THEN
         NEXT.LINE = REC<L>[STRING.WITHIN.QUOTES.POS+1,LEN(REC<L>)]
         REC<L> = REC<L>[1,STRING.WITHIN.QUOTES.POS]
         INS NEXT.LINE BEFORE REC<L+1>
         NO.OF.LINES+=1
      END
      RETURN
*
**
*
CHECK.WITHIN.QUOTES:
*~~~~~~~~~~~~~~~~~~*
*
* This section will check if a string which is passed by the calling
* section is within quotes or not. This is used to check if 'to' and
* ';' is used within the quotes. Like in a PRINT statement. So this
* para will be generic.
*
      STRING.WITHIN.QUOTES = 1
      FIRST.DQUOTE = '' ; SECOND.DQUOTE = ''
      FIRST.SQUOTE = '' ; SECOND.SQUOTE = ''
      WITHIN.SQUOTE = '' ; WITHIN.DQUOTE = ''
      YLINE = '' ; YSTR = ''
*
* These variables have the position no. of the quote ( single or double)
* If the matching quote is found then the corresponding FIRST and SECOND
* quote are initialised.
*
      YLINE = REC<L> ; YSTR = YTEXT

      CH.POS = 1 ; CH = ''
      LOOP
      WHILE CH.POS <= LEN(YLINE)
         CH = YLINE[CH.POS,1]
         BEGIN CASE
            CASE CH = "'"
               IF NOT(FIRST.SQUOTE) THEN
                  FIRST.SQUOTE = CH.POS
                  IF FIRST.DQUOTE THEN WITHIN.DQUOTE = 1
               END ELSE
                  IF WITHIN.DQUOTE THEN
                     IF NOT(FIRST.DQUOTE) AND NOT(SECOND.DQUOTE) THEN
                        WITHIN.DQUOTE = '' ; FIRST.SQUOTE = CH.POS
                     END ELSE
                        IF FIRST.DQUOTE AND FIRST.SQUOTE THEN
                           WITHIN.DQUOTE = '' ; FIRST.SQUOTE = ''
                        END
                     END
                  END ELSE
* Since this got to be the second occurance of single quote.
                     FIRST.SQUOTE = ''
                     FIRST.DQUOTE = '' ; WITHIN.SQUOTE = ''
* This is because it is the end of the string for eg.
* PRINT 'abc"def;' . After the rightmost squote, there is no need
* of WITHIN.SQUOTE since the string within squotes is finished.
                  END
               END
            CASE CH = '"'
               IF NOT(FIRST.DQUOTE) THEN
                  FIRST.DQUOTE = CH.POS
                  IF FIRST.SQUOTE THEN WITHIN.SQUOTE = 1
               END ELSE
                  IF WITHIN.SQUOTE THEN
                     IF NOT(FIRST.SQUOTE) AND NOT(SECOND.SQUOTE) THEN
                        WITHIN.SQUOTE = '' ; FIRST.DQUOTE = CH.POS
                     END ELSE
                        IF FIRST.DQUOTE AND FIRST.SQUOTE THEN
                           WITHIN.SQUOTE = '' ; FIRST.DQUOTE = ''
                        END
                     END
                  END ELSE
* Since this got to be the second occurance of double quote.
                     FIRST.DQUOTE = ''
                     FIRST.SQUOTE = '' ; WITHIN.DQUOTE = ''
* This is because it is the end of the string for eg.
* PRINT "abc'def;" . After the rightmost dquote, there is no need
* of WITHIN.DQUOTE since the string within dquotes is finished.
                  END
               END
            CASE CH = YSTR[1,1]
*
               IF YLINE[CH.POS,LEN(YSTR)] = YSTR THEN
*
* Well if the FIRST.DQUOTE and FIRST.SQUOTE is not set, then the
* string is not within any quotes, so raise the alarm !!!
*
                  IF NOT(FIRST.DQUOTE) AND NOT(FIRST.SQUOTE) THEN
                     STRING.WITHIN.QUOTES = 0 ; STRING.WITHIN.QUOTES.POS = CH.POS
                     EXIT
                  END
               END
         END CASE
         CH.POS+=1
      REPEAT
      RETURN
*
**
*
   END
