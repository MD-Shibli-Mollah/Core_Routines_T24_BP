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

* Version n dd/mm/yy  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>124</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AZ.ModelBank
    SUBROUTINE E.AZ.REPAY.SCHEDULE(E.ARRAY)

* This routine used for Schedules enquiry AZ.REPAYMENT.SCH / AZ.REP.SCH.NAU
*
*------------------------------------------------------------------------------------------------*
* Modification History:
* ---------------------
* 13/01/05 - CI_10026342
*            New routine created
*
* 19/12/05 - EN_10002733
*            Show details related to Online Principal/Interest repayment
*            of loans only if SHOW.ONLINE.INFO selection field in enquiry
*            has the value as 'YES'.
* 02/02/06 - CI_10038653
*             1.Total online payment should be displated in AZ Loan enquiries
*             2. Online repayments are indicated by '**' preceding date.
*               As '*' is delimiter, we use 'O' to indicate the same.
*
* 03/07/06 - CI_10042332
*            Multiple drawdown amount should be displayed in AZ Loan enquiries.
*
* 07/06/10 - Task - 61994
*            Ref : Defect 52831
*            Interest capitalised online should be shown along with the online details.
*------------------------------------------------------------------------------------------------*
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.AZ.SCHEDULES
*
    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB GET.SELECTION
*

    RETURN
*
INITIALISE:
*==========
    SCHD.REC = '' ; SCHD.ERR = '' ; D.POS = ''
    CNT.VM = '' ; NXT.VM = '' ; E.ARRAY = ''
*
    RETURN
*
GET.SELECTION:
*=============
    LOCATE 'ACCOUNT.NO' IN D.FIELDS<1> SETTING D.POS ELSE RETURN

    ACCT.ID = D.RANGE.AND.VALUE<D.POS>

* EN_10002733 S
* Show details related to Online repayment of loans
* Only if SHOW.ONLINE.INFO selection field in enquiry
* has the value as 'YES'.

    INCLUDE.ONLINE.INFO = ''
    LOCATE 'SHOW.ONLINE.INFO' IN D.FIELDS<2> SETTING OI.POS THEN
        OI.VALUE = D.RANGE.AND.VALUE<OI.POS>
        IF OI.VALUE ='YES' THEN INCLUDE.ONLINE.INFO = 1
    END

* EN_10002733 E

    GOSUB GET.DETAILS
*
    RETURN
*
OPEN.FILES:
*==========
    IF DATA.FILE.NAME = 'NOFILE.AZ.SCHEDULES' THEN
        FN.AZ.SCHEDULES = 'F.AZ.SCHEDULES'
        FP.AZ.SCHEDULES = ''
        CALL OPF(FN.AZ.SCHEDULES,FP.AZ.SCHEDULES)
    END ELSE
        FN.AZ.SCHEDULES.NAU = 'F.AZ.SCHEDULES.NAU'
        FP.AZ.SCHEDULES.NAU = ''
        CALL OPF(FN.AZ.SCHEDULES.NAU,FP.AZ.SCHEDULES.NAU)
    END
*
    RETURN
*
GET.DETAILS:
*===========
    IF DATA.FILE.NAME = 'NOFILE.AZ.SCHEDULES' THEN
        CALL F.READ(FN.AZ.SCHEDULES,ACCT.ID,SCHD.REC,FP.AZ.SCHEDULES,SCHD.ERR)
    END ELSE
        CALL F.READ(FN.AZ.SCHEDULES.NAU,ACCT.ID,SCHD.REC,FP.AZ.SCHEDULES.NAU,SCHD.ERR)
    END

    CNT.VM = DCOUNT(SCHD.REC<AZ.SLS.DATE>,@VM)

    FOR NXT.VM = 1 TO CNT.VM
* EN_10002733 S
* If SHOW.ONLINE.INFO is 'YES' then display actual account balance during
* online repayment also.
        IF SCHD.REC<AZ.SLS.TYPE.B,NXT.VM> OR SCHD.REC<AZ.SLS.TYPE.B.SYS,NXT.VM> OR SCHD.REC<AZ.SLS.TYPE.P,NXT.VM> OR SCHD.REC<AZ.SLS.TYPE.I,NXT.VM> OR SCHD.REC<AZ.SLS.TYPE.C,NXT.VM> OR SCHD.REC<AZ.SLS.TOT.REPAY.AMT,NXT.VM> OR (SCHD.REC<AZ.SLS.ONLINE.AMT,NXT.VM> AND INCLUDE.ONLINE.INFO)  OR NXT.VM = '1' THEN  ;* CI_10042332 -S/E
            CALL AZ.GET.ACT.BALANCE(ACCT.ID,SCHD.REC<AZ.SLS.DATE,NXT.VM>,ACT.BALANCE)
* EN_10002733 E

            GOSUB FORMAT.ARRAY
        END
    NEXT NXT.VM
*
    RETURN
*
FORMAT.ARRAY:
*============
* EN_10002733 S
* If ONLINE REPAYMENT is alone present and there are no other schedule
* on corresponding date, then display online details along with the date
* ( ON.DATE is set withs scheduled date.).
* If any other schedule is present, then display details related to other
* schedules in the first row & then display Online repayment details
* in subsequent row without date( ON.DATE is reset).

    ON.DATE =SCHD.REC<AZ.SLS.DATE,NXT.VM>
* EN_10002733 E
    IF NXT.VM = 1 THEN
        IF SCHD.REC<AZ.SLS.TYPE.B,NXT.VM> OR SCHD.REC<AZ.SLS.TYPE.B.SYS,NXT.VM> OR SCHD.REC<AZ.SLS.TYPE.P,NXT.VM> OR SCHD.REC<AZ.SLS.TYPE.I,NXT.VM> OR SCHD.REC<AZ.SLS.TYPE.C,NXT.VM> OR SCHD.REC<AZ.SLS.TOT.REPAY.AMT,NXT.VM>  THEN  ;* CI_10042332 -S/E
            E.ARRAY<-1> = SCHD.REC<AZ.SLS.DATE,NXT.VM>:'*':SCHD.REC<AZ.SLS.TOT.REPAY.AMT,NXT.VM>:'*':SCHD.REC<AZ.SLS.TYPE.P,NXT.VM>:'*':SCHD.REC<AZ.SLS.TYPE.I,NXT.VM>:'*':SCHD.REC<AZ.SLS.TYPE.N,NXT.VM>:'*':SCHD.REC<AZ.SLS.TYPE.C,NXT.VM>:'*':SCHD.REC<AZ.SLS.TYPE.B,NXT.VM>:'*':SCHD.REC<AZ.SLS.TOT.TAX,NXT.VM>:'*':SCHD.REC<AZ.SLS.SCHEDULE.BAL,NXT.VM>:'*':ACT.BALANCE:'*':SUM(SCHD.REC<AZ.SLS.NEW.AMOUNT>)

        END ELSE
            E.ARRAY<-1> = ' ':'*':' ':'*':' ':'*':' ':'*':' ':'*':' ':'*':' ':'*':' ':'*':SCHD.REC<AZ.SLS.SCHEDULE.BAL,NXT.VM>:'*':ACT.BALANCE:'*':SUM(SCHD.REC<AZ.SLS.NEW.AMOUNT>)
        END
    END ELSE
        IF SCHD.REC<AZ.SLS.TYPE.B,NXT.VM> OR SCHD.REC<AZ.SLS.TYPE.B.SYS,NXT.VM> OR SCHD.REC<AZ.SLS.TYPE.P,NXT.VM> OR SCHD.REC<AZ.SLS.TYPE.I,NXT.VM> OR SCHD.REC<AZ.SLS.TYPE.C,NXT.VM> OR SCHD.REC<AZ.SLS.TOT.REPAY.AMT,NXT.VM>  THEN  ;* CI_10042332 -S/E
            E.ARRAY<-1> = SCHD.REC<AZ.SLS.DATE,NXT.VM>:'*':SCHD.REC<AZ.SLS.TOT.REPAY.AMT,NXT.VM>:'*':SCHD.REC<AZ.SLS.TYPE.P,NXT.VM>:'*':SCHD.REC<AZ.SLS.TYPE.I,NXT.VM>:'*':SCHD.REC<AZ.SLS.TYPE.N,NXT.VM>:'*':SCHD.REC<AZ.SLS.TYPE.C,NXT.VM>:'*':SCHD.REC<AZ.SLS.TYPE.B,NXT.VM>:'*':SCHD.REC<AZ.SLS.TOT.TAX,NXT.VM>:'*':SCHD.REC<AZ.SLS.SCHEDULE.BAL,NXT.VM>:'*':ACT.BALANCE

        END

    END
* EN_10002733 S
* Show online repayment details ONLY if Principal/Interest is repaid online
    IF INCLUDE.ONLINE.INFO AND SCHD.REC<AZ.SLS.ONLINE.AMT,NXT.VM> THEN
        ONLINE.P.AMT =' ' ; ONLINE.N.AMT = ' '
        ONLINE.AMOUNT = SCHD.REC<AZ.SLS.ONLINE.AMT,NXT.VM>
        FINDSTR 'P-' IN ONLINE.AMOUNT SETTING FMP,VMP,SMP THEN
            ONLINE.P.AMT = FIELD(ONLINE.AMOUNT<FMP,VMP,SMP>, '-', 2)
        END
        FINDSTR 'N-' IN ONLINE.AMOUNT SETTING FMN,VMN,SMN THEN
            ONLINE.N.AMT = FIELD(ONLINE.AMOUNT<FMN,VMN,SMN>, '-', 2)
        END
        IF ONLINE.P.AMT OR ONLINE.N.AMT THEN
* CI_10038653 S
* Indicate total online payment
            TOT.ONLINE.PAYMENT = ONLINE.P.AMT + ONLINE.N.AMT
            IF SCHD.REC<AZ.SLS.TYPE.I,NXT.VM> THEN
                E.ARRAY<-1> =  ON.DATE:'O*':TOT.ONLINE.PAYMENT:'*':ONLINE.P.AMT:'*':' ':'*':ONLINE.N.AMT:'*':' ':'*':' ':'*':' ':'*':SCHD.REC<AZ.SLS.SCHEDULE.BAL,NXT.VM>:'*':ACT.BALANCE:'*':SUM(SCHD.REC<AZ.SLS.NEW.AMOUNT>)
            END ELSE
                TOT.CAP.INT = SCHD.REC<AZ.SLS.ACT.I.AMT,NXT.VM>
                E.ARRAY<-1> =  ON.DATE:'O*':TOT.ONLINE.PAYMENT:'*':ONLINE.P.AMT:'*':TOT.CAP.INT:'*':ONLINE.N.AMT:'*':' ':'*':' ':'*':' ':'*':SCHD.REC<AZ.SLS.SCHEDULE.BAL,NXT.VM>:'*':ACT.BALANCE:'*':SUM(SCHD.REC<AZ.SLS.NEW.AMOUNT>)
            END
* CI_10038653 E
        END
    END
* EN_1002733 E


*
    RETURN
*
END
