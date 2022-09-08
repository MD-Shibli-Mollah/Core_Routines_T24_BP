* @ValidationCode : MjotMTgzMjIyMjQyNzpDcDEyNTI6MTUyODk2MTg3MzE1NDpkbWF0ZWk6LTE6LTE6MDotMTp0cnVlOk4vQTpERVZfMjAxODA2LjA6LTE6LTE=
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

*-----------------------------------------------------------------------------
$PACKAGE AO.Framework
SUBROUTINE AA.TC.PERMISSIONS.FIELDS(OUT.ASSOC, OUT.F, OUT.N, OUT.T, OUT.CHECKFILE, OUT.RULE.TYPE, OUT.MAND, OUT.ACTIVITY.LIST)
*-----------------------------------------------------------------------------
** Provides field definition for the TC.PERMISSIONS property class
** This applies to both the product designer and the arrangement
*-----------------------------------------------------------------------------
* Modification History:
*
* 03/10/16 - Enhancement 1812222 / Task 1905849
*            Tc Permissions property class
*
* 25/01/18 - Enhancement 2379129 / Task 2433777
*            Master Update validations for Protection Limit and Permissions
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
    $USING AO.Framework

    GOSUB INITIALISE
    GOSUB FIELD.DEFINITIONS

RETURN
*------------------------------------------------------------------------------
INITIALISE:
* Initialise required variables
*
RETURN
*----------------------------------------------------------------------------------
FIELD.DEFINITIONS:

    Z = 0

    Z+=1
    OUT.ASSOC<Z> = "XX<" ; OUT.F<Z> = "DEFINED.CUSTOMERS" ; OUT.N<Z> = "30" ; OUT.T<Z> = "CUS"
    OUT.CHECKFILE<Z> = "CUSTOMER":@VM:ST.Customer.Customer.EbCusShortName
    OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "A" ; OUT.ACTIVITY.LIST<Z> = ""

    Z+=1
    OUT.ASSOC<Z> = "XX-XX." ; OUT.F<Z> = "DEFINED.COMPANY" ; OUT.N<Z> = "30" ; OUT.T<Z> = "A"
   
    Z+=1
    OUT.ASSOC<Z> = "XX>" ; OUT.F<Z> = "DEFINED.CUSTOMERS.SEL" ; OUT.N<Z> = "10" ; OUT.T<Z,2> = "No_Yes"


    Z+=1
    OUT.ASSOC<Z> = "XX<" ; OUT.F<Z> = "DEFINED.PRODUCT.GROUPS" ; OUT.N<Z> = "31" ; OUT.T<Z> = "A"
    OUT.CHECKFILE<Z> = "AA.PRODUCT.GROUP":@VM:AA.ProductFramework.ProductGroup.PgDescription
    OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "" ; OUT.ACTIVITY.LIST<Z> = ""

    Z+=1
    OUT.ASSOC<Z> = "XX>" ; OUT.F<Z> = "DEFINED.PRODUCT.GROUP.SEL" ; OUT.N<Z> = "10" ; OUT.T<Z,2> = "See_Transact_Exclude"

    Z+=1
    OUT.ASSOC<Z> = "XX<" ; OUT.F<Z> = "REL.CUSTOMER" ; OUT.N<Z> = "10..C" ; OUT.T<Z> = "CUS"
    OUT.CHECKFILE<Z> = "CUSTOMER":@VM:ST.Customer.Customer.EbCusShortName
    OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "A" ; OUT.ACTIVITY.LIST<Z> = ""

    Z+=1
    OUT.ASSOC<Z> = "XX-" ; OUT.F<Z> = "PRODUCT.GROUPS" ; OUT.N<Z> = "30" ; OUT.T<Z> = "A"
    OUT.CHECKFILE<Z> = "AA.PRODUCT.GROUP":@VM:AA.ProductFramework.ProductGroup.PgDescription
    OUT.RULE.TYPE<Z> = "" ; OUT.MAND<Z> = "" ; OUT.ACTIVITY.LIST<Z> = ""

    Z+=1
    OUT.ASSOC<Z> = "XX-" ; OUT.F<Z> = "PRODUCT.GROUP.SEL" ; OUT.N<Z> = "10" ; OUT.T<Z,2> = "See_Transact_Exclude"

    Z+=1
    OUT.ASSOC<Z> = "XX-XX<" ; OUT.F<Z> = "PRODUCT" ; OUT.N<Z> = "35" ; OUT.T<Z> = "A"

    Z+=1
    OUT.ASSOC<Z> = "XX>XX>" ; OUT.F<Z> = "PRODUCT.SEL" ; OUT.N<Z> = "10" ; OUT.T<Z,2> = "Auto_See_Transact_Exclude"

    Z+=1
    OUT.ASSOC<Z> = "" ; OUT.F<Z> = "MASTER.LVL.CHANGE" ; OUT.N<Z> = "30" ; OUT.T<Z> = "A"

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
*
RETURN
*
*-----------------------------------------------------------------------------
*** </region>
END

