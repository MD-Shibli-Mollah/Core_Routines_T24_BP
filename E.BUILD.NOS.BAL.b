* @ValidationCode : MjoxNjUzMjc3NTAxOmNwMTI1MjoxNTk5Njc3NDQzNDQ3OnNhaWt1bWFyLm1ha2tlbmE6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOC4yMDIwMDczMS0xMTUxOjkzOjU5
* @ValidationInfo : Timestamp         : 10 Sep 2020 00:20:43
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : saikumar.makkena
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 59/93 (63.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>104</Rating>
*-----------------------------------------------------------------------------
* Version 10 29/09/00  GLOBUS Release No. 200508 30/06/05
*
*************************************************************************
*
$PACKAGE AC.ModelBank

SUBROUTINE E.BUILD.NOS.BAL
*
*************************************************************************
*
* This routine is called by the enquiry 'NOSTRO.POS' which displays
* the nostro balances for the next five calendar days.
*
* The routine will calculate the next five calendar days based on the
* current account currency passed in R.RECORD and determine the
* balance for each day by analysing the value dated balance fields on
* the account record.
*
* The results will be passed back in the O.DATA string as :-
*
*  R.RECORD         =   Account record - from correct company
*  O.DATA<1,1>      =   VAL.DATE:SM:VAL.DATE:SM:... (5)
*  O.DATA<1,2>      =   BALANCE:SM:BALANCE:SM:... (5)
*
* PIF GB9301840; Added Country code to call to CDT.
*
* 06/06/94 - GB9400733
*            If the account number (O.DATA) has '*LOCAL' appended
*            to it then the region code passed to CDT should be
*            that of the local currency.
*
* 11/02/97 - GB9700152
*            Look for LONG.POS.SIGN in the enquiry to set the sign to the
*            opposite if set to PLUS
*
* 28/09/98 - GB9801153
*            Do not read R.RECORD as the enquiry does this , convert to EUR
*            if required
* 31/08/04 - EN_10002239
*            Removal of Cash flow process, use Available balance instead.
*
* 17/09/10 - Task - 88199
*            If TODAY is working day in company Holiday table and Holiday in Currency
*            Hloiday table then system should not displays Nostro balance for Holiday.
*
* 23/05/11 - Enhancement - 182581 / Task- 191536
*            Moving Balances to ECB from Account Balance Fields.
*
* 06/06/11 - ENHANCEMENT 182577 /Task 191523
*            Moving Balances from ACCOUNT to ECB
*            Moving Cashflow Management Fields to ECB
*
* 13/07/12 - Defect 441964 / Task 442592
*            For Nostro Acocunt merge the ECB record to get correct balance.
*
* 12/12/12 - Defect 516257 / Task 538786
*            Get COUNTRY.CODE from CURRENCY record instead of extracting first two letters
*            of CURRENCY.
* 02/01/14 - Defect 862567 / Task 876110
*             Enquires NOSTRO.POSITION and NOSTRO.SUMMARY displays incorrect results .
*
* 28/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 04/08/2020 - Defect 3844751 / Task 3891353
*              Nostro balances are made to be displayed properly for five
*              calendar days from today irrespective of the currency.
*
* 09/09/20 - Enhancement 3932648 / Task 3952625
*            Reference of EB.CONTRACT.BALANCES is changed from RE to BF
*************************************************************************
*
    $USING EB.SystemTables
    $USING EB.Reports
    $USING AC.AccountOpening
    $USING EB.API
    $USING AC.HighVolume
    $USING ST.CurrencyConfig
    $USING ST.ExchangeRate
    $USING BF.ConBalanceUpdates

    GOSUB GET.VALUES
    GOSUB READ.ACCOUNT.AND.ECB
    GOSUB FORM.O.DATA

RETURN
*************************************************************************
GET.VALUES:
***********
*
    LOC.FLAG = ''
    IF EB.Reports.getOData()[6] = '*LOCAL' THEN
        LENGTH.OF.O.DATA = LEN(EB.Reports.getOData())
        EB.Reports.setOData(EB.Reports.getOData()[1,(LENGTH.OF.O.DATA - 6)])
        LOC.FLAG = 1
        LCCY.CODE = EB.SystemTables.getLccy()[1,2]
    END
*
    MULT.SIGN = 1   ;* CHnage the sign of the balances
    LOCATE "LONG.POS.SIGN" IN EB.Reports.getEnqSelection()<2,1> SETTING LP.POS THEN
        IF EB.Reports.getEnqSelection()<4,LP.POS> = "PLUS" THEN
            MULT.SIGN = -1
        END
    END
*
    CONV.NCU = ''   ;* Set if merging EU amounts
    LOCATE "MERGE.NCU" IN EB.Reports.getEnqSelection()<2,1> SETTING EU.POS THEN
        IF EB.Reports.getEnqSelection()<4,EU.POS>[1,1] = 'Y' THEN
            CONV.NCU = 1
        END
    END
*
RETURN
*--------------------------------------------------------------------------------------------------
READ.ACCOUNT.AND.ECB:
********************
* call core routine to return baalnce of HVT account( All Nostro Accounts are Nostro Accounts)
*
    ECB.ERR = ''
    R.ECB = ''
    ACCOUNT.KEY = EB.Reports.getOData()
    AC.HighVolume.EbReadHvt("EB.CONTRACT.BALANCES" , ACCOUNT.KEY , R.ECB , ECB.ERR)
***
    IF EB.Reports.getREnq()<EB.Reports.Enquiry.EnqFileName>['$',1,1] NE 'ACCOUNT' THEN      ;* If we don't select the account file
        R.ACCOUNT.RECORD = AC.AccountOpening.tableAccount(ACCOUNT.KEY, ERR)
        EB.Reports.setRRecord(R.ACCOUNT.RECORD);* Read account from correct company.
    END

RETURN
*--------------------------------------------------------------------------------------------------
FORM.O.DATA:
***********
* Remove Cash flow process, use available bal and mvmts instead
* Since Nostro is not updated by unauthorised transactions, then only
* authorised movements are considered
*****
    C.DATE = EB.SystemTables.getToday()
    C.BAL  = R.ECB<BF.ConBalanceUpdates.EbContractBalances.EcbWorkingBalance>
    V.DATE = R.ECB<BF.ConBalanceUpdates.EbContractBalances.EcbAvailableDate>
    D.MOV  = R.ECB<BF.ConBalanceUpdates.EbContractBalances.EcbAvAuthDbMvmt>
    C.MOV  = R.ECB<BF.ConBalanceUpdates.EbContractBalances.EcbAvAuthCrMvmt>
    V.BAL  = R.ECB<BF.ConBalanceUpdates.EbContractBalances.EcbAvailableBal>
*****

    CCY = EB.Reports.getRRecord()<AC.AccountOpening.Account.Currency>
    CCY.REC = ''
    CCY.REC = ST.CurrencyConfig.tableCurrency(CCY, ERR)
    IF ERR THEN
        CCY.REC = ''
    END

*****
    FIX.CCY      = CCY.REC<ST.CurrencyConfig.Currency.EbCurFixedCcy>
    FIX.RATE     = CCY.REC<ST.CurrencyConfig.Currency.EbCurFixedRate>
    COUNTRY.CODE = EB.Reports.getRRecord()<AC.AccountOpening.Account.Currency>[1,2]
    IF COUNTRY.CODE = "CN" THEN
* When country is CN then check in currency table whether it is CNY or CNH
* get the correct country code either CN or HK.
        COUNTRY.CODE = CCY.REC<ST.CurrencyConfig.Currency.EbCurCountryCode>         ;* Get country code from currency record
    END
*****
* Irrespective of the currency, Nostro balances will be displayed for five calendar days
* Thus code part to check today is holiday or not and date calculation for finding the
* working day in the currency specified has been removed.

    IF LOC.FLAG THEN
        REGION.CODE = LCCY.CODE:'00'
    END ELSE
        REGION.CODE = COUNTRY.CODE:'00'
    END
*****
    V$DIV = 1000
    EB.Reports.setOData('')
*****
    IF NOT(C.BAL) THEN C.BAL = 0
    IF FIX.CCY AND CONV.NCU THEN
        GOSUB CONVERT.AMOUNT  ;* Convert to Euro
    END
    FOR I = 1 TO 5
        LOCATE C.DATE IN V.DATE<1,1> BY 'AL' SETTING POS THEN
            C.BAL = V.BAL<1,POS>
            IF FIX.CCY AND CONV.NCU THEN
                GOSUB CONVERT.AMOUNT    ;* Convert to Euro
            END
        END ELSE
            BEGIN CASE
                CASE V.DATE EQ ''
                    NULL
                CASE V.DATE<1,POS>
                    C.BAL = V.BAL<1,POS> - D.MOV<1,POS> - C.MOV<1,POS>
                    IF FIX.CCY AND CONV.NCU THEN
                        GOSUB CONVERT.AMOUNT          ;* Convert to Euro
                    END
                CASE 1
                    C.BAL = V.BAL<1,POS-1>
                    IF FIX.CCY AND CONV.NCU THEN
                        GOSUB CONVERT.AMOUNT          ;* Convert to Euro
                    END
            END CASE
        END
*
        tmp=EB.Reports.getOData(); tmp<1,1,I>=C.DATE; EB.Reports.setOData(tmp)
        tmp=EB.Reports.getOData(); tmp<1,2,I>=(C.BAL / V$DIV) * MULT.SIGN; EB.Reports.setOData(tmp)
*The enquiry is made to display the balance details for calendar days .
        EB.API.Cdt(REGION.CODE,C.DATE,'+1C')

    NEXT I

RETURN
*
***************************************************************************
CONVERT.AMOUNT:
*==============
*
    OUT.AMT = ''
    ST.ExchangeRate.Exchrate('1', CCY, C.BAL, FIX.CCY, OUT.AMT, '', FIX.RATE, '', '', '')
    C.BAL = OUT.AMT
*
RETURN
*
****************************************************************************

END
