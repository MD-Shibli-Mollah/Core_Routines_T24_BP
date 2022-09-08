* @ValidationCode : MjoxODQzNjI0MDA3OkNwMTI1MjoxNTI3ODMyMTEyNDY3OnN2aWthc2g6MTowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE4MDUuMjAxODA0MTgtMTM1NTo4Ojg=
* @ValidationInfo : Timestamp         : 01 Jun 2018 11:18:32
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : svikash
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 8/8 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201805.20180418-1355
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


  
$PACKAGE AA.Interest
SUBROUTINE AA.CUSTOM.RATE.NULL(ARRANGEMENT.ID, CUR.PROP, EFFECTIVE.DATE, CURRENCY, CALC.PERIOD, INTEREST.RECORD, INT.DATA)
*-----------------------------------------------------------------------------
**** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
* This is a demo hook routine implemented for custom rate related feature.
* This routine is implemented so that validation of null interest rate is covered in AA.BUILD.INTEREST.INFO
* This routine just returns null value for Effective Interest Rate.
*** </region>
*-----------------------------------------------------------------------------
* @access       : private
* @stereotype   : subroutine
* @author       : svikash@temenos.com
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Input
* @param    ARRANGEMENT.ID      Id of the Arrangement for which details are sought
* @param    CUR.PROP            The current property for calculating interest rate.
* @param    EffectiveDate       The date on which the activity is run
* @param    Currency            Currency of the arrangement Id
* @param    CalcPeriod          Record Start Date, Start Date of the period and End date of the period for which the rate is requested
* @param    InterestRecord      The interest record for the date will be passed and any information recorded there could be used.
*                               The custom details and values is normally expected to store details useful for the calculation and sometimes it could even be stored in some Local ref

* Output
*
* @param    IntData             Returns the interest related information
*                               <1> contains effective dates on which rate revision has happened till this date in descending order
*                               <2> contains the effective rates as on each of these dates.
*
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History
* 31/05/18 - Task: 2612967
*            Defect : 2574680
*            This routine is implemented so that validation of null interest rate is covered in AA.BUILD.INTEREST.INFO
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc> </desc>
    $USING AA.Interest
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main control>
*** <desc>main control logic in the sub-routine</desc>

    GOSUB INITIALISE
   
    GOSUB MAIN.PROCESS

RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>File variables and local variables</desc>
INITIALISE:
    INT.DATA = ''
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main process>
*** <desc>main processing block in the sub-routine</desc>
MAIN.PROCESS:
    
    INT.DATA<1> = CALC.PERIOD<1,1> ;* set start date of the rate
    INT.DATA<2> = '' ;* Null Rate is returned
RETURN

END

