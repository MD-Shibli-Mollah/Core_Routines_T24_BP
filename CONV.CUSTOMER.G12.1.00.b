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
* <Rating>550</Rating>
*-----------------------------------------------------------------------------
* Version 4 06/06/01  GLOBUS Release No. 200511 31/10/05
*
* Reserved field9 used as Issue.Cheques
* Routine to check and update Chq.Is.Restrict with 'YES', if Cheque has
* been issued to any of the account of this Customer.
*

    $PACKAGE ST.Customer
      SUBROUTINE CONV.CUSTOMER.G12.1.00
*
* 20/11/01 - CI_10000520
*            Rewritten the entire routine for converting
*            multi company areas
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY
$INSERT I_F.CUSTOMER

      GOSUB INITIALISE
      GOSUB SELECT.RECORDS
      ID.COMPANY = SAVE.ID.COMPANY
      RETURN                             ; * Exit program

*----------
INITIALISE:
*----------


      SAVE.ID.COMPANY = ID.COMPANY
      FN.COMPANY = 'F.COMPANY'
      F.COMPANY = ''
      CALL OPF(FN.COMPANY ,F.COMPANY)
      RETURN


*--------------
SELECT.RECORDS:
*--------------

      SEL.CMD = 'SELECT F.COMPANY WITH CONSOLIDATION MARKER EQ "N"'
      COM.LIST = ''
      YSEL = 0

      CALL EB.READLIST(SEL.CMD,COM.LIST,'',YSEL,'')

      LOOP
         REMOVE K.COMPANY FROM COM.LIST SETTING END.OF.COMPANIES
      WHILE K.COMPANY:END.OF.COMPANIES
         IF K.COMPANY <> ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
         END
         FN.CUSTOMER.ACCOUNT = 'F.CUSTOMER.ACCOUNT'
         FV.CUSTOMER.ACCOUNT = ''
         CALL OPF(FN.CUSTOMER.ACCOUNT,FV.CUSTOMER.ACCOUNT)
*
         FN.CHEQUE.REGISTER = 'F.CHEQUE.REGISTER'
         FV.CHEQUE.REGISTER = ''
         CALL OPF(FN.CHEQUE.REGISTER,FV.CHEQUE.REGISTER)
*
         CUS.ACC.SEL = 'SELECT ':FN.CUSTOMER.ACCOUNT
         CUST.ACCT.ID.LIST = ''
         TTL.CUS.ACC = ''
         CUS.ACC.READ.ERR = ''
         CALL EB.READLIST(CUS.ACC.SEL, CUST.ACCT.ID.LIST, '', TTL.CUS.ACC, CUS.ACC.READ.ERR)
*
         IF NOT(TTL.CUS.ACC) THEN
            CRT 'No Records to process (Conv.Customer.G12.1)'
         END ELSE
            CHQ.REG.SEL = 'SELECT ':FN.CHEQUE.REGISTER
            CHEQ.REG.ID.LIST = ''
            TTL.CHQ.REG = ''
            CHQ.REG.READ.ERR =''
            CALL EB.READLIST(CHQ.REG.SEL, CHEQ.REG.ID.LIST, '', TTL.CHQ.REG,CHQ.REG.READ.ERR)
            CONVERT '.' TO @VM IN CHEQ.REG.ID.LIST

            IF NOT(TTL.CHQ.REG) THEN
               CRT 'No Records in Cheque.Register (Conv.Customer.G12.1)'
            END

            GOSUB PROCESS.RECORDS
         END
      REPEAT
      RETURN

*---------------
PROCESS.RECORDS:
*---------------
      FOR FILE.TYPE = 1 TO 3
         BEGIN CASE
            CASE FILE.TYPE EQ 1
               SUFFIX = ""
            CASE FILE.TYPE EQ 2
               SUFFIX = "$NAU"
            CASE FILE.TYPE EQ 3
               SUFFIX = "$HIS"
         END CASE
*
         FN.CUSTOMER = 'F.CUSTOMER':SUFFIX
         FV.CUSTOMER = ''
         CALL OPF(FN.CUSTOMER,FV.CUSTOMER)
         LOOP
            REMOVE CUST.ACC.ID FROM CUST.ACCT.ID.LIST SETTING JS.POS
         WHILE CUST.ACC.ID:JS.POS
            CUST.ACCT.REC = ''           ; * Reinitialise Customer.Account Record
            CALL F.READ(FN.CUSTOMER.ACCOUNT, CUST.ACC.ID, CUST.ACCT.REC, FV.CUSTOMER.ACCOUNT, CUST.READ.ERR)
            IF CUST.ACCT.REC THEN
               TTL.ACCTS = DCOUNT(CUST.ACCT.REC, FM)
               FOR JS.CNT = 1 TO TTL.ACCTS
                  ACCT.NUM = CUST.ACCT.REC<JS.CNT>
                  U.FM = '' ; U.VM = '' ; U.SM = ''
                  FIND ACCT.NUM IN CHEQ.REG.ID.LIST SETTING U.F, U.V, U.S THEN
                     CUST.REC = ''       ; * Reinitialise Customer Record
                     CALL F.READ(FN.CUSTOMER, CUST.ACC.ID, CUST.REC, FV.CUSTOMER, CUST.READ.ERR)
                     IF NOT(CUST.READ.ERR) THEN
                        CUST.REC<34> = 'YES'
                        GOSUB UPDATE.AUDIT.FIELDS
                        CALL F.WRITE(FN.CUSTOMER, CUST.ACC.ID, CUST.REC)
                        CALL JOURNAL.UPDATE(CUST.ACC.ID)
                        U.EXIT.FLAG = 0
                        U.FM = ''
                        U.VM = ''
                        U.SM = ''
                        LOOP UNTIL U.EXIT.FLAG EQ 1
                           FIND ACCT.NUM IN CHEQ.REG.ID.LIST SETTING U.FM, U.VM, U.SM THEN
                              DEL CHEQ.REG.ID.LIST<U.FM>
                           END ELSE
                              U.EXIT.FLAG = 1
                           END
                        REPEAT
                        EXIT
                     END ELSE
                        TEXT = CUST.READ.ERR
                        CALL FATAL.ERROR('CONV.CUSTOMER.G12.1')
                     END
                  END
               NEXT JS.CNT
            END
         REPEAT

      NEXT FILE.TYPE
      RETURN


UPDATE.AUDIT.FIELDS:
*-------------------
      CUST.REC<44> = TNO:'_':'CONV.CUSTOMER.G12.1.00'
      J.X = OCONV(DATE(),'D-')
      TIME.STAMP = TIMEDATE()
      DATE.TIME = J.X[9,2]:J.X[1,2]:J.X[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]
      CUST.REC<45> = DATE.TIME
      RETURN
   END
