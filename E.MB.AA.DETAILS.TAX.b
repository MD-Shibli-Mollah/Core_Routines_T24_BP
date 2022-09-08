* @ValidationCode : MjotMTA1Mjk3ODcxNzpDcDEyNTI6MTUxODQ1MjQ5OTM2MTptZ2hhc2Fyb3V5ZToyMTowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE4MDIuMjAxODAxMjItMTM1Nzo0Nzo0Nw==
* @ValidationInfo : Timestamp         : 12 Feb 2018 17:21:39
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mghasarouye
* @ValidationInfo : Nb tests success  : 21
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 47/47 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201802.20180122-1357
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
* Subroutine Type : Subroutine

* Incoming        : O.DATA

* Outgoing        : O.DATA Common Variable

* Attached to     : AA.ARR.TAX

* Attached as     : Conversion Routine

* Primary Purpose : It must find out if netting and/or consolidation is active.

* Incoming        : Conversion routine will be applied on AA.ARR.TAX file, so the id and record is from this file.Input will be either PROPERTY or PROPERTY.CLASS

* Change History  :

* Version         : First Version


************************************************************

*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Changes done in the sub-routine</desc>
* Modification History
*
* 01/22/18 - Enhancement : 2388930
*            Task        : 2388933
*            New Conversion routine
*
*-----------------------------------------------------------------------------

$PACKAGE AA.ModelBank
SUBROUTINE E.MB.AA.DETAILS.TAX

*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING AA.ProductFramework
    $USING AA.Tax
    $USING EB.Reports
    $USING EB.SystemTables
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>
    GOSUB Init ; *To initialise variables
    IF InputValue THEN;* If no input value, just exit the routine
        GOSUB Process ; *Main Processing
    END
    EB.Reports.setOData(Result);*setting result
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Init>
*** <desc>To initialise variables </desc>
Init:
    
    Result = "Error"
    InputValue = EB.Reports.getOData()
    ConsolidationActive = ""
    R.Tax = EB.Reports.getRRecord()
    NettingActive = R.Tax<AA.Tax.Tax.TaxNetTax> EQ 'YES'
    PropNetTax = R.Tax<AA.Tax.Tax.TaxPropNetTax>
    ArrangementId = FIELD(EB.Reports.getId(),'-',1) ;* Extract arrangement id

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= process>
*** <desc>Main Processing </desc>
Process:

    IF InputValue MATCHES "INTEREST":@VM:"CHARGE" THEN;* If no incoming property but only property class
        GOSUB CheckPropertyClass
    END ELSE
        LOCATE InputValue IN PropNetTax<1,1> SETTING Pos ELSE ;* Now check if the incoming property is selected for netting in MV field
            NettingActive = "";* If not, set netting as not active
        END
    END
    
    AA.Framework.GetArrangement(ArrangementId, R.Arrangement, RetError)
    IF R.Arrangement<AA.Framework.Arrangement.ArrStartDate> GT EB.SystemTables.getToday() THEN
        EffectiveDate = R.Arrangement<AA.Framework.Arrangement.ArrStartDate>
    END ELSE
        EffectiveDate = EB.SystemTables.getToday()
    END
    AA.Framework.GetArrangementConditions( ArrangementId, 'PAYMENT.SCHEDULE', '', EffectiveDate, '', R.PaymentSchedule, ReturnError) ;* Load PS record

    R.PaymentSchedule = RAISE(R.PaymentSchedule) ;* Raise it

    ConsolidationActive = R.PaymentSchedule<AA.PaymentSchedule.PaymentSchedule.PsConsolidateClass,1> NE ''

    GOSUB SetResult
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= CheckPropertyClass>
*** <desc>Check Property Class of prop next tax to see whether they are the same as InputValue or not</desc>
CheckPropertyClass:

    
    NettingActive = "";*deactivate NettingActive flag
    AA.ProductFramework.GetPropertyClass(PropNetTax, PropertyClasses);*Get the property class of all properties selected for netting
    LOCATE InputValue  IN PropertyClasses SETTING PropertyClassPos THEN
        NettingActive = 1;*set netting as active.
    END

   
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= SetResult>
*** <desc>SetResult </desc>
SetResult:


    BEGIN CASE
        CASE NOT(NettingActive);* blank no netting, no consolidation ;* blank no netting, consolidation
            Result = ""
        CASE NettingActive AND NOT(ConsolidationActive);* N      netting, no consolidation
            Result = "N"
        CASE NettingActive AND  ConsolidationActive     ;* NC    netting, consolidation
            Result = "NC"
    END CASE

RETURN
*** </region>

*-----------------------------------------------------------------------------

END

