* @ValidationCode : MTo1ODAyMDgyOlVURi04OjE0Njk2MjUzMDM3MzQ6a2FuYW5kOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTYwNy4x
* @ValidationInfo : Timestamp         : 27 Jul 2016 18:45:03
* @ValidationInfo : Encoding          : UTF-8
* @ValidationInfo : User Name         : kanand
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201607.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE DD.Channels
    SUBROUTINE E.TC.CONV.GET.NEW.DD.ITEM
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
*
* To set the next payment date for the DD Item record.
*
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Conversion
* Attached To        : Enquiry > TC.DIRECT.DEBITS as a Conversion routine for ID
* IN Parameters      : O.DATA
* Out Parameters     : O.DATA
*
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 27/05/2016  - Enhancement 1694534 / Task 1741987
*               TCIB Componentization- Advanced Common Functional Components - Transfers/Payment/STO/Beneficiary/DD
*---------------------------------------------------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>
* Inserts
    $USING EB.Reports
    $USING DD.Contract
    $USING EB.DataAccess
    $INSERT I_DAS.DD.ITEM
    $INSERT I_DAS.DD.ITEM.NOTES

*** </region>
*-----------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main processing </desc>

    GOSUB INITIALISE
    GOSUB PROCESS
*
    RETURN
*** </region>
*------------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise variables used in this routine</desc>
INITIALISE:
*-----------
*Initialise required variables
    
    TABLE.SUFFIX = '';* Initialising variable
    MANDATE.REF = EB.Reports.getOData()      ;* Assign DD reference
    THE.LIST=DAS.DD.ITEM$CLAIMED.ITEMS  ;* Argument to get New DD Item
    THE.ARGS=EB.Reports.getOData():@FM:'NEW.ITEM'       ;* Assign DD reference and Status
    R.DD.ITEM=''    ;* initialise DD.ITEM array record
    ERR.DD.ITEM=''  ;* Initialise DD.ITEM error
*
    RETURN
*** </region>
*------------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>Get beneficiary details for process</desc>
PROCESS:
*--------
* To get value date from new DD.ITEM
    EB.DataAccess.Das("DD.ITEM",THE.LIST,THE.ARGS,TABLE.SUFFIX)      ;* To get new DD Item list
    DD.ITEM.REF=THE.LIST      ;* To assign new DD Item list
    R.DD.ITEM = DD.Contract.Item.Read(DD.ITEM.REF,ERR.DD.ITEM)         ;* Read DD.ITEM record
    EB.Reports.setOData(R.DD.ITEM<DD.Contract.Item.ItemValueDate>);* Assign value date to O.DATA
*
    RETURN
*------------------------------------------------------------------------------
    END

