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
* <Rating>-19</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Foundation
    SUBROUTINE CONV.DX.LIMIT.TXNS.R09
*----------------------------------------------------------------------------
* Conversion routine to change the date component in LIMIT.TXNS.
*-----------------------------------------------------------------------------
* Modification History:
* ---------------------
* 16/03/12 - Defect-369726 / Task-373270
*            Unable to do closeout for DX.TRADE after upgrading to R11.
*
* 12/04/12 - Defect - 387876/ Task-389396
*            LIMIT.TXNS was update wrogly ,after running the conversion CONV.DX.LIMIT.TXNS.R09.
*
* 15/04/13 - Defect - 638464 / Task 649687
*            Fatal error occurs when product "DX" is not installed.
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DX.TRADE
    $INSERT I_F.DX.CONTRACT.MASTER


    GOSUB CHECK.PROD.INSTAL ; * Check whether DX is installed
    IF VALID.PRODUCT AND COMPANY.HAS.PRODUCT THEN ; * If product DX is valid and installed in current company then process
        GOSUB INITIALISE
        GOSUB SELECTION
        GOSUB PROCESS
    END

    RETURN
*-----------------------------------------------------------------------------
CHECK.PROD.INSTAL:
******************

    VALID.PRODUCT = ""
    PRODUCT.INSTALLED = ""
    COMPANY.HAS.PRODUCT = ""
    ERROR.TEXT = ""
    CALL EB.VAL.PRODUCT("DX",VALID.PRODUCT,PRODUCT.INSTALLED,COMPANY.HAS.PRODUCT, ERROR.TEXT)

    RETURN
*-----------------------------------------------------------------------------
INITIALISE:
**********

    FN.LI.TXNS = 'F.LIMIT.TXNS'
    F.LI.TXNS = ''
    CALL OPF(FN.LI.TXNS, F.LI.TXNS)

    FN.DX.CONTRACT.MASTER = "F.DX.CONTRACT.MASTER"
    F.DX.CONTRACT.MASTER = ""
    CALL OPF(FN.DX.CONTRACT.MASTER, F.DX.CONTRACT.MASTER)

    FN.DX.TRADE = 'F.DX.TRADE'
    F.DX.TRADE = ''
    CALL OPF(FN.DX.TRADE,F.DX.TRADE)

    R.DX.LIMIT.TXNS = ""
    R.DX.CONTRACT.MASTER = ""
    R.DX.TRADE = ""

    LIMIT.REC = ""
    RETURN

*-----------------------------------------------------------------------------
SELECTION:
*********
* Select the records in LIMIT.TXNS which are created for DX.

    COMMAND = 'SELECT ':FN.LI.TXNS:' WITH TXN.DATA LIKE DX...'
    DX.LIMIT.TXNS.LIST = ''
    SELECTED = ''
    SERR = ''
    CALL EB.READLIST(COMMAND, DX.LIMIT.TXNS.LIST,'', SELECTED, SERR)

    RETURN
*-----------------------------------------------------------------------------
PROCESS:
********
* Pick up the reord in LIMIT.TXNS and compare the date, if the date is not the Last Calendar Day
* then check for the maturity type of the contract. If is Monthly maturity type then
* replace the date in LIMIT.TXNS to last calendar day.

    LOOP
        REMOVE DX.LIMIT.TXNS.ID FROM DX.LIMIT.TXNS.LIST SETTING DX.TXNS
    WHILE DX.LIMIT.TXNS.ID:DX.TXNS
        CALL F.READ("FN.LI.TXNS", DX.LIMIT.TXNS.ID , R.DX.LIMIT.TXNS, F.LI.TXNS  , ERR)
        LIMIT.REC = ""
        TOTAL.TXNS = DCOUNT(R.DX.LIMIT.TXNS ,FM)

        FOR NO.OF.TXNS = 1 TO TOTAL.TXNS
            TXN.REF =FIELD(R.DX.LIMIT.TXNS<NO.OF.TXNS>, "\" ,1)
            TRADE.ID = FIELD(TXN.REF, "." ,1)
            TXN.CCY = FIELD(R.DX.LIMIT.TXNS<NO.OF.TXNS>, "\" ,2)
            TXN.LIMIT.AMOUNT = FIELD(R.DX.LIMIT.TXNS<NO.OF.TXNS>, "\" ,3)
            LIMIT.DATE = FIELD(R.DX.LIMIT.TXNS<NO.OF.TXNS>, "\" ,4)
            COMP.MNE = FIELD(R.DX.LIMIT.TXNS<NO.OF.TXNS>, "\" ,5)
            TOTAL.AMOUNT = FIELD(R.DX.LIMIT.TXNS<NO.OF.TXNS>, "\" ,6)
            LIMIT.REFF = FIELD(R.DX.LIMIT.TXNS<NO.OF.TXNS>, "\" ,7)

            MAT.YEAR = LIMIT.DATE[1,4]
            MAT.MONTH = LIMIT.DATE[5,2]
            MAT.DATE = LIMIT.DATE[7,2]

            GOSUB CALC.LAST.CAL.DAY
            IF LIMIT.DATE[7,2] NE RET.DATE THEN
                CALL F.READ("FN.DX.TRADE",TRADE.ID, R.DX.TRADE, F.DX.TRADE, ERR)
                CONTRACT.ID = R.DX.TRADE<DX.TRA.CONTRACT.CODE>
                CALL F.READ("FN.DX.CONTRACT.MASTER", CONTRACT.ID, R.DX.CONTRACT.MASTER,F.DX.CONTRACT.MASTER , ERR)
                MAT.TYPE = R.DX.CONTRACT.MASTER<DX.CM.MATURITY.TYPE>
                IF MAT.TYPE EQ "MONTHLY" THEN
                    LIMIT.DATE = MAT.YEAR:MAT.MONTH:RET.DATE
                END
            END
            LIMIT.REC<NO.OF.TXNS> = TXN.REF:"\":TXN.CCY:"\":TXN.LIMIT.AMOUNT:"\":LIMIT.DATE:"\":COMP.MNE:"\":TOTAL.AMOUNT:"\":LIMIT.REFF
        NEXT NO.OF.TXNS

        GOSUB CONV.LIMIT.TXNS
    REPEAT

    RETURN
*-----------------------------------------------------------------------------
CALC.LAST.CAL.DAY:
*****************
* Call for the routine to get the number of calendar days in a Month for a particular year.

    CALL DX.GET.LCD.MM(MAT.YEAR, MAT.MONTH, RET.DATE)
    RETURN
*-----------------------------------------------------------------------------
CONV.LIMIT.TXNS:
***************
* Writes the data to LIMIT.TXNS

    CALL F.WRITE (FN.LI.TXNS, DX.LIMIT.TXNS.ID, LIMIT.REC)
    RETURN

    END
