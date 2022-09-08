* @ValidationCode : MjoxMzU0ODUwNjIwOkNwMTI1MjoxNTg5NzkzMTc1ODQ4OnNrYXlhbHZpemhpOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDQuMjAyMDA0MDItMDU0OTo5ODo1MA==
* @ValidationInfo : Timestamp         : 18 May 2020 14:42:55
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : skayalvizhi
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 50/98 (51.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202004.20200402-0549
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*------------------------------------------------------------------------------
$PACKAGE PPSYTC.ClearingFramework
SUBROUTINE PPSYSTC.VALIDATE.API.FOR.DD.DDI
*-----------------------------------------------------------------------------
* This routine is the validate API to be attached in DD.DDI version.
* And validates the below fields
* - DEST.ACCT.NO - RIB validation
* - BANK.CODE - valid code in CA.CLEARING.DIRECTORY
* - Amount - not greater than 5,000,000
*-----------------------------------------------------------------------------
* Modification History :
*24/03/2020 - Enhancement 3540611/Task 3638768- Payments-Afriland - SYSTAC (CEMAC) - Direct Debits
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING DD.Contract
    $USING EB.ErrorProcessing
    $USING CA.Contract
    $USING AC.AccountOpening
    $USING CA.Config
*-----------------------------------------------------------------------------
    GOSUB initialise
    GOSUB process
RETURN
*------------------------------------------------------------------------------
initialise:
* initialise all the local variable
    destAcctNo = ''
    bankClrCode = ''
    amount = ''
    validationResult = ''
    altKeyVal = ''
    err = ''
    error = ''
    clrParamRecord = ''
    scheme= ''
    keyFieldCount = ''
    REACHABILITY.KEY.FIELD = ''
    bicPresent = ''
    schemePresent = ''
    pmtChannelPresent = ''
    nccPresent = ''
    R.ACCOUNT = ''
    ACC.ERR = ''
    INT.ACCT.CURRENCY = ''
RETURN
*------------------------------------------------------------------------------
process:
* GOSUB VALIDATE.CURRENCY
    IF EB.SystemTables.getAf() EQ DD.Contract.Ddi.DdiDestAcctNo THEN
        destAcctNo = EB.SystemTables.getComi()
        IF destAcctNo NE ''THEN
            GOSUB VALIDATE.DEST.ACCT.NO
        END
    END
    IF EB.SystemTables.getAf() EQ DD.Contract.Ddi.DdiDebtorBnkClearingCode THEN
        bankClrCode = EB.SystemTables.getComi()
        IF bankClrCode NE ''THEN
            GOSUB VALIDATE.BANK.CODE
        END
    END
    IF EB.SystemTables.getAf() EQ DD.Contract.Ddi.DdiStandAloneAmt THEN
        amount = EB.SystemTables.getComi()
        IF amount NE ''THEN
            GOSUB VALIDATE.AMOUNT
        END
    END
    
RETURN
*------------------------------------------------------------------------------
VALIDATE.DEST.ACCT.NO:
* RIB validation for DEST.ACCT.NO field

    PPSYTC.ClearingFramework.ppsystcRibValidation(destAcctNo,validationResult)
    
    IF validationResult EQ '2' THEN
        EB.SystemTables.setAf(DD.Contract.Ddi.DdiDestAcctNo)
        EB.SystemTables.setEtext("PPSYTC-RIB.INVALID")
        EB.ErrorProcessing.StoreEndError()
    END ELSE IF validationResult EQ '3' THEN
        EB.SystemTables.setAf(DD.Contract.Ddi.DdiDestAcctNo)
        EB.SystemTables.setEtext("PPSYTC-BEN.ACCT.RIB.LENGTH.INVALID")
        EB.ErrorProcessing.StoreEndError()
    END ELSE IF validationResult EQ '4' THEN
        EB.SystemTables.setAf(DD.Contract.Ddi.DdiDestAcctNo)
        EB.SystemTables.setEtext("PPSYTC-BANKCODE.INVALID")
        EB.ErrorProcessing.StoreEndError()
    END
RETURN
*------------------------------------------------------------------------------
VALIDATE.BANK.CODE:
* validate BankCode.
    GOSUB getAltKeyVal
    clearingDirListRec = CA.Contract.ClearingDirectoryList.Read(altKeyVal,err)
    IF clearingDirListRec EQ '' THEN
        EB.SystemTables.setAf(DD.Contract.Ddi.DdiDebtorBnkClearingCode)
        EB.SystemTables.setEtext("PPSYTC-INVALID.BANK.CODE.DDI")
        EB.ErrorProcessing.StoreEndError()
    END
        
RETURN
*-----------------------------------------------------------------------------
getAltKeyVal:
    
    clrParamRecord = CA.Config.ClearingDirectoryParam.Read('SYSTAC.BNK',error)
    paymentChannel = 'SYSTAC'
    REACHABILITY.KEY.FIELD = clrParamRecord<CA.Config.ClearingDirectoryParam.CacdpReachabilityKeyFields>
    keyFieldCount = DCOUNT(REACHABILITY.KEY.FIELD, @VM)
    CONVERT @VM TO @FM IN REACHABILITY.KEY.FIELD
    intCount = 1
    LOOP
    WHILE intCount LE keyFieldCount
        BEGIN CASE
            CASE REACHABILITY.KEY.FIELD<intCount> EQ 'PAYMENT CHANNEL'
                pmtChannelPresent = 1
            CASE REACHABILITY.KEY.FIELD<intCount> EQ 'NATIONAL CLR CODE'
                nccPresent = 1
        END CASE
        intCount = intCount + 1
    REPEAT
    
* Based on the key combination defined in param table form the alternate key value and update it in the required field
    
    BEGIN CASE
        CASE pmtChannelPresent EQ '1' AND nccPresent EQ '1' AND REACHABILITY.KEY.FIELD<1> EQ 'PAYMENT CHANNEL'
            altKeyVal = paymentChannel:'-':bankClrCode
        CASE pmtChannelPresent EQ '1' AND nccPresent EQ '1' AND REACHABILITY.KEY.FIELD<1> EQ 'NATIONAL CLR CODE'
            altKeyVal = bankClrCode:'-':paymentChannel
        CASE pmtChannelPresent EQ '1' AND nccPresent EQ ''
            altKeyVal = paymentChannel
        CASE pmtChannelPresent EQ '' AND nccPresent EQ '1'
            altKeyVal = bankClrCode
    END CASE

RETURN
*-----------------------------------------------------------------------------
RETURN
*------------------------------------------------------------------------------
VALIDATE.AMOUNT:
* validate Amount field.If amount is greater than 5000000,then throw an error
    IF amount GE '5000000' THEN
        EB.SystemTables.setAf(DD.Contract.Ddi.DdiStandAloneAmt)
        EB.SystemTables.setEtext("PPSYTC-AMT.GE.5000000")
        EB.ErrorProcessing.StoreEndError()
    END
RETURN
*------------------------------------------------------------------------------
*VALIDATE.CURRENCY:
*    GOSUB READ.ACCOUNT
*    INT.ACCT.CURRENCY = R.ACCOUNT<AC.AccountOpening.Account.Currency>
*    IF INT.ACCT.CURRENCY NE '' AND INT.ACCT.CURRENCY NE 'XAF' THEN
*        EB.SystemTables.setE('PPSYTC-INVALID.ACCOUNT.CCY')
*        EB.ErrorProcessing.Err()
*    END
*RETURN
**------------------------------------------------------------------------------
*** <desc>Read the Account record</desc>
*READ.ACCOUNT:
*    ACCT = EB.SystemTables.getComi()
*    R.ACCOUNT = AC.AccountOpening.Account.Read(ACCT,ACC.ERR)
*RETURN
**------------------------------------------------------------------------------
END
