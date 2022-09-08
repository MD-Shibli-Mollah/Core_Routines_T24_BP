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
* <Rating>-40</Rating>
*-----------------------------------------------------------------------------
* Version n dd/mm/yy  GLOBUS Release No. 200511 31/10/05
*
    $PACKAGE FT.BulkProcessing
    SUBROUTINE FT.BK.CREDIT.OC.CHECK.RECORD
************************************************************************
* Building up the record details
************************************************************************
* 28/07/04 - BG_100007014
*            New Version
*
* 01/08/05 - CI_10032367
*            CROSS COMPILATION
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
************************************************************************
    $USING EB.SystemTables
    $USING FT.BulkProcessing

    GOSUB INITIALISE
    GOSUB RECORD.VALIDATIONS
    GOSUB FIELD.VALIDATIONS

    RETURN


INITIALISE:
***********

    RETURN


RECORD.VALIDATIONS:
*******************
* Restrict any amendment to the record
    IF EB.SystemTables.getIdOld() = EB.SystemTables.getIdNew() THEN
        IF INDEX("I",EB.SystemTables.getVFunction(),1) THEN
            EB.SystemTables.setE('FT.FT.TRANSFER.ALREADY.AUTH.1')
            RETURN
        END
    END

    RETURN

FIELD.VALIDATIONS:
******************

    IF INDEX('C',EB.SystemTables.getVFunction(),1) THEN
        * Clear the following fields during 'C' funtion
        EB.SystemTables.setRNew(FT.BulkProcessing.BulkCreditOc.BkcrocTreasuryRate, '')
        EB.SystemTables.setRNew(FT.BulkProcessing.BulkCreditOc.BkcrocCustomerRate, '')
        EB.SystemTables.setRNew(FT.BulkProcessing.BulkCreditOc.BkcrocCustomerSpread, '')
        EB.SystemTables.setRNew(FT.BulkProcessing.BulkCreditOc.BkcrocOfsGenId, '')
        EB.SystemTables.setRNew(FT.BulkProcessing.BulkCreditOc.BkcrocOfsErrYN, '')
        EB.SystemTables.setRNew(FT.BulkProcessing.BulkCreditOc.BkcrocOverride, '')
    END

* Default the Txn type to 'OC'
    EB.SystemTables.setRNew(FT.BulkProcessing.BulkCreditOc.BkcrocTransactionType, 'OC')

    RETURN

    END
