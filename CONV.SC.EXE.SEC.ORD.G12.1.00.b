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
* <Rating>326</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctOrderExecution
    SUBROUTINE CONV.SC.EXE.SEC.ORD.G12.1.00
*****************************************************************
* This is a Conversion Program to read each record from
* SC.EXE.SEC.ORDERS live file and write it in to the
* SC.EXE.SEC.ORDERS$NAU file and delete the live file record.

*GLOBUS_EN_10000197 - 30/09/01
*
* 04/02/04 - CI_10017119
*            Field names replaced with corresponding field numbers.
*
*****************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SC.EXE.SEC.ORDERS
    $INSERT I_F.COMPANY
*
******************************************************************

    GOSUB INITIALISE
    GOSUB MAIN.PROCESS
    RETURN

******************************************************************
INITIALISE:
***********
* Variable Initialisation
    SC.EXE.ID = '' ; CNT = '' ; ID.POS = '' ; SEL.CMD = ''
    ID.LIST = '' ; ERROR.CODE = '' ; ARRAY.SIZE = ''
    ARRAY.SIZE = SC.ESO.AUDIT.DATE.TIME ; TOTAL.CUST = ''
*
    DIM R.SC.EXE(ARRAY.SIZE) ; DIM R.SC.EXE$NAU(ARRAY.SIZE)
    MAT R.SC.EXE$NAU = '' ; MAT R.SC.EXE = ''
*
    RETURN
*********************************************************
SUB.PROCESS:
*************
    SEL.CMD = 'SELECT ':FN.SC.EXE.SEC.ORDERS
    CALL EB.READLIST(SEL.CMD,ID.LIST,'','',ERROR.CODE)
    LOOP
        REMOVE SC.EXE.ID FROM ID.LIST SETTING ID.POS
    WHILE SC.EXE.ID:ID.POS DO
        ER = ''
        CALL F.MATREAD(FN.SC.EXE.SEC.ORDERS,SC.EXE.ID,MAT R.SC.EXE,ARRAY.SIZE,F.SC.EXE.SEC.ORDERS,ER)
        GOSUB ASSIGN.VALUE
        CALL F.MATWRITE(FN.SC.EXE.SEC.ORDERS$NAU,SC.EXE.ID,MAT R.SC.EXE$NAU,ARRAY.SIZE)
        CALL F.DELETE(FN.SC.EXE.SEC.ORDERS,SC.EXE.ID)
        CALL JOURNAL.UPDATE(SC.EXE.ID)
    REPEAT
    RETURN
*
******************************************************************
ASSIGN.VALUE:
************
* This subroutine assigns the live file record to NAU file
* for each SC.EXE.SEC.ORDERS record.
*
* CI_10017119 - S
    R.SC.EXE$NAU(1) = R.SC.EXE(1)
    R.SC.EXE$NAU(2) = R.SC.EXE(2)
    R.SC.EXE$NAU(3) = R.SC.EXE(3)
    R.SC.EXE$NAU(4) = R.SC.EXE(4)
    R.SC.EXE$NAU(5) = R.SC.EXE(5)
    R.SC.EXE$NAU(6) = R.SC.EXE(6)
    R.SC.EXE$NAU(7) = R.SC.EXE(7)
    R.SC.EXE$NAU(8) = R.SC.EXE(8)
*
    GOSUB ASSIGN.CUST.NOMINAL.AND.PRICE
*
    R.SC.EXE$NAU(17) = R.SC.EXE(11)
    R.SC.EXE$NAU(18) = R.SC.EXE(12)
    R.SC.EXE$NAU(19) = R.SC.EXE(13)
    R.SC.EXE$NAU(21) = R.SC.EXE(14)
    R.SC.EXE$NAU(22) = R.SC.EXE(15)
    R.SC.EXE$NAU(23) = R.SC.EXE(16)
    R.SC.EXE$NAU(24) = R.SC.EXE(17)
    R.SC.EXE$NAU(31) = R.SC.EXE(18)
    R.SC.EXE$NAU(33)<1,1> = R.SC.EXE(19)
    R.SC.EXE$NAU(34)<1,1> = R.SC.EXE(20)
    R.SC.EXE$NAU(35)<1,1> = R.SC.EXE(21)
    R.SC.EXE$NAU(36)<1,1> = R.SC.EXE(22)
    R.SC.EXE$NAU(37)<1,1> = R.SC.EXE(23)
    R.SC.EXE$NAU(39)<1,1> = R.SC.EXE(24)
    R.SC.EXE$NAU(40)<1,1> = R.SC.EXE(25)
    R.SC.EXE$NAU(41)<1,1> = R.SC.EXE(26)
    R.SC.EXE$NAU(42)<1,1> = R.SC.EXE(27)
    R.SC.EXE$NAU(43)<1,1> = R.SC.EXE(28)
    R.SC.EXE$NAU(44)<1,1> = R.SC.EXE(29)
    R.SC.EXE$NAU(46)<1,1> = R.SC.EXE(30)
    R.SC.EXE$NAU(47)<1,1> = R.SC.EXE(31)
    R.SC.EXE$NAU(48)<1,1> = R.SC.EXE(32)
    R.SC.EXE$NAU(49)<1,1> = R.SC.EXE(33)
    R.SC.EXE$NAU(50)<1,1> = R.SC.EXE(34)
    R.SC.EXE$NAU(45)<1,1> = R.SC.EXE(35)
    R.SC.EXE$NAU(51) = R.SC.EXE(36)
    R.SC.EXE$NAU(52) = R.SC.EXE(37)
    R.SC.EXE$NAU(53) = R.SC.EXE(38)
    R.SC.EXE$NAU(54) = R.SC.EXE(39)
    R.SC.EXE$NAU(55) = R.SC.EXE(40)
    R.SC.EXE$NAU(56) = R.SC.EXE(41)
    R.SC.EXE$NAU(57) = R.SC.EXE(42)
    R.SC.EXE$NAU(58) = R.SC.EXE(43)
    R.SC.EXE$NAU(64) = R.SC.EXE(49)
    R.SC.EXE$NAU(65) = R.SC.EXE(50)
    R.SC.EXE$NAU(66) = 'IHLD'
    R.SC.EXE$NAU(67) = R.SC.EXE(52)
    R.SC.EXE$NAU(68) = R.SC.EXE(53)
    R.SC.EXE$NAU(69) = R.SC.EXE(54)
    R.SC.EXE$NAU(70) = R.SC.EXE(55)
    R.SC.EXE$NAU(71) = R.SC.EXE(56)
    R.SC.EXE$NAU(72) = R.SC.EXE(57)
    R.SC.EXE$NAU(73) = R.SC.EXE(58)
    R.SC.EXE$NAU(74) = R.SC.EXE(59)
*
* CI_10017119 - E
    RETURN
******************************************************************
ASSIGN.CUST.NOMINAL.AND.PRICE:
******************************
    TOTAL.CUST = DCOUNT(R.SC.EXE(7),VM)
    FOR CNT = 1 TO TOTAL.CUST
        R.SC.EXE$NAU(9)<1,CNT,1> = R.SC.EXE(9)<1,CNT>
        R.SC.EXE$NAU(10)<1,CNT,1> = R.SC.EXE(10)<1,CNT>
    NEXT CNT
*
    RETURN
******************************************************************
MAIN.PROCESS:
* Open Files
* Select all existing companies
    YFILE.NAME = "F.SC.EXE.SEC.ORDERS"

    FN.COMPANY = 'F.COMPANY'
    F.COMPANY = ''
    CALL OPF(FN.COMPANY,F.COMPANY)

    COMMAND = 'SSELECT F.COMPANY'
    COMPANY.LIST = ''
    CALL EB.READLIST(COMMAND,COMPANY.LIST,'','','')

* Perform the conversion for each company

    LOOP

* Pick up each company one by one

        REMOVE K.COMPANY FROM COMPANY.LIST SETTING END.OF.COMPANIES
    WHILE K.COMPANY:END.OF.COMPANIES


* Find out if SC product is installed in this company.
* If not, loop to next company.

        READV APP.LIST FROM F.COMPANY,K.COMPANY,EB.COM.APPLICATIONS ELSE CONTINUE
        LOCATE 'SC' IN APP.LIST<1,1> SETTING FOUND ELSE CONTINUE


* Get the mnemonic of the company

        READV MNEMONIC FROM F.COMPANY,K.COMPANY,EB.COM.MNEMONIC THEN

            FILE.NAME = 'F':MNEMONIC:'.':YFILE.NAME[3,99]

            FN.SC.EXE.SEC.ORDERS = FILE.NAME
            OPEN FN.SC.EXE.SEC.ORDERS TO F.SC.EXE.SEC.ORDERS ELSE OPEN.EXE.ERR = 1
            FN.SC.EXE.SEC.ORDERS$NAU = FILE.NAME : "$NAU"
            F.SC.EXE.SEC.ORDERS$NAU = ''
            OPEN FN.SC.EXE.SEC.ORDERS$NAU TO F.SC.EXE.SEC.ORDERS$NAU ELSE OP.NAU.ERR = 1
            GOSUB SUB.PROCESS
        END
*
    REPEAT
    RETURN
*
*******************************************************************
END
