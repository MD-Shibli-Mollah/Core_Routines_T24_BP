* @ValidationCode : MjotNzExMDU0MDQ6Q3AxMjUyOjE0OTgwMzU2ODY0Nzk6c2l2YWdhbWFzdW5kYXJpOjI6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxNzA3LjIwMTcwNjE0LTAwNDI6MjY6MjY=
* @ValidationInfo : Timestamp         : 21 Jun 2017 14:31:26
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sivagamasundari
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 26/26 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201707.20170614-0042
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE ST.Channels
SUBROUTINE E.TC.CUST.DEFAULT
*-----------------------------------------------------------------------------------------------------------------
*  To Default values when creating TCUA Indirect User
*-----------------------------------------------------------------------------------------------------------------
* Modification history:
*-----------------------------------------------------------------------------------------------------------------
* 08/12/2016 - Enhancement - 1825131 / Task - 1660111
*              IRIS Service Integration : Administration Home > Customer > Customer Search > View Customer Details
*
* 21/06/2017 - Defect - 2023432 / Task - 2039136
*              TCUA-change set-ST_Channels
*
*----------------------------------------------------------------------------------------------------------------
    $USING ST.Customer
    $USING EB.SystemTables

*-----------------------------------------------------------------------------------------------------------------
    GOSUB Initialise
    GOSUB Process

RETURN

*-----------------------------------------------------------------------------------------------------------------
Initialise:
*-----------------------------------------------------------------------------------------------------------------

* Initialise all
    ETEXT = ''
    var_cusTitle = ''
    var_givenNames = ''
    var_familyName = ''
    var_Id = ''
    var_shortName = ''
    var_nameOne = ''
    
RETURN

*----------------------------------------------------------------------------------------------------------------
Process:
*-----------------------------------------------------------------------------------------------------------------

* Load the customer Title, GivenName and FamilyName from R.NEW
    var_cusTitle = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusTitle)
    var_givenNames = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusGivenNames)
    var_familyName = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusFamilyName)
    var_Id = EB.SystemTables.getIdNew()

* Default Customer Mnemonic in R.NEW
    EB.SystemTables.setRNew(ST.Customer.Customer.EbCusMnemonic, "IB":var_Id)

* Default Customer ShortName in R.NEW
    var_shortName = var_givenNames[1,1]:var_familyName[1,8]
    
    EB.SystemTables.setRNew(ST.Customer.Customer.EbCusShortName, var_shortName)

* Default Customer NameOne in R.NEW
    IF var_cusTitle EQ "" THEN
        var_nameOne = var_givenNames:' ':var_familyName
        EB.SystemTables.setRNew(ST.Customer.Customer.EbCusNameOne, var_nameOne)
    END ELSE
        var_nameOne = var_cusTitle:' ':var_givenNames:' ':var_familyName
        EB.SystemTables.setRNew(ST.Customer.Customer.EbCusNameOne, var_nameOne)
    END

RETURN

END
