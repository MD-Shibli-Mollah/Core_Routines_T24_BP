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
* <Rating>212</Rating>
*-----------------------------------------------------------------------------
* Version 2 29/09/00  GLOBUS Release No. G11.0.00 29/06/00
    $PACKAGE TT.ModelBank
    SUBROUTINE E.TT.RETAILER.STOCK
*---------------------------------
* 01/03/07 - EN_10003187
*            DAS Retail Application Changes
*
* 04/04/07 - CI_10048255
*            Not all SERIAL NOS are displayed.
*---------------------------------

    $INSERT I_DAS.TT.STOCK.CONTROL      ;* EN_10003187 S/E

    $USING AC.AccountOpening
    $USING TT.Config
    $USING TT.Stock
    $USING EB.DataAccess
    $USING EB.API
    $USING EB.SystemTables
    $USING EB.Reports

*
* open files
*
    F.TT.STOCK.CONTROL = ''
*
    RETAILER.ID = EB.Reports.getId()
    SEL.CCY = ''
    SEL.TID = ''
    SEL.CAT = ''
*
* extract selection info
*
    LOCATE 'CURRENCY' IN EB.Reports.getEnqSelection()<2,1> SETTING CCYPOS THEN
    SEL.CCY = EB.Reports.getEnqSelection()<4,CCYPOS>
    END
*
    LOCATE 'TELLER.ID' IN EB.Reports.getEnqSelection()<2,1> SETTING TIDPOS THEN
    SEL.TID = EB.Reports.getEnqSelection()<4,TIDPOS>
    END
*
    LOCATE 'CATEGORY' IN EB.Reports.getEnqSelection()<2,1> SETTING CATPOS THEN
    SEL.CAT = EB.Reports.getEnqSelection()<4,CATPOS>
    END
*
* EN_10003187 S
    THE.LIST = DAS.TT.STOCK.CONTROL$DYNAMIC.SEL
    THE.ARGS = RETAILER.ID:@FM:SEL.CCY:@FM:SEL.TID:@FM:SEL.CAT
    EB.DataAccess.Das('TT.STOCK.CONTROL',THE.LIST,THE.ARGS,'')

    TC.LIST = THE.LIST
* EN_10003187 E

    GOSUB BUILD.TT.RETAILER.STOCK
*
    RETURN          ;* program end
*
************************
BUILD.TT.RETAILER.STOCK:
************************
*
    EB.Reports.setRRecord('')
*
    LOOP
        REMOVE STOCK.ID FROM TC.LIST SETTING END.MARK
    WHILE STOCK.ID:END.MARK
        R.TT.SC = ''
        R.TT.SC = TT.Stock.StockControl.Read(STOCK.ID, '')
        IF R.TT.SC THEN
            CHECKFILE1 = 'ACCOUNT':@FM:AC.AccountOpening.Account.SerialNoFormat
            YACCOUNT.NO = STOCK.ID
            CCY.SERIAL.FMT = ''
            EB.DataAccess.Dbr(CHECKFILE1,YACCOUNT.NO,CCY.SERIAL.FMT)
            IF EB.SystemTables.getEtext() THEN
                EB.Reports.setEnqError('SERIAL NO. FORMAT NOT DEFINED IN ':STOCK.ID)
                RETURN
            END
            *
            FOR YY = 1 TO DCOUNT(R.TT.SC<TT.Stock.StockControl.ScDenomination>,@VM)
                THIS.DENOM = R.TT.SC<TT.Stock.StockControl.ScDenomination,YY>
                THIS.SERIAL.NO = ''
                FOR YX = 1 TO DCOUNT(R.TT.SC<TT.Stock.StockControl.ScSerialNo,YY>,@SM)
                    IF RETAILER.ID EQ R.TT.SC<TT.Stock.StockControl.ScCustomerNo,YY,YX> THEN
                        THIS.SERIAL.NO<1,1,-1> = R.TT.SC<TT.Stock.StockControl.ScSerialNo,YY,YX>
                    END
                NEXT YX
                *
                IF THIS.SERIAL.NO THEN
                    GOSUB COUNT.STOCK
                    LOCATE THIS.DENOM IN EB.Reports.getRRecord()<1,1> SETTING DENOM.POS THEN
                    tmp=EB.Reports.getRRecord(); tmp<2,DENOM.POS>=EB.Reports.getRRecord()<2,DENOM.POS> + SERIAL.COUNT; EB.Reports.setRRecord(tmp)
                    tmp=EB.Reports.getRRecord(); tmp<3,DENOM.POS,-1>=THIS.SERIAL.NO; EB.Reports.setRRecord(tmp)
                    tmp=EB.Reports.getRRecord(); tmp<4,DENOM.POS>=EB.Reports.getRRecord()<4,DENOM.POS> + THIS.STOCK.VALUE; EB.Reports.setRRecord(tmp)
                END ELSE
                    tmp.REC = EB.Reports.getRRecord()
                    INS THIS.DENOM BEFORE tmp.REC<1,DENOM.POS>
                    INS SERIAL.COUNT BEFORE tmp.REC<2,DENOM.POS>
                    INS THIS.SERIAL.NO BEFORE tmp.REC<3,DENOM.POS>
                    INS THIS.STOCK.VALUE BEFORE tmp.REC<4,DENOM.POS>
                    EB.Reports.setRRecord(tmp.REC)
                END
            END
        NEXT YY
    END
    REPEAT
*
    EB.Reports.setVmCount(DCOUNT(EB.Reports.getRRecord()<1>,@VM))
    EB.Reports.setSmCount(DCOUNT(EB.Reports.getRRecord()<3>,@SM));* CI_10048255 S/E
*
    RETURN
*
************
COUNT.STOCK:
************
*
    THIS.STOCK.VALUE = 0
    SERIAL.COUNT = 0
*
    FOR SIDX = 1 TO DCOUNT(THIS.SERIAL.NO,@SM)
        RANGE.START = FIELD(THIS.SERIAL.NO<1,1,SIDX>,'-',1)
        RANGE.END = FIELD(THIS.SERIAL.NO<1,1,SIDX>,'-',2)
        RANGE.END = TRIM(RANGE.END,' ','A')       ;* remove all spaces
        RANGE.END = TRIM(RANGE.END,'.','A')       ;* remove all '.'
        IF RANGE.END EQ '' THEN
            SERIAL.COUNT += 1
        END ELSE
            THIS.SERIAL = RANGE.START
            GOSUB CALL.SPLIT.ALPHA.NUMERIC
            RANGE.END = RANGE.END[LEN(ALPHA.1)+1,LEN(NUMERIC.PART)]
            SERIAL.COUNT += RANGE.END - NUMERIC.PART + 1
        END
    NEXT SIDX
*
    IF SERIAL.COUNT THEN
        CHECKFILE1 = 'TELLER.DENOMINATION':@FM:TT.Config.TellerDenomination.DenValue
        THIS.VALUE = ''
        EB.DataAccess.Dbr(CHECKFILE1,THIS.DENOM,THIS.VALUE)
        IF THIS.VALUE THEN
            THIS.STOCK.VALUE = SERIAL.COUNT * THIS.VALUE
        END
    END
*
    RETURN
*
*************************
CALL.SPLIT.ALPHA.NUMERIC:
*************************
*
    ALPHA.1 = ''
    ALPHA.2 = ''
    NUMERIC.PART = ''
    EB.API.SplitAlphaNumeric(THIS.SERIAL,
    CCY.SERIAL.FMT,
    ALPHA.1,
    ALPHA.2,
    NUMERIC.PART,
    '',
    '')
*
    RETURN
*
    END
