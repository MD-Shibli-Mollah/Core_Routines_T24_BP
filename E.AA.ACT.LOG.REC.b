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
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.ACT.LOG.REC
*********************************
*Subroutine to update the Nofile enquiry for activity log history
*
*Logic - O.DATA returns the IDS which is nothing but
*the numbers we updated in the routine E.AA.ACTIVITY.LOG
*use it to get the position from LOG.LIST and return the results
*
****************
* MODIFICATION HISTORY
*
* 29 Apr 2014 - Task: 985127
*               Ref : 983039
*               Usage of common variable removed and instead lower the details
* 
*********************************
    $USING EB.Reports
    
****************

    ITEM.NO = EB.Reports.getOData()          ;*Locate the position
    EB.Reports.setRRecord(RAISE(ITEM.NO));*Details were lowered.

    RETURN
**************************************
