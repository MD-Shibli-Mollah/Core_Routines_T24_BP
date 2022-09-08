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
* <Rating>-7</Rating>
*-----------------------------------------------------------------------------
* Version n dd/mm/yy  GLOBUS Release No. 200508 30/06/05
*
    $PACKAGE FT.BulkProcessing
    SUBROUTINE FT.BK.CREDIT.AC.CHECKID
************************************************************************
* ID level validations
************************************************************************
* 29/06/04 - EN_10002298
*            New Version
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
************************************************************************
    $USING EB.SystemTables
    $USING EB.TransactionControl
    $USING FT.BulkProcessing
* Validation and changes of the ID entered.  Set ERROR to 1 if in error.
    EB.SystemTables.setE('')

    EB.SystemTables.setIdNew(EB.SystemTables.getComi())
    EB.TransactionControl.FormatId("BKAC") ;* Format to BKOTyydddNNNNN;NN

    RETURN
    END
*-----------------------------------------------------------------------------
