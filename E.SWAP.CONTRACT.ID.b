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
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
* Version 2 02/06/00  GLOBUS Release No. 200508 30/06/05
*
    $PACKAGE SW.Reports
    SUBROUTINE E.SWAP.CONTRACT.ID(ID.LIST)
*
*************************************************
*                                               *
*  Routine     : E.SWAP.CONTRACT.ID.            *
*                                               *
*************************************************
*                                               *
*  Description : Swap schedule enquiry.         *
*                                               *
*  Routine called from standard.selection rec   *
*  NOFILE.SWAP to set outgoing arg ID.LIST to   *
*  the swap contract id.                        *
*  The swap schedule enquiry uses ID.LIST       *
*  within the data build routine                *
*  E.SW.FUTURE.SCHEDULE.                        *
*                                               *
*************************************************
*                                               *
*  Modifications :                              *
*      
* 30/12/15 - Enhancement 1226121
*		   - Task 1569212
*		   - Routine incorporated
*                                         *
*************************************************
*
    $USING EB.Reports

*
*************************************************
*
    ID.LIST = EB.Reports.getDRangeAndValue()        ; * Swap contract id.
*
    RETURN
*
*************************************************
*
    END
