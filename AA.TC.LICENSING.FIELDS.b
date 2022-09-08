* @ValidationCode : MjotOTA2OTkzNTA5OkNwMTI1MjoxNTM3NjM0ODg0MTcwOnJ0YW5hc2U6LTE6LTE6MDotMTp0cnVlOk4vQTpERVZfMjAxODEwLjIwMTgwOTE4LTExMTU6LTE6LTE=
* @ValidationInfo : Timestamp         : 22 Sep 2018 19:48:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rtanase
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : true
* @ValidationInfo : Compiler Version  : DEV_201810.20180918-1115
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AO.Framework
SUBROUTINE AA.TC.LICENSING.FIELDS(OUT.ASSOC, OUT.F, OUT.N, OUT.T, OUT.CHECKFILE, OUT.RULE.TYPE, OUT.MAND, OUT.ACTIVITY.LIST)
*-----------------------------------------------------------------------------
** Provides field definition for the TC.LICENSING property class
** This applies to both the product designer and the arrangement
*-----------------------------------------------------------------------------
* Modification History:
*
* 27/07/2018 - Enhancement 2669405 / Task 2779868
*              TCUA : TC Licensing - User and Role Licensing for Master Arrangements
*
*-----------------------------------------------------------------------------
*** <region name= INSERTS>
***
    $USING AO.Framework
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main control>
*** <desc>main control logic in the sub-routine</desc>
*
    GOSUB INITIALISE
    GOSUB FIELD.DEFINITIONS
*
RETURN
*** </region>
*------------------------------------------------------------------------------
*** <region name= Initialise required variables>
INITIALISE:
*
RETURN
*** </region>
*----------------------------------------------------------------------------------
*** <region name= FIELD DEF>
FIELD.DEFINITIONS:

    Z = 0

    Z+=1
    OUT.ASSOC<Z> = "" ; OUT.F<Z> = "NO.OF.USERS" ; OUT.N<Z> = "4" ; OUT.T<Z> = "" ; OUT.T<Z,2> = "1...9999"
    OUT.CHECKFILE<Z> = "" ; OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "" ; OUT.ACTIVITY.LIST<Z> = ""
       
    Z+=1
    OUT.ASSOC<Z> = "" ; OUT.F<Z> = "NO.OF.ROLES" ; OUT.N<Z> = "4" ; OUT.T<Z> = "" ; OUT.T<Z,2> = "0...9999"
    OUT.CHECKFILE<Z> = "" ; OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "" ; OUT.ACTIVITY.LIST<Z> = ""

    Z+=1
    OUT.ASSOC<Z> = "" ; OUT.F<Z> = "RESERVED.10" ; OUT.N<Z> = "1" ; OUT.T<Z,3> = "NOINPUT"
    OUT.CHECKFILE<Z> = "" ; OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "" ; OUT.ACTIVITY.LIST<Z> = ""

    Z+=1
    OUT.ASSOC<Z> = "" ; OUT.F<Z> = "RESERVED.9" ; OUT.N<Z> = "1" ; OUT.T<Z,3> = "NOINPUT"
    OUT.CHECKFILE<Z> = "" ; OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "" ; OUT.ACTIVITY.LIST<Z> = ""

    Z+=1
    OUT.ASSOC<Z> = "" ; OUT.F<Z> = "RESERVED.8" ; OUT.N<Z> = "1" ; OUT.T<Z,3> = "NOINPUT"
    OUT.CHECKFILE<Z> = "" ; OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "" ; OUT.ACTIVITY.LIST<Z> = ""

    Z+=1
    OUT.ASSOC<Z> = "" ; OUT.F<Z> = "RESERVED.7" ; OUT.N<Z> = "1" ; OUT.T<Z,3> = "NOINPUT"
    OUT.CHECKFILE<Z> = "" ; OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "" ; OUT.ACTIVITY.LIST<Z> = ""

    Z+=1
    OUT.ASSOC<Z> = "" ; OUT.F<Z> = "RESERVED.6" ; OUT.N<Z> = "1" ; OUT.T<Z,3> = "NOINPUT"
    OUT.CHECKFILE<Z> = "" ; OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "" ; OUT.ACTIVITY.LIST<Z> = ""

    Z+=1
    OUT.ASSOC<Z> = "" ; OUT.F<Z> = "RESERVED.5" ; OUT.N<Z> = "1" ; OUT.T<Z,3> = "NOINPUT"
    OUT.CHECKFILE<Z> = "" ; OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "" ; OUT.ACTIVITY.LIST<Z> = ""

    Z+=1
    OUT.ASSOC<Z> = "" ; OUT.F<Z> = "RESERVED.4" ; OUT.N<Z> = "1" ; OUT.T<Z,3> = "NOINPUT"
    OUT.CHECKFILE<Z> = "" ; OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "" ; OUT.ACTIVITY.LIST<Z> = ""

    Z+=1
    OUT.ASSOC<Z> = "" ; OUT.F<Z> = "RESERVED.3" ; OUT.N<Z> = "1" ; OUT.T<Z,3> = "NOINPUT"
    OUT.CHECKFILE<Z> = "" ; OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "" ; OUT.ACTIVITY.LIST<Z> = ""

    Z+=1
    OUT.ASSOC<Z> = "" ; OUT.F<Z> = "RESERVED.2" ; OUT.N<Z> = "1" ; OUT.T<Z,3> = "NOINPUT"
    OUT.CHECKFILE<Z> = "" ; OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "" ; OUT.ACTIVITY.LIST<Z> = ""

    Z+=1
    OUT.ASSOC<Z> = "" ; OUT.F<Z> = "RESERVED.1" ; OUT.N<Z> = "1" ; OUT.T<Z,3> = "NOINPUT"
    OUT.CHECKFILE<Z> = "" ; OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "" ; OUT.ACTIVITY.LIST<Z> = ""
*
RETURN
*** </region>
*-----------------------------------------------------------------------------

END

