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

* Version 3 25/10/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>927</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.EntryCreation
      SUBROUTINE CONV.CATEG.ENT.TODAY
*
* 03/03/92 - HY9200669
*            Replace READLIST with call to EB.READLIST
*
* 02/07/92 - GB9200598
*            Write entry key in record.
*
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.CATEG.ENTRY
*
      YF.CATEG.ENT.TODAY = "F.CATEG.ENT.TODAY"
      F.CATEG.ENT.TODAY = ""
      CALL OPF(YF.CATEG.ENT.TODAY,F.CATEG.ENT.TODAY)
*
      YF.CATEG.MONTH = "F.CATEG.MONTH"
      F.CATEG.MONTH = ""
      CALL OPF(YF.CATEG.MONTH,F.CATEG.MONTH)
      F.CATEG.ENTRY = ""
      CALL OPF("F.CATEG.ENTRY",F.CATEG.ENTRY)
*
*###      SAVE.LIST.ID = ID.COMPANY:".CONV.CATEG.ENT.TODAY"
*###      EXECUTE "DELETE.LIST ": SAVE.LIST.ID
*###      EXECUTE "SELECT ":YF.CATEG.ENT.TODAY:" WITH @ID MATCHES '1N0N'"
*###      EXECUTE "SAVE.LIST ": SAVE.LIST.ID
*###      READLIST YCATEGORIES FROM SAVE.LIST.ID ELSE
*###         YCATEGORIES = ""
*###      END
*
      PRINT @(5,9):
      SELECT.COMMAND = "SELECT ":YF.CATEG.ENT.TODAY
*#### :" WITH @ID MATCHES '1N0N'"
      YCATEGORIES = ""
      CALL EB.READLIST(SELECT.COMMAND, YCATEGORIES, "CONV.CATEG", "", "")
*
      PRINT @(5,6): "Converting CATEG.ENT.TODAY ":
*
      LOOP
         REMOVE YCAT FROM YCATEGORIES SETTING YDELIM
         IF YCAT THEN
            PRINT @(5,7):"Converting ":YCAT
            READ YR.CAT.ENT.TODAY FROM F.CATEG.ENT.TODAY, YCAT THEN
*
               IF INDEX(YCAT,"-",1) THEN           ; * Converted already
                  YR.CAT.ENT.TODAY = YCAT["-",4,1]           ; * Entry id
                  WRITE YR.CAT.ENT.TODAY TO F.CATEG.ENT.TODAY, YCAT
               END ELSE
                  LOOP
                     REMOVE YCAT.ENT.ID FROM YR.CAT.ENT.TODAY SETTING YID.DELIM
                     IF YCAT.ENT.ID THEN
                        READ YR.CATEG.ENTRY FROM F.CATEG.ENTRY,YCAT.ENT.ID THEN
                           YNEW.ID = YR.CATEG.ENTRY<AC.CAT.PL.CATEGORY>:"-":YR.CATEG.ENTRY<AC.CAT.SYSTEM.ID>:"-":YR.CATEG.ENTRY<AC.CAT.CURRENCY>:"-":YCAT.ENT.ID
                           WRITE YCAT.ENT.ID TO F.CATEG.ENT.TODAY,YNEW.ID
                        END ELSE NULL
                     END
                  UNTIL YID.DELIM = 0
                  REPEAT
                  DELETE F.CATEG.ENT.TODAY,YCAT
               END
            END ELSE NULL
         END
      UNTIL YDELIM = 0
      REPEAT
*
*
*
*-----------------------------------------------------------------------
*
      PRINT @(5,6):"Converting CATEG.MONTH         ":
*
      PRINT @(5,9):
      EXECUTE "SSELECT ": YF.CATEG.MONTH
*
*
      LOOP READNEXT ID ELSE ID = "" WHILE ID
*
         IF ID[".",3,1] THEN
            GOTO NEXT.ID
         END
*
         PRINT @(5,7):"Converting ": ID:
         READ R.MAIN FROM F.CATEG.MONTH, ID ELSE GOTO NEXT.ID
         IF R.MAIN<1> LT 10000 THEN
            CATEG.SEQU = R.MAIN<1>
            DEL R.MAIN<1>
         END ELSE
            CATEG.SEQU = 0
         END
*
         R.CATEG.MONTH = ""
         FOR I = 1 TO CATEG.SEQU
            READ R.SPLIT FROM F.CATEG.MONTH, ID:".":I ELSE R.SPLIT= ""
            IF R.SPLIT<1> LT 10000 THEN
               DEL R.SPLIT<1>            ; * Tidy up old rubbish
            END
            R.CATEG.MONTH<-1> = R.SPLIT
         NEXT
         R.CATEG.MONTH<-1> = R.MAIN      ; * Add main record to list
         CATEG.SEQU = 0
         LOOP ENTRY.COUNT = COUNT(R.CATEG.MONTH,@FM)+1 UNTIL ENTRY.COUNT < 199
            R.SPLIT = R.CATEG.MONTH[@FM,1,199]
            CATEG.SEQU +=1
            WRITE R.SPLIT TO F.CATEG.MONTH, ID:".":CATEG.SEQU
            R.CATEG.MONTH = R.CATEG.MONTH[@FM,200,999999]    ; * Remainder
         REPEAT
         IF CATEG.SEQU THEN
            INS CATEG.SEQU BEFORE R.CATEG.MONTH<1>
         END
         WRITE R.CATEG.MONTH TO F.CATEG.MONTH, ID  ; * Put it back
*
NEXT.ID:
      REPEAT
*
*
*----------------------------------------------------------------------
*
      RETURN
   END
