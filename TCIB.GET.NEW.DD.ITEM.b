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
* <Rating>-51</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE T2.ModelBank

    SUBROUTINE TCIB.GET.NEW.DD.ITEM
*-----------------------------------------------------------------------------
* Attached to     : Conversion routine in enquiry TCIB.CUS.DD.MANDATES
* Incoming        : O.DATA
* Outgoing        : VALUE.DATE
*------------------------------------------------------------------------------
* Description:
* To get value date from New DD Item
*------------------------------------------------------------------------------
* Modification History :
* 25/11/14 - En 1093024 / Task 1116410
*            To get value date from New DD Item
*
*------------------------------------------------------------------------------
    $USING EB.Reports
    $USING DD.Contract
    $USING EB.DataAccess
    $INSERT I_DAS.DD.ITEM
    $INSERT I_DAS.DD.ITEM.NOTES

*
    GOSUB INITIALISE
    GOSUB OPENFILE
    GOSUB PROCESS
*
    RETURN
*------------------------------------------------------------------------------
INITIALISE:
*Initialise required variables
    MANDATE.REF = EB.Reports.getOData()      ;* Assign DD reference
    THE.LIST=DAS.DD.ITEM$CLAIMED.ITEMS  ;* Argument to get New DD Item
    THE.ARGS=EB.Reports.getOData():@FM:'NEW.ITEM'       ;* Assign DD reference and Status
    R.DD.ITEM=''    ;* To initialise DD.ITEM record
    ERR.DD.ITEM=''  ;* Initialise DD.ITEM error
*
    RETURN
*------------------------------------------------------------------------------
OPENFILE:
* Open required files

*
    RETURN
*------------------------------------------------------------------------------
PROCESS:
* To get value date from new DD.ITEM
    EB.DataAccess.Das("DD.ITEM",THE.LIST,THE.ARGS,TABLE.SUFFIX)      ;* To get new DD Item list
    DD.ITEM.REF=THE.LIST      ;* To assign new DD Item list
    R.DD.ITEM = DD.Contract.Item.Read(DD.ITEM.REF,ERR.DD.ITEM)         ;* Read DD.ITEM record
    EB.Reports.setOData(R.DD.ITEM<DD.Contract.Item.ItemValueDate>);* Assign value date to O.DATA
*
    RETURN
*------------------------------------------------------------------------------
    END
