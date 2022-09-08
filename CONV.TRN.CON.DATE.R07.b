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
    SUBROUTINE CONV.TRN.CON.DATE.R07
* Conversion Routine for the removal of -777 and -999 TRN.CON.DATE records
*
* 11/09/06 - EN_10003050
*            Conversion routine for trn.con.date
*
* 07/04/09 - GLOBUS_CI_10061954
*            TRN.CON.DATE records missing after running
*            Conversion Conv.Trn.Con.Date.R07 .
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
    FN.TRN.CON.DATE = 'F.TRN.CON.DATE'
    F.TRN.CON.DATE = ''
    CALL OPF(FN.TRN.CON.DATE,F.TRN.CON.DATE)
    SEL.CMD1 = ''
    SEL.CMD1 = 'SELECT ':FN.TRN.CON.DATE:' WITH @ID LIKE ...-999....':' OR LIKE ...-777....'
    GOSUB PROCESS.TRN.CON.DATE
    RETURN
*---------------------
PROCESS.TRN.CON.DATE:
*---------------------
    TRN.CON.DATE.LIST = '' ; YSEL1 = 0
    CALL EB.READLIST(SEL.CMD1,TRN.CON.DATE.LIST,'',YSEL1,'')
    LOOP
        REMOVE TRN.REF FROM TRN.CON.DATE.LIST SETTING END.OF.TRN.CON
    WHILE TRN.REF:END.OF.TRN.CON
        PORT.ID = ''
        PORT.ID = FIELD(TRN.REF,'.',1)
        IF PORT.ID[3] EQ '777' OR PORT.ID[3] EQ '999' THEN
            DELETE F.TRN.CON.DATE,TRN.REF
        END
    REPEAT
    RETURN
END
