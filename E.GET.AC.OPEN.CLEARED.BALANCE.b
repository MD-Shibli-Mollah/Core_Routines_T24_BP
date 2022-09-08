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
    $PACKAGE AC.ModelBank

    SUBROUTINE E.GET.AC.OPEN.CLEARED.BALANCE
*-----------------------------------------------------------------------------
*
* Consversion routine which gets the account ID in O.DATA and
* returns the Balance
*
*******************************************************************************\
*           MODIFICATION HISTORY
*******************************************************************************
*
* 09/06/2011 - EN-182574 / TASK 255332
*              Introduced new conversion routine for enquiry
*
* 23/08/2013 - Defect 762538
*              No need to merge the ECB every time for geting OPEN ACTUAL balance.
*              Use Account service routine to get balance directly from
*              EB.CONTRACT.BALANCES record.
*
* 29/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*******************************************************************************
*
    $USING EB.Reports
    $USING AC.CashFlow

    accountKey = EB.Reports.getOData()
    openClearedBal = ''
    response = ''

    AC.CashFlow.AccountserviceGetopenclearedbalance(accountKey, openClearedBal, response)

    EB.Reports.setOData(openClearedBal)

    RETURN
*-----------------------------------------------------------------------------

    END
