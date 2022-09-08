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

*
*-----------------------------------------------------------------------------
* <Rating>1353</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.Config
    SUBROUTINE CONV.AC.SYS.CODES
***********************************************************
* This coversion routine will create a record in AC.SYS.CODES
* for all values define in ACCOUNT.PARAMETER SYS.CODE field.
************************************************************
* 22/09/03 - EN_10002030
*            System codes ars soft coded using AC.SYS.CODES system table.
*
* 10/10/03 - BG_100005359
*            F.WRITE replaced with WRITE statement
*
* 11/04/06 - CI_10040375
*            Variable uninitialised error when running conversion after upgrade.
*
***********************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_F.ACCOUNT.PARAMETER
    $INSERT I_F.SC.TRANS.NAME
    $INSERT I_F.AC.SYS.CODES
************************************************************
    GOSUB INITIALISE
*
    GOSUB CREATE.AC.SYS.CODES
*
    GOSUB CHECK.SYS.CODE.ALL
*
    RETURN
************************************************************
CREATE.AC.SYS.CODES:
*
    NO.OF.SYS.CODES = DCOUNT(R.ACCOUNT.PARAMETER<AC.PAR.SYS.CODE>,VM)
    FOR SYS.I = 1 TO NO.OF.SYS.CODES
        COMI = R.ACCOUNT.PARAMETER<AC.PAR.SYS.CODE,SYS.I>
        BEGIN CASE
        CASE COMI = 'ALL'
            COMI.ENRI = 'ALL APPLICATIONS'
        CASE LEN(COMI) GT 2 AND COMI[1,2] NE "SC" ;* Can be anything
            IF NOT(COMI MATCHES "2A'-'1X0X") THEN
                E ="AC.RTN.INCORRECT.FORMAT"
                GOTO FIELD.ERROR
            END ELSE
                LOCATE COMI[1,2] IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING POS ELSE
                    E ='AC.RTN.NOT.DEFINED.ON.COMP.REC'
                    GOTO FIELD.ERROR
                END
                COMI.SAVE = COMI ; COMI = COMI[1,2]
                CALL CHECK.APPLICATION
                COMI = COMI.SAVE
                IF E THEN GOTO FIELD.ERROR
            END
        CASE LEN(COMI) GT 2   ;* Must be SC
            LOCATE 'SC' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING POS ELSE
                E ='AC.RTN.SC.NOT.DEFINED.ON.COMP.REC'
                GOTO FIELD.ERROR
            END
            IF COMI[3,1] NE '-' THEN
                E ='AC.RTN.SEPARATED.BY.'
                GOTO FIELD.ERROR
            END
            SCTN.ID = FIELD(COMI,'-',2)
            SCTN.REC = ''
            READ.FAILED = ''
            CALL F.READ('F.SC.TRANS.NAME', SCTN.ID, SCTN.REC, F.SC.TRANS.NAME, READ.FAILED)
            IF READ.FAILED THEN
                E ='AC.RTN.INVALID.SC.TRANS.NAME.ID'
                GOTO FIELD.ERROR
            END ELSE
                ENRICH = SCTN.REC<SC.TNM.SHORT.NAME,LNGG>
                COMI.ENRI = 'SECURITIES-':ENRICH
            END
        CASE 1
            LOCATE COMI IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING POS ELSE
                E ='AC.RTN.NOT.DEFINED.ON.COMP.REC'
                GOTO FIELD.ERROR
            END
            CALL CHECK.APPLICATION
            IF E THEN GOTO FIELD.ERROR
        END CASE
FIELD.ERROR:
*
        IF NOT(E) THEN
            SYS.ID = COMI
            R.AC.SYS.CODES<AC.SYS.CODE.DESCRIPTION> = COMI.ENRI
            R.AC.SYS.CODES<AC.SYS.CODE.RECORD.STATUS> = "IHLD"
            R.AC.SYS.CODES<AC.SYS.CODE.INPUTTER> = TNO:'_':OPERATOR
            FAC.DATE = OCONV(DATE(),"D-")
            FAC.DATE = FAC.DATE[9,2]:FAC.DATE[1,2]:FAC.DATE[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]
            R.AC.SYS.CODES<AC.SYS.CODE.DATE.TIME> = FAC.DATE
            R.AC.SYS.CODES<AC.SYS.CODE.CO.CODE> = ID.COMPANY
            WRITE R.AC.SYS.CODES TO FV.AC.SYS.CODES,SYS.ID  ;* BG_100005359
        END
*
    NEXT SYS.I
*
    RETURN
*****************************************************************
INITIALISE:
*
    R.AC.SYS.CODES = ''
    FN.AC.SYS.CODES = "F.AC.SYS.CODES$NAU"
    FV.AC.SYS.CODES = ''
    CALL OPF(FN.AC.SYS.CODES,FV.AC.SYS.CODES)
*
    RETURN
******************************************************************
CHECK.SYS.CODE.ALL:
*
    LOCATE "ALL" IN R.ACCOUNT.PARAMETER<AC.PAR.SYS.CODE,1> SETTING YPOS ELSE
        SYS.ID = "ALL"
        R.AC.SYS.CODES<AC.SYS.CODE.DESCRIPTION> = "ALL APPLICATIONS"
        R.AC.SYS.CODES<AC.SYS.CODE.RECORD.STATUS> = "IHLD"
        R.AC.SYS.CODES<AC.SYS.CODE.INPUTTER> = TNO:'_':OPERATOR
        FAC.DATE = OCONV(DATE(),"D-")
        FAC.DATE = FAC.DATE[9,2]:FAC.DATE[1,2]:FAC.DATE[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]
        R.AC.SYS.CODES<AC.SYS.CODE.DATE.TIME> = FAC.DATE
        R.AC.SYS.CODES<AC.SYS.CODE.CO.CODE> = ID.COMPANY
        WRITE R.AC.SYS.CODES TO FV.AC.SYS.CODES,SYS.ID      ;* BG_100005359
    END
*
    RETURN
*
END
