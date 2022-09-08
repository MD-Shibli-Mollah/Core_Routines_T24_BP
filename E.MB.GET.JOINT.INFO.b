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
* <Rating>-27</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.GET.JOINT.INFO
*-----------------------------------------------------------------------------
*Description:
*           Conversion routine attached to the enquiry ACCOUNT.DETAILS.SCV
*           to display the joint holder data as Yes/NULL. It gets the current customer
*           present in !CURRENT.CUSTOMER variable and check's againg the customer
*           number passed from the enquiry if it is equal it send's "" else "Yes" via O.DATA
*-----------------------------------------------------------------------------
*
*Modification History:
*
*
*-----------------------------------------------------------------------------

    $USING EB.Reports

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN

*-----------------------------------------------------------------------------
INITIALISE:
*-----------------------------------------------------------------------------
* Initialise variables and open required files

    Y.CURR.CUST = ""
    CALL System.getUserVariables(YR.VARIABLE.NAMES,YR.VARIABLE.VALUES)
    LOCATE 'CURRENT.CUSTOMER' IN YR.VARIABLE.NAMES SETTING YR.POS.1 THEN
    Y.CURR.CUST = YR.VARIABLE.VALUES<YR.POS.1>
    END

    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------

* Get the account number from O.DATA. Read the file ACCT.ENT.FWD
* Populate the entries in R.RECORD<200>

    Y.CUST = EB.Reports.getOData()

    IF Y.CURR.CUST EQ Y.CUST THEN
        EB.Reports.setOData("")
    END ELSE
        EB.Reports.setOData("Yes")
    END

    RETURN

*-----------------------------------------------------------------------------
