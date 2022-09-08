* @ValidationCode : MjoxNTc5NDA0MzI0OkNwMTI1MjoxNTI3MTYzNzI5MjIxOmdtYW1hdGhhOjE6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxODA0LjIwMTgwMzIzLTAyMDE6Mjc6Mjc=
* @ValidationInfo : Timestamp         : 24 May 2018 17:38:49
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : gmamatha
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 27/27 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201804.20180323-0201
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------------
$PACKAGE PP.PaymentWorkflowService
SUBROUTINE T24PaymentWorkflowServiceImpl.getIdentifierCodeDetails(recApplication, currentFieldValue, responseDetails)
*-----------------------------------------------------------------------------------
*
* In/out parameters:
* recApplication - holds the POR.SUPPLEMENTARY.INFO table record details.
* currentFieldValue - holds the Identifier Code value for DBTAGT role of party Debit and Credit details.
*----------------------------------------------------------------------------------
* Author: gmamatha@temenos.com
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 02/05/2018 - Defect 2567133 / Task 2572715
*              Standalone Requests are not getting emitted. IF Events are not generated
*              To fetch Identifier Code field values from debit and credit table for particular role and Indicator.
*
*-----------------------------------------------------------------------------
    $USING PP.PaymentWorkflowGUI
 
    GOSUB initialise
    GOSUB process
    
RETURN
*-----------------------------------------------------------------------------
initialise:
    
    partyRole = ''
    rolPosDebit = ''
    rolPosCredit = ''

RETURN
*-----------------------------------------------------------------------------
process:
*   Get multiple partyRole details from POR Supplementary table present for Debit and credit parties.
    partyRole = recApplication<PP.PaymentWorkflowGUI.PorSupplementaryInfo.PorIdPartyRole>
    
    GOSUB getDebitIdentifierCode ;* To fetch Debit party Identifier Code
    GOSUB getCreditdentifierCode ;* To fetch Credit party Identifier Code
    
RETURN
*-----------------------------------------------------------------------------
getDebitIdentifierCode:
*   To fetch Identifier code from debit party where party role is equal to 'DBTAGT' and role Indicator equal to 'R',
*   If present then map it to the output parameter.
    partyRoleIndicator = ''
    LOCATE 'DBTAGT' IN partyRole<1,1> SETTING rolPosDebit THEN
        partyRoleIndicator = recApplication<PP.PaymentWorkflowGUI.PorSupplementaryInfo.PorIdRoleIndicator,rolPosDebit>
        IF partyRoleIndicator EQ 'R' THEN
            currentFieldValue<1,-1> = recApplication<PP.PaymentWorkflowGUI.PorSupplementaryInfo.PorIdPartyIdentifierCode,rolPosDebit>:'-':rolPosDebit
        END
    END
 
RETURN
*--------------------------------------------------------------------------------
getCreditdentifierCode:
*   To fetch Identifier code from credit party where party role is equal to 'ORDINS' and role Indicator equal to 'R',
*   If present then map it to the output parameter.
    partyRoleIndicator = ''
    LOCATE 'ORDINS' IN partyRole<1,1> SETTING rolPosCredit THEN
        partyRoleIndicator = recApplication<PP.PaymentWorkflowGUI.PorSupplementaryInfo.PorIdRoleIndicator,rolPosCredit>
        IF partyRoleIndicator EQ 'R' THEN
            currentFieldValue<1,-1> = recApplication<PP.PaymentWorkflowGUI.PorSupplementaryInfo.PorIdPartyIdentifierCode,rolPosCredit>:'-':rolPosCredit
        END
    END

RETURN
*------------------------------------------------------------------------------

END
