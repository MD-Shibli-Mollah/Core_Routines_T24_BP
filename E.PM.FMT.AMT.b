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
* <Rating>85</Rating>
*-----------------------------------------------------------------------------
* Version 4 29/09/00  GLOBUS Release No. 200508 30/06/05

    $PACKAGE PM.Reports
    SUBROUTINE E.PM.FMT.AMT

* This routine is one of a set of routines which may be used by PM
* enquiries to format amounts using the signing conventions defined
* on a given PM.ENQ.PARAM record. Each routine formats the amount
* passed in O.DATA as either a pure asset / liability amount or as
* an amount representing the diference between an asset and liabilty.
* Each routine will also scale the amount by a given factor.

* This routine formats amounts according to the rules on PM.ENQ.PARAM
* for pure asset or liability amounts.
* All amounts will be returned rounded to the correct number of decimals
* for the currency defined in PM$CCY.
*
*-----------------------------------------------------------------------------
* M O D I F I C A T I O N S
*-----------------------------------------------------------------------------
* 08/03/14 - Defect 631804 / Task 934729
*            The Amounts field in the core enquiries are not formatted correctly.
*            when the navigation of the pages handled by the new tSS session.
*
* 26/10/15 - EN_1226121 / Task 1511358
*	      	 Routine incorporated
*
*-----------------------------------------------------------------------------


    $USING PM.Config
    $USING PM.ModelBank
    $USING PM.Reports
    $USING EB.Reports


    tmp.O.DATA = EB.Reports.getOData()
    IF NOT(NUM(tmp.O.DATA)) THEN RETURN

    BEGIN CASE
        CASE PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqAmountFormat) = 'MI'
            FACTOR = 1000000
        CASE PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqAmountFormat) = 'TH'
            FACTOR = 1000
        CASE PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqAmountFormat) = ''
            FACTOR = ''
    END CASE
    FLAG = 'PURE'

    AMT = EB.Reports.getOData()

*When navigation of the core enquiry pages handled by the new tSS,reload the common variable for amount formation(include sign and commas)
    IF PM.Config.getRPmEnqParam(5) = 0 THEN
        PM.ModelBank.EPmInitCommon()
    END

    PM.Reports.EPmFormatSignAmt(FACTOR, FLAG)

    RETURN


******
    END
