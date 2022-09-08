* @ValidationCode : MjotMzc3MTIyNDE6Q3AxMjUyOjE1NjQ1NzI2NzM1NzA6c3JhdmlrdW1hcjotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxOTA4LjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 Jul 2019 17:01:13
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqStockControl
SUBROUTINE CONV.STOCK.REGISTER.SORT.SERIES.NO(STOCK.REG.ID,STOCK.REG.REC,YFILE.REC)

* 12/05/06 - CI_10040871/CI_10041068
*            This conversion should be run in order to sort the Series Nos under a particular
*            Series ID of a Stock register in ascending order.In addition after the sort order, if
*            there are any blank nos in the series nos , they would get deleted.
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_StockControl as ST_ChqStockControl and include $PACKAGE
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
*

    SER.IDS = RAISE(STOCK.REG.REC<1>)
    SER.IDS.CNT = DCOUNT(SER.IDS,FM)    ;* CI_10041068S/E

    SER.NOS = RAISE(STOCK.REG.REC<2>)
    SER.NOS.CNT = DCOUNT(SER.NOS,VM)

    SER.CTR = 0

    LOOP
        REMOVE STO.SER FROM SER.IDS SETTING SER.1
        SER.CTR +=1
    UNTIL SER.CTR GT SER.IDS.CNT
        NEW.RANGE = ''        ;* CI_10041068/S
        RANGE.FIELD = RAISE(STOCK.REG.REC<2,SER.CTR>)
        NEW.RANGE = RANGE.FIELD<1,1>
        ST.NO =  FIELD(NEW.RANGE,"-",1)
        END.NO = FIELD(NEW.RANGE,"-",2) ;*CI_10041068/E
        RESULT = ''
        RESULT<2> = 1
        CALL EB.MAINTAIN.RANGES(RANGE.FIELD,ST.NO,END.NO,"INS",RESULT,CHQ.ERROR)
        RANGE.FIELD = LOWER(RANGE.FIELD)
        STOCK.REG.REC<2,SER.CTR> = RANGE.FIELD

    REPEAT
*
RETURN
*------------


END
