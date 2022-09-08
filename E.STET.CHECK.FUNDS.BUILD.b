* @ValidationCode : MjoxNDk0MjA1NDA5OkNwMTI1MjoxNTYxMzcwMTUxMDczOnNyYXZpa3VtYXI6NjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwNy4yMDE5MDYxMi0wMzIxOjEwMjo5MQ==
* @ValidationInfo : Timestamp         : 24 Jun 2019 15:25:51
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 91/102 (89.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190612-0321
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PZ.ModelBank
SUBROUTINE E.STET.CHECK.FUNDS.BUILD(EnqData)
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>To define the arguments </desc>
* Incoming Arguments:
*
* @param EnqData - The actual selection creiteria defined in the enquiry selection
*
* Outgoing Arguments:
*
* @param EnqData - Modified selection criteria
*
*** </region>
*-----------------------------------------------------------------------------
* Modification History :
*
* 22/2/19 - Defect 3003472 / Task 3003473
*           Build routine introduced to modify enquiry selection criteria based on STET requirements
*
* 24/06/19 - Enhancement 3187108 / Task 3187086
*			 Code changes have been made to check product installation for CQ
*
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.Reports
    $USING CQ.Cards
    $USING AC.AccountOpening
    $USING EB.DataAccess
    $USING EB.API
*-----------------------------------------------------------------------------

    GOSUB initialise ;*initialise necessary variables
    GOSUB fetchData ;*fetch necessary data from selection

RETURN

initialise:

    iBanPos = ''
    bankPos = ''
    cPanPos = ''
    iBan = ''
    bank = ''
    cPan = ''
    KeyList = ''
    selected = ''
    cardIssueEr = ''
    cardIssueRecord = ''
    accountId = ''
    accountRecCard = ''
    accErr = ''
    HistRec = ''
    Yerror = ''

RETURN

fetchData:

    LOCATE "ACCOUNT" IN EnqData<2,1> SETTING iBanPos THEN ;*get IBAN
        iBan = EnqData<4,iBanPos>
    END

    LOCATE "BANK" IN EnqData<2,1> SETTING bankPos THEN ;*get Bank
        bank = EnqData<4,bankPos>
    END

    CqInstalled = ''
    EB.API.ProductIsInCompany('CQ', CqInstalled)
    IF CqInstalled THEN       ;* Check whether the product 'CQ' is installed
        LOCATE "CARD.NUMBER" IN EnqData<2,1> SETTING cPanPos THEN ;*get CPAN
            cPan = EnqData<4,cPanPos>
            IF cPan THEN
                FN.CARD.ISSUE = 'F.CARD.ISSUE'
                F.CARD.ISSUE = ''
                EB.DataAccess.Opf(FN.CARD.ISSUE, F.CARD.ISSUE)
                SelectStatement = "SELECT ":FN.CARD.ISSUE:" WITH @ID LIKE ":"...":cPan:"..."
                EB.DataAccess.Readlist(SelectStatement, KeyList, '', selected, '') ;*Use read list to get the card number prefix
                IF selected = 0 THEN
                    EB.Reports.setEnqError("PZ-CARD.NUMBER.INVALID") ;*if no card issue record is selected
                    RETURN
                END
                cardIssueRecord = CQ.Cards.CardIssue.Read(KeyList, cardIssueEr)
                accountId = cardIssueRecord<CQ.Cards.CardIssue.CardIsAccount>
                IF NOT(iBan)THEN ;*If only CPAN is given, introduce selection for account to proceed with further processing in conversion routine.
                    EnqData<2,-1> = "ACCOUNT"
                    EnqData<3,-1> = "EQ"
                    EnqData<4,-1> = accountId
                END
                accountRecCard = AC.AccountOpening.Account.Read(accountId,accErr) ;*Read account record
            END
        END
    END

    GOSUB validateSelection ;*Validate selection provided


RETURN

*-----------------------------------------------------------------------------
validateSelection:  ;*Validate against CPAN
*-----------------------------------------------------------------------------

    IF accountRecCard THEN ;*If CPAN is present
        IF iBan THEN ;*If IBAN is present
            IF iBan NE accountId THEN ;*LOCATE iBan IN accountRecCard<AC.AccountOpening.Account.AltAcctId> SETTING iBanType ELSE
                EB.Reports.setEnqError("PZ-DOES.NOT.MATCH":@FM:'CPAN':@VM:'IBAN')
                RETURN
            END
        END ;*END of Locate
        IF bank AND bank NE accountId THEN
            EB.Reports.setEnqError("PZ-DOES.NOT.MATCH":@FM:'CPAN':@VM:'BANK')
            RETURN
        END
        RETURN ;*Dont process further since all validations are done
    END ELSE ;*If CPAN is not present
        GOSUB validateWithBank
    END
RETURN


*-----------------------------------------------------------------------------
validateWithBank: ;* Validate against BANK
*-----------------------------------------------------------------------------

    IF bank THEN
        account = bank
        accountRec = AC.AccountOpening.Account.Read(account,accErr) ;*Read account record
        IF accErr THEN ;*If both account and mnemonic value is not given
            accountHis = account
            F.ACCOUNT$HIS = ''
            EB.DataAccess.Opf('F.ACCOUNT$HIS',F.ACCOUNT$HIS)
            EB.DataAccess.ReadHistoryRec(F.ACCOUNT$HIS, accountHis, HistRec, Yerror)
            IF HistRec THEN
                EB.Reports.setEnqError('AC-ACCOUNT.CLOSED.STATUS')
                RETURN
            END ELSE
                EB.Reports.setEnqError('PZ-BANK.INVALID')
                RETURN
            END
        END
        IF NOT(iBan) THEN ;*If IBAN is not present
            RETURN ;*No more further validations happen at this level
        END
        IF account NE iBan THEN ;*LOCATE iBan IN accountRec<AC.AccountOpening.Account.AltAcctId> SETTING iBanType ELSE
            EB.Reports.setEnqError("PZ-DOES.NOT.MATCH":@FM:'BANK':@VM:'IBAN')
            RETURN
        END
        RETURN ;*Dont process further since all validations are done
    END ELSE
        GOSUB checkMandatory
    END
RETURN

*-----------------------------------------------------------------------------
checkMandatory: ;* Validate if either one selection is given
*-----------------------------------------------------------------------------

    IF NOT(bank OR iBan OR cPan) THEN
        EB.Reports.setEnqError("PZ-ONE.ACC.INPUT.MANDATORY")
        RETURN
    END

RETURN
END


