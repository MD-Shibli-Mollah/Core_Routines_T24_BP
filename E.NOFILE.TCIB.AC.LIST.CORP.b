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
* <Rating>-41</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE T4.ModelBank
    SUBROUTINE E.NOFILE.TCIB.AC.LIST.CORP(FINAL.ARRAY)
*-------------------------------------------------------------------------------------------------------
* Developed By : Temenos Application Management
* Program Name : E.NOFILE.TCIB.AC.LIST.CORP
*-----------------------------------------------------------------------------------------------------------------
* Description   : It's a  Nofile Enquiry used to Display the Current customers Accounts for version dropdown
* Linked With   : Standard.Selection for the Enquiry
* @Author       : kanand@temenos.com
* In Parameter  : NILL
* Out Parameter : FINAL.ARRAY
* Enhancement   : 696318
*-----------------------------------------------------------------------------------------------------------------

    $USING AC.AccountOpening
    $USING EB.SystemTables
*-----------------------------------------------------------------------------------------------------------------
* Modification Details:
*=====================
*
* 14/07/15 - Enhancement 1326996 / Task 1399947
*			 Incorporation of T components
*-----------------------------------------------------------------------------------------------------------------
    GOSUB INITILIZE
    GOSUB PROCESS
    RETURN
*-------------------------------------------------------------------------------------
**********
INITILIZE:
**********
    DEFFUN System.getVariable()

    FINAL.ARRAY = ''
    R.CUSTOMER.ACCOUNT = ''
    ERR.CUSTOMER.ACCOUNT = ''
    TOTAL.ID = ''
    Y.ID = 1

    RETURN
*-------------------------------------------------------------------------------------
*******
PROCESS:
********

    CURR.CUS.NO =  System.getVariable("EXT.SMS.CUSTOMERS")
    GOSUB READ.CUSTOMER.ACC

    ACC.LIST.SEE =  System.getVariable("EXT.SMS.ACCOUNTS")
    IF ACC.LIST.SEE NE 'EXT.SMS.ACCOUNTS' THEN
        TOTAL.ID = DCOUNT(ACC.LIST.SEE,@SM)
        LOOP
        WHILE Y.ID LE TOTAL.ID
            ACC.ID1 = FIELD(ACC.LIST.SEE,@SM,Y.ID)
            LOCATE ACC.ID1 IN R.CUSTOMER.ACCOUNT  SETTING POS1 THEN
            FINAL.ARRAY<-1> = ACC.ID1
        END
        Y.ID = Y.ID +1
    REPEAT
    END

    RETURN

*---------------------------------------------------------------------------------------------
******************
READ.CUSTOMER.ACC:
******************

    R.CUSTOMER.ACCOUNT = AC.AccountOpening.CustomerAccount.Read(CURR.CUS.NO,ERR.CUSTOMER.ACCOUNT)

    RETURN
*---------------------------------------------------------------------------------------------
    END
