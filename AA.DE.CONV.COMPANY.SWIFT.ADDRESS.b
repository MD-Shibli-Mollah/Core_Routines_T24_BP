* @ValidationCode : MjotMTc0NTc4NjAzODpDcDEyNTI6MTU5MzA5ODk3Mjk5MjpyYWtzaGFyYToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA2LjIwMjAwNTIxLTA2NTU6MTU6MTU=
* @ValidationInfo : Timestamp         : 25 Jun 2020 20:59:32
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rakshara
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 15/15 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE AA.DE.CONV.COMPANY.SWIFT.ADDRESS(InValue,HeaderRec,MvNo,OutValue,ErrorMsg)
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>/desc>
* Arguments
*
* Input
*
*** </region>
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 24/06/20 - Enhancement : 3774161
*            Task        : 3818321
*            Logic to display swift address based on incoming company.
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Common variables and file inserts</desc>
* Inserts

    $USING DE.Config
    $USING ST.CustomerService

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process Logic>
*** <desc>Program Control</desc>

    GOSUB Initialise            ;* Initialise variables
    GOSUB DoProcess             ;* Main processing
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise all local variables required</desc>
Initialise:
    
    OutValue = ''
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= DoProcess>
*** <desc>Main Logic</desc>
DoProcess:
    
***Currently, in system only print carrier is available,following logic will display swift address also, based on incoming company.

    CompanyId = InValue     ;* Incoming company
    KeyDetails = ''
    KeyDetails<ST.CustomerService.AddressIDDetails.customerKey> = ''
    KeyDetails<ST.CustomerService.AddressIDDetails.preferredLang> = HeaderRec<DE.Config.OHeader.HdrLanguage>
    KeyDetails<ST.CustomerService.AddressIDDetails.companyCode> = CompanyId
    KeyDetails<ST.CustomerService.AddressIDDetails.addressNumber> = "1"
    Address = ''
    ST.CustomerService.getSWIFTAddress(KeyDetails,Address)
    
    OutValue = Address<ST.CustomerService.SWIFTDetails.code>   ;* Swift address

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
