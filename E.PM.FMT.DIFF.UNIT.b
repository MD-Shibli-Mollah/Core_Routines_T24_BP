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
* <Rating>91</Rating>
*-----------------------------------------------------------------------------
* Version 2 02/06/00  GLOBUS Release No. 200508 30/06/05
    $PACKAGE PM.Reports
    SUBROUTINE E.PM.FMT.DIFF.UNIT

* This routine is one of a set of routines which may be used by PM
* enquiries to format amounts using the signing conventions defined
* on a given PM.ENQ.PARAM record. Each routine formats the amount
* passed in O.DATA as either a pure asset / liability amount or as
* an amount representing the diference between an asset and liabilty.
* Each routine will also scale the amount by a given factor.

* This routine formats amounts according to the rules on PM.ENQ.PARAM
* for asset / liability difference amounts.
* All amounts will be returned rounded to the nearest whole unit.
*********
*********** Modification History ************************************
*
* 26/10/15 - EN_1226121 / Task 1511358
*	      	 Routine incorporated
*---------------------------------------------------------------------------------------------
    $USING PM.Reports
    $USING EB.Reports


    tmp.O.DATA = EB.Reports.getOData()
    IF NOT(NUM(tmp.O.DATA)) THEN RETURN

    FACTOR = 1
    FLAG = 'DIFF'

    AMT = EB.Reports.getOData()

    PM.Reports.EPmFormatSignAmt(FACTOR, FLAG)

    RETURN


******
    END
