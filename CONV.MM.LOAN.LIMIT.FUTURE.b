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

* Version 3 15/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MM.Contract
    SUBROUTINE CONV.MM.LOAN.LIMIT.FUTURE(MM.ID,MM.REC,MM.FILE)
*
*********************************************************************
* This conversion is used to reverse a future dated principal decrease
* amount of a MM- Loan contract from the LIMIT
*********************************************************************
* MODIFICATIONS:
****************
*
* 23/03/05 - CI_10028552
*            MM contract principal reduction - LIAB / GAP errors
*
* 02/08/05 - CI_10033007
*            Executing RUN.CONVERSION.PGMS-fatals out in LOAD.COMPANY.
*
* 10/10/08 - CI_10058085
*            System Fatal outs after Upgrade and Conversion Run through Service.
*
* 06/01/09 - CI_10059884
*            Limit record not processed for the contract who's PD Effective
*            Date falling on Today.
*********************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_CONV.COMMON
    $INSERT I_F.COMPANY
    $INSERT I_F.MM.MONEY.MARKET
    $INSERT I_F.CUSTOMER

    DIM SAVE.R.NEW(500)
    MAT SAVE.R.NEW = MAT R.NEW
    SAVE.V = V
    MATPARSE R.NEW FROM MM.REC
    VALUES = DCOUNT(MM.REC,@FM)
    V = VALUES
    LOCATE 'MM' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING FOUND.POS THEN
        GOSUB PROCESS.MM.FILE
    END
    MATBUILD MM.REC FROM R.NEW
    MAT R.NEW = MAT SAVE.R.NEW
    V = SAVE.V
    RETURN
*
**************************
PROCESS.MM.FILE:
**************************
*
    IF MM.REC NE '' THEN
        LOAN.OR.DEPOSIT = ''
        PRINCIPAL.AMOUNT = ''
        CALL MM.CONTYPE (MM.REC<MM.CATEGORY>, LOAN.OR.DEPOSIT, Y.LD.CON.TYPE, "","")
        IF LOAN.OR.DEPOSIT = "LOAN" AND MM.REC<MM.PRIN.INCREASE>[1,1] = '-' AND MM.REC<MM.INCR.EFF.DATE> GE TODAY THEN
            PRINCIPAL.AMOUNT = MM.REC<MM.PRIN.INCREASE> * (-1)
            IF LEN(MM.REC<MM.MATURITY.DATE>) LE "3" THEN
                LIM.EXPIRE = MM.REC<MM.INT.DUE.DATE>
            END ELSE
                LIM.EXPIRE = MM.REC<MM.MATURITY.DATE>
            END
            CHECKFILE1 = "CUSTOMER"
            CHECKFILE1 <2> = EB.CUS.CUSTOMER.LIABILITY
            CHECKFILE1 <3> = ".A.S"
            CUSTOMER.LIABILITY = ""

            CALL DBR(CHECKFILE1 , MM.REC<MM.CUSTOMER.ID> , CUSTOMER.LIABILITY)

            REFERENCE.NO = FIELD(MM.REC<MM.LIMIT.REFERENCE>,".",1)
            SERIAL.NO = FIELD(MM.REC<MM.LIMIT.REFERENCE>,".",2)
            UPDATE.MODE = 'DEL'
            CALL LIMIT.CHECK(CUSTOMER.LIABILITY, MM.REC<MM.CUSTOMER.ID>, REFERENCE.NO, SERIAL.NO, MM.ID, LIM.EXPIRE, MM.REC<MM.CURRENCY>, PRINCIPAL.AMOUNT, "","","","","","", MM.REC<MM.CURR.NO>, "", "U", UPDATE.MODE, RETURN.CODE)
        END
    END
    RETURN
*
END
