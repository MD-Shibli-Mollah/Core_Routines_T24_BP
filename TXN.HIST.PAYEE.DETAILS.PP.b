* @ValidationCode : MjotMTQ0NDYxNzpjcDEyNTI6MTYxNTI5MDY0OTIyMDptc3NocnV0aGk6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMy4wOjQwOjQw
* @ValidationInfo : Timestamp         : 09 Mar 2021 17:20:49
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : msshruthi
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 40/40 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE PZ.ModelBank
SUBROUTINE TXN.HIST.PAYEE.DETAILS.PP(ApplicationId, ApplicationRecord, StmtEntryId, StmtEntryRec, OutText)
*-----------------------------------------------------------------------------
*** <region name= description>
*** <desc> Description about the routine</desc>
*
* Hook routine attached to STMT.NARR.FORMAT - PP.TXHIS.
* This routine determines the beneficiary details(payee account and payee
* customer)of an underlying TPS transaction.
*-----------------------------------------------------------------------------
*
* @package PZ.ModelBank
* @class TXN.HIST.PAYEE.DETAILS.PP
* @stereotype subroutine
* @author rdhepikha@temenos.com
*
*** </region>
*
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>To define the arguments </desc>
* Incoming Arguments:
*
* @param ApplicationId     -    Transaction Reference (POR.TRANSACTION id)
* @param ApplicationRecord -    Transaction Record (Record of POR.TRANSACTION)
* @param StmtEntryId       -    ID of STMT.ENTRY
* @param StmtEntryRec      -    STMT.ENTRY record
*
* Outgoing Arguments:
*
* @param OutText           -    Payee account and payee name seperated by "#"
*
*** </region>
*
*-----------------------------------------------------------------------------
*** <region name= MODIFICATION HISTORY>
*** <desc>Modification History</desc>
*-----------------------------------------------------------------------------
*
* 06/09/17 - Enhancement 2140052 / Task 2261830
*            Hook routine attached to STMT.NARR.FORMAT - PP.TXHIS, to determine
*            the beneficiary details(payee account and payee customer) of
*            an underlying TPS transaction.
*
*11/13/2019 - Defect 3424440 /Task 3433159
*             POR.PARTCREDIT record is read only when PP product is installed
*
* 29/05/2020 - Defect 3758022 / Task 3771321
*             Credit and debit details fetched from POR.SUPPLEMENTARY.INFO
*
* 09/02/21 - Task 3879095
*            Creditor/Debtor details fetched from POR.SUPPLEMENTARY.INFO AcctInfo fields
*            instead of POR.PARTY.CREDIT
*
*-----------------------------------------------------------------------------
    
    $USING PP.CreditPartyDeterminationService
    $USING EB.SystemTables
    $USING ST.Customer
    $USING AC.AccountOpening
    $USING EB.DataAccess
    $USING PP.DebitPartyDeterminationService
    $USING EB.API
    $USING PZ.ModelBank
    $INSERT I_F.POR.SUPPLEMENTARY.INFO
    $INSERT I_CreditPartyDeterminationService_CreditPartyDetails
    $INSERT I_DebitPartyDeterminationService_DebitPartyRole
    $INSERT I_DebitPartyDeterminationService_PartyDebitDetails
    $INSERT I_CreditPartyDeterminationService_CreditPartyKey
    $INSERT I_DebitPartyDeterminationService_DebitPartyRole
*-----------------------------------------------------------------------------

    GOSUB initialise
    IF PPInstalled THEN
        GOSUB process ;* Main process
    END

RETURN
*-----------------------------------------------------------------------------
initialise:

    PPInstalled = ""
    EB.API.ProductIsInCompany("PP",PPInstalled) ;* check if PP product is installed
    
    credAccLine = ""
    credPartyName = ""
    debtAccLine = ""
    debtPartyName = ""
    OutText = ""

RETURN
*-----------------------------------------------------------------------------
process:

    GOSUB getDetails

    OutText = credAccLine :"#": credPartyName :"#": debtAccLine :'#': debtPartyName

RETURN
*-----------------------------------------------------------------------------
getDetails:
    
    iTransAccDetails = ""
    iTransAccDetails<PP.DebitPartyDeterminationService.InputTransactionAccDetails.ftNumber> = ApplicationId
    iTransAccDetails<PP.DebitPartyDeterminationService.InputTransactionAccDetails.companyID> = EB.SystemTables.getIdCompany()
    oAccInfoDetails = ""
    oGetAccError = ""
    PP.DebitPartyDeterminationService.getAccInfoDetails(iTransAccDetails, oAccInfoDetails, oGetAccError) ;* call getAccInfoDetails API to get debit and credit acct details

    AccTypeCnt = DCOUNT(oAccInfoDetails<PP.DebitPartyDeterminationService.AccInfoDetails.mainOrChargeAccType>,@VM)
    FOR AccType = 1 TO AccTypeCnt
        IF oAccInfoDetails<PP.DebitPartyDeterminationService.AccInfoDetails.mainOrChargeAccType,AccType> EQ "D" THEN ;* debit details
            debtAccLine = oAccInfoDetails<PP.DebitPartyDeterminationService.AccInfoDetails.accountNumber,AccType>
            debtPartyName = oAccInfoDetails<PP.DebitPartyDeterminationService.AccInfoDetails.customerName,AccType>
        END
        IF oAccInfoDetails<PP.DebitPartyDeterminationService.AccInfoDetails.mainOrChargeAccType,AccType> EQ "C" THEN ;* credit details
            credAccLine = oAccInfoDetails<PP.DebitPartyDeterminationService.AccInfoDetails.accountNumber,AccType>
            credPartyName = oAccInfoDetails<PP.DebitPartyDeterminationService.AccInfoDetails.customerName,AccType>
        END
    NEXT AccType
        
RETURN
*-----------------------------------------------------------------------------
END
