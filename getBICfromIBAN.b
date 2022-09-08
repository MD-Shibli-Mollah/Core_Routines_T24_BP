* @ValidationCode : MjotMTkxNTQ2OTYwMjpDcDEyNTI6MTU5NjA4Nzk1OTEzNDpwcmVldGhpczo2OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA2LjIwMjAwNTI3LTA0MzU6MTU0OjExMQ==
* @ValidationInfo : Timestamp         : 30 Jul 2020 11:15:59
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : preethis
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 111/154 (72.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-77</Rating>
*-----------------------------------------------------------------------------
$PACKAGE IN.Config

SUBROUTINE getBICfromIBAN (IBAN.ID, BIC.REC.ID, RET.ERR)
*---------------------------------------------------------------------
*<doc>
* Enquiry routine that used for fetching the BIC from the input IBAN no.
* @author tejomaddi@temenos.com
* @stereotype Application
* @IN_Config
* </doc>
*
**********************************************************************
*               M O D I F I C A T I O N  H I S T O R Y               *
**********************************************************************
*
* 01/06/12 - Enhancement 379826/SI 167927
*            Payments - Development for IBAN.
*
* 08/07/13 - Enhancement 671225 / Task 707307
*            Performance tunning, BIC code is cached and retrived thus avoiding
*            multiple select for the same IBAN number.
*
* 11/10/13 - Enhancement 785613 / Task 809936
*            Supporting IBAN Plus Directory (SWIFT 2013 changes), IBAN related information
*            is no more available in DE.BIC, changes done to get IBAN PLUS id in the enquiry
*
* 12/06/15 - Enhancement 1358265 / Task 1370409
*			 SWIFT 2015 Changes - BIC Id is formed considering the OFFICE.TYPE and GROUP.TYPE
*			 field in the DE.BIC record
*
* 08/03/19 - Defect 3024215 / Task 3025519
*            Performance issue for enquiry GetBICfromIBAN
*
* 23/04/19 - Enhancement 3080153 / Task 3080137
*            Validate IBAN structure based on Mandatory and Optional Commence Date
*
* 28/05/19 - Defect 3149898 / Task 3151417
*            When Allowed company is configured and Current company is not in Allowed company then do not return the BIC.REC.ID.
*
* 31/07/19 - Defect 3261570 / Task 3261616
*            Validating IBAN structure based on Mandatory and Optional Commence Date is replaced with IBANService.CheckIBANRequired API
*
* 02/03/20 - Enhancement 1899539 / Task 3629093
*            Code cleanup to remove the dependency with DE.BIC
*
* 23/07/2020 - Defect 38666020 / Task 3870764
*              Changes done to not set error when IN.BIC.NATCU.CONCAT is not present thereby
*              defaulting BIC IBAN details for valid IBAN in BENEFICIARY if available.
*---------------------------------------------------------------------
    $USING IN.Config
    $USING DE.Config
    $USING EB.SystemTables
    $USING IN.IbanAPI

    GOSUB DEFINE.PARAMETERS
    GOSUB PROCESS

RETURN
**********************************************************************
DEFINE.PARAMETERS:
******************

    CNTRY.CODE = ""
    R.IBAN.STRUCTURE = ""
    BNK.IDFR.POS = ""
    NAT.ID.LEN = ""
    BIC.REC.ID = ""
    IBAN.NAT.ID = ""
    RET.ERR = ''
    Pos = ''
* Introducing common variables to store the BIC code details for performance tunning
    IF UNASSIGNED(IN.Config.getBicDetails()) THEN
        IN.Config.setBicCntryNatId('')
        IN.Config.setBicDetails('')
    END
    
    CurrentComp = EB.SystemTables.getIdCompany()

RETURN
**********************************************************************
PROCESS:
********

    CNTRY.CODE = IBAN.ID[1,2]
    R.IBAN.STRUCTURE = IN.Config.IbanStructure.CacheRead(CNTRY.CODE, RET.ERR)
    IF RET.ERR THEN
        RETURN
    END
    
    TodayDate = EB.SystemTables.getToday()
    InDetails<IN.IbanAPI.CountryCode> = CNTRY.CODE
    InDetails<IN.IbanAPI.RequestDate> = TodayDate
    IN.IbanAPI.IbanserviceCheckIBANRequired(InDetails, OutDetails, Reserved1, Reserved2)
    IF OutDetails<IN.IbanAPI.Error> OR OutDetails<IN.IbanAPI.RequiredStatus> EQ 'N' THEN
        RET.ERR = 'IN-IBAN.STRUCTURE.MISSING'
        RETURN
    END
    
    BNK.IDFR.POS = R.IBAN.STRUCTURE<IN.Config.IbanStructure.IbanStrBnkIdentifierPos>
    NAT.ID.LEN = R.IBAN.STRUCTURE<IN.Config.IbanStructure.IbanStrIbNationalIdLen>

    IBAN.NAT.ID = IBAN.ID[BNK.IDFR.POS,NAT.ID.LEN]

    IBAN.CNTRY.NAT.ID = CNTRY.CODE:'.':IBAN.NAT.ID ;* Id to locate in the cache variable

* Check if the BIC code for the IBAN is available in the cache variables
* else select the DE.BIC to get the BIC.CODE and store in the cache
    LOCATE IBAN.CNTRY.NAT.ID IN IN.Config.getBicCntryNatId()<1> SETTING BIC.POS THEN
        BIC.REC.ID = IN.Config.getBicDetails()<BIC.POS> ;* Return BIC code stored in the cache
    END ELSE
*
* Forming BIC
*
* This concat file is used to get the BIC code when country code and national id is available
        RET.ERR = ''
        R.IBAN.PLUS.CC = ''
        R.IBAN.PLUS.CC = IN.Config.IbanPlusConcat.CacheRead(IBAN.CNTRY.NAT.ID, RET.ERR)
        IF NOT(RET.ERR) THEN
            CusBicCode = R.IBAN.PLUS.CC<IN.Config.IbanPlusConcat.PlCcCusBicCode>
            FutBicCode = R.IBAN.PLUS.CC<IN.Config.IbanPlusConcat.PlCcFutBicCode>
            BicCode = R.IBAN.PLUS.CC<IN.Config.IbanPlusConcat.PlCcBicCode>
            BEGIN CASE
                CASE CusBicCode
                    BIC.REC.ID = CusBicCode<1,1>
                    Pos = IN.Config.IbanPlusConcat.PlCcCusBicCode
                CASE FutBicCode
                    FutDate = FIELD(FutBicCode,"-",2)
                    IF FutDate LE EB.SystemTables.getToday() THEN
                        BIC.REC.ID = FIELD(FutBicCode,"-",1)
                        Pos = IN.Config.IbanPlusConcat.PlCcFutBicCode
                    END ELSE
                        BIC.REC.ID = BicCode
                        Pos = IN.Config.IbanPlusConcat.PlCcBicCode
                    END
                CASE BicCode
                    BIC.REC.ID = BicCode
                    Pos = IN.Config.IbanPlusConcat.PlCcBicCode
            END CASE
            BicNatCuConcatId = CNTRY.CODE:'.':IBAN.NAT.ID:'.':BIC.REC.ID
            RBicNatCuConcat = IN.Config.BicNatCuConcat.CacheRead(BicNatCuConcatId, Error)
* If IN.BIC.NATCU.CONCAT is present, then validations for BIC.REC.ID based on ALLOWED.COMPANY and EXCLUDED.COMPANY of IN.IBAN.PLUS will be invoked.
* Else no error will be set. i.e.,the BIC code from IN.IBAN.PLUS.CONCAT if available will be returned as BIC.REC.ID.
            IF NOT(Error) THEN
                IbanPlusId = FIELD(RBicNatCuConcat<Pos>,"-",1)
                RIbanPlus = IN.Config.IbanPlus.Read(IbanPlusId, RetError)
                IbanStatus = RIbanPlus<IN.Config.IbanPlus.PlStatus>
                IF NOT(RetError) AND IbanStatus NE 'DELETE' THEN
                    AllowedComp = RIbanPlus<IN.Config.IbanPlus.PlAllowedCompany>
                    ExclComp = RIbanPlus<IN.Config.IbanPlus.PlExcludedCompany>
                    IF AllowedComp THEN
                        LOCATE CurrentComp IN AllowedComp<1,1> SETTING VAllPos THEN     ;* If current company is configured in Allowed Company
                            Allowed = 1                                                 ;* Set Allowed flag as 1
                        END
                    END
                    IF ExclComp THEN
                        LOCATE CurrentComp IN ExclComp<1,1> SETTING VAllPos THEN        ;* If current company is configured in Excluded Company
                            Excluded = 1                                                ;* Set Excluded flag as 1
                        END
                    END
    
                    BEGIN CASE
                        CASE Allowed                ;* If Current company is in Allowed Company
                            GOSUB CHECK.EXCLUSION.LIST ; *Check if the current company is present in Exclusion List
                        CASE Excluded               ;* If Current company is in Excluded company
                            BIC.REC.ID = ''
                            RET.ERR = 'IN-INVALID.IBAN.STRUCTURE'
                        CASE AllowedComp
                            BIC.REC.ID = ''
                            RET.ERR = 'IN-INVALID.IBAN.STRUCTURE'
                        CASE 1                      ;* All other cases
                            GOSUB CHECK.EXCLUSION.LIST ; *Check if the current company is present in Exclusion List
                    END CASE
                END ELSE
                    BIC.REC.ID = ''
                    RET.ERR = 'IN-INVALID.IBAN.STRUCTURE'
                END
            END
        END
    END
*
RETURN
**********************************************************************
*** <region name= CHECK.EXCLUSION.LIST>
CHECK.EXCLUSION.LIST:
*** <desc>Check if the current company is present in Exclusion List </desc>
    ERR = ''
    RExclusionListCt = ''
    RExclusionListCt = IN.Config.ExclusionListConcat.Read(IBAN.CNTRY.NAT.ID, ERR)
    IF NOT(ERR) THEN
        CusExclCode = RExclusionListCt<IN.Config.ExclusionListConcat.ExCcCusExclCode>
        FutExclCode = RExclusionListCt<IN.Config.ExclusionListConcat.ExCcFutExclCode>
        ExclCode = RExclusionListCt<IN.Config.ExclusionListConcat.ExCcExclCode>
        BEGIN CASE
            CASE CusExclCode
                EXCLUSION.LIST.ID = CusExclCode<1,1>
            CASE FutExclCode
                FutDate = FIELD(FutExclCode,"-",2)
                IF FutDate LE EB.SystemTables.getToday() THEN
                    EXCLUSION.LIST.ID = FutExclCode
                END ELSE
                    EXCLUSION.LIST.ID = ExclCode
                END
            CASE ExclCode
                EXCLUSION.LIST.ID = ExclCode
        END CASE
        YERR = ''
        RExclusionList = ''
        RExclusionList = IN.Config.ExclusionList.CacheRead(EXCLUSION.LIST.ID, YERR)
        Status = RExclusionList<IN.Config.ExclusionList.ExLiStatus>
        IF NOT(YERR) AND Status NE 'DELETE' THEN
            AllowedComp = RExclusionList<IN.Config.ExclusionList.ExLiAllowedCompany>
            ExclComp = RExclusionList<IN.Config.ExclusionList.ExLiExcludedCompany>
            IF AllowedComp THEN
                LOCATE CurrentComp IN AllowedComp<1,1> SETTING VAllPos THEN     ;* If current company is configured in Allowed Company
                    AllowedinExcl = 1                                                 ;* Set Allowed flag as 1
                END
            END
            IF ExclComp THEN
                LOCATE CurrentComp IN ExclComp<1,1> SETTING VAllPos THEN        ;* If current company is configured in Excluded Company
                    ExcludedinExcl = 1                                                ;* Set Excluded flag as 1
                END
            END
    
            BEGIN CASE
                CASE AllowedinExcl                ;* If Current company is in Allowed Company
                    BIC.REC.ID = ''
                    RET.ERR = 'IN-INVALID.IBAN.STRUCTURE'
                CASE ExcludedinExcl               ;* If Current company is in Excluded company
                    VALID.BIC = 1          ;* Valid BIC
                CASE AllowedComp
                    VALID.BIC = 1          ;* Valid BIC
                CASE 1                     ;* All other cases
                    BIC.REC.ID = ''
                    RET.ERR = 'IN-INVALID.IBAN.STRUCTURE'
            END CASE
            
        END ELSE
            VALID.BIC = 1
        END
    END
    
RETURN
*** </region>

END

