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
* <Rating>-30</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AI.ModelBank
    SUBROUTINE V.MB.AI.TO.DAO
*-----------------------------------------------------------------------------
* This routine is attached to the version EB.SECURE.MESSAGE,AI.NEW to populate the DAO
* of the customer to the field TO.DAO
*================================================================================================================
*                        M O D I F I C A T I O N S
*
* 14/09/10 - Task 76280
*            Change the reads to Customer to use the Customer
*            Service api calls
*
* 24/04/14 - Task 983288 / Defect 982274
*            ORIG.PARENT.MSG.ID field should be removed in EB.SECURE.MESSAGE application.
*
* 18/05/15 - Enhancement-1326996/Task-1327012
*			 Incorporation of AI components
*================================================================================================================

    $USING EB.ARC
    $USING EB.SystemTables
    $USING EB.ErrorProcessing

    $INSERT I_CustomerService_AccountOfficer

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN

INITIALISE:

    customerKey = EB.ErrorProcessing.getExternalCustomer()

    RETURN

PROCESS:

    customerAccountOfficer = ''
    CALL CustomerService.getAccountOfficer(customerKey,customerAccountOfficer)


    IF EB.SystemTables.getEtext() EQ '' AND EB.SystemTables.getRNew(EB.ARC.SecureMessage.SmToDao) EQ '' AND customerKey AND NOT(EB.SystemTables.getRNew(EB.ARC.SecureMessage.SmParentMessageId)) THEN
        EB.SystemTables.setRNew(EB.ARC.SecureMessage.SmToDao, customerAccountOfficer<AccountOfficer.accountOfficer>)
    END ELSE
        EB.SystemTables.setEtext('')
    END
    IF EB.SystemTables.getRNew(EB.ARC.SecureMessage.SmParentMessageId) EQ '' THEN
        EB.SystemTables.setRNew(EB.ARC.SecureMessage.SmParentMessageId, EB.SystemTables.getIdNew())
    END

    RETURN
    END
