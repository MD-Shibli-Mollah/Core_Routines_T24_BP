* @ValidationCode : MjotNTk4NTQ2NjQ3OkNwMTI1MjoxNTc4NDczNTk2Mjc5Om1hbmlzZWthcmFua2FyOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMS4yMDE5MTIxMy0wNTQwOi0xOi0x
* @ValidationInfo : Timestamp         : 08 Jan 2020 14:23:16
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : manisekarankar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202001.20191213-0540
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE LI.ModelBank
SUBROUTINE E.SUB.LIMIT.DETAILS
*-----------------------------------------------------------------------------
* E.SUB.LIMIT.DETAILS is an conversion routine which is used to get restriction limit details.
*
* This routine will inturn call conversion routine E.RESTRICTION.LIMITS and manupulate
* Context name details inorder to display as required in IRIS response.
*
*-----------------------------------------------------------------------------
* Company Name   : TEMENOS
* Developed By   : manisekarankar@temenos.com
* Program Name   : E.SUB.LIMIT.DETAILS
* Module Name    : LI
* Component Name : LI_ModelBank
*-----------------------------------------------------------------------------------------------------------
* Modification History :
*
* 08/01/2010 - Enhancement 3512771 / Task 3526381
*              Conversion routine attached to API enquiry.
*
*-----------------------------------------------------------------------------------------------------------
*** <region name= Inserts>
    $USING LI.ModelBank
    $USING EB.Reports
*** </region>
*-----------------------------------------------------------------------------

    GOSUB initialise
    GOSUB process

RETURN
*-----------------------------------------------------------------------------
initialise:
**********
    R.Record = ''
    ContextName = ''
    ContextValue = ''
    ContextValueCount = ''
    ContValIndex = ''

RETURN
*-----------------------------------------------------------------------------
process:
*******

* Call this routine so that R.RECORD is being set with the required values.
    LI.ModelBank.eRestrictionLimit()
    R.Record = EB.Reports.getRRecord()
    ContextName = R.Record<2>
    ContextValue = R.Record<3>
* The Context Name is Multi valued array & Context Value is sub valued array
* Example:
* ContextName       ContextValue
* ***********       ************
* PRODUCT.LINE      CUSTOMER.LOAN
*                   HOME.LOAN
* CURRENCY          USD
*                   CCY
* CUSTOMER          190037
*
* Inorder to display the above in understandable format in IRIS response, the array must be made like below:
* Example:
* ContextName       ContextValue
* ***********       ************
* PRODUCT.LINE       CUSTOMER.LOAN
* PRODUCT.LINE       HOME.LINE
* CURRENCY           USD
* CURRENCY           CCY
* CUSTOMER           190037
    
    ContextValue = RAISE(ContextValue)
    ContextValueCount = DCOUNT(ContextValue,@VM)
    ContextName = RAISE(ContextName)
    
    FOR ContValIndex = 1 TO ContextValueCount
        ContextNameValue = ContextName<ContValIndex>
        ContextMultiValues = ''
        ContextMultiValueCount = ''
        ContextMutliValues = ContextValue<ContValIndex>
        GOSUB FormContextName
    NEXT ContValIndex
    
* Assign R.RECORD with the modified ContextName Value
    R.Record<2> = LOWER(ContextName)
    EB.Reports.setRRecord(R.Record)
RETURN
*-----------------------------------------------------------------------------
FormContextName:
****************
    ContextMultiValueCount = DCOUNT(ContextMutliValues,@VM)
    IF ContextMultiValueCount EQ 1 THEN
        RETURN
    END
    
    FOR ContMvIndex = 1 TO ContextMultiValueCount
        ContextName<ContValIndex,ContMvIndex> = ContextNameValue       
    NEXT ContMvIndex

RETURN
*-----------------------------------------------------------------------------
END



