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
* <Rating>-60</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.HEADER.DETAILS.DELEGATED(LINE.DETAIL)

*------------------------------------------------------------------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Task of the sub-routine</desc>
* Program Description
*
*   This subroutine will return the header for the output file generated.
*
*
*** </region>
*------------------------------------------------------------------------------------------------------------------------------------

*** <region name= Arguments>
*
* RET.VAL = returns the header values.
*
*** </region>
*------------------------------------------------------------------------------------------------------------------------------------
*** <region name = Modification History>
*** <desc>Modification Summary</desc>
* Modification History:
*
*13/07/15 - Enhancement 1177306 / Task 1252426
*           Creation of Routine (DFE configuration)
*
* 21/09/15 - Enhancement 1461371 / Task 1461382
*            OTC Collateral and Valuation Reporting.
*
* 30/12/15 - EN_1226121 / Task 1568411
*			 Incorporation of the routine
*** </region>
*------------------------------------------------------------------------------------------------------------------------------------

    $USING EB.Utility
    $USING OC.Reporting


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


    IF EB.Utility.getCRMapping()<EB.Utility.DfeMapping.DfeMapFileName> EQ 'OC.VAL.COLL.DATA' THEN
        LINE.DETAIL = "TXN.ID,COMPANY,REPORTING.MODEL,ACTION.TYPE,MTM.VALUE.OF.CONTRACT,MTM.CURRENCY,VALUATION.DATE,VALUATION.TIME,VALUATION.TYPE,COLLATERALIZATION,COLLATERAL.PORT.IND,COLLATERAL.PORT.CODE,COLLATERAL.VALUE,COLLATERAL.CCY"
    END ELSE
        LINE.DETAIL ="DATE.AND.TIME,TRANSACTION.ID,COMPANY,REPORTING.MODEL,TRADE.REPOSITORY,BROKER.PREFIX,CPARTY.ID,CPARTY2.PREFIX,REPORTING.ENTITY,CP.TRADE.PURPOSE,COLLATERISATION,COLLAT.PORT.CODE,NOTIONAL.CCY,DELIVERY.CCY,UNIQUE.TRAN.ID,PRE.UTI.ID.1,PRE.UTI.ID.2,EXEC.VENUE,PORT.COMPRESSION,PRICE.RATE,NOTIONAL.AMOUNT1,EXEC.TIME.STAMP,EFFECTIVE.DATE,MATURITY.DATE,SETTLEMENT.DATE,AGREEMENT.TYPE,LEG1.FIXED.RATE,EXCHANGE.RATE1,FORWARD.EXCH.RATE,ACTION.TYPE,ACTION.TYPE.DETAILS"
    END

    RETURN
*** </region>

    END
