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
* Attached to     : ENQUIRY record AI.AA.AD.ARRANGEMENT.TAB
* Attached as     : Field Conversion Routine
*-------------------------------------------------------------------------------------------------
*Description:
*  Find the TERM from the application "AA.ARR.TERM.AMOUNT"
*-------------------------------------------------------------------------------------------------
*Modification History
*-------------------------------------------------------------------------------------------------

    $PACKAGE AA.ModelBank
    SUBROUTINE E.MB.AI.TERM

    $INSERT I_DAS.AA.ARR.TERM.AMOUNT

    $USING AA.TermAmount
    $USING EB.DataAccess
    $USING EB.Reports


    GOSUB INITIALISE
    GOSUB OPENFILE
    GOSUB PROCESS

    RETURN

***********************
INITIALISE:
***********************

    F.TM=''

    ARR.ID=EB.Reports.getOData()

    THE.LIST=dastermamount

    THE.ARGS=ARR.ID:"..."

    RETURN

***********************
OPENFILE:
***********************

    RETURN

***********************
PROCESS:
***********************
    EB.DataAccess.Das("AA.ARR.TERM.AMOUNT",THE.LIST,THE.ARGS,'')

    SEL.LIST=THE.LIST

    LOOP

        REMOVE TM.ID FROM SEL.LIST SETTING POS

    WHILE TM.ID DO

        TM.DATE<1,-1>=FIELD(TM.ID,"-",3)


    REPEAT
    TM.ID.SORT=SORT(TM.DATE)

    TM.ID.CNT=DCOUNT(TM.ID.SORT,@FM)

    LAST.ID=TM.ID.SORT<TM.ID.CNT>

    TM.FINAL.ID=ARR.ID:"-COMMITMENT-":LAST.ID

    TM.REC = AA.TermAmount.ArrTermAmount.Read(TM.FINAL.ID, Y.ERR)
    EB.Reports.setOData(TM.REC<AA.TermAmount.TermAmount.AmtTerm>)

    RETURN

    END
