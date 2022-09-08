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
* <Rating>-32</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoSecurityPositionUpdate
    SUBROUTINE CONV.POS.CON.SCAC.R07
* Conversion Routine for the removal of -777 and -999 POS.CON.SCAC records
*
* 11/09/06 - EN_10003050
*            Conversion routine for pos.con.scac
*--------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY

    ORIG.COMPANY = ID.COMPANY
    F.COMPANY = ''
    CALL OPF('F.COMPANY',F.COMPANY)

    SEL.CMD = 'SELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
    COM.LIST = '' ; YSEL = 0
    CALL EB.READLIST(SEL.CMD,COM.LIST,'',YSEL,'')
    LOOP
        REMOVE K.COMPANY FROM COM.LIST SETTING END.OF.COMPANIES
    WHILE K.COMPANY:END.OF.COMPANIES
        IF K.COMPANY <> ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
        END
        LOCATE 'SC' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING PROD.POSN THEN
            GOSUB MAIN.PROCESS
        END
    REPEAT
    IF ORIG.COMPANY <> ID.COMPANY THEN
        CALL LOAD.COMPANY(ORIG.COMPANY)
    END
    RETURN

*-------------
MAIN.PROCESS:
*-------------
    FN.POS.CON.SCAC = 'F.POS.CON.SCAC'
    F.POS.CON.SCAC = ''
    CALL OPF(FN.POS.CON.SCAC,F.POS.CON.SCAC)
    SEL.CMD1 = ''
    SEL.CMD1 = 'SELECT ' :FN.POS.CON.SCAC:' WITH @ID LIKE ...-999':' OR LIKE ...-777'
    GOSUB PROCESS.POS.CON.SCAC
    RETURN
*--------------------
PROCESS.POS.CON.SCAC:
*--------------------
    POS.CON.SCAC.LIST = '' ; YSEL1 = 0
    CALL EB.READLIST(SEL.CMD1,POS.CON.SCAC.LIST,'',YSEL1,'')
    LOOP
        REMOVE POS.REF FROM POS.CON.SCAC.LIST SETTING END.OF.POS.CON
    WHILE POS.REF:END.OF.POS.CON
        DELETE F.POS.CON.SCAC,POS.REF
    REPEAT
    RETURN
END
