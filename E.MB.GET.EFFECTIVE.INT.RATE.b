* @ValidationCode : MjotODMzNTAwNDY2OkNwMTI1MjoxNTQ5MjYyNzEyMzE1OnByYWthc2hna3M6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwMi4yMDE5MDExNy0wMzQ3OjE5OjE5
* @ValidationInfo : Timestamp         : 04 Feb 2019 12:15:12
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : prakashgks
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 19/19 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201902.20190117-0347
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-35</Rating>
*-----------------------------------------------------------------------------
* A new routine has been introduced to Show the effective interest rate in Overview screen.
* This new routine is called from an existing enquiry (DEPOSITS.DETAILS.SCV)
*------------------------------------------------------------------------------
$PACKAGE AD.ModelBank
SUBROUTINE E.MB.GET.EFFECTIVE.INT.RATE

*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Changes done in the routine </desc>
* 10/01/2014  - Defect : 881518
*               Task   : 885485
*               A new routine has been introduced to Show the effective interest rate in Overview screen.
*
* 04/02/2019  - Defect : 2969871
*               Task   : 2973863
*               Show AUTH values even when there is any activity in INAU.
*
*-----------------------------------------------------------------------------

    $USING AA.Interest
    $USING AA.ProductFramework
    $USING AA.Framework
    $USING EB.SystemTables
    $USING EB.Reports


    GOSUB INIT
    GOSUB GET.ID
    GOSUB PROCESS

RETURN

*------------------------------------------------------------------------------
INIT:
*------------------------------------------------------------------------------

    ARR.ID = ''
    ARR.ID = EB.Reports.getOData()
    effectiveDate = EB.SystemTables.getToday()
    idArrangementComp = FIELD(ARR.ID,"-",1)
    idProperty = FIELD(ARR.ID,"-",2)

RETURN

*------------------------------------------------------------------------------
GET.ID:
*------------------------------------------------------------------------------

    AA.ProductFramework.GetPropertyClass(idProperty,idPropertyClass)
    idArrangementComp<3> = "AUTH"  ;* Get only AUTH values to display in enquiry
    CONVERT @FM TO "/" IN idArrangementComp  ;* In GetArrangementConditions "/" is used as seperator for idArrangementComp
    AA.Framework.GetArrangementConditions(idArrangementComp,idPropertyClass, idProperty, effectiveDate, returnIds, returnConditions,returnError)
    returnConditions = RAISE(returnConditions)

RETURN

*------------------------------------------------------------------------------
PROCESS:
*------------------------------------------------------------------------------

    EFFECTIVE.RATE = returnConditions<AA.Interest.Interest.IntEffectiveRate>

    EB.Reports.setOData(EFFECTIVE.RATE)

RETURN
END
