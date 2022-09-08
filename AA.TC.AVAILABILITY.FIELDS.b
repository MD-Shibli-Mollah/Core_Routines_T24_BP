* @ValidationCode : MjotNTA3ODE4MTczOkNwMTI1MjoxNTI4OTYxODczMDkxOmRtYXRlaTotMTotMTowOi0xOnRydWU6Ti9BOkRFVl8yMDE4MDYuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 14 Jun 2018 10:37:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : dmatei
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : true
* @ValidationInfo : Compiler Version  : DEV_201806.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE AO.Framework
SUBROUTINE AA.TC.AVAILABILITY.FIELDS(OUT.ASSOC, OUT.F, OUT.N, OUT.T, OUT.CHECKFILE, OUT.RULE.TYPE, OUT.MAND, OUT.ACTIVITY.LIST)
*-----------------------------------------------------------------------------
** Provides field definition for the TC.AVILABILITY property class
** This applies to both the product designer and the arrangement
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Modification History:
* 07/12/2016 - Enhancement 1825131/ Task 1825578
*              Avialability property class definition
* 09/01/2018 - Enhancement 2379129 / Task 238097 - SubArrangements validation
*
* 22/05/18 - Enhancement 2587968 / Task 2633901
*            TCUA - Extensions to Sub Arrangements - rebuild the external variables based on the flag from AA.ARRANGEMENT.EXTUSER table

*-----------------------------------------------------------------------------

**=========================================================================
    GOSUB INITIALISE
    GOSUB FIELD.DEFINITIONS

RETURN
*---------------------------------------------------------
*** <region name= Initialise>
INITIALISE:
*** <desc>All the initialisation goes here</desc>
*
    DAY.NAME = "DAY.OF.WEEK.LIST"
    CALL EB.LOOKUP.LIST(DAY.NAME)
    DAY.NAME = LOWER(DAY.NAME)

RETURN
*
*** </region>
*---------------------------------------------------------
*** <region name= FIELD DEF>
FIELD.DEFINITIONS:
***
*
    Z = 0

    Z+=1
    OUT.ASSOC<Z> = "XX<" ; OUT.F<Z> = "DAY.NAME" ; OUT.N<Z> = "11..C" ; OUT.T<Z> = DAY.NAME
    OUT.CHECKFILE<Z> = ""
    OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "" ; OUT.ACTIVITY.LIST<Z> = ""

    Z+=1
    OUT.ASSOC<Z> = "XX-" ; OUT.F<Z> = "DAY.SELECT" ; OUT.N<Z> = "11" ; OUT.T<Z,2> = "Yes_No"
    OUT.CHECKFILE<Z> = ""
    OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "" ; OUT.ACTIVITY.LIST<Z> = ""

    Z+=1
    OUT.ASSOC<Z> = "XX-XX<" ; OUT.F<Z> = "START.TIME" ; OUT.N<Z> = "005..C" ; OUT.T<Z,4> = "R##:##"; OUT.T<Z,5> = "C"
    OUT.CHECKFILE<Z> = ""
    OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "" ; OUT.ACTIVITY.LIST<Z> = ""

    Z+=1
    OUT.ASSOC<Z> = "XX>XX>" ; OUT.F<Z> = "END.TIME" ; OUT.N<Z> = "005..C" ; OUT.T<Z,4> = "R##:##"; OUT.T<Z,5> = "C"
    OUT.CHECKFILE<Z> = ""
    OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "" ; OUT.ACTIVITY.LIST<Z> = ""

    Z+=1
    OUT.ASSOC<Z> = "" ; OUT.F<Z> = "MASTER.LVL.CHANGE" ; OUT.N<Z> = "31" ; OUT.T<Z> = "A"
    OUT.CHECKFILE<Z> = ""
    OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "" ; OUT.ACTIVITY.LIST<Z> = ""

    Z+=1
    OUT.ASSOC<Z> = "" ; OUT.F<Z> = "RESERVED1" ; OUT.N<Z> = "30" ; OUT.T<Z> = "TIME" ; OUT.T<Z,3> = "NOINPUT"
    OUT.CHECKFILE<Z> = ""
    OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "" ; OUT.ACTIVITY.LIST<Z> = ""

RETURN
*
*-----------------------------------------------------------------------------
*** </region>
END

