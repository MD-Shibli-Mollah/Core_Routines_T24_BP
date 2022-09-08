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
* <Rating>260</Rating>
*-----------------------------------------------------------------------------
* Version 2 29/09/00  GLOBUS Release No. 200508 30/06/05
****
****
      $PACKAGE AC.AccountClosure
      SUBROUTINE CONV.ACCOUNT.AC.OFF
****
****
** To get Account Officer from Customer for all accounts which have
** blanks in the ACCOUNT.OFFICER field.
****
****
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.ACCOUNT
**
**
**
      F.ACCOUNT = ''
      ACCOUNT.FILE = "F.ACCOUNT" ; 
      CALL OPF(ACCOUNT.FILE, F.ACCOUNT)
      F.CUSTOMER = ''
      CALL OPF("F.CUSTOMER", F.CUSTOMER)
*
*
      SEL.SENT = "SELECT ":ACCOUNT.FILE:" WITH ACCOUNT.OFFICER EQ ''"
      SEL.SENT := " AND WITH CUSTOMER NE ''"
      EXECUTE SEL.SENT
      LOOP
         READNEXT ACC.ID FROM 0 ELSE ACC.ID= ''
      UNTIL ACC.ID = ''
         R.ACCOUNT = ''
         READ R.ACCOUNT FROM F.ACCOUNT, ACC.ID ELSE
            PRINT "ACCOUNT ":ACC.ID:" MISSING" ; 
            GOTO NEXT.ID
         END
         PRINT @(10,10):"Converting ":ACC.ID
         R.CUSTOMER = ''
         READ R.CUSTOMER FROM F.CUSTOMER, R.ACCOUNT<AC.CUSTOMER> ELSE
            PRINT "CUSTOMER ":R.ACCOUNT<AC.CUSTOMER>:" MISSING" ; 
            GOTO NEXT.ID
         END
         R.ACCOUNT<AC.ACCOUNT.OFFICER> = R.CUSTOMER<11>
         WRITE R.ACCOUNT TO F.ACCOUNT, ACC.ID
NEXT.ID:
      REPEAT
**
**
      RETURN
   END
