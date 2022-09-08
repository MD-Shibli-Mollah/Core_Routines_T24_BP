* @ValidationCode : Mjo4NTQ5NTY3NTk6Q3AxMjUyOjE1MzAzMDc1NTMzMjY6cHJha2FzaGdrczotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxODA3LjIwMTgwNTMxLTE4MDQ6LTE6LTE=
* @ValidationInfo : Timestamp         : 29 Jun 2018 23:25:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : prakashgks
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201807.20180531-1804
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-34</Rating>
*----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.MB.GET.PROPERTY.NAME(PRODUCT.RECORD, PROPERTY.CLASS, PROPERTY)

* This New routine has been introduced to replace this core routine AA.GET.PROPERTY.NAME(Not to use this core routine inside Enquiry)
*
* Given a Product record and Property class, this routine returns a list of Properties for that class
* IN  - PRODUCT.RECORD - Product definition record
*       PROPERTY.CLASS - Property class for which properties are sought
* OUT - PROPERTY - Returns a list of properties (seperated by FMs) for the given property class
*** </region>
*----------------------------------------------------------------------------------------
*** <region name= MODIFICATION HISTORY>
***
* Modification History :
*** </region>
*
*
* 29/06/18 - Task : 2655569
*            Defect : 2653256
*            Clear the common variable AaPropertyClassList before calling AA.GET.PROPERTY.CLASS. Else this will fetch values from previous sessions.
*            For enquiry purposes system should not rely on this variable.
*
*** <region name= Inserts>
***

    $USING AA.ProductManagement
    $USING AA.ProductFramework
    $USING AA.Framework

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main Process>
***

    GOSUB INITIALISE          ;* Initialise
    GOSUB GET.PROPERTY.NAME   ;* Get the property list
RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Initialise>
***
INITIALISE:

    PROP.LIST = RAISE(PRODUCT.RECORD<AA.ProductManagement.ProductDesigner.PrdProperty>)
    PROP.CLASS = ''
    PROP.LIST.IDX = ''
    PROP = ''
    PROPERTY = ''
    AA.Framework.setAaPropertyClassList("")  ;* For enquiries system should not rely on this variable. If not cleared this will be used in routine AA.GET.PROPERTY.CLASS.
RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Get the Property name>
***
GET.PROPERTY.NAME:

    LOOP
        READNEXT PROP FROM PROP.LIST SETTING PROP.LIST.IDX ELSE
            PROP.LIST.IDX = ''
        END
    UNTIL NOT(PROP)
        AA.ProductFramework.GetPropertyClass(PROP, PROP.CLASS)    ;* Find the class of this property
        IF PROP.CLASS EQ PROPERTY.CLASS THEN  ;* If the required and current classes are the same, append to the list
            PROPERTY<-1> = PROP
        END
    REPEAT
RETURN

*** </region>
*-----------------------------------------------------------------------------
END
