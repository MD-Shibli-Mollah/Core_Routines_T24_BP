* @ValidationCode : MjoxMDc5NzY3NDgzOkNwMTI1MjoxNjEzMzkzNzU4NDYxOmRpdnlhc2FyYXZhbmFuOjEwOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA2LjIwMjAwNTIxLTA2NTU6MzA0OjI3Mg==
* @ValidationInfo : Timestamp         : 15 Feb 2021 18:25:58
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : divyasaravanan
* @ValidationInfo : Nb tests success  : 10
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 272/304 (89.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>572</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.FIN.SUMMARY(SCHED.ARR)
*
** Enquiry routine to return a list of balance types for an
** arrangement for a given date
** needs to look at the properties of the arrangement and
** add the possible prefixes and suffixes to the property
** balance types and associated balance for the date will be
** added to the arrangement record
*
** Uses
**  R.RECORD - AA.ARRANGEMENT layout
**  O.DATA  - ARRANGEMENT ID
**  ENQ.SELECTION - to find effective date
** Updates
**  R.RECORD
*
*-----------------------------------------------------------------------------
*MODIFICATION HISTORY
*
* 05/01/09 - BG_100021512
*            Arguments changed for SIM.READ.
*
*
* 16/01/09 - BG_100021546
*            Hard coded logic to display Balance Types of
*            TERM.AMOUNT is now removed.
*
* 07/10/09 - CI_10066245
*            Ref: HD0935656
*            Calculate the interest amount using the AA.INTEREST.ACCRULES file
*            during the projection of simulation overview screen.
*
* 01/10/09 - CI_10066780
*            Replaced the call to AA.GET.ARRANGEMENT.PRODUCT with AA.GET.ARRANGEMENT.PROPERTIES
*            to get the list arrangement of properties.
*            Ref: HD0935492
*
* 13/08/10 - Task : 76269
*            Defect : 75685
*            Financial summary not displayed for a future dated arrangement. End Date and Effective Date
*            assigned with Start Date if Start Date is greater.
*
* 06/11/13 - Task : 829073
*            Defect : 823332
*            The arrangement balances was not comes to zero in the simulation overview screen after simulating the payoff activity.
*
* 11/06/14 - Task : 722477
*            Enh : 713751
*            Request type 6 is assigned with charge off type value (Bank, Customer , Both)
*
* 01/01/15 - Task : 1213915
*            Defect : 1201788
*            If FIXED.SELECTION is given then not need to process other balances
*
* 01/01/16 - Task : 1397005
*            Enhancement : 1396849
*            Contract date will hold the current system date (trade date), hence use Value date to fetch the arrangement base date.
*
* 17/11/16 - Task : 1928067
*            Defect : 1922102
*            AA Arrangement Total Due amount and detail amount different
*
* 30/12/16 - Task : 1971272
*            Defect : 1970411
*            CURCOMMITMENT increases in LOC (Revolving) Loan when charge is capitalized.
*
*
* 03/12/16 - Task: 1945332   /  Defect: 1937723
*            In arrangement overview sign for interest accruals should be -ve.
*            For simulation the for interest the balance should be fetched from interest accruals instead GetPeriodBalances
*
* 30/05/19 - Task : 3154426
*            Def  : 3147824
*            Need to set the CHRG.TYPE to BANK if the arrangement is charged off.

** 05/09/19 - Enhancement : 3250575
*            Task : 3250578
*            To display CUST and CO balances of fully charged-off contract
*
* 27/09/19 - Defect : 3354197
*            Task   : 3360150
*            Drilldown Not working for Accruals Related Details in Financial Summary.
*
* 18/03/20 - Enhancement : 3611016
*            Task   : 3611019
*            DRILL.DOWN.ENQ given in fixed selection for API Enquiry
*
* 11/08/20 - Defect : 3899756
*            Task   : 3905331
*            Performance issue.
*            Read the balance types using cache read only for the ones provided as part of selection.
*            No need of loading all the balance types in system.
*
* 09/02/21 - Enhancement : 4023769
*            Task   : 4222321
*            Model routine changes for FWD balances in Financial Summary.
*
* 15/02/21 - Enhancement : 4217759
*            Task   : 4232588
*            Forward Dated arrangement financial summary changes
*
*-----------------------------------------------------------------------------

    $USING EB.Reports
    $USING AA.Framework
    $USING AA.ProductFramework
    $USING AC.SoftAccounting
    $USING AA.PaymentSchedule
    $USING AA.Interest
    $USING EB.DataAccess
    $USING EB.DatInterface
    $USING EB.SystemTables
    $USING AF.Framework
    $USING AA.TermAmount

*

    GOSUB INITIALISE
    GOSUB GET.BALANCE.TYPES
    GOSUB ADD.BALANCES
    IF NOT(DRILL.DOWN) THEN
        GOSUB SORT.ARRAY
    END

    IF CHRG.TYPE AND NOT(CLEAR.CHRG.TYPE) THEN
        GOSUB FRAME.CHARGEOFF.ARRAY
    END

*
RETURN
*
*-----------------------------------------------------------------------------
INITIALISE:

    ARR.NO = ""
    SIM.REF = ""
    ST.DT = ""
    END.DT = ""
    EFF.DATE = ""
    BAL.TYPES = ""
    IDX = ""
    BALANCE.LIST = ""
    REQUEST.TYPE = ""
    ARR.POS = ""
    CHRG.TYPE = ""
    DRILL.DOWN = ""

    LOCATE 'ARRANGEMENT.ID' IN EB.Reports.getEnqSelection()<2,1> SETTING ID.POS THEN
        ARR.NO = EB.Reports.getEnqSelection()<4,ID.POS>
    END
*
    LOCATE 'SIM.REF' IN EB.Reports.getEnqSelection()<2,1> SETTING SIM.POS THEN
        SIM.REF = EB.Reports.getEnqSelection()<4,SIM.POS>
    END
*
    LOCATE 'START.DATE' IN EB.Reports.getEnqSelection()<2,1> SETTING SIM.POS THEN
        ST.DT = EB.Reports.getEnqSelection()<4,SIM.POS>
    END
*
    LOCATE 'END.DATE' IN EB.Reports.getEnqSelection()<2,1> SETTING SIM.POS THEN
        END.DT = EB.Reports.getEnqSelection()<4,SIM.POS>
    END
*
    LOCATE 'BALANCE.TYPE' IN EB.Reports.getEnqSelection()<2,1> SETTING BAL.POS THEN
        BAL.TYPES = EB.Reports.getEnqSelection()<4,BAL.POS>
    END ELSE
        BAL.TYPES = ''
    END

    LOCATE 'CHG.OFF' IN EB.Reports.getEnqSelection()<2,1> SETTING CHRG.POS THEN
        CHRG.TYPE = EB.Reports.getEnqSelection()<4,CHRG.POS>
    END

    CONVERT ' ' TO @FM IN BAL.TYPES
*
    FIX.SEL = EB.Reports.getREnq()<EB.Reports.Enquiry.EnqFixedSelection>

    IS.BAL.TYPE.GIVEN = ""
    IF BAL.TYPES OR FIX.SEL THEN
        IS.BAL.TYPE.GIVEN = 1     ;* Balance type is given. Only display this
    END

    NO.SEL = DCOUNT(FIX.SEL,@VM)
    FOR CNT.LOOP = 1 TO NO.SEL
        SEL.COND = FIX.SEL<1,CNT.LOOP>
        BEGIN CASE
            CASE SEL.COND[' ',1,1] EQ 'BALANCE.TYPE'
                NO.ARGS = DCOUNT(SEL.COND,' ')
                FOR ARG.CNT = 3 TO NO.ARGS
                    BAL.TYPES<-1> = SEL.COND[' ',ARG.CNT,1]
                NEXT ARG.CNT
            CASE SEL.COND[' ',1,1] EQ 'DRILL.DOWN.ENQ'  ;* DRILL.DOWN.ENQ set as YES in fixed selection.
                DRILL.DOWN = SEL.COND[' ',3,1] EQ 'YES'

        END CASE
    NEXT CNT.LOOP
*
    LOCATE 'DISPLAY.ZERO.BALS' IN EB.Reports.getEnqSelection()<2,1> SETTING BAL.POS THEN
        DISP.ZERO = EB.Reports.getEnqSelection()<4,BAL.POS> EQ 'YES'
    END ELSE
        DISP.ZERO = ''
    END
*
    IF NOT(DRILL.DOWN) THEN ;* If DRILL.DOWN defined through fixed selection, skip to take it from selection criteria
        LOCATE 'DRILL.DOWN.ENQ' IN EB.Reports.getEnqSelection()<2,1> SETTING ID.POS THEN
            DRILL.DOWN = EB.Reports.getEnqSelection()<4,ID.POS> EQ 'YES'
        END ELSE
            DRILL.DOWN = ''
        END
    END
*
    AF.Framework.setProductArr(AA.Framework.AaArrangement)
*    AA.Framework.setProductArr(AA.Framework.AaArrangement)
    IF SIM.REF THEN
        IF END.DT ELSE
            FV.AA.SIM = ''
            R.AA.SIM = ''
            RET.ERR = ''
            R.AA.SIM = AA.Framework.SimulationRunner.Read(SIM.REF, RET.ERR)
            END.DT = R.AA.SIM<AA.Framework.SimulationRunner.SimSimEndDate>
        END
        EB.DatInterface.SimRead(SIM.REF, 'F.AA.ACCOUNT.DETAILS', ARR.NO, R.ACCOUNT.DETAILS, "", "", ERRMSG)
        EB.DatInterface.SimRead(SIM.REF, 'F.AA.ARRANGEMENT', ARR.NO, ARR.RECORD, "", "", RET.ERR)
    END ELSE
        AA.Framework.GetArrangement(ARR.NO, ARR.RECORD, RET.ERR)
        AA.PaymentSchedule.ProcessAccountDetails(ARR.NO, 'INITIALISE', '', R.ACCOUNT.DETAILS, ERRMSG)
    END

** When this NoFile enquiry routine called from the AA.DETAILS.FINANCIAL.SUMMARY then the CHRG.TYPE will not get set. Because
** this should project only BANK balances like CURACCOUNT. So we need to set the CHRG.TYPE to BANK if the arrangement is charged off.
** If we not set this flag then AA.GET.PERIOD.BALANCES called with CHRG.TYPE as null and inside that routine we set the CHARGEOFF.TYPE as BOTH
** to get both the BANK and CUST balances and merged them. So it results the TOTPRINCIPAL shown from this enquiry not reflecting the CURACCOUNT balance.
    CLEAR.CHRG.TYPE = 0 ;* Flag to clear charge off type after get.period.balances
    IF CHRG.TYPE EQ "" AND R.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdChargeoffDate> THEN
        CLEAR.CHRG.TYPE = 1
        CHRG.TYPE = "BANK"
    END
*
    IF ST.DT EQ '' THEN
        ST.DT = R.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdValueDate>
    END
*
    IF END.DT EQ '' THEN
        END.DT = EB.SystemTables.getToday()
        IF ST.DT GT END.DT THEN         ;* can be true for fwd dated arrangement
            END.DT = ST.DT
        END
    END
*
    ACCT.NO = ARR.RECORD<AA.Framework.Arrangement.ArrLinkedApplId>
    BALANCE.TYPE.POS = 50     ;* Balance type field in record
    BALANCE.BK.AMT.POS = 51   ;* Booking dated balance for balance type
    BALANCE.VD.AMT.POS = 52   ;* Value Dated balance for balance type
*
    EFF.DATE = EB.SystemTables.getToday()
    IF ST.DT GT EFF.DATE THEN ;* can be true for fwd dated arrangement
        EFF.DATE = ST.DT
    END
*

    AA.Framework.GetArrangementProduct(ARR.NO, EFF.DATE, RArrangement, ProductId, RPropertyList)  ;* Product details are needed to get the product record
    AA.ProductFramework.GetPublishedRecord("PRODUCT", "", ProductId, EFF.DATE, RProductRecord, RetErr) ;* Product record is needed to get the source balance type for the interest property
 
    SCHED.ARR = ''
    TEMP.SCHED.ARR = ''
    PROP.CLS.LIST = ''
    PROP.LIST = ''
    REQD.BAL.LIST = ''
*
    R.TERM.AMT.REC = ''
    R.TERM.AMT.PROPERTY.COND.REC = ''
    FWD.ACCOUNTING.FLAG = ''
    AA.Framework.GetArrangementConditions(ARR.NO, "TERM.AMOUNT", "", EFF.DATE, "", R.TERM.AMT.REC, RET.ERROR) ;* get term amount property condition
    R.TERM.AMT.PROPERTY.COND.REC = RAISE(R.TERM.AMT.REC)   ;* to raise the returned lowered property condition record
    FWD.ACCOUNTING = R.TERM.AMT.PROPERTY.COND.REC<AA.TermAmount.TermAmount.AmtFwdAccting>
    IF FWD.ACCOUNTING EQ 'YES' THEN
        FWD.ACCOUNTING.FLAG = 1
    END
*
RETURN
*
*-----------------------------------------------------------------------------
GET.BALANCE.TYPES:
*
** Get the list of properties from the arrangement record
** then from the property class get the prefixes
** also get a list of all balance types so that we can look for virtual balances
** and any that are created by soft accounting
*

* Forcefully append null values into ARR.INFO, so that, values are not picked from common in AA.GET.ARRANGEMENT.PROPERTIES
* This is done to avoid common variables of some other arrangement getting assinged from cache, when multiple arrangment details are accessed within
* the same session
    PROPERTY.LIST = ""
    ARR.INFO = ARR.NO:@FM:'':@FM:'':@FM:'':@FM:'':@FM:''
    AA.Framework.GetArrangementProperties(ARR.INFO, EFF.DATE, ARR.RECORD, PROPERTY.LIST)     ;* Get properties associated with the arrangement for the effective date

    IF NOT(IS.BAL.TYPE.GIVEN) THEN       ;*No balance type given, so build for TOT Term Amount, CUR Term Amount & CUR Account
        AA.ProductFramework.GetPropertyClass(PROPERTY.LIST, PROP.CLS.LIST)
        LOCATE "TERM.AMOUNT" IN PROP.CLS.LIST<1,1> SETTING PROP.POS THEN
            PR.TERM.AMT = PROPERTY.LIST<1,PROP.POS>
            BAL.TYPES<-1> = "TOT":PR.TERM.AMT
            BAL.TYPES<-1> = "CUR":PR.TERM.AMT
        END
*
        LOCATE "ACCOUNT" IN PROP.CLS.LIST<1,1> SETTING PROP.POS THEN
            PR.ACC = PROPERTY.LIST<1,PROP.POS>
            BAL.TYPES<-1> = "CUR":PR.ACC
        END
    END

    BALANCE.LIST = CHANGE(BAL.TYPES,@VM,@FM)
    REQD.BAL.LIST = BAL.TYPES
*
RETURN
*
*-----------------------------------------------------------------------------
ADD.BALANCES:
*
** Now for each balance in the list call EB.GET.ACCT.BALANCE to retrieve
** the balance we want
*
    NEXT.BAL = 0
    IDX = 0
    REQUEST.TYPE<3> = 'ALL'
    REQUEST.TYPE<2> = 'ALL'
    BAL.DETAILS = ''
    LOOP
        IDX += 1
        BALANCE.TYPE = BALANCE.LIST<IDX>

        PROPERTY = PROP.LIST<IDX>
        PROPERTY.CLASS = PROP.CLS.LIST<IDX>
        
    WHILE BALANCE.TYPE
        
        BALANCE.TYPE.REC = ''
        BALANCE.TYPE.REC = AC.SoftAccounting.BalanceType.CacheRead(BALANCE.TYPE, "") ;* read each balance type given from AC.BALANCE.TYPE
        IF BALANCE.TYPE.REC THEN ;* proceed if we have a record available for the balance type
            
            VIRTUAL.BAL = "" ;* to display the correct accrued related details
            GOSUB CALCULATE.SIM.INTEREST
            
            VIRTUAL.BALANCES = BALANCE.TYPE.REC<AC.SoftAccounting.BalanceType.BtVirtualBal> ;* get the virtual balances specified
            IF VIRTUAL.BALANCES THEN    ;* Get the balance from the values we've already calculated
                VIRTUAL.BAL = 'YES'
                SAVE.BALANCE.TYPE =  BALANCE.TYPE
                GOSUB CALCULATE.VIRTUAL.BALANCE
                BALANCE.TYPE = SAVE.BALANCE.TYPE
                BD.BAL = BAL.AMT
            END ELSE
                IF INTEREST.FOUND NE 1 THEN
                    VIRTUAL.BAL = ''
                    GOSUB GET.PERIOD.BALANCES
                END
            END

            IF BD.BAL OR DISP.ZERO THEN
                NEXT.BAL +=1
                ARR.RECORD<BALANCE.TYPE.POS, NEXT.BAL> = BALANCE.TYPE
                ARR.RECORD<BALANCE.BK.AMT.POS, NEXT.BAL> = BD.BAL
                IF NOT(DRILL.DOWN) THEN
                    LOCATE BALANCE.TYPE IN REQD.BAL.LIST<1> SETTING REQ.POS THEN
                  
                        CURRENT.PROPERTY = ""
                        CURRENT.PROPERTY.CLASS = ""
                        CURRENT.PROPERTY = BALANCE.TYPE[4,20]
                        AA.ProductFramework.GetPropertyClass(CURRENT.PROPERTY, CURRENT.PROPERTY.CLASS)
                        IF CURRENT.PROPERTY.CLASS EQ "TERM.AMOUNT" AND BALANCE.TYPE[1,3] EQ "CUR" AND BD.BAL GT 0 THEN
                            BD.BAL = 0 ;* Shows the available commitment as 0 when the CUR<TERM.AMOUNT> goes in positive for loans
                        END
                                                    
                        ARR.POS<-1> = REQ.POS
                        TEMP.SCHED.ARR<-1> = BALANCE.TYPE:'*':BD.BAL:'*':VIRTUAL.BAL:'*':PROPERTY:'*':PROPERTY.CLASS:'*':ARR.NO
                    END
                END
            END
        END

    REPEAT
*
RETURN
*
*-----------------------------------------------------------------------------
CALCULATE.VIRTUAL.BALANCE:
*
** We'll calculate this from the balances that we will have already extracted
** We do this as although EB.GET.ACCT.BALANCE handles virtual balances it only
** does so if the balance is in ACCT.ACTIVITY which may not always be the case
** for some balances
*
    BAL.AMT = ''
    LOOP
        REMOVE BAL.NAME FROM VIRTUAL.BALANCES SETTING YD
    WHILE BAL.NAME:YD
        LOCATE BAL.NAME IN ARR.RECORD<BALANCE.TYPE.POS,1> SETTING BAL.POS THEN
            BAL.AMT += ARR.RECORD<BALANCE.BK.AMT.POS, BAL.POS>
        END ELSE
            BALANCE.TYPE = BAL.NAME
            BD.BAL = 0.00
            GOSUB CALCULATE.SIM.INTEREST          ;* For simulation get the accr amt. If found INTEREST.FOUND flag is set to '1'
            IF INTEREST.FOUND NE 1 THEN
                GOSUB GET.PERIOD.BALANCES
            END
            BAL.AMT + = BD.BAL
        END

        IF DRILL.DOWN AND (BAL.AMT OR DISP.ZERO) THEN
            SCHED.ARR<-1> = BAL.NAME:'*':BAL.AMT:'*':'':'*':'':'*':'':'*':ARR.NO:'*':SAVE.BALANCE.TYPE
            BAL.AMT = 0.00
        END
    REPEAT
*
RETURN
*
*-----------------------------------------------------------------------------
GET.PERIOD.BALANCES:

    REQUEST.TYPE<6> = CHRG.TYPE
    IF FWD.ACCOUNTING.FLAG THEN
        REQUEST.TYPE<9> = 'FWD'
    END
    AA.Framework.GetPeriodBalances(ACCT.NO,BALANCE.TYPE,REQUEST.TYPE,ST.DT,END.DT,'',BAL.DETAILS,'')
    NO.OF.DT = DCOUNT(BAL.DETAILS<1>,@VM)
    BD.BAL = BAL.DETAILS<4,NO.OF.DT>

RETURN
*-----------------------------------------------------------------------------
CALCULATE.SIM.INTEREST:

    IF SIM.REF THEN
        INTEREST.FOUND = ''
        ACCT.NO<2> = SIM.REF
        CURRENT.PROPERTY = ""
        CURRENT.PROPERTY.CLASS = ""
        TOT.ACCR.AMT = ""
        TOT.DUE.AMT = ""
        CURRENT.PROPERTY = BALANCE.TYPE[4,20]
        SourceType = ""

        AA.ProductFramework.GetPropertyClass(CURRENT.PROPERTY, CURRENT.PROPERTY.CLASS)

        IF CURRENT.PROPERTY.CLASS EQ "INTEREST" AND BALANCE.TYPE[1,3] EQ "ACC" THEN
            INT.ACCRUALS.ID = ARR.NO:"-":CURRENT.PROPERTY

            R.PROPERTY = ""
            AA.Framework.LoadStaticData("F.AA.PROPERTY",CURRENT.PROPERTY,R.PROPERTY,"")
            PROPERTY.TYPE = R.PROPERTY<AA.ProductFramework.Property.PropPropertyType>
            IS.RESIDUAL.ACCRUAL = AA.Framework.OptionSelected(PROPERTY.TYPE,"RESIDUAL.ACCRUAL")
            EB.DatInterface.SimRead(SIM.REF, 'F.AA.INTEREST.ACCRUALS', INT.ACCRUALS.ID, R.INTEREST.ACCRUALS, "", "", RET.ERR)

            IF IS.RESIDUAL.ACCRUAL THEN
                NO.DUES = DCOUNT(R.INTEREST.ACCRUALS<AA.Interest.InterestAccruals.IntAccTotAccrAmt>,@VM)
                TOT.ACCR.AMT = R.INTEREST.ACCRUALS<AA.Interest.InterestAccruals.IntAccTotAccrAmt,NO.DUES>
                TOT.DUE.AMT = R.INTEREST.ACCRUALS<AA.Interest.InterestAccruals.IntAccTotDueAmt,NO.DUES>
                TOT.RPY.AMT = R.INTEREST.ACCRUALS<AA.Interest.InterestAccruals.IntAccTotRpyAmt,NO.DUES>
            END ELSE
                TOT.ACCR.AMT = SUM(R.INTEREST.ACCRUALS<AA.Interest.InterestAccruals.IntAccTotAccrAmt>)
                TOT.DUE.AMT = SUM(R.INTEREST.ACCRUALS<AA.Interest.InterestAccruals.IntAccTotDueAmt>)
                TOT.RPY.AMT = SUM(R.INTEREST.ACCRUALS<AA.Interest.InterestAccruals.IntAccTotRpyAmt>)
            END
            BD.BAL = TOT.ACCR.AMT - TOT.DUE.AMT - TOT.RPY.AMT
            GOSUB GetAdjustmentSign
            BD.BAL = BD.BAL * Sign    ;* Interest from accrual should be considered in the opposite sign.
            INTEREST.FOUND = 1
        END
    END

RETURN



*-----------------------------------------------------------------------------
SORT.ARRAY:

    NO.OF.IDS = DCOUNT(ARR.POS,@FM)
    ADJ.CNT = 0
    FOR LOOP.CNT = 1 TO NO.OF.IDS
        INS.POS = ARR.POS<LOOP.CNT>
        SCHED.ARR<INS.POS> = TEMP.SCHED.ARR<LOOP.CNT>
    NEXT LOOP.CNT
*
    NO.OF.BAL = DCOUNT(SCHED.ARR,@FM)
    FOR LOOP.CNT = 1 TO NO.OF.BAL
        IF SCHED.ARR<LOOP.CNT> ELSE
            DEL SCHED.ARR<LOOP.CNT>
            LOOP.CNT -= 1
            NO.OF.BAL -= 1
        END
    NEXT LOOP.CNT
*
RETURN
*-----------------------------------------------------------------------------
FRAME.CHARGEOFF.ARRAY:
*--------------------
    CHG.ARRAY = SCHED.ARR
    SCHED.ARR = ""
    SCH.INT = 1
    SCH.CNT = DCOUNT(CHG.ARRAY,@FM)
    LOOP
        REMOVE ARR.VAL FROM CHG.ARRAY SETTING CHG.POS
    WHILE ARR.VAL : CHG.POS
        CHK.NO = MOD(SCH.INT,2)
        IF CHK.NO NE '0' THEN
            SCHED.ARR<-1> = CHG.ARRAY<SCH.INT>
        END ELSE
            SCHED.ARR := @FM:CHG.ARRAY<SCH.INT>   ;*EX:CURACCOUNTCO*-80000****AA19079Q9LP4/ACCPRINCIPALINTCO*-158.59****AA19079Q9LP4, it will display only first part so changed marker
        END
        SCH.INT++
    REPEAT

RETURN

*-----------------------------------------------------------------------------
*** <region name= GetAdjustmentSign>
*** <desc>Get the sign for adjustment </desc>

GetAdjustmentSign:

    ProductLine  = ARR.RECORD<AA.Framework.Arrangement.ArrProductLine>
    AA.Framework.GetSourceBalanceType(CURRENT.PROPERTY, ProductId, RProductRecord, SourceType, RetErr)  ;* Source Balance type is used to determine sign for adjustment with accrual amount

    BEGIN CASE

        CASE SourceType EQ "CREDIT"  ;* Add the adjustment amount with the accrual amount
            Sign = 1
        CASE SourceType EQ "DEBIT"   ;* Subtract the adjustment amount with the accrual amount
            Sign = -1
        CASE 1

            IF ProductLine EQ "DEPOSITS" THEN  ;* For other source balance types, Product line must be validate to arrive at the adjustment sign
                Sign = -1  ;* Deposits product line, adjustment amount must be subtracted with the accrual amount
            END ELSE
                Sign = 1  ;* For Lending and other product line, adjustment amount must be added with the accrual amount
            END

    END CASE

RETURN
    
*** </region>


*-------------------------------------------------------------------------------
END
