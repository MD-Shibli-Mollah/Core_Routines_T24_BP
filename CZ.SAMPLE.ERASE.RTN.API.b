* @ValidationCode : MjoxNzAwMTU1NDU3OkNwMTI1MjoxNTIzNzAyMzQ4NTU5Om1hbmlzZWthcmFua2FyOjM6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxODAzLjIwMTgwMjIwLTAxNTE6MjA6MjA=
* @ValidationInfo : Timestamp         : 14 Apr 2018 16:09:08
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : manisekarankar
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 20/20 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201803.20180220-0151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE CZ.ErasureProcess
SUBROUTINE CZ.SAMPLE.ERASE.RTN.API(customerId,applicationRecId,eraseOptionId,fieldName,inputFieldValues,outputValues)
*-----------------------------------------------------------------------------
* Description    : Sample Routine for the Record Erasure Process.
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------
* 04/12/2017 - Enhancement- 2326350 / Task- 2326899 - cmanivannan@temenos.com
*              Erasure Process done for the request fields(GDPR).
* 06/04/2017 - Defect- 2478051 / Task- 2525084 - jbalaji@temenos.com
*              Generalizing the changes done for obfuscate API. Added 2 params customerId & applicationRecId.
*              These 2 params is not used in this routine.
* 07/03/2018 - Defect -2494794/Task-2495096 - cmanivannan@temenos.com
*              Store the Erased details.
*-----------------------------------------------------------------------------
    $USING CZ.ErasureProcess
    $USING CZ.Framework
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name= methodStart>
*** <desc>Start Of the Program </desc>

    GOSUB initialise ;* To initialise the Variables
    GOSUB process ;* Setup the parameters for BATCH.BUILD.LIST
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= initialise>
initialise:
*** <desc>To initialise Variables </desc>

    SSFieldSingleMulti = fieldName<2>
    fieldName          = fieldName<1>
    errorInReading     = ''
    rEraseRECORD       = ''

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= process>
process:
*** <desc>Setup the parameters for BATCH.BUILD.LIST</desc>

*sample Routine which mask the values for given erase option i.e OBFUSCATE
* this only mask the values of single value field not for multi value field.

    rEraseRECORD = CZ.Framework.CdpEraseOption.Read(eraseOptionId, errorInReading)
    IF rEraseRECORD THEN
        BEGIN CASE
            CASE rEraseRECORD<CZ.Framework.CdpEraseOption.DataType> EQ "DATE"
                outputValues = "19500101"
            CASE rEraseRECORD<CZ.Framework.CdpEraseOption.DataType> EQ "NUMBER"
                outputValues = "99999"
            CASE rEraseRECORD<CZ.Framework.CdpEraseOption.DataType> EQ "ALPHA"
                outputValues = "XXXXX"
        END CASE
    END

RETURN
*-----------------------------------------------------------------------------
END
