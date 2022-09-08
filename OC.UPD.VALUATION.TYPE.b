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
* <Rating>-30</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting
    SUBROUTINE OC.UPD.VALUATION.TYPE(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
*The routine returns the valuation type for FOREX,SWAP,FRA.DEAL,ND.DEAL and DX.TRADE.
*-----------------------------------------------------------------------------
* Modification History :
*
* 18/09/15 - Enhancement 1461371 / Task 1461382
*            OTC Collateral and Valuation Reporting.
*
* 30/12/15 - EN_1226121 / Task 1568411
*			 Incorporation of the routine
*
* 11/7/16 - Defect 1523549 / Task 1562086
*           MTM value 1 & MTM value 2 updation in OC.VAL.COLL.DATA enquiry.
*
*-----------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING EB.API
    $USING FX.Contract

*-----------------------------------------------------------------------------

    GOSUB INITIALISE ; *INITIALISE
    GOSUB PROCESS ; *PROCESS

    RETURN

*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>INITIALISE </desc>

    RET.VAL = ''

    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
PROCESS:
*** <desc>PROCESS </desc>

    RET.VAL = 'O' ;*valuation type will be 'O' for IRS,CIRS,FRA,ND.DEAL,DX.TRADE and FOREX FWD.


    IF TXN.ID[1,2] EQ 'FX' AND TXN.REC<FX.Contract.Forex.DealType> EQ 'SW' THEN;* for FX SWAP

        SWAP.REF.NO = TXN.REC<FX.Contract.Forex.SwapRefNo> ;* fetch the ref no

        IF SWAP.REF.NO<1,1> EQ TXN.ID THEN ;*first leg of swap
            RET.VAL = 'M';*default as 'M' for spot leg of swap.
        END ELSE
            RET.VAL ='O';*default as 'O' for fwd leg of swap.
        END

    END
    RETURN
*** </region>
*-----------------------------------------------------------------------------

    END


