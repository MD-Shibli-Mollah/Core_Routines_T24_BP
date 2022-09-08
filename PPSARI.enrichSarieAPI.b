* @ValidationCode : MjotMTk3NzY3ODQzMzpDcDEyNTI6MTU5NTMzNTc4MjAwMTp1bWFtYWhlc3dhcmkubWI6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNi4yMDIwMDUyNy0wNDM1OjcwOjcw
* @ValidationInfo : Timestamp         : 21 Jul 2020 18:19:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : umamaheswari.mb
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 70/70 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PPSARI.Foundation

SUBROUTINE PPSARI.enrichSarieAPI(iPaymentDets,iIFEmitDets,oUpdatePaymentObject,oEnrichIFDets, oChangeHistory, ioReserved1, ioReserved2, ioReserved3, ioReserved4, ioReserved5)
*-----------------------------------------------------------------------------
*This routine is to enrich SARIE outgoing CT message. Bank operation code will be enriched as 'SSTP' when ACWINS and RECVER BIC are same and tag 72 is not present and BENFCY account number
* is valid IBAN otherwise enrich bank operation as 'CRED'
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $USING PP.CreditPartyDeterminationService
    $USING PP.CountryIBANStructureService
    $USING PP.DuplicateCheckService
    $USING PP.InboundCodeWordService
    $USING PP.OutwardInterfaceService
 
    GOSUB initialise ; * Initialise the variables
    GOSUB validateToEnrich ; * Perfom the checks and enrich bank operation code and additional info
    GOSUB updateEnrichInfo ; * Update the enrich data to outparameter

RETURN
*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc> </desc>
    

    CALL TPSLogging("Input Parameter","SARIEService.enrichSARIEAPI","iPaymentDets:":iPaymentDets:",iIFEmitDets:":iIFEmitDets,"")
    iPorTransactionDets = RAISE(iIFEmitDets<3>)
    iPaymentParties = RAISE(iIFEmitDets<4>)
    iPaymentInfo = RAISE(iIFEmitDets<6>)
    iAdditionalInfo = RAISE(iIFEmitDets<7>)
    companyId = FIELDS(iPaymentDets,'*',1)
    ftNumber = FIELDS(iPaymentDets,'*',2)
    stpFlag = 0
    IBANstpFlag = 0
    tag72Flag = 0
RETURN
*** </region>


*-----------------------------------------------------------------------------
*** <region name= validateToEnrich>
validateToEnrich:
*** <desc> </desc>
    
    GOSUB CheckTag72 ; *Check tag 72 is present
    GOSUB EnrichBankOprtCode ; *Check ACWINS and RECVER bic are same and BENFY IBAN is valid and tag 72 is not present, set bank operation code as 'SSTP' else set as 'CRED'
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= updateEnrichInfo>
updateEnrichInfo:
*** <desc> </desc>
    oEnrichIFDets = iIFEmitDets
    oEnrichIFDets<3> = LOWER(iPorTransactionDets)
*oEnrichIFDets<4> = LOWER(iPaymentParties)
*oEnrichIFDets<6> = LOWER(iPaymentInfo)
*oEnrichIFDets<7> = LOWER(iAdditionalInfo)

    CALL TPSLogging("Out Parameter","SARIEService.enrichSarieAPI","oEnrichIFDets:":oEnrichIFDets,"")
RETURN
*** </region>
*-----------------------------------------------------------------------------
 
*** <region name= EnrichBankOprtCode>
EnrichBankOprtCode:
*** <desc>Chweck ACWINS and RECVER bic are same and BENFY IBAN is valid, set bank operation code as 'SSTP' else set as 'CRED' </desc>
    crPrtyRoles = iPaymentParties<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRole>
    crRolePos = 0
    
    LOOP
        REMOVE crPrtyRole FROM crPrtyRoles SETTING RolePos
    WHILE crPrtyRole:RolePos
        crRolePos = crRolePos + 1
        
        BEGIN CASE
            CASE iPaymentParties<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRoleIndic,crRolePos> EQ 'G' AND crPrtyRole EQ 'ACWINS'
                ACWINSbic = iPaymentParties<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyIdentifCode,crRolePos>
        
    
            CASE iPaymentParties<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyRoleIndic,crRolePos> EQ 'D' AND crPrtyRole EQ 'RECVER'
                RECVERbic = iPaymentParties<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyIdentifCode,crRolePos>
    
            CASE crPrtyRole EQ 'BENFCY'
                BENFCYiban = iPaymentParties<PP.CreditPartyDeterminationService.CreditPartyDetails.crPartyAccountLine ,crRolePos>
        END CASE
    
    REPEAT

    IF ACWINSbic EQ RECVERbic THEN
        stpFlag = 1
    END
    
    
    IF BENFCYiban NE '' THEN ;* Validate BENFCY IBAN is a valid IBAN
        ibancheck = BENFCYiban[1,1]
        IF BENFCYiban[1,1] EQ '/' THEN
            iBANLength = LEN(BENFCYiban)
            BENFCYiban = BENFCYiban[2,iBANLength]
        END
        iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.companyID> = companyId
        iPotentialIBAN<PP.CountryIBANStructureService.PotentialIBAN.ibanAccountNumber> = BENFCYiban
        PP.CountryIBANStructureService.determineIBAN(iPotentialIBAN, oIBANDetail, oDetIBANResponse)
        IF BENFCYiban[1,2] EQ 'SA' THEN ;* Validate its saudi IBAN
            IBANstpFlag = 1
        END
    END
* Bank operation code will be enriched as 'SSTP' when ACWINS and RECVER BIC are same and tag 72 is not present and BENFCY account number
* is valid IBAN otherwise enrich bank operation as 'CRED'
    IF (stpFlag EQ 1) AND (oDetIBANResponse EQ '') AND (tag72Flag EQ 0) AND (IBANstpFlag EQ 1) THEN
        iPorTransactionDets<PP.OutwardInterfaceService.PorTransactionRTGS.bankOperationCode> = 'SSTP'
    END ELSE
        iPorTransactionDets<PP.OutwardInterfaceService.PorTransactionRTGS.bankOperationCode> = 'CRED'
    END
RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= CheckTag72>
CheckTag72:
*** <desc>Check tag 72 </desc>

    iInfoCodes = iPaymentInfo<PP.InboundCodeWordService.PaymentInformation.informationCode>
    infoCodeCount = 0

    LOOP
        REMOVE iInfoCode FROM iInfoCodes SETTING infoPos
    WHILE iInfoCode:infoPos
        infoCodeCount = infoCodeCount + 1
 
        IF iInfoCode EQ 'INSSDR' AND iPaymentInfo<PP.InboundCodeWordService.PaymentInformation.instructionCode,infoCodeCount> EQ 'CTI' THEN
            tag72Flag = 1
        END
     
    REPEAT

RETURN
*** </region>
*-----------------------------------------------------------------------------

END



