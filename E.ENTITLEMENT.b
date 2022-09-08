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
* <Rating>347</Rating>
*-----------------------------------------------------------------------------
* Version 2 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*
    $PACKAGE SC.SccReports

    SUBROUTINE E.ENTITLEMENT(ENT.LIST)
*
* This routine is called by the enquiry ENTL.FULL.ENQ and returns all
* the Entitlement IDS associated with a single DIARY record. These
* Entitlement records could either be on the unauthorised or
* authoirsed files.
*-----------------------------------------------------------------------------------------
* 02/08/07 - CI_10050669
*            Incorrect display of FULL.ENTL enquiry
* 
* 19/1/16 - 1322379
*           Incorporation
*
*  -----------------------------------------------------------------------------------------

    $USING EB.DataAccess
    $USING SC.SccEventCapture
    $USING SC.SccEntitlements
    $USING EB.SystemTables
    $USING EB.Reports

    GOSUB INITIALISE
*
    GOSUB SELECT.DIARY
*
    LOOP
        REMOVE ID.DIARY FROM DIARY.LIST SETTING MORE
    WHILE ID.DIARY:MORE DO
        GOSUB SETUP.ENT.LIST
    REPEAT
*
    RETURN          ;* To Enquiry
*
*----------
INITIALISE:
*----------
*
    DIARY.FILE = 'F.DIARY'
    F.DIARY = ''
    EB.DataAccess.Opf(DIARY.FILE,F.DIARY)
*
    ENT.LIST = ''
    LOCATE 'DIARY.ID' IN EB.Reports.getDFields()<1> SETTING ID.POS ELSE NULL
    DIARY.OPERAND = EB.Reports.getDLogicalOperands()<ID.POS>
    REC = ''
    LOCATE "EX.DATE" IN EB.Reports.getDFields()<1> SETTING EX.DATE.POS ELSE EX.DATE.POS = ''
    EX.DATE.OPERAND = EB.Reports.getDLogicalOperands()<EX.DATE.POS>
    LOCATE "PAY.DATE" IN EB.Reports.getDFields()<1> SETTING PAY.DATE.POS ELSE PAY.DATE.POS = ''
    PAY.DATE.OPERAND = EB.Reports.getDLogicalOperands()<PAY.DATE.POS>
    LOCATE "SECURITY.NO" IN EB.Reports.getDFields()<1> SETTING SEC.POS ELSE SEC.POS = ''
    SEC.OPERAND = EB.Reports.getDLogicalOperands()<SEC.POS>
*
    RETURN
*
*------------
SELECT.DIARY:
*------------
*
    SEL.CMD = 'SELECT ':DIARY.FILE      ;* CI_10050669 S/E
    COMMND = ''     ;* CI_10050669 S/E
    IF DIARY.OPERAND THEN
        DIARY.DATA = EB.Reports.getDRangeAndValue()<ID.POS>
        IF DIARY.DATA = 'ALL' ELSE
            OPERAND = DIARY.OPERAND
            GOSUB CONVERT.OPERAND
            COMMND := ' WITH @ID ':OPERAND:' ':DIARY.DATA   ;* CI_10050669 S/E
        END
    END
    IF EX.DATE.OPERAND THEN
        EX.DATE.DATA = EB.Reports.getDRangeAndValue()<EX.DATE.POS>
        OPERAND = EX.DATE.OPERAND
        GOSUB CONVERT.OPERAND
        IF COMMND THEN        ;* CI_10050669 S
            COMMND := ' AND WITH EX.DATE ':OPERAND:' ':EX.DATE.DATA
        END ELSE
            COMMND := ' WITH EX.DATE ':OPERAND:' ':EX.DATE.DATA
        END         ;* CI_10050669 E
    END
    IF PAY.DATE.OPERAND THEN
        PAY.DATE.DATA = EB.Reports.getDRangeAndValue()<PAY.DATE.POS>
        OPERAND = PAY.DATE.OPERAND
        GOSUB CONVERT.OPERAND
        IF COMMND THEN        ;* CI_10050669 S
            COMMND := ' AND WITH PAY.DATE ':OPERAND:' ':PAY.DATE.DATA
        END ELSE
            COMMND := ' WITH PAY.DATE ':OPERAND:' ':PAY.DATE.DATA
        END         ;* CI_10050669 E
    END
    IF SEC.OPERAND THEN
        SEC.DATA = EB.Reports.getDRangeAndValue()<SEC.POS>
        IF SEC.DATA EQ 'ALL' ELSE
            OPERAND = SEC.OPERAND
            GOSUB CONVERT.OPERAND
            IF COMMND THEN    ;* CI_10050669 S
                COMMND := ' AND WITH SECURITY.NO ':OPERAND:' ':SEC.DATA
            END ELSE
                COMMND := ' WITH SECURITY.NO ':OPERAND:' ':SEC.DATA
            END     ;* CI_10050669 E
        END
    END

    SEL.CMD := COMMND         ;* CI_10050669 S/E
    DIARY.LIST = ''
    SELECTED = ''
    SYSTEM.RET.CODE = ''
    EB.DataAccess.Readlist(SEL.CMD,DIARY.LIST,'',SELECTED,SYSTEM.RET.CODE)  ;* CI_10050669 S/E
*
    RETURN
*
*---------------
CONVERT.OPERAND:
*---------------
*
    BEGIN CASE
        CASE OPERAND = 1
            OPERAND = 'EQ'
        CASE OPERAND = 2
            OPERAND = 'RG'
        CASE OPERAND = 3
            OPERAND = 'LT'
        CASE OPERAND = 4
            OPERAND = 'GT'
        CASE OPERAND = 5
            OPERAND = 'NE'
        CASE OPERAND = 6
            OPERAND = 'LIKE'
        CASE OPERAND = 7
            OPERAND = 'UNLIKE'
        CASE OPERAND = 8
            OPERAND = 'LE'
        CASE OPERAND = 9
            OPERAND = 'GE'
        CASE OPERAND = 10
            OPERAND = 'NR'
    END CASE
*
    RETURN
*
*--------------
SETUP.ENT.LIST:
*--------------
*
    EB.SystemTables.setEtext('')
    R.SC.CON.ENTITLEMENT = ''
    tmp.ETEXT = EB.SystemTables.getEtext()
    R.SC.CON.ENTITLEMENT = SC.SccEntitlements.ConEntitlement.Read(ID.DIARY, tmp.ETEXT)
* Before incorporation : CALL F.READ('F.SC.CON.ENTITLEMENT',ID.DIARY,R.SC.CON.ENTITLEMENT,F.SC.CON.ENTITLEMENT,tmp.ETEXT)
    EB.SystemTables.setEtext(tmp.ETEXT)
    IF EB.SystemTables.getEtext() THEN
        EB.SystemTables.setEtext('')
    END ELSE
        ENT.LIST = R.SC.CON.ENTITLEMENT
    END
*
    R.CONCAT.DIARY = ''
    tmp.ETEXT = EB.SystemTables.getEtext()
    R.CONCAT.DIARY = SC.SccEntitlements.ConcatDiary.Read(ID.DIARY, tmp.ETEXT)
* Before incorporation : CALL F.READ('F.CONCAT.DIARY',ID.DIARY,R.CONCAT.DIARY,F.CONCAT.DIARY,tmp.ETEXT)
    EB.SystemTables.setEtext(tmp.ETEXT)
    IF EB.SystemTables.getEtext() THEN
        EB.SystemTables.setEtext('')
    END ELSE
        IF ENT.LIST THEN
            ENT.LIST := @FM:R.CONCAT.DIARY
        END ELSE
            ENT.LIST = R.CONCAT.DIARY
        END
    END
*
    RETURN
*
    END
