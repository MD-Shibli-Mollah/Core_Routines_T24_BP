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

* Version n dd/mm/yy  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-23</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Position
    SUBROUTINE CONV.DX.REP.POS.200506
*----------------------------------------------------------------------------------
* This routine rebuilds DX.REP.POSITION in order to populate the fields(EXCHANGE.CODE
* to OWNBOOK) added to it
* CI_10030532
*
* 01/06/05 - 100030682
*            DX reval fails after upgrade
*
* 07/07/05 - CI_10032058
*            Only convert in lead companies with DX installed.
*
* 23/03/06 - CI_10039962
*          - Upgrade problem in CONV.DX.REP.POS
*---------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
*
    SAVE.ID.COMPANY = ID.COMPANY

    GOSUB INITIALISE          ;* open files etc

* CI_10039962 - Not for Conslidation and Reporting companies
    SEL.CMD = 'SELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'

    COMPANIES = ''
    YSEL = 0
    CALL EB.READLIST(SEL.CMD,COMPANIES,'',YSEL,'')

    LOOP
        REMOVE K.COMPANY FROM COMPANIES SETTING MORE.COMPANIES
    WHILE K.COMPANY:MORE.COMPANIES

        IF K.COMPANY NE ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
        END
        IF R.COMPANY(EB.COM.FINANCIAL.MNE) = R.COMPANY(EB.COM.MNEMONIC) THEN
            LOCATE 'DX' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING POSN ELSE
                POSN = 0
            END
            IF POSN THEN
                GOSUB MAIN.PROCESS
            END
        END

    REPEAT

    IF ID.COMPANY NE SAVE.ID.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)
    END

    RETURN

INITIALISE:
*

    RETURN

MAIN.PROCESS:

    CALL DX.ONLINE.RP.REBUILD

    RETURN
END
