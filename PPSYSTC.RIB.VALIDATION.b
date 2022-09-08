* @ValidationCode : MjoxNzAxMzg2NDczOkNwMTI1MjoxNTg3MTI5Mzg1NTc2OnNhcm1lbmFzOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDIuMjAyMDAxMTctMjAyNjoxMDY6NTQ=
* @ValidationInfo : Timestamp         : 17 Apr 2020 18:46:25
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sarmenas
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 54/106 (50.9%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
$PACKAGE PPSYTC.ClearingFramework
SUBROUTINE PPSYSTC.RIB.VALIDATION(acctNo,result)
*-----------------------------------------------------------------------------
* This routine contains the RIB validation for accounts
*-----------------------------------------------------------------------------
* Modification History :
*24/03/2020 - Enhancement 3540611/Task 3638768- Payments-Afriland - SYSTAC (CEMAC) - Direct Debits
*-----------------------------------------------------------------------------
    $USING CA.Config
    $USING CA.Contract
*-----------------------------------------------------------------------------
    GOSUB INITIALISE
    GOSUB PROCESS
    
RETURN
  
*-----------------------------------------------------------------------------
INITIALISE:
*   initialise the variables here
    bankCode = ''
    branchCode = ''
    AccountNoRIB = ''
    RIBKey = ''
    intCount = ''
    totCount = ''
    intCount = 1
    totCount = 11
    result = '1' ;* set the sucess result as 1

RETURN
*-----------------------------------------------------------------------------
PROCESS:
    
    bankCode = SUBSTRINGS(acctNo,1,5)
    branchCode = SUBSTRINGS(acctNo,6,5)
    AccountNoRIB = SUBSTRINGS(acctNo,11,11)
    controlDigits = SUBSTRINGS(acctNo,22,2)
    
    nationalClrCode = SUBSTRINGS(acctNo,1,10)
       
	IF acctNo NE '' AND LEN(acctNo) NE 23 THEN
        result = '3' ;* set the falg value to 4 to indicate invalid account length
        RETURN
    END
     
    GOSUB validateBankCode
	
    IF result EQ 1 THEN
        AccountNoRIB = SUBSTRINGS(acctNo,11,11)
        LOOP
        WHILE intCount LE totCount
            String = SUBSTRINGS(AccountNoRIB,intCount,1)
            BEGIN CASE
                
                CASE String EQ 'A' OR String EQ 'J'
                    AccountNoRIB = EREPLACE(AccountNoRIB,String,"1")
                CASE String EQ 'B' OR String EQ 'K' OR String EQ 'S'
                    AccountNoRIB = EREPLACE(AccountNoRIB,String,"2")
                CASE String EQ 'C' OR String EQ 'L' OR String EQ 'T'
                    AccountNoRIB = EREPLACE(AccountNoRIB,String,"3")
                CASE String EQ 'D' OR String EQ 'M' OR String EQ 'U'
                    AccountNoRIB = EREPLACE(AccountNoRIB,String,"4")
                CASE String EQ 'E' OR String EQ 'N' OR String EQ 'V'
                    AccountNoRIB = EREPLACE(AccountNoRIB,String,"5")
                CASE String EQ 'F' OR String EQ 'O' OR String EQ 'W'
                    AccountNoRIB = EREPLACE(AccountNoRIB,String,"6")
                CASE String EQ 'G' OR String EQ 'P' OR String EQ 'X'
                    AccountNoRIB = EREPLACE(AccountNoRIB,String,"7")
                CASE String EQ 'H' OR String EQ 'Q' OR String EQ 'Y'
                    AccountNoRIB = EREPLACE(AccountNoRIB,String,"8")
                CASE String EQ 'I' OR String EQ 'R' OR String EQ 'Z'
                    AccountNoRIB = EREPLACE(AccountNoRIB,String,"9")
            END CASE
            intCount++
        REPEAT
        RIBKey = 97 - (MOD((89*bankCode + 15*branchCode + 3*AccountNoRIB),97))
                
        IF RIBKey EQ controlDigits THEN
            RIBKey = controlDigits
        END ELSE
            result = '2' ;* set the flag Value to 2 to indicate invalid RIB account
        END
    END
RETURN
*-----------------------------------------------------------------------------
validateBankCode:
    
    clrParamRecord = CA.Config.ClearingDirectoryParam.Read('SYSTAC.BRH',error)
    REACHABILITY.KEY.FIELD = clrParamRecord<CA.Config.ClearingDirectoryParam.CacdpReachabilityKeyFields>
    CONVERT @VM TO @FM IN REACHABILITY.KEY.FIELD
    GOSUB getAltKeyVal
    clearingDirListRec = CA.Contract.ClearingDirectoryList.Read(altKeyVal,err)
    IF err THEN
        result = '4'
    END
        
RETURN
*-----------------------------------------------------------------------------
getAltKeyVal:
    
    paymentChannel = 'SYSTAC'
    scheme= ''
    REACHABILITY.KEY.FIELD = clrParamRecord<CA.Config.ClearingDirectoryParam.CacdpReachabilityKeyFields>
    keyFieldCount = DCOUNT(REACHABILITY.KEY.FIELD, @VM)
    CONVERT @VM TO @FM IN REACHABILITY.KEY.FIELD
    intCount = 1
    LOOP
    WHILE intCount LE keyFieldCount
        BEGIN CASE
            CASE REACHABILITY.KEY.FIELD<intCount> EQ 'BIC'
                bicPresent = 1
            CASE REACHABILITY.KEY.FIELD<intCount> EQ 'SCHEME'
                schemePresent = 1
            CASE REACHABILITY.KEY.FIELD<intCount> EQ 'PAYMENT CHANNEL'
                pmtChannelPresent = 1
            CASE REACHABILITY.KEY.FIELD<intCount> EQ 'NATIONAL CLR CODE'
                nccPresent = 1
        END CASE
        intCount = intCount + 1
    REPEAT
    
* Based on the key combination defined in param table form the alternate key value and update it in the required field
    
    BEGIN CASE
        CASE bicPresent EQ '' AND schemePresent EQ '1' AND pmtChannelPresent EQ '1' AND nccPresent EQ '1'
            altKeyVal = nationalClrCode:'-':scheme:'-':paymentChannel
        CASE bicPresent EQ '' AND schemePresent EQ '1' AND pmtChannelPresent EQ '1' AND nccPresent EQ ''
            altKeyVal = scheme:'-':paymentChannel
        CASE bicPresent EQ '' AND schemePresent EQ '1' AND pmtChannelPresent EQ '' AND nccPresent EQ '1'
            altKeyVal = nationalClrCode:'-':scheme
        CASE bicPresent EQ '' AND schemePresent EQ '' AND pmtChannelPresent EQ '1' AND nccPresent EQ '1' AND REACHABILITY.KEY.FIELD<1> EQ 'NATIONAL CLR CODE'
            altKeyVal = nationalClrCode:'-':paymentChannel
        CASE bicPresent EQ '' AND schemePresent EQ '' AND pmtChannelPresent EQ '1' AND nccPresent EQ '1' AND REACHABILITY.KEY.FIELD<1> EQ 'PAYMENT CHANNEL'
            altKeyVal = paymentChannel:'-':nationalClrCode
        CASE bicPresent EQ '' AND schemePresent EQ '1' AND pmtChannelPresent EQ '' AND nccPresent EQ ''
            altKeyVal = scheme
        CASE bicPresent EQ '' AND schemePresent EQ '' AND pmtChannelPresent EQ '1' AND nccPresent EQ ''
            altKeyVal = paymentChannel
        CASE bicPresent EQ '' AND schemePresent EQ '' AND pmtChannelPresent EQ '' AND nccPresent EQ '1'
            altKeyVal = nationalClrCode
    END CASE

RETURN
*-----------------------------------------------------------------------------
END
