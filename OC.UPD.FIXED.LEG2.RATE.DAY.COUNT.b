* @ValidationCode : MjoyMDMwNTY5MDgwOkNwMTI1MjoxNTgzMjIxMTAwMTA4OnByaXlhZGhhcnNoaW5pazoyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAyLjIwMjAwMTE3LTIwMjY6MTg6MTg=
* @ValidationInfo : Timestamp         : 03 Mar 2020 13:08:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : priyadharshinik
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 18/18 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.FIXED.LEG2.RATE.DAY.COUNT(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*<Routine description>
*
*
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* report the day count basis on the fixed leg of the contract.
*
*
* Incoming parameters:
*
* APPL.ID   -   Transaction ID of the contract.
* APPL.REC  -   A dynamic array holding the contract.
* FIELD.POS -   Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
* RET.VAL   -   Day count basis on the Fixed leg of the contract
*               If T24 Bank is seller, the day count basis of asset leg
*               Else liability leg
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 21/02/2020 - Enhancement 3568600 / Task 3568601
*              CI#4 -Mapping of TX.TXN.BASE.MAPPING and related routines
*
*
*-----------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING SW.Contract
    
    GOSUB INITIALISE ; *
    GOSUB PROCESS ; *
RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>
    RET.VAL = ''
    FIXED.RATE.LEG2 = ''
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>Day count basis on the Fixed leg of the contract</desc>

*To get the value from the field FIXED.RATE.LEG2.
    OC.Reporting.UpdFixedRateLeg2(APPL.ID, APPL.REC, FIELD.POS, FIXED.RATE.LEG2)
    
    IF FIXED.RATE.LEG2 THEN
        CPARTY.SIDE = ''
        OC.Reporting.UpdCpartySide(APPL.ID, APPL.REC, FIELD.POS, CPARTY.SIDE)

*If T24 Bank is seller, the day count basis of liability leg.
*If T24 Bank is Buyer, the day count basis of assest leg.
    
        BEGIN CASE
        
            CASE CPARTY.SIDE = 'S'
                RET.VAL = APPL.REC<SW.Contract.Swap.LbBasis>
            CASE CPARTY.SIDE = 'B'
                RET.VAL = APPL.REC<SW.Contract.Swap.AsBasis>
        END CASE
    
    END
    
RETURN
*** </region>

END


