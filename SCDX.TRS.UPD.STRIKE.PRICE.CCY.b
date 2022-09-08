* @ValidationCode : MjoxMjQ2MzY4NDg2OkNwMTI1MjoxNjA0ODM3NTAyNzczOnJkZWVwaWdhOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDkuMjAyMDA4MjgtMTYxNzoxNjoxNg==
* @ValidationInfo : Timestamp         : 08 Nov 2020 17:41:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 16/16 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.STRIKE.PRICE.CCY(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine return Strike Price currency for updation in SCDX.ARM.MIFID.DATA
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
* RET.VAL  -  Strike Price currency
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 22/10/2020 - SI - 3754772 / ENH - 3994136 / TASK - 3994144
*              TRS Reporting / Mapping Routines
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Inserts and control logic</desc>

    $USING DX.Trade
    
*** </region>
*-----------------------------------------------------------------------------

    GOSUB INITIALISE    ; *Initialise the variables required for processing
    GOSUB PROCESS       ; *Process to return Strike Price currency
           
RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the variables required for processing </desc>

    RET.VAL = ''
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>Process to return Strike Price currency for reporting purpose </desc>

    BEGIN CASE
        CASE TXN.ID[1,5] EQ 'DXTRA'
            CONTRACT.CCY = TXN.REC<DX.Trade.Trade.TraContractCcy>
            QUOTE.CCY = TXN.REC<DX.Trade.Trade.TraStrikeQuoteCcy>
            IF CONTRACT.CCY EQ QUOTE.CCY THEN
                RET.VAL = TXN.REC<DX.Trade.Trade.TraDlvCcy>
            END ELSE
                RET.VAL = CONTRACT.CCY
            END
        
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
