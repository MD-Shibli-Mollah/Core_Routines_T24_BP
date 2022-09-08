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

* Version 2 29/09/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>181</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE TT.ModelBank
    SUBROUTINE E.TT.BUILD.RETAILER.LIST(ENQUIRY.DATA)
*-----------------------------------------------------------------------------
* 01/03/07 - EN_10003187
*            DAS Retail Application Changes
*
* 04/04/07 - CI_10048255
*            Not all SERIAL NOs are displayed.
*-----------------------------------------------------------------------------
    $INSERT I_DAS.TT.STOCK.CONTROL      ;* EN_10003187 S/E

    $USING TT.Stock
    $USING EB.Reports
    $USING EB.DataAccess

*
* open files
*
    F.TT.STOCK.CONTROL = ''
*
* select on retailer id only
*
    LOCATE 'RETAILER.NO' IN ENQUIRY.DATA<2,1> SETTING RET.POS THEN
    RETAILER.ID = ENQUIRY.DATA<4,RET.POS>
    CONVERT ' ' TO @VM IN RETAILER.ID
    NO.OF.IDS = DCOUNT(RETAILER.ID,@VM)
*
    IF NO.OF.IDS GT 1 AND INDEX(RETAILER.ID,"ALL",1) THEN
        EB.Reports.setEnqError("INVALID RETAILER")
        RETURN
    END
    END ELSE
    RETURN
    END
*
    IF RETAILER.ID<1,1> EQ 'ALL' THEN
        THIS.RETAILER.LIST = ''
    END ELSE
        THIS.RETAILER.LIST = RETAILER.ID
    END
    GOSUB BUILD.RETAILER.ID.LIST
*
    IF RETAILER.ID THEN
        RETAILER.ID = RAISE(RETAILER.ID)
        SELECT RETAILER.ID
    END ELSE
        EB.Reports.setEnqError("NO RECORD MATCHED THE SELECTION CRITERIA")
    END
*
    RETURN
*
***********************
BUILD.RETAILER.ID.LIST:
***********************
*
* build retailer list from TT.STOCK.CONTROL
*

    SEL.CCY = ''
    SEL.TID = ''
    SEL.CAT = ''
*
* extract selection info
*
    LOCATE 'CURRENCY' IN ENQUIRY.DATA<2,1> SETTING CCYPOS THEN
    SEL.CCY = ENQUIRY.DATA<4,CCYPOS>
    END
*
    LOCATE 'TELLER.ID' IN ENQUIRY.DATA<2,1> SETTING TIDPOS THEN
    SEL.TID = ENQUIRY.DATA<4,TIDPOS>
    END
*
    LOCATE 'CATEGORY' IN ENQUIRY.DATA<2,1> SETTING CATPOS THEN
    SEL.CAT = ENQUIRY.DATA<4,CATPOS>
    END
*
* EN_10003187 S
    THE.LIST = DAS.TT.STOCK.CONTROL$DYNAMIC.SEL
    THE.ARGS = THIS.RETAILER.LIST:@FM:SEL.CCY:@FM:SEL.TID:@FM:SEL.CAT
    EB.DataAccess.Das('TT.STOCK.CONTROL',THE.LIST,THE.ARGS,'')

    TC.LIST = THE.LIST
* EN_10003187 E

* CI_10048255 S
    IF NOT(TC.LIST) THEN
        RETAILER.ID = ''
        RETURN
    END
    IF NOT(THIS.RETAILER.LIST) THEN
        RETAILER.ID = ''      ;* CI_10048255 E
        LOOP
            REMOVE STOCK.ID FROM TC.LIST SETTING END.MARK
        WHILE STOCK.ID:END.MARK
            R.TT.SC = ''
            R.TT.SC = TT.Stock.StockControl.Read(STOCK.ID, '')
            IF R.TT.SC THEN
                FOR YY = 1 TO DCOUNT(R.TT.SC<TT.Stock.StockControl.ScDenomination>,@VM)
                    FOR YX = 1 TO DCOUNT(R.TT.SC<TT.Stock.StockControl.ScSerialNo,YY>,@SM)
                        THIS.RETAILER = R.TT.SC<TT.Stock.StockControl.ScCustomerNo,YY,YX>
                        IF THIS.RETAILER THEN
                            LOCATE THIS.RETAILER IN RETAILER.ID<1,1> SETTING RETPOS ELSE
                            INS THIS.RETAILER BEFORE RETAILER.ID<1,RETPOS>
                        END
                    END
                NEXT YX
            NEXT YY
        END
    REPEAT
    END   ;* CI_10048255 S/E
*
    RETURN
*
    END
