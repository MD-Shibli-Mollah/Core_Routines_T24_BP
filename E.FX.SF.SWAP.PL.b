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

* Version 2 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-33</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FX.ModelBank
    SUBROUTINE E.FX.SF.SWAP.PL
*


    $USING FX.Reports
    $USING EB.Reports
    $USING FX.ModelBank

*
*************************************************************************
* Modifications:
* -------------
* 07/06/07 - EN_10003396
*            I-Descriptor Cleanup
*
* 15/09/15 - EN_1226121 / Task 1477143
*	      	 Routine incorporated
*
*-----------------------------------------------------------------------
*************
MAIN.PROCESS:
*************
*

    GOSUB INITIALISATION
*
    GOSUB READ.FX.SF.SWAP.RECORD
*
    IF R.FX.SF.SWAP THEN
        IF R.FX.SF.SWAP<FX.Reports.SfSwap.SfTotIntBought> THEN
            TEMP.O.DATA = -R.FX.SF.SWAP<FX.Reports.SfSwap.SfTotIntBought>
            TEMP.O.DATA := '*':-R.FX.SF.SWAP<FX.Reports.SfSwap.SfBuyDailyAccF>
            TEMP.O.DATA := '*':-R.FX.SF.SWAP<FX.Reports.SfSwap.SfBuyAccTdateF>
            EB.Reports.setOData(TEMP.O.DATA)
        END ELSE
            IF R.FX.SF.SWAP<FX.Reports.SfSwap.SfTotIntSold> THEN
                TEMP.O.DATA = R.FX.SF.SWAP<FX.Reports.SfSwap.SfTotIntSold>
                TEMP.O.DATA := '*':R.FX.SF.SWAP<FX.Reports.SfSwap.SfSelDailyAccF>
                TEMP.O.DATA := '*':R.FX.SF.SWAP<FX.Reports.SfSwap.SfSelAccTdateF>
                EB.Reports.setOData(TEMP.O.DATA)
            END
        END
    END
*
    RETURN
*
************************************************************************
*
***************
INITIALISATION:
***************
*

*
    EB.Reports.setOData("")
    R.FOREX = ""
    R.FX.SF.SWAP = ''
    FX.ID = EB.Reports.getId()
*
    RETURN
*
*************************************************************************
*
******************
READ.FX.SF.SWAP.RECORD:
******************
*
*  Read FX.SF.SWAP contract
*
    ER = ''
    R.FX.SF.SWAP = FX.Reports.SfSwap.Read(FX.ID, ER)
    IF ER THEN
        R.FX.SF.SWAP = ""
    END
*
    RETURN
*
*************************************************************************
*
    END
