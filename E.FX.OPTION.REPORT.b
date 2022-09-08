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
* <Rating>-32</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FX.ModelBank
    SUBROUTINE E.FX.OPTION.REPORT(ENQ)

* Build routine for the Enquiry - E.FX.OPTION.OS.REPORT
* For FX Multi-Rate
*
************************************
*
* 21/03/07 - EN_10003186
*            New Routine
*
* 08/08/07 - BG_100014861
*            When the field OPT.OS.RP.DAYS is null then the default number
*            of days for generating the report is 1 day prior to value date.
*
* 15/09/15 - EN_1226121 / Task 1477143
*	      	 Routine incorporated
*
************************************

    $USING FX.Config
    $USING EB.API
    $USING EB.SystemTables
    $USING FX.ModelBank



    GOSUB GET.REPORT.DAYS

    GOSUB SET.ENQ.CONDITION

    RETURN

*-----------------------------------------------------------------------------

*** <region name= GET.REPORT.DAYS>
GET.REPORT.DAYS:
*** <desc>Gets the number of days from FX.PARAMETERS to produce the report</desc>


    FX.PARAMETERS.ID = 'FX.PARAMETERS'

    R.FX.PARAMETERS = ''
    YERR = ''
    R.FX.PARAMETERS = FX.Config.Parameters.Read(FX.PARAMETERS.ID, YERR)
    REPORT.DAYS = R.FX.PARAMETERS<FX.Config.Parameters.POptOsRpDays>

    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= SET.ENQ.CONDITION>
SET.ENQ.CONDITION:
*** <desc>Sets the variable ENQ based on FX.PARAMETERS field OPT.OS.RP.DAYS</desc>
    IF NOT(REPORT.DAYS) THEN
        * Default displacement is as of that day. If nothing is mentioned in FX.PARAMETERS
        REPORT.DAYS = 1
    END

    VDATE = EB.SystemTables.getToday()
    DISP = "+":REPORT.DAYS:"W"
    EB.API.Cdt('',VDATE,DISP)

    ENQ<2,1> = 'VALUE.DATE.BUY'
    ENQ<3,1> = 'LE'
    ENQ<4,1> = VDATE

    RETURN
*** </region>
    END
