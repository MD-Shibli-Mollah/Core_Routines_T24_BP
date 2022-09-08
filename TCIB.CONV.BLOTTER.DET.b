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
* <Rating>-12</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE T5.ModelBank
    SUBROUTINE TCIB.CONV.BLOTTER.DET
*-----------------------------------------------------------------------------
* It is used to get the SC,MF,DX datas
* attached as conversion routine.
* @author ssrimathi@temenos.com
* INCOMING PARAMETER  - ODATA
* OUTGOING PARAMETER  - ODATA
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------
* 29/04/2014 - Enhancement/Task_641974/991074
*              passing the values to the enquiry based on the Product.
* 19/05/2014 - Defect 967056 / Task 995233
*              CALC.CHRGS, CASH.CHRGS and CU.CASH.AMOUNT fields are include for SC Cash type
* 23/09/2015 - Defect 1474940 / Task 1478198
*			   TCIB WEALTH MODEL BANK - OPEN ORDER LIST ENQUIRY DOESNT WORK
*-------------------------------------------------------------------------------
    $USING EB.Reports
    $USING EB.SystemTables
    $USING DX.Order
    $USING MF.Orders
    $USING SC.SctOrderCapture
   
    SPF.ID = 'SYSTEM'
    R.SPF.REC = EB.SystemTables.Spf.Read(SPF.ID, SPF.ERR)	;*Read spf file
    PROD.INSTAL = R.SPF.REC<EB.SystemTables.Spf.SpfProducts>	;*Read products installed
    CONVERT @VM TO @FM IN PROD.INSTAL

    MFPOS = '';*Initialising variable
    MF.INSTALLED = 0;
    LOCATE 'MF' IN PROD.INSTAL SETTING MFPOS THEN       ;* To check MF module is installed
    MF.INSTALLED = 1
    END

    DXPOS = '';*Initialising variable

    DX.INSTALLED = 0;
    LOCATE 'DX' IN PROD.INSTAL SETTING DXPOS THEN	;* To check DX module is installed
    DX.INSTALLED = 1;
    END

    Y.PRODUCT = EB.Reports.getOData()
    Y.PROD = FIELD(Y.PRODUCT,'*',1)     ;* Get the Product
    Y.TRANS.ID = FIELD(Y.PRODUCT,'*',2) ;* Get the transaction id
    BEGIN CASE
        CASE Y.PROD EQ 'SC'       ;* Passing values to O.DATA based on the product 'SC'
            LIM.TYPE = ''
            TRADE.TYPE = ''
            FUND.CCY = ''
            UNIT.AMT = ''
            TRADE.DATE = ''
            LIM.DATE = ''
            CAL.CHRGS = ''
            CASH.CHRGS = ''
            CASH.AMOUNT = ''
            R.SEC.OPEN.ORDER = SC.SctOrderCapture.SecOpenOrder.Read(Y.TRANS.ID, ERR.SEC.OPEN.ORDER)
            CAL.CHRGS = R.SEC.OPEN.ORDER<SC.SctOrderCapture.SecOpenOrder.ScSooCalcChrgs>
            CASH.CHRGS = R.SEC.OPEN.ORDER<SC.SctOrderCapture.SecOpenOrder.ScSooCashChrgs>
            CASH.AMOUNT =  R.SEC.OPEN.ORDER<SC.SctOrderCapture.SecOpenOrder.ScSooCuCashAmount>
            EB.Reports.setOData(LIM.TYPE:"!":TRADE.TYPE:"!":FUND.CCY:"!":UNIT.AMT:"!":TRADE.DATE:"!":LIM.DATE:"!":CAL.CHRGS:"!":CASH.CHRGS:"!":CASH.AMOUNT);* Passing values to O.DATA
        CASE Y.PROD EQ 'MF' AND MF.INSTALLED EQ '1'   ;* Passing values to O.DATA based on the product 'MF'
            R.MF.ORD.REC = MF.Orders.Order.Read(Y.TRANS.ID,MF.ORD.ERR)      ;* Read the MF.ORDER record.
            TRADE.TYPE = ''
            TRADE.DATE = ''
            LIM.DATE = ''
            FUND.CCY = R.MF.ORD.REC<MF.Orders.Order.OrdFundCcy>
            UNIT.AMT = R.MF.ORD.REC<MF.Orders.Order.OrdUnitAmount>
            LIM.TYPE =R.MF.ORD.REC<MF.Orders.Order.OrdLimitType>
            EB.Reports.setOData(LIM.TYPE:"!":TRADE.TYPE:"!":FUND.CCY:"!":UNIT.AMT:"!":TRADE.DATE:"!":LIM.DATE);* Passing values to O.DATA
        CASE Y.PROD EQ 'DX' AND DX.INSTALLED EQ '1'    ;* Passing values to O.DATA based on the product 'DX'
            R.DX.ORD.REC = DX.Order.Order.Read(Y.TRANS.ID,DX.ORD.ERR)      ;* Read the DX.ORDER record.
            FUND.CCY = ''
            UNIT.AMT = ''
            TRADE.DATE = R.DX.ORD.REC<DX.Order.Order.OrdTradeDate>
            LIM.TYPE = R.DX.ORD.REC<DX.Order.Order.OrdLimitType>
            LIM.DATE = R.DX.ORD.REC<DX.Order.Order.OrdLimitDate>
            TRADE.TYPE = R.DX.ORD.REC<DX.Order.Order.OrdTradeType>
            EB.Reports.setOData(LIM.TYPE:"!":TRADE.TYPE:"!":FUND.CCY:"!":UNIT.AMT:"!":TRADE.DATE:"!":LIM.DATE);* Passing values to O.DATA
    END CASE
    RETURN
    END
