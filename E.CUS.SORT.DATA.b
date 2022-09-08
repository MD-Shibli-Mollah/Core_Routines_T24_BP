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

* Version 3 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>-5</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.ModelBank

    SUBROUTINE E.CUS.SORT.DATA(OUT.ORDER, IN.CAT, IN.SYSTEM)
*-----------------------------------------------------------------------------
*
** This subroutine will return the sorted code from EB.SYSTEM.ID
** for a given enquiry.
*
* MODIFICATION :
*
* 23/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*-----------------------------------------------------------------------------
    $USING ST.Customer
    $USING ST.ModelBank
*
    CP.REC = ""
    ST.ModelBank.CpGetRecord(CP.REC, IN.CAT, IN.SYSTEM)
    CONVERT ">]" TO @FM:@VM IN CP.REC
*
    OUT.ORDER = CP.REC<ST.Customer.CusPosEnqParam.CpeParSortPosition>
*
    RETURN
*
*-----------------------------------------------------------------------------
    END
