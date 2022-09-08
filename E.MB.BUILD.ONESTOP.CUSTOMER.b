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
* <Rating>-27</Rating>
*-----------------------------------------------------------------------------
*
* This subroutine is a build routine which gets the customer number from the user
* and returns the list of PW.ACTIVITY.TXN records created for processing that customer
*------------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.BUILD.ONESTOP.CUSTOMER(enqData)

* Attached as     : Build Routine to F.ENQUIRY>ONE.STOP.ITEMS.FOR.CUSTOMER
*
*----------------------------------------------------------------------------
* @author         : srajadurai@temenos.com
*----------------------------------------------------------------------------
*Modification History
*
* 04/04/09 - BG_100023504
*            DAS conversion of the routine E.MB.BUILD.ONESTOP.CUSTOMER
*            that is attched as build routine to the ENQUIRY>ONE.STOP.ITEMS.FOR.CUSTOMER
*
* 02/09/10 - 42147: Amend Infrastructure routines to use the Customer Service API's
*
*----------------------------------------------------------------------------
    $INSERT I_DAS.PW.ACTIVITY.TXN
    $INSERT I_CustomerService_Key

    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.DataAccess
    $USING PW.Foundation

    GOSUB Initialise
    GOSUB SelectProcess

    RETURN

Initialise:

    processIds = ''

    R.PW.ACTIVITY.TXN.REC = ''
    PWAT.ERR = ''

    RETURN

SelectProcess:

    LOCATE 'PROCESS' IN enqData<2,1> SETTING transPos THEN
    customerNo = enqData<4,transPos>
    END

    mnemonic = customerNo
    customerKey = ''
    CALL CustomerService.getCustomerForMnemonic(mnemonic, customerKey)
    IF EB.SystemTables.getEtext() NE '' THEN
        customerNo =  customerKey<Key.customerID>
    END ELSE
        EB.SystemTables.setEtext('')
    END

    TABLE.NAME = "PW.ACTIVITY.TXN"
    DAS.LIST   = dasPwActivityTxn
    ARGUMENTS  = customerNo
    TABLE.SUFFIX = ''

    EB.DataAccess.Das(TABLE.NAME, DAS.LIST, ARGUMENTS, TABLE.SUFFIX)

    LOOP

        REMOVE PW.TXN.ID FROM DAS.LIST SETTING PW.TXN.POS

    WHILE PW.TXN.POS

        R.PW.ACTIVITY.TXN.REC = PW.Foundation.ActivityTxn.Read(PW.TXN.ID, PWAT.ERR)
        processIds = R.PW.ACTIVITY.TXN.REC<PW.Foundation.ActivityTxn.ActTxnProcess> : ' ':processIds
        enqData<4,transPos> = processIds
    REPEAT

    RETURN
