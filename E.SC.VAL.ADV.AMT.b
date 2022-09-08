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

*-----------------------------------------------------------------------------
* <Rating>-59</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScvReports
    SUBROUTINE E.SC.VAL.ADV.AMT
************************************************************
*
*   SUBROUTINE TO EXTRACT THE ADVISED AMOUNT FROM THE LIMITS FILE
*   RECORD FOR SC.VAL.MARGIN .
*
*   AUTHOR  : A.K.
*   DATE    : 23/10/86
*
*  PIF GB9200915; Now reads REF.CCY from VALUATION.CURRENCY field on
*  SEC.ACC.MASTER rather than REFERENCE.CURRENCY. (pete 08/10/92)
*
************************************************************
*** <region name= Modification History>
*** <desc>Modification History </desc>
* Modification History:
*
* 23/09/02 - EN_10001200
*            Conversion of error messages to error codes.
*
* 25/11/08 - GLOBUS_BG_100020996 - dgearing@temenos.com
*            Tidy up.
*
* 20/07/10 - 68871: Amend SC routines to use the Customer Service API's
*
* 20/04/15 - * 20/04/15 - 1323085
*            Incorporation of components
*-----------------------------------------------------------
*** </region>
*** <region name= Inserts>
*** <desc>Inserts </desc>

    $INSERT I_CustomerService_Parent
*** </region>
    $USING ST.ExchangeRate
    $USING EB.ErrorProcessing
    $USING SC.ScoPortfolioMaintenance
    $USING LI.Config
    $USING AC.AccountOpening
    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.Foundation

    tmp.O.DATA = EB.Reports.getOData()
    SEC.ACC.NO = FIELD(tmp.O.DATA,'.',1)
    EB.Reports.setOData(tmp.O.DATA)
    CUST.NO = FIELD(SEC.ACC.NO,'-',1)
    R.SEC.ACC.MASTER = '' ; * BG_100020996 s
    YERR = ''
    R.SEC.ACC.MASTER = SC.ScoPortfolioMaintenance.tableSecAccMaster(SEC.ACC.NO,YERR)

    REF.CCY = R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamValuationCurrency>
    FIN.ACC.NOS = R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamAccountNos> ; * BG_100020996 e
    CCY2 = REF.CCY
*
* EXTRACT ADVISED AMT FROM THE LIMIT FILE .
*
    LOMBARD.CREDIT.LIMIT = 0

    customerKey = CUST.NO
    customerParent = ''
    CALL CustomerService.getParent(customerKey,customerParent)
    IF EB.SystemTables.getEtext() = '' THEN
        CUST.LIAB = customerParent<Parent.customerLiability>
    END ELSE
        EB.SystemTables.setEtext('')
        CUST.LIAB = CUST.NO
    END

    NO.FIN.ACCS = DCOUNT(FIN.ACC.NOS,@VM) ; * BG_100020996 s
    FOUND.LIMIT = @FALSE
    FOR ACCOUNT.LOCAL = 1 TO NO.FIN.ACCS UNTIL FOUND.LIMIT ; * BG_100020996 e
        K.FIN.ACC = FIN.ACC.NOS<1,ACCOUNT.LOCAL>
        IF K.FIN.ACC THEN
            ACC.ERR = ''
            R.ACC = AC.AccountOpening.tableAccount(K.FIN.ACC,ACC.ERR)
            LIMIT.REF = R.ACC<AC.AccountOpening.Account.LimitRef>

            IF LIMIT.REF # 'NOSTRO' AND LIMIT.REF # '' THEN
                GOSUB GET.LIMIT ; *Get limit record and amount
            END
        END
    NEXT ACCOUNT.LOCAL

    EB.Foundation.ScFormatCcyAmt(CCY2,LOMBARD.CREDIT.LIMIT)
*
    EB.Reports.setOData(LOMBARD.CREDIT.LIMIT)
    RETURN
*
************************
* CONVERT AMOUNT.
************************
*------------
EXCHANGE:
*------------

    XCHANGE = '' ; RET.CODE = ''
    AMT2 = ''
    ST.ExchangeRate.Exchrate("1",CCY1,AMT1,CCY2,AMT2,'',XCHANGE,'','',RET.CODE)
    IF RET.CODE<2> THEN
        EB.SystemTables.setE('SC.RTN.RATE.OUT.TOL')
        GOSUB FATAL
    END
    IF EB.SystemTables.getEtext() THEN
        EB.SystemTables.setE(EB.SystemTables.getEtext())
        GOSUB FATAL
    END
    RETURN
*


*-----------
FATAL:
*-----------
*
    EB.SystemTables.setText(EB.SystemTables.getE())
    EB.ErrorProcessing.FatalError('E.SC.VAL.ADV.AMT')

    RETURN

*-----------------------------------------------------------------------------
*** <region name= GET.LIMIT>
GET.LIMIT:
*** <desc>Get limit record and amount </desc>

    FIRST.PART.REF = FMT(FIELD(LIMIT.REF,'.',1),'7"0"R')
    BEGIN CASE
        CASE FIRST.PART.REF[1,3] # 0
            FIRST.PART.REF = FIRST.PART.REF[1,3]:'0000'
        CASE FIRST.PART.REF[4,2] # 0
            FIRST.PART.REF = FIRST.PART.REF[1,5]:'00'
    END CASE
    SECOND.PART.REF = FIELD(LIMIT.REF,'.',2)
    TOP.LEVEL.REF = FIRST.PART.REF:'.':SECOND.PART.REF
    K.LIMIT = CUST.LIAB:'.':TOP.LEVEL.REF
    R.LIMIT = '' ; * BG_100020996 s
    YERR = ''
    R.LIMIT = LI.Config.tableLimit(K.LIMIT,YERR)

    LOMBARD.CREDIT.LIMIT = R.LIMIT<LI.Config.Limit.AdvisedAmount>
    LIMIT.CCY = R.LIMIT<LI.Config.Limit.LimitCurrency> ; * BG_100020996 e
    IF YERR = '' THEN ; * BG_100020996
        IF LIMIT.CCY # REF.CCY THEN
            AMT1 = LOMBARD.CREDIT.LIMIT
            CCY1 = LIMIT.CCY
            GOSUB EXCHANGE
            LOMBARD.CREDIT.LIMIT = AMT2
        END
        FOUND.LIMIT = @TRUE ; * BG_100020996
    END

    RETURN
*** </region>

    END
