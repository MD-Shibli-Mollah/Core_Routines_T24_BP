* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-27</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.GET.PRODUCT.ID

*** <region name= Description>
*** <desc>Task of the sub-routine</desc>
* Program Description
*
* Product field in AA.ARRANGEMENT is a multi-valued field.
* Enquiries which need to display product id, can make use of this generic routine
* It requires ARRANGEMENT.ID in O.DATA and returns relevant Product id in the same variable

*-----------------------------------------------------------------------------
* @uses I_ENQUIRY.COMMON
* @package retaillending.AA
* @stereotype subroutine
* @link AA.GET.ARRANGEMENT.PRODUCT
* @author psankar@temenos.com
*-----------------------------------------------------------------------------
*** </region>

*-----------------------------------------------------------------------------

*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
* None
*
*
*** </region>

*-----------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History
*
* 28/06/07 - EN_10003400
*            Ref: SAR-2006-04-22-0001(Chg Product)
*            Generic method to get the product id for Enquiries
*
*** </region>

*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING AA.Framework
    $USING EB.SystemTables
    $USING EB.Reports

*** </region>

*** <region name= Main control>
*** <desc>main control logic in the sub-routine</desc>

    ARR.ID = EB.Reports.getOData() ;* Pick the arrangement id from enquiry variable
    EFF.DATE = EB.SystemTables.getToday() ;* The user is viewing the enquiry. It is relevant to show the current product as of today
    ARR.RECORD = '' ;* They would be read if not passed

    AA.Framework.GetArrangementProduct(ARR.ID, EFF.DATE, ARR.RECORD, PRODUCT.ID, PROPERTY.LIST)

    EB.Reports.setOData(PRODUCT.ID);* return the product id in the enquiry common

    RETURN
*** </region>
    END
