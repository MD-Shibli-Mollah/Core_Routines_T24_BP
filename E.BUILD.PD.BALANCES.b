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

* Version 2 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PD.ModelBank
    SUBROUTINE E.BUILD.PD.BALANCES(ENQUIRY.DATA)
**************************************************************************
*
* This routine checks for user defined periods or defines some if none
* have been entered.
*
* 08/10/97 - GB9701100
*
* 19/04/10 - Defect id - 29369 ; Task id - 41829
*            Performance Tunning. Removal of i-des from selection.
*
* 11/07/13 - Defect id - 713714 ; Task id - 725985
*            Performance Tunning. If condition has been added before the SELECT statement.
*
* 15/02/16 - Defect id - 1627615 ; Task id - 1632542
*            Performance Tunning. To check for those customers having no PD records.

*****************************************************************************************

    $USING PD.Config
    $USING EB.Reports

*  check that periods exist or create some
    GOSUB INIT.CHECK
    IF R.PD.CUSTOMER THEN
        GOSUB BUILD.SELECTION
    END


    RETURN
*----------
INIT.CHECK:
*----------
    F.PD.CUSTOMER = "F.PD.CUSTOMER"
    FN.PD.CUSTOMER = "";R.PD.CUSTOMER = "";CUST.ERROR = ""

    CUSTOMER.COND = 0 ; CUSTOMER.POS = 0
*
    LOCATE 'CUSTOMER.NO' IN ENQUIRY.DATA<2,1> SETTING CUSTOMER.POS THEN
    CUSTOMER.COND = 1
    R.PD.CUSTOMER = PD.Config.Customer.Read(ENQUIRY.DATA<4,CUSTOMER.POS>, CUST.ERROR)
    END
*
	IF CUST.ERROR NE '' THEN
		EB.Reports.setEnqError('No records matched the selection criteria')
	END
	
    PERIODS.COND = 0; PERIODS.POS = 0

    LOCATE 'PERIODS' IN ENQUIRY.DATA<2,1> SETTING PERIODS.POS THEN
    PERIODS.COND = 1
    END



    RETURN
*------------------
BUILD.SELECTION:
*-----------------
    IF CUSTOMER.COND AND NOT(CUST.ERROR) THEN
        CONVERT @FM TO " " IN R.PD.CUSTOMER
        ENQUIRY.DATA<2,CUSTOMER.POS> = '@ID'
        ENQUIRY.DATA<3,CUSTOMER.POS> = 'CT'
        ENQUIRY.DATA<4,CUSTOMER.POS> = R.PD.CUSTOMER
    END

    IF NOT(PERIODS.COND) THEN
        ENQUIRY.DATA<2,PERIODS.POS> = 'PERIODS'
        ENQUIRY.DATA<3,PERIODS.POS> = 'EQ'
        ENQUIRY.DATA<4,PERIODS.POS> = '30 60 90'
    END

    RETURN

    END

