* @ValidationCode : MjoyMDQyODQwNDM0OkNwMTI1MjoxNjA0ODM3NDk5NjUwOnJkZWVwaWdhOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDkuMjAyMDA4MjgtMTYxNzo2OjY=
* @ValidationInfo : Timestamp         : 08 Nov 2020 17:41:39
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 6/6 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.INDICATOR(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine return indicator as 1(TRUE) for updation in SCDX.ARM.MIFID.DATA
* for reporting purpose
* Attached as the link routine in TX.TXN.BASE.MAPPING for updation in
* Database SCDX.ARM.MIFID.DATA
* Incoming parameters:
**********************
* TXN.ID   -   Transaction ID of the contract.
* TXN.REC  -   A dynamic array holding the contract.
* TXN.DATA -   Data passed based on setup done in TX.TXN.BASE.MAPPING
*
* Outgoing parameters:
**********************
* RET.VAL  -   "1" indicates TRUE
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 22/10/2020 - SI - 3754772 / ENH - 3994136 / TASK - 3994144
*              TRS Reporting / Mapping Routines
*
*-----------------------------------------------------------------------------

    GOSUB INITIALISE    ; *Initialise the variables required for processing
    GOSUB PROCESS       ; *Process to return Trade id indicator
           
RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the variables required for processing </desc>


RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>Process to return indicator as TRUE for reporting purpose </desc>

    RET.VAL = '1'
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
