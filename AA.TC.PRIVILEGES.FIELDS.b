* @ValidationCode : MjotNDY5MzkwNDM1OkNwMTI1MjoxNTI4OTYxODczMzcyOmRtYXRlaTotMTotMTowOi0xOnRydWU6Ti9BOkRFVl8yMDE4MDYuMDotMTotMQ==
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
SUBROUTINE AA.TC.PRIVILEGES.FIELDS(OUT.ASSOC, OUT.F, OUT.N, OUT.T, OUT.CHECKFILE, OUT.RULE.TYPE, OUT.MAND, OUT.ACTIVITY.LIST)
*-----------------------------------------------------------------------------
** Provides field definition for the TC.PRIVILEGES property class
** This applies to both the product designer and the arrangement
*-----------------------------------------------------------------------------
* Modification History:
*
* 03/10/16 - Enhancement 1812222 / Task 1905849
*            Tc Privileges property class

* 16/06/2017 - Defect 2012008 / Task 2184329
*              SERVICE.ACTIVE and OPERATION.ACTIVE values updated
* 09/01/2018 - Enhancement 2379129 / Task 238097 - SubArrangements validation
*
* 22/05/18 - Enhancement 2587968 / Task 2633901
*            TCUA - Extensions to Sub Arrangements - rebuild the external variables based on the flag from AA.ARRANGEMENT.EXTUSER table
*
*-----------------------------------------------------------------------------
*** <region name= INSERTS>
***
    $USING AA.Framework
    $USING ST.Customer
    $USING AA.ProductFramework
*** </region>
*---------------------------------------------------------
    GOSUB INITIALISE
    GOSUB FIELD.DEFINITIONS
*
RETURN
*---------------------------------------------------------
*** <region name= Initialise>
INITIALISE:
*** <desc>All the initialisation goes here</desc>
*
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
    OUT.ASSOC<Z> = "XX<" ; OUT.F<Z> = "SERVICE" ; OUT.N<Z> = "30" ; OUT.T<Z> = "A"
    OUT.CHECKFILE<Z> = "TC.SERVICES"
    OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "" ; OUT.ACTIVITY.LIST<Z> = ""

    Z+=1
    OUT.ASSOC<Z> = "XX-" ; OUT.F<Z> = "SERVICE.ACTIVE" ; ; OUT.N<Z> = "30" ; OUT.T<Z,2> = "_Yes"
    OUT.CHECKFILE<Z> = ""
    OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "" ; OUT.ACTIVITY.LIST<Z> = ""

    Z+=1
    OUT.ASSOC<Z> = "XX-XX<" ; OUT.F<Z> = "OPERATION" ; OUT.N<Z> = "35" ; OUT.T<Z> = "A"
    OUT.CHECKFILE<Z> = ""
    OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "" ; OUT.ACTIVITY.LIST<Z> = ""

    Z+=1
    OUT.ASSOC<Z> = "XX>XX>" ; OUT.F<Z> = "OPERATION.ACTIVE" ; OUT.N<Z> = "30" ; OUT.T<Z,2> = "_Yes"
    OUT.CHECKFILE<Z> = ""
    OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "" ; OUT.ACTIVITY.LIST<Z> = ""

    Z+=1
    OUT.ASSOC<Z> = "" ; OUT.F<Z> = "MASTER.LVL.CHANGE" ; OUT.N<Z> = "31" ; OUT.T<Z> = "A"

    Z+=1
    OUT.ASSOC<Z> = "" ; OUT.F<Z> = "RESERVED.9" ; OUT.N<Z> = "1" ; OUT.T<Z,3> = "NOINPUT"

    Z+=1
    OUT.ASSOC<Z> = "" ; OUT.F<Z> = "RESERVED.8" ; OUT.N<Z> = "1" ; OUT.T<Z,3> = "NOINPUT"

    Z+=1
    OUT.ASSOC<Z> = "" ; OUT.F<Z> = "RESERVED.7" ; OUT.N<Z> = "1" ; OUT.T<Z,3> = "NOINPUT"

    Z+=1
    OUT.ASSOC<Z> = "" ; OUT.F<Z> = "RESERVED.6" ; OUT.N<Z> = "1" ; OUT.T<Z,3> = "NOINPUT"

    Z+=1
    OUT.ASSOC<Z> = "" ; OUT.F<Z> = "RESERVED.5" ; OUT.N<Z> = "1" ; OUT.T<Z,3> = "NOINPUT"

    Z+=1
    OUT.ASSOC<Z> = "" ; OUT.F<Z> = "RESERVED.4" ; OUT.N<Z> = "1" ; OUT.T<Z,3> = "NOINPUT"

    Z+=1
    OUT.ASSOC<Z> = "" ; OUT.F<Z> = "RESERVED.3" ; OUT.N<Z> = "1" ; OUT.T<Z,3> = "NOINPUT"

    Z+=1
    OUT.ASSOC<Z> = "" ; OUT.F<Z> = "RESERVED.2" ; OUT.N<Z> = "1" ; OUT.T<Z,3> = "NOINPUT"

    Z+=1
    OUT.ASSOC<Z> = "" ; OUT.F<Z> = "RESERVED.1" ; OUT.N<Z> = "1" ; OUT.T<Z,3> = "NOINPUT"

RETURN
*
*-----------------------------------------------------------------------------
*** </region>
END
