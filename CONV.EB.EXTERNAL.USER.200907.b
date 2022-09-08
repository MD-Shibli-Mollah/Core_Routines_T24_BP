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
* <Rating>-32</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.ARC
    SUBROUTINE CONV.EB.EXTERNAL.USER.200907(YID, R.RECORD, FN.FILE)

********************************************************************************
* 21/05/08 - EN_10003680
* Conversion routine for all property class at designer level. This routine will
* default the corresponding value to the field APP.METHOD and DEFAULT.RESET.
* Also to append 'D' to values in BILL.PRODUCED field in PAYMENT.SCHEDULE
* as BILL.PRODUCED field is changed to type PERIOD
*
********************************************************************************-
*** <region name= Modification History>
***
* 15/06/09 - EN_10004165
*            ARC IB Licence Restrictions
*            SAR-2008-09-15-0008
*
* 22/01/16 - Task 1608211 / Defect 1598395
*			 EB.EXTERNAL.USER Conversion issue in USER.TYPE field
*
***</region>
*-----------------------------------------------------------------------------
* !** Simple SUBROUTINE template
* @author sivall@temenos.com
* @stereotype subroutine
* @package infra.eb
*!
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts
    $INSERT I_COMMON
    $INSERT I_EQUATE

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>
*
    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Process>
PROCESS:
*** <desc></desc>
*
* Loop through each arrangement and check the condition
    LOOP
        REMOVE ARR.ID FROM ARRANGEMENT.LIST SETTING ARR.POS ;* for every arrangemnet in all channels
    WHILE ARR.ID:ARR.POS
        CALL EB.GET.ARRANGEMENT.TYPE(ARR.ID,ARR.TYPE,ARR.CUSTOMER,ARR.ERR)      ;* Get the Arrangement customer and type
        R.RECORD<18,ARR.POS> = ARR.TYPE<1,1>   ;* get the Arrangement type 
    REPEAT
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Initialise>
INITIALISE:
*** <desc>Initialise</desc>

    R.RECORD.TEMP = R.RECORD
    ARR.ID = ''     ;* hold the Arrangement id
    ARR.POS = ''
    ARR.TYPE = ''   ;* hold the Arrangement type
    ARR.CUSTOMER = ''         ;* hold the Arrangement customer
    ARR.ERR = ''    ;* hold the error message
    ARRANGEMENT.LIST = R.RECORD<10>          ;* Arrangement list
    RETURN
*** </region>
*-----------------------------------------------------------------------------
END
