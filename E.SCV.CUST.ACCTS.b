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
* <Rating>54</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.SCV.CUST.ACCTS(ENQ.DATA)
*-----------------------------------------------------------------------------
*
* Subroutine Type : BUILD Routine
* Attached to     : ACCOUNT.DETAILS.SCV
* Attached as     : Build Routine
* Primary Purpose : We need a way of retrieving all the accounts held by a customer along with
*                   account for which the customer is joint holder.
* Incoming:
* ---------
*
* Outgoing:
* ---------
*
* Error Variables:
* ----------------
*
*-----------------------------------------------------------------------------
*MODIFICATION HISTORY:
*********************
*
* 22/03/14 - DEFECT_932917 / TASK_947493
*            If the customer doesnot have primary account but the joint account, then the joint contract
*            is passed without customer account prefix.
*
* 05/05/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*----------------------------------------------------------------------------------

    $USING AC.AccountOpening
    $USING ST.Customer

    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB PROCESS

    RETURN          ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:

    LOCATE 'CUSTOMER' IN ENQ.DATA<2,1> SETTING CUS.CODE.POS THEN
    Y.CUST.ID = ENQ.DATA<4,CUS.CODE.POS>
    IF Y.CUST.ID THEN
        R.CUSTOMER.ACCOUNT = AC.AccountOpening.tableCustomerAccount(Y.CUST.ID,ERR.CU.AC)
        R.CUSTOMER.ACCOUNT = CHANGE(R.CUSTOMER.ACCOUNT,@FM," ")
        R.JOINT.CONTRACTS.XREF = ST.Customer.tableJointContractsXref(Y.CUST.ID, ERR.XREF)
        R.JOINT.CONTRACTS.XREF = CHANGE(R.JOINT.CONTRACTS.XREF,@FM," ")
        IF R.CUSTOMER.ACCOUNT OR R.JOINT.CONTRACTS.XREF THEN
            ENQ.DATA<2,CUS.CODE.POS> = '@ID'
            ENQ.DATA<3,CUS.CODE.POS> = 'EQ'

            * If the customer doesnot have primary account, then it is correct to send only the joint contract reference alone
            * without the prefix of the customer account.

            IF R.CUSTOMER.ACCOUNT THEN
                ENQ.DATA<4,CUS.CODE.POS> = R.CUSTOMER.ACCOUNT:" ":R.JOINT.CONTRACTS.XREF
            END ELSE
                ENQ.DATA<4,CUS.CODE.POS> = R.JOINT.CONTRACTS.XREF
            END

        END ELSE
            ENQ.DATA<4,CUS.CODE.POS> = Y.CUST.ID
        END
    END
    END

    RETURN
*-----------------------------------------------------------------------------------
INITIALISE:

    Y.CUST.ID = ''

    RETURN          ;* From INITIALISE
*-----------------------------------------------------------------------------------
OPEN.FILES:

    RETURN          ;* From OPEN.FILES
*-----------------------------------------------------------------------------------
    END
