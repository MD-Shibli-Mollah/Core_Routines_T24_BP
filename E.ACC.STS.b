* @ValidationCode : MjotMjEwMTQ5ODY5OTpDcDEyNTI6MTU2NDU3MDg5MzIzMDpzcmF2aWt1bWFyOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTkwOC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 Jul 2019 16:31:33
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
* <Rating>739</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CQ.ChqEnquiry
    SUBROUTINE E.ACC.STS(YID.LIST)
*****************************************************************
* 05/02/07 - EN_10003187
*            Data Access Service - Application changes
*
* 23/07/10 - Task 68840
*            Change the reads to Customer to use the Customer
*            Service api calls
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Enquiry as ST_ChqEnquiry and include $PACKAGE
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
*****************************************************************
    $USING CQ.ChqFees
    $USING AC.AccountOpening
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.Reports

    $INSERT I_DAS.CHEQUE.CHARGE.BAL     ;* EN_10003187 S/E
    $INSERT I_CustomerService_NameAddress


    LOCATE 'CHEQUE.STATUS' IN EB.Reports.getDFields()<1> SETTING POS ELSE POS = ''
    STS.CODE = EB.Reports.getDRangeAndValue()<1,POS>

* EN_10003187 S
    THE.LIST = DAS.CHEQUE.CHARGE.BAL$CHQ.STATUS
    THE.ARGS = ''
    THE.ARGS<1> = STS.CODE
    EB.DataAccess.Das("CHEQUE.CHARGE.BAL",THE.LIST ,THE.ARGS,'')

    SEL.LIST = THE.LIST
* EN_10003187 E
    LOOP
        REMOVE CHQ.CHR.ID FROM SEL.LIST SETTING MORE
    WHILE CHQ.CHR.ID : MORE
        ACC.NO = FIELD(CHQ.CHR.ID,'.',2)
        ACC.REC = AC.AccountOpening.tableAccount(ACC.NO,ERR2)
        CUS.NO = ACC.REC<AC.AccountOpening.Account.Customer>
        customerKey = CUS.NO
        prefLang = EB.SystemTables.getLngg()
        customerNameAddress = ''
        CALL CustomerService.getNameAddress(customerKey,prefLang,customerNameAddress)
        CUS.NAME = customerNameAddress<NameAddress.shortName>
        CHQ.CHR.REC = CQ.ChqFees.tableChequeChargeBal(CHQ.CHR.ID,ERR4)
        ST.CNT = DCOUNT(CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBal.CcBalChequeStatus>,@VM)
        TOT.CHRG.AMT = 0
        TOT.TAX.AMT = 0
        TOT.CHRG.LCY.AMT = 0
        TOT.CHRG.FCY.AMT = 0
        TOT.TAX.LCY.AMT = 0
        TOT.TAX.FCY.AMT = 0 

        FOR I = 1 TO ST.CNT
            IF CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBal.CcBalChequeStatus,I> EQ STS.CODE THEN
                ST.DATE = CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBal.CcBalStatusDate,I>
                CHRG.ACC = CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBal.CcBalChrgAccount,I>
                IF NOT(CHRG.ACC) THEN CHRG.ACC = ACC.NO
                CHRG.CCY = CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBal.CcBalChrgCcy,I>

                CHRG.CNT = DCOUNT(CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBal.CcBalChrgCode>,@SM)
                FOR C.CNT = 1 TO CHRG.CNT
                    TOT.CHRG.LCY.AMT += CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBal.CcBalChrgLcyAmt><1,I,C.CNT>
                    TOT.CHRG.FCY.AMT += CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBal.CcBalChrgFcyAmt><1,I,C.CNT>
                NEXT C.CNT

                TAX.CNT = DCOUNT(CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBal.CcBalTaxCode>,@SM)
                FOR T.CNT = 1 TO TAX.CNT
                    TOT.TAX.LCY.AMT += CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBal.CcBalTaxLcyAmt><1,I,T.CNT>
                    TOT.TAX.FCY.AMT += CHQ.CHR.REC<CQ.ChqFees.ChequeChargeBal.CcBalTaxFcyAmt><1,I,T.CNT>
                NEXT T.CNT
            END
        NEXT I

        TOT.CHRG.AMT = IF TOT.CHRG.FCY.AMT THEN TOT.CHRG.FCY.AMT ELSE TOT.CHRG.LCY.AMT
    TOT.TAX.AMT = IF TOT.TAX.FCY.AMT THEN TOT.TAX.FCY.AMT ELSE TOT.TAX.LCY.AMT

    YID.LIST<-1> = ST.DATE:'*':CHRG.ACC:'*':CUS.NO:'*':CUS.NAME:'*':CHRG.CCY:'*':TOT.CHRG.LCY.AMT:'*':TOT.CHRG.FCY.AMT:'*':TOT.TAX.LCY.AMT:'*':TOT.TAX.FCY.AMT

    REPEAT
    RETURN

    END
