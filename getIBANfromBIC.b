* @ValidationCode : MjoxNTk4MjU5MDk3OkNwMTI1MjoxNTg0Njg3MzI3MDk2OnlncmFqYXNocmVlOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDQuMjAyMDAzMTMtMDY1MToxMTk6ODk=
* @ValidationInfo : Timestamp         : 20 Mar 2020 12:25:27
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ygrajashree
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 89/119 (74.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202004.20200313-0651
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-96</Rating>
*-----------------------------------------------------------------------------
$PACKAGE IN.Config

SUBROUTINE getIBANfromBIC(BIC.ID, AC.NO, INST.NAME, CTY.HD, IBAN.NAT.ID, RET.IBAN, RET.CD)
*---------------------------------------------------------------------------
*<doc>
* Enquiry routine that used for fetching the IBAN from the input BIC/INST.NAME and CITY.HEADING.
* @author tejomaddi@temenos.com
* @stereotype Application
* @IN_Config
* </doc>
*
****************************************************************************
*                  M O D I F I C A T I O N  H I S T O R Y                  *
****************************************************************************
*
* 01/06/12 - Enhancement 379826/SI 167927
*            Payments - Development for IBAN.
*
* 16/07/12 - Enahancement - 381897 / Task - 439575
*            This enquiry should work for thrid party accounts also.
*            So, check against account file is removed.
*
* 11/10/13 - Enhancement 785613 / Task 809936
*            Supporting IBAN Plus Directory (SWIFT 2013 changes), IBAN related information
*            is no more available in DE.BIC, changes done to get IBAN PLUS id in the enquiry
*
* 23/04/19 - Enhancement 3080153 / Task 3080137
*            IBAN.PLUS id is chosen based on priority between Custom, Future and Master IDs
*            from the IN.BIC.IBAN.PLUS concat file
*
* 20/05/2019 - Enhancement 3126319 / Task 3126323
*              DAS on DE.BIC to be done if RD not installed or if RD installed and
*              field REFERENCE.DATA is set to NO
*
* 31/07/19 - Defect 3261570 / Task 3261616
*            Validating IBAN structure based on Mandatory and Optional Commence Date is replaced with IBANService.CheckIBANRequired API
*
* 02/03/20 - Enhancement 1899539 / Task 3629093
*            Check if DE is installed before calling DAS of DE.BIC
*---------------------------------------------------------------------------

    $USING IN.IbanAPI
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING IN.Config
    $USING RD.Config
    $USING EB.API
    
    $INSERT I_DAS.DE.BIC
    $INSERT I_DAS.IN.IBAN.PLUS

    GOSUB DEFINE.PARAMETERS
    GOSUB PROCESS

RETURN
*---------------------------------------------------------------------------
DEFINE.PARAMETERS:
******************

    R.BIC.IBAN.PLUS = ""
    BIC.READ.ERR = ""
    MOD.VALUE = ''
*
    IBAN.PLUS.ID = ''

    R.IBAN.STR = ""
    IBAN.STR.READ.ERR = ""
*
    IN.CNTRY.CD = ""
    IBAN.NO = ""
    Err = ""

    InEnabled = ''
    IN.IbanAPI.CheckInDevEnabled(InEnabled)
    
    RD.INSTALLED = ''
    RD.PARAMETER.REC = ''
    REFERENCE.DATA = ''
    Error = ''
    DE.INSTALLED = ''
    
RETURN



*---------------------------------------------------------------------------
PROCESS:
********
* Finding the Country code from the given bic.


    BEGIN CASE
        CASE IBAN.NAT.ID
            GOSUB GET.IBAN.PLUS.FROM.NID ; *

        CASE BIC.ID
            GOSUB GET.IBAN.PLUS.FROM.BIC ; *Read the concat file IN.BIC.IBAN.PLUS get the IBAN.PLUS record id based on priority

        CASE INST.NAME AND CTY.HD
            GOSUB GET.BIC
            GOSUB GET.IBAN.PLUS.FROM.BIC ; *Read the concat file IN.BIC.IBAN.PLUS get the IBAN.PLUS record id based on priority

        CASE 1 ;* Either of the above is required to find the country and national id so return
            RETURN
    END CASE

    GOSUB READ.RECORDS

    IF NOT(EB.SystemTables.getEtext()) THEN
        GOSUB FORM.POSSIBLE.IBAN
    END

RETURN
*---------------------------------------------------------------------------
READ.RECORDS:
*--*********
* Reading BIC record with the given BIC
*
    IBAN.PLUS.READ.ERR = ''
    R.IBAN.PLUS = ''
    R.IBAN.PLUS = IN.Config.IbanPlus.Read(IBAN.PLUS.ID, IBAN.PLUS.READ.ERR)
    IF IBAN.PLUS.READ.ERR THEN
        EB.SystemTables.setEtext("IN-INVALID.IBAN.PLUS.ENTERED")
        RETURN
    END

    IN.CNTRY.CD = R.IBAN.PLUS<IN.Config.IbanPlus.PlIbanCountryCode>

* Finding out the IBAN Structure file for this.
*

    R.IBAN.STR = IN.Config.IbanStructure.Read(IN.CNTRY.CD, IBAN.STR.READ.ERR)
* Before incorporation : CALL F.READ(FN.IN.IBAN.STRUCTURE, IN.CNTRY.CD, R.IBAN.STR, F.IBAN.STR, IBAN.STR.READ.ERR)
    IF IBAN.STR.READ.ERR THEN
        EB.SystemTables.setEtext("IN-IBAN.STR.FILE.NOT.FOUND")
    END ELSE
        TodayDate = EB.SystemTables.getToday()
        InDetails<IN.IbanAPI.CountryCode> = IN.CNTRY.CD
        InDetails<IN.IbanAPI.RequestDate> = TodayDate
        IN.IbanAPI.IbanserviceCheckIBANRequired(InDetails, OutDetails, Reserved1, Reserved2)
        IF OutDetails<IN.IbanAPI.Error> OR OutDetails<IN.IbanAPI.RequiredStatus> EQ 'N' THEN
            EB.SystemTables.setEtext("IN-IBAN.STR.FILE.NOT.FOUND")
            RETURN
        END
    END

RETURN
*---------------------------------------------------------------------------
GET.BIC:
********
* IF REFERENCE.DATA field of RD.PARAMETER is set 'NO' or RD is not installed, only then
* DAS will be performed on DE.BIC
    
    EB.API.ProductIsInCompany('RD', RD.INSTALLED)
    IF RD.INSTALLED THEN
        RD.PARAMETER.REC = RD.Config.RdParameter.CacheRead('SYSTEM', Error)
        REFERENCE.DATA = RD.PARAMETER.REC<RD.Config.RdParameter.RdParmReferenceData>
    END
    
    EB.API.ProductIsInCompany('DE', DE.INSTALLED)
    
    IF DE.INSTALLED AND (NOT(RD.INSTALLED) OR REFERENCE.DATA EQ 'NO') THEN
        THE.LIST = DAS.DE.BIC$FINDBICCODE
        THE.ARGS<1> = INST.NAME
        THE.ARGS<2> = CTY.HD
        TABLE.SUFFIX = ""
        EB.DataAccess.Das("DE.BIC", THE.LIST, THE.ARGS, TABLE.SUFFIX)
        BIC.ID = THE.LIST<1>
    END

RETURN
*---------------------------------------------------------------------------
FORM.POSSIBLE.IBAN:
*******************

    ACCT.LEN = R.IBAN.STR<IN.Config.IbanStructure.IbanStrAcNumberLen>
    ACCT.FMT = "R%":ACCT.LEN
    ACCOUNT.NO = FMT(AC.NO, ACCT.FMT)

    POSSIBLE.BBAN = R.IBAN.PLUS<IN.Config.IbanPlus.PlIbanNationalId> : ACCOUNT.NO
    REARRANGED.IBAN = POSSIBLE.BBAN : IN.CNTRY.CD : '00'
    
    IN.IbanAPI.ConvAlphaToNumeric(REARRANGED.IBAN , MOD.VALUE)
    CHECK.DIGIT = 98 - MOD.VALUE

* IBAN is formed from COUNTRY.CODE, REMAINDER and BBAN

    RET.IBAN = IN.CNTRY.CD : FMT(CHECK.DIGIT,"R%2") : POSSIBLE.BBAN
    RET.IBAN := '*':IBAN.PLUS.ID

RETURN
*-----------------------------------------------------------------------------

*** <region name= GET.IBAN.PLUS.FROM.BIC>
GET.IBAN.PLUS.FROM.BIC:
*** <desc>Read the concat file IN.BIC.IBAN.PLUS get the first field as the IBAN.PLUS record id </desc>

    R.BIC.IBAN.PLUS = IN.Config.BicIbanPlus.Read(BIC.ID, BIC.READ.ERR)
* Before incorporation : CALL F.READ('F.IN.BIC.IBAN.PLUS', BIC.ID, R.BIC.IBAN.PLUS, F.BIC.IBAN.PLUS, BIC.READ.ERR)
    IF NOT(R.BIC.IBAN.PLUS) THEN
        EB.SystemTables.setEtext("IN-INVALID.BIC.ENTERED")
        RETURN
    END ELSE
        IF InEnabled = 'NO' THEN
            IBAN.PLUS.ID = R.BIC.IBAN.PLUS<1>
        END ELSE
            IbanPlus = R.BIC.IBAN.PLUS<IN.Config.BicIbanPlus.BicIpIbanPlusId>
            CusIbanPlus = R.BIC.IBAN.PLUS<IN.Config.BicIbanPlus.BicIpCusIbanPlus>
            FutIbanPlus = R.BIC.IBAN.PLUS<IN.Config.BicIbanPlus.BicIpFutIbanPlus>
            BEGIN CASE
                CASE CusIbanPlus
                    IBAN.PLUS.ID = CusIbanPlus<1,1>
                CASE FutIbanPlus
                    FutDate = FIELD(FutIbanPlus,"-",2)
                    IF FutDate LE EB.SystemTables.getToday() THEN
                        IBAN.PLUS.ID = FutIbanPlus
                    END ELSE
                        IBAN.PLUS.ID = IbanPlus
                    END
                CASE IbanPlus
                    IBAN.PLUS.ID = IbanPlus
            END CASE
        END
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= GET.IBAN.PLUS.FROM.NID>
GET.IBAN.PLUS.FROM.NID:
*** <desc> </desc>
* Get the IBAN Plus record id passing the given national id

    THE.LIST = dasInIbanPlus$FIND.IBAN.PLUS.FROM.NID
    THE.ARGS = ''
    THE.ARGS<1> = IBAN.NAT.ID
    TABLE.SUFFIX = ""
    EB.DataAccess.Das("IN.IBAN.PLUS", THE.LIST, THE.ARGS, TABLE.SUFFIX)

    IBAN.PLUS.ID = THE.LIST<1>

RETURN
*** </region>
*-----------------------------------------------------------------------------

END


