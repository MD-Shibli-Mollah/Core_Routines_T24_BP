* @ValidationCode : MjotNDQ1MTg4NjEwOkNwMTI1MjoxNTUyMzg2MzAzNTQ2OnNyZGVlcGlnYTotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxOTAyLjIwMTkwMTExLTAzNDc6LTE6LTE=
* @ValidationInfo : Timestamp         : 12 Mar 2019 15:55:03
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : srdeepiga
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201902.20190111-0347
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-177</Rating>
*-----------------------------------------------------------------------------
*
* 25/03/02 - BG_100000775
*            Fixing the problem of the enquiry not displaying
*            all subvalues (all lines) of the associated
*            Diary item of a LD contract.
*
* 11/08/06 - CI_10043299
*            Enquiry does not display the diary events when DIARY.ACTION
*            defined on a single line(one subvalue).
*
* 27/05/08 - BG_100018573
*            reduce compiler ratings
*
* 11/08/10 - Task 60363
*            Change the reads to Customer to use the Customer
*            Service api calls
*
* 29/11/2018 - Enhancement: 2822515
*              Task :  2847828
*              Componentisation changes.
*
*************************************************************************
$PACKAGE LD.ModelBank
SUBROUTINE E.LD.DIARY.ENQ(YID.LIST)
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.LD.LOANS.AND.DEPOSITS
    $INSERT I_F.LMM.SCHEDULES
    $INSERT I_F.DEPT.ACCT.OFFICER
    $INSERT I_CustomerService_NameAddress
*
    IF (INDEX(D.FIELDS,'CONTRACT.NO',2)) THEN
        RETURN
    END
    IF (INDEX(D.FIELDS,'CUSTOMER.NO',2)) THEN
        RETURN
    END
    IF (INDEX(D.FIELDS,'ACCOUNT.OFFICER',2)) THEN
        RETURN
    END

    GOSUB INITIALISE

    GOSUB SELECT.LDS

    IF NOT(SEL.LIST) THEN
        RETURN
    END

    GOSUB PROCESS

    SORT.N = DCOUNT(SORT.ARRAY,@FM)
    SORT.ARRAY1 = ''
    YID.LIST = ''
    SORT.ARRAY1 = ''
    FOR XX = 2 TO SORT.N      ;* CI_10043299 S/E
        SORT.REC = SORT.ARRAY<XX>
        SORT.ARRAY1<-1> = SORT.REC
    NEXT XX

    YID.LIST<-1> = SORT.ARRAY1

RETURN
*

INITIALISE:
***********
*
    GOSUB OPENFILES ;* BG_100018573 S/E

*
    LD.REC.ARRAY = ''
    SORT.ARRAY = ''
    SORT.ARRAY<-1> = '***'
    SORT.ARR1 = ''
    SORT.ARR2 = ''
*
    ARRAY1 = ''     ;* Account Officer
    TEMP.CNT = ''
    SORT.ARR = ''
    SORT.ARR<-1> = '**'
    ARRAY2 = ''     ;* LDs
    ARRAY3 = ''     ;* Diary Actions
*
    CUSTOMER.NO = ''
    CONTRACT.NO = ''
    CONTRACT.OPERAND = ''
    TEMP.OPERAND = ''
    USER.START.DATE = ''
    DATE.OPERAND = ''

    IGGI = D.LOGICAL.OPERANDS
    TEXT = LOWER(D.FIELDS)
*      CALL OVE
    TEXT = D.RANGE.AND.VALUE
*      CALL OVE
    LOCATE 'CUSTOMER.NO' IN D.FIELDS<1> SETTING C.POS ELSE
        C.POS = ''
    END
    CUSTOMER.NO = D.RANGE.AND.VALUE<C.POS>
    LOCATE 'CONTRACT.NO' IN D.FIELDS<1> SETTING L.POS ELSE
        L.POS = ''
    END
    CONTRACT.NO = D.RANGE.AND.VALUE<L.POS>
    TEMP.OPERAND = D.LOGICAL.OPERANDS<L.POS>
    IF TEMP.OPERAND EQ 1 THEN
        CONTRACT.OPERAND = 'EQ'
    END ELSE
        CONTRACT.OPERAND = 'LIKE'
    END
    LOCATE 'ACCOUNT.OFFICER' IN D.FIELDS<1> SETTING A.POS ELSE
        A.POS = ''
    END
    ACCOUNT.OFFICER = D.RANGE.AND.VALUE<A.POS>
    LOCATE 'EVENT.DATE' IN D.FIELDS<1> SETTING D.POS ELSE
        D.POS = ''
    END
    USER.START.DATE = D.RANGE.AND.VALUE<D.POS>
    TEMP.OPERAND = D.LOGICAL.OPERANDS<D.POS>
    DATE.OPERAND = OPERAND.LIST<TEMP.OPERAND>

    GOSUB GEN.DATES


*
RETURN
*********
OPENFILES:
*********

    FN.LD = 'F.LD.LOANS.AND.DEPOSITS'
    FV.LD = ''
    CALL OPF(FN.LD,FV.LD)
*
    FN.LMM.CUSTOMER = 'F.LMM.CUSTOMER'
    FV.LMM.CUSTOMER = ''
    CALL OPF(FN.LMM.CUSTOMER,FV.LMM.CUSTOMER)
*
    FN.ACCOUNT.OFFICER = 'F.DEPT.ACCT.OFFICER'
    FV.ACCOUNT.OFFICER = ''
    CALL OPF(FN.ACCOUNT.OFFICER, FV.ACCOUNT.OFFICER)
*
    FN.LMM.SCHEDULES = 'F.LMM.SCHEDULES'
    FV.LMM.SCHEDULES = ''
    CALL OPF(FN.LMM.SCHEDULES, FV.LMM.SCHEDULES)

RETURN
SELECT.LDS:
***********
    SEL.CMD = ''
    SEL.LIST = ''
    NO.REC = ''
    ERR1 = ''
    NO.OF.CUSTOMER = ''
    CUS.SEL = ''
    NO.OF.LDS = ''
    LD.SEL = ''
    NO.OF.ACC.OFFICERS = ''
    ACC.SEL = ''

    IF CUSTOMER.NO THEN
        NO.OF.CUSTOMER = DCOUNT(CUSTOMER.NO,@SM)
        FOR CUS.I = 1 TO NO.OF.CUSTOMER
            CUS.SEL := ' CUSTOMER.NO EQ ':CUSTOMER.NO<1,1,CUS.I>:' OR '
        NEXT CUS.I
        CUS.LEN = LEN(CUS.SEL)
        CUS.SEL = CUS.SEL[1,CUS.LEN-3]
        CUS.SEL = ' (':CUS.SEL:' ) '
    END

    IF CONTRACT.NO THEN
        NO.OF.LDS = DCOUNT(CONTRACT.NO,@SM)
        FOR LD.I = 1 TO NO.OF.LDS
            LD.SEL := ' @ID ':CONTRACT.OPERAND:' ':CONTRACT.NO<1,1,LD.I>:' OR '
        NEXT LD.I
        LD.LEN = LEN(LD.SEL)
        LD.SEL = LD.SEL[1,LD.LEN-3]
        LD.SEL = ' (':LD.SEL:' ) '
    END


    IF ACCOUNT.OFFICER THEN
        NO.OF.ACC.OFFICERS = DCOUNT(ACCOUNT.OFFICER,@SM)
        FOR ACC.I = 1 TO NO.OF.ACC.OFFICERS
            ACC.SEL := ' MIS.ACCT.OFFICER EQ ':ACCOUNT.OFFICER<1,1,ACC.I>:' OR '
        NEXT ACC.I
        ACC.LEN = LEN(ACC.SEL)
        ACC.SEL = ACC.SEL[1,ACC.LEN-3]
        ACC.SEL = ' (':ACC.SEL:' ) '
    END

    SEL.CMD = ''

    IF CUS.SEL THEN
        SEL.CMD := CUS.SEL
    END

    IF LD.SEL THEN
        IF SEL.CMD THEN
            SEL.CMD := 'AND ':LD.SEL
        END ELSE
            SEL.CMD = LD.SEL
        END
    END

    IF ACC.SEL THEN
        IF SEL.CMD THEN
            SEL.CMD := 'AND' :ACC.SEL
        END ELSE
            SEL.CMD = ACC.SEL
        END
    END

    IF SEL.CMD THEN
        SEL.CMD = 'SELECT ':FN.LD:' WITH ':SEL.CMD
    END ELSE
        SEL.CMD = 'SELECT ':FN.LD
    END

    IF SEL.CMD THEN
        CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.REC,ERR1)
    END

    IF SEL.LIST THEN
        TEMP.LIST = ''
        ID.POS = ''
        SEL.LEN = DCOUNT(SEL.LIST,@FM)
        FOR LIST.I = 1 TO SEL.LEN
            TEMP.ID = SEL.LIST<LIST.I>
            LOCATE TEMP.ID IN TEMP.LIST<1> BY 'AR' SETTING ID.POS ELSE
                INS TEMP.ID BEFORE TEMP.LIST<ID.POS>
            END
        NEXT LIST.I

        SEL.LIST = TEMP.LIST


    END
RETURN

PROCESS:
********
*
    LD.LIST = SEL.LIST
    LD.REC.ID = ''
    LD.POS = ''
    LOOP
        REMOVE LD.REC.ID FROM LD.LIST SETTING LD.POS
    WHILE LD.REC.ID : LD.POS
*  Read the LD record
        LD.REC = ''
        LD.ERR = ''
        CALL F.READ(FN.LD,LD.REC.ID,LD.REC,FV.LD,LD.ERR)
        IF LD.REC THEN
            CUS.ID = LD.REC<LD.CUSTOMER.ID>
            ACC.OFFICER = LD.REC<LD.MIS.ACCT.OFFICER>
            GOSUB CHECK.EVENTS
        END
    REPEAT
*
RETURN
*
CHECK.EVENTS:
*************

    EVENT.DATE = ''
    EVENT.JUL.DATE = ''
    DATE.POS = ''
    D.LIST = DATE.LIST
    LOOP
        REMOVE EVENT.DATE FROM D.LIST SETTING DATE.POS
    WHILE EVENT.DATE : DATE.POS
        CALL JULDATE(EVENT.DATE,EVENT.JUL.DATE)
        LMM.SCHEDULES.ID = LD.REC.ID:EVENT.JUL.DATE:'00'
        SCHEDULES.REC = ''
        SCHEDULES.ERR = ''
        DIARY.ARR = ''
        CALL F.READ(FN.LMM.SCHEDULES,LMM.SCHEDULES.ID,SCHEDULES.REC,FV.LMM.SCHEDULES,SCHEDULES.ERR)

        GOSUB SCHEDULES.BALANCES.REC    ;* BG_100018573 S/E
    REPEAT
*
RETURN
**********************************************************
SCHEDULES.BALANCES.REC:
*---------------------
    IF SCHEDULES.REC THEN
        IF SCHEDULES.REC<LD9.TYPE.D> EQ 'Y' THEN
            DIARY.ARR = ''
            NO.OF.DIARY.ACTN = DCOUNT(SCHEDULES.REC<LD9.DIARY.ACTION>,@VM)
* BG_100000775 S
            ACTION = 1
            GOSUB INSERT.DIARY.ACTION
            FOR ACTION = NO.OF.DIARY.ACTN TO 2 STEP -1
                GOSUB INSERT.DIARY.ACTION
* BG_100000775 E
            NEXT ACTION
        END
    END
RETURN

* BG_100000775 S
INSERT.DIARY.ACTION:
* BG_100000775 E
    DIARY.ARR = SCHEDULES.REC<LD9.DIARY.ACTION,ACTION>
    SORT.KEY = EVENT.DATE:'*':ACC.OFFICER:'*':LD.REC.ID
    LOCATE SORT.KEY IN SORT.ARR<1> BY "AR" SETTING POSN THEN
        INS SORT.KEY BEFORE SORT.ARR<POSN>
        INS ENQ.START.DATE:'*':EVENT.DATE:'***********':DIARY.ARR BEFORE SORT.ARRAY<POSN+1>
        TEMP.CNT +=1
    END ELSE
        LD.REQ.REC = LD.REC.ID
        CUS.ID = LD.REC<LD.CUSTOMER.ID>
        customerKey = CUS.ID
        prefLang = LNGG
        customerNameAddress = ''
        CALL CustomerService.getNameAddress(customerKey,prefLang,customerNameAddress)
        CUS.NAME = customerNameAddress<NameAddress.shortName>
        LD.REQ.REC = LD.REC.ID:'*':LD.REC<LD.CATEGORY>:'*':LD.REC<LD.CURRENCY>
        LD.REQ.REC := '*':CUS.NAME:'*':CUS.ID:'*':LD.REC<LD.VALUE.DATE>
* IGGY
        OUTS.AMT = LD.REC<LD.AMOUNT>
        CALL EB.ROUND.AMOUNT(LD.REC<LD.CURRENCY>,OUTS.AMT,1,'')
* IGGY
        LD.REQ.REC := '*':LD.REC<LD.FIN.MAT.DATE>:'*':OUTS.AMT        ;* IGGY
        INS SORT.KEY BEFORE SORT.ARR<POSN>
        SORT.KEY1 = EVENT.DATE:'*':ACC.OFFICER
        SORT.INSERT = EVENT.DATE:'*':ACC.OFFICER:'*':LD.REQ.REC:'*':DIARY.ARR
        LOCATE SORT.KEY1 IN SORT.ARR1<1> SETTING POSM THEN
            SORT.INSERT = '**':LD.REQ.REC:'*':DIARY.ARR
        END ELSE
            SORT.KEY2 = EVENT.DATE
            LOCATE SORT.KEY2 IN SORT.ARR2<1> SETTING POSL THEN
                SORT.INSERT = '*':ACC.OFFICER:'*':LD.REQ.REC:'*':DIARY.ARR
            END ELSE
                INS SORT.KEY2 BEFORE SORT.ARR2<1>
            END
            INS SORT.KEY1 BEFORE SORT.ARR1<1>
        END
        INS ENQ.START.DATE:'*':EVENT.DATE:'*':SORT.INSERT BEFORE SORT.ARRAY<POSN>
        TEMP.CNT +=1
* BG_100000775 S
    END
RETURN
* BG_100000775 E

GEN.DATES:
**********
    NO.OF.DAYS.REQ = 7

    DATE.LIST = ''

    ENQ.START.DATE = TODAY

    IF USER.START.DATE THEN
        GOSUB CHECK.DATE.OPERAND        ;* BG_100018573 S/E
    END ELSE
        START.DATE = TODAY
        FOR I = 1 TO 7
            DATE.LIST<-1> = START.DATE
            CALL CDT('',START.DATE,'+1C')
        NEXT I
    END

RETURN
***********************************************************
CHECK.DATE.OPERAND:


    IF DATE.OPERAND EQ 'EQ' THEN
        START.DATE = USER.START.DATE<1,1,1>
        DATE.LIST<-1> = START.DATE
        ENQ.START.DATE = START.DATE
        RETURN
    END
    IF DATE.OPERAND EQ 'RG' THEN
        START.DATE = USER.START.DATE<1,1,1>
        END.DATE = USER.START.DATE<1,1,2>
        ENQ.START.DATE = START.DATE
        IF START.DATE LE END.DATE THEN
            LOOP
                DATE.LIST<-1> = START.DATE
                CALL CDT('',START.DATE,'+1C')
            WHILE START.DATE LE END.DATE
            REPEAT
        END
        RETURN
    END
    IF DATE.OPERAND EQ 'LT' THEN
        START.DATE = TODAY
        END.DATE = USER.START.DATE<1,1,1>
        IF START.DATE LT END.DATE THEN
            LOOP
                DATE.LIST<-1> = START.DATE
                CALL CDT('',START.DATE,'+1C')
            WHILE START.DATE LT END.DATE
            REPEAT
        END
        RETURN
    END
    IF DATE.OPERAND EQ 'LE' THEN
        START.DATE = TODAY
        END.DATE = USER.START.DATE<1,1,1>
        IF START.DATE LE END.DATE THEN
            LOOP
                DATE.LIST<-1> = START.DATE
                CALL CDT('',START.DATE,'+1C')
            WHILE START.DATE LE END.DATE
            REPEAT
        END
        RETURN
    END
RETURN
END
