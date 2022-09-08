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
* <Rating>398</Rating>
*-----------------------------------------------------------------------------
* Version 4 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*
    $PACKAGE DE.Reports
    SUBROUTINE E.BUILD.HANDOFF.REC
*
    $USING DE.Config
    $USING EB.DataAccess
    $USING DE.API
    $USING DE.Reports
    $USING DE.ModelBank
    $USING EB.SystemTables
    $USING EB.Reports
*
** This routine build R.RECORD from the DE.HANDOFF record together
** with the mapped field names. The format of the record is as
** follows
*
* R.RECORD<1>          Mapping Key
* R.RECORD<2>          Bank Date
* R.RECORD<3,xx>       Record Position
* R.RECORD<4,xx>       Field Name
* R.RECORD<5,xx>       Content
*

*-----------------------------------------------------------------------------
* 26/09/02 - GLOBUS_EN_10001244
*            To handle the User defined fields in Message and Mapping
*
* 07/10/02 - GLOBUS_BG_100002274
*          Change the USR.FIELD.NAME as USR.FLD.NAME and USR.DESCRIPT
*          as USR.FLD.DESC
*
* 31/01/03 - GLOBUS_BG_100003344
*           Feild names doesn't get displayed in the enquiry DE.HANDOFF.DETS
*           because the correct mapping record is not read.
*
* 17/01/07 - GLOBUS_BG_100012688
*            Variable DR.MAP is never assigned.
*
* 02/03/07 - BG_100013037
*            CODE.REVIEW changes.
*
* 26/04/07 - EN_10003323
*             Delivery link to AA. Get right file record by locating file name
*
* 04/12/07 - BG_100016172
*            Ref : TTS0754691
*            Handoff Record is passed as an argument for DE.CONV.NAMES.TO.NUMS
*
* 16/10/15 - Enhancement 1265068/ Task 1504013
*          - Routine incorporated
*
*-----------------------------------------------------------------------------
    DE.KEY = EB.Reports.getOData() ;* Passed in common

    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
*
    F.DE.MAPPING = ''
    EB.DataAccess.Opf("F.DE.MAPPING", F.DE.MAPPING)
*
    F.DE.O.HANDOFF = ''
    EB.DataAccess.Opf("F.DE.O.HANDOFF", F.DE.O.HANDOFF)
*
    EQU EOS TO 0 , FMC TO 2 , VMC TO 3 , SMC TO 4 , TMC TO 5
*
    EB.Reports.setRRecord('')
    EB.Reports.setVmCount(3)
    tmp=EB.Reports.getRRecord(); tmp<3,1>='0.0'; EB.Reports.setRRecord(tmp); tmp=EB.Reports.getRRecord(); tmp<4,1>='DELIVERY KEY'; EB.Reports.setRRecord(tmp); tmp=EB.Reports.getRRecord(); tmp<5,1>=DE.KEY; EB.Reports.setRRecord(tmp)
    READ HANDY.REC FROM F.DE.O.HANDOFF , DE.KEY THEN
        K.DE.MAPPING = FIELD(HANDY.REC<1>,@TM,1)
        HANDY.REC<1> = FIELD(HANDY.REC<1>,@TM,2,99)
        BANK.DATE = K.DE.MAPPING["*",2,1]
        IF INDEX(K.DE.MAPPING,"*",1) THEN         ;* Drop other nonsense
            K.DE.MAPPING = FIELD(K.DE.MAPPING,"*",1)
        END
        tmp=EB.Reports.getRRecord(); tmp<1>=K.DE.MAPPING; EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord(); tmp<2>=BANK.DATE; EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord(); tmp<3,2>='0.1'; EB.Reports.setRRecord(tmp); tmp=EB.Reports.getRRecord(); tmp<4,2>='MAPPING.KEY'; EB.Reports.setRRecord(tmp); tmp=EB.Reports.getRRecord(); tmp<5,2>=K.DE.MAPPING; EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord(); tmp<3,3>='0.2'; EB.Reports.setRRecord(tmp); tmp=EB.Reports.getRRecord(); tmp<4,3>='BANK.DATE'; EB.Reports.setRRecord(tmp); tmp=EB.Reports.getRRecord(); tmp<5,3>=BANK.DATE; EB.Reports.setRRecord(tmp)

        *!* Define the mapping key to consist of just the product code.

        MSG = FIELD(K.DE.MAPPING , "." , 1)


        GOSUB READ.MAPPING.RECORD       ;* BG_100013037 - S / E


        REC = 1
        V$FIELD = 1
        VAL = 1
        V$SUB = 1
        *---------------------
        * NH 11-12-96 T/0661-A
        GOSUB GET.PREFIX      ;* BG_100013037 - S / E
        HANDY.REC=HANDY.REC
    END ELSE
    END
    RETURN
*
MAP.PREFIX:
    TEMP.ID = EB.SystemTables.getPrefix()
    FLD.NAME = ''   ;* Name in mapping
    PREFIX.FOUND = ''
    DOT.COUNT = DCOUNT(TEMP.ID,'.')
    FOR X = 1 TO DOT.COUNT UNTIL PREFIX.FOUND
        IF NOT(TEMP.ID MATCHES "1N") THEN
            GOSUB SEARCH.FIELD.NAME     ;* BG_100013037 - S / E
        END
    NEXT X
    RETURN
*************************************************************************************************************
* BG_100013037 - S
*===========
GET.PREFIX:
*===========
    MORE$=0
    LOOP
        REMOVE V$DATA FROM HANDY.REC SETTING MORE
        BEGIN CASE
            CASE MORE=SMC OR MORE$=SMC
                EB.SystemTables.setPrefix(REC:'.':V$FIELD:'.':VAL:'.':V$SUB)
            CASE MORE=VMC OR MORE$=VMC
                EB.SystemTables.setPrefix(REC:'.':V$FIELD:'.':VAL)
            CASE 1
                EB.SystemTables.setPrefix(REC:'.':V$FIELD)
        END CASE
        GOSUB MAP.PREFIX

        EB.Reports.setVmCount(EB.Reports.getVmCount() + 1)
        VM.COUNT.VAL = EB.Reports.getVmCount()
        tmp=EB.Reports.getRRecord(); tmp<3, VM.COUNT.VAL>=EB.SystemTables.getPrefix(); EB.Reports.setRRecord(tmp);* Position
        tmp=EB.Reports.getRRecord(); tmp<4, VM.COUNT.VAL>=FLD.NAME; EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord(); tmp<5, VM.COUNT.VAL>=V$DATA; EB.Reports.setRRecord(tmp)
        *
        IF MORE NE SMC THEN
            IF MORE NE VMC THEN
                IF MORE NE FMC THEN
                    IF MORE NE TMC THEN
                        EXIT
                    END ELSE
                        REC+=1
                    END
                    V$FIELD=1
                END ELSE
                    V$FIELD+=1
                END
                VAL=1
            END ELSE
                VAL+=1
            END
            V$SUB=1
        END ELSE
            V$SUB+=1
        END
        MORE$=MORE
    REPEAT
    RETURN
*************************************************************************************************************
*=====================
READ.MAPPING.RECORD:
*=====================
* BG_100003344 -s
* For the mapping records like 320.FDP.1, field names doesn't get displayed
* in the enquiry DE.HANDOFF.DETS.  This is because DE.MAPPING record is
* read with the id 320.FD.1 (with only 2 characters of the application)
* and not with id 320.FDP.1.
* (commented)        APP = FIELD(K.DE.MAPPING , "." , 2)[1 , 2]

    APP = FIELD(K.DE.MAPPING , "." , 2)

* if the length is four characters, then only use the first two (FTAC => FT)

    IF LEN(APP) = 4 THEN
        APP = APP[1,2]
    END

* BG_100003344 -e

    SER.NO = FIELD(K.DE.MAPPING , "." , 3)
    K.DE.MAPPING = MSG:'.':APP:'.':SER.NO



*         READ R.DE.MAPPING FROM F.DE.MAPPING,K.DE.MAPPING THEN

* EN_10001244 - S
* To convert the field names to numbers Call DE.CONV.NAMES.TO.NUMS.
* MATREAD is used insted of READ to get the mapping record in dimensioned array
* to pass to the name to number conversion routine

    DIM R.DE.MAPPING(DE.Config.Mapping.MapAuditDateTime)
    MATREAD R.DE.MAPPING FROM F.DE.MAPPING,K.DE.MAPPING THEN
    ERR.TEXT = ''
    DIM TMP.HANDOFF.REC(DCOUNT(HANDY.REC,@FM)) ;*BG_100016172 -S
    MATPARSE TMP.HANDOFF.REC FROM HANDY.REC
    DE.API.ConvNamesToNums(MAT R.DE.MAPPING,ERR.TEXT,MAT TMP.HANDOFF.REC)         ;*BG_100016172 -E
* EN_10001244 - E
    END ELSE
    MAT R.DE.MAPPING = ''
    END
    RETURN
*************************************************************************************************************
*=================
SEARCH.FIELD.NAME:
*================

* EN_10001244 - S
* To locate field name in DE.Mapping, first look in the USR.FLD.NAME
*  and if it is not found then locate in FIELD.NAME .
*
    REC.NO = TEMP.ID[1,2]
    IF REC.NO MATCHES '2N' THEN GOSUB CHECK.FOR.RIGHT.RECORD
*
    LOCATE TEMP.ID IN R.DE.MAPPING(DE.Config.Mapping.MapUsrInputPos)<1,1> SETTING POS THEN
    PREFIX.FOUND = 1
* BG_100002274 - S
    IF R.DE.MAPPING(DE.Config.Mapping.MapUsrFldName)<1,POS> THEN
        FLD.NAME= ' ':R.DE.MAPPING(DE.Config.Mapping.MapUsrFldName)<1,POS>
    END ELSE
        FLD.NAME= " HDR - ":R.DE.MAPPING(DE.Config.Mapping.MapHeaderName)<1,POS>
    END
* BG_100002274 - E
    END ELSE
    LOCATE TEMP.ID IN R.DE.MAPPING(DE.Config.Mapping.MapInputPosition)<1,1> SETTING POS THEN
    IF R.DE.MAPPING(DE.Config.Mapping.MapFieldName)<1,POS> THEN
        FLD.NAME= ' ':R.DE.MAPPING(DE.Config.Mapping.MapFieldName)<1,POS>
    END ELSE
        FLD.NAME= " HDR - ":R.DE.MAPPING(DE.Config.Mapping.MapHeaderName)<1,POS>
    END
    END ELSE
    TEMP.ID = FIELD(TEMP.ID,'.',1,(DOT.COUNT-X))
    END
    END
* EN_10001244 - E

    RETURN          ;*BG_100013037 - E
*************************************************************************************************************
CHECK.FOR.RIGHT.RECORD:
* get the file name corresponding to record number

    MAP.FILE.NAME = ''; MAP.HANDOFF.SAME = 0

    FILE.REC = FIELD(HANDY.REC, CHARX(251), 7)

    LOCATE TEMP.ID IN R.DE.MAPPING(DE.Config.Mapping.MapInputPosition)<1,1> SETTING REC.POS THEN
    MAP.FILE.NAME = R.DE.MAPPING(DE.Config.Mapping.MapInputFile)<1,REC.POS>

    LOCATE MAP.FILE.NAME IN FILE.REC<1> SETTING HAND.FILE.POS THEN          ;* file names appear in 7th handoff record
    IF (10+HAND.FILE.POS) EQ REC.NO THEN
        MAP.HANDOFF.SAME = 1
    END
    END
    END

    IF MAP.HANDOFF.SAME EQ 0 THEN
        REC.ID = INDEX(TEMP.ID,'.',1)
        TEMP.ID= TEMP.ID[REC.ID+1, 99]
        TEMP.ID = REC.NO:'.':TEMP.ID
    END

    RETURN
    END
