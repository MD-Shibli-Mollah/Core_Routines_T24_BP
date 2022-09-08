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
* <Rating>-31</Rating>
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Subroutine type : SUBROUTINE
* Attached to     : ENQUIRY record AI.AA.DETAILS.TERMS.AMOUNT
* Attached as     : Field Conversion Routine
*-------------------------------------------------------------------------------------------------
*Description:
*  Find the settlement account from the application "AA.ARR.SETTLEMENT"
*-------------------------------------------------------------------------------------------------
*Modification History
*-------------------------------------------------------------------------------------------------

    $PACKAGE AA.ModelBank
    SUBROUTINE E.AI.INTEREST.ACCOUNT

    $INSERT I_DAS.AA.ARR.SETTLEMENT

    $USING AA.Settlement
    $USING EB.DataAccess
    $USING EB.Reports


    GOSUB INITIALISE
    GOSUB OPENFILE
    GOSUB PROCESS

    RETURN

***********************
INITIALISE:
***********************

    Y.ERR = ''
    
    F.SETTLEMENT=''

    ARR.ID=EB.Reports.getOData()

    THE.LIST=dassettlementaccount

    THE.ARGS=ARR.ID:"..."

    RETURN

***********************
OPENFILE:
***********************

    RETURN

***********************
PROCESS:
***********************

    EB.DataAccess.Das("AA.ARR.SETTLEMENT",THE.LIST,THE.ARGS,'')

    SEL.LIST=THE.LIST

    LOOP

        REMOVE ARR.SET.ID FROM SEL.LIST SETTING POS

    WHILE ARR.SET.ID DO

        SET.DATE<1,-1>=FIELD(ARR.SET.ID,"-",3)


    REPEAT

    SET.ID.SORT=SORT(SET.DATE)

    SET.ID.CNT=DCOUNT(SET.ID.SORT,@FM)

    LAST.ID=SET.ID.SORT<SET.ID.CNT>

    SET.FINAL.ID=ARR.ID:"-SETTLEMENT-":LAST.ID

    INT.AC.REC = AA.Settlement.ArrSettlement.Read(SET.FINAL.ID, Y.ERR)

    EB.Reports.setOData(INT.AC.REC<AA.Settlement.Settlement.SetPayoutAccount>)

    RETURN

    END
