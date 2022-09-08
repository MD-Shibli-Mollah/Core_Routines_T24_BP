* @ValidationCode : MjoyMDk4NDY3NTEzOkNwMTI1MjoxNTAzMzE1NjMyNzMzOm5zaGFtdWR1bmlzaGE6MTowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDguMjAxNzA3MDMtMjE0NzoxODoxOA==
* @ValidationInfo : Timestamp         : 21 Aug 2017 17:10:32
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nshamudunisha
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 18/18 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201708.20170703-2147
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE AC.ModelBank
SUBROUTINE E.BUILD.ACCOUNT.ALERTS(ENQ.DATA)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 21/08/17 - Defect 2233377 / Task 2241211
*            New build routine introduced to display correctly for AA accounts.
*
*-----------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING EB.Reports
    $USING AC.AccountOpening


    GOSUB INIT ; *

    IF NUM(ACCT.NO) THEN
        GOSUB PROCESS ; *
    END

RETURN
*-----------------------------------------------------------------------------

*** <region name= INIT>
INIT:
*** <desc> </desc>

    R.ACCOUNT = ''
    ACC.ERR = ''

    OLD.ENQ.DATA = ENQ.DATA

    LOCATE "CONTRACT.REF" IN ENQ.DATA<2,1> SETTING ACCT.POS THEN
        ACCT.NO = ENQ.DATA<4,ACCT.POS>
    END
   
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>

    R.ACCOUNT = AC.AccountOpening.Account.Read(ACCT.NO, ACC.ERR)

    ACCOUNT.ARR = R.ACCOUNT<AC.AccountOpening.Account.ArrangementId>

    IF ACCOUNT.ARR THEN
        ENQ.DATA<4,ACCT.POS> = ACCOUNT.ARR
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

END


