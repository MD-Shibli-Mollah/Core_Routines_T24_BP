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
    $PACKAGE AA.ModelBank
    SUBROUTINE E.MB.GET.DATE

    $USING EB.Reports


    GOSUB INIT
    GOSUB PROCESS
    RETURN

*********************************************
INIT:
*********************************************
    EB.Reports.setId(" ")
    EB.Reports.setId(EB.Reports.getOData())
    tmp.ID = EB.Reports.getId()
    BAS.DATE = FIELD(tmp.ID,"/",1)
    EB.Reports.setId(tmp.ID)
    tmp.ID = EB.Reports.getId()
    COOL.DUR = FIELD(tmp.ID,"/",2)
    EB.Reports.setId(tmp.ID)
    CURR.YEAR = BAS.DATE[1,4]
    CURR.MONTH = BAS.DATE[5,2]
    CURR.DATE = BAS.DATE[7,2]
    CURR.DATE = CURR.DATE + COOL.DUR
    YEAR.CHK = MOD(CURR.YEAR,4)
    RETURN

*********************************************
PROCESS:
*********************************************

    IF CURR.MONTH EQ '02' THEN
        IF  YEAR.CHK EQ 0 THEN
            DAYS = 29
            GOSUB DATE.CHK
        END ELSE
            DAYS = 28
            GOSUB DATE.CHK
        END
    END ELSE

        IF CURR.MONTH EQ '1' OR  CURR.MONTH EQ '3' OR CURR.MONTH EQ '5' OR CURR.MONTH EQ '7' OR CURR.MONTH EQ '8'  OR CURR.MONTH EQ '10' OR CURR.MONTH EQ '12' THEN
            DAYS = 31
            GOSUB DATE.CHK
        END ELSE
            DAYS = 30
            GOSUB DATE.CHK
        END
    END
    RETURN

********************************************
DATE.CHK:
********************************************

    IF CURR.DATE > DAYS THEN
        CURR.DATE = CURR.DATE - DAYS
        CURR.MONTH = CURR.MONTH + 1
        IF CURR.MONTH > 12 THEN
            CURR.MONTH = CURR.MONTH - 12
            CURR.YEAR = CURR.YEAR +1
            YEAR.CHK = MOD(CURR.YEAR,4)
        END
        GOSUB PROCESS
    END ELSE
        CURR.DATE = CURR.DATE
        CURR.MONTH = CURR.MONTH
        CURR.YEAR = CURR.YEAR
    END
    EB.Reports.setOData(CURR.DATE : ' ' : CURR.MONTH : ' ' : CURR.YEAR)
    RETURN
    END

