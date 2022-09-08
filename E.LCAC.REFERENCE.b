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

* Version 1 20/10/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.ModelBank

    SUBROUTINE E.LCAC.REFERENCE(RTN.LIST)

*****************************************************************
*MODIFICATION.HISTORY
*****************************************************************
*
* 09/12/14 - Task : 1116645 / Enhancement : 990544
* 			 LC Componentization and Incorporation
*
*****************************************************************************************
    $USING EB.Reports
    $USING LC.ModelBank
    $USING EB.DataAccess
    $USING LC.Foundation


    EB.Reports.setRRecord("")
    LCAC.ERR = ""
    RTN.LIST = EB.Reports.getDRangeAndValue()<1>
    EB.Reports.setRRecord(LC.Foundation.tableAccountBalances(RTN.LIST[1,12], LCAC.ERR))
    IF NOT(EB.Reports.getRRecord()) THEN
        RTN.LIST = ''
    END
    RETURN
    END
