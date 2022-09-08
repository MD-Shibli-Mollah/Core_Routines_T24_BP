* @ValidationCode : MjoxMDcxNjU1MDg4OkNwMTI1MjoxNTI3NjgzMDYxMzAxOnNyYXZpa3VtYXI6MTU6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxODA0LjIwMTgwMzIzLTAyMDE6NDE6NDE=
* @ValidationInfo : Timestamp         : 30 May 2018 17:54:21
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : 15
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 41/41 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201804.20180323-0201
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE CZ.ErasureProcess

SUBROUTINE CZ.OBFUSCATE.MNEMONIC.FLD.API(customerId,applicationRecId, eraseOptionId,fieldName,inputFieldValues,outputValues)
*-----------------------------------------------------------------------------
* Sample Routine to obfuscate the Customer and Account Mnemonic and return it.
* For example : Get the CustomerID from Mnemonic. If customerId is 123456789 then obfuscated mnemonic value will be A23456789
* and if customerId is 223456789 then obfuscated mnemonic value is B23456789.
* That is the first character of ID gets replaced with alphabet (1=A ; 2=B ; 3=C & so on)
* Param 'customerId' : This contains the customerId
* Param 'applicationRecId' : It contains the application record Id which should be used as input for obfuscation
* (i.e.) for customer it will be CustomerId, account it will account id and so on. This value is obfuscated & returned as outputValues
* Param 'fieldName' : should contain value 'MNEMONIC'
* Param 'inputFieldValues' : it contains the mnemonic value and should not be empty for processing

*-----------------------------------------------------------------------------
* Modification History :
* 23/05/18 - Defect 2595794 / Task 2631343
*            Fix made to obfuscate the Customer and Account mnemonic irrespective of the data type .
*
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $INSERT I_CustomerService_Key
    $USING CZ.Framework
    $USING EB.SystemTables
    $USING EB.API
    $USING AC.AccountOpening
    $USING ST.Customer

*** <region name= methodStart>
*** <desc> </desc>
    GOSUB initialise ; *To initialise the Variables
*Application should contain a valid Mnemonic and applicationRecordId should not be empty to start processing.
    IF inputFieldValues NE '' AND fieldName<1> EQ 'MNEMONIC' AND applicationRecId NE '' THEN
        GOSUB process ; *Process the input parameter and conditions
    END
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc>To initialise the Variables </desc>
    errorInReading     = ''
    rEraseRECORD       = ''
    EB.API.Ocomo("CZ.OBFUSCATE.MNEMONIC.FLD.API routine --> param applicationRecId : ":applicationRecId) ;*
    obfusConstant = ''
    obfusConstant<1> = 'A'
    obfusConstant<2> = 'B'
    obfusConstant<3> = 'C'
    obfusConstant<4> = 'D'
    obfusConstant<5> = 'E'
    obfusConstant<6> = 'F'
    obfusConstant<7> = 'G'
    obfusConstant<8> = 'H'
    obfusConstant<9> = 'I'
    
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= process>
process:
*** <desc>Process the input parameter and conditions </desc>
    rEraseRECORD = CZ.Framework.CdpEraseOption.Read(eraseOptionId, errorInReading)
    IF rEraseRECORD THEN
        eraseAction = rEraseRECORD<CZ.Framework.CdpEraseOption.EraseAction>
        BEGIN CASE
            CASE eraseAction EQ "OBFUSCATE"
                GOSUB obfuscateMnemonic ; *Obfuscation of ID happens here
            CASE 1
                RETURN
        END CASE
    END
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= obfuscateMnemonic>
obfuscateMnemonic:
*** <desc>Obfuscation of ID happens here </desc>
    applicationRecId = FIELD(applicationRecId,';',1) ;* incase History_ID is passed , getting only the ID and omit the curNo
    IF applicationRecId NE '' AND NUM(LEFT(applicationRecId,1)) THEN
        IF LEFT(applicationRecId,1) EQ '0' THEN
            outputValues = 'J':RIGHT(applicationRecId,LEN(applicationRecId)-1)
        END
        ELSE
            outputValues = obfusConstant<LEFT(applicationRecId,1)>:RIGHT(applicationRecId,LEN(applicationRecId)-1)
        END
    END
    EB.API.Ocomo("CZ.OBFUSCATE.MNEMONIC.FLD.API routine obfuscated outputValues : ":outputValues) ;*
RETURN
*** </region>

END










