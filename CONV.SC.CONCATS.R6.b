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
* <Rating>-51</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoFoundation
    SUBROUTINE CONV.SC.CONCATS.R6
*--------------------------------------------------------------------
* 01/12/2006 - GLOBUS_CI_10045849
*              Crash occurs when COB ran after upgrade had been done from R05 to R07
*
* 14/05/2008 - GLOBUS_CI_10055383
*              In Multicompany environment,routine doesn't update the SC.SETTLE.DATE.CONTROL id
*              properly in all companies.The routine only convert the SC.SETTL.DATE.CONTROL
*              record id of BNK company and leaves other company ids unchanged.
*--------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE

    GOSUB INITIALISE

    SELECT.CMD = 'SELECT ':FN.COMPANY:' WITH CONSOLIDATION.MARK EQ "N"'
    CALL EB.READLIST(SELECT.CMD,COMPANY.ID.LIST,'','','')
    NO.COMPS = DCOUNT(COMPANY.ID.LIST,@FM)

    FOR J = 1 TO NO.COMPS
        COMP.ID = COMPANY.ID.LIST<J>
        CALL LOAD.COMPANY(COMP.ID)
        GOSUB OPEN.FILE
        GOSUB MAIN.PROCESS
    NEXT J
    CALL LOAD.COMPANY(SAVE.ID.COMPANY)

    RETURN
******************
INITIALISE:
******************
    SELECT.CMD = ''
    COMPANY.ID.LIST = ''
    J = '' ; NO.COMPS = ''
    SAVE.ID.COMPANY = ID.COMPANY

    FN.COMPANY = 'F.COMPANY'
    F.COMPANY = ''
    CALL OPF(FN.COMPANY,F.COMPANY)

    RETURN
*********
OPEN.FILE:
*********

    FN.SETTL = 'F.SC.SETTL.DATE.CONTROL'
    F.SETTL = ''
    CALL OPF(FN.SETTL,F.SETTL)

    FN.SDC = 'F.SC.DELIV.CONTROL'
    F.SDC = ''
    CALL OPF(FN.SDC,F.SDC)

    RETURN

************
MAIN.PROCESS:
************
    FN.CONV.FILE = FN.SETTL
    F.CONV.FILE = F.SETTL
    SUB.PROCESS = 1
    GOSUB PROCESS

    FN.CONV.FILE = FN.SDC
    F.CONV.FILE = F.SDC
    SUB.PROCESS = 2
    GOSUB PROCESS

    RETURN

*****************
PROCESS:
*****************

    SEL.CMD = 'SELECT ':FN.CONV.FILE
    SEL.LIST = ''
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'','','')

    LOOP
        REMOVE VALUE.DATE FROM SEL.LIST SETTING FOUND
    WHILE VALUE.DATE:FOUND
        ER = '' ; R.SETTL = ''
        READ R.SETTL FROM F.CONV.FILE,VALUE.DATE ELSE
        END
        NO.OF.TXNS = 1
        LOOP
        WHILE R.SETTL<2,NO.OF.TXNS>
            RECORD = ''
            FOR I = 1 TO 4
                RECORD<I> = R.SETTL<I,NO.OF.TXNS>
            NEXT I
            IF SUB.PROCESS = 1 THEN
                SETTL.ID = VALUE.DATE:'*':RECORD<2>
            END
            ELSE
                SETTL.ID = VALUE.DATE:'*':RECORD<1>
            END
            WRITE RECORD TO F.CONV.FILE,SETTL.ID
            NO.OF.TXNS += 1
        REPEAT
        DELETE F.CONV.FILE,VALUE.DATE
    REPEAT

    RETURN

END
