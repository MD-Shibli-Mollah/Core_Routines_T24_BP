* @ValidationCode : MjoxMTQwNzAwMDI1OkNwMTI1MjoxNTY0NTcwODkyNzUwOnNyYXZpa3VtYXI6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxOTA4LjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 Jul 2019 16:31:32
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>435</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqEnquiry
SUBROUTINE E.HIS.STS(YID.LIST)
*
*****************************************************************
* 23/10/01 - GLOBUS_BG_100000159
*            Inclusion of Date as optional selection
*            criteria.
*
* 05/02/07 - EN_10003187
*            Data Access Service - Application changes
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Enquiry as ST_ChqEnquiry and include $PACKAGE
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
*
* 1/5/2017 - Enhancement 1765879 / Task 2094697
*            Remove dependency of code in ST products
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
*****************************************************************
*
    $USING CQ.ChqIssue
    $USING CQ.ChqFees
    $USING CQ.ChqConfig
    $USING EB.SystemTables
    $USING EB.Reports

    $INSERT I_DAS.CHEQUE.CHARGE.BAL     ;* EN_10003187 S/E

    LOCATE 'ACCT.NO' IN EB.Reports.getDFields()<1> SETTING POS ELSE POS=''
    ACC.NO = EB.Reports.getDRangeAndValue()<1,POS>
* BG_100000159 - S
    LOCATE 'ST.DATE' IN EB.Reports.getDFields()<1> SETTING POS1 ELSE POS1=''
    LOCATE 'END.DATE' IN EB.Reports.getDFields()<1> SETTING POS2 ELSE POS2=''
    DATE1 = EB.Reports.getDRangeAndValue()<POS1>
    DATE2 = EB.Reports.getDRangeAndValue()<POS2>
    IF DATE2 = '' THEN DATE2 = EB.SystemTables.getToday()
    IF DATE1 NE '' AND DATE2 NE '' THEN
* EN_10003187 S
        THE.LIST = DAS.CHEQUE.CHARGE.BAL$ACCT.STATUSDATE
        THE.ARGS = ''
        THE.ARGS<1> = ACC.NO
        THE.ARGS<2> = DATE1
        THE.ARGS<3> = DATE2
        CALL DAS("CHEQUE.CHARGE.BAL",THE.LIST ,THE.ARGS,'')
* EN_10003187 E
    END ELSE
* BG_100000159 - E
* EN_10003187 S
        THE.LIST = DAS.CHEQUE.CHARGE.BAL$ACCT
        THE.ARGS = ''
        THE.ARGS<1> = ACC.NO
        CALL DAS("CHEQUE.CHARGE.BAL",THE.LIST,THE.ARGS,'')
    END   ;* BG_100000159 S/E
    SEL.LIST = THE.LIST
* EN_10003187 E
    LOOP
        REMOVE CHQ.CHR.ID FROM SEL.LIST SETTING MORE
    WHILE CHQ.CHR.ID : MORE
        CHQ.CHR.REC = CQ.ChqFees.ChequeChargeBal.Read(CHQ.CHR.ID, ERR2)

        CHQ.STS.CNT = DCOUNT(CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBalHold.CcBalChequeStatus>,@VM)
        FOR I = 1 TO CHQ.STS.CNT

            TOT.CHG.LCY.AMT = 0
            TOT.CHG.FCY.AMT = 0
            TOT.TAX.LCY.AMT = 0
            TOT.TAX.FCY.AMT = 0
            CNTR = 0
            REMARKS = ''

            CHG.CCY = CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBalHold.CcBalChrgCcy><1,I>
            CHQ.STS = CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBalHold.CcBalChequeStatus><1,I>
            STS.DATE = CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBal.CcBalStatusDate><1,I>

            STS.REC = CQ.ChqConfig.ChequeStatus.Read(CHQ.STS, ERR3)
            STS.DESC = STS.REC<CQ.ChqConfig.ChequeStatus.ChequeStsDescription>
            STS.DESC = STS.DESC[1,20]

            CHG.CNT = DCOUNT(CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBal.CcBalChrgCode><1,I>,@SM)
            FOR J = 1 TO CHG.CNT
                TOT.CHG.LCY.AMT += CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBal.CcBalChrgLcyAmt><1,I,J>
                TOT.CHG.FCY.AMT += CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBal.CcBalChrgFcyAmt><1,I,J>
            NEXT J

            TAX.CNT = DCOUNT(CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBalHold.CcBalTaxCode><1,I>,@SM)
            FOR K = 1 TO TAX.CNT
                TOT.TAX.LCY.AMT += CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBal.CcBalTaxLcyAmt><1,I,K>
                TOT.TAX.FCY.AMT += CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBal.CcBalTaxFcyAmt><1,I,K>
            NEXT K

            CNTR += 1
            IF INDEX(STS.DESC,'ISSUE',1) THEN
                ISS.REC = CQ.ChqIssue.ChequeIssue.Read(CHQ.CHR.ID, ERR5)
                IF INDEX(ISS.REC<CQ.ChqIssue.ChequeIssue.ChequeIsOverride>,'ISSUE',1) THEN
                    REMARKS = 'First Time'
                END
            END

            IF CNTR > 0 THEN
                YID.LIST<-1>=CHQ.CHR.ID:'*':STS.DATE:'*':CHQ.STS:'*':STS.DESC:'*':CHG.CCY:'*':TOT.CHG.LCY.AMT:'*':TOT.CHG.FCY.AMT:'*':TOT.TAX.LCY.AMT:'*':TOT.TAX.FCY.AMT:'*':REMARKS
            END

        NEXT I
    REPEAT
RETURN
END
