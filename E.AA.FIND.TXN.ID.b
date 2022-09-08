* @ValidationCode : MjotMTcxNzUzMDM3MDpDcDEyNTI6MTYwNTYxODY0NzExMjpzbWl0aGFiaGF0Ojc6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMDo5NTo4Mg==
* @ValidationInfo : Timestamp         : 17 Nov 2020 18:40:47
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smithabhat
* @ValidationInfo : Nb tests success  : 7
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 82/95 (86.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-36</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.FIND.TXN.ID
************************************
* Modification History
*
* 20/11/14 - Task 1171853
*            Defect 1169324
*            Conversion routine attached to the enquiry AA.DETAILS.ACTIVITY.LOG.PENDING.FIN
*            Retuning Corresponding TFS @ID
*
* 05/12/14 - Task 1189738
*            Defect 1187835
*            Routine has been modified to support both pending and live activity log enquiry.
*
* 19/12/14 - Task 1203655
*            Defect 1203654
*            Payment stop process has been modified
*
* 01/01/15 - Task 1213895
*            Defect 1213815
*            Rotuine called from pending activity log enquiry then it'll check whether transaction reference is AAA
*
* 24/04/19 - Task   : 3101636
*            Defect : 3081293
*            Drilldown for Enquiry AA.DETAILS.ACTIVITY.LOG.PENDING.FIN not working for DX.TRADE
*
* 20/01/20 - Enhancement :
*            Task :
*            When transaction reference is AAA, for External Financial Arragements, AlternateId is returned
*
* 17/11/20 - Task   : 4084918
*            Defect : 3933674
*            Changes made to return Cheque.Collection Id for Enquiry AA.DETAILS.ACTIVITY.LOG.PENDING.FIN.
*
************************************
**
*    $INSERT I_COMMON
*    $INSERT I_EQUATE

    $USING AA.Framework
    $USING FT.Contract
    $USING TT.Contract
    $USING EB.Delivery
    $USING EB.DataAccess
    $USING EB.Reports
    $USING LC.Contract
    $USING MD.Contract
    $USING CQ.ChqSubmit

    GOSUB PRODUCT.VALIDATION
    GOSUB MAIN.PROCESS
    
RETURN
*
************************************
PRODUCT.VALIDATION:
*
************************************

    FT.VALID = '' ; FT.INSTALLED = '' ; COMP.FT = '' ; ERR.MSG = ''
    EB.Delivery.ValProduct('FT',FT.VALID,FT.INSTALLED,COMP.FT,ERR.MSG)

    TT.VALID = '' ; TT.INSTALLED = '' ; COMP.TT = '' ; ERR.MSG = ''
    EB.Delivery.ValProduct('TT',TT.VALID,TT.INSTALLED,COMP.TT,ERR.MSG)
    
    DX.VALID = '' ; DX.INSTALLED = '' ; COMP.DX = '' ; ERR.MSG = ''
    EB.Delivery.ValProduct('DX',DX.VALID,DX.INSTALLED,COMP.DX,ERR.MSG)
    
    CQ.VALID = '' ; CQ.INSTALLED = '' ; COMP.CQ = '' ; ERR.MSG = ''
    EB.Delivery.ValProduct('CQ',CQ.VALID,CQ.INSTALLED,COMP.CQ,ERR.MSG) ;* Check if CQ is installed .

RETURN
*
************************************
MAIN.PROCESS:
*
************************************
    TXN.CONTRACT.REC = '' ;   TXN.CONTRACT.ID = ''
    tmp.O.DATA = EB.Reports.getOData()
    TRANSACTION.REFERENCE = TRIM(tmp.O.DATA)
  
    AA.Framework.GetTxnContractId(TRANSACTION.REFERENCE, TXN.CONTRACT.REC)
    TXN.CONTRACT.ID = TXN.CONTRACT.REC<AA.Framework.TcrContractId>

    EB.Reports.setOData(tmp.O.DATA)
     

 
    BEGIN CASE
        CASE TRANSACTION.REFERENCE[1,2] EQ "FT" AND FT.VALID AND FT.INSTALLED AND COMP.FT
            IF EB.Reports.getEnqSelection()<1> EQ "AA.DETAILS.ACTIVITY.LOG.PENDING.FIN" THEN
                FN.FUNDS.TRANSFER.LOC = "F.FUNDS.TRANSFER$NAU"
            END ELSE
                IF EB.Reports.getEnqSelection()<1> EQ "AA.DETAILS.ACTIVITY.LOG.FIN" THEN
                    FN.FUNDS.TRANSFER.LOC = "F.FUNDS.TRANSFER"
                END
            END
            F.FUNDS.TRANSFER.LOC = ""
            EB.DataAccess.Opf(FN.FUNDS.TRANSFER.LOC,F.FUNDS.TRANSFER.LOC)
            EB.DataAccess.FRead(FN.FUNDS.TRANSFER.LOC,TXN.CONTRACT.ID,R.FT,F.FUNDS.TRANSFER.LOC,FT.ERR)
            IF R.FT<FT.Contract.FundsTransfer.TfsReference> THEN
                EB.Reports.setOData(FIELD(R.FT<FT.Contract.FundsTransfer.TfsReference>,'-',1))
            END ELSE
                EB.Reports.setOData("")
            END
        CASE TRANSACTION.REFERENCE[1,2] EQ "TT" AND TT.VALID AND TT.INSTALLED AND COMP.TT
            IF EB.Reports.getEnqSelection()<1> EQ "AA.DETAILS.ACTIVITY.LOG.PENDING.FIN" THEN
                FN.TELLER.LOC = "F.TELLER$NAU"
            END ELSE
                IF EB.Reports.getEnqSelection()<1> EQ "AA.DETAILS.ACTIVITY.LOG.FIN" THEN
                    FN.TELLER.LOC = "F.TELLER"
                END
            END
            EB.DataAccess.Opf(FN.TELLER.LOC,F.TELLER.LOC)
            EB.DataAccess.FRead(FN.TELLER.LOC,TXN.CONTRACT.ID,R.TT,F.TELLER.LOC,TT.ERR)
            
            IF R.TT<TT.Contract.Teller.TeTfsReference> THEN
                EB.Reports.setOData(FIELD(R.TT<TT.Contract.Teller.TeTfsReference>,'-',1))
            END ELSE
                EB.Reports.setOData("")
            END
        
* If Transaction Reference is CHEQUE.COLLECTION id set the same in Common variable.
        CASE TRANSACTION.REFERENCE[1,2] EQ "CC" AND CQ.VALID AND CQ.INSTALLED AND COMP.CQ AND EB.Reports.getEnqSelection()<1> EQ "AA.DETAILS.ACTIVITY.LOG.PENDING.FIN"
 
            EB.Reports.setOData(TRANSACTION.REFERENCE)
                
        CASE TRANSACTION.REFERENCE[1,3] EQ "AAA"
            IF EB.Reports.getEnqSelection()<1> EQ "AA.DETAILS.ACTIVITY.LOG.PENDING.FIN" THEN
                
                FN.AAA.LOC = "F.AA.ARRANGEMENT.ACTIVITY$NAU"
                F.AAA.LOC = ""
                R.AAA = ""
                AAA.ERR = ""
                EB.DataAccess.Opf(FN.AAA.LOC,F.AAA.LOC)
                EB.DataAccess.FRead(FN.AAA.LOC,TRANSACTION.REFERENCE,R.AAA,F.AAA.LOC,AAA.ERR)
                ArrangementId = R.AAA<AA.Framework.ArrangementActivity.ArrActArrangement>
                AA.Framework.GetArrangement(ArrangementId, RArrangement, RetError)

                AlternateId = RArrangement<AA.Framework.Arrangement.ArrAlternateId>
                
                IF NOT(AlternateId) THEN
                    AlternateId = R.AAA<AA.Framework.ArrangementActivity.ArrActAlternateId>
                END
                    
                BEGIN CASE
                    CASE AlternateId[1,2] EQ 'TF'
                        FN.LCMD.LOC = "F.LETTER.OF.CREDIT$NAU"
                        EB.DataAccess.Opf(FN.LCMD.LOC,F.LCMD.LOC)
                        EB.DataAccess.FRead(FN.LCMD.LOC,AlternateId,R.LCMD,F.LCMD.LOC,LCMD.ERR)
                        IF R.LCMD<LC.Contract.LetterOfCredit.TfLcRecordStatus> EQ 'INAU' THEN
                            EB.Reports.setOData(AlternateId)
                        END
            
                    CASE AlternateId[1,2] EQ 'MD'
                        FN.LCMD.LOC = "F.MD.DEAL$NAU"
                        EB.DataAccess.Opf(FN.LCMD.LOC,F.LCMD.LOC)
                        EB.DataAccess.FRead(FN.LCMD.LOC,AlternateId,R.LCMD,F.LCMD.LOC,LCMD.ERR)
                        IF R.LCMD<MD.Contract.Deal.DeaRecordStatus> EQ 'INAU' THEN
                            EB.Reports.setOData(AlternateId)
                        END
                    CASE 1
                        EB.Reports.setOData(TRANSACTION.REFERENCE)
                END CASE

            END ELSE
                EB.Reports.setOData("")
            END

        CASE TRANSACTION.REFERENCE[1,5] EQ "DXTRA" AND DX.VALID AND DX.INSTALLED AND COMP.DX
            DX.ID = FIELD(TRANSACTION.REFERENCE,'.',1)         ;* Get the correct DX.Trade Id with the Mnemonic
            DX.MNEMONIC = FIELD(TRANSACTION.REFERENCE,"\", 2)
            EB.Reports.setOData(DX.ID:"\":DX.MNEMONIC)

        CASE 1
            EB.Reports.setOData("")
    END CASE
*
************************************
RETURN
*
************************************
END
