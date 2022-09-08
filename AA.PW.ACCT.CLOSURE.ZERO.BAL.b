* @ValidationCode : Mjo0ODUwNTU2MDg6Q3AxMjUyOjE1NjQ1NTI0MTcxOTM6YXJvb2JhOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDcuMjAxOTA2MTItMDMyMToxNToxNA==
* @ValidationInfo : Timestamp         : 31 Jul 2019 11:23:37
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : arooba
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 14/15 (93.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190612-0321
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-42</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AR.ModelBank
SUBROUTINE AA.PW.ACCT.CLOSURE.ZERO.BAL(RET.ERR)
*-----------------------------------------------------------------------------
*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*
* This routine is used in PW.TRANSITION and is used to determine if the account has balance.
* If the balance is zero then PW process should not trigger AA.ACCOUNT.CLOSURE.DETAILS.
*-----------------------------------------------------------------------------
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Arguments>
*** <desc>Input and output arguments required for the sub-routine</desc>
* Arguments
*
* Output
*
* @param  RET.ERR - If there is balance in the account then we return "TRUE".
*
*** </region>
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Modification History :
*
* 17/11/15 - DEFECT: 1517715
*            TASK  : 1535740
*            When the account balance is zero process workflow should not allow to popup AA.ACCOUNT.CLOSURE.DETAILS.
*
* 04/01/16 - DEFECT: 1588776
*			 TASK  : 1588778
*            Uploaded under defenitions folder instead of Source.
*
* 26/07/19 - DEFECT: 3233568
*            TASK  : 3251259
*            ACCOUNT.CLOSURE PW flow does not triggering the next activity INPUT.SETTLE.ACTIVITY if the account has the balance amount.
*
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts
    $USING EB.SystemTables
    $USING AA.Framework
    $USING AA.Accounting

*    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
*    $INSERT I_F.AA.ARRANGEMENT
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>main control logic in the sub-routine</desc>

    GOSUB INITIALIZE
    GOSUB GET.BALANCE
RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>File variables and local variables</desc>
INITIALIZE:

    ARR.ID = EB.SystemTables.getRNew(AA.Framework.SimulationRunner.SimArrangementRef)   ;* Arrangement Reference
    PROD.DATE = EB.SystemTables.getToday()
    
RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get Balance>
*** <desc>Get the account balance</desc>

GET.BALANCE:

    AA.Framework.GetArrangement(ARR.ID,R.ARRANGEMENT,ARR.ERR)

    LOCATE "ACCOUNT" IN R.ARRANGEMENT<AA.Framework.ArrangementSim.ArrLinkedAppl,1> SETTING LINK.POS THEN
        ACC.NO = R.ARRANGEMENT<AA.Framework.ArrangementSim.ArrLinkedApplId,LINK.POS>
    END

    AA.Accounting.GetAcctBalance(ACC.NO,"","",PROD.DATE,"",BAL.AMOUNT,"","",BAL.ERR)

    IF BAL.AMOUNT THEN
        RET.ERR = "TRUE"
    END
RETURN

*** </region>
*-----------------------------------------------------------------------------

END
