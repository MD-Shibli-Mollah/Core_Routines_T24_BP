* @ValidationCode : MjoyNDk4NjQzOTQ6Q3AxMjUyOjE2MDQ4Mzc1MDMyODA6cmRlZXBpZ2E6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOS4yMDIwMDgyOC0xNjE3OjM2OjM2
* @ValidationInfo : Timestamp         : 08 Nov 2020 17:41:43
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 36/36 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.HEADER.DETAILS(LINE.DETAIL)
*------------------------------------------------------------------------------------------------------------------------------------
* Description
*************
*   This subroutine will return the header for the output file generated by dfe.
*   It will be attached in the header details field of
*   DFE parameter and it will be triggered from the routine DFE.OUTWARD.FILE.EXTRACT.POST.
*   In addition,the routine appends the time stamp value in the
*   output file name generated.
*
* Arguments:
************
* LINE.DETAIL = returns the header values.
*
*** </region>
*------------------------------------------------------------------------------------------------------------------------------------
*** <region name = Modification History>
*** <desc>Modification Summary</desc>
* Modification History:
*
* 22/10/2020 - SI - 3754772 / ENH - 3994136 / TASK - 3994144
*              TRS Reporting / Mapping Routines
*** </region>
*------------------------------------------------------------------------------------------------------------------------------------

    $USING EB.Utility
    $USING SC.SctTrading

    GOSUB INITIALISE          ;*Initialise
    GOSUB APPEND.TIME         ;*to append time of report generation with out file name
    GOSUB FORM.HEADER         ;*Form header

RETURN

*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>INITIALISE </desc>

    SYS.TIME=''
    REPORT.GENERATED.TIME=''
    EB.Utility.setCFileName(EB.Utility.getCRParameter()<EB.Utility.DfeParameter.DfeParamOutFileName>);*extract the outfile name defined in dfe parameter.
    SYS.TIME= TIMEDATE()

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= APPEND.TIME>
APPEND.TIME:
*** <desc>Append time stamp with out file name </desc>

    HOUR =FIELD(SYS.TIME,':',1)
    MINUTE =FIELD(SYS.TIME,':',2)
    SECOND =FIELDS(SYS.TIME,':',3,2)
    SECOND =SECOND[1,2]


    REPORT.GENERATED.TIME = HOUR:'_':MINUTE:'_':SECOND   ;*form the timestamp with hour,minute and second separated by underscore.


    EB.Utility.setCFileName(EB.Utility.getCFileName() :'-':REPORT.GENERATED.TIME:'.csv');*append the timestamp value with the outfile name

    tmp.C$FILE.NAME = EB.Utility.getCFileName()
    IF INDEX(tmp.C$FILE.NAME,'!',1) THEN
        EB.Utility.setCFileName(tmp.C$FILE.NAME)
        tmp.C$FILE.NAME = EB.Utility.getCFileName()
        EB.Utility.DfeRetrieveCommonValues(tmp.C$FILE.NAME) ;*common variables defined in out file name will be replaced by their respective values.
        EB.Utility.setCFileName(tmp.C$FILE.NAME)
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= FORM.HEADER>
FORM.HEADER:
*** <desc>To form header.Header will be in line with the order of fields defined in mapping record. </desc>

    LINE.DETAIL =  "ORIGINATE.SYSTEM,FI,REPORT.SET,REPORT.DATE,K.PLUS.DEAL.ID,GATOS.DEAL.ID,PMDSN,PRODUCT,PRODUCT.TYPE,SUBMISSION.ID,RECORD.ID,REPORT.STATUS,"
    LINE.DETAIL := "TRANSACTION.REF.ID,TRADE.ID.INDICATOR,TRADING.VENUE.TXN.ID,EXECUTING.ENTITY.ID.CODE,INVESTMENT.FIRM.INDICATOR,SUBMITTING.ENTITY.ID,BUYER.ID.TYPE,"
    LINE.DETAIL := "BUYER.ID,BUYER.BRANCH.COUNTRY,BUYER.FIRST.NAME,BUYER.LAST.NAME,BUYER.DOB,BUYER.DECISION.MKR.TYPE,BUYER.DECISION.MKR.CODE,BUYER.DECISION.MKR.FIRST.NAME,"
    LINE.DETAIL := "BUYER.DECISION.MKR.LAST.NAME,BUYER.DECISION.MKR.DOB,SELLER.ID.TYPE,SELLER.ID,SELLER.BRANCH.COUNTRY,SELLER.FIRST.NAME,SELLER.LAST.NAME,SELLER.DOB,"
    LINE.DETAIL := "SELLER.DECISION.MKR.TYPE,SELLER.DECISION.MKR.CODE,SELLER.DECISION.MKR.FIRST.NAME,SELLER.DECISION.MKR.LAST.NAME,SELLER.DECISION.MKR.DOB,"
    LINE.DETAIL := "TRANSM.ORDER.INDICATOR,TRANSM.FIRM.CODE.BUYER,TRANSM.FIRM.CODE.SELLER,TRADING.DATE.TIME,SIDE,TRADING.CAPACITY,QTY.NOTATION,QUANTITY,QTY.CURRENCY,"
    LINE.DETAIL := "DERVATIVE.NOTIONAL.INCR.DECR,PRICE.NOTATION,PRICE,PRICE.CURRENCY,NET.AMOUNT,VENUE,COUNTRY.OF.BRANCH.MEMBERSHIP,UPFRONT.PAYMENT,UPFRONT.PAYMENT.CCY,"
    LINE.DETAIL := "COMPLEX.TRADE.COMPONENT.ID,INSTRUMENT.ID.TYPE,INSTRUMENT.ID,INSTRUMENT.FULL.NAME,INSTRUMENT.CLASSIFICATION,NOTIONAL.CCY.1,NOTIONAL.CCY.2,PRICE.MULTIPLIER,"
    LINE.DETAIL := "UNDERLYING.INSTRUMENT.CODE,UNDERLYING.INDEX.NAME,TERM.OF.UNDERLYING.INDEX,OPTION.TYPE,STRIKE.PRICE,STRIKE.PRICE.CCY,STRIKE.PRICE.NOTATION,OPTION.EXERCISE.STYLE,"
    LINE.DETAIL := "MATURITY.DATE,EXPIRY.DATE,DELIVERY.TYPE,INV.DECISION.WITHIN.FIRM.TYPE,INV.DECISION.WITHIN.FIRM,CTRY.INV.DECISION.MKR.BRANCH,EXECUTION.WITHIN.FIRM.TYPE,"
    LINE.DETAIL := "EXECUTION.WITHIN.FIRM,CTRY.EXEC.SUPERVISOR.BRANCH,WAIVER.INDICATOR,SHORT.SELLING.INDICATOR,OTC.POST.TRADE.INDICATOR,COMMODITY.DERIVATIVE.INDICATOR,"
    LINE.DETAIL := "SEC.FINANCING.TXN.INDICATOR,BUSINESS.UNIT,FREE.TEXT.1,FREE.TEXT.2,ROUTING.INSTRUCTIONS,DATE.AND.TIME"

RETURN
*** </region>

END
