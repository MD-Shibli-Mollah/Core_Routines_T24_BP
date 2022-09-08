* @ValidationCode : Mjo4MjgyNTU4MzI6Q3AxMjUyOjE1OTM2NzIzODY2NjI6cnZhcmFkaGFyYWphbjoyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA2LjIwMjAwNTI3LTA0MzU6MzE6MzE=
* @ValidationInfo : Timestamp         : 02 Jul 2020 12:16:26
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rvaradharajan
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 31/31 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-7</Rating>
*-----------------------------------------------------------------------------
$PACKAGE IN.Config

SUBROUTINE E.GET.BIC.FROM.IBAN(BIC.DATA)
*-----------------------------------------------------------------------------
*<doc>
* Enquiry routine that used for fetching the BIC from the input IBAN no.
* @author tejomaddi@temenos.com
* @stereotype Application
* @IN_Config
* </doc>
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------
* 02/06/12 - Enhancement 379826/SI 167927
*            Payments - Development for IBAN.
*
* 04/03/20 - Enhancement 1899539 / Task 3626886
*            Modified to set Enquiry Error when invalid BIC is given
*
* 29/06/2020 - Enhancement 3810259 / Task 3810269
*              Conversion routine to get all the secondary customers for an account
*-----------------------------------------------------------------------------
* <region name= Inserts>
    $USING IN.Config
    $USING EB.Reports
    $USING ST.Config
* </region>
*-----------------------------------------------------------------------------
 
    GOSUB INITIALISE ; *initialise the variables
 
    GOSUB PROCESS ; *get teh values in the variables
 
RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>initialise the variables </desc>

    BIC.DATA = ''
    RET.DATA = ''
    RET.CODE = ''
    BicDetails = ''
    ErrorDetails = ''
    Reserved1 = ''
    Reserved2 = ''
    InDetails = ''
    BankName = ''
    Country = ''
    City = ''
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>get teh values in the variables </desc>
    EB.Reports.setEnqError('')
    
    IBAN.ID = EB.Reports.getDRangeAndValue()
    IN.Config.Getbicfromiban(IBAN.ID,RET.DATA,RET.CODE)

** Set Enquiry error when BIC entered is invalid
    IF RET.CODE THEN
        EB.Reports.setEnqError('IN-INVALID.BIC')
        RETURN
    END
    

    InDetails<ST.Config.StBicRecordId> = RET.DATA       ;* pass the bic record id to get the details
    ST.Config.GetBicDetails(InDetails, BicDetails, ErrorDetails, Reserved1, Reserved2)
    
    IF BicDetails THEN
        BankName = BicDetails<ST.Config.StInstitutionName>      ;*bank name of the bic
        Country = BicDetails<ST.Config.StCntry>                 ;*country name of the bic
        City = BicDetails<ST.Config.StCity>                     ;*city name of the bic
    END
    
    BIC.DATA = RET.DATA : "*" : BankName : "*" : Country : "*" : City
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END



    
