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

* Version 3 15/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>2695</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FT.Clearing
    SUBROUTINE FT.BACS.OUT.MAPPING(NAME.OF.TAPE, TAPE.SEQ.NO, NO.OF.RECORDS, CREDIT.TOTAL, DEBIT.TOTAL, CHECKSUM.VALUE)

*************************************************************************
**
** This routine will use the FT.BC.XREF file to build a flat file to be
** put on the outgoing tape or diskette which is to be sent out to the
** Wood Street Branch of Hill Samuel Bank in London.
** It is intended that this routine is run on-line by the operator from
** the FT.TAPES routine in 'GENERATE' mode.
**
*************************************************************************
*MODIFICATIONS

* 20/09/02 - GLOBUS_EN_10001180
*          Conversion Of all Error Messages to Error Codes
*
* 28/01/03 - CI_10006482
*            Readseq fails causing BACS Interface problem. The failure
*            happens if the record is not already present. Hence during
*            openseq , if we get an error that the record is not already
*            existing, then create a dummy record.
*            This will set the EOF marker and hence the system will
*            not crash .
* 06/05/07 - EN_10003245
*            Data Access Service - FT - Application Changes
*
* 20/07/10 - Task 66080
*            Change the reads to Customer to use the Customer
*            Service api calls
*
* 25/02/13 - Task 603243
*            Validation added to complete the txn during verifying of GENERATE tapes.
*
* 16/03/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
* 17/08/15 - Enhancement 1265068/ Task 1387507 
*          - Routine incorporated
************************************************************************

    $USING EB.Security
    $USING FT.Clearing
    $USING FT.Contract
    $USING FT.LocalClearing
    $USING AC.Config
    $USING EB.DataAccess
    $USING EB.ErrorProcessing
    $USING EB.TransactionControl
    $USING EB.Display
    $USING AC.API
    $USING EB.SystemTables

    $INSERT I_DAS.FT.BC.XREF
    $INSERT I_CustomerService_NameAddress

    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
    GOSUB INITIALISE

    GOSUB PROCESS.XREF.FILE

    RETURN

*************************************************************************
INITIALISE:
*************************************************************************

    DIM FT(FT.Contract.FundsTransfer.AuditDateTime)

    EB.SystemTables.setText(''); EB.SystemTables.setEtext('')

    SAVE.ID.NEW = ''

    STATUS.OK = 1   ;* Status flag

    ORIGINAL.COUNT = 0        ;* Counter for previously downloaded records

    TRANSFER.TOTAL = 0

    DIRECT.TOTAL = 0

    INDIRECT.TOTAL = 0

    NO.OF.RECORDS = 0         ;* Parameter to be passed back

    CREDIT.TOTAL = 0          ;* Parameter to be passed back

    DEBIT.TOTAL = 0 ;* Parameter to be passed back

    CHECKSUM.VALUE = 0        ;* Parameter to be passed back

    DELIV.REF = NAME.OF.TAPE:'-':TAPE.SEQ.NO:'-'  ;* Used to update deliv outref on FT

    DR.ACCT.ARRAY = ''
    ERROR.MESSAGES = ''

    RETURN

*************************************************************************
PROCESS.XREF.FILE:
*************************************************************************
*  Process DIRECT FTs from Standing Orders

    GOSUB SELECT.XREF.FILE

    TRANSFER.TOTAL = 0

    PROCESS.PYMT.TYPE = 'DIRECT'

    LOOP
        REMOVE FT.ID FROM ID.LIST SETTING DUMDUM
        IF FT.ID THEN
            GOSUB READ.FUNDS.TRANSFER
            IF STATUS.OK THEN
                IF NOT(NO.OF.RECORDS) THEN        ;* Open only once
                    GOSUB OPEN.TAPE.FILE
                    IF NOT(STATUS.OK) THEN RETURN
                    GOSUB READ.TAPE.FILE
                END
                GOSUB UPDATE.CLEARING.RECORD
            END ELSE STATUS.OK = 1
            END
        WHILE DUMDUM
        REPEAT

        DIRECT.TOTAL = TRANSFER.TOTAL

        *  Process INDIRECT FTs

        GOSUB SELECT.XREF.FILE

        TRANSFER.TOTAL = 0

        PROCESS.PYMT.TYPE = 'INDIRECT'

        LOOP
            REMOVE FT.ID FROM ID.LIST SETTING DUMDUM
            IF FT.ID THEN
                GOSUB READ.FUNDS.TRANSFER
                IF STATUS.OK THEN
                    IF NOT(NO.OF.RECORDS) THEN        ;* Open only once
                        GOSUB OPEN.TAPE.FILE
                        IF NOT(STATUS.OK) THEN RETURN
                        GOSUB READ.TAPE.FILE
                    END
                    GOSUB UPDATE.CLEARING.RECORD
                END ELSE STATUS.OK = 1
                END
            WHILE DUMDUM
            REPEAT

            INDIRECT.TOTAL = TRANSFER.TOTAL

            GOSUB GET.FIXED.VALUES

            *  Debit Entries (Irregular Payments)

            IF INDIRECT.TOTAL GT 0 THEN

                BACS.CONSTANT.1 = '0'

                BACS.CONSTANT.2 = '17'

                BACS.CONSTANT.3 = '0000'

                TRANSFER.AMT = INDIRECT.TOTAL

                CUST.ACCT.NAME = 'IRREGULAR PAYMENTS'

                BACS.FILLER = SPACE(24)

                *
                * Set the length of the sentence to the minimum of 124 bytes.
                *
                LENGTH.OF.SENTENCE = SPACE(124)
                CLEARING.RECORD = LENGTH.OF.SENTENCE
                CLEARING.RECORD[01,06] = FMT(AGENT.SORT.CODE,'6R')[1,6]
                CLEARING.RECORD[07,08] = FMT(AGENT.ACCT.NO,'8R')[1,8]
                CLEARING.RECORD[15,01] = FMT(BACS.CONSTANT.1,'1R')[1,1]
                CLEARING.RECORD[16,02] = FMT(BACS.CONSTANT.2,'2R')[1,2]
                CLEARING.RECORD[18,06] = FMT(AGENT.SORT.CODE,'6R')[1,6]
                CLEARING.RECORD[24,08] = FMT(AGENT.ACCT.NO,'8R')[1,8]
                CLEARING.RECORD[32,04] = FMT(BACS.CONSTANT.3,'4R')[1,4]
                CLEARING.RECORD[36,11] = FMT(TRANSFER.AMT,'11"0"R')[1,11]
                CLEARING.RECORD[47,18] = FMT(CUST.ACCT.NAME,'18L')[1,18]
                CLEARING.RECORD[65,18] = FMT(PAYEE.REFERENCE,'18L')[1,18]
                CLEARING.RECORD[83,18] = FMT(PAYEE.NAME,'18L')[1,18]
                CLEARING.RECORD[101,24] = FMT(BACS.FILLER,'24L')[1,24]
                CLEARING.RECORD := CHARX(13):CHARX(10)

                WRITEBLK CLEARING.RECORD TO TAPE.FILE ELSE
                EB.SystemTables.setText('BACS TAPE FILE "WRITE ERROR"')
                GOTO FATAL.ERROR
            END

        END

        * Debit Entries (Standing Orders)

        IF DIRECT.TOTAL GT 0 THEN

            BACS.CONSTANT.1 = '0'

            BACS.CONSTANT.2 = '17'

            BACS.CONSTANT.3 = '0000'

            TRANSFER.AMT = DIRECT.TOTAL

            CUST.ACCT.NAME = 'STANDING ORDERS'

            BACS.FILLER = SPACE(24)

            *
            * Set the length of the sentence to the minimum of 124 bytes.
            *
            LENGTH.OF.SENTENCE = SPACE(124)
            CLEARING.RECORD = LENGTH.OF.SENTENCE
            CLEARING.RECORD[01,06] = FMT(AGENT.SORT.CODE,'6R')[1,6]
            CLEARING.RECORD[07,08] = FMT(AGENT.ACCT.NO,'8R')[1,8]
            CLEARING.RECORD[15,01] = FMT(BACS.CONSTANT.1,'1R')[1,1]
            CLEARING.RECORD[16,02] = FMT(BACS.CONSTANT.2,'2R')[1,2]
            CLEARING.RECORD[18,06] = FMT(AGENT.SORT.CODE,'6R')[1,6]
            CLEARING.RECORD[24,08] = FMT(AGENT.ACCT.NO,'8R')[1,8]
            CLEARING.RECORD[32,04] = FMT(BACS.CONSTANT.3,'4R')[1,4]
            CLEARING.RECORD[36,11] = FMT(TRANSFER.AMT,'11"0"R')[1,11]
            CLEARING.RECORD[47,18] = FMT(CUST.ACCT.NAME,'18L')[1,18]
            CLEARING.RECORD[65,18] = FMT(PAYEE.REFERENCE,'18L')[1,18]
            CLEARING.RECORD[83,18] = FMT(PAYEE.NAME,'18L')[1,18]
            CLEARING.RECORD[101,24] = FMT(BACS.FILLER,'24L')[1,24]
            CLEARING.RECORD := CHARX(13):CHARX(10)

            WRITEBLK CLEARING.RECORD TO TAPE.FILE ELSE
            EB.SystemTables.setText('BACS TAPE FILE "WRITE ERROR"')
            GOTO FATAL.ERROR
        END

    END

    IF NO.OF.RECORDS THEN
        CLOSESEQ TAPE.FILE
    END ELSE
        EB.SystemTables.setEtext('FT.RTN.NO.OUTWARD.FUNDS.TRANSFERS.REPORT.1')
    END

    DEBIT.TOTAL = (DIRECT.TOTAL + INDIRECT.TOTAL) / 100

    IF DEBIT.TOTAL GT 0 THEN
        GOSUB PROCESS.FINAL.CREDIT
        EB.SystemTables.setV(FT.Clearing.Tapes.TapAuditDateTime)
        EB.SystemTables.setDynArrayToRNew(SAVE.R.NEW)
        EB.SystemTables.setIdNew(SAVE.ID.NEW)
        GOSUB CLEAR.XREF.FILE
    END

    RETURN

*************************************************************************
SELECT.XREF.FILE:
*************************************************************************

    ID.LIST = ''    ;* List of items selected
    TABLE.NAME = 'FT.BC.XREF'
    THE.ARGS = ''
    THE.LIST = DAS.FT.BC.XREF$CRDATEEQTODAY
    TABLE.SUFFIX = ''
    EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
    ID.LIST = THE.LIST
    RETURN

*************************************************************************
READ.FUNDS.TRANSFER:
*************************************************************************

    HIST.FILE = ''
    MAT FT = '' ; ER = '' ; R.FT = ''
    FT.Contract.FundsTransferLock(FT.ID,R.FT,ER,'','')
    MATPARSE FT FROM R.FT
    IF ER THEN
        EB.DataAccess.FRelease('F.FUNDS.TRANSFER', FT.ID, F.FUNDS.TRANSFER.LOC)
        FT.BC.XREF.REC = '' ; ER = ''
        FT.BC.XREF.REC = FT.Clearing.BcXref.Read(FT.ID, ER)
        IF ER THEN
            ERROR.NOTE = 'ERROR IN OUTWARD BACS PROCESSING'
            EB.ErrorProcessing.ExceptionLog('S','FT','FT.BACS.OUT.MAPPING','','920',ERROR.NOTE,'F.FT.BC.XREF',FT.ID,1,ER,'')
            STATUS.OK = 0
            RETURN
        END

        HIST.FILE = 1
        FT.ID$HIS = FT.ID:';':FT.BC.XREF.REC<FT.Clearing.BcXref.BcxCurrentNumber>
        MAT FT = '' ; ER = '' ; R.FT = ''
        FT.Contract.FundsTransferLock(FT.ID$HIS,R.FT,ER,'','')
        MATPARSE FT FROM R.FT
        IF ER THEN
            EB.DataAccess.FRelease('F.FUNDS.TRANSFER$HIS', FT.ID$HIS, F.FUNDS.TRANSFER$HIS)
            ERROR.NOTE = 'ERROR IN OUTWARD BACS PROCESSING'
            EB.ErrorProcessing.ExceptionLog('S','FT','FT.BACS.OUT.MAPPING','','920',ERROR.NOTE,'F.FT.BC.XREF',FT.ID,1,ER,'')
            STATUS.OK = 0
            RETURN
        END
    END

    RETURN

*************************************************************************
UPDATE.CLEARING.RECORD:
*************************************************************************

    GOSUB GET.LOCAL.REF.POSITIONS

*  Process only If PAYMENT.TYPE = PROCESS.PYMT.TYPE

    BEGIN CASE
        CASE FT(FT.Contract.FundsTransfer.InwardPayType)[1,3] = 'STO'
            PAYMENT.TYPE = 'DIRECT'
        CASE FT(FT.Contract.FundsTransfer.InwardPayType)[1,8] = 'BULK.STO'
            PAYMENT.TYPE = 'DIRECT'
        CASE 1
            PAYMENT.TYPE = 'INDIRECT'
    END CASE
*
    IF PAYMENT.TYPE NE PROCESS.PYMT.TYPE THEN
        RETURN
    END

    NO.OF.RECORDS += 1

    GOSUB GET.SORT.CODE

    IF FT(FT.Contract.FundsTransfer.BcBankSortCode) = '' THEN
        PAYEE.SORT.CODE = '999999'
    END ELSE
        PAYEE.SORT.CODE = FT(FT.Contract.FundsTransfer.BcBankSortCode)
    END

    SERIAL.NO = NO.OF.RECORDS + ORIGINAL.COUNT

    PAYEE.ACCT.NO = FT(FT.Contract.FundsTransfer.BenAcctNo)

    BACS.CONSTANT.1 = '0'

    BACS.CONSTANT.2 = '99'

    CUST.ACCT.NO = FT(FT.Contract.FundsTransfer.DebitAcctNo)

    BACS.CONSTANT.3 = '0000'

    TRANSFER.AMT = FT(FT.Contract.FundsTransfer.LocAmtCredited)
    TRANSFER.AMT = FIELD(TRANSFER.AMT,'.',1):FIELD(TRANSFER.AMT,'.',2)
    TRANSFER.TOTAL += TRANSFER.AMT

    FINAL.DR.ACCT = FT(FT.Contract.FundsTransfer.CreditAcctNo)
    IF FINAL.DR.ACCT AND TRANSFER.AMT THEN
        LOCATE FINAL.DR.ACCT IN DR.ACCT.ARRAY<1,1> SETTING DR.POS ELSE DR.POS = ''
        IF DR.POS THEN
            DR.ACCT.ARRAY<2,DR.POS> = DR.ACCT.ARRAY<2,DR.POS> + TRANSFER.AMT
        END ELSE
            DR.ACCT.ARRAY<1,-1> = FINAL.DR.ACCT
            DR.ACCT.ARRAY<2,-1> = TRANSFER.AMT
        END
    END

    CUST.ACCT.NAME = ''
    IF FT(FT.Contract.FundsTransfer.OrderingCust) THEN
        IF NUM(FT(FT.Contract.FundsTransfer.OrderingCust)) THEN
            customerKey = FT(FT.Contract.FundsTransfer.OrderingCust)<1,1>
            customerNameAddress = ''
            prefLang = EB.SystemTables.getLngg()
            CALL CustomerService.getNameAddress(customerKey,prefLang,customerNameAddress)
            CUST.ACCT.NAME = customerNameAddress<NameAddress.shortName>
            IF EB.SystemTables.getEtext() THEN
                EB.SystemTables.setEtext(''); CUST.ACCT.NAME = customerKey
            END
        END ELSE
            CUST.ACCT.NAME = FT(FT.Contract.FundsTransfer.OrderingCust)<1,1>
        END
    END

    PAYEE.REFERENCE = ''
    IF FT(FT.Contract.FundsTransfer.PaymentDetails) NE '' THEN
        PAYEE.REFERENCE = LEFT(FT(FT.Contract.FundsTransfer.PaymentDetails)<1,1>,18)
    END ELSE
        PAYEE.REFERENCE = SPACE(18)
    END

    PAYEE.NAME = ''
    IF FT(FT.Contract.FundsTransfer.BenCustomer) THEN
        IF NUM(FT(FT.Contract.FundsTransfer.BenCustomer)) THEN
            customerKey = FT(FT.Contract.FundsTransfer.BenCustomer)<1,1>
            customerNameAddress = ''
            prefLang = EB.SystemTables.getLngg()
            CALL CustomerService.getNameAddress(customerKey,prefLang,customerNameAddress)
            PAYEE.NAME = customerNameAddress<NameAddress.shortName>
            IF EB.SystemTables.getEtext() THEN
                EB.SystemTables.setEtext(''); PAYEE.NAME = customerKey
            END
        END ELSE
            PAYEE.NAME = FT(FT.Contract.FundsTransfer.BenCustomer)<1,1>
        END
    END

    BACS.FILLER = SPACE(24)

*
* Set the length of the sentence to the minimum of 124 bytes.
*
    LENGTH.OF.SENTENCE = SPACE(124)
    CLEARING.RECORD = LENGTH.OF.SENTENCE
    CLEARING.RECORD[01,06] = FMT(PAYEE.SORT.CODE,'6R')[1,6]
    CLEARING.RECORD[07,08] = FMT(PAYEE.ACCT.NO,'8R')[1,8]
    CLEARING.RECORD[15,01] = FMT(BACS.CONSTANT.1,'1R')[1,1]
    CLEARING.RECORD[16,02] = FMT(BACS.CONSTANT.2,'2R')[1,2]
    CLEARING.RECORD[18,06] = FMT(OUR.SORT.CODE,'6R')[1,6]
    CLEARING.RECORD[24,08] = FMT(CUST.ACCT.NO,'8R')[1,8]
    CLEARING.RECORD[32,04] = FMT(BACS.CONSTANT.3,'4R')[1,4]
    CLEARING.RECORD[36,11] = FMT(TRANSFER.AMT,'11"0"R')[1,11]
    CLEARING.RECORD[47,18] = FMT(CUST.ACCT.NAME,'18L')[1,18]
    CLEARING.RECORD[65,18] = FMT(PAYEE.REFERENCE,'18L')[1,18]
    CLEARING.RECORD[83,18] = FMT(PAYEE.NAME,'18L')[1,18]
    CLEARING.RECORD[101,24] = FMT(BACS.FILLER,'24L')[1,24]
    CLEARING.RECORD := CHARX(13):CHARX(10)

    WRITEBLK CLEARING.RECORD TO TAPE.FILE ELSE
    EB.SystemTables.setText('BACS TAPE FILE "WRITE ERROR"')
    GOTO FATAL.ERROR
    END

    GOSUB UPDATE.FUNDS.TRANSFER
    GOSUB UPDATE.TAPE.JOURNAL

    EB.TransactionControl.JournalUpdate(BACS.TAPE.DATA.ID)

    RETURN

*************************************************************************
UPDATE.FUNDS.TRANSFER:
*************************************************************************

    FT(FT.Contract.FundsTransfer.DeliveryOutref)<1,-1> = DELIV.REF:SERIAL.NO
    FT(FT.Contract.FundsTransfer.LocalRef)<1,TRANSMISSION.DATE.POS> = EB.SystemTables.getToday()
    MATBUILD FT.REC FROM FT
    IF HIST.FILE THEN
        FT.FILE.ID = FT.ID$HIS
        FT.Contract.FundsTransferWrite(FT.FILE.ID,FT.REC,'HIS')
    END ELSE
        FT.FILE.ID = FT.ID
        FT.Contract.FundsTransferWrite(FT.FILE.ID,FT.REC,'')
    END

    RETURN

****************************************************************************
UPDATE.TAPE.JOURNAL:
****************************************************************************

    BACS.TAPE.REP = ''
    BACS.TAPE.DATA.ID = NAME.OF.TAPE:'-':TAPE.SEQ.NO:'-':FT(FT.Contract.FundsTransfer.DebitValueDate):'-':NO.OF.RECORDS
*
    BACS.TAPE.REP<FT.LocalClearing.BacsTapeData.BacsFtTranId> = FT.ID
    BACS.TAPE.REP<FT.LocalClearing.BacsTapeData.BacsInputDate> = FT(FT.Contract.FundsTransfer.ProcessingDate)
    BACS.TAPE.REP<FT.LocalClearing.BacsTapeData.BacsProcessingDate> = FT(FT.Contract.FundsTransfer.DebitValueDate)
*
    CUS.ACC.NAME = ''
    IF FT(FT.Contract.FundsTransfer.OrderingCust) THEN
        IF NUM(FT(FT.Contract.FundsTransfer.OrderingCust)) THEN
            customerKey = FT(FT.Contract.FundsTransfer.OrderingCust)<1,1>
            customerNameAddress = ''
            prefLang = EB.SystemTables.getLngg()
            CALL CustomerService.getNameAddress(customerKey,prefLang,customerNameAddress)
            CUS.ACC.NAME = customerNameAddress<NameAddress.shortName>
            IF EB.SystemTables.getEtext() THEN
                EB.SystemTables.setEtext(''); CUS.ACC.NAME = customerKey
            END
        END ELSE
            CUS.ACC.NAME = FT(FT.Contract.FundsTransfer.OrderingCust)<1,1>
        END
    END
    BACS.TAPE.REP<FT.LocalClearing.BacsTapeData.BacsDebitAcctName> = CUS.ACC.NAME
    BACS.TAPE.REP<FT.LocalClearing.BacsTapeData.BacsDebitAcctNo> = FT(FT.Contract.FundsTransfer.DebitAcctNo)
    BACS.TAPE.REP<FT.LocalClearing.BacsTapeData.BacsDebitAmount> = TRANSFER.AMT/100
    BACS.TAPE.REP<FT.LocalClearing.BacsTapeData.BacsDestSortCode> = FT(FT.Contract.FundsTransfer.BcBankSortCode)
    BACS.TAPE.REP<FT.LocalClearing.BacsTapeData.BacsDestAcctNo> = FT(FT.Contract.FundsTransfer.BenAcctNo)
    BACS.TAPE.REP<FT.LocalClearing.BacsTapeData.BacsTransCode> = '11'
    BACS.TAPE.REP<FT.LocalClearing.BacsTapeData.BacsReference> = FT(FT.Contract.FundsTransfer.PaymentDetails)<1,1>
*
    FT.LocalClearing.BacsTapeDataWrite(BACS.TAPE.DATA.ID,BACS.TAPE.REP,'')

    RETURN

*************************************************************************
GET.SORT.CODE:
*************************************************************************

    OUR.SORT.CODE = ''
    CREDIT.ACCT = FT(FT.Contract.FundsTransfer.CreditAcctNo)
    LOCATE CREDIT.ACCT IN FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcBrnchNostroBc)<1,1> SETTING NOSTRO.POS ELSE NOSTRO.POS = ''
    IF NOSTRO.POS THEN
        OUR.SORT.CODE = FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcBcCode)<1,NOSTRO.POS>
    END ELSE
        OUR.SORT.CODE = FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcBcCode)<1,1>
    END

    RETURN


*************************************************************************
GET.LOCAL.REF.POSITIONS:
*************************************************************************

    TRANSMISSION.DATE.POS = ''
    LOCATE 'TRANSMISSION.DATE' IN FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcReqLocrefName)<1,1> SETTING DATE.POS ELSE DATE.POS = ''
    IF DATE.POS THEN
        TRANSMISSION.DATE.POS = FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcReqLocrefPos)<1,DATE.POS>
    END

    RETURN

*************************************************************************
OPEN.TAPE.FILE:
*************************************************************************

    TAPE.FILE.ID = NAME.OF.TAPE:'.':TAPE.SEQ.NO

    TAPE.FILE.NAME = 'FT.IN.TAPE'
* CI_10006482 S
*      OPENSEQ TAPE.FILE.NAME, TAPE.FILE.ID TO TAPE.FILE LOCKED
*         ETEXT = 'FT.RTN.OUTGOING.TAPE.FILE.USE.1' ; STATUS.OK = 0
*      END ELSE NULL

    OPEN.ERR = ''
    LOCK.ERR = ''
    OPENSEQ TAPE.FILE.NAME, TAPE.FILE.ID TO TAPE.FILE LOCKED LOCK.ERR = 1 THEN OPEN.ERR =0 ELSE OPEN.ERR = 1
    IF LOCK.ERR THEN
        EB.SystemTables.setEtext('FT.RTN.OUTGOING.TAPE.FILE.USE.1'); STATUS.OK = 0
    END
    IF OPEN.ERR THEN
        CREATE TAPE.FILE ELSE EB.SystemTables.setEtext('CANNOT CREATE FT.IN.TAPE WITH ID':TAPE.FILE.ID); STATUS.OK = 0
    END
* CI_10006482 E
    RETURN

*************************************************************************
READ.TAPE.FILE:
*************************************************************************

    EOF = '' ; ORIGINAL.COUNT = 0
    LOOP
        TAPE.REC = ''
        READSEQ TAPE.REC FROM TAPE.FILE ELSE EOF = 1
    UNTIL EOF
        ORIGINAL.COUNT += 1
    REPEAT

    RETURN

*************************************************************************
GET.FIXED.VALUES:
*************************************************************************
*
* Get values from FT.TAPE.PARAMS for the outgoing tape.
*
    FTP.ID = 'BACS'
    FTP.REC = ''
    READ.FAILED = ''
    FTP.REC = FT.Clearing.TapeParams.Read(FTP.ID, READ.FAILED)
    IF READ.FAILED THEN
        EB.SystemTables.setText(READ.FAILED)
        GOTO FATAL.ERROR
    END
*
    AGENT.SORT.CODE = ''
    LOCATE 'AGENT.SORT.CODE' IN FTP.REC<FT.Clearing.TapeParams.TpRunParam,1> SETTING POS THEN
    AGENT.SORT.CODE = FTP.REC<FT.Clearing.TapeParams.TpRunValue,POS>
    END
*
    AGENT.ACCT.NO = ''
    LOCATE 'AGENT.ACCT.NO' IN FTP.REC<FT.Clearing.TapeParams.TpRunParam,1> SETTING POS THEN
    AGENT.ACCT.NO = FTP.REC<FT.Clearing.TapeParams.TpRunValue,POS>
    END
*
    PAYEE.REFERENCE = ''
    LOCATE 'PAYEE.REFERENCE' IN FTP.REC<FT.Clearing.TapeParams.TpRunParam,1> SETTING POS THEN
    PAYEE.REFERENCE = FTP.REC<FT.Clearing.TapeParams.TpRunValue,POS>
    END
*
    PAYEE.NAME = ''
    LOCATE 'PAYEE.NAME' IN FTP.REC<FT.Clearing.TapeParams.TpRunParam,1> SETTING POS THEN
    PAYEE.NAME = FTP.REC<FT.Clearing.TapeParams.TpRunValue,POS>
    END

    RETURN

*************************************************************************
PROCESS.FINAL.CREDIT:
*************************************************************************
*
* We need to debit the suspense account and credit the nostro account
* with the total amount of the BACS payments for the day.
*
    IF DR.ACCT.ARRAY THEN
        NO.OF.ACCTS = DCOUNT(DR.ACCT.ARRAY<1>,@VM)
        FOR CNTR = 1 TO NO.OF.ACCTS
            DEBIT.ACCT = DR.ACCT.ARRAY<1,CNTR>
            DEBIT.AMNT = DR.ACCT.ARRAY<2,CNTR> / 100
            GOSUB INIT.FT.DATA
            *
NEXT.ID:
            FT.Contract.GenerateId(APP.IND,FT.ID)
            EB.SystemTables.setIdNew(FT.ID)
            IF EB.SystemTables.getEtext() THEN
                GOSUB FATAL.ERROR
            END
            *
            ** Read and lock the FUNDS TRANSFER to stop it being used elsewhere
            *
            YERR = ""
            R.NEW.REC = ''
            REC.ID = EB.SystemTables.getIdNew()
            FT.Contract.FundsTransferLock(REC.ID,R.NEW.REC,YERR,'','')
            EB.SystemTables.setDynArrayToRNew(R.NEW.REC)
            IF NOT(YERR) THEN ;* Record already exists abort
                EB.DataAccess.FRelease("F.FUNDS.TRANSFER",REC.ID,F.FUNDS.TRANSFER.LOC)       ;* Try again
                GOTO NEXT.ID
            END ELSE
                YERR = ""
                FT.Contract.FundsTransferLock(REC.ID,R.NEW.REC,YERR,'','')
                EB.SystemTables.setDynArrayToRNew(R.NEW.REC)
                IF NOT(YERR) THEN       ;* Record already exists abort
                    EB.DataAccess.FRelease("F.FUNDS.TRANSFER",REC.ID,F.FUNDS.TRANSFER.LOC)   ;* Try again
                    EB.DataAccess.FRelease("F.FUNDS.TRANSFER$NAU",REC.ID,F.FUNDS.TRANSFER$NAU)     ;* Try again
                    GOTO NEXT.ID
                END
            END
            *
            * Build up the FT record
            *
            EB.SystemTables.clearRNew()
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.TransactionType, 'AC')
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CurrencyMktCr, '1');* Always local
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CurrencyMktDr, '1');* Always local
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CreditCurrency, EB.SystemTables.getLccy());* Always GBP
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.DebitCurrency, EB.SystemTables.getLccy());* Always GBP
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.Inputter, EB.SystemTables.getTno():"_":NAME.OF.TAPE)
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.DateTime, DATE.TIME)
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CoCode, EB.SystemTables.getIdCompany())
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.DeptCode, EB.SystemTables.getRUser()<EB.Security.User.UseDepartmentCode>)
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.ReturnToDept, "NO")
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CreditAcctNo, CREDIT.ACCT)
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.DebitAcctNo, DEBIT.ACCT)
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.DebitAmount, DEBIT.AMNT)
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.DebitValueDate, EB.SystemTables.getToday())
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CreditValueDate, EB.SystemTables.getToday())
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.ProcessingDate, EB.SystemTables.getToday())
            tmp=EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef); tmp<1,TRANSMISSION.DATE.POS>=EB.SystemTables.getToday(); EB.SystemTables.setRNew(FT.Contract.FundsTransfer.LocalRef, tmp)
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CommissionCode, 'WAIVE')
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.ChargeCode, 'WAIVE')
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.DrAdviceReqdYN, 'NO')
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CrAdviceReqdYN, 'NO')
            PYMT.NARR = 'BACS PAYMENT FOR ':EB.SystemTables.getToday()
            tmp=EB.SystemTables.getRNew(FT.Contract.FundsTransfer.PaymentDetails); tmp<1,1>=PYMT.NARR; EB.SystemTables.setRNew(FT.Contract.FundsTransfer.PaymentDetails, tmp)
            *
            FT.Contract.CompleteXvalidation("","","")
            IF EB.SystemTables.getEndError() OR EB.SystemTables.getEtext() THEN
                HOLD = 1
                IF EB.SystemTables.getEtext() THEN
                    EB.SystemTables.setText(EB.SystemTables.getEtext());* Already translated
                END ELSE
                    EB.SystemTables.setText("CROSS VALIDATION ERROR IN FUNDS TRANSFER")
                    MSG = EB.SystemTables.getText()
                    EB.Display.Txt(MSG)
                END
                GOSUB EXCEPTION.MESSAGE
            END
            IF NOT(HOLD) THEN ;* Accounting
                FT.Contract.InputAccounting("","","")
                IF EB.SystemTables.getEtext() THEN
                    HOLD = 1 ; EB.SystemTables.setText(EB.SystemTables.getEtext())
                    MSG = EB.SystemTables.getText()
                    EB.Display.Txt(MSG)
                    GOSUB EXCEPTION.MESSAGE
                END ELSE
                    IF EB.SystemTables.getText() THEN
                        HOLD = 1
                        MSG = EB.SystemTables.getText()
                        EB.Display.Txt(MSG)
                        GOSUB EXCEPTION.MESSAGE
                    END
                END
            END
            *
            REC.ID = EB.SystemTables.getIdNew()
            IF NOT(HOLD) THEN ;* Write to Authorised file
                EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CurrNo, 1)
                EB.SystemTables.setRNew(FT.Contract.FundsTransfer.Authoriser, EB.SystemTables.getTno():"_":NAME.OF.TAPE)
                AC.API.EbAccounting('FT','AUT','','')
                FT.Contract.Delivery()
                EB.SystemTables.setDynArrayToRNew(R.NEW.REC)
                FT.Contract.FundsTransferWrite(REC.ID,R.NEW.REC,'')
                EB.DataAccess.FRelease("F.FUNDS.TRANSFER$NAU",REC.ID, F.FUNDS.TRANSFER$NAU)
            END ELSE
                EB.SystemTables.setRNew(FT.Contract.FundsTransfer.RecordStatus, "IHLD")
                EB.SystemTables.setDynArrayToRNew(R.NEW.REC)
                FT.Contract.FundsTransferWrite(REC.ID,R.NEW.REC,'NAU')
                EB.DataAccess.FRelease("F.FUNDS.TRANSFER", REC.ID, F.FUNDS.TRANSFER.LOC)
                EB.DataAccess.FRelease("F.ACCOUNT","",F.ACCOUNT.LOC)
                EB.DataAccess.FRelease("F.LIMIT","",F.LIMIT)
            END
            *
            EB.TransactionControl.JournalUpdate(REC.ID)

        NEXT CNTR

    END
    RETURN

*************************************************************************
INIT.FT.DATA:
*************************************************************************

    APP.IND = 'BGC' ;* For generation of FT ID

    EB.SystemTables.setV(FT.Contract.FundsTransfer.AuditDateTime)

    EB.SystemTables.setEtext(''); EB.SystemTables.setText(''); EB.SystemTables.setEndError('')

    HOLD = ''       ;* Set if transaction is to be put on hold
    SAVE.ID.NEW = EB.SystemTables.getIdNew()
    EB.SystemTables.setIdNew('');* ID of the FT
    SAVE.R.NEW = EB.SystemTables.getDynArrayFromRNew()
    EB.SystemTables.clearRNew()  ;* FT record

    EB.SystemTables.setTimeStamp(TIMEDATE());* Set date and time
    tmp.TIME.STAMP = EB.SystemTables.getTimeStamp()
    V$DATE=OCONV(ICONV(FIELD(tmp.TIME.STAMP,' ',2,3),'D'),'D2/E')
    V$DATE=V$DATE[7,2]:V$DATE[4,2]:V$DATE[1,2]
    V$TIME=EB.SystemTables.getTimeStamp()[1,2]:EB.SystemTables.getTimeStamp()[4,2]
    DATE.TIME = V$DATE:V$TIME

    CREDIT.ACCT = FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcBrnchNostroBc)<1,1>
*
    GOSUB CHECK.ACCOUNT.CLASS
*
    RETURN

*************************************************************************
CHECK.ACCOUNT.CLASS:
*************************************************************************

    ACC.CLS.ID = 'LCLSUSP'
    ACC.CLS.REC = ''
    READ.FAILED = ''
    ACC.CLS.REC = AC.Config.AccountClass.Read(ACC.CLS.ID, READ.FAILED)
    IF READ.FAILED THEN
        EB.SystemTables.setText('SUSPENSE ACCOUNT MUST BE SET UP ON ACCOUNT.CLASS WITH ID = LCLSUSP')
        GOTO FATAL.ERROR
    END

    RETURN

*************************************************************************
CLEAR.XREF.FILE:
*************************************************************************

    XREF.CNT = 0
    GOSUB SELECT.XREF.FILE
    LOOP
        REMOVE FT.ID FROM ID.LIST SETTING GIMP
        IF FT.ID THEN
            XREF.CNT += 1
            FT.Clearing.BcXref.Delete(FT.ID)
            IF XREF.CNT = 200 THEN
                EB.TransactionControl.JournalUpdate(FT.ID)
                XREF.CNT = 0
            END
        END
    WHILE GIMP
    REPEAT

    IF XREF.CNT GT 0 THEN
        EB.TransactionControl.JournalUpdate(FT.ID)
    END

    RETURN

*************************************************************************
EXCEPTION.MESSAGE:
*************************************************************************

    tmp=EB.SystemTables.getRNew(FT.Contract.FundsTransfer.Override); tmp<1,-1>=EB.SystemTables.getText(); EB.SystemTables.setRNew(FT.Contract.FundsTransfer.Override, tmp)
    ERROR.MESSAGES<1,-1> = EB.SystemTables.getText()
    REC.ID = EB.SystemTables.getIdNew()
    MSG = EB.SystemTables.getText()
    DEPT.CODE = EB.SystemTables.getRUser()<EB.Security.User.UseDepartmentCode>
    EB.ErrorProcessing.ExceptionLog('S','FT','FT.BACS.OUT.MAPPING','','920','VALIDATION ERROR IN BACS PAYMENT PROCESSING','F.FUNDS.TRANSFER',REC.ID,1,MSG,DEPT.CODE)

    RETURN

*************************************************************************
FATAL.ERROR:
*************************************************************************

    EB.ErrorProcessing.FatalError('FT.BACS.OUT.MAPPING')

    RETURN

***
    END
