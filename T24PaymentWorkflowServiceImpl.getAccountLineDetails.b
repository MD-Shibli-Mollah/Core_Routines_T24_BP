* @ValidationCode : MjoxOTc3NjM0OTE4OkNwMTI1MjoxNTI3MTYzNzI5MTIwOmdtYW1hdGhhOjE6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxODA0LjIwMTgwMzIzLTAyMDE6Mjc6Mjc=
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
SUBROUTINE T24PaymentWorkflowServiceImpl.getAccountLineDetails(recApplication, currentFieldValue, responseDetails)
*-----------------------------------------------------------------------------------
*
* In/out parameters:
* recApplication - holds the POR.SUPPLEMENTARY.INFO table record details.
* currentFieldValue - holds the AccountLine value for DEBTOR role of party Debit and ORDPTY role of party Credit.
*----------------------------------------------------------------------------------
* Author: gmamatha@temenos.com
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 02/05/2018 - Defect 2567133 / Task 2572715
*              Standalone Requests are not getting emitted. IF Events are not generated
*              To fetch AccountLine field values from debit and credit table for particular role and Indicator.
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
    
    GOSUB getDebitAccountLine  ;* To fetch Debit party AccountLine Code
    GOSUB getCreditAccountLine ;* To fetch Credit party AccountLine Code
    
RETURN
*-----------------------------------------------------------------------------
getDebitAccountLine:
*   To fetch AccountLine from debit party where party role is equal to 'DEBTOR' and role Indicator equal to 'R',
*   If present then map it to the output parameter.
    partyRoleIndicator = ''
    LOCATE 'DEBTOR' IN partyRole<1,1> SETTING rolPosDebit THEN
        partyRoleIndicator = recApplication<PP.PaymentWorkflowGUI.PorSupplementaryInfo.PorIdRoleIndicator,rolPosDebit>
        IF partyRoleIndicator EQ 'R' THEN
            currentFieldValue<1,-1> = recApplication<PP.PaymentWorkflowGUI.PorSupplementaryInfo.PorIdPartyAccountLine,rolPosDebit>:'-':rolPosDebit
        END
    END
 
RETURN
*--------------------------------------------------------------------------------
getCreditAccountLine:
*   To fetch AccountLine from credit party where party role is equal to 'ORDPTY' and role Indicator equal to 'R',
*   If present then map it to the output parameter.
    partyRoleIndicator = ''
    LOCATE 'ORDPTY' IN partyRole<1,1> SETTING rolPosCredit THEN
        partyRoleIndicator = recApplication<PP.PaymentWorkflowGUI.PorSupplementaryInfo.PorIdRoleIndicator,rolPosCredit>
        IF partyRoleIndicator EQ 'R' THEN
            currentFieldValue<1,-1> = recApplication<PP.PaymentWorkflowGUI.PorSupplementaryInfo.PorIdPartyAccountLine,rolPosCredit>:'-':rolPosCredit
        END
    END

RETURN
*------------------------------------------------------------------------------

END
