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
* <Rating>-4</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CR.ModelBank
    SUBROUTINE E.CR.FIND.CUSTOMER(ENQUIRY.DATA)
*------------------------------------------------------------------------------
* This is the build routine of the enquiry CR.FIND.CUSTOMER
* This routine reads Account and gets the correspoding customer no
* and changes the select criteria to be based on customer no
*-------------------------------------------------------------------------------
* 
* 13/06/06 - BG_100011201 ( CRM Phase1)
*            Creation
*            Ref:SAR-2005-12-06-0005
*
*------------------------------------------------------------------------------
    
    $USING AC.AccountOpening
    

    LOCATE 'ACCOUNT' IN ENQUIRY.DATA<2,1> SETTING POS THEN
        ACC.ID = ENQUIRY.DATA<4,POS>

        F.ACCOUNT = 'F.ACCOUNT'
        R.ACCOUNT = ''
        ER = ''
        R.ACCOUNT = AC.AccountOpening.Account.Read(ACC.ID, ER)

        CUST.ID = R.ACCOUNT<AC.AccountOpening.Account.Customer>
        ENQUIRY.DATA<2,POS> = '@ID'
        ENQUIRY.DATA<4,POS> = CUST.ID
        ENQUIRY.DATA<3,POS> = 'EQ'

    END
    RETURN
END
