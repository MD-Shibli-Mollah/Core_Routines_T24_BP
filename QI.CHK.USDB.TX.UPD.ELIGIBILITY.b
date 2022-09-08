* @ValidationCode : MjotMTYzNTQ1ODMxODpDcDEyNTI6MTYxNjA3MjY2ODg4Mjpra2F2aXRoYW5qYWxpOjExOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTAzLjA6MTA0OjEwMg==
* @ValidationInfo : Timestamp         : 18 Mar 2021 18:34:28
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kkavithanjali
* @ValidationInfo : Nb tests success  : 11
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 102/104 (98.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE QI.Reporting

SUBROUTINE QI.CHK.USDB.TX.UPD.ELIGIBILITY(APPLICATION, APPLN.ID, APPLICATION.REC, QI.PARAM.REC, MESSAGE, QCSI.TRG.ID, QCSI.TRG.REC, RES1, RES2, ERR)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Task of the sub-routine</desc>
* Program Description
*
** This routine form the @ID and Record of F.QCSI.TRIGGER file, after checking the eligibility.
** As per this Public Api, when the TAX.TYPE defined in ENTITLEMENT / SC.ADJ.TXN.UPDATE(Created via SC.INCOME.RECLASSIFICATION) applications
** matches with QI.TAX.TYPE or FAX.TAX.TYPE defined in QI.PARAMETER, then the application is eligible for QI REPORTING.
** When the WHT.TAX.CODE defined in SEC.TRADE matches with RECALC.TAX.TYPE and CUST.TRANS.CODE of corresponding CUSTOMER.NO is SEL
** then this SEC.TRADE is eligible for QI REPORTING.
*
*-----------------------------------------------------------------------------
* @package QI.Reporting
* @stereotype subroutine
* @author kkavithanjali@temenos.com
*-----------------------------------------------------------------------------
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
* Input
*
* @param APPLICATION          Application Name - can be SEC.TRADE or ENTITLEMENT or SC.ADJ.TXN.UPDATE
*
* @param APPLN.ID             Application Id
*
* @param APPLICATION.REC      Application Record passed to retrieve TAX.TYPE
*
* @param QI.PARAM.REC         QI.PARAMETER record passed to retrieve QI.TAX.TYPE, FATCA.TAX.TYPE and RECALC.TAX.TYPE
*
* @param MESSAGE              Message will be AUT during Authorisation and Reversal Authorisation.
*
* Output
*
* @return QCSI.TRIG.ID        QCSI.TRIGGER ID is formed as REP*APPLICATION*ACTION.TYPE*APPLICATION.ID*COMPANY.ID
*                             ACTION.TYPE - can be AUT / MOD / REV
*                             During Authtorisation of SEC.TRADE / ENTITLEMENT - ACTION.TYPE will be AUT
*                             During Authtorisation of SC.ADJ.TXN.UPDATE - ACTION.TYPE will be MOD
*                             During Reversal Authtorisation of SEC.TRADE / ENTITLEMENT / SC.ADJ.XN.UPDATE - ACTION.TYPE will be REV
*
* @return QCSI.TRIG.REC       For SEC.TRADE alone, QCSI.TRIG.REC<1> is updated with list of CUSTOMER.NO separated by '*', when its corresponding CUST.TRANS.CODE is SEL.
*
* @return RES2                Reserved for Future use
*
* @return RES1                Reserved for Future use
*
* @return ERR                 Error messages, if any, during processing
*
*** </region>
*-----------------------------------------------------------------------------
*
* 22/2/2021 - Enhancement 4240448 / Task 4240456
*             Form Qcsi Trigger ID and Record for eligible transaction.
*
* 24/2/2021 - Enhancement 4240616 / Task 4240621
*             After amendment to TXN.TAX.CODE, existing SEC.TRADE is amended. Current WHT.TAX.CODE not matched with RECALC.TAX.TYPE. But the Old WHT.TAX.CODE matches with RECALC.TAX.TYPE
*             Then Form Qcsi Trigger ID with ACTION.TYPE as REV for SEC.TRADE Application, in order to stop QI REPORTING.
*             Update Flag MANUAL in QCSI.TRG.REC<2>, when ENTITLEMENT>MAN.TAX.ACY or SC.ADJ.TXN.UPDATE>NEW.INC.MAN.TAX.AMT holds value.
*             Hence with the help of this MANUAL flag, we will be able to split the Manual tax amount under an income code against a customer in case of joint portfolio.
*
* 16/3/2021 - Enhancement 4240448 / Task 4287864
*             Record Status is updated as R only, when Entitlement is reversed directly.
*             Direct reversal of Entitlement allowed for STOCK.CASH events, wherein more than one entitlement will be created after authorising the DIARY
*
*-----------------------------------------------------------------------------
    $USING QI.Config
    $USING SC.SccEntitlements
    $USING SC.SctTrading
    $USING EB.SystemTables

    GOSUB INITIALISE ; * Initialise the Local variables
    
    IF MESSAGE NE "AUT" THEN ;* For Message other than AUT, skip QCSI.TRIGGER ID formation.
        RETURN
    END
    
    GOSUB SET.RULE.TYPE ; * Set the Rule Type of Entitlement / Sc Adj Txn Update / Sec Trade to be located in QI.PARAMETER
    
    LOCATE RULE.TYPE IN QI.PARAM.REC<QI.Config.QiParameter.QiParRuleType,1> SETTING RULE.POS ELSE
        RETURN
    END
    
    GOSUB GET.TAX.TYPE ; * Get the Sc Tax type from Sec Trade, Entitlement or Sc Adj Txn pdate Application

*   When the Tax Type from the Entitlement or ScAdjTxnUpdate Application matches with that of QI or FATCA Tax Type defined in QI.PARAMETER
*   or Sec trade's Wht tax code matches with Recalc tax type, then form QCSI.TRIGGER ID

    IF NOT(SC.TAX.TYPE OR SEC.TRADE.TAX.TYPE) THEN ;* Skip trigger id creation for manually created SC.ADJ.TXN.UPDATE
        RETURN
    END
    
    GOSUB FORM.QCSI.TRIGGER ; * Form the ID and Record of F.QCSI.TRIGGER

RETURN


*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> Initialise the Local variables </desc>

*   Get the QI.TAX.TYPE and FATCA.TAX.TYPE from QI.PARAMETER
    QI.TAX.TYPE = QI.PARAM.REC<QI.Config.QiParameter.QiParQiTaxType>
    FATCA.TAX.TYPE = QI.PARAM.REC<QI.Config.QiParameter.QiParFatcaTaxType>
    QI.RECALC.TAX.TYPE = QI.PARAM.REC<QI.Config.QiParameter.QiParRecalcTaxType>
    
    APPLN.COMPANY.ID = EB.SystemTables.getIdCompany()
    
    REC.STATUS = ""
    ACTION.TYPE = ""
    SC.TAX.TYPE = ""
    SEC.TRADE.TAX.TYPE = ""
    PROCEED.FLAG = ""
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= SET.RULE.TYPE>
SET.RULE.TYPE:
*** <desc> Set the Rule Type of Entitlement / Sc Adj Txn Update / Sec Trade to be located in QI.PARAMETER </desc>
   
    BEGIN CASE
        CASE APPLICATION EQ "ENTITLEMENT"
            RULE.TYPE = "QI.REP.MAP.ENT"
            
        CASE APPLICATION EQ "SC.ADJ.TXN.UPDATE"
            RULE.TYPE = "QI.REP.MAP.SCADJUPD"
    
        CASE APPLICATION EQ "SEC.TRADE"
            RULE.TYPE = "QI.REP.MAP.SECTR"
    END CASE
    
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= GET.TAX.TYPE>
GET.TAX.TYPE:
*** <desc> Get the Sc Tax type from Sec Trade, Entitlement or Sc Adj Txn pdate Application </desc>

    BEGIN CASE
    
        CASE APPLICATION EQ "ENTITLEMENT"
            
            TAX.TYPE = APPLICATION.REC<SC.SccEntitlements.Entitlement.EntScTaxType>
            TAX.TYP.CNT = DCOUNT(TAX.TYPE,@VM)
            FOR CNT = 1 TO TAX.TYP.CNT ;* ENT.SC.TAX.TYPE is multi value field
                SC.TAX.TYPE<-1> = FIELD(TAX.TYPE<1,CNT>,'*',2) ;* ENT.SC.TAX.TYPE accepts valid TAX or TAX.TYPE record. When TAX.TYPE record is attached, this field value is prefixed with *
            NEXT CNT
            REC.STATUS = APPLICATION.REC<SC.SccEntitlements.Entitlement.EntRecordStatus>
            MAN.TAX.AMT = APPLICATION.REC<SC.SccEntitlements.Entitlement.EntManTaxAcy>
            LOCATE QI.TAX.TYPE IN SC.TAX.TYPE SETTING POS ELSE
                LOCATE FATCA.TAX.TYPE IN SC.TAX.TYPE SETTING POS ELSE
                    RETURN
                END
            END
        
            PROCEED.FLAG = 1 ;* QI.TAX.TYPE or FATCA.TAX.TYPE from QI.PARAMETER matches with the SC.TAX.TYPE list for ENTITLEMENT Application
            
        CASE APPLICATION EQ "SC.ADJ.TXN.UPDATE" AND APPLICATION.REC<SC.SccEntitlements.AdjTxnUpdate.AdjScIncomeReclassification>
            
            SC.TAX.TYPE = APPLICATION.REC<SC.SccEntitlements.AdjTxnUpdate.AdjTaxType> ;* ADJ.TAX.TYPE accepts only valid TAX.TYPE record. ADJ.TAX.TYPE is Single Value field.
            REC.STATUS = APPLICATION.REC<SC.SccEntitlements.AdjTxnUpdate.AdjRecordStatus>
            IF MESSAGE EQ "AUT" AND REC.STATUS NE "RNAU" THEN
                ACTION.TYPE = "MOD"
            END
            MAN.TAX.AMT = APPLICATION.REC<SC.SccEntitlements.AdjTxnUpdate.AdjNewIncManTaxAmt>
            CONVERT @SM TO '' IN MAN.TAX.AMT
            IF SC.TAX.TYPE AND QI.TAX.TYPE NE SC.TAX.TYPE THEN
                RETURN
            END
            
            PROCEED.FLAG = 1 ;* QI.TAX.TYPE from QI.PARAMETER matches with the SC.TAX.TYPE for SC.ADJ.TXN.UPDATE Application
    
        CASE APPLICATION EQ "SEC.TRADE"
        
            REP.CUSTOMER.NO = ""
            CUSTOMER.NO = APPLICATION.REC<SC.SctTrading.SecTrade.SbsCustomerNo>
            CUST.NO.CNT = DCOUNT(CUSTOMER.NO, @VM)
            FOR CNT = 1 TO CUST.NO.CNT
                IF APPLICATION.REC<SC.SctTrading.SecTrade.SbsCustTransCode,CNT> EQ "SEL" THEN
                    REP.CUSTOMER.NO<-1> = APPLICATION.REC<SC.SctTrading.SecTrade.SbsCustomerNo,CNT>
                END
            NEXT CNT
        
            IF REP.CUSTOMER.NO THEN
                CONVERT @FM TO "*" IN REP.CUSTOMER.NO
                SEC.TRADE.TAX.TYPE = FIELD(APPLICATION.REC<SC.SctTrading.SecTrade.SbsWhtTaxCode>,'*',2) ;* SBS.WHT.TAX.CODE accepts valid TAX or TAX.TYPE record. When TAX.TYPE record is attached, this field value is prefixed with *
                REC.STATUS = APPLICATION.REC<SC.SctTrading.SecTrade.SbsRecordStatus>
            END
        
            SEC.TRADE.TAX.TYPE.OLD = FIELD(EB.SystemTables.getROld(SC.SctTrading.SecTrade.SbsWhtTaxCode),'*',2)
            IF (SEC.TRADE.TAX.TYPE AND SEC.TRADE.TAX.TYPE NE QI.RECALC.TAX.TYPE) AND (SEC.TRADE.TAX.TYPE.OLD AND SEC.TRADE.TAX.TYPE.OLD EQ QI.RECALC.TAX.TYPE) THEN
                SEC.TRADE.TAX.TYPE = SEC.TRADE.TAX.TYPE.OLD
                ACTION.TYPE = "REV"
            END
                
            IF SEC.TRADE.TAX.TYPE AND (SEC.TRADE.TAX.TYPE NE QI.RECALC.TAX.TYPE) THEN
                RETURN
            END
    
            PROCEED.FLAG = 1 ;* QI.RECALC.TAX.TYPE matches with SEC.TRADE.TAX.TYPE for SEC.TRADE Application
    
    END CASE

    IF NOT(ACTION.TYPE) THEN ;* Set the ACTION.TYPE as AUT, on authorisation of ENTIITLEMENT and SEC.TRADE applications
        ACTION.TYPE = MESSAGE
    END
    
    IF REC.STATUS[1,1] EQ "R" THEN ;* Set the ACTION.TYPE as REV, on Reversal authorisation of ENTIITLEMENT, SC.ADJ.TXN.UPDATE and SEC.TRADE applications
        ACTION.TYPE = "REV"
    END
    
RETURN

*** </region>

*-----------------------------------------------------------------------------

*** <region name= FORM.QCSI.TRIGGER>
FORM.QCSI.TRIGGER:
*** <desc> Form the ID and Record of F.QCSI.TRIGGER </desc>
                
    IF PROCEED.FLAG THEN
                
        QCSI.TRG.ID = "REP*":APPLICATION:"*":ACTION.TYPE:"*":APPLN.ID:"*":APPLN.COMPANY.ID
        IF REP.CUSTOMER.NO THEN
            QCSI.TRG.REC<1> = REP.CUSTOMER.NO
        END
        IF MAN.TAX.AMT NE '' THEN ;* Update Manual Flag only when Manual tax amount isnt Null and Txn Tax Type matches with QI Tax Type from QI.PARAMETER.
            LOCATE QI.TAX.TYPE IN SC.TAX.TYPE SETTING POS ELSE
                RETURN
            END
            QCSI.TRG.REC<2> = "MANUAL"
        END
    
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END




