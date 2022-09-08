* @ValidationCode : MjoxMjQzMDM4MzEzOmNwMTI1MjoxNTAxODYzMjMxMjQ5Om1vd3U6MTowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDcuMjAxNzA2MjMtMDAzNTo4Ojg=
* @ValidationInfo : Timestamp         : 04 Aug 2017 18:13:51
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : mowu
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 8/8 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201707.20170623-0035
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

  
$PACKAGE AA.Interest
SUBROUTINE AA.CUSTOM.RATE.METHOD( ARRANGEMENT.ID, CUR.PROP, EFFECTIVE.DATE, CURRENCY, CALC.PERIOD, INTEREST.RECORD, INT.DATA)
*----------------MULTI.CURRENCY.WEIGHTED.METHOD-------------------------------------------------------------
**** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
* This is a demo hook routine implemented for custom rate related feature.
* This routine just simple take the 1st MV from CUSTOM.VALUE field from INTEREST.RECORD, and ignore rest of the data.
*** </region>
*-----------------------------------------------------------------------------
* @access       : private
* @stereotype   : subroutine
* @author       : mowu@temenos.com
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Input
* @param    ARRANGEMENT.ID      Id of the Arrangement for which details are sought
* @param    CUR.PROP            The currenct property for calculating interest rate.
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
*
*
* 01/08/17 - Task : 2211477
*            Enhancement : 2165901
*            Multi-currency part 2, add simple defalt custom rate method
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc> </desc>

*** </region>
*-----------------------------------------------------------------------------

    $USING AA.Interest

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
    INT.DATA<2> = INTEREST.RECORD<AA.Interest.Interest.IntCustomValue, 1> ;* only take the first position of the MV as the rate
RETURN

END

