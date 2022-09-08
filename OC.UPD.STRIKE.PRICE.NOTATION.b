* @ValidationCode : MjoyMTQyNDM2NDE3OkNwMTI1MjoxNTkyMzExOTQwOTIwOnN0aGVqYXN3aW5pOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjEtMDY1NTo5Ojk=
* @ValidationInfo : Timestamp         : 16 Jun 2020 18:22:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sthejaswini
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 9/9 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-26</Rating>
*-----------------------------------------------------------------------------
$PACKAGE OC.Reporting
 
SUBROUTINE OC.UPD.STRIKE.PRICE.NOTATION(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
* The routine will be attached as a link routine in TX.TXN.BASE.MAPPING record.
* It returns the default value "U"
* This is the routine ONLY for the DX.
*-----------------------------------------------------------------------------
* Modification History :
*
*
* 31/01/2020 - Enhancement 3562849 / Task 3562851
*              CI #3 - Mapping Routines
*
*-----------------------------------------------------------------------------
*******************************************************************
*
*
* Incoming parameters:
*
* APPL.ID   - Id of transaction
* APPL.REC  - A dynamic array holding the contract.
* FIELD.POS - Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
* Ret.val- returns the default value "U".
*
*
*******************************************************************
    
    GOSUB INITIALISE ; *
    GOSUB PROCESS ; *
   
RETURN

*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    IF (APPL.ID[1,2] EQ "DX") THEN
        RET.VAL = "U"
    END
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>
    RET.VAL = ''

RETURN
*** </region>

END
