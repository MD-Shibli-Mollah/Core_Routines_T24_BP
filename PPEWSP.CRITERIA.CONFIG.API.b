* @ValidationCode : Mjo2MTM2MDA0NzM6Q3AxMjUyOjE1OTk1NjczMTM5MzM6amF5YXNocmVldDoxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA3LjIwMjAwNzAxLTA2NTc6MjI6MjI=
* @ValidationInfo : Timestamp         : 08 Sep 2020 17:45:13
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jayashreet
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 22/22 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202007.20200701-0657
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE PPEWSP.Foundation
SUBROUTINE PPEWSP.CRITERIA.CONFIG.API(iCriteriaConfAPIInput, oCriteriaDets)
*-----------------------------------------------------------------------------
* Modification History :
*03/09/2020 - Enhancement 3831744/Task 3910362: Clearing Specific API changes for EWSEPA clearing
*-----------------------------------------------------------------------------

    $USING DE.Messaging
    $USING PP.OutwardMappingFramework
*-----------------------------------------------------------------------------
* Modification History :
*  01/09/2020 - Enhancement 3831744 / Task 3910362- EWSEPA - Bulking of pacs.028 for all camt.027/87/56 msg
*-----------------------------------------------------------------------------
* This API will enrich the generic criterias to be used fot bulking
*-----------------------------------------------------------------------------

    GOSUB initialise
    GOSUB process
    
RETURN
*------------------------------------------------------------------------------

*** <region name= Initialise>
initialise:
    CHANGE @VM TO @FM IN iCriteriaConfAPIInput
    oCriteriaDets = ''
    ftNumber = iCriteriaConfAPIInput<PP.OutwardMappingFramework.CriteriaConfAPIInput.ftNumber>
    ebqaId = iCriteriaConfAPIInput<PP.OutwardMappingFramework.CriteriaConfAPIInput.ebqaId>
    clearingTransactionType = iCriteriaConfAPIInput<PP.OutwardMappingFramework.CriteriaConfAPIInput.clearingTransactionType>
    ebqaRec = ''
    Error = ''
RETURN
*-----------------------------------------------------------------------------
*** <region name= Process>
process:
    GOSUB determineCriteriaDets
    CHANGE @FM TO @VM IN iCriteriaConfAPIInput
RETURN
*** </region>
*-------------------------------------------------------------------------------
determineCriteriaDets:
* For pacs.028 (clearing transaction type  - SR/SR-CA/SR-CM) fetch the bulkreference of the original message from EBQA record and assign it as bulking criteria.
    IF clearingTransactionType[1,2] EQ 'SR' AND ebqaId NE '' THEN
        ebqaRec = DE.Messaging.EbQueriesAnswers.Read(ebqaId, Error)
        IF Error EQ '' THEN
* In EBQA record the sent reference field will be updated in the format filerefernce##bulkReference
            bulkReference = FIELD(ebqaRec<DE.Messaging.EbQueriesAnswers.EbQaSentReference>,"##",2)
            oCriteriaDets<PP.OutwardMappingFramework.CriteriaConfDet.genericCriteriaInput1> = bulkReference
        END
    END
RETURN
*** </region>
*-------------------------------------------------------------------------------
END
