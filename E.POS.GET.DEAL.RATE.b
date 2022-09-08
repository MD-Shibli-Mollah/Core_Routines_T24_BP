* @ValidationCode : Mjo2MTMyNjU2ODI6Q3AxMjUyOjE1NDI3OTg5NDk2MTg6cG1haGE6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTgxMS4yMDE4MTAyMi0xNDA2Oi0xOi0x
* @ValidationInfo : Timestamp         : 21 Nov 2018 16:45:49
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : pmaha
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 1 04/03/98  GLOBUS Release No.
*-----------------------------------------------------------------------------
* <Rating>1746</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.ModelBank
    
SUBROUTINE E.POS.GET.DEAL.RATE
*
** This subroutine will return the exchange rate entered in the deal
** and also the other currency
*
**************************************************************************
*                                                                       *
*  Modifications :
* 09/11/18 - Enhancement 2822523 / Task 2847649
*          - Incorporation of EB_ModelBank component
*************************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.FOREX
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.SEC.TRADE
    $INSERT I_F.POS.MVMT.TODAY
    $INSERT I_F.TELLER
    $INSERT I_F.COMPANY
*
    TXN.REF = O.DATA
    IN.CCY = R.RECORD<PSE.CURRENCY>
    OUT.CCY = ''    ;* Other Currency
    OUT.RATE = ''   ;* Returned
    BUY.SELL = ''   ;* Buy Sell indicator
    VALUE.DATE = ''
*
    LOCATE "SHOW.LOCAL.RATE" IN ENQ.SELECTION<2,1> SETTING POS THEN
        SHOW.LOCAL.RATE = ENQ.SELECTION<4,POS>
    END ELSE
        SHOW.LOCAL.RATE = ''
    END
*
    APP.CODE = MATCHFIELD(TXN.REF,'1-6A0X',1)
    BEGIN CASE
        CASE SHOW.LOCAL.RATE = 'YES'
            OUT.CCY = LCCY
            OUT.RATE = R.RECORD<PSE.EXCHANGE.RATE>
*
        CASE APP.CODE = 'FT'
            LOCATE 'FT' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING POS THEN
                F.FUNDS.TRANSFER = '' ; CALL OPF('F.FUNDS.TRANSFER', F.FUNDS.TRANSFER)
                F.FUNDS.TRANSFER$NAU = '' ; CALL OPF('F.FUNDS.TRANSFER$NAU', F.FUNDS.TRANSFER$NAU)
                F.FUNDS.TRANSFER$HIS = '' ; CALL OPF('F.FUNDS.TRANSFER$HIS', F.FUNDS.TRANSFER$HIS)
*
                READ FT.REC FROM F.FUNDS.TRANSFER$NAU, TXN.REF ELSE
                    READ FT.REC FROM F.FUNDS.TRANSFER, TXN.REF ELSE
                        READ FT.REC FROM F.FUNDS.TRANSFER$HIS, TXN.REF:';1' ELSE FT.REC = ''
                    END
                END
                OUT.RATE = FT.REC<FT.CUSTOMER.RATE>
                IF OUT.RATE = '' THEN OUT.RATE = FT.REC<FT.TREASURY.RATE>
*
                IF IN.CCY = FT.REC<FT.CREDIT.CURRENCY> THEN
                    OUT.CCY = FT.REC<FT.DEBIT.CURRENCY>
                    VALUE.DATE = FT.REC<FT.CREDIT.VALUE.DATE>
                END ELSE
                    OUT.CCY = FT.REC<FT.CREDIT.CURRENCY>
                    VALUE.DATE = FT.REC<FT.DEBIT.VALUE.DATE>
                END
*
            END
*
        CASE APP.CODE = 'FX'
            LOCATE 'FX' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING POS THEN
                F.FOREX = '' ; CALL OPF('F.FOREX', F.FOREX)
                F.FOREX$NAU = '' ; CALL OPF('F.FOREX$NAU', F.FOREX$NAU)
                F.FOREX$HIS = '' ; CALL OPF('F.FOREX$HIS', F.FOREX$HIS)
*
                TXN.REF = TXN.REF[1,12]
                READ FX.REC FROM F.FOREX$NAU, TXN.REF ELSE
                    READ FX.REC FROM F.FOREX, TXN.REF ELSE
                        READ FX.REC FROM F.FOREX$HIS, TXN.REF:';1' ELSE FX.REC = ''
                    END
                END
*
                BEGIN CASE
                    CASE FX.REC<FX.DEAL.TYPE> = 'SP'
                        OUT.RATE = FX.REC<FX.SPOT.RATE>
*
                    CASE FX.REC<FX.DEAL.TYPE> = 'FW'
                        OUT.RATE = FX.REC<FX.FORWARD.RATE>
*
                    CASE FX.REC<FX.FORWARD.RATE>
                        OUT.RATE = FX.REC<FX.FORWARD.RATE>
*
                    CASE 1
                        OUT.RATE = FX.REC<FX.SPOT.RATE>
*
                END CASE
*
                IF FX.REC<FX.CURRENCY.SOLD> = IN.CCY THEN
                    OUT.CCY = FX.REC<FX.CURRENCY.BOUGHT>
                    VALUE.DATE = FX.REC<FX.VALUE.DATE.SELL>
                END ELSE
                    OUT.CCY = FX.REC<FX.CURRENCY.SOLD>
                    VALUE.DATE = FX.REC<FX.VALUE.DATE.BUY>
                END
            END
*
        CASE APP.CODE = 'TT'
            LOCATE 'TT' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING POS THEN
                F.TELLER = '' ; CALL OPF('F.TELLER', F.TELLER)
                F.TELLER$NAU = '' ; CALL OPF('F.TELLER$NAU', F.TELLER$NAU)
                F.TELLER$HIS = '' ; CALL OPF('F.TELLER$HIS', F.TELLER$HIS)
*
                READ TT.REC FROM F.TELLER$NAU, TXN.REF ELSE
                    READ TT.REC FROM F.TELLER, TXN.REF ELSE
                        READ TT.REC FROM F.TELLER$HIS, TXN.REF:';1' ELSE TT.REC = ''
                    END
                END
*
                OUT.RATE = TT.REC<TT.TE.DEAL.RATE>
                IF TT.REC<TT.TE.CURRENCY.1> = IN.CCY THEN
                    OUT.CCY = TT.REC<TT.TE.CURRENCY.2>
                    VALUE.DATE = TT.REC<TT.TE.VALUE.DATE.1>
                END ELSE
                    OUT.CCY = TT.REC<TT.TE.CURRENCY.1>
                    VALUE.DATE = TT.REC<TT.TE.VALUE.DATE.2>
                END
            END
*
        CASE APP.CODE = 'SCTRSC'
*
** Deducing the rate is not that easy, leave it now
*
            LOCATE 'SC' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING POS THEN
                F.SEC.TRADE = '' ; CALL OPF('F.SEC.TRADE', F.SEC.TRADE)
                F.SEC.TRADE$NAU = '' ; CALL OPF('F.SEC.TRADE$NAU', F.SEC.TRADE$NAU)
                F.SEC.TRADE$HIS = '' ; CALL OPF('F.SEC.TRADE$HIS', F.SEC.TRADE$HIS)
*
                READ SC.REC FROM F.SEC.TRADE$NAU, TXN.REF ELSE
                    READ SC.REC FROM F.SEC.TRADE, TXN.REF ELSE
                        READ SC.REC FROM F.SEC.TRADE$HIS, TXN.REF:';1' ELSE SC.REC = ''
                    END
                END
*
                IF IN.CCY = SC.REC<SC.SBS.TRADE.CCY> THEN
                    IF DCOUNT(SC.REC<SC.SBS.CU.ACCOUNT.CCY>,@VM) = 1 THEN
                        OUT.CCY = SC.REC<SC.SBS.CU.ACCOUNT.CCY,1>
                        OUT.RATE = SC.REC<SC.SBS.CU.EX.RATE.ACC,1>
                    END
                END ELSE
                    LOCATE IN.CCY IN SC.REC<SC.SBS.TRADE.CCY,1> SETTING YPOS THEN
                        OUT.CCY = SC.REC<SC.SBS.TRADE.CCY>
                        OUT.RATE = SC.REC<SC.SBS.CU.EX.RATE.ACC,YPOS>
                    END
                END
                VALUE.DATE = SC.REC<SC.SBS.VALUE.DATE>
*
            END
*
    END CASE
*
    IF OUT.RATE = '' THEN
        OUT.RATE = R.RECORD<PSE.CROSS.RATE>
        OUT.CCY = R.RECORD<PSE.OTHER.CCY>
    END
    IF VALUE.DATE = '' THEN VALUE.DATE = R.RECORD<PSE.VALUE.DATE>
    O.DATA = OUT.RATE:">":OUT.CCY
*
** Set the Purchase / Sale indicator
*
    BEGIN CASE
        CASE R.RECORD<PSE.AMOUNT.LCY> LT 0 AND R.RECORD<PSE.TRANSACTION.CODE> MATCHES "DEL":@VM:"REV"
            BUY.SELL = "S*"
        CASE R.RECORD<PSE.AMOUNT.LCY> LT 0
            BUY.SELL = "P"
        CASE R.RECORD<PSE.TRANSACTION.CODE> MATCHES "DEL":@VM:"REV"
            BUY.SELL = "P*"
        CASE 1
            BUY.SELL = "S"
    END CASE
*
    O.DATA := '>':BUY.SELL:'>':VALUE.DATE
*
END
