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
* <Rating>707</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctOrderCapture
    SUBROUTINE CONV.SEC.OPEN.ORDER.CORR
*
*************************************************************************
* 07/07/04 - CI_10021114
*            This routine is a modification of CONV.SEC.OPEN.ORDER.G12.1
*            attached as file routine to the conversion details record
*            CONV.SEC.OPEN.ORDER.G12.1 found in G121DEV and G122DEV
*
* 19/08/05 - CI_10033644
*            Multi-company compatible.
*************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SC.TRANS.TYPE

* POSITIONS AS IN G121
    EQU SC.SOO.TRANSACTION.CODE TO 7
    EQU SC.SOO.SECURITY.ACCNT TO 10
    EQU SC.SOO.SECURITY.NO TO 3
    EQU SC.SOO.DEPOSITORY TO 42
    EQU SC.SOO.NOMINEE.CODE TO 43
    EQU SC.SOO.SUB.ACCOUNT TO 37
    EQU SC.SOO.NO.NOMINAL TO 11

* POSITION AS IN G120 AS CONVERSION FOR SECURITY.POSITION HAS NOT RUN YET
    EQU SC.SCP.NET.OPEN.ORD.POS TO 40

    SAVE.ID.COMPANY = ID.COMPANY

* Loop through each company

    COMMAND = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
    COMPANY.LIST = ''
    CALL EB.READLIST(COMMAND, COMPANY.LIST, '','','')

    LOOP
        REMOVE K.COMPANY FROM COMPANY.LIST SETTING COMP.MARK
    WHILE K.COMPANY:COMP.MARK

        IF K.COMPANY <> ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
        END

        GOSUB OPEN.FILES

        EXECUTE ' SELECT ':FN.SEC.OPEN.ORDER
        SC.SOO.REC = '' ; REC.UPD = '' ; LIVE.FL = ''

        LOOP
            READNEXT SOO.ID ELSE SOO.ID = ''
        WHILE SOO.ID DO
            LIVE.FL = 'Y'
            READ SC.SOO.REC FROM F.SEC.OPEN.ORDER, SOO.ID THEN GOSUB UPDATE.SEC.POS
        REPEAT
    REPEAT

    IF ID.COMPANY <> SAVE.ID.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)
    END

    RETURN
*
*--------------
UPDATE.SEC.POS:
*--------------

    NO.OF.PORTFOLIOS = 0
    NO.OF.PORTFOLIOS = DCOUNT(SC.SOO.REC<SC.SOO.SECURITY.ACCNT>,VM)
    SOO.TRANS.CODE = SC.SOO.REC<SC.SOO.TRANSACTION.CODE>
    TRANS.CODE = SOO.TRANS.CODE
    GOSUB GET.DR.CR
    FOR X = 1 TO NO.OF.PORTFOLIOS
        DEP.KEY = "" ; SUB.ACCOUNT = "" ; YPOS = ''
        LOCATE SC.SOO.REC<SC.SOO.SECURITY.ACCNT><1,X> IN SC.SOO.REC<SC.SOO.SECURITY.ACCNT,1> SETTING YPOS ELSE YPOS = 0

        IF YPOS THEN
            DEP.KEY = SC.SOO.REC<SC.SOO.SECURITY.ACCNT><1,YPOS>:'.':SC.SOO.REC<SC.SOO.SECURITY.NO>:'.':SC.SOO.REC<SC.SOO.DEPOSITORY>:'.':SC.SOO.REC<SC.SOO.NOMINEE.CODE>:'...':SC.SOO.REC<SC.SOO.SUB.ACCOUNT><1,YPOS>
            DEP.REC = '' ; RETRY = ''

            READ DEP.REC FROM F.SECURITY.POSITION, DEP.KEY THEN
                IF DEP.REC<SC.SCP.NET.OPEN.ORD.POS> = '' THEN DEP.REC<SC.SCP.NET.OPEN.ORD.POS> = 0
                IF SC.SOO.REC<SC.SOO.TRANSACTION.CODE> = CR.CODE THEN
                    DEP.REC<SC.SCP.NET.OPEN.ORD.POS> = DEP.REC<SC.SCP.NET.OPEN.ORD.POS> +(2*(SC.SOO.REC<SC.SOO.NO.NOMINAL><1,YPOS>))
                END ELSE
                    DEP.REC<SC.SCP.NET.OPEN.ORD.POS> = DEP.REC<SC.SCP.NET.OPEN.ORD.POS> - (2*(SC.SOO.REC<SC.SOO.NO.NOMINAL><1,YPOS>))
                END
                WRITE DEP.REC TO F.SECURITY.POSITION, DEP.KEY
            END
        END
    NEXT X
*
    RETURN
*----------
GET.DR.CR:
*----------
*
    DR.CODE = "" ; CR.CODE = "" ; TRANS.KEY = ''
    CALL DBR("SC.TRA.CODE":FM:1,TRANS.CODE,TRANS.KEY)
    R.TRANS = '' ; ER = ''
    CALL F.READ('F.SC.TRANS.TYPE',TRANS.KEY,R.TRANS,F.TRANS.FILE,ER)
    IF ER THEN TEXT = ER ; GOTO FATAL.ERR
    DR.CODE = R.TRANS<SC.TRN.SECURITY.DR.CODE>
    CR.CODE = R.TRANS<SC.TRN.SECURITY.CR.CODE>
*
    RETURN
*----------
OPEN.FILES:
*----------

    CALL OPF('F.SC.TRANS.TYPE',F.TRANS.FILE)
    F.SECURITY.POSITION = ''
    FN.SECURITY.POSITION = 'F.SECURITY.POSITION'
    CALL OPF(FN.SECURITY.POSITION, F.SECURITY.POSITION)
    FN.SEC.OPEN.ORDER = "F.SEC.OPEN.ORDER" ; F.SEC.OPEN.ORDER = ""
    CALL OPF(FN.SEC.OPEN.ORDER, F.SEC.OPEN.ORDER)
*
    RETURN
*----------
FATAL.ERR:
*----------
*
    CALL FATAL.ERROR('CONV.SEC.OPEN.ORDER.G12.1')
*
    RETURN
*
END
