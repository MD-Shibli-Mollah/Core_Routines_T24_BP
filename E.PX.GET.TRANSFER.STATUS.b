* @ValidationCode : MjoxNTAxNjg0NTAzOkNwMTI1MjoxNTEyOTk5NDU2OTE2OnN1amF0YXNpbmdoOjE6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxNzEyLjIwMTcxMTAyLTE0MzI6NTg6NDU=
* @ValidationInfo : Timestamp         : 11 Dec 2017 19:07:36
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sujatasingh
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 45/58 (77.5%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201712.20171102-1432
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-60</Rating>
*-----------------------------------------------------------------------------
$PACKAGE FT.ModelBank
SUBROUTINE E.PX.GET.TRANSFER.STATUS(FT.DATA)
*-----------------------------------------------------------------------------
* No file enquiry routine to return payment status and information
* Incoming
*  FT.DATA - Null
* Outgoing
* FT.DATA - Holds payment status and information
*-----------------------------------------------------------------------------
* Modification History :
* 20/11/17 - EN 2191150 / Task 2357548
*          - No File enquiry routine for transfer list enquiry
*
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING FT.Contract
    $USING EB.Reports
    $USING EB.DataAccess
    $USING ST.CompanyCreation
*-----------------------------------------------------------------------------
     
    GOSUB INITIALISE
    IF FT.ID AND NOT(EB.Reports.getEnqError()) THEN
        GOSUB READ.FT
        IF NOT(EB.Reports.getEnqError()) THEN
            GOSUB BUILD.FT.DATA
        END
    END
    verr=EB.Reports.getEnqError()
RETURN
*-----------------------------------------------------------------------------
INITIALISE:
**<region = INITIALISE>
**<des = initialise variables>
    EB.Reports.setEnqError('')  ;* set enquiry error as null
    FT.ID = ''  ;* holds incoming payment id
    FtPos = ''  ;* position of payment id
    R.FT.REC = ''  ;* payment record variables
    ER = '' ;* read error variable
    LOCATE 'REF.NO' IN EB.Reports.getDFields()<1> SETTING FtPos THEN    ;* locate FTID in enquiry data and get position
        PAYMENT.ID = EB.Reports.getDRangeAndValue()<FtPos>                           ;* Get the FT id using the position
    END
    FT.ID = PAYMENT.ID
    FN.FUNDS.TRANSFER.HIS = 'F.FUNDS.TRANSFER$HIS'
    F.FUNDS.TRANSFER.HIS = ''
    EB.DataAccess.Opf(FN.FUNDS.TRANSFER.HIS,F.FUNDS.TRANSFER.HIS)  ;* open FUNDS.TRANSFER table
    PX.INSTALLED = ''
    LOCATE 'PX' IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING POSN ELSE
        PX.INSTALLED = 0
        EB.Reports.setEnqError('FT-PX.NOT.INSTALLED')
    END
RETURN
**</region>
*-----------------------------------------------------------------------------
READ.FT:
**<region = READ.FT>
**<des = Read record from live/exception/history>
    R.FT.REC = FT.Contract.FundsTransfer.Read(FT.ID,ER) ;* read from live
    IF ER THEN  ;* if error
        ER = ''
        R.FT.REC = FT.Contract.FundsTransfer.ReadNau(FT.ID,ER)  ;* read from NAU
    END
    IF ER THEN ;* if not in exception
        ER = ''
        EB.DataAccess.ReadHistoryRec(F.FUNDS.TRANSFER.HIS, FT.ID, R.FT.REC, ER)  ;* read from history
    END

    IF ER THEN  ;* if not present, then invalid id
        EB.Reports.setEnqError('FT-INVALID.FT.ID')
    END
RETURN
**</region>
*-----------------------------------------------------------------------------
BUILD.FT.DATA:
**<region = BUILD.FT.DATA>
**<des = Build return data>
    FT.DATA = PAYMENT.ID
    FT.DATA<-1> = R.FT.REC<FT.Contract.FundsTransfer.CreditAmount>  ;* payment amount
    FT.DATA<-1> = R.FT.REC<FT.Contract.FundsTransfer.CreditCurrency> ;* payment currency
    RecStatus = R.FT.REC<FT.Contract.FundsTransfer.RecordStatus>  ;* get record status to determine transaction status

    BEGIN CASE
        CASE RecStatus EQ ''
            PaymentTransStatus = 'Completed'
        CASE RecStatus EQ 'INAU' OR RecStatus EQ 'IHLD'
            PaymentTransStatus = 'Waiting Submit'
        CASE RecStatus EQ 'REVE'
            PaymentTransStatus = 'Cancelled'
        CASE 1
            PaymentTransStatus = 'In Progress'
    END CASE
    FT.DATA<-1> = PaymentTransStatus  ;* assing to return array
    FT.DATA<-1> = ''  ;* null for payment status. Currently not applicable for FT

    CONVERT @FM TO '*' IN FT.DATA  ;* return FT.DATA with delimeter as *
RETURN
*-----------------------------------------------------------------------------
END
