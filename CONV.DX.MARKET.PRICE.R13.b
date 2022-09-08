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
* <Rating>-31</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Trade
    SUBROUTINE CONV.DX.MARKET.PRICE.R13(DX.MARKET.PRICE.ID, R.DX.MARKET.PRICE, FN.DX.MARKET.PRICE)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*         Defect - 1468656 Task - 1509617
*           Error in VDF when loading DX Prices
*           Conversion will process and convert the DX.MARKET.PRICE ID's which are not having DX.REP.POSITION
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DX.CONTRACT.MASTER
    $INSERT I_F.DX.MARKET.PRICE
*-----------------------------------------------------------------------------

    FN.DX.CONTRACT.MASTER = 'F.DX.CONTRACT.MASTER'
    F.DX.CONTRACT.MASTER = ''
    CALL OPF(FN.DX.CONTRACT.MASTER,F.DX.CONTRACT.MASTER)
    GOSUB FILTERING ; *Filtering the IDs to be processed based on number of '/' (i.e whether the ID has Rep Position or not)
    RETURN
*-----------------------------------------------------------------------------

*** <region name= FILTERING>
FILTERING:
*** <desc>Filtering the IDs to be processed based on number of '/' (i.e whether the ID has Rep Position or not) </desc>
    TEMP=DX.MARKET.PRICE.ID
    TEMP.FIRST.CHANGE.ID = FIELD(TEMP,":",1)
    TEMP.SECOND.CHANGE.ID = FIELD(TEMP,":",2)
    COUNTER=DCOUNT(TEMP.SECOND.CHANGE.ID,"/")
    COUNTER=COUNTER-1
    IF COUNTER LE 5 THEN
        GOSUB FORM.NEW.MARKET.PRICE.ID
    END
    RETURN
*** </region>


*-----------------------------------------------------------------------------
*** <region name= FORM.NEW.MARKET.PRICE.ID>
FORM.NEW.MARKET.PRICE.ID:
*** <desc>Create a new ID format and update with the existing ID </desc>
    DX.CHANGE.ID=DX.MARKET.PRICE.ID
*    Extract a first part of DX change ID with delimiter ':'
    FIRST.CHANGE.ID = FIELD(DX.CHANGE.ID,":",1)
*    Extract a second part of DX change ID with delimiter ':'
    SECOND.CHANGE.ID = FIELD(DX.CHANGE.ID,":",2)
*    Extract a third part of DX change ID with delimiter  ':'
    THIRD.CHANGE.ID = FIELD(DX.CHANGE.ID,":",3)
* Extract the contract master id from second change id using delimiter	'/'
    CONTRACT.MASTER.ID = FIELD(SECOND.CHANGE.ID,"/",2)
*   Get the Delivery Currency and Option Style information using contract master id to change the format of DX.MARKET.ID
    CALL F.READ(FN.DX.CONTRACT.MASTER,CONTRACT.MASTER.ID,R.CONTRACT.MASTER,F.DX.CONTRACT.MASTER,ERR.CONTRACT.MASTER)
    IF R.CONTRACT.MASTER THEN
        DEL.CURR = R.CONTRACT.MASTER<DX.CM.DELIVERY.CURRENCY>
        OPTN.STYLE = R.CONTRACT.MASTER<DX.CM.OPTION.STYLE>
    END
*   Assign the formt to newly Changed Market Price ID with already extracted three parts with  Delivery currency and Option Styles
    NEW.VAL.ID = SECOND.CHANGE.ID:"/":DEL.CURR:"/":OPTN.STYLE[1,1]
    FINAL.MARKET.PRICE.ID = FIRST.CHANGE.ID:":":NEW.VAL.ID:":":THIRD.CHANGE.ID
    R.DX.MARKET.PRICE<DX.MKT.OPTION.STYLE> = OPTN.STYLE[1,1]
    R.DX.MARKET.PRICE<DX.MKT.DELIVERY.CCY> = DEL.CURR
    CALL  F.WRITE(FN.DX.MARKET.PRICE,FINAL.MARKET.PRICE.ID,R.DX.MARKET.PRICE)
    CALL F.DELETE(FN.DX.MARKET.PRICE,DX.MARKET.PRICE.ID)
    RETURN
*** </region>
    END





