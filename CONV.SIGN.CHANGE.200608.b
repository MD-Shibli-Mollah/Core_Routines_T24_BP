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
* <Rating>-33</Rating>
*-----------------------------------------------------------------------------
* Version n dd/mm/yy  GLOBUS Release No. 200508 30/06/05
*
    $PACKAGE RE.Consolidation
    SUBROUTINE CONV.SIGN.CHANGE.200608
*-----------------------------------------------------------------------------
* Build STATIC.CHANGE.TODAY with possible sign change.
*-----------------------------------------------------------------------------
* Modification History:
*
* 20/12/04 - EN_10002974
*            Update STATIC.CHANGE.TODAY with possible sign change

*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT

* Equate field numbers to position manually, do no use $INSERT
    EQU SUFFIXES TO 3
    EQU FILE.CONTROL.CLASS TO 6

    SAVE.ID.COMPANY = ID.COMPANY

*
    COMMAND = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
    COMPANY.LIST = ''
    CALL EB.READLIST(COMMAND, COMPANY.LIST, '', '', '')

    LOOP
        REMOVE K.COMPANY FROM COMPANY.LIST SETTING MORE.COMPANIES
    WHILE K.COMPANY:MORE.COMPANIES

        IF K.COMPANY NE ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
        END

        GOSUB INITIALISE

        GOSUB SELECT.ECB

        IF SEL.LIST # '' THEN
            GOSUB PROCESS.ECB
        END

    REPEAT

    IF ID.COMPANY NE SAVE.ID.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)
    END

    RETURN

*---------*
INITIALISE:
*---------*
* open files etc


    FN.EB.CONTRACT.BALANCES = 'F.EB.CONTRACT.BALANCES'
    F.EB.CONTRACT.BALANCES = ''
    CALL OPF(FN.EB.CONTRACT.BALANCES,F.EB.CONTRACT.BALANCES)

    FN.STATIC.CHANGE.TODAY = 'F.STATIC.CHANGE.TODAY'
    F.STATIC.CHAGE.TODAY = ''
    CALL OPF(FN.STATIC.CHANGE.TODAY,F.STATIC.CHANGE.TODAY)

    RETURN

*----------*
SELECT.ECB:
*---------*

    EX.STMT = 'SELECT ':FN.EB.CONTRACT.BALANCES

    SEL.LIST = "" ; SYS.ERROR = ""
    NO.OF.RECS = ''

    CALL EB.READLIST(EX.STMT, SEL.LIST, "", NO.OF.RECS, SYS.ERROR)

    RETURN

*----------*
PROCESS.ECB:
*----------*

    LOOP
        REMOVE ECB.ID FROM SEL.LIST SETTING MORE

    WHILE ECB.ID:MORE DO


        R.ACCOUNT.EXPOSURE = ''

        READ R.ECB FROM F.EB.CONTRACT.BALANCES, ECB.ID ELSE
            CONTINUE
        END

        IF R.ECB<17> = 'Y' THEN
            R.SCT = ''
            R.SCT<1> = R.ECB<20>
            R.SCT<2> = R.ECB<14>

            WRITE R.SCT ON F.STATIC.CHANGE.TODAY,ECB.ID

        END
    REPEAT

    RETURN


END
