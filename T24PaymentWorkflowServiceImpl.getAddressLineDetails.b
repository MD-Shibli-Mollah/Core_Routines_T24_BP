* @ValidationCode : MjoyMjE3MTQwMzE6Q3AxMjUyOjE1MjcxNjM3MzE2MjI6Z21hbWF0aGE6MTowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE4MDQuMjAxODAzMjMtMDIwMToyNzoyNw==
* @ValidationInfo : Timestamp         : 24 May 2018 17:38:51
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
SUBROUTINE T24PaymentWorkflowServiceImpl.getAddressLineDetails(recApplication, currentFieldValue, responseDetails)
*-----------------------------------------------------------------------------------
*
* In/out parameters:
* recApplication - holds the POR.SUPPLEMENTARY.INFO table record details.
* currentFieldValue - holds the AddressLine value for DEBTOR role of party Debit and ORDPTY role of party Credit.
*----------------------------------------------------------------------------------
* Author: gmamatha@temenos.com
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 02/05/2018 - Defect 2567133 / Task 2572715
*              Standalone Requests are not getting emitted. IF Events are not generated
*              To fetch AddressLine field values from debit and credit table for particular role and Indicator.
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
    
    GOSUB getDebitAddressLine  ;* To fetch Debit party AddressLine
    GOSUB getCreditAddressLine ;* To fetch Credit party AddressLine
    
RETURN
*-----------------------------------------------------------------------------
getDebitAddressLine:
*   To fetch AddressLine from debit party where party role is equal to 'DEBTOR' and role Indicator equal to 'R',
*   If present then map it to the output parameter.
    partyRoleIndicator = ''
    LOCATE 'DEBTOR' IN partyRole<1,1> SETTING rolPosDebit THEN
        partyRoleIndicator = recApplication<PP.PaymentWorkflowGUI.PorSupplementaryInfo.PorIdRoleIndicator,rolPosDebit>
        IF partyRoleIndicator EQ 'R' THEN
            currentFieldValue<1,-1> = recApplication<PP.PaymentWorkflowGUI.PorSupplementaryInfo.PorIdAddressLine,rolPosDebit>:'-':rolPosDebit
        END
    END
 
RETURN
*--------------------------------------------------------------------------------
getCreditAddressLine:
*   To fetch AddressLine from credit party where party role is equal to 'ORDPTY' and role Indicator equal to 'R',
*   If present then map it to the output parameter.
    partyRoleIndicator = ''
    LOCATE 'ORDPTY' IN partyRole<1,1> SETTING rolPosCredit THEN
        partyRoleIndicator = recApplication<PP.PaymentWorkflowGUI.PorSupplementaryInfo.PorIdRoleIndicator,rolPosCredit>
        IF partyRoleIndicator EQ 'R' THEN
            currentFieldValue<1,-1> = recApplication<PP.PaymentWorkflowGUI.PorSupplementaryInfo.PorIdAddressLine,rolPosCredit>:'-':rolPosCredit
        END
    END

RETURN
*------------------------------------------------------------------------------

END
