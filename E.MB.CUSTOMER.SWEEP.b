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
* <Rating>-53</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.CUSTOMER.SWEEP(ENQ.DATA)
*-----------------------------------------------------------------------------
* Subroutine Type : Subroutine

* Incoming        : ENQ.DATA

* Outgoing        : ENQ.DATA Common Variable

* Attached to     : ENQUIRY CUSTOMER.SWEEP.SCV

* Attached as     : Build Routine in the Field BUILD.ROUTINE

* Primary Purpose :  The main purpose of this routine is used to Get the Account No for a Customer,from the
*                    Customer Number Which is given in the Selection Field in an enquiry CUSTOMER.SWEEP.SCV.
*                    and Read the Sweep ids belongs to that Account if
*                    duplicates(if from and to account belongs to the same customer two sweep ids will be updated for one sweep in a file AC.ACCOUNT.LINK.CONCAT)
*                    present remove the duplicates Sweep ids.


* Incoming        : Common variable ENQ.DATA Which contains all the
*                 : enquiry selection criteria details

* Change History  :

* Version         : First Version
*----------------------------------------------------------------------------
* 03/02/15 - Defect 1237720/ Task 1241741
*            system failed to display the account sweep details even though the customer has the account sweep details present
*
* 30/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 30/06/15 - Defect : 1748557 / Task :  1779773
*            System would display sweep transaction details on the enquiry screen while providing customer no on the selection criteria.
*
************************************************************************
    $USING EB.DataAccess
    $USING AC.AccountOpening
    $USING RS.Sweeping

    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN

*------------
INITIALISE:
*------------
*Initialise the variables and open the respective files


    AC.SWEEP.ID = '' ; SWAP.ARRAY = '' ; ACCOUNT.ARRAY = ''

    CUS.NO = ENQ.DATA<4,1>
 * Remove the formed leading zeros.   
    CUS.NO = TRIM(CUS.NO,"0", "L")
   
    Y.ACC.ARRAY=''
    Y.FIELD.VALUE=''
    ACCOUNT.ARRAY.COUNT=''
    ACC.ARR.FIELD.VALUE=''

    RETURN


*--------
PROCESS:
*---------* Read a CUSTOMER.ACCOUNT file for getting a List of Account no for a Given a Customer Number
    REC.CUS.ACC.NO = AC.AccountOpening.tableCustomerAccount(CUS.NO,CUS.ERR)
    SEL.LIST = REC.CUS.ACC.NO

    GOSUB PROCESS.ARRAY

    RETURN
*---------------
PROCESS.ARRAY:
*--------------
* Select all the records from the file AC.ACCOUNT.LINK.CONCAT and read the records to form an array
* with distinct sweep id

    LOOP
        REMOVE AC.SWEEP.ID FROM SEL.LIST SETTING SW.MORE
    WHILE AC.SWEEP.ID:SW.MORE
        EB.DataAccess.FRead('F.AC.ACCOUNT.LINK.CONCAT',AC.SWEEP.ID,R.SWEEP.REC,F.AC.ACCT.LINK.CONCAT,SW.ERR1)
        ACCOUNT.SWEEP.ID = R.SWEEP.REC<1>
        LOCATE ACCOUNT.SWEEP.ID IN SWAP.ARRAY<1> SETTING SW.POS ELSE
        IF SWAP.ARRAY NE '' THEN
            SWAP.ARRAY := @FM : ACCOUNT.SWEEP.ID
        END ELSE
            SWAP.ARRAY = ACCOUNT.SWEEP.ID
        END
        IF ACCOUNT.ARRAY NE '' THEN
            ACCOUNT.ARRAY := @FM : AC.SWEEP.ID
        END ELSE
            ACCOUNT.ARRAY = AC.SWEEP.ID
        END
    END
    REPEAT

    CONVERT @FM TO " " IN ACCOUNT.ARRAY
    ENQ.DATA<2,1> = "ACCOUNT.ID"
    ENQ.DATA<3,1> = "EQ"
    ENQ.DATA<4,1> = ACCOUNT.ARRAY

    RETURN

    END
