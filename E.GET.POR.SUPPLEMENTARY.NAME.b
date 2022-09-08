* @ValidationCode : MjotMTQ0MDg3MzYwOkNwMTI1MjoxNTc0NzY4NTkzMjU1OnNtdWdlc2g6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkxMC4yMDE5MDkyMC0wNzA3OjMyOjMy
* @ValidationInfo : Timestamp         : 26 Nov 2019 17:13:13
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smugesh
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 32/32 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.




*-----------------------------------------------------------------------------
$PACKAGE PI.Channels
SUBROUTINE E.GET.POR.SUPPLEMENTARY.NAME
*-----------------------------------------------------------------------------
*
* Consversion routine which gets the FTNumber in O.DATA and
* returns the Beneficiary or ORDERING Name
*-----------------------------------------------------------------------------
*   Modification History :
*
* 14-10-2019  - Enhancement (3343561) - Task (3384625)
*               SWIFT GPI in TCIB - POR.SUPPLEMENTARY.NAME
*-----------------------------------------------------------------------------

    $USING EB.Reports
    $USING PP.PaymentWorkflowGUI
 
    oData = EB.Reports.getOData() ;*Get FT Number
    CONVERT "@" TO @FM IN oData
    ftNumber = oData<1>
    fieldName = oData<2>          ;*Get Payment Direction
    
    supplementaryName = '';
;*Read POR.SUPPLEMENTARY.INFO
    BEGIN CASE
        CASE fieldName EQ 'orderingName'
            roleName = "ORDPTY"
            PP.PaymentWorkflowGUI.getSupplementaryInfo('POR.PARTYDEBIT',ftNumber,'',PORSupplementaryRecord,'')
            debitPartyRole = PORSupplementaryRecord<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyrole>
            LOCATE roleName IN debitPartyRole<1,1> SETTING partyFound THEN
                supplementaryName = PORSupplementaryRecord<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyname,partyFound>
                IF supplementaryName EQ '' THEN
                    supplementaryName = PORSupplementaryRecord<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyfreeline1,partyFound>
                END
            END
        CASE fieldName EQ 'beneficiaryName'
            roleName = "BENFCY"
            PP.PaymentWorkflowGUI.getSupplementaryInfo('POR.PARTYCREDIT',ftNumber,'',PORSupplementaryRecord,'')
            creditPartyRole = PORSupplementaryRecord<PP.PaymentWorkflowGUI.PorPartycredit.Creditpartyrole>
            LOCATE roleName IN creditPartyRole<1,1> SETTING partyFound THEN
                supplementaryName = PORSupplementaryRecord<PP.PaymentWorkflowGUI.PorPartycredit.Creditpartyname,partyFound>
                IF supplementaryName EQ '' THEN
                    supplementaryName = PORSupplementaryRecord<PP.PaymentWorkflowGUI.PorPartycredit.Creditpartyfreeline1,partyFound>
                END
            END
        
        CASE fieldName EQ 'AdditionalInfo'
            tableName = "POR.ADDITIONALINF"
            PP.PaymentWorkflowGUI.getSupplementaryInfo(tableName,ftNumber,'',PORSupplementaryRecord,'')
            supplementaryName = PORSupplementaryRecord<PP.PaymentWorkflowGUI.PorAdditionalinf.Additionalinfline,1>
    END CASE

    EB.Reports.setOData(supplementaryName) ;*Set the Beneficiary or Ordername
        

*-----------------------------------------------------------------------------

END
