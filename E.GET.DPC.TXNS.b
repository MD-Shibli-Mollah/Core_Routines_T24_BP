* @ValidationCode : MjoxMzg3MTc3MDpDcDEyNTI6MTU1ODAwNjY5MjM1OTphYXJ0aGlhOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwMy4yMDE5MDIxOS0xMjQxOi0xOi0x
* @ValidationInfo : Timestamp         : 16 May 2019 17:08:12
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : aarthia
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201903.20190219-1241
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PM.Reports
SUBROUTINE E.GET.DPC.TXNS(EntireTxnList)
*-----------------------------------------------------------------------------
* A new NOFILE build routine to revamp the existing design of DPC.TXNS enquiry
*-----------------------------------------------------------------------------
* Modification History :
*
* 08/03/19 - Enh 2941192 / Task 3020586
*            Restructuring of DPC.TXNS enquiry issue
*            Revamping is done in order to make the enquiry results compatible with the UXP browser which avoids the usage of multiple values
*
* 10/04/19 - Enh 2941192 / Task 3076644
*            Restructuring of DPC.TXNS enquiry issue - Recoding task
*     
*-----------------------------------------------------------------------------
    $USING EB.Reports
    $USING PM.Reports
    
*-----------------------------------------------------------------------------
    GOSUB Initialise ; *Initialise the variables
    GOSUB BuildArray ; *Build the enquiry data for first date
* When two different dates are available in same bucket, do the same for the remaining enquiry keys
    LOOP
        IdList = EB.Reports.getEnqKeys()
        EB.Reports.setEnqKeys('')
        EB.Reports.setId(IdList)
        TxnList = ''
        GOSUB BuildArray
    
    UNTIL EB.Reports.getEnqKeys() = ''
    REPEAT
    
RETURN
*-----------------------------------------------------------------------------
*** <region name= Initialise>
Initialise:
*** <desc>Initialise the variables </desc>
    
    IdList = ''
    
    PM.Reports.EPmMcIdList(IdList)
    EB.Reports.setId(IdList)
    TxnList = "" ; EntireTxnList = ''
  
* Invoke E.PM.GET.TXN.DTLS for the first time wit ODATA as SETUP - Which would help to load certain variables
    EB.Reports.setOData('SETUP')
    PM.Reports.EPmGetTxnDtls()
 
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= BuildArray>
BuildArray:
*** <desc>Build the enquiry data </desc>
 
    IF IdList THEN
        EB.Reports.setOData(IdList)
        EB.Reports.setRRecord('')
        PM.Reports.EPmGetTxnDtls()
    
        getRRecord = EB.Reports.getRRecord()    ;* R.RECORD holding the display data
    
        TxnIds = getRRecord<10>  ;* 10th position - Transaction id
        TxnAmount = getRRecord<12> ;* Txn Amt
        TxnConvAmt = getRRecord<14> ;* Txn Conv Amt
    
        TxnTotal = 0 ; TxnConvTotal = 0; DailyTotal = 0
        FmtTxnAmt = 0; FmtTxnConvAmt = 0
    
        TxnCount = DCOUNT(TxnIds, @VM)
        FOR EachTxn = 1 TO TxnCount
        
* By default form the TxnList for the first time
            IF TxnIds<1,EachTxn> NE TxnIds<1,EachTxn-1> OR EachTxn EQ 1 THEN
* Date*Transaction Ref*Disp Txn Ref*Ccy*Txn Amount*Txn Total*Total Txn Amt*Total Conv Amt               
* 20100104*FX0935700002*FX0935700002*GBP*9000000*9000000*9000000*9000000^   - Independent data
                GOSUB FmtTxnAndConvAmt ; * Format Txn and TxnConvAmt
                TxnList<-1> = getRRecord<1,EachTxn>:"*":getRRecord<10,EachTxn> :"*": getRRecord<10,EachTxn>:"*":getRRecord<15,EachTxn>:"*":FmtTxnAmt:"*":FmtTxnAmt:"*":FmtTxnAmt:"*":FmtTxnConvAmt
*
            END ELSE
*
* Date*Transaction Ref*Disp Txn Ref*Ccy*Txn Amount*Txn Total*Total Txn Amt*Total Conv Amt 
* 20100103*MM0935700005*MM0935700005*GBP*-24.66^
* 20100103*MM0935700005*MM0935700005*GBP*-30000*-30024.66*-30024.66*-30024.66^
                GOSUB FmtTxnAndConvAmt ; * Format Txn and TxnConvAmt
                TxnTotal = FIELD(TxnList<EachTxn-1>,"*",6) + FmtTxnAmt
                TxnConvTotal = FIELD(TxnList<EachTxn-1>,"*",8) + FmtTxnConvAmt
* Remove last 3 amount fields in TxnList of the previous record
                TxnList<EachTxn-1> = FIELD(TxnList<EachTxn-1>,"*",1):"*": FIELD(TxnList<EachTxn-1>,"*",2):"*":FIELD(TxnList<EachTxn-1>,"*",3):"*":FIELD(TxnList<EachTxn-1>,"*",4):"*":FIELD(TxnList<EachTxn-1>,"*",5)
* Form Next line with the summated data
                TxnList<-1> = getRRecord<1,EachTxn>:"*":getRRecord<10,EachTxn> :"*": getRRecord<10,EachTxn>:"*":getRRecord<15,EachTxn>:"*":FmtTxnAmt:"*":TxnTotal:"*":TxnTotal:"*":TxnConvTotal
*
            END
    
            DailyTotal += TxnConvAmt<1,EachTxn>
        
            IF EachTxn EQ TxnCount THEN
                EB.Reports.setOData(DailyTotal)
                PM.Reports.EPmFmtUnit()
                FmtDailyTotal = EB.Reports.getOData()
                TxnList<EachTxn> = TxnList<EachTxn>:"*":FmtDailyTotal
  
            END
    
        NEXT EachTxn
    
        EntireTxnList<-1> = TxnList  ;* Append TxnList for all dates at end
    END
    
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= FmtTxnAndConvAmt>
FmtTxnAndConvAmt:
*** <desc> Format Txn and TxnConvAmt </desc>
    EB.Reports.setOData(TxnAmount<1,EachTxn>)
    PM.Reports.EPmFmtUnit()
    FmtTxnAmt = EB.Reports.getOData()
            
    EB.Reports.setOData(TxnConvAmt<1,EachTxn>)
    PM.Reports.EPmFmtUnit()
    FmtTxnConvAmt = EB.Reports.getOData()

RETURN
*** </region>
*-----------------------------------------------------------------------------
END

