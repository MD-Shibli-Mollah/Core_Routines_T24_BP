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

*
*Subroutine to get the Basic Debit interest of the ACCOUNT given in the Enquiry
*-----------------------------------------------------------------------------
* <Rating>130</Rating>
*-----------------------------------------------------------------------------
*
    $PACKAGE IC.ModelBank
    SUBROUTINE E.MB.IC.DEB.BASIC
*
* Attached to     : ENQUIRY>ACC.CURRENT.INT
*--------------------------------------------------------------------------------------------------
* Modification History
* 06/11/08       -   BG_100019949
*                    Mb Routine Standardisation
*
* 04/08/11       -   Task 357262 / Defect 248715
*                    Changes done to display the allignment correctly
*                    When int rate is null it update with previous rate value. This process is removed here
*                    and it introduced in E.MB.IC.RATE.CHANGE routine.
*
* 16/05/13 - Task 676249
*            Performance problem in the enquiry ACC.CURRENT.INT. A common variable is introduce to
*            hold the data return by the routine E.MB.IC.RATE.CHANGE. If there is any record present
*            in this common varible then using this value instead of calling the E.MB.IC.RATE.CHANGE
*            routine.
*--------------------------------------------------------------------------------------------------

    $USING IC.ModelBank
    $USING EB.Reports

*
    GOSUB INITIALISE

    IF EB.Reports.getEnqSelection() THEN
        OUT.DATA = ''
        GOSUB GET.DATES
    END ELSE
        * This routine can only be called from an enquiry
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
    GOSUB PROCESS
    RETURN

**********
GET.DATES:
**********

    CURRENT.RATE = ''         ;* Set if called with 1 date
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

    LOCATE "ACCOUNT.NUMBER" IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN
    AC1.NO = EB.Reports.getEnqSelection()<4,POS>
    END ELSE
    AC1.NO = ''
    END

    IF END.DATE = '' THEN
        CURRENT.RATE = 1      ;* Return rates effective on date passed
    END
    RETURN

********
PROCESS:
********
    IF NOT(IC.ModelBank.getMbIcReturnData()) THEN      ;* If this value is null then call the routine to get the data
        IC.ModelBank.EMbIcRateChange(AC.NO, START.DATE, END.DATE, RET.DATA, "")
        IC.ModelBank.setMbIcReturnData(RET.DATA)
    END ELSE
        RET.DATA = IC.ModelBank.getMbIcReturnData()
    END

    RATE.CHANGE.DATES = FIELD(RET.DATA,'#',2)
    RET.DATA = FIELD(RET.DATA,'#',1)

    NO.OF.DATES = DCOUNT(RET.DATA<1>, @VM)
    FOR I = 1 TO NO.OF.DATES
        GOSUB UPD.FOR.DR.TYPE

        * Increment line count to keep description, credits and debits in sync
        CR.CNT = DCOUNT(RET.DATA<IC.RC.CREDIT.BAND.RATE, I>, @SM)
        DR.CNT = DCOUNT(RET.DATA<IC.RC.DEBIT.BAND.RATE, I>, @SM)
        IF CR.CNT > DR.CNT THEN
            CNT += CR.CNT - DR.CNT
        END

    NEXT I
    OUT.DATA = LOWER(OUT.DATA)
*
    NO.OF.RATES = DCOUNT(OUT.DATA,@VM)
    CNT11 = ""
    CNT11 = 402
    tmp=EB.Reports.getRRecord(); tmp<402>=""; EB.Reports.setRRecord(tmp)

    FOR RATE.CNT = 1 TO NO.OF.RATES
        IF OUT.DATA<1,RATE.CNT> EQ '' THEN
            tmp=EB.Reports.getRRecord(); tmp<402,-1>=0; EB.Reports.setRRecord(tmp)
        END ELSE
            tmp=EB.Reports.getRRecord(); tmp<402,-1>=OUT.DATA<1,RATE.CNT>; EB.Reports.setRRecord(tmp)
        END
    NEXT RATE.CNT
    RETURN
************************************************************************
INITIALISE:
*==========

    LOCATE "ACCOUNT.NUMBER" IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN
    AC1.NO = EB.Reports.getEnqSelection()<4,POS>
    END ELSE
    AC1.NO = ''
    END

    AC.NO = AC1.NO
    CNT = 0

    IC.RC.CREDIT.BAND.RATE = 4
    IC.RC.DEBIT.RATE.TYPE = 5
    IC.RC.DEBIT.BAND.UPTO = 6
    IC.RC.DEBIT.BAND.RATE = 7

    RETURN
*
************************************************************************
UPD.FOR.DR.TYPE:
*===============

    BEGIN CASE
        CASE RET.DATA<IC.RC.DEBIT.RATE.TYPE,I> = 'F'
            CNT += 1
            OUT.DATA<CNT> := FIELD(RET.DATA<IC.RC.DEBIT.BAND.RATE, I>,'$',2)

        CASE RET.DATA<IC.RC.DEBIT.RATE.TYPE,I> = 'B'
            IF RET.DATA<IC.RC.DEBIT.BAND.RATE, I, 1> NE '' THEN
                CNT += 1
                OUT.DATA<CNT> := FIELD(RET.DATA<IC.RC.DEBIT.BAND.RATE, I, 1>,'$',2)
            END
            NO.OF.RATES = DCOUNT(RET.DATA<IC.RC.DEBIT.BAND.RATE,I>, @SM)

            IF NO.OF.RATES = 1 THEN
***            *OUT.DATA<CNT> := " over ":FMT(RET.DATA<IC.RC.DEBIT.BAND.UPTO, I, 1>,'L,0')
            END ELSE

                IF RET.DATA<IC.RC.DEBIT.BAND.UPTO, I, 1> NE '' THEN
***                *OUT.DATA<CNT> := " from 0 up to ":FMT(RET.DATA<IC.RC.DEBIT.BAND.UPTO, I, 1>,'L,0')
                END
                FOR J = 2 TO NO.OF.RATES
                    IF RET.DATA<IC.RC.DEBIT.BAND.RATE, I, J> NE '' THEN

                        CNT += 1
                        OUT.DATA<CNT> = FIELD(RET.DATA<IC.RC.DEBIT.BAND.RATE, I, J>,'$',2)

***                    OUT.DATA<CNT> = FIELD(RET.DATA<IC.RC.DEBIT.BAND.RATE, I, J>,'$',2)
***                    *OUT.DATA<CNT> := FMT(RET.DATA<IC.RC.DEBIT.BAND.UPTO, I, J-1>,'L,0')

                        IF J <> NO.OF.RATES THEN
***                        *OUT.DATA<CNT> := " up to ":FMT(RET.DATA<IC.RC.DEBIT.BAND.UPTO, I, J>,'L,0')

                        END
                    END
                NEXT J
            END

        CASE RET.DATA<IC.RC.DEBIT.RATE.TYPE,I> = 'L'
            NO.OF.RATES = DCOUNT(RET.DATA<IC.RC.DEBIT.BAND.RATE,I>, @SM)
            IF NO.OF.RATES GT 1 THEN
                FOR J = 1 TO NO.OF.RATES
                    CNT += 1      ;* BG_100010575 S/E
                    IF J NE NO.OF.RATES THEN

                        OUT.DATA<CNT> = FIELD(RET.DATA<IC.RC.DEBIT.BAND.RATE, I, J>,'$',2)

***                    OUT.DATA<CNT> = FIELD(RET.DATA<IC.RC.DEBIT.BAND.RATE, I, J>,'$',2)
***                    *OUT.DATA<CNT> := FMT(RET.DATA<IC.RC.DEBIT.BAND.UPTO, I, J>,'L,0')

                    END ELSE

                        OUT.DATA<CNT> = FIELD(RET.DATA<IC.RC.DEBIT.BAND.RATE, I, J>,'$',2)

***                    OUT.DATA<CNT> = FIELD(RET.DATA<IC.RC.DEBIT.BAND.RATE, I, J>,'$',2)
***                    *OUT.DATA<CNT> := FMT(RET.DATA<IC.RC.DEBIT.BAND.UPTO, I, J-1>,'L,0')

                    END
                NEXT J
            END ELSE

                CNT += 1
                OUT.DATA<CNT> := FIELD(RET.DATA<IC.RC.DEBIT.BAND.RATE, I, 1>,'$',2)
***            OUT.DATA<CNT> := FIELD(RET.DATA<IC.RC.DEBIT.BAND.RATE, I, 1>,'$',2)

            END
    END CASE
*
    RETURN
    END
