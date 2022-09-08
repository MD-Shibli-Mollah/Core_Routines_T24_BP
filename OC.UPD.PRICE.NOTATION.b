* @ValidationCode : Mjo3NzM0MDk2MzI6Q3AxMjUyOjE1OTk1NjcwNTkwNDg6a2JoYXJhdGhyYWo6NDowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOC4yMDIwMDczMS0xMTUxOjk6OQ==
* @ValidationInfo : Timestamp         : 08 Sep 2020 17:40:59
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kbharathraj
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 9/9 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-26</Rating>
*-----------------------------------------------------------------------------
$PACKAGE OC.Reporting

SUBROUTINE OC.UPD.PRICE.NOTATION(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
* The routine will be attached as a link routine in TX.TXN.BASE.MAPPING record.
* It returns the default value "X"
* This is the common routine for the FX,ND,SWAP,FRA and DX.
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*
* 27/02/20 - Enhancement 3562855 / Task 3562856
*            Mapping routine logic changes for EMIR-Phase 2
*
* 27/02/20 - Enhancement 3568609 / Task 3568610
*            Mapping routine logic change-SW for EMIR-Phase2
*
* 31/01/2020 - Enhancement 3562849 / Task 3562851
*              CI #3 - Mapping Routines
*
* 08/06/2020 - Enhancement 3715904 / Task 3786684
*              EMIR changes for DX
*
* 27/08/20 - Enhancement 3793940 / Task 3793943
*            CI#3 - Mapping routines - Part II
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
* Ret.val- returns the default value "X".
*
*
*******************************************************************
   
    $USING FX.Contract
    $USING SW.Contract
    $USING ST.CurrencyConfig
    $USING OC.Reporting
    
    GOSUB INITIALISE ; *
    GOSUB PROCESS ; *
   
RETURN

*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    IF (APPL.ID[1,2] EQ "FR") OR (APPL.ID[1,2] EQ "SW") OR (APPL.ID[1,2] EQ "ND") OR (APPL.ID[1,2] EQ "DX") OR (APPL.ID[1,2] EQ "FX") THEN
        RET.VAL = "X"
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
