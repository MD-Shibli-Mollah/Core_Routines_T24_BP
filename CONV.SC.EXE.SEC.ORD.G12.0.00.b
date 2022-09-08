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
* <Rating>273</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctOrderExecution
    SUBROUTINE CONV.SC.EXE.SEC.ORD.G12.0.00
*****************************************************************
* 28/08/03 - CI_10012140
* This routine have been writern for the conversion in G12.0.
* While upgrading, the Old CO.CODE was not taken while running
* Conversion (g12.0).
*****************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_F.SC.EXE.SEC.ORDERS

    GOSUB CHECK.MULTI.COMPANY
    RETURN

CHECK.MULTI.COMPANY:
********************
* Select all existing companies

    YFILE.NAME = "F.SC.EXE.SEC.ORDERS"

    FN.COMPANY = 'F.COMPANY'
    F.COMPANY = ''
    CALL OPF(FN.COMPANY,F.COMPANY)

    COMMAND = 'SSELECT F.COMPANY'
    COMPANY.LIST = ''
    CALL EB.READLIST(COMMAND,COMPANY.LIST,'','','')

    LOOP

* Pick up each company one by one

        REMOVE K.COMPANY FROM COMPANY.LIST SETTING END.OF.COMPANIES
    WHILE K.COMPANY:END.OF.COMPANIES

* Find out if SC product is installed in this company.
* If not, loop to next company.

        APP.LIST = ''
        READV APP.LIST FROM F.COMPANY,K.COMPANY,EB.COM.APPLICATIONS ELSE CONTINUE
        LOCATE 'SC' IN APP.LIST<1,1> SETTING FOUND ELSE CONTINUE

* Get the mnemonic of the company

        READV MNEMONIC FROM F.COMPANY,K.COMPANY,EB.COM.MNEMONIC THEN

            FILE.NAME = 'F':MNEMONIC:'.':YFILE.NAME[3,99]

            FN.SC.EXE.SEC.ORDERS = FILE.NAME
            OPEN FN.SC.EXE.SEC.ORDERS TO F.SC.EXE.SEC.ORDERS ELSE OPEN.EXE.ERR = 1

        END
        GOSUB FOR.EACH.COMPANY

    REPEAT
    RETURN
*
*******************************************************************
FOR.EACH.COMPANY:
*****************

    SEL.CMD = 'SELECT ':FN.SC.EXE.SEC.ORDERS

    ID.POS = ''
    CALL EB.READLIST(SEL.CMD,ID.LIST,'','',ERROR.CODE)
    LOOP
        REMOVE SC.EXE.ID FROM ID.LIST SETTING ID.POS
    WHILE SC.EXE.ID:ID.POS DO
        ER = ''
        CALL F.READ(FN.SC.EXE.SEC.ORDERS,SC.EXE.ID,R.SC.EXE,F.SC.EXE.SEC.ORDERS,ER)
        R.SC.EXE<43> = ID.COMPANY
        CALL F.WRITE(FN.SC.EXE.SEC.ORDERS,SC.EXE.ID,R.SC.EXE)
        CALL JOURNAL.UPDATE(SC.EXE.ID)
    REPEAT
    RETURN

END

