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

*--------------------------------------------------------...
*-----------------------------------------------------------------------------
* <Rating>599</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE T2.ModelBank 
    SUBROUTINE E.TC.TERM.DETAILS
*-----------------------------------------------------------------------------
* Subroutine type : SUBROUTINE
* Attached to     : ENQUIRY record TCIB.AA.AD.ARRANGEMENT.TAB
* Attached as     : Field Conversion Routine
*-------------------------------------------------------------------------------------------------
* Description:
*  Find the TERM,AMOUNT and SETTLEMENT ACCOUNT
*-------------------------------------------------------------------------------------------------
* Modification History
* 13/01/16 - Defect 1596309 / Task 1597891
*            TCIB-Performance tuning
*-------------------------------------------------------------------------------------------------

    $USING EB.Reports
    $USING AA.TermAmount
    $USING AA.Settlement 
    $USING AA.Interest
    $USING AA.Framework 
*
    GOSUB INITIALISE
    GOSUB PROCESS
*
    RETURN
*------------------------------------------------------------------------------------------------
INITIALISE:
*Initialise required variables
    ARR.ID = EB.Reports.getOData():'//AUTH'  ;*Take the authorised arrangement of the active channel
    PROPERTY.CLASS = 'TERM.AMOUNT'      ;* Initialise Term Amount property class
    R.TERM.AMOUNT=''          ;* Initialise Term Amount Arrangement Record
    R.SETTLEMENT='' ;* Initialise Settlement Arrangement Record
    RET.ERR=''      ;*Initialise Record Error
*
    RETURN
*----------------------------------------------------------------------------------------------------
PROCESS:
* Process to get Term , Amount and Settlement Account
    AA.Framework.GetArrangementConditions(ARR.ID,PROPERTY.CLASS,'','',PROPERTY.IDS,R.TERM.AMOUNT,RET.ERR)        ;* Get arrangement condition record
*
    R.TERM.AMOUNT= RAISE(R.TERM.AMOUNT) ;* Term Amont Record
    PROPERTY.CLASS='SETTLEMENT'
    AA.Framework.GetArrangementConditions(ARR.ID,PROPERTY.CLASS,'','',PROPERTY.IDS,R.SETTLEMENT,RET.ERR)         ;* Get arrangement condition record
    R.SETTLEMENT=RAISE(R.SETTLEMENT)    ;* Settlement Record
    PROPERTY.CLASS='INTEREST'
    AA.Framework.GetArrangementConditions(ARR.ID,PROPERTY.CLASS,'','',PROPERTY.IDS,R.INTEREST,RET.ERR)         ;* Get arrangement condition record
    R.INTEREST=RAISE(R.INTEREST)   ;* Interest Record
    INT.RATE=R.INTEREST<AA.Interest.Interest.IntEffectiveRate,1>
    INT.RATE = FMT(INT.RATE,'7R4')
    EB.Reports.setOData(R.TERM.AMOUNT<AA.TermAmount.TermAmount.AmtTerm>:"*":R.TERM.AMOUNT<AA.TermAmount.TermAmount.AmtAmount>:"*":R.SETTLEMENT<AA.Settlement.Settlement.SetPayoutAccount>:"*":INT.RATE);* Return array
*
    RETURN
*-------------------------------------------------------------------------------------------------------
END
