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
* <Rating>-11</Rating>
*-----------------------------------------------------------------------------
* Version n dd/mm/yy  GLOBUS Release No. 200511 31/10/05
*
    $PACKAGE FT.BulkProcessing
    SUBROUTINE FT.BK.DEBIT.OT.BEFORE.AUTH
***********************************************************************
* Routine to be processed Before authorisation that builds
* OFS string and calls OFS.GLOBUS.MANAGER for Bulk Debit of OT Txn type
***********************************************************************
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
************************************************************************
    $USING EB.SystemTables
    $USING FT.Contract
    $USING FT.BulkProcessing

    OUT.DATA = ''
    FT.Contract.DynMappingProcess(OUT.DATA)

    VM.CNT = DCOUNT(OUT.DATA<1>,@VM)
    FOR VM.POS = 1 TO VM.CNT
        CURR.MV.NO = OUT.DATA<1, VM.POS>          ;* Extract the MV position
        tmp=EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotOfsGenId); tmp<1,CURR.MV.NO>=OUT.DATA<2, VM.POS>; EB.SystemTables.setRNew(FT.BulkProcessing.BulkDrOt.BkdrotOfsGenId, tmp);* Store the TXN ids
        tmp=EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotOfsErrYN); tmp<1,CURR.MV.NO>=OUT.DATA<3, VM.POS>; EB.SystemTables.setRNew(FT.BulkProcessing.BulkDrOt.BkdrotOfsErrYN, tmp);* Indicate the TXNs with error
    NEXT VM.POS

    RETURN

    END
