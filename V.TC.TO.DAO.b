* @ValidationCode : MTozMTk5NjIwNDQ6VVRGLTg6MTQ3MDA2Mjk2MzQ5NTpyc3VkaGE6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTYwNy4x
* @ValidationInfo : Timestamp         : 01 Aug 2016 20:19:23
* @ValidationInfo : Encoding          : UTF-8
* @ValidationInfo : User Name         : rsudha
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201607.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
    $PACKAGE EB.Channels
    SUBROUTINE V.TC.TO.DAO
*-----------------------------------------------------------------------------
* This routine is attached to the version EB.SECURE.MESSAGE,TC to populate the DAO
* of the customer to the field TO.DAO
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Changes done in the sub-routine </desc>
* Modification history:
*-----------------------
* 24/05/16 - Enhancement 1694532 / Task 1741992
*            Populate the TO.DAO field and parent message id
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>

    $USING EB.ARC
    $USING EB.SystemTables
    $USING EB.ErrorProcessing
    $INSERT I_CustomerService_AccountOfficer

*** </region>
*-----------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main processing </desc>

    GOSUB INITIALISE
    GOSUB PROCESS

*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise commons and required varaibles </desc>
INITIALISE:
*---------
* Get customer id and other required details
    customerKey = EB.ErrorProcessing.getExternalCustomer()
    EB.SystemTables.setEtext('')
    TO.DAO = EB.SystemTables.getRNew(EB.ARC.SecureMessage.SmToDao)
    PARENT.MSG.ID = EB.SystemTables.getRNew(EB.ARC.SecureMessage.SmParentMessageId)
    RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc> Populate required fields </desc>
PROCESS:
*------
    customerAccountOfficer = ''
    CALL CustomerService.getAccountOfficer(customerKey,customerAccountOfficer) ;* Get account officer value from customer record

    IF EB.SystemTables.getEtext() EQ '' AND NOT(TO.DAO) AND customerKey AND NOT(PARENT.MSG.ID) THEN ;* Assign customer account officer value with TO.DAO
        EB.SystemTables.setRNew(EB.ARC.SecureMessage.SmToDao, customerAccountOfficer<AccountOfficer.accountOfficer>)
    END ELSE
        EB.SystemTables.setEtext('')
    END
    IF NOT(PARENT.MSG.ID) THEN ;*Set parent message id
        EB.SystemTables.setRNew(EB.ARC.SecureMessage.SmParentMessageId, EB.SystemTables.getIdNew())
    END

    RETURN
*** </region>
*----------------------------------------------------------------------------
    END
