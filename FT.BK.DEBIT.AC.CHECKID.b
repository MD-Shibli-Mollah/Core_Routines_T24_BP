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

* Version n dd/mm/yy  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>-9</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FT.BulkProcessing
    SUBROUTINE FT.BK.DEBIT.AC.CHECKID
****************************************************************
* ID level validations for Bulk Debit of AC Txn type
****************************************************************
* 15/07/04 - BG_100006954
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
****************************************************************
    $USING EB.SystemTables
    $USING EB.TransactionControl
    $USING FT.BulkProcessing

* Validation and changes of the ID entered.  Set ERROR to 1 if in error.
    EB.SystemTables.setE('')

    EB.SystemTables.setIdNew(EB.SystemTables.getComi())
    EB.TransactionControl.FormatId("BKAC") ;* Format to BKOTyydddNNNNN;NN

    RETURN
    END
