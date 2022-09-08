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

* Version 7 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>29</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE IC.ModelBank
    SUBROUTINE E.IC.RATE.CHANGE.DESC(OUT.DATA,AC1.NO,START.DATE,END.DATE)
*
************************************************************************
* Description:                                                         *
* ============                                                         *
*                                                                      *
*                                                                      *
*                                                                      *
************************************************************************
* Modification Log:                                                    *
* =================                                                    *
*                                                                      *
* 04/03/98 - GB9800155                                                 *
*            Initial version                                           *
*                                                                      *
*                                                                      *
* 12/10/98 - GB9801259
*            Return the effective rate when no end date is supplied
*                                                                      *
* 26/10/98 - GB9801323
*            Correct narrative for final band
*            If level type is specified on the debit side only
*            then the rates would be displayed on the credit's side.
*                                                                      *
* 10/11/98 - GB9801359
*            Don't insert values into OUT array where rates do not
*            exist
*
* 12/01/99 - GB9900037
*            Rates not displayed correctly where ACI and GCI both exist
*            (ACI should take precedence)
*
* 30/06/04 - CI_10020990
*            The enquiry ACC.CURRENT.INT produces incorrect results.This is because
*            in E.IC.RATE.CHANGE, wrong format was assigned to ICONV 'DE/ ' instead of 'DE'.
*
* 13/08/04 - CI_10022073
*            Enquiry produces incorrect results when an account has GCI,ACI and ADI.
*
* 01/09/04 - CI_10022759
*            Changes included to show correct data in the enquiry ACC.CURRENT.INT
*
* 18/11/05 - CI_10036580 / REF:HD0515730
*            Bug fix to display enquiry correctly when it has mixed
*            rate combinations.
*
* 13/03/06 - BG_100010575
*            Created from E.IC.RATE.CHANGE to separate the description
*            from the rest of the output.
*
* 09/08/10 - Defect 68450 / Task 74689
*            Aligned the description accordingly, while BASIC.INTEREST
*            records exists.
*
* 28/03/11 - Defect 178208 / Task 178273
*            Initialised the varibale PREV.CNT.
*
* 04/08/11 - Task 249110 / Defect 248715
*            Changes done to display the allignment correctly.
*            E.MB.IC.RATE.CHANGE routine is used to get the information
*
* 16/05/13 - Task 676249
*            Performance problem in the enquiry ACC.CURRENT.INT. A common
*            variable is introduce to hold the data return by the routine
*            E.MB.IC.RATE.CHANGE. If there is any record present in this
*            common varible then using this value instead of calling the
*            E.MB.IC.RATE.CHANGE routine.
************************************************************************
*
    $USING IC.ModelBank
    $USING EB.Reports

*
    GOSUB INITIALISE
*
    OUT.DATA = ''
    IF EB.Reports.getEnqSelection() THEN
        CURRENT.RATE = ''     ;* Set if called with 1 date
        LOCATE "START.DATE" IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN
        START.DATE = EB.Reports.getEnqSelection()<4,POS>
    END ELSE
        RETURN
    END
*
    LOCATE "END.DATE" IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN
    END.DATE = EB.Reports.getEnqSelection()<4,POS>
    END ELSE
    END.DATE = ''
    END
    IF END.DATE = '' THEN CURRENT.RATE = 1    ;* Return rates effective on date passed
    END ELSE
*
* This routine can only be called from an enquiry
*
    RETURN
    END
*
* Check whether the account number, start date and end date are not same. If not then nullify the
* MB.IC.RETURN.DATA so that this will recalculate again
*
    IF AC.NO NE IC.ModelBank.getMbIcAcctNo() OR IC.ModelBank.getMbIcStartDate() NE START.DATE OR IC.ModelBank.getMbIcEndDate() NE END.DATE THEN
        IC.ModelBank.setMbIcAcctNo(AC.NO)
        IC.ModelBank.setMbIcStartDate(START.DATE)
        IC.ModelBank.setMbIcEndDate(END.DATE)
        IC.ModelBank.setMbIcReturnData('')
    END
*
    IF NOT(IC.ModelBank.getMbIcReturnData()) THEN      ;* If this value is null then call the routine to get the data
        IC.ModelBank.EMbIcRateChange(AC.NO, START.DATE, END.DATE, RET.DATA, "")
        IC.ModelBank.setMbIcReturnData(RET.DATA)
    END ELSE
        RET.DATA = IC.ModelBank.getMbIcReturnData()
    END
*
    RATE.CHANGE.DATES = FIELD(RET.DATA,'#',2)
    RET.DATA = FIELD(RET.DATA,'#',1)

* BG_100010575 Lines removed
*
    INT.DATES = ''
    INT.DATES = RAISE(RATE.CHANGE.DATES<1>)
    NO.OF.DATES = DCOUNT(RET.DATA<1>, @VM)
    FOR I = 1 TO NO.OF.DATES
        * BG_100010575 Lines removed
        DTE = RET.DATA<1,I>
        DTE = DTE[7,2]:"/":DTE[5,2]:"/":DTE[1,4]
        DTE = OCONV(ICONV(DTE,'DE'),'DE')         ;* CI_10020990 S/E
        IF CURRENT.RATE THEN
            OUT.DATA<CNT> = "Effective interest rates on ":DTE
        END ELSE
            OUT.DATA<CNT> = "Interest Rates changed with effect from ":DTE
        END
        * BG_100010575 S
        * Increment line count to keep description, credits and debits in sync.
        CR.CNT = DCOUNT(RET.DATA<IC.RC.CREDIT.BAND.RATE, I>, @SM)
        DR.CNT = DCOUNT(RET.DATA<IC.RC.DEBIT.BAND.RATE, I>, @SM)
        IF CR.CNT > DR.CNT THEN
            CNT += CR.CNT
        END ELSE
            CNT += DR.CNT
        END
        * BG_100010575 E
        * BG_100010575 Lines removed
    NEXT I
    OUT.DATA = LOWER(OUT.DATA)
*
    RETURN
************************************************************************
*
INITIALISE:
*==========
*
    AC.NO = AC1.NO
    CNT = 1         ;* EN_100010575 S/E
* BG_100010575 Lines removed
    IC.RC.CREDIT.BAND.RATE = 4
* BG_100010575 Lines removed
    IC.RC.DEBIT.BAND.RATE = 7
* BG_100010575 Lines removed

    RETURN
* BG_100010575 Lines removed

    END
