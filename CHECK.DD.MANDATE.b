* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE DD.Contract
    SUBROUTINE CHECK.DD.MANDATE(MandateDets,MandateInfo,MandateErr)
*-----------------------------------------------------------------------------
*Incoming
*MandateDets<1> - Mandate reference
*MandateDets<2> - Creditor Id
*
* Outgoing:
* MandateInfo - Array with details from DD.DDI
* MandateInfo<1> - IbanInwardAccount
* MandateInfo<2> - IbanDestinationAccount
* MandateInfo<3> - End date
* MandateInfo<4> - Status
*
* MandateErr - Error returned to calling routine
*-----------------------------------------------------------------------------
* Modification History :
* 01/01/16 - Enhancement / Task
*          - New API creation to return mandate info when requested from third party
*-----------------------------------------------------------------------------
    $USING DD.Contract
    $USING EB.DataAccess
    $INSERT I_DAS.DD.DDI
    $INSERT I_DAS.DD.DDI.NOTES
*-----------------------------------------------------------------------------
    GOSUB INITIALISE ;*initialise the variables
    GOSUB GET.DD.DDI  ;*get the list of DD.DDI with provided mandate reference and creditor id

    IF THE.LIST EQ '' THEN                           ;*if there are no records with provided mandate reference and creditor id return with error
        MandateErr = 'RECORD NOT FOUND'
    END ELSE
        GOSUB GET.MANDATE.INFO ;*get the mandate info for the DD.DDI record identified
    END
    RETURN

INITIALISE:

*initialise the outgoing arguments
    MandateInfo = ''
    MandateErr = ''

    RETURN

GET.DD.DDI:

*For the Mandate reference and Creditor Id, get the list of DD.DDI records.

    TABLE.NAME = 'DD.DDI'
    THE.ARGS = MandateDets
    THE.LIST = DAS.DD$SYSREF.CREDID
    TABLE.SUFFIX = ''
    EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)

    RETURN

GET.MANDATE.INFO:

*Get the DD.DDI field values
    MandateId = THE.LIST<1>
    R.DD.DDI = DD.Contract.Ddi.Read(MandateId,Err)         ;*Read the DD.DDI record
    MandateInfo<1> =  R.DD.DDI<DD.Contract.Ddi.DdiIbanInwardAcct>  ;*Debitor account reference
    MandateInfo<2> =  R.DD.DDI<DD.Contract.Ddi.DdiIbanDestAcct>    ;*Creditor account reference
    MandateInfo<3> =  R.DD.DDI<DD.Contract.Ddi.DdiTerminationDate>  ;*end date of the DD.DDI
    MandateInfo<4> =  R.DD.DDI<DD.Contract.Ddi.DdiStatus>     ;*status of the DD.DDI

    RETURN

    END
