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
* <Rating>-19</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.BUILD.DR.LATEST.DATE(ENQ.DATA)
*-----------------------------------------------------------------------------

* Subroutine Type : Subroutine

* Incoming        : ENQ.DATA

* Outgoing        : ENQ.DATA Common Variable

* Attached to     : STMT.ACCT.DR

* Attached as     : Build Routine in the Field BUILD.ROUTINE

* Primary Purpose : To get a latest record of a given Account from a file STMT.ACCT.DR

* Incoming        : Common variable ENQ.DATA Which contains all the
*                 : enquiry selection criteria details

* Change History  :

* Version         : First Version
*
* Modification History:
* =====================
*
* 05/08/13 - Defect 743883/ Task 749003
*            Performance Issue using I-DESC
*
* 30/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*-------------------------------------------------------------------------------------------------------------
    $USING AC.AccountOpening

    ACC.NUMBER = ENQ.DATA<4,1>          ;* Get the Account number from Enquiry Selection
*
* Form @ID with Account No and latest capitalisation date
    R.ACCOUNT = AC.AccountOpening.tableAccount(ACC.NUMBER,ERR.ACC)
    Y.DATE = R.ACCOUNT<AC.AccountOpening.Account.CapDateDrInt,1>                          ;*Get the latest date from account
    Y.LATEST.ID = ACC.NUMBER : '-' : Y.DATE                          ;*Form the latest @ID
    ENQ.DATA<2,1> = '@ID'
    ENQ.DATA<3,1> = 'EQ'
    ENQ.DATA<4,1> = Y.LATEST.ID

    RETURN
*-----------------------------------------------------------------------------

    END
