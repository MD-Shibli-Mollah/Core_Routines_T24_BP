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

* Version 3 07/06/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>35088</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.Repgens
    SUBROUTINE CONV.REPGEN.SOURCE.G11(RG.NAME.ID,RG.REC,RG.FILE)
REM "REPGEN.SOURCE",850927-001,"MAINPGM"
*
*      Program name : CONV.REPGEN.SOURCE

* 08/05/00 -  GB0001154
*             Conversion program to recompile and catalog all
*             REPGENs. This is required for G11.0.00 upgrade.
*             where the common KEYWORDS DISPLAY was converted
*             V$DISPLAY, for jBASE compatibility.
*             S.Satish Narayanan
*
**********     NOTE     *************
* This conversion program is a copy of REPGEN.SOURCE. The changes made are
* remove interactive code, like prompting for user interaction.
* remove unwanted display
* display meaningful information.
*
* The above changes are made to suit the conversion procedure
* during GLOBUS upgarde.
* The PIF nos mentioned below apply to REPGEN.SOURCE and not for
* this conversion program. Any PIF for this conversion program
* should be mentioned above this note.
*
* S.Satish Narayanan
*23/08/00 - GB0002062
*           jBASE changes.
*           Program must call the jbase compiler if required.
*           This will allow for jBASE checks to be performed
*            when doing a release to test.
*
* 23/08/02 - GLOBUS_EN_10000971
*          Conversion Of all Error Messages to Error Codes
*
* 02/11/07 - BG_100015661
*            Call to COMPILE.IN.JBASE removed as the routine changed to JBASE.COMPILE.
*
* 8/12/2011 - Task 321080
*			 Field position is used instead of field name.       
*
*************************************************************8
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_SCREEN.VARIABLES
    $INSERT I_RC.COMMON
    $INSERT I_F.LANGUAGE
    $INSERT I_F.COMPANY
    $INSERT I_F.PGM.FILE
    $INSERT I_F.REPGEN.CREATE
    $INSERT I_F.SPF

*
*--------------------------------------------------------------------
*
* 08/07/88 EB8800729 - Clear sort file rather than delete/re-create.
*          Rev 7 does not allow delete on an open file. Disk space
*          is recovered.
*
* 11/02/93 GB9300237 - Add READLIST and REMOVE processing to inprove
*          performance on large files.
*
* 03/08/93 - GB9301255
*            Allow a subroutine to be called to perform the selection
*
* 08/10/93 - GB9301396
*            Catalog locally as specified in SPF
*
* 22.11.93 - GB9300826
*            The RGS.xxxx program should call EB.READLIST to get
*            the list of Companies if "ALL" is specified in
*            DEFINE.COMPANY
*            Remove Commented out code that does this. This is done in
*            the routine REPGEN.SMS.FILE (in GOSUB - SMS.FILE.CHECK)
*
* 16/02/95 - GB9400926
*            Amended to allow for the change in the default cataloging
*            option on the SPF from GLOBAL to LOCAL
*
* 07/05/96 - GB9600523
*            Replace calls to STATIC.FIELD.TEXT with calls to TXT.
*
* 08/05/97 - GB9700569
*            For reports using a blank special heading the page number is too far to the right.
*
* 11/12/97 - GB9701367
*            Year 2000 changes - Extend contract keys/date field on
*                                schedule files for century compliance
*
* 27/01/98 - GB9800063
*            PIF GB9701076 was a onsite fix for GWK. This fix
*            created a problem for other customers producing
*            the report only as a flat file in that in their
*            case they had extra characters appearing in the
*            front of the file. This processing now needs
*            to be done depending on the value of the field
*            SPECIAL.HEADING. If the value in this field has been
*            set to 'NONE' the GWK processing will be performed
*            otherwise is this is set to 'FLAT' the old
*            processing before the change made for GWK will be
*            performed.
*
* 27/01/98 - GB9800077
*            In a multi-company environment the program
*            REPGEN.SOURCE does not do a LOAD.COMPANY
*            which can make things go wrong in the report
*            program it generates.
*
* 02/02/98 - GB9800096
*            Year 2000 changes - Earlier change causes problems for
*                                keys with multiple components
*
* 06/10/98 - GB9801237
*            year 2000 changes - the setting of the key components in
*            print section was checking the YMASK but Ymask was not set
*            for the correct Multi-value.
*
* 04/05/00 - GB0001154
*            Change DISPLAY to V$DISPLAY in the code generated. This variable
*            is only used when running from REPGEN.OUTPUT and tells repgen to
*            output to the screen.
*
*************************************************************************
*

*************************************************************
    GOSUB INITIALISE
    F.PGM.FILE = "" ; CALL OPF ("F.PGM.FILE", F.PGM.FILE)
    F.REPGEN.CREATE = ""
    CALL OPF ("F.REPGEN.CREATE", F.REPGEN.CREATE)
    OPEN "", "RG.BP" TO F.RG.BP ELSE
        TEXT = "RG.BP-FILE NOT AVAILABLE" ; CALL REM ; RETURN
    END
*
* These are not required in the conversion program
*      YTEXT = "PGM. CREATES SOURCE CODE, "
*      IF LNGG <> 1 THEN CALL TXT ( YTEXT )
*      YTEXT2 = "COMPILES AND CATALOGES LOCALLY"
*      IF LNGG <> 1 THEN CALL TXT ( YTEXT2 )
*      PRINT @(1,1):S.CLEAR.EOL:YTEXT:YTEXT2:
*
    IF R.SPF.SYSTEM<11> <> "GLOBAL" THEN
        CATALOG.OPTION = "LOCAL"        ;* Appended to catalog statement
    END ELSE
        CATALOG.OPTION = ""
    END
    RG.PROCESSED = ''
*
*
*
RECORD.NAME.INPUT:
*
*
    YPGM.NAME = RG.NAME.ID
    IF RG.PROCESSED = RG.NAME.ID THEN RETURN
    RG.PROCESSED = RG.NAME.ID
*
LOCK.REPGEN.CREATE:
*
    MATREADU R.NEW FROM F.REPGEN.CREATE, YPGM.NAME LOCKED
        TEXT = "FILE=F.REPGEN.CREATE ID=":YPGM.NAME ; CALL LCK
        GOTO LOCK.REPGEN.CREATE
    END ELSE
        MAT R.NEW = ''
        E ="EB.RTN.REC.MISS.2"
*
PGM.ERROR:
*
        RELEASE ; L = 22 ; CALL ERR ; GOTO RECORD.NAME.INPUT
    END
*
    YTEXT = "LAST COMPILING OF" ; CALL TXT (YTEXT)
    V$DISPLAY = R.NEW(RG.CRE.DATE.TIME.COMPILER)
    IF V$DISPLAY THEN CALL MSK (15, FM:FM:FM:"RDD DD  DD ##:##")
    ELSE V$DISPLAY = "---"
* This display is not required
*      PRINT @(0,L1ST-2):S.CLEAR.EOL:" ":YTEXT:" ":YPGM.NAME:": ":DISPLAY:
*      FOR LL = L1ST TO 19 ; PRINT @(0,LL):S.CLEAR.EOL: ; NEXT LL
*      TEXT = "TO CONTINUE SAY 'Y'" ; CALL OVE ; * not reqd since automatic
    TEXT = 'YES'
    IF TEXT = "NO" THEN RELEASE ; GOTO RECORD.NAME.INPUT
*
    READU YRG FROM F.RG.BP, "RGP.":YPGM.NAME LOCKED
        E ="EB.RTN.SOURCE.PGM..LOCKED.2" ; GOTO PGM.ERROR
    END ELSE
        YRG = ""
    END
    IF NOT(YRG) THEN YPRINTOUT.VERSION = 1
    ELSE YPRINTOUT.VERSION = FIELD(YRG<2>,"-",2)+1
*
    READU YRG FROM F.RG.BP, "RGS.":YPGM.NAME LOCKED
        E ="EB.RTN.SOURCE.PGM..LOCKED.3" ; GOTO PGM.ERROR
    END ELSE
        YRG = ""
    END
*
*------------------------------------------------------------------------
*
* Calculate dimension of fields (used fields for write record)
*
    IF R.NEW(RG.CRE.USING.132.COLUMNS) THEN YLAST.COL = 133
    ELSE YLAST.COL = 81
    YDIM.RECNO = 0 ; YSTMNO = 1000 ; YHEADER.DISPLAY = 0
    IF NOT(R.NEW(RG.CRE.MNEMON.SEQU)<1,1>) THEN
        YCOUNT = COUNT(R.NEW(RG.CRE.DEFINE.MNEMONIC),VM)+1
        FOR YAV = 1 TO YCOUNT
            IF R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV> THEN
                YDIM.RECNO += 1
                IF R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV> = "1 HEADER" THEN
                    YHEADER.DISPLAY = 1
                END
            END
        NEXT YAV
    END
    YCOUNT = COUNT(R.NEW(RG.CRE.MNEMON.SEQU),VM)+1
    FOR YAV = 1 TO YCOUNT
        IF R.NEW(RG.CRE.MNEMON.SEQU)<1,YAV> THEN
            YCOUNT.AS = COUNT(R.NEW(RG.CRE.MNEMON.SEQU)<1,YAV>,SM)+1
            YMAX = 0
            FOR YAS = 1 TO YCOUNT.AS
                YMNE = R.NEW(RG.CRE.MNEMON.SEQU)<1,YAV,YAS>
                YAV.MNE = 1
                LOOP
                UNTIL YMNE = R.NEW(RG.CRE.DEFINE.MNEMONIC)<1,YAV.MNE> DO
                    YAV.MNE += 1
                REPEAT
                IF R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE> THEN
                    YMAX += 1
                    IF R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE> = "1 HEADER" THEN
                        YHEADER.DISPLAY = 1
                    END
                END
            NEXT YAS
            IF YMAX > YDIM.RECNO THEN YDIM.RECNO = YMAX
        END
    NEXT YAV
*
*------------------------------------------------------------------------
*
* Update File tables
* YT.SMS.FILE = all files / YT.MODIF.FILE = foreign (modif.) file only
*
    YT.SMS.FILE = R.NEW(RG.CRE.READ.FILE) ; YT.MODIF.FILE = ""
    CONVERT VM TO FM IN YT.SMS.FILE
    YCOUNT = COUNT(R.NEW(RG.CRE.MODIF.FILE),VM)+1
    FOR YAV = 1 TO YCOUNT
        YCOUNT.AS = COUNT(R.NEW(RG.CRE.MODIF.FILE)<1,YAV>,SM)+1
        FOR YAS = 1 TO YCOUNT.AS
            YFILE = R.NEW(RG.CRE.MODIF.FILE)<1,YAV,YAS>
            IF YFILE THEN
                LOCATE YFILE IN YT.MODIF.FILE<1> SETTING X
                ELSE YT.MODIF.FILE<-1> = YFILE
            END
        NEXT YAS
    NEXT YAV
    IF YT.MODIF.FILE THEN
        YCOUNT = COUNT(YT.MODIF.FILE,FM)+1
        FOR YAF = 1 TO YCOUNT
            YFILE = YT.MODIF.FILE<YAF>
            LOCATE YFILE IN YT.SMS.FILE<1> SETTING X
            ELSE YT.SMS.FILE<-1> = YFILE
        NEXT YAF
    END
    YCOUNT = COUNT(R.NEW(RG.CRE.FL.DECISION),VM)+1
    FOR YAV = 1 TO YCOUNT
        YCOUNT.AS = COUNT(R.NEW(RG.CRE.FL.DECISION)<1,YAV>,SM)+1
        FOR YAS = 1 TO YCOUNT.AS
            IF R.NEW(RG.CRE.FL.DECISION)<1,YAV,YAS> = 'KEY' THEN
                YFILE = R.NEW(RG.CRE.FL.DECIS.FR)<1,YAV,YAS>
                IF YFILE THEN
                    LOCATE YFILE IN YT.SMS.FILE<1> SETTING X
                    ELSE YT.SMS.FILE<-1> = YFILE
                END
            END
        NEXT YAS
    NEXT YAV
*
*------------------------------------------------------------------------
*
* Define table with multi/subvalue Mnemonics
* and with Field no.s for splitting record to several ones
*
    YT.MNE.VALTYP = "" ; YT.SPLIT = "" ; V$FUNCTION = "REPGEN.SOURCE"
* YT.MNE.VALTYP defines whether field is multi value (M) or
* subfield (S) - may be defined by MNEMON- or MODIF.FIELD
* e.g. Mnemonic may be a single field but may be replaced by a multi
* value field of another file
    YCOUNT = COUNT(R.NEW(RG.CRE.DEFINE.MNEMONIC),VM)+1
    FOR YAV = 1 TO YCOUNT
        IF R.NEW(RG.CRE.MULTI.SPLIT.TOT)<1,YAV> <> "TOTAL" THEN
            IF R.NEW(RG.CRE.MULTI.SPLIT.TOT)<1,YAV> <> "Y" THEN
* exclude sum of multi value/sub field ('Y'=content of old records)
                YCOUNT.AS = COUNT(R.NEW(RG.CRE.MNEMON.FIELD)<1,YAV>,SM)+1
                FOR YAS = 1 TO YCOUNT.AS
                    YFIELD = R.NEW(RG.CRE.MNEMON.FIELD)<1,YAV,YAS>
                    YUPDATE.FIELD = "MNEMON"
                    GOSUB UPDATE.MULTI.AND.SPLIT.TABLE
                    YFIELD = R.NEW(RG.CRE.MODIF.FIELD)<1,YAV,YAS>
                    YUPDATE.FIELD = "MODIF"
                    GOSUB UPDATE.MULTI.AND.SPLIT.TABLE
                NEXT YAS
            END
        END
    NEXT YAV
*
* 2nd run to get multi/sub value code of fields which are mnemonics
* (take type of DEFINE.MNEMONIC field)
*
    FOR YAV = 1 TO YCOUNT
        IF NOT(R.NEW(RG.CRE.MULTI.SPLIT.TOT)<1,YAV>) THEN
* exclude sum of splitted or multi value/sub field
            YCOUNT.AS = COUNT(R.NEW(RG.CRE.MNEMON.FIELD)<1,YAV>,SM)+1
            FOR YAS = 1 TO YCOUNT.AS
                YFIELD = R.NEW(RG.CRE.MNEMON.FIELD)<1,YAV,YAS>
                IF YFIELD[1,1] >= "A" THEN
                    LOCATE FIELD(YFIELD,"[",1) IN R.NEW(RG.CRE.DEFINE.MNEMONIC)<1,1> SETTING X ELSE X = 0
                    IF X THEN
                        YMOD.VALTYP = YT.MNE.VALTYP<X>
                        IF YMOD.VALTYP THEN
                            IF YT.MNE.VALTYP<YAV> <> "S" THEN
                                YT.MNE.VALTYP<YAV> = YMOD.VALTYP
                            END
                        END
                    END
                END
                YFIELD = R.NEW(RG.CRE.MODIF.FIELD)<1,YAV,YAS>
                IF YFIELD[1,1] >= "A" THEN
                    LOCATE FIELD(YFIELD,"[",1) IN R.NEW(RG.CRE.DEFINE.MNEMONIC)<1,1> SETTING X ELSE X = 0
                    IF X THEN
                        YMOD.VALTYP = YT.MNE.VALTYP<X>
                        IF YMOD.VALTYP THEN
                            IF YT.MNE.VALTYP<YAV> <> "S" THEN
                                YT.MNE.VALTYP<YAV> = YMOD.VALTYP
                            END
                        END
                    END
                END
            NEXT YAS
        END
    NEXT YAV
*
*------------------------------------------------------------------------
*
* Ask for DISPLAY.TYPE '5 CONTIN.TOTAL' requiring 3rd record to hold
* amounts:
*
    YANY.CONTIN.TOTAL = 0
    FOR YAV = 1 TO YCOUNT
        IF R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV> = "5 CONTIN.TOTAL" THEN
            YANY.CONTIN.TOTAL = 1 ; YAV = YCOUNT
        END
    NEXT YAV
*
*------------------------------------------------------------------------
*
* Update table with masks (necessary to concatenate fields):
*
    YT.CONCAT.MNEMONIC = "" ; YT.CONCAT.MASK = ""
    FOR YAV = 1 TO YCOUNT
        IF INDEX(R.NEW(RG.CRE.MASK)<1,YAV>,"#",1) THEN
            YT.CONCAT.MNEMONIC<-1> = R.NEW(RG.CRE.DEFINE.MNEMONIC)<1,YAV>
            YT.CONCAT.MASK<-1> = R.NEW(RG.CRE.MASK)<1,YAV>
        END
    NEXT YAV
    YMASK.FOR.CONCAT.POSSIBLE = 0 ; YMASK.FOR.CONCAT = ""
*
* Clear True-Counter (used for decisions within decision)
*
    YTRUE.COUNTER = 0
    YT.TRUE = ""
*
*------------------------------------------------------------------------
*
* 1st Source pgm: Sort
*
* Define Source Code header (SORT)
*
    IF NOT(YRG) THEN YVERSION = 1
    ELSE YVERSION = FIELD(YRG<2>,"-",2)+1
    YRG = '  SUBROUTINE RGS.':YPGM.NAME
    YSYSDATE = OCONV(DATE(),"D-")
    YRG<-1> = 'REM "RGS.':YPGM.NAME:'",':YSYSDATE[9,2]:YSYSDATE[1,2]:YSYSDATE[4,2]:'-':YVERSION
    YRG<-1> = STR("*",73)
    YRG<-1> = '$INSERT I_COMMON'
    YRG<-1> = '$INSERT I_EQUATE'
    YRG<-1> = '$INSERT I_RC.COMMON'
    YRG<-1> = '$INSERT I_SCREEN.VARIABLES'
    YRG<-1> = '$INSERT I_F.COMPANY'
    YRG<-1> = '$INSERT I_F.USER'
*
*-----------------------------------------------------------------------
*
* Initialise SAVE.ID.COMPANY to the current company running under
*
** GB9800070
** ---------
*
    YRG<-1> = '  SAVE.ID.COMPANY = ID.COMPANY'

*
*------------------------------------------------------------------------
*
* Define variables used for Call routines:
    F.PGM.FILE = "" ; CALL OPF ("F.PGM.FILE", F.PGM.FILE)
    YT.CALL.PGM.FILE = "" ; YT.CALL.ROUTINE = ""
    YCOUNT = COUNT(R.NEW(RG.CRE.MODIFICATION),VM)+1
    FOR YAV = 1 TO YCOUNT
        YMODIFICATION = R.NEW(RG.CRE.MODIFICATION)<1,YAV>
        LOOP WHILE YMODIFICATION DO
            YMOD = YMODIFICATION<1,1,1> ; DEL YMODIFICATION<1,1,1>
            IF YMOD[1,1] = "@" THEN
                YMOD = FIELD(YMOD,"#",1) ; YMOD = YMOD[2,99]
                LOCATE YMOD IN YT.CALL.PGM.FILE<1> SETTING X ELSE
                    YT.CALL.PGM.FILE<-1> = YMOD ; YPG.KEY = ""
                    READV YPG.KEY FROM F.PGM.FILE, YMOD, EB.PGM.BATCH.JOB ELSE
                        E = "EB.RTN.MISS.FILE.PGM.FILE.ID..1":FM:YMOD
                        GOTO PGM.ERROR
                    END
                    YPG.KEY = YPG.KEY[2,99]
                    LOCATE YPG.KEY IN YT.CALL.ROUTINE<1> SETTING X ELSE
                        YT.CALL.ROUTINE<-1> = YPG.KEY
                        READV X FROM F.PGM.FILE, YPG.KEY, 1 ELSE
                            E = "EB.RTN.MISS.FILE.PGM.FILE.ID..1":FM:YPG.KEY
                            GOTO PGM.ERROR
                        END
                    END
                END
            END
        REPEAT
    NEXT YAV
    IF YT.CALL.ROUTINE THEN
        YT.CALL.PGM.FILE = ""
        YRG<-1> = STR("*",73)
        LOOP WHILE YT.CALL.ROUTINE DO
            YCALL.ROUTINE = YT.CALL.ROUTINE<1> ; DEL YT.CALL.ROUTINE<1>
            YRG<-1> = '  ':YCALL.ROUTINE:' = "':YCALL.ROUTINE:'"'
        REPEAT
    END
*
*------------------------------------------------------------------------
*
* Open VOC-File when SELECT with Field no.s used:
*
    YVOC = 0 ; YCOUNT = COUNT(R.NEW(RG.CRE.FL.FIELD.NO),VM)+1
    FOR YAV = 1 TO YCOUNT
        YCOUNT.AS = COUNT(R.NEW(RG.CRE.FL.FIELD.NO)<1,YAV>,SM)+1
        FOR YAS = 1 TO YCOUNT.AS
            IF R.NEW(RG.CRE.FL.FIELD.NO)<1,YAV,YAS> THEN
                IF R.NEW(RG.CRE.FL.DECISION)<1,YAV,YAS> NE "KEY" AND R.NEW(RG.CRE.FL.DECISION)<1,YAV,YAS> NE "SUB" THEN
                    YVOC = 1 ; YAS = YCOUNT.AS ; YAV = YCOUNT
                END
            END
        NEXT YAS
    NEXT YAV
    IF YVOC THEN
        YRG<-1> = STR("*",73)
        YRG<-1> = '  YF.VOC = ""'
        YRG<-1> = '  OPEN "", "VOC" TO YF.VOC ELSE'
        YRG<-1> = '    TEXT = "CANNOT OPEN VOC-FILE"'
        YRG<-1> = '    CALL FATAL.ERROR ("RGS.':YPGM.NAME:'")'
        YRG<-1> = '  END'
    END
*
*------------------------------------------------------------------------
*
    GOSUB SMS.FILE.CHECK
*
*------------------------------------------------------------------------
*
    YRG<-1> = '  YBLOCKNO = 0; YKEYNO = 0; YWRITNO = 0'
    YRG<-1> = '  YT.FORFIL = ""; YKEYFD = ""'
    YRG<-1> = '  YFD.LEN = ""; YPART.S = ""; YPART.L = ""'
    YRG<-1> = '  DIM YR.REC(':YDIM.RECNO:')'
    YRG<-1> = '  YFILE = "F":R.COMPANY(EB.COM.MNEMONIC):".RGS.':YPGM.NAME:'"'
    YRG<-1> = '  YOLDFILE = 1'
    YRG<-1> = '  OPEN "", YFILE TO F.FILE ELSE YOLDFILE = 0'
    YRG<-1> = '  IF NOT(PHNO) THEN PRINT @(0,10):'
    YRG<-1> = '  IF YOLDFILE THEN'
    YRG<-1> = '     CLEARFILE F.FILE'
    YRG<-1> = '     PRINT "FILE ":YFILE:"  CLEARED"'
    YRG<-1> = '  END ELSE'
    YRG<-1> = '    ERROR.MESSAGE = ""'
* PIF GB9100056 Pass filename without prefix
    YRG<-1> = '    Y.OUT.FILE = FIELD(YFILE,".",2,99)'
    YRG<-1> = '    CALL EBS.CREATE.FILE(Y.OUT.FILE,"",ERROR.MESSAGE)'
    YRG<-1> = '  END'
    YRG<-1> = '  OPEN "", YFILE TO F.FILE ELSE'
    YRG<-1> = '    TEXT = "CANNOT OPEN ":YFILE'
    YRG<-1> = '    CALL FATAL.ERROR ("RGS.':YPGM.NAME:'")'
    YRG<-1> = '  END'
    YRG<-1> = '*'
*
*------------------------------------------------------------------------
*
* Look for any @DATE or @MONTH decision
*
    YDATMTH = 0
    FOR YAF = RG.CRE.DECISION.FR TO RG.CRE.DECISION.TO
        YCOUNT = COUNT(R.NEW(YAF),VM)+1
        FOR YAV = 1 TO YCOUNT
            YCOUNT.AS = COUNT(R.NEW(YAF)<1,YAV>,SM)+1
            FOR YAS = 1 TO YCOUNT.AS
                IF R.NEW(YAF)<1,YAV,YAS>[1,1] = "@" THEN
                    YDATMTH = 1 ; YAS = YCOUNT.AS
                    YAV = YCOUNT ; YAF = RG.CRE.DECISION.TO
                END
            NEXT YAS
        NEXT YAV
    NEXT YAF
    IF YDATMTH THEN YRG<-1> = '  YT.DATMTH = ""'
*
*------------------------------------------------------------------------
*
* Define maximum length of group (used for key)
*
    YGROUP.LENGTH = 0
    YCOUNT.GROUP = COUNT(R.NEW(RG.CRE.GROUP),VM)+1
    FOR YAV = 1 TO YCOUNT.GROUP
        IF LEN(R.NEW(RG.CRE.GROUP)<1,YAV>) > YGROUP.LENGTH THEN
            YGROUP.LENGTH = LEN(R.NEW(RG.CRE.GROUP)<1,YAV>)
        END
    NEXT YAV
*
*------------------------------------------------------------------------
*
* Handle summary report (compensation) when more than 1 company
*
    IF NOT(R.NEW(RG.CRE.DEFINE.COMPANY)) THEN
        YRG<-1> = '  YCOM = ID.COMPANY'
        YPRECOM = "" ; GOSUB CREATE.PW.TABLE
    END ELSE
        YPRECOM = "  "
        IF R.NEW(RG.CRE.DEFINE.COMPANY) <> "ALL" THEN
            YCOUNT = COUNT(R.NEW(RG.CRE.DEFINE.COMPANY),VM)+1
            YRG<-1> = '  YCOMTBL = ""; YF.COMPANY = ""'
            YRG<-1> = '  CALL OPF ("F.COMPANY", YF.COMPANY)'
            FOR YAV = 1 TO YCOUNT
                YRG<-1> = '  YCOMTBL<':YAV:'> = "':R.NEW(RG.CRE.DEFINE.COMPANY)<1,YAV>:'"'
            NEXT YAV
        END
        YRG<-1> = '  DIM R.COMPANY.SAVE(EB.COM.AUDIT.DATE.TIME)'
        YRG<-1> = '  MAT R.COMPANY.SAVE = MAT R.COMPANY'
        YRG<-1> = '  LOOP UNTIL YCOMTBL = "" DO'
        YRG<-1> = '    YCOM = YCOMTBL<1>; DEL YCOMTBL<1>'
        YRG<-1> = '    T.OPF = ""; OPF.NO = 0'
        YRG<-1> = '* Deleting table of opened files is important'
        YRG<-1> = '    MATREAD R.COMPANY FROM YF.COMPANY, YCOM ELSE'
        YRG<-1> = '      TEXT = "MISSING FILE=F.COMPANY ID=":YCOM'
        YRG<-1> = '      CALL FATAL.ERROR ("RGS.':YPGM.NAME:'"); RETURN'
        YRG<-1> = '    END'
*
** GB9800070
** ---------
*
        YRG<-1> = '    CALL LOAD.COMPANY(YCOM)'
        GOSUB CREATE.PW.TABLE
    END
*------------------------------------------------------------------------
*
* Define Source Code: Open files
*
    IF YT.MODIF.FILE THEN
        YCOUNT = COUNT(YT.MODIF.FILE,FM)+1
        FOR YAF = 1 TO YCOUNT
            YFILE = YT.MODIF.FILE<YAF>
            YRG<-1> = YPRECOM:'  YFILE = "F.':YFILE:'"; YF.':YFILE:' = ""'
            YRG<-1> = YPRECOM:'  CALL OPF (YFILE, YF.':YFILE:')'
        NEXT YAF
    END
*
*------------------------------------------------------------------------
*
* Define Source Code Part: Reading file ID's
*
    YPRE = "" ; YPRESUB = "" ; YT.MNE = ""
    YCOUNT.FILE = COUNT(R.NEW(RG.CRE.READ.FILE),VM)+1
    FOR YAV.FILE = 1 TO YCOUNT.FILE
        YT.FILE.FIELD = ""
        IF R.NEW(RG.CRE.FL.DECISION)<1,YAV.FILE,1> = 'KEY' THEN
            YFILE = R.NEW(RG.CRE.FL.DECIS.FR)<1,YAV.FILE,1>
        END ELSE
            YFILE = R.NEW(RG.CRE.READ.FILE)<1,YAV.FILE>
        END
        YRG<-1> = STR("*",73)
        YRG<-1> = YPRECOM:'  YFILE = "':YFILE:'"'
        YRG<-1> = YPRECOM:'  FULL.FNAME = "F.':YFILE:'"; YF.':YFILE:' = ""'
        YRG<-1> = YPRECOM:'  LOCATE YFILE IN YT.SMS<1,1> SETTING X ELSE'
        YRG<-1> = YPRECOM:'    X = 0; T.PWD = ""'
        YRG<-1> = YPRECOM:'  END'
        YRG<-1> = YPRECOM:'  IF X THEN'
        YRG<-1> = YPRECOM:'    T.PWD = YT.SMS<2,X>'
        YRG<-1> = YPRECOM:'    CONVERT SM TO FM IN T.PWD'
        YRG<-1> = YPRECOM:'  END'
        READV YPGMTYP FROM F.PGM.FILE, YFILE["$",1,1], 1 ELSE
            E = "EB.RTN.MISS.FILE.PGM.FILE.ID..1":FM:YFILE ; GOTO PGM.ERROR ; GOTO PGM.ERROR
        END
        YPRETBL = YPRECOM ; YSEL = ""
        YRG<-1> = YPRECOM:'  CALL OPF (FULL.FNAME, YF.':YFILE:')'
        SUBROUTINE.TO.CALL = ""
        IF R.NEW(RG.CRE.FL.DECISION)<1,YAV.FILE,1> = 'KEY' OR R.NEW(RG.CRE.FL.DECISION)<1,YAV.FILE,1> = "SUB" THEN
            YFL.FIELD.NO = ""
            YFL.DECISION = ""
            YFL.DECIS.FR = ""
            YFL.DECIS.TO = ""
            YFL.REL.NEXT = ""
            IF R.NEW(RG.CRE.FL.DECISION)<1,YAV.FILE,1> = "SUB" THEN
                SUBROUTINE.TO.CALL = R.NEW(RG.CRE.FL.DECIS.FR)<1,YAV.FILE,1>
                YFILE2 = ""
            END ELSE
                YFILE2 = YFILE
            END
        END ELSE
            YFILE2 = ""
            YFL.FIELD.NO = R.NEW(RG.CRE.FL.FIELD.NO)<1,YAV.FILE>
            YFL.DECISION = R.NEW(RG.CRE.FL.DECISION)<1,YAV.FILE>
            YFL.DECIS.FR = R.NEW(RG.CRE.FL.DECIS.FR)<1,YAV.FILE>
            YFL.DECIS.TO = R.NEW(RG.CRE.FL.DECIS.TO)<1,YAV.FILE>
            YFL.REL.NEXT = R.NEW(RG.CRE.FL.REL.NEXT)<1,YAV.FILE>
        END
        LOOP UNTIL YFL.FIELD.NO = "" DO
            IF NOT(YSEL) THEN YSEL = ' WITH '
            YFIELD.NO = YFL.FIELD.NO<1,1,1> ; DEL YFL.FIELD.NO<1,1,1>
            IF YFIELD.NO THEN
                LOCATE YFIELD.NO IN YT.FILE.FIELD<1> SETTING YFLD.LOC
                ELSE YT.FILE.FIELD<-1> = YFIELD.NO
                YSEL.FLD = 'FLD'
                IF YFLD.LOC > 1 THEN YSEL.FLD := YFLD.LOC
                YSEL.FLD := ".':TNO:'"
            END ELSE
                YSEL.FLD = '@ID'
            END
            YDECISION = YFL.DECISION<1,1,1> ; DEL YFL.DECISION<1,1,1>
            YFR = YFL.DECIS.FR<1,1,1> ; DEL YFL.DECIS.FR<1,1,1>
            YTO = YFL.DECIS.TO<1,1,1> ; DEL YFL.DECIS.TO<1,1,1>
            BEGIN CASE
            CASE YDECISION = "EQ"
                IF YTO = "" THEN
                    YSEL := YSEL.FLD:' = ':YFR
                END ELSE
                    YSEL := YSEL.FLD:' >= ':YFR:' AND ':YSEL.FLD:' <= ':YTO
                END
            CASE YDECISION = "GE" ; YSEL := YSEL.FLD:' >= ':YFR
            CASE YDECISION = "GT" ; YSEL := YSEL.FLD:' > ':YFR
            CASE YDECISION = "LE" ; YSEL := YSEL.FLD:' <= ':YFR
            CASE YDECISION = "LK" ; YSEL := YSEL.FLD:' LIKE ':YFR
            CASE YDECISION = "LT" ; YSEL := YSEL.FLD:' < ':YFR
            CASE YDECISION = "NE"
                IF YTO = "" THEN
                    YSEL := YSEL.FLD:' <> ':YFR
                END ELSE
                    YSEL := YSEL.FLD:' < ':YFR:' OR ':YSEL.FLD:' > ':YTO
                END
            CASE YDECISION = "UL" ; YSEL := YSEL.FLD:' UNLIKE ':YFR
            END CASE
            YREL.NEXT = YFL.REL.NEXT<1,1,1> ; DEL YFL.REL.NEXT<1,1,1>
            IF YREL.NEXT THEN
                IF YREL.NEXT = "OR" THEN YSEL := ' OR WITH '
                ELSE YSEL := ' AND '
            END ELSE
                IF YFL.FIELD.NO <> "" THEN YSEL := ' AND '
            END
        REPEAT
*
*------------------------------------------------------------------------
*
* Write field parameters to VOC file to make SELECT with field numbers
* possible:
*
        IF YT.FILE.FIELD THEN
            V$FUNCTION = "REPGEN.SOURCE"
            V = 1 ; ROUTINE = YFILE["$",1,1] ; CALL @ROUTINE ; V$FUNCTION = ""
            ID.R = "" ; MAT R = "" ; ID.F = "" ; ID.N = ""
            ID.CHECKFILE = "" ; ID.CONCATFILE = ""
            MAT CHECKFILE = "" ; MAT CONCATFILE = ""
            YCOUNT.FILE.FLD = COUNT(YT.FILE.FIELD,FM)+1
            FOR YLOC.FLD = 1 TO YCOUNT.FILE.FLD
                YSELECTFIELD = YT.FILE.FIELD<YLOC.FLD>
                YLEN = FIELD(N(YSELECTFIELD),".",1)+0
                YRG<-1> = YPRECOM:'  YR.VOC = "D"; YR.VOC<2> = ':YSELECTFIELD
                YT1 = T(YSELECTFIELD)<1> ; YT2 = T(YSELECTFIELD)<2,1>
                YMASK = T(YSELECTFIELD)<4>
                IF YT1 = "CUS" THEN YLEN = 6
* Customer number = 6 digits (also for Mnemonic 10 defined)
                IF YMASK THEN
                    YLEN = COUNT(YMASK,"#")+COUNT(YMASK,"D")
* Define number of characters by mask parameters
                END
                YASC = "L"
                BEGIN CASE
                CASE YT1 = ""
                    BEGIN CASE
                    CASE YT2 = "" OR YT2 = "-" ; YASC = "R"
                    CASE INDEX(YT2,"...",1)
                        IF NUM(FIELD(YT2,".",1)) = NUMERIC THEN
                            IF NUM(FIELD(YT2,".",4)) = NUMERIC THEN
                                YASC = "R"
                            END
                        END
                    CASE OTHERWISE
                        YCOUNT = COUNT(YT2,"_")+1 ; YASC = "R"
                        FOR YA = 1 TO YCOUNT
                            IF NUM(FIELD(YT2,"_",YA)) = NOTNUMERIC THEN
                                YASC = "L" ; YCOUNT = 0
                            END
                        NEXT YA
                    END CASE
                CASE YT1 = ".ACCD" ; YASC = "R"
                CASE YT1 = ".CCYD" ; YASC = "R"
                CASE YT1 = ".D" ; YASC = "R"
                CASE YT1 = ".YM" ; YASC = "R"
                CASE YT1 = "ACC" ; YASC = "R"
                CASE YT1 = "ALL" ; YASC = "R"
                CASE YT1 = "AMT" ; YASC = "R"
                CASE YT1 = "ANT" ; YASC = "R"
                CASE YT1 = "CUS" ; YASC = "R"
                CASE YT1 = "INT" ; YASC = "R"
                CASE YT1 = "NOSACC" ; YASC = "R"
                CASE YT1 = "NOSALL" ; YASC = "R"
                CASE YT1 = "NOSANT" ; YASC = "R"
                END CASE
                YRG<-1> = YPRECOM:'  YR.VOC<5> = "':YLEN:YASC:'"'
                BEGIN CASE
                CASE F(YSELECTFIELD)[1,2] <> "XX"
                    YRG<-1> = YPRECOM:'  YR.VOC<6> = 1'
                CASE F(YSELECTFIELD)[4,2] = "XX"
                    YRG<-1> = YPRECOM:'  YR.VOC<6> = "S"'
                CASE F(YSELECTFIELD) = "XX.LOCAL.REF"
                    YRG<-1> = YPRECOM:'  YR.VOC<6> = "S"'
                CASE OTHERWISE
                    YRG<-1> = YPRECOM:'  YR.VOC<6> = "M"'
                END CASE
                YSEL.FLD = '"FLD'
                IF YLOC.FLD > 1 THEN YSEL.FLD := YLOC.FLD
                YSEL.FLD := '.":TNO'
                YRG<-1> = YPRECOM:'  WRITE YR.VOC TO YF.VOC, ':YSEL.FLD
            NEXT YLOC.FLD
            MAT F = "" ; MAT N = ""
        END
*
*------------------------------------------------------------------------
*
        YRG<-1> = YPRECOM:'  CLEARSELECT'
        IF YSEL THEN
            YRG<-1> = '  EXECUTE "HUSH ON"'
            YRG<-1> = "  EXECUTE 'SELECT ':FULL.FNAME:":"'":YSEL:"'"
            YRG<-1> = '  EXECUTE "HUSH OFF"'
            YRG<-1> = "  CALL EB.READLIST('', YID.LIST, '', '', '')"
        END ELSE
            IF SUBROUTINE.TO.CALL THEN
                YRG<-1> = YPRECOM:'  CALL ':SUBROUTINE.TO.CALL:'(FULL.FNAME)'
            END ELSE
                YRG<-1> = YPRECOM:'  SELECT YF.':YFILE
            END
            YRG<-1> = YPRECOM:"  CALL EB.READLIST('', YID.LIST, '', '', '')"
        END
        IF YFILE2 NE "" THEN
            YFILE = R.NEW(RG.CRE.READ.FILE)<1,YAV.FILE>
            YRG<-1> = YPRECOM:'  YFILE = "':YFILE:'"'
            YRG<-1> = YPRECOM:'  FULL.FNAME = "F.':YFILE:'"; YF.':YFILE:' = ""'
            YRG<-1> = YPRECOM:'  LOCATE YFILE IN YT.SMS<1,1> SETTING X ELSE'
            YRG<-1> = YPRECOM:'    X = 0; T.PWD = ""'
            YRG<-1> = YPRECOM:'  END'
            YRG<-1> = YPRECOM:'  IF X THEN'
            YRG<-1> = YPRECOM:'    T.PWD = YT.SMS<2,X>'
            YRG<-1> = YPRECOM:'    CONVERT SM TO FM IN T.PWD'
            YRG<-1> = YPRECOM:'  END'
            READV YPGMTYP FROM F.PGM.FILE, YFILE["$",1,1] ,1 ELSE
                E = "EB.RTN.MISS.FILE.PGM.FILE.ID..1":FM:YFILE ; GOTO PGM.ERROR ; GOTO PGM.ERROR
            END
            YPRETBL = YPRECOM ; YSEL = ""
            YRG<-1> = YPRECOM:'  CALL OPF (FULL.FNAME, YF.':YFILE:')'
            YRG<-1> = YPRECOM:'  LOOP'
            YRG<-1> = YPRECOM:'    REMOVE WR.NEW FROM YID.LIST SETTING YDELIM'
            YRG<-1> = YPRECOM:'  WHILE WR.NEW:YDELIM'
            YRG<-1> = YPRECOM:'    READ YR.KEYS FROM YF.':YFILE2:', WR.NEW ELSE YR.KEYS = ""'
            YRG<-1> = YPRECOM:'      LOOP UNTIL YR.KEYS = "" DO'
            YRG<-1> = YPRECOM:'        ID.NEW = YR.KEYS<1>; DEL YR.KEYS<1>'
            YPRETBL = "    ":YPRETBL
        END ELSE
            YRG<-1> = YPRECOM:'  LOOP'
            YRG<-1> = YPRECOM:'    REMOVE ID.NEW FROM YID.LIST SETTING YDELIM'
            YRG<-1> = YPRECOM:'  WHILE ID.NEW:YDELIM'
        END
        IF YPGMTYP = "T" THEN
            YRG<-1> = YPRETBL:'    READ YR.NEW FROM YF.':YFILE:', ID.NEW ELSE ID.NEW = ""'
        END ELSE
            YSPLIT = YT.SPLIT<YAV.FILE>
            IF YSPLIT THEN
                YRG<-1> = YPRETBL:'    MATREAD R.OLD FROM YF.':YFILE:', ID.NEW ELSE ID.NEW = "" ; MAT R.OLD = ""'
                YRG<-1> = YPRETBL:'    IF T.PWD THEN'
                YRG<-1> = YPRETBL:'      MAT R.NEW = MAT R.OLD'
                YRG<-1> = YPRETBL:'      CALL CONTROL.USER.PROFILE ("RECORD")'
                YRG<-1> = YPRETBL:'      IF ETEXT THEN ID.NEW = ""'
                YRG<-1> = YPRETBL:'    END'
            END ELSE
                YRG<-1> = YPRETBL:'    MATREAD R.NEW FROM YF.':YFILE:', ID.NEW ELSE ID.NEW = "" ; MAT R.NEW = ""'
                YRG<-1> = YPRETBL:'    IF T.PWD THEN'
                YRG<-1> = YPRETBL:'      CALL CONTROL.USER.PROFILE ("RECORD")'
                YRG<-1> = YPRETBL:'      IF ETEXT THEN ID.NEW = ""'
                YRG<-1> = YPRETBL:'    END'
            END
        END
        YRG<-1> = YPRETBL:'    IF ID.NEW <> "" THEN'
*
*------------------------------------------------------------------------
*
        YRG<-1> = '*'
        YRG<-1> = '* Handle Decision Table'
*
        YCOUNT.GROUP = COUNT(R.NEW(RG.CRE.GROUP),VM)+1
        YDECNO = YSTMNO ; YT.MNE = ""
        FOR YIND = 1 TO YCOUNT.GROUP
            YGROUP = R.NEW(RG.CRE.GROUP)<1,YIND>
            IF YPGMTYP = "T" THEN
*
* PGM.TYPE 'T' handles every field of the tabel like a record:
*
                YRG<-1> = YPRETBL:'      LOOP UNTIL YR.NEW = "" DO'
                YPRETBL := "  "
                YRG<-1> = YPRETBL:'      R.NEW(1) = YR.NEW<1>; DEL YR.NEW<1>'
            END ELSE
                YSPLIT = YT.SPLIT<YAV.FILE>
                IF YSPLIT THEN
*
* File has a table with splitted fields:
*
                    YRG<-1> = YPRETBL:'      MAT R.NEW = MAT R.OLD'
                    YRG<-1> = YPRETBL:'      YSPLIT.COUNT = COUNT(R.OLD(':YSPLIT<1,1>:'),VM)+1'
                    LOOP
                        DEL YSPLIT<1,1>
                    WHILE YSPLIT DO
                        YRG<-1> = YPRETBL:'      IF COUNT(R.OLD(':YSPLIT<1,1>:'),VM) >= YSPLIT.COUNT THEN'
                        YRG<-1> = YPRETBL:'        YSPLIT.COUNT = COUNT(R.OLD(':YSPLIT<1,1>:'),VM)+1'
                        YRG<-1> = YPRETBL:'      END'
                    REPEAT
                    YRG<-1> = YPRETBL:'      FOR YAV.SPLIT = 1 TO YSPLIT.COUNT'
                    YPRETBL := "  "
                    YSPLIT = YT.SPLIT<YAV.FILE>
                    YRG<-1> = YPRETBL:'      YSPLIT.COUNT.AS = COUNT(R.OLD(':YSPLIT<1,1>:')<1,YAV.SPLIT>,SM)+1'
                    LOOP
                        DEL YSPLIT<1,1>
                    WHILE YSPLIT DO
                        YRG<-1> = YPRETBL:'      IF COUNT(R.OLD(':YSPLIT<1,1>:')<1,YAV.SPLIT>,SM) >= YSPLIT.COUNT.AS THEN'
                        YRG<-1> = YPRETBL:'        YSPLIT.COUNT.AS = COUNT(R.OLD(':YSPLIT<1,1>:')<1,YAV.SPLIT>,SM)+1'
                        YRG<-1> = YPRETBL:'      END'
                    REPEAT
                    YRG<-1> = YPRETBL:'      FOR YAS.SPLIT = 1 TO YSPLIT.COUNT.AS'
                    YPRETBL := "  "
                    YSPLIT = YT.SPLIT<YAV.FILE>
                    LOOP WHILE YSPLIT DO
                        YRG<-1> = YPRETBL:'      R.NEW(':YSPLIT<1,1>:') = R.OLD(':YSPLIT<1,1>:')<1,YAV.SPLIT,YAS.SPLIT>'
                        DEL YSPLIT<1,1>
                    REPEAT
                    YSPLIT = 1
                END
            END
            IF R.NEW(RG.CRE.GROUP.DEC.NAME)<1,YIND> = "" THEN
                YSTM = YPRETBL:'      '
                IF YCOUNT.GROUP > 1 THEN
                    YSTM = YSTM:'YGROUP = "':YGROUP:'"; '
                END
                IF R.NEW(RG.CRE.GLOBAL.DEC.NAME) = "" THEN
                    YRG<-1> = YSTM:'GOSUB 2000000'
                END ELSE
                    YRG<-1> = YSTM:'GOSUB 1000000'
                END
                GOTO AFTER.GROUP.DECISION
            END
            YDECISION.NAME = R.NEW(RG.CRE.GROUP.DEC.NAME)<1,YIND>
            YDEC.SEQU = "GROUP" ; GOSUB UPDATE.DECISION.STATEMENT
*
AFTER.GROUP.DECISION:
*
            IF YPGMTYP = "T" THEN
                YPRETBL = YPRETBL[3,99]
                YRG<-1> = YPRETBL:'      REPEAT'
            END ELSE
                IF YSPLIT THEN
                    YPRETBL = YPRETBL[3,99]
                    YRG<-1> = YPRETBL:'      NEXT YAS.SPLIT'
                    YPRETBL = YPRETBL[3,99]
                    YRG<-1> = YPRETBL:'      NEXT YAV.SPLIT'
                END
            END
            IF YCOUNT.AS > 1 THEN YRG<-1> = YDECNO:':'
            YDECNO += 1
        NEXT YIND
        YRG<-1> = YPRETBL:'    END'
        IF YFILE2 NE "" THEN
            YRG<-1> = YPRECOM:'      REPEAT'
        END
        YRG<-1> = '*'
*
*------------------------------------------------------------------------
*
        YRG<-1> = YPRECOM:'  REPEAT'
        YSTMNO += 1000
    NEXT YAV.FILE
*
    IF YPRECOM <> "" THEN
        YRG<-1> = '  REPEAT'
        YRG<-1> = '  MAT R.COMPANY = MAT R.COMPANY.SAVE'
        YRG<-1> = '  T.OPF=""; OPF.NO=0'
    END
*
* Set printer variables
*
    YRG<-1> = '  IF YKEYNO THEN'
    IF R.NEW(RG.CRE.CUST.PRINT.MNE) THEN
        YRG<-1> = '  YR.REC(':YDIM.RECNO:')  := FM:YM.':R.NEW(RG.CRE.CUST.PRINT.MNE)
    END ELSE
        YRG<-1> = '  YR.REC(':YDIM.RECNO:')  := FM'
    END
    IF R.NEW(RG.CRE.ACCT.PRINT.MNE) THEN
        YRG<-1> = '  YR.REC(':YDIM.RECNO:')  := FM:YM.':R.NEW(RG.CRE.ACCT.PRINT.MNE)
    END
    YRG<-1> = '     MATWRITE YR.REC TO F.FILE, YKEY'
    YRG<-1> = '  END '
*
* Write (last) used Table and Sequence Table
*
    YRG<-1> = '*'
    YRG<-1> = '  IF NOT(PHNO) THEN PRINT @(41,L1ST-3):YBLOCKNO+YWRITNO:'
*
** GB9800070
** ---------
*
    YRG<-1> = '  IF SAVE.ID.COMPANY # ID.COMPANY THEN'
    YRG<-1> = '     CALL LOAD.COMPANY(SAVE.ID.COMPANY)'
    YRG<-1> = '  END'
    YRG<-1> = '  RETURN'
    YRG<-1> = STR("*",73)
*
*------------------------------------------------------------------------
*
* Exclude Fields by Global decision (Group from/to defined)
*
    IF R.NEW(RG.CRE.GLOBAL.DEC.NAME) THEN
        YRG<-1> = '*'
        YRG<-1> = '* Handle Global Decision Table'
        YRG<-1> = '1000000:'
        YRG<-1> = '*'
*
        FOR YAV.FILE = 1 TO YCOUNT.FILE
            IF YAV.FILE > 1 THEN
                YRG<-1> = '*':STR("-",72)
            END
            YT.MNE = "" ; YFILE = R.NEW(RG.CRE.READ.FILE)<1,YAV.FILE>
            IF YCOUNT.FILE = 1 THEN
                YPRE = ""
            END ELSE
                YPRE = "  "
                YRG<-1> = '  IF YFILE = "':YFILE:'" THEN'
            END
            YCOUNT.GROUP = COUNT(R.NEW(RG.CRE.DECIS.GROUP.FR),VM)+1
            FOR YIND = 1 TO YCOUNT.GROUP
                YFROM = R.NEW(RG.CRE.DECIS.GROUP.FR)<1,YIND>
                IF YFROM THEN
                    YTO = R.NEW(RG.CRE.DECIS.GROUP.TO)<1,YIND>
                    IF YFROM[1,1] = '"' THEN
                        X = LEN(YFROM)-2 ; IF X THEN
                            IF NUM(YFROM[2,X]) = NUMERIC THEN
                                YFROM = YFROM[2,X]
                            END
                        END
                    END
                    IF YTO[1,1] = '"' THEN
                        X = LEN(YTO)-2 ; IF X THEN
                            IF NUM(YTO[2,X]) = NUMERIC THEN YTO = YTO[2,X]
                        END
                    END
                    YRG<-1> = YPRE:'  IF YGROUP >= ':YFROM:' AND YGROUP <= ':YTO:' THEN'
                    YPRE := "  "
                END
                YDECISION.NAME = R.NEW(RG.CRE.GLOBAL.DEC.NAME)<1,YIND>
                YDEC.SEQU = "GLOBAL" ; GOSUB UPDATE.DECISION.STATEMENT
                IF R.NEW(RG.CRE.DECIS.GROUP.FR) THEN
                    YRG<-1> = YPRE:'  RETURN'
                    YRG<-1> = YPRE:'END'
                    YPRE = YPRE[1,LEN(YPRE)-2]
                END
            NEXT YIND
            IF YPRE <> "" THEN
                YRG<-1> = '    GOTO 2000000'
                YRG<-1> = '  END'
            END
        NEXT YAV.FILE
        IF R.NEW(RG.CRE.DECIS.GROUP.FR) = "" THEN
            YRG<-1> = '  RETURN'
        END
*
        YRG<-1> = STR("*",73)
    END
*
*------------------------------------------------------------------------
*
* Define Source Code: Define and Write record
*
    YRG<-1> = '*'
    YRG<-1> = '* Define and Write record'
    YRG<-1> = '2000000:'
    YRG<-1> = '*'
*
    IF YCOUNT.FILE > 1 THEN
        YRG<-1> = '  BEGIN CASE'
    END
    FOR YAV.FILE = 1 TO YCOUNT.FILE
        IF YAV.FILE > 1 THEN
            YRG<-1> = '*':STR("-",72)
        END
        YFILE = R.NEW(RG.CRE.READ.FILE)<1,YAV.FILE>
        IF YCOUNT.FILE = 1 THEN
            YPRE = ""
        END ELSE
            YPRE = "    "
            YRG<-1> = '    CASE YFILE = "':YFILE:'"'
        END
        YCOUNT.GROUP = COUNT(R.NEW(RG.CRE.GROUP),VM)+1
        IF YCOUNT.GROUP > 1 THEN
            YRG<-1> = YPRE:'  BEGIN CASE'
        END
        FOR YIND = 1 TO YCOUNT.GROUP
            IF YIND > 1 THEN YRG<-1> = '*'
            YT.MNE = "" ; YGROUP = R.NEW(RG.CRE.GROUP)<1,YIND>
            IF NOT(YGROUP.LENGTH) THEN
                IF R.NEW(RG.CRE.SORT.FILE.TYPE) = 1 THEN
                    YRG<-1> = YPRE:'  YKEY = "C"; MAT YR.REC = ""'
                END ELSE
                    YRG<-1> = YPRE:'  YKEY = ""; MAT YR.REC = ""'
                END
            END ELSE
                YRG<-1> = YPRE:'    CASE YGROUP = "':YGROUP:'"'
                YPRE := "    "
                IF R.NEW(RG.CRE.SORT.FILE.TYPE) = 1 THEN
                    YRG<-1> = YPRE:'  YKEY = "C":"':FMT(YGROUP,YGROUP.LENGTH:'"0"R'):'"; MAT YR.REC = ""'
                END ELSE
                    YRG<-1> = YPRE:'  YKEY = "':FMT(YGROUP,YGROUP.LENGTH:'"0"R'):'"; MAT YR.REC = ""'
                END
            END
            YCURR.FDNO = 0
            GOSUB DEFINE.MNEMONIC.SEQUENCE
            FOR YAV.WR = 1 TO YCOUNT.WR
                GOSUB DEFINE.MNEMONIC.WITHIN.LOOP
                IF R.NEW(RG.CRE.KEY.TYPE)<1,YAV.MNE> OR R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE> THEN
                    YAV.MNE.SAVE.DISPL = YAV.MNE ; YDEC.SEQU = ""
                    YT.MNE.SAVE = "" ; YMOD = "" ; YMOD.VALTYP = ""
                    YPRESUB = YPRE ; GOSUB DEFINE.MNEMONIC.FIELD
                    YAV.MNE = YAV.MNE.SAVE.DISPL
                    YMNE = R.NEW(RG.CRE.DEFINE.MNEMONIC)<1,YAV.MNE>
                    YMASK = R.NEW(RG.CRE.MASK)<1,YAV.MNE>
                    IF R.NEW(RG.CRE.KEY.TYPE)<1,YAV.MNE> THEN
                        YSUFFIX = YT.MNE.VALTYP<YAV.MNE>
                        IF YSUFFIX = "M" THEN YSUFFIX = "<1,1>"
                        IF YSUFFIX = "S" THEN YSUFFIX = "<1,1,1>"
                        YCHR = R.NEW(RG.CRE.NUMBER.OF.CHAR)<1,YAV.MNE>
                        BEGIN CASE
                        CASE YMASK = "@DATE"
                            YRG<-1> = YPRE:'  YKEYFD = YM.':YMNE:YSUFFIX
                            YRG<-1> = YPRE:'  YKEYFD = FMT(YM.':YMNE:YSUFFIX:',"':YCHR:'L")'
*
                        CASE NOT(YMASK)
* GB9701367 +
* GB9800096 +
                            YCHR += 2   ;* This ID will always be 2 longer than the base
                            YRG<-1> = YPRE:'  YKEYFD = YM.':YMNE:YSUFFIX

                            YRG := FM
                            YRG := FM:YPRE:'* check ID to see if it matches keys with contract no. in the format'
                            YRG := FM:YPRE:'* xxyydddnnnnn. if it does, extend the year (yy) component of the key'
                            YRG := FM:YPRE:'* to yyyy and use this as the id to the REPGEN work file. all the'
                            YRG := FM:YPRE:'* aforementioned processing is done in ENQ.BUILD.TXN and is part of'
                            YRG := FM:YPRE:'* Year 2000 compliance':FM

                            YRG := FM:YPRE:'  FULL.TXN.ID = ""'
                            YRG := FM:YPRE:'  CALL ENQ.BUILD.TXN(FULL.TXN.ID,YKEYFD)':FM
                            YRG := FM:YPRE:'  YKEYFD = FMT(YM.':YMNE:YSUFFIX:',"':YCHR:'L")':FM
                            YRG := FM
* GB9800096 -
* GB9701367 -
                        CASE YMASK[1,4] = "@AMT"
*
* Change '-' to 'A' and '+' to 'B' as these are invalid chars for keys.
* EB8800298
*
                            YRG<-1> = YPRE:'  YKEYFD = FMT(YM.':YMNE:YSUFFIX:',"':YCHR:'R':YMASK[5,1]:'")'
                            YRG<-1> = YPRE:'  IF YM.':YMNE:YSUFFIX:'[1,1] = "-" THEN YKEYFD[1,1] = "A" ELSE YKEYFD[1,1] = "B"'
                        CASE INDEX(YMASK,"#",1)
                            YRG<-1> = YPRE:'  YKEYFD = FMT(YM.':YMNE:YSUFFIX:',"':YMASK:'")'
                        CASE OTHERWISE
                            YMNE.SAVE = YMNE ; YMNE = YMASK
                            YAV.MNE.SAVE = YAV.MNE
                            GOSUB DEFINE.MNEMONIC.FIELD
                            YRG<-1> = YPRE:'  YDEC = "NO.OF.DECIMALS"; CALL UPD.CCY (YM.':YMNE:', YDEC)'
                            YMNE = YMNE.SAVE ; YAV.MNE = YAV.MNE.SAVE
                            YRG<-1> = YPRE:'  YKEYFD = FMT(YM.':YMNE:YSUFFIX:',"':YCHR:'R":YDEC:",")'
                        END CASE
                        YRG<-1> = YPRE:'  IF LEN(YKEYFD) > ':YCHR:' THEN YKEYFD = YKEYFD[1,':YCHR-1:']:"|"'
                        YRG<-1> = YPRE:'  GOSUB 8000000'
                    END
                    IF R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE> THEN
                        IF YMASK THEN IF YMASK[1,1] <> "@" THEN
                            IF NOT(INDEX(YMASK,"#",1)) THEN
                                YMNE.SAVE = YMNE ; YMNE = YMASK
                                YAV.MNE.SAVE = YAV.MNE
                                GOSUB DEFINE.MNEMONIC.FIELD
                                YRG<-1> = YPRE:'  YDEC = "NO.OF.DECIMALS"; CALL UPD.CCY (YM.':YMNE:', YDEC)'
                                YMNE = YMNE.SAVE ; YAV.MNE = YAV.MNE.SAVE
                                YMOD.VALTYP = YT.MNE.VALTYP<YAV.MNE>
                                BEGIN CASE
                                CASE YMOD.VALTYP = ""
                                    YRG<-1> = YPRE:'  IF YM.':YMNE:' <> "" THEN'
                                    YRG<-1> = YPRE:'    YM.':YMNE:' = TRIM(FMT(YM.':YMNE:',"19R":YDEC))'
                                    YRG<-1> = YPRE:'  END'
                                CASE YMOD.VALTYP = "M"
                                    YRG<-1> = YPRE:'  YCOUNT.RPL = COUNT(YM.':YMNE:',VM)+1'
                                    YRG<-1> = YPRE:'  FOR YAV.RPL = 1 TO YCOUNT.RPL'
                                    YSUFFIX = "<1,YAV.RPL>"
                                    YRG<-1> = YPRE:'    IF YM.':YMNE:YSUFFIX:' <> "" THEN'
                                    YRG<-1> = YPRE:'      YM.':YMNE:YSUFFIX:' = TRIM(FMT(YM.':YMNE:YSUFFIX:',"19R":YDEC))'
                                    YRG<-1> = YPRE:'    END'
                                    YRG<-1> = YPRE:'  NEXT YAV.RPL'
                                CASE YMOD.VALTYP = "S"
                                    YRG<-1> = YPRE:'  YCOUNT.RPL = COUNT(YM.':YMNE:',VM)+1'
                                    YRG<-1> = YPRE:'  FOR YAV.RPL = 1 TO YCOUNT.RPL'
                                    YRG<-1> = YPRE:'    YCOUNT.AS.RPL = COUNT(YM.':YMNE:'<1,YAV.RPL>,SM)+1'
                                    YRG<-1> = YPRE:'    FOR YAS.RPL = 1 TO YCOUNT.AS.RPL'
                                    YSUFFIX = "<1,YAV.RPL,YAS.RPL>"
                                    YRG<-1> = YPRE:'      IF YM.':YMNE:YSUFFIX:' <> "" THEN'
                                    YRG<-1> = YPRE:'        YM.':YMNE:YSUFFIX:' = TRIM(FMT(YM.':YMNE:YSUFFIX:',"19R":YDEC))'
                                    YRG<-1> = YPRE:'      END'
                                    YRG<-1> = YPRE:'    NEXT YAS.RPL'
                                    YRG<-1> = YPRE:'  NEXT YAV.RPL'
                                END CASE
* update amount with 0, 2 or 3 decimals (e.g. 1.1 = 1.10) to have the
* definition for printout pgm. (when decimals are currency related)
                            END
                        END
                        YCURR.FDNO += 1
                        YRG<-1> = YPRE:'  YR.REC(':YCURR.FDNO:') = YM.':YMNE
                    END
                END
            NEXT YAV.WR
            IF YCOUNT.GROUP > 1 THEN YPRE = YPRE[1,LEN(YPRE)-4]
        NEXT YIND
        IF YCOUNT.GROUP > 1 THEN
            YRG<-1> = YPRE:'  END CASE'
        END
    NEXT YAV.FILE
    IF YPRE <> "" THEN YRG<-1> = '  END CASE'
*
    YRG<-1> = '*'
    YRG<-1> = '  YKEYNO = YKEYNO + 1'
    YSTM = '"0"' ; YSTM = "'5":YSTM:"R'"
    YRG<-1> = '  IF YKEYNO > 9999 THEN'
    YRG<-1> = '    YKEY = YKEY:YKEYNO'
    YRG<-1> = '  END ELSE'
    YRG<-1> = '    YKEY = YKEY : FMT(YKEYNO,':YSTM:')'
    YRG<-1> = '  END'
    YRG<-1> = '  MATWRITE YR.REC TO F.FILE, YKEY'
    YRG<-1> = '*'
    YRG<-1> = '  IF NOT(PHNO) THEN'
    YRG<-1> = '    IF YWRITNO < 9 THEN'
    YRG<-1> = '      YWRITNO = YWRITNO + 1'
    YRG<-1> = '    END ELSE'
    YRG<-1> = '      YWRITNO = 0; YBLOCKNO = YBLOCKNO + 10'
    YRG<-1> = '      PRINT @(41,L1ST-3):YBLOCKNO+YWRITNO:'
    YRG<-1> = '    END'
    YRG<-1> = '  END'
    YRG<-1> = '  RETURN'
    YRG<-1> = STR("*",73)
*
*------------------------------------------------------------------------
*
* Convert invalid key characters
*
    YRG<-1> = '*'
    YRG<-1> = '* Update Key (and convert invalid Key char.)'
    YRG<-1> = '8000000:'
    YRG<-1> = '*'
    YRG<-1> = '  YLEN.KEY = LEN(YKEYFD)'
    YRG<-1> = '  FOR YNO = 1 TO YLEN.KEY'
    YRG<-1> = '    YKEY.CHR = YKEYFD[YNO,1]'
    YRG<-1> = '    IF YKEY.CHR < "A" THEN'
    YRG<-1> = '      IF YKEY.CHR >= 0 AND YKEY.CHR <= 9 THEN'
    YRG<-1> = '        YKEY = YKEY : YKEY.CHR'
    YRG<-1> = '      END ELSE'
    YRG<-1> = '        IF INDEX(".$",YKEY.CHR,1) THEN'
    YRG<-1> = '          YKEY = YKEY : YKEY.CHR'
    YRG<-1> = '        END ELSE'
    YRG<-1> = '          YKEY = YKEY : "&"'
    YRG<-1> = '        END'
    YRG<-1> = '      END'
    YRG<-1> = '    END ELSE'
    YRG<-1> = '      IF YKEY.CHR < "[" THEN'
    YRG<-1> = '        YKEY = YKEY : YKEY.CHR'
    YRG<-1> = '      END ELSE'
    YRG<-1> = '        IF YKEY.CHR >= "a" AND YKEY.CHR <= "z" THEN'
    YRG<-1> = '          YKEY = YKEY : YKEY.CHR'
    YRG<-1> = '        END ELSE'
    YRG<-1> = '          YKEY = YKEY : "&"'
    YRG<-1> = '        END'
    YRG<-1> = '      END'
    YRG<-1> = '    END'
    YRG<-1> = '  NEXT YNO'
    YRG<-1> = '  RETURN'
    YRG<-1> = STR("*",73)
*------------------------------------------------------------------------
*
* Define Subroutine to hold (often used) Parameters of a foreign file
*
    IF YT.MODIF.FILE THEN
        YRG<-1> = '*'
        YRG<-1> = '* Update table of Parameters of foreign file'
        YRG<-1> = '9000000:'
        YRG<-1> = '*'
        YRG<-1> = '  LOCATE YCOMP IN YT.FORFIL<1,1> SETTING YLOC.FOR ELSE'
        YRG<-1> = '    YFOR.ID = FIELD(YCOMP,"_",3)'
        YRG<-1> = '    YFOR.FD = FIELD(YCOMP,"_",2)'
        YRG<-1> = '    YFOR.AF = FIELD(YFOR.FD,".",1)'
        YRG<-1> = '    YFOR.AV = FIELD(YFOR.FD,".",2)'
        YRG<-1> = '    YFOR.AS = FIELD(YFOR.FD,".",3)'
        YRG<-1> = '*'
        YRG<-1> = '    T.PWD.SAVE = T.PWD; T.PWD = ""'
        YRG<-1> = '    IF YT.SMS THEN'
        YRG<-1> = '      LOCATE FIELD(YCOMP,"_",1) IN YT.SMS<1,1> SETTING T.PWD ELSE NULL'
        YRG<-1> = '    END'
        YRG<-1> = '    IF T.PWD THEN'
        YRG<-1> = '      MAT R.NEW.LAST = MAT R.NEW'
        YRG<-1> = '      ID.NEW.SAVE = ID.NEW; ID.NEW = YFOR.ID'
        YRG<-1> = '      MATREAD R.NEW FROM YFORFIL, ID.NEW ELSE MAT R.NEW = ""'
        YRG<-1> = '      T.PWD = YT.SMS<2,T.PWD>; CONVERT SM TO FM IN T.PWD'
        YRG<-1> = '      CALL CONTROL.USER.PROFILE ("RECORD")'
        YRG<-1> = '      IF ETEXT THEN'
        YRG<-1> = '        YFOR.FD = "@"'
        YRG<-1> = '      END ELSE'
        YRG<-1> = '        YFOR.FD = R.NEW(YFOR.AF)'
        YRG<-1> = '      END'
        YRG<-1> = '      MAT R.NEW = MAT R.NEW.LAST; ID.NEW = ID.NEW.SAVE'
        YRG<-1> = '    END ELSE'
        YRG<-1> = '      READV YFOR.FD FROM YFORFIL, YFOR.ID, YFOR.AF ELSE YFOR.FD = ""'
        YRG<-1> = '    END'
        YRG<-1> = '    T.PWD = T.PWD.SAVE; T.PWD.SAVE = ""'
        YRG<-1> = '*'
        YRG<-1> = '    IF NOT(YHANDLE.LNGG) THEN'
        YRG<-1> = '      IF YFOR.AV <> "" THEN YFOR.FD = YFOR.FD<1,YFOR.AV,YFOR.AS>'
        YRG<-1> = '    END ELSE'
        YRG<-1> = '      IF YFOR.FD<1,LNGG> = "" THEN'
        YRG<-1> = '        YFOR.FD = YFOR.FD<1,1>'
        YRG<-1> = '      END ELSE'
        YRG<-1> = '        YFOR.FD = YFOR.FD<1,LNGG>'
        YRG<-1> = '      END'
        YRG<-1> = '    END'
        YRG<-1> = '    IF NOT(COUNT(YFOR.FD,VM)) THEN'
* Don't hold multi value fields on table
        YRG<-1> = '      DEL YT.FORFIL<1,50>; DEL YT.FORFIL<2,50>'
        YRG<-1> = '      INS YCOMP BEFORE YT.FORFIL<1,1>'
        YRG<-1> = '      INS YFOR.FD BEFORE YT.FORFIL<2,1>'
        YRG<-1> = '    END'
        YRG<-1> = '    YLOC.FOR = 0'
        YRG<-1> = '  END'
        YRG<-1> = '  IF YLOC.FOR THEN YFOR.FD = YT.FORFIL<2,YLOC.FOR>'
        YRG<-1> = '  IF YPART.S <> "" THEN'
        YRG<-1> = '    YCOUNT.FOR = COUNT(YFOR.FD,VM)+1'
        YRG<-1> = '    FOR YAV.FOR = 1 TO YCOUNT.FOR'
        YRG<-1> = '      YCOUNT.AS.FOR = COUNT(YFOR.FD<1,YAV.FOR>,SM)+1'
        YRG<-1> = '      FOR YAS.FOR = 1 TO YCOUNT.AS.FOR'
        YRG<-1> = '        IF YFD.LEN = "" THEN'
        YRG<-1> = '          YFOR.FD<1,YAV.FOR,YAS.FOR> = FIELD(YFOR.FD<1,YAV.FOR,YAS.FOR>,YPART.S,YPART.L)'
        YRG<-1> = '        END ELSE'
        YRG<-1> = '          X = FMT(YFOR.FD<1,YAV.FOR,YAS.FOR>,YFD.LEN)'
        YRG<-1> = '          YFOR.FD<1,YAV.FOR,YAS.FOR> = X[YPART.S,YPART.L]'
        YRG<-1> = '        END'
        YRG<-1> = '      NEXT YAS.FOR'
        YRG<-1> = '    NEXT YAV.FOR'
        YRG<-1> = '  END'
        YRG<-1> = '  RETURN'
        YRG<-1> = STR("*",73)
    END
*
*------------------------------------------------------------------------
*
* Define @DATE/@MONTH values to be defined one time only:
*
    IF YDATMTH THEN
        YRG<-1> = '*'
        YRG<-1> = '* Hold table of already defined @DATE/@MONTH values'
        YRG<-1> = '9100000:'
        YRG<-1> = '*'
        YRG<-1> = '  LOCATE YCOMP IN YT.DATMTH<1,1> SETTING X ELSE'
        YRG<-1> = '    YDTM = OCONV(DATE(),"D-"); YDTM = YDTM[7,4]:YDTM[1,2]:YDTM[4,2]'
        YRG<-1> = '    BEGIN CASE'
        YRG<-1> = '      CASE YCOMP = ".DATE"; NULL'
        YRG<-1> = '      CASE YCOMP[1,5] = ".DATE"'
        YRG<-1> = '        IF YCOMP[6,1] = "P" THEN Y = "+" ELSE Y = "-"'
        YRG<-1> = '        Y = Y : YCOMP[7,99]; CALL CDT("", YDTM, Y)'
        YRG<-1> = '      CASE YCOMP = ".MONTH"; YDTM = YDTM[1,6]'
        YRG<-1> = '      CASE OTHERWISE'
        YRG<-1> = '        YDTM = YDTM[1,6]; YADDSUB = YCOMP[7,1]; YMTHNO = YCOMP[8,99]'
        YRG<-1> = '        LOOP WHILE YMTHNO DO'
        YRG<-1> = '          IF YADDSUB = "P" THEN'
        YRG<-1> = '            YDTM = YDTM+1'
        YRG<-1> = '            IF YDTM[5,2] > 12 THEN YDTM = YDTM[1,4]+1; YDTM = YDTM:"01"'
        YRG<-1> = '          END ELSE'
        YRG<-1> = '            YDTM = YDTM-1'
        YRG<-1> = '            IF NOT(YDTM[5,2]) THEN YDTM = YDTM[1,4]-1; YDTM = YDTM:"12"'
        YRG<-1> = '          END'
        YRG<-1> = '          YMTHNO = YMTHNO-1'
        YRG<-1> = '        REPEAT'
        YRG<-1> = '    END CASE'
        YRG<-1> = '    INS YCOMP BEFORE YT.DATMTH<1,1>'
        YRG<-1> = '    INS YDTM BEFORE YT.DATMTH<2,1>'
        YRG<-1> = '    RETURN'
        YRG<-1> = '  END'
        YRG<-1> = '  YDTM = YT.DATMTH<2,X>; RETURN'
        YRG<-1> = '  RETURN'
        YRG<-1> = STR("*",73)
    END
*
*------------------------------------------------------------------------
*
    GOSUB SMS.COMPANY.CHECK
*
*------------------------------------------------------------------------
*
    YRG<-1> = 'END'
    WRITE YRG TO F.RG.BP, "RGS.":YPGM.NAME
    YRG = ""        ;*PRINT @(0,3):
    EXECUTE "BASIC RG.BP RGS.":YPGM.NAME
    SOURCE.ITEM = "RGS.":YPGM.NAME
    SOURCE.FNAME = "RG.BP"
    GOSUB COMPILE.IN.JBASE    ;*GB0002062
    EXECUTE "CATALOG RG.BP RGS.":YPGM.NAME:" ":CATALOG.OPTION
*
*************************************************************************
*
* 2nd Source pgm: Printout and Display (if not more than 78 columns used)
*
* Define Source Code header (PRINTOUT)
*
    YRG = '  SUBROUTINE RGP.':YPGM.NAME
    YSYSDATE = OCONV(DATE(),"D-")
    YRG<-1> = 'REM "RGP.':YPGM.NAME:'",':YSYSDATE[9,2]:YSYSDATE[1,2]:YSYSDATE[4,2]:'-':YPRINTOUT.VERSION
    YRG<-1> = STR("*",73)
    YRG<-1> = '$INSERT I_COMMON'
    YRG<-1> = '$INSERT I_EQUATE'
    YRG<-1> = '$INSERT I_RC.COMMON'
    YRG<-1> = '$INSERT I_SCREEN.VARIABLES'
    YRG<-1> = '$INSERT I_F.COMPANY'
    YRG<-1> = '$INSERT I_F.LANGUAGE'
    YRG<-1> = '$INSERT I_F.USER'
*
*------------------------------------------------------------------------
*
    YRG<-1> = STR("*",73)
    YRG<-1> = 'REPORT.ID = "RG.':YPGM.NAME:'"'
    YRG<-1> = 'PRT.UNIT = 0'
    YRG<-1> = '  IF V$DISPLAY = "D" THEN YPRINTING = 0 ELSE YPRINTING = 1'
    YCT.LNGG = COUNT(R.NEW(RG.CRE.LANGUAGE.CODE),VM)
    IF R.NEW(RG.CRE.USING.132.COLUMNS) THEN
        YRG<-1> = '  IF NOT(YPRINTING) THEN IF NOT(S.COL132.ON) THEN'
        YRG<-1> = '    TEXT = "TERMINAL CANNOT DISPLAY 132 COLUMS"'
        YRG<-1> = '    CALL REM; RETURN  ;* end of pgm'
        YRG<-1> = '  END'
    END
*
*------------------------------------------------------------------------
*
    GOSUB SMS.FILE.CHECK
*
    YRG:=FM:'   F.LANGUAGE=""; CALL OPF("F.LANGUAGE",F.LANGUAGE)'
    YRG:=FM:'   READV AMOUNT.FORMAT FROM F.LANGUAGE,LNGG,EB.LAN.AMOUNT.FORMAT ELSE AMOUNT.FORMAT=""'
*
*------------------------------------------------------------------------
*
    YRG<-1> = '  CLEARSELECT'
    YRG<-1> = '  YFILE = "F":R.COMPANY(EB.COM.MNEMONIC):".RGS.':YPGM.NAME:'"'
    YRG<-1> = '  EXECUTE "HUSH ON"'
    YRG<-1> = '  EXECUTE "SSELECT ":YFILE'
    YRG<-1> = '  EXECUTE "HUSH OFF"'
    YRG<-1> = "  CALL EB.READLIST('', YID.LIST, '', '', '')"
    YRG<-1> = '  IF YPRINTING THEN'
    YRG<-1> = '    CALL PRINTER.ON(REPORT.ID,PRT.UNIT); YBLOCKNO = 0; YWRITNO = 0; COMI = C.F'
    YRG<-1> = '  END ELSE'
    IF R.NEW(RG.CRE.USING.132.COLUMNS) THEN
        YRG<-1> = '    PRINT S.COL132.ON:'
        YCOL = 132
    END ELSE
        YCOL = 80
    END
    YRG<-1> = '    PRINT @(0,L1ST-1):STR("-",':YCOL:'):'
    YRG<-1> = '    YEND = 0; Y = 1; LASTP = 1; L = L1ST; PRINT @(0,L):'
    YRG<-1> = '    FOR LL = L TO 19; PRINT S.CLEAR.EOL; NEXT LL'
    YRG<-1> = '    YTEXT = T.REMTEXT(23)'
    YRG<-1> = '* T.REMTEXT(23) = "PAGE"'
    YRG<-1> = '    PRINT @(0,20):STR("-",':YCOL:'):@(63+LEN(YTEXT),21):S.HALF.INTENSITY.OFF:@(63,21):S.HALF.INTENSITY.ON:YTEXT:S.HALF.INTENSITY.OFF:'
* Addressing a column greater than 79 is not possible
* (so Page no. can't be displayed at column 120 ff)
    YRG<-1> = '    YT.PAGE = ""; T.CONTROLWORD = C.U:FM:C.B:FM:C.F:FM:C.E:FM:C.V:FM:C.W'
    YRG<-1> = '  END'
    YRG<-1> = '  YKEY = ""; YTOTFD = ""'
    YRG<-1> = '  DIM YR.REC(':YDIM.RECNO + 2:'); MAT YR.REC = ""'
    YTOT.BLK.LIN = 0 ; YHDR.BLK.LIN = 0
    IF R.NEW(RG.CRE.ADD.BLANK.LINE) THEN
        IF R.NEW(RG.CRE.ADD.BLANK.LINE) <> "1 AFTER TOTAL" THEN
            YTOT.BLK.LIN = 1 ; YHDR.BLK.LIN = 1
        END
    END
    IF R.NEW(RG.CRE.ADD.TOT.BLANK.LINE) THEN
        IF R.NEW(RG.CRE.ADD.TOT.BLANK.LINE) <> "1 HEADER" THEN
            YTOT.BLK.LIN += 1
        END
        IF R.NEW(RG.CRE.ADD.TOT.BLANK.LINE) <> "2 TOTAL" THEN
            YHDR.BLK.LIN += 1
        END
    END
    IF YHEADER.DISPLAY THEN
        YRG<-1> = '  DIM YR.REC.OLD(':YDIM.RECNO:'); MAT YR.REC.OLD = "_"'
    END
    IF YANY.CONTIN.TOTAL THEN
        YRG<-1> = '  DIM YR.REC.TOT(':YDIM.RECNO:'); MAT YR.REC.TOT = 0'
    END
    YRG<-1> = '  GOSUB 1000000'
    YCOUNT.GROUP = COUNT(R.NEW(RG.CRE.GROUP),VM)+1
    IF YCOUNT.GROUP = 1 THEN
        GOSUB DEFINE.HEADER.TEXT ; GOSUB DEFINE.TOTAL.FIELDS
        IF NOT(YHDR.BLK.LIN) THEN
            YRG<-1> = '  YKEYFD = ""'
        END ELSE
            YRG<-1> = '  YKEYFD = ""; Y1ST.LIN = 1'
        END
        YRG<-1> = '  LOOP WHILE YKEYFD = "" DO'
        GOSUB ASK.FOR.HEADER.PRINT ; GOSUB DEFINE.PRINTOUT.LINE
        YRG<-1> = '    GOSUB 1000000'
        GOSUB ASK.FOR.TOTAL.PRINT ; GOSUB ASK.FOR.PAGING
        YRG<-1> = '  REPEAT'
    END ELSE
        YT.GROUP = "" ; YT.IND = ""
        FOR YIND = 1 TO YCOUNT.GROUP
*
* PIF GB9400135; "&R" changed "'0'R" because nothing was output
* if you were using more than 9 groups.
            YGROUP = FMT(R.NEW(RG.CRE.GROUP)<1,YIND>,YGROUP.LENGTH:"'0'R")
            LOCATE YGROUP IN YT.GROUP<1> BY "AL" SETTING YLOC ELSE NULL
            INS YGROUP BEFORE YT.GROUP<YLOC>
            INS YIND BEFORE YT.IND<YLOC>
        NEXT YIND
        Y1ST.PAGE = 1
        LOOP WHILE YT.GROUP DO
            YGROUP = YT.GROUP<1> ; DEL YT.GROUP<1>
            YIND = YT.IND<1> ; DEL YT.IND<1>
            BEGIN CASE
            CASE Y1ST.PAGE
                Y1ST.PAGE = 0
                GOSUB DEFINE.HEADER.TEXT ; GOSUB DEFINE.TOTAL.FIELDS
                IF NOT(R.NEW(RG.CRE.NEW.PAGE.FOR.GROUP)) THEN
                    GOSUB PRINT.GROUP.HEADER
                END
            CASE R.NEW(RG.CRE.NEW.PAGE.FOR.GROUP)
                YSUBGROUP = 0 ; YPRE.EOG = "  "
                GOSUB COMMON.END.OF.GROUP
                GOSUB DEFINE.HEADER.TEXT ; GOSUB DEFINE.TOTAL.FIELDS
            CASE OTHERWISE
                GOSUB DECIDE.PRINT.DISPLAY
                GOSUB PRINT.GROUP.HEADER ; GOSUB DEFINE.TOTAL.FIELDS
            END CASE
            IF YHDR.BLK.LIN OR YTOT.BLK.LIN THEN
                YRG<-1> = '  Y1ST.LIN = 1'
            END
            YRG<-1> = '  LOOP WHILE YKEYFD = "':YGROUP:'" DO'
            GOSUB ASK.FOR.HEADER.PRINT ; GOSUB DEFINE.PRINTOUT.LINE
            YRG<-1> = '    GOSUB 1000000'
            GOSUB ASK.FOR.TOTAL.PRINT ; GOSUB ASK.FOR.PAGING
            YRG<-1> = '  REPEAT'
            IF YT.GROUP THEN YRG<-1> = '*'
        REPEAT
    END
    YRG<-1> = '  YTEXT = "*** END OF REPORT ***"'
    YPRE.EOG = "  " ; GOSUB COMMON.GROUP
    YRG<-1> = '  IF YPRINTING THEN'
    YRG<-1> = '    CALL PRINTER.OFF'
    YRG<-1> = '    IF NOT(PHNO) THEN PRINT @(41,L1ST-3):YBLOCKNO+YWRITNO:'
    YRG<-1> = '    C$RPT.CUSTOMER.NO = YR.REC(':YDIM.RECNO+1:')'
    YRG<-1> = '    C$RPT.ACCOUNT.NO = YR.REC(':YDIM.RECNO+2:')'
    YRG<-1> = '    CALL PRINTER.CLOSE(REPORT.ID,PRT.UNIT,"")'
    YRG<-1> = '  END ELSE'
    YRG<-1> = '    TEXT = "END OF REPORT"; YEND = 1; GOSUB 9100000'
    YRG<-1> = '  END'
    YRG<-1> = '  RETURN'
*
*------------------------------------------------------------------------
*
    YRG<-1> = STR("*",73)
    YRG<-1> = '1000000:'
    YRG<-1> = '*'
    YRG<-1> = '  YKEY.OLD = YKEY'
    IF YHEADER.DISPLAY THEN
        YRG<-1> = '  MAT YR.REC.OLD = MAT YR.REC'
    END
    IF YANY.CONTIN.TOTAL THEN
        YRG<-1> = '  MAT YR.REC.TOT = MAT YR.REC'
    END
    YRG<-1> = '  REMOVE YKEY FROM YID.LIST SETTING YDELIM'
    YRG<-1> = '  IF NOT(YKEY:YDELIM) THEN'
    YRG<-1> = '    YKEYFD = "***"; YKEY = STR("*",188); RETURN'
    YRG<-1> = '  END'
    YRG<-1> = '  MATREAD YR.REC FROM F.FILE, YKEY ELSE MAT YR.REC = "" ; GOTO 1000000'
    IF R.NEW(RG.CRE.SORT.FILE.TYPE) > 1 THEN
        YRG<-1> = '  YKEY = "C":YKEY'
    END
    IF YGROUP.LENGTH THEN
        YRG<-1> = '  YKEYFD = YKEY[2,':YGROUP.LENGTH:']'
    END
    YRG<-1> = '  IF NOT(PHNO) AND YPRINTING THEN'
    YRG<-1> = '    IF YWRITNO < 9 THEN'
    YRG<-1> = '      YWRITNO += 1'
    YRG<-1> = '    END ELSE'
    YRG<-1> = '      YWRITNO = 0; YBLOCKNO += 10'
    YRG<-1> = '      CALL PRINTER.OFF; PRINT @(41,L1ST-3):YBLOCKNO+YWRITNO:; CALL PRINTER.ON(REPORT.ID,PRT.UNIT)'
    YRG<-1> = '    END'
    YRG<-1> = '  END'
    YRG<-1> = '  RETURN'
*
*------------------------------------------------------------------------
*
    YRG<-1> = STR("*",73)
    YRG<-1> = '9000000:'
    YRG<-1> = '*'
    YRG<-1> = '  YTOTFD = TRIMB(YTOTFD)'
    IF NOT(R.NEW(RG.CRE.EMPTY.LINE.WANTED)) THEN
        YRG<-1> = '  IF YTOTFD = "" THEN RETURN'
    END
    YRG<-1> = '*'
    YRG<-1> = '9000010:'
    YRG<-1> = '  IF YPRINTING THEN PRINT YTOTFD; YTOTFD = ""; RETURN'
    YRG<-1> = '  PRINT YTOTFD:; YT.PAGE<P,L> = YTOTFD; YTOTFD = ""'
    YRG<-1> = '  IF L < 19 THEN L += 1; PRINT @(0,L):; RETURN'
    YRG<-1> = '*'
    YRG<-1> = '9100000:'
    YRG<-1> = '  PRINT @(13,21):TIMEDATE()[1,8]:@(68,21):S.CLEAR.EOL:P:'
    YRG<-1> = '*'
    YRG<-1> = '9100010:'
    YRG<-1> = '  Y = T.REMTEXT(4)  ;* AWAITING PAGE INSTRUCTIONS'
    YRG<-1> = '  CALL INP (Y,8,22,5.1,"A")'
    YRG<-1> = '  BEGIN CASE'
    YRG<-1> = '    CASE COMI = C.B; NEXTP = P-1'
    YRG<-1> = '    CASE COMI = C.F'
    YRG<-1> = '      NEXTP = P+1; IF NEXTP = LASTP+1 THEN GOTO 9190000'
    YRG<-1> = '    CASE COMI = C.E; NEXTP = LASTP'
    YRG<-1> = '    CASE COMI = C.V OR COMI = C.W OR COMI = C.U'
    IF R.NEW(RG.CRE.USING.132.COLUMNS) THEN
        YRG<-1> = '      PRINT S.COL132.OFF:'
    END
    YRG<-1> = '      CLEARSELECT; COMI = C.U; RETURN'
    YRG<-1> = '    CASE COMI = "P"; NEXTP = 1'
    YRG<-1> = '    CASE COMI[1,1] = "P" AND NUM(COMI[2,99]) = NUMERIC'
    YRG<-1> = '      NEXTP = COMI[2,99]'
    YRG<-1> = '      IF NEXTP = LASTP+1 THEN COMI = C.F; GOTO 9190000'
    YRG<-1> = '    CASE OTHERWISE'
    YRG<-1> = '      E = ""; L = 22; CALL ERR; GOTO 9100010'
    YRG<-1> = '  END CASE'
    YRG<-1> = '*'
    YRG<-1> = '  IF NEXTP < 1 THEN'
    YRG<-1> = '    NEXTP = 1'
    YRG<-1> = '  END ELSE'
    YRG<-1> = '    IF NEXTP > LASTP THEN NEXTP = LASTP'
    YRG<-1> = '  END'
    YRG<-1> = '  IF NEXTP = P THEN GOTO 9100000'
    YRG<-1> = '  P = NEXTP'
    YRG<-1> = '*'
    YRG<-1> = '  GOSUB 9200000'
    YRG<-1> = '  FOR LL = L1ST TO 19'
    YRG<-1> = '    X = YT.PAGE<P,LL>; IF X <> "" THEN PRINT @(0,LL):X:'
    YRG<-1> = '  NEXT LL; GOTO 9100000'
    YRG<-1> = '*'
    YRG<-1> = '9190000:'
    YRG<-1> = '  IF YEND THEN GOTO 9100000 ELSE P = NEXTP'
    YRG<-1> = '*'
    YRG<-1> = '9200000:'
    YRG<-1> = '  L = L1ST; PRINT @(0,L):'
    YRG<-1> = '  FOR LL = L TO 19; PRINT S.CLEAR.EOL; NEXT LL'
    YRG<-1> = '  PRINT @(0,L):'
    YRG<-1> = '  IF P > LASTP THEN LASTP = P'
    YRG<-1> = '  RETURN'
*
*------------------------------------------------------------------------
*
    YRG<-1> = STR("*",73)
*
    GOSUB SMS.COMPANY.CHECK
*
*------------------------------------------------------------------------
*
    YRG<-1> = 'END'
    WRITE YRG TO F.RG.BP, "RGP.":YPGM.NAME
*      PRINT @(0,10):
    EXECUTE "BASIC RG.BP RGP.":YPGM.NAME
    EXECUTE "CATALOG RG.BP RGP.":YPGM.NAME:" ":CATALOG.OPTION
*
*------------------------------------------------------------------------
*
    X = OCONV(DATE(),"D-")
    X = X[9,2]:X[1,2]:X[4,2]:TIMEDATE()[1,2]:TIMEDATE()[4,2]
    R.NEW(RG.CRE.DATE.TIME.COMPILER) = X
    MATWRITE R.NEW TO F.REPGEN.CREATE, YPGM.NAME
    RELEASE F.RG.BP ; GOTO RECORD.NAME.INPUT
*
*************************************************************************
*
DEFINE.MNEMONIC.FIELD:
*
    GOSUB DEFINE.SINGLE.MNEMONIC
    IF YMNE.LOC THEN RETURN
    YMOD = R.NEW(RG.CRE.MODIFICATION)<1,YAV.MNE,YAS.MNE>
    IF YMOD = "" OR YMOD = "FIELD.DECISION" OR YMOD[1,1] = "@" THEN
        RETURN
    END
*
    YMOD.VALTYP = YT.MNE.VALTYP<YAV.MNE>
    YMFD = R.NEW(RG.CRE.MODIF.FIELD)<1,YAV.MNE,YAS.MNE>
    YFORFIL = R.NEW(RG.CRE.MODIF.FILE)<1,YAV.MNE,YAS.MNE>
    IF YFORFIL THEN
        YMNE.SAVE = YMNE ; YAV.MNE.SAVE = YAV.MNE
        YFD.PART = "" ; YFD.LEN = "" ; YHANDLE.LNGG = 0
        IF INDEX(YMFD,"[",1) THEN
            YFD.PART = "[":FIELD(YMFD,"[",2)
            YMFD = FIELD(YMFD,"[",1)
        END
        BEGIN CASE
        CASE YMOD.VALTYP = ""
            YRG<-1> = YPRESUB:'  IF YM.':YMNE:' <> "" THEN'
            YRG<-1> = YPRESUB:'    YCOMP = "':YFORFIL:'_':YMFD:'_":YM.':YMNE
        CASE YMOD.VALTYP = "M"
            YRG<-1> = YPRESUB:'  YCOUNT.RPL = COUNT(YM.':YMNE:',VM)+1'
            YRG<-1> = YPRESUB:'  FOR YAV.RPL = 1 TO YCOUNT.RPL'
            YPRESUB := "  "
            YRG<-1> = YPRESUB:'  IF YM.':YMNE:'<1,YAV.RPL> <> "" THEN'
            YRG<-1> = YPRESUB:'    YCOMP = "':YFORFIL:'_':YMFD:'_":YM.':YMNE:'<1,YAV.RPL>'
        CASE YMOD.VALTYP = "S"
            YRG<-1> = YPRESUB:'  YCOUNT.RPL = COUNT(YM.':YMNE:',VM)+1'
            YRG<-1> = YPRESUB:'  FOR YAV.RPL = 1 TO YCOUNT.RPL'
            YPRESUB := "  "
            YRG<-1> = YPRESUB:'  YCOUNT.AS.RPL = COUNT(YM.':YMNE:'<1,YAV.RPL>,SM)+1'
            YRG<-1> = YPRESUB:'  FOR YAS.RPL = 1 TO YCOUNT.AS.RPL'
            YPRESUB := "  "
            YRG<-1> = YPRESUB:'  IF YM.':YMNE:'<1,YAV.RPL,YAS.RPL> <> "" THEN'
            YRG<-1> = YPRESUB:'    YCOMP = "':YFORFIL:'_':YMFD:'_":YM.':YMNE:'<1,YAV.RPL,YAS.RPL>'
        END CASE
        YRG<-1> = YPRESUB:'    YFORFIL = YF.':YFORFIL
        V$FUNCTION = "REPGEN.SOURCE"
        V = 1 ; ROUTINE = YFORFIL["$",1,1] ; CALL @ROUTINE
        ID.R = "" ; MAT R = "" ; MAT T = "" ; ID.T = "" ; ID.F = ""
        MAT CHECKFILE = "" ; MAT CONCATFILE = ""
        IF YMFD <= V THEN IF F(FIELD(YMFD,'.',1))[4,3] = "LL." THEN
            YHANDLE.LNGG = 1
        END
        MAT F = "" ; V$FUNCTION = "" ; MAT N = "" ; ID.N = ""
        IF YFD.PART THEN
            YFD.LEN = FIELD(YFD.PART,"]",2)
            YFD.PART = FIELD(YFD.PART,"]",1):"]"
            IF YFD.LEN = "" THEN
                YPART.S = '"':YFD.PART[2,1]:'"'
                YPART.L = YFD.PART[3,99] ; YPART.L = FIELD(YPART.L,"]",1)
            END ELSE
                YPART.S = FIELD(YFD.PART,",",1)
                YPART.S = FIELD(YPART.S,"[",2)
                YPART.L = FIELD(YFD.PART,",",2)
                YPART.L = FIELD(YPART.L,"]",1)
            END
            YRG<-1> = YPRESUB:'    YPART.S = ':YPART.S:'; YPART.L = ':YPART.L:'; YFD.LEN = "':YFD.LEN:'"; YHANDLE.LNGG = ':YHANDLE.LNGG:'; GOSUB 9000000'
        END ELSE
            YRG<-1> = YPRESUB:'    YPART.S = ""; YFD.LEN = ""; YHANDLE.LNGG = ':YHANDLE.LNGG:'; GOSUB 9000000'
        END
        BEGIN CASE
        CASE YMOD.VALTYP = ""
            YRG<-1> = YPRESUB:'    YM.':YMNE:' = YFOR.FD'
            YRG<-1> = YPRESUB:'  END'
        CASE YMOD.VALTYP = "M"
            YRG<-1> = YPRESUB:'    YM.':YMNE:'<1,YAV.RPL> = YFOR.FD'
            YRG<-1> = YPRESUB:'  END'
            YPRESUB = YPRESUB[3,99]
            YRG<-1> = YPRESUB:'  NEXT YAV.RPL'
        CASE YMOD.VALTYP = "S"
            YRG<-1> = YPRESUB:'    YM.':YMNE:'<1,YAV.RPL,YAS.RPL> = YFOR.FD'
            YRG<-1> = YPRESUB:'  END'
            YPRESUB = YPRESUB[3,99]
            YRG<-1> = YPRESUB:'  NEXT YAS.RPL'
            YPRESUB = YPRESUB[3,99]
            YRG<-1> = YPRESUB:'  NEXT YAV.RPL'
        END CASE
        YAV.MNE = YAV.MNE.SAVE ; YMNE = YMNE.SAVE ; RETURN
    END
*
    YRG<-1> = YPRESUB:'  YM1.':YMNE:' = YM.':YMNE
    YMASK.FOR.CONCAT.POSSIBLE = 1 ; YMASK.FOR.CONCAT = ""
    GOSUB MODIFY.SINGLE.FIELD ; YMASK.FOR.CONCAT.POSSIBLE = 0
    BEGIN CASE
    CASE YMOD.VALTYP = ""
        IF YMOD <> "CONCATENATE" THEN
            YRG<-1> = YPRESUB:'  IF NUM(YM1.':YMNE:') = NUMERIC THEN IF NUM(YM.':YMNE:') = NUMERIC THEN'
        END
        BEGIN CASE
        CASE YMOD[1,1] = "-" OR YMOD[1,1] = "+"
            YRG<-1> = YPRESUB:'    IF LEN(YM1.':YMNE:') = 8 THEN IF ABS(YM.':YMNE:') < 10000 THEN'
            YRG<-1> = YPRESUB:'      YM.':YMNE:' = "':YMOD[1,1]:'":YM.':YMNE:':"':YMOD[2,1]:'"'
            YRG<-1> = YPRESUB:'      CALL CDT("", YM1.':YMNE:', YM.':YMNE:')'
            YRG<-1> = YPRESUB:'    END'
        CASE YMOD = "ADD"
            YRG<-1> = YPRESUB:'    YM1.':YMNE:' = YM1.':YMNE:' + YM.':YMNE
        CASE YMOD = "CONCATENATE"
            IF YMASK.FOR.CONCAT THEN
                YRG<-1> = YPRESUB:'  YM1.':YMNE:' = YM1.':YMNE:' : FMT(YM.':YMNE:',"':YMASK.FOR.CONCAT:'")'
            END ELSE
                YRG<-1> = YPRESUB:'  YM1.':YMNE:' = YM1.':YMNE:' : YM.':YMNE
            END
        CASE YMOD = "DIVIDE"
            GOSUB DEFINE.PRECISION
            YRG<-1> = YPRESUB:'    PRECISION 6; YFD = YM1.':YMNE:' / YM.':YMNE
            YRG<-1> = YPRESUB:'    YM1.':YMNE:YROUND:'; PRECISION 6'
        CASE YMOD = "MULTIPLY"
            GOSUB DEFINE.PRECISION
            YRG<-1> = YPRESUB:'    PRECISION 6; YFD = YM1.':YMNE:' * YM.':YMNE
            YRG<-1> = YPRESUB:'    YM1.':YMNE:YROUND:'; PRECISION 6'
        CASE YMOD = "SUBTRACT"
            YRG<-1> = YPRESUB:'    YM1.':YMNE:' = YM1.':YMNE:' - YM.':YMNE
        END CASE
        IF YMOD <> "CONCATENATE" THEN
            YRG<-1> = YPRESUB:'    IF YM1.':YMNE:' = 0 THEN YM1.':YMNE:' = ""'
            YRG<-1> = YPRESUB:'  END'
        END
    CASE YMOD.VALTYP = "M"
        YRG<-1> = YPRESUB:'  YCOUNT.MOD = COUNT(YM1.':YMNE:',VM)+1'
        YRG<-1> = YPRESUB:'  YCOUNT.MOD2 = COUNT(YM.':YMNE:',VM)+1'
        YRG<-1> = YPRESUB:'  IF YCOUNT.MOD2 > YCOUNT.MOD THEN YCOUNT.MOD = YCOUNT.MOD2'
        YRG<-1> = YPRESUB:'  FOR YAV.MOD = 1 TO YCOUNT.MOD'
        YRG<-1> = YPRESUB:'    YFD = YM.':YMNE:'<1,YAV.MOD>'
        IF YMOD <> "CONCATENATE" THEN
            YRG<-1> = YPRESUB:'    IF NUM(YM1.':YMNE:'<1,YAV.MOD>) = NUMERIC THEN IF NUM(YFD) = NUMERIC THEN'
        END
        BEGIN CASE
        CASE YMOD[1,1] = "-" OR YMOD[1,1] = "+"
            YRG<-1> = YPRESUB:'      YFD1 = YM1.':YMNE:'<1,YAV.MOD>'
            YRG<-1> = YPRESUB:'      IF LEN(YFD1) = 8 THEN IF ABS(YFD1) < 10000 THEN'
            YRG<-1> = YPRESUB:'        YFD = "':YMOD[1,1]:'":YFD:"':YMOD[2,1]:'"'
            YRG<-1> = YPRESUB:'        CALL CDT("", YFD1, YFD)'
            YRG<-1> = YPRESUB:'      END'
            YRG<-1> = YPRESUB:'      YM1.':YMNE:'<1,YAV.MOD> = YFD1'
        CASE YMOD = "ADD"
            YRG<-1> = YPRESUB:'      YM1.':YMNE:'<1,YAV.MOD> = YM1.':YMNE:'<1,YAV.MOD> + YFD'
        CASE YMOD = "CONCATENATE"
            IF YMASK.FOR.CONCAT THEN
                YRG<-1> = YPRESUB:'    YM1.':YMNE:'<1,YAV.MOD> = YM1.':YMNE:'<1,YAV.MOD> : FMT(YFD,"':YMASK.FOR.CONCAT:'")'
            END ELSE
                YRG<-1> = YPRESUB:'    YM1.':YMNE:'<1,YAV.MOD> = YM1.':YMNE:'<1,YAV.MOD> : YFD'
            END
        CASE YMOD = "DIVIDE"
            GOSUB DEFINE.PRECISION
            YRG<-1> = YPRESUB:'      PRECISION 6; YFD = YM1.':YMNE:'<1,YAV.MOD> / YFD'
            YRG<-1> = YPRESUB:'      YM1.':YMNE:'<1,YAV.MOD>':YROUND:'; PRECISION 6'
        CASE YMOD = "MULTIPLY"
            GOSUB DEFINE.PRECISION
            YRG<-1> = YPRESUB:'      PRECISION 6; YFD = YM1.':YMNE:'<1,YAV.MOD> * YFD'
            YRG<-1> = YPRESUB:'      YM1.':YMNE:'<1,YAV.MOD>':YROUND:'; PRECISION 6'
        CASE YMOD = "SUBTRACT"
            YRG<-1> = YPRESUB:'      YM1.':YMNE:'<1,YAV.MOD> = YM1.':YMNE:'<1,YAV.MOD> - YFD'
        END CASE
        IF YMOD <> "CONCATENATE" THEN
            YRG<-1> = YPRESUB:'      IF YM1.':YMNE:'<1,YAV.MOD> = 0 THEN YM1.':YMNE:'<1,YAV.MOD> = ""'
            YRG<-1> = YPRESUB:'    END'
        END
        YRG<-1> = YPRESUB:'  NEXT YAV.MOD'
    CASE YMOD.VALTYP = "S"
        YRG<-1> = YPRESUB:'  YCOUNT.MOD = COUNT(YM1.':YMNE:',VM)+1'
        YRG<-1> = YPRESUB:'  YCOUNT.MOD2 = COUNT(YM.':YMNE:',VM)+1'
        YRG<-1> = YPRESUB:'  IF YCOUNT.MOD2 > YCOUNT.MOD THEN YCOUNT.MOD = YCOUNT.MOD2'
        YRG<-1> = YPRESUB:'  FOR YAV.MOD = 1 TO YCOUNT.MOD'
        YRG<-1> = YPRESUB:'    YCOUNT.AS.MOD = COUNT(YM1.':YMNE:'<1,YAV.MOD>,SM)+1'
        YRG<-1> = YPRESUB:'    YCOUNT.AS.MOD2 = COUNT(YM.':YMNE:'<1,YAV.MOD>,SM)+1'
        YRG<-1> = YPRESUB:'    IF YCOUNT.AS.MOD2 > YCOUNT.AS.MOD THEN YCOUNT.AS.MOD = YCOUNT.AS.MOD2'
        YRG<-1> = YPRESUB:'    FOR YAS.MOD = 1 TO YCOUNT.AS.MOD'
        YRG<-1> = YPRESUB:'      YFD = YM.':YMNE:'<1,YAV.MOD,YAS.MOD>'
        IF YMOD <> "CONCATENATE" THEN
            YRG<-1> = YPRESUB:'      IF NUM(YM1.':YMNE:'<1,YAV.MOD,YAS.MOD>) = NUMERIC THEN IF NUM(YFD) = NUMERIC THEN'
        END
        BEGIN CASE
        CASE YMOD[1,1] = "-" OR YMOD[1,1] = "+"
            YRG<-1> = YPRESUB:'        YFD1 = YM1.':YMNE:'<1,YAV.MOD,YAS.MOD>'
            YRG<-1> = YPRESUB:'        IF LEN(YFD1) = 8 THEN IF ABS(YFD1) < 10000 THEN'
            YRG<-1> = YPRESUB:'          YFD = "':YMOD[1,1]:'":YFD:"':YMOD[2,1]:'"'
            YRG<-1> = YPRESUB:'          CALL CDT("", YFD1, YFD)'
            YRG<-1> = YPRESUB:'        END'
            YRG<-1> = YPRESUB:'        YM1.':YMNE:'<1,YAV.MOD,YAS.MOD> = YFD1'
        CASE YMOD = "ADD"
            YRG<-1> = YPRESUB:'        YM1.':YMNE:'<1,YAV.MOD,YAS.MOD> = YM1.':YMNE:'<1,YAV.MOD,YAS.MOD> + YFD'
        CASE YMOD = "CONCATENATE"
            IF YMASK.FOR.CONCAT THEN
                YRG<-1> = YPRESUB:'      YM1.':YMNE:'<1,YAV.MOD,YAS.MOD> = YM1.':YMNE:'<1,YAV.MOD,YAS.MOD> : FMT(YFD,"':YMASK.FOR.CONCAT:'")'
            END ELSE
                YRG<-1> = YPRESUB:'      YM1.':YMNE:'<1,YAV.MOD,YAS.MOD> = YM1.':YMNE:'<1,YAV.MOD,YAS.MOD> : YFD'
            END
        CASE YMOD = "DIVIDE"
            GOSUB DEFINE.PRECISION
            YRG<-1> = YPRESUB:'        PRECISION 6; YFD = YM1.':YMNE:'<1,YAV.MOD,YAS.MOD> / YFD'
            YRG<-1> = YPRESUB:'        YM1.':YMNE:'<1,YAV.MOD,YAS.MOD>':YROUND:'; PRECISION 6'
        CASE YMOD = "MULTIPLY"
            GOSUB DEFINE.PRECISION
            YRG<-1> = YPRESUB:'        PRECISION 6; YFD = YM1.':YMNE:'<1,YAV.MOD,YAS.MOD> * YFD'
            YRG<-1> = YPRESUB:'        YM1.':YMNE:'<1,YAV.MOD,YAS.MOD>':YROUND:'; PRECISION 6'
        CASE YMOD = "SUBTRACT"
            YRG<-1> = YPRESUB:'        YM1.':YMNE:'<1,YAV.MOD,YAS.MOD> = YM1.':YMNE:'<1,YAV.MOD,YAS.MOD> - YFD'
        END CASE
        IF YMOD <> "CONCATENATE" THEN
            YRG<-1> = YPRESUB:'        IF YM1.':YMNE:'<1,YAV.MOD,YAS.MOD> = 0 THEN YM1.':YMNE:'<1,YAV.MOD,YAS.MOD> = ""'
            YRG<-1> = YPRESUB:'      END'
        END
        YRG<-1> = YPRESUB:'    NEXT YAS.MOD'
        YRG<-1> = YPRESUB:'  NEXT YAV.MOD'
    END CASE
    YRG<-1> = YPRESUB:'  YM.':YMNE:' = YM1.':YMNE
    YMASK.FOR.CONCAT = "" ; RETURN
*
*************************************************************************
*
DEFINE.PRECISION:
*
    YDEC = 9 ; YDECFD = R.NEW(RG.CRE.MODIF.FIELD)<1,YAV.MNE,YAS.MNE>
    IF YDECFD[1,1] = '"' THEN
        YDECFD = YDECFD[2,LEN(YDECFD)-2] ; YDEC = INDEX(YDECFD,".",1)
        IF YDEC THEN YDEC = LEN(YDECFD)-YDEC
    END
    BEGIN CASE
    CASE YDEC = 0 ; YROUND = " = OCONV(YFD,'MD0')"
    CASE YDEC = 1 ; YROUND = " = OCONV(ICONV(YFD,'MD1'),'MD1')"
    CASE YDEC = 2 ; YROUND = " = OCONV(ICONV(YFD,'MD2'),'MD2')"
    CASE YDEC = 3 ; YROUND = " = OCONV(ICONV(YFD,'MD3'),'MD3')"
    CASE YDEC = 4 ; YROUND = " = OCONV(ICONV(YFD,'MD4'),'MD4')"
    CASE YDEC = 5 ; YROUND = " = OCONV(ICONV(YFD,'MD5'),'MD5')"
    CASE YDEC = 6 ; YROUND = " = OCONV(ICONV(YFD,'MD6'),'MD6')"
    CASE YDEC = 7 ; YROUND = " = OCONV(ICONV(YFD,'MD7'),'MD7')"
    CASE YDEC = 8 ; YROUND = " = OCONV(ICONV(YFD,'MD8'),'MD8')"
    CASE OTHERWISE ; YROUND = " = OCONV(ICONV(YFD,'MD9'),'MD9')"
    END CASE
    RETURN
*
*************************************************************************
*
DEFINE.SINGLE.MNEMONIC:
*
    LOCATE YMNE IN YT.MNE<1,1> SETTING YMNE.LOC ELSE YMNE.LOC = ""
    IF YMNE.LOC <> "" THEN YAV.MNE = YT.MNE<2,YMNE.LOC> ; RETURN
    YAV.MNE = 1
    LOOP UNTIL YMNE = R.NEW(RG.CRE.DEFINE.MNEMONIC)<1,YAV.MNE> DO
        YAV.MNE += 1
    REPEAT
    YAS.MNE = 1
    IF YCOUNT.FILE > 1 THEN
        LOOP
            X = R.NEW(RG.CRE.MNEMON.FILE)<1,YAV.MNE,YAS.MNE>
        UNTIL YFILE = X OR X = "" DO
            YAS.MNE += 1
        REPEAT
    END
*
* Don't hold Mnemonic on table when used within a FIELD.DECISION:
*
    YFIELD.DEC.MOD = 0
    YCOUNT.MOD = COUNT(YT.MNE.SAVE,FM)+1 ; YAF.MOD = 1
    LOOP UNTIL YAF.MOD > YCOUNT.MOD OR YFIELD.DEC.MOD DO
        IF YT.MNE.SAVE<YAF.MOD,5> = "FIELD.DECISION" THEN
            YFIELD.DEC.MOD = 1
        END ELSE
            YAF.MOD += 1
        END
    REPEAT
    IF NOT(YFIELD.DEC.MOD) THEN
        YT.MNE<1,-1> = YMNE ; YT.MNE<2,-1> = YAV.MNE
    END
*
    YMOD = R.NEW(RG.CRE.MODIFICATION)<1,YAV.MNE,YAS.MNE>
    BEGIN CASE
    CASE YMOD[1,1] = "@"
*
* Handle Call routines:
        YAV.MNE.1ST = YAV.MNE
        LOOP
            YAV.MNE.1ST.OK = 1
            IF YAV.MNE.1ST > 1 THEN
                YMOD.BEFORE = R.NEW(RG.CRE.MODIFICATION)<1,YAV.MNE.1ST-1,YAS.MNE>
                IF FIELD(YMOD,"#",1) = FIELD(YMOD.BEFORE,"#",1) THEN
                    IF FIELD(YMOD.BEFORE,"#",2) < FIELD(YMOD,"#",2) THEN
                        YAV.MNE.1ST.OK = 0
                    END
                END
            END
        UNTIL YAV.MNE.1ST.OK DO YAV.MNE.1ST -= 1 ; REPEAT
        YAV.MNE.LAST = YAV.MNE
        LOOP
            YAV.MNE.LAST.OK = 1
            YMOD.NEXT = R.NEW(RG.CRE.MODIFICATION)<1,YAV.MNE.LAST+1,YAS.MNE>
            IF FIELD(YMOD,"#",1) = FIELD(YMOD.NEXT,"#",1) THEN
                IF FIELD(YMOD.NEXT,"#",2) > FIELD(YMOD,"#",2) THEN
                    YAV.MNE.LAST.OK = 0
                END
            END
        UNTIL YAV.MNE.LAST.OK DO YAV.MNE.LAST += 1 ; REPEAT
*
        YAV.MNE = YAV.MNE.1ST
        LOOP
            YMNE = R.NEW(RG.CRE.DEFINE.MNEMONIC)<1,YAV.MNE>
            INS YMNE BEFORE YT.MNE.SAVE<1>
            YT.MNE.SAVE<1,2> = YMNE.LOC
            YT.MNE.SAVE<1,3> = YAV.MNE ; YT.MNE.SAVE<1,4> = YAS.MNE
            YT.MNE.SAVE<1,5> = YMOD ; YT.MNE.SAVE<1,6> = YMOD.VALTYP
            YT.MNE.SAVE<1,7> = YDEC.SEQU
            YT.MNE.SAVE<1,8> = YAV.MNE.1ST
            YT.MNE.SAVE<1,9> = YAV.MNE.LAST
            YMFD = R.NEW(RG.CRE.MNEMON.FIELD)<1,YAV.MNE,YAS.MNE>
            GOSUB MODIFY.SINGLE.FIELD
            YMNE = YT.MNE.SAVE<1,1> ; YMNE.LOC = YT.MNE.SAVE<1,2>
            YAV.MNE = YT.MNE.SAVE<1,3> ; YAS.MNE = YT.MNE.SAVE<1,4>
            YMOD = YT.MNE.SAVE<1,5> ; YMOD.VALTYP = YT.MNE.SAVE<1,6>
            YDEC.SEQU = YT.MNE.SAVE<1,7>
            YAV.MNE.1ST = YT.MNE.SAVE<1,8>
            YAV.MNE.LAST = YT.MNE.SAVE<1,9> ; DEL YT.MNE.SAVE<1>
            YRG<-1> = YPRESUB:'  YM':YAV.MNE:'.GOSUB = YM.':YMNE
            YT.MNE<1,-1> = YMNE ; YT.MNE<2,-1> = YAV.MNE
        UNTIL YAV.MNE = YAV.MNE.LAST DO YAV.MNE += 1 ; REPEAT
        YPG.KEY = FIELD(YMOD,"#",1) ; YPG.KEY = YPG.KEY[2,99]
        YSEQ = ""
        READ YSEQ FROM F.PGM.FILE, YPG.KEY ELSE
            TEXT = "MISSING FILE=F.PGM.FILE, ID=":YPG.KEY
            CALL FATAL.ERROR ("REPGEN.SOURCE")
        END
        YCALL.ROUTINE = YSEQ<EB.PGM.BATCH.JOB>
        YCALL.ROUTINE = YCALL.ROUTINE[2,99] ; X = ""
        READV X FROM F.PGM.FILE, YCALL.ROUTINE, 1 ELSE
            TEXT = "MISSING FILE=F.PGM.FILE,  ID=":YCALL.ROUTINE
            CALL FATAL.ERROR ("REPGEN.SOURCE")
        END
        YSEQ = YSEQ<EB.PGM.ADDITIONAL.INFO>
        YSEQ = FIELD(YSEQ,"(",2) ; YSEQ = FIELD(YSEQ,")",1)
        YNO.OF.SEQ = COUNT(YSEQ,",")+1
        YSEQ1 = 1 ; YSEQ2 = YAV.MNE.1ST ; YRG.LINE = ""
        LOOP
            IF FIELD(YSEQ,",",YSEQ1) = "*" THEN
                YRG.LINE := '""'
            END ELSE
                YRG.LINE := 'YM':YSEQ2:'.GOSUB' ; YSEQ2 += 1
            END
        UNTIL YSEQ1 = YNO.OF.SEQ DO
            YRG.LINE := ", " ; YSEQ1 += 1
        REPEAT
*
        YRG<-1> = YPRESUB:'  CALL @':YCALL.ROUTINE:' (':YRG.LINE:')'
*
        YSEQ1 = 1 ; YSEQ2 = YAV.MNE.1ST
        LOOP
            IF FIELD(YSEQ,",",YSEQ1) <> "*" THEN
                YRG<-1> = YPRESUB:'  YM.':R.NEW(RG.CRE.DEFINE.MNEMONIC)<1,YSEQ2>:' = YM':YSEQ2:'.GOSUB'
                YSEQ2 += 1
            END
        UNTIL YSEQ1 = YNO.OF.SEQ DO YSEQ1 += 1 ; REPEAT
    CASE YMOD = "FIELD.DECISION"
*
* Handle Field decision:
        YTRUE.COUNTER += 1
        YRG<-1> = YPRESUB:'  YTRUE.':YTRUE.COUNTER:' = 0'
        INS YMNE BEFORE YT.MNE.SAVE<1>
        YT.MNE.SAVE<1,2> = YMNE.LOC
        YT.MNE.SAVE<1,3> = YAV.MNE ; YT.MNE.SAVE<1,4> = YAS.MNE
        YT.MNE.SAVE<1,5> = YMOD ; YT.MNE.SAVE<1,6> = YMOD.VALTYP
        YDEC.SEQU = "FIELD" ; YT.MNE.SAVE<1,7> = YDEC.SEQU
        YDECISION.NAME = R.NEW(RG.CRE.MODIF.FIELD)<1,YAV.MNE,YAS.MNE>
        GOSUB UPDATE.DECISION.FOR.MNEMONIC
        LOOP UNTIL R.NEW(RG.CRE.DEFINE.MNEMONIC)<1,YAV.MNE> <> R.NEW(RG.CRE.DEFINE.MNEMONIC)<1,YAV.MNE+1> DO
            YRG<-1> = YPRESUB:'  IF NOT(YTRUE.':YTRUE.COUNTER:') THEN'
            YAV.MNE += 1 ; YAS.MNE = 1 ; X = 1
            IF YCOUNT.FILE > 1 THEN
                LOOP
                    X = R.NEW(RG.CRE.MNEMON.FILE)<1,YAV.MNE,YAS.MNE>
                UNTIL YFILE = X OR X = "" DO
                    YAS.MNE += 1
                REPEAT
            END
            IF X THEN
                YPRESUB := "  "
                INS YMNE BEFORE YT.MNE.SAVE<1>
                YT.MNE.SAVE<1,2> = YMNE.LOC
                YT.MNE.SAVE<1,3> = YAV.MNE ; YT.MNE.SAVE<1,4> = YAS.MNE
                YT.MNE.SAVE<1,5> = YMOD ; YT.MNE.SAVE<1,6> = YMOD.VALTYP
                YT.MNE.SAVE<1,7> = YDEC.SEQU
                YDECISION.NAME = R.NEW(RG.CRE.MODIF.FIELD)<1,YAV.MNE,YAS.MNE>
                YDEC.SEQU = "FIELD" ; GOSUB UPDATE.DECISION.FOR.MNEMONIC
                YPRESUB = YPRESUB[3,99]
                YRG<-1> = YPRESUB:'  END'
            END
        REPEAT
        YRG<-1> = YPRESUB:'  IF NOT(YTRUE.':YTRUE.COUNTER:') THEN YM.':YMNE:' = ""'
        YTRUE.COUNTER -= 1
    CASE OTHERWISE
*
* Normal handling (no Call routine, no FIELD.DECISION):
        YMFD = R.NEW(RG.CRE.MNEMON.FIELD)<1,YAV.MNE,YAS.MNE>
        GOSUB MODIFY.SINGLE.FIELD
    END CASE
*
* Hold mask for concatenation:
*
    IF YMASK.FOR.CONCAT.POSSIBLE THEN
        LOCATE YMNE IN YT.CONCAT.MNEMONIC<1> SETTING X ELSE
            YMASK.FOR.CONCAT = "" ; RETURN
        END
        YMASK.FOR.CONCAT = YT.CONCAT.MASK<X>
    END
    RETURN
*
************************************************************************
*
MODIFY.SINGLE.FIELD:
*
    YFD.PART = ""
    IF YMFD[1,1] <> '"' THEN IF INDEX(YMFD,"[",1) THEN
        YFD.PART = "[":FIELD(YMFD,"[",2) ; YMFD = FIELD(YMFD,"[",1)
    END
    BEGIN CASE
    CASE YMFD = "" ; YRG<-1> = YPRESUB:'  YM.':YMNE:' = ""'
    CASE YMFD[1,1] = '"' ; YRG<-1> = YPRESUB:'  YM.':YMNE:' = ':YMFD
    CASE YMFD[1,1] >= "A"
* Mnemonic relates to another Mnemonic
        INS YMNE BEFORE YT.MNE.SAVE<1>
        YT.MNE.SAVE<1,2> = YMNE.LOC ; YT.MNE.SAVE<1,3> = YAV.MNE
        YT.MNE.SAVE<1,4> = YAS.MNE ; YT.MNE.SAVE<1,5> = YMOD
        YT.MNE.SAVE<1,6> = YMOD.VALTYP ; YT.MNE.SAVE<1,7> = YDEC.SEQU
        YT.MNE.SAVE<1,8> = YFD.PART ; YT.MNE.SAVE<1,9> = YMFD
        YMNE = YMFD ; GOSUB DEFINE.MNEMONIC.FIELD
        YMNE = YT.MNE.SAVE<1,1> ; YMNE.LOC = YT.MNE.SAVE<1,2>
        YAV.MNE = YT.MNE.SAVE<1,3> ; YAS.MNE = YT.MNE.SAVE<1,4>
        YMOD = YT.MNE.SAVE<1,5> ; YMOD.VALTYP = YT.MNE.SAVE<1,6>
        YDEC.SEQU = YT.MNE.SAVE<1,7> ; YFD.PART = YT.MNE.SAVE<1,8>
        YMFD = YT.MNE.SAVE<1,9> ; DEL YT.MNE.SAVE<1>
        YRG<-1> = YPRESUB:'  YM.':YMNE:' = YM.':YMFD
        IF YFD.PART THEN
            YSTM = YPRESUB:'  YM.':YMNE:' = '
            YSTM.PART = 'YM.':YMNE ; YSTM.MNE = 'YM.':YMNE
            GOSUB UPDATE.FIELD.LENGTH.FOR.PART
        END
    CASE NOT(YMFD)
        YSTM = YPRESUB:'  YM.':YMNE:' = '
        YSTM.PART = 'ID.NEW' ; YSTM.MNE = 'YM.':YMNE
        GOSUB UPDATE.FIELD.LENGTH.FOR.PART
    CASE R.NEW(RG.CRE.MULTI.SPLIT.TOT)<1,YAV.MNE> AND R.NEW(RG.CRE.MULTI.SPLIT.TOT)<1,YAV.MNE> <> "SPLIT"
        YSTM = YPRESUB:'  YM.':YMNE:' = '
        YSTM.PART = 'R.NEW(':YMFD:')' ; YSTM.MNE = 'YM.':YMNE
        GOSUB UPDATE.FIELD.LENGTH.FOR.PART
        YRG<-1> = YPRESUB:'  YT.FD = YM.':YMNE:'; YM.':YMNE:' = ""'
        YRG<-1> = YPRESUB:'  YCOUNT.SUB = COUNT(YT.FD,VM)+1'
        YRG<-1> = YPRESUB:'  FOR YAV.SUB = 1 TO YCOUNT.SUB'
        YRG<-1> = YPRESUB:'    YCOUNT.SUB.AS = COUNT(YT.FD<1,YAV.SUB>,SM)+1'
        YRG<-1> = YPRESUB:'    FOR YAS.SUB = 1 TO YCOUNT.SUB.AS'
        IF YFD.PART = "" THEN
            YRG<-1> = YPRESUB:'      YFD = YT.FD<1,YAV.SUB,YAS.SUB>'
            YRG<-1> = YPRESUB:'      IF NUM(YFD) = NUMERIC THEN YM.':YMNE:' = YM.':YMNE:' + YFD'
        END ELSE
            YSTM = YPRESUB:'      YFD = YT.FD<1,YAV.SUB,YAS.SUB>; '
            YSTM.PART = 'YFD' ; YSTM.MNE = 'YFD'
            GOSUB UPDATE.FIELD.LENGTH.FOR.PART
            YRG<-1> = YPRESUB:'      IF NUM(YFD) = NUMERIC THEN YM.':YMNE:' = YM.':YMNE:' + YFD'
        END
        YRG<-1> = YPRESUB:'    NEXT YAS.SUB'
        YRG<-1> = YPRESUB:'  NEXT YAV.SUB'
        YRG<-1> = YPRESUB:'  IF YM.':YMNE:' = 0 THEN YM.':YMNE:' = ""'
    CASE OTHERWISE
        YSTM = YPRESUB:'  YM.':YMNE:' = '
        YMAF = FIELD(YMFD,".",1) ; YMAV = FIELD(YMFD,".",2)
        YMAS = FIELD(YMFD,".",3) ; YSTM.MNE = 'YM.':YMNE
        IF YMAV = "" THEN
            YSTM.PART = 'R.NEW(':YMAF:')'
        END ELSE
            IF YMAS = "" THEN
                YSTM.PART = 'R.NEW(':YMAF:')<1,':YMAV:'>'
            END ELSE
                YSTM.PART = 'R.NEW(':YMAF:')<1,':YMAV:',':YMAS:'>'
            END
        END
        GOSUB UPDATE.FIELD.LENGTH.FOR.PART
    END CASE
    RETURN
*
*************************************************************************
*
* Ask for maximum length of a field, when Part of a field used only
*
UPDATE.FIELD.LENGTH.FOR.PART:
*
    IF YFD.PART = "" THEN
        YRG<-1> = YSTM:YSTM.PART
    END ELSE
        YCHR = FIELD(YFD.PART,"]",2)
        IF YCHR = "" THEN
            YFD.PART = FIELD(YFD.PART,"]",1)
            YFD.PART = FIELD(YFD.PART,"[",2)
            YRG<-1> = YSTM:' FIELD(':YSTM.PART:',"':YFD.PART[1,1]:'",':YFD.PART[2,99]:')'
        END ELSE
            YFD.PART = FIELD(YFD.PART,"]",1):"]"
            YRG<-1> = YSTM:'FMT(':YSTM.PART:',"':YCHR:'"); ':YSTM.MNE:' = ':YSTM.MNE:YFD.PART
        END
    END
    RETURN
*
*************************************************************************
*
UPDATE.DECISION.STATEMENT:
*
    YT.MNE.SAVE = "" ; YMOD = "" ; YMOD.VALTYP = ""
*
UPDATE.DECISION.FOR.MNEMONIC:
*
    LOCATE YDECISION.NAME IN R.NEW(RG.CRE.DECISION.NAME)<1,1> SETTING YAV.DEC ELSE NULL
    YCOUNT.AS.DEC = COUNT(R.NEW(RG.CRE.DECIS.MNEMON)<1,YAV.DEC>,SM)+1
    FOR YAS.DEC = 1 TO YCOUNT.AS.DEC
        YAS.DEC2 = YAS.DEC ; YT.MNE.ALREADY.DEFINED = ""
        INS "X" BEFORE YT.MNE.SAVE<1>
        YT.MNE.SAVE<1,2> = "X" ; YT.MNE.SAVE<1,3> = YAV.DEC
        YT.MNE.SAVE<1,4> = YAS.DEC ; YT.MNE.SAVE<1,5> = YMOD
        YT.MNE.SAVE<1,6> = YMOD.VALTYP ; YT.MNE.SAVE<1,7> = YDEC.SEQU
        LOOP UNTIL YAS.DEC2 = "" DO
            YMNE = R.NEW(RG.CRE.DECISION.FR)<1,YAV.DEC,YAS.DEC2>
            BEGIN CASE
            CASE YMNE = "" ; NULL
            CASE YMNE[1,1] = "@" ; GOSUB HANDLE.DATE.OR.MONTH
            CASE YMNE[1,1] = '"' ; NULL
            CASE OTHERWISE
                GOSUB DEFINE.PRESUB.SPACE
                INS "X" BEFORE YT.MNE.SAVE<1>
                YT.MNE.SAVE<1,2> = "X" ; YT.MNE.SAVE<1,3> = YAV.DEC
                YT.MNE.SAVE<1,4> = YAS.DEC2 ; YT.MNE.SAVE<1,5> = "X"
                YT.MNE.SAVE<1,6> = "X" ; YT.MNE.SAVE<1,7> = YDEC.SEQU
                GOSUB DEFINE.MNEMONIC.FIELD
                YAV.DEC = YT.MNE.SAVE<1,3> ; YAS.DEC2 = YT.MNE.SAVE<1,4>
                YDEC.SEQU = YT.MNE.SAVE<1,7> ; DEL YT.MNE.SAVE<1>
            END CASE
            YMNE = R.NEW(RG.CRE.DECISION.TO)<1,YAV.DEC,YAS.DEC2>
            BEGIN CASE
            CASE YMNE = "" ; NULL
            CASE YMNE[1,1] = "@" ; GOSUB HANDLE.DATE.OR.MONTH
            CASE YMNE[1,1] = '"' ; NULL
            CASE OTHERWISE
                GOSUB DEFINE.PRESUB.SPACE
                INS "X" BEFORE YT.MNE.SAVE<1>
                YT.MNE.SAVE<1,2> = "X" ; YT.MNE.SAVE<1,3> = YAV.DEC
                YT.MNE.SAVE<1,4> = YAS.DEC2 ; YT.MNE.SAVE<1,5> = "X"
                YT.MNE.SAVE<1,6> = "X" ; YT.MNE.SAVE<1,7> = YDEC.SEQU
                GOSUB DEFINE.MNEMONIC.FIELD
                YAV.DEC = YT.MNE.SAVE<1,3> ; YAS.DEC2 = YT.MNE.SAVE<1,4>
                YDEC.SEQU = YT.MNE.SAVE<1,7> ; DEL YT.MNE.SAVE<1>
            END CASE
            YMNE = R.NEW(RG.CRE.DECIS.MNEMON)<1,YAV.DEC,YAS.DEC2>
            GOSUB DEFINE.PRESUB.SPACE
            LOCATE YMNE IN YT.MNE.ALREADY.DEFINED<1> SETTING X ELSE
                YT.MNE.ALREADY.DEFINED<-1> = YMNE
                INS "X" BEFORE YT.MNE.SAVE<1>
                YT.MNE.SAVE<1,2> = "X" ; YT.MNE.SAVE<1,3> = YAV.DEC
                YT.MNE.SAVE<1,4> = YAS.DEC2 ; YT.MNE.SAVE<1,5> = "X"
                YT.MNE.SAVE<1,6> = "X" ; YT.MNE.SAVE<1,7> = YDEC.SEQU
                GOSUB DEFINE.MNEMONIC.FIELD
                YAV.DEC = YT.MNE.SAVE<1,3> ; YAS.DEC2 = YT.MNE.SAVE<1,4>
                YDEC.SEQU = YT.MNE.SAVE<1,7> ; DEL YT.MNE.SAVE<1>
            END
            IF R.NEW(RG.CRE.REL.NEXT.FD)<1,YAV.DEC,YAS.DEC2> = "" THEN
                YAS.DEC2 = ""
            END ELSE
                YAS.DEC2 += 1
            END
        REPEAT
        YAV.DEC = YT.MNE.SAVE<1,3> ; YAS.DEC = YT.MNE.SAVE<1,4>
        YMOD = YT.MNE.SAVE<1,5> ; YMOD.VALTYP = YT.MNE.SAVE<1,6>
        YDEC.SEQU = YT.MNE.SAVE<1,7>
        DEL YT.MNE.SAVE<1> ; YAS.DEC2 = YAS.DEC
        BEGIN CASE
        CASE YDEC.SEQU = "GLOBAL"
            YSTM = YPRE:'  IF ' ; YPRESUB = YPRE:"  "
        CASE YDEC.SEQU = "GROUP"
            YSTM = YPRETBL:'      IF ' ; YPRESUB = YPRETBL:"      "
        CASE OTHERWISE
            YSTM = YPRESUB:'  IF '
        END CASE
        LOOP UNTIL YAS.DEC2 = "" DO
            YMNE = R.NEW(RG.CRE.DECIS.MNEMON)<1,YAV.DEC,YAS.DEC2>
            YSTM := R.NEW(RG.CRE.BRACKETS.OP)<1,YAV.DEC,YAS.DEC2>[3,99]
            YDECISION = R.NEW(RG.CRE.DECISION)<1,YAV.DEC,YAS.DEC2>
            YFROM = R.NEW(RG.CRE.DECISION.FR)<1,YAV.DEC,YAS.DEC2>
            YTO = R.NEW(RG.CRE.DECISION.TO)<1,YAV.DEC,YAS.DEC2>
            BEGIN CASE
            CASE YDECISION = "EQ"
                IF YTO = "" THEN
                    YSTM := 'YM.':YMNE:' = ' ; GOSUB UPDATE.FROM
                END ELSE
                    YSTM := '(YM.':YMNE:' >= ' ; GOSUB UPDATE.FROM
                    YSTM := ' AND YM.':YMNE:' <= ' ; GOSUB UPDATE.TO
                    YSTM := ')'
                END
            CASE YDECISION = "GE"
                YSTM := 'YM.':YMNE:' >= ' ; GOSUB UPDATE.FROM
            CASE YDECISION = "GT"
                YSTM := 'YM.':YMNE:' > ' ; GOSUB UPDATE.FROM
            CASE YDECISION = "LE"
                YSTM := 'YM.':YMNE:' <= ' ; GOSUB UPDATE.FROM
            CASE YDECISION = "LK"
                YFROM = YFROM[2,LEN(YFROM)-2]
                BEGIN CASE
                CASE YFROM[1,3] = "..." AND YFROM[LEN(YFROM)-2,3] = "..."
                    YSTM := 'INDEX(YM.':YMNE:',"':YFROM[4,LEN(YFROM)-6]:'",1)'
                CASE YFROM[1,3] = '...'
                    YLEN = LEN(YFROM)-3
                    YSTM := 'YM.':YMNE:'[LEN(YM.':YMNE:')-':YLEN-1:',':YLEN:'] = "':YFROM[4,99]:'"'
                CASE OTHERWISE
                    YSTM := 'INDEX(YM.':YMNE:',"':YFROM[1,LEN(YFROM)-3]:'",1) = 1'
                END CASE
            CASE YDECISION = "LT"
                YSTM := 'YM.':YMNE:' < ' ; GOSUB UPDATE.FROM
            CASE YDECISION = "NE"
                IF YTO = "" THEN
                    YSTM := 'YM.':YMNE:' <> ' ; GOSUB UPDATE.FROM
                END ELSE
                    YSTM := '(YM.':YMNE:' < ' ; GOSUB UPDATE.FROM
                    YSTM := ' OR YM.':YMNE:' > ' ; GOSUB UPDATE.TO
                    YSTM := ')'
                END
            CASE YDECISION = "UL"
                YFROM = YFROM[2,LEN(YFROM)-2]
                BEGIN CASE
                CASE YFROM[1,3] = "..." AND YFROM[LEN(YFROM)-2,3] = "..."
                    YSTM := 'INDEX(YM.':YMNE:',"':YFROM[4,LEN(YFROM)-6]:'",1) = 0'
                CASE YFROM[1,3] = "..."
                    YLEN = LEN(YFROM)-3
                    YSTM := 'YM.':YMNE:'[LEN(YM.':YMNE:')-':YLEN-1:',':YLEN:'] <> "':YFROM[4,99]:'"'
                CASE OTHERWISE
                    YSTM := 'INDEX(YM.':YMNE:',"':YFROM[1,LEN(YFROM)-3]:'",1) <> 1'
                END CASE
            END CASE
            YSTM := R.NEW(RG.CRE.BRACKETS.CL)<1,YAV.DEC,YAS.DEC2>[3,99]
            IF R.NEW(RG.CRE.REL.NEXT.FD)<1,YAV.DEC,YAS.DEC2> = "" THEN
                YAS.DEC = YAS.DEC2 ; YAS.DEC2 = ""
            END ELSE
                YSTM := ' ':R.NEW(RG.CRE.REL.NEXT.FD)<1,YAV.DEC,YAS.DEC2>:' '
                YAS.DEC2 += 1
            END
        REPEAT
        BEGIN CASE
        CASE YDEC.SEQU = "GLOBAL"
            YRG<-1> = YSTM:' THEN' ; YSTM = ""
            YRG<-1> = YPRE:'    GOTO 2000000'
            YRG<-1> = YPRE:'  END'
        CASE YDEC.SEQU = "GROUP"
            YRG<-1> = YSTM:' THEN' ; YSTM = YPRETBL:'        '
            IF YCOUNT.GROUP > 1 THEN
                YSTM = YSTM:'YGROUP = "':YGROUP:'"; '
            END
            IF R.NEW(RG.CRE.GLOBAL.DEC.NAME) = "" THEN
                YSTM = YSTM:'GOSUB 2000000'
            END ELSE
                YSTM = YSTM:'GOSUB 1000000'
            END
            IF YCOUNT.AS.DEC > 1 THEN IF YAS.DEC < YCOUNT.AS.DEC THEN
                YSTM = YSTM:'; GOTO ':YDECNO
            END
            YRG<-1> = YSTM ; YSTM = ""
            YRG<-1> = YPRETBL:'      END'
        CASE OTHERWISE
            YRG<-1> = YSTM:' THEN' ; YSTM = "" ; YPRESUB := "  "
            YRG<-1> = YPRESUB:'  YTRUE.':YTRUE.COUNTER:' = 1'
            YMNE = YT.MNE.SAVE<1,1> ; YMNE.LOC = YT.MNE.SAVE<1,2>
            YAV.MNE = YT.MNE.SAVE<1,3> ; YAS.MNE = YT.MNE.SAVE<1,4>
            YMOD = YT.MNE.SAVE<1,5> ; YMOD.VALTYP = YT.MNE.SAVE<1,6>
            YDEC.SEQU = YT.MNE.SAVE<1,7> ; DEL YT.MNE.SAVE<1>
            YMFD = R.NEW(RG.CRE.MNEMON.FIELD)<1,YAV.MNE,YAS.MNE>
            GOSUB MODIFY.SINGLE.FIELD ; YPRESUB = YPRESUB[3,99]
            YRG<-1> = YPRESUB:'  END'
        END CASE
    NEXT YAS
    RETURN
*
*------------------------------------------------------------------------
*
UPDATE.FROM:
*
    YDECIS = YFROM ; GOTO UPDATE.FROM.AND.TO
*
UPDATE.TO:
*
    YDECIS = YTO
*
UPDATE.FROM.AND.TO:
*
    IF YDECIS[1,1] = '"' THEN
        X = LEN(YDECIS)-2
        IF X AND NUM(YDECIS[2,X]) = NUMERIC THEN
            YSTM := YDECIS[2,X]
        END ELSE
            YSTM := YDECIS
        END
    END ELSE
        IF YDECIS[1,1] = "@" THEN
            YDECIS = ".":YDECIS[2,99]
            CONVERT "+" TO "P" IN YDECIS ; CONVERT "-" TO "M" IN YDECIS
        END
        YSTM := 'YM.':YDECIS
    END
    RETURN
*
*------------------------------------------------------------------------
*
HANDLE.DATE.OR.MONTH:
*
    YMNE2 = ".":YMNE[2,99]
    CONVERT "+" TO "P" IN YMNE2 ; CONVERT "-" TO "M" IN YMNE2
    GOSUB DEFINE.PRESUB.SPACE
    YRG<-1> = YPRESUB:'  YCOMP = "':YMNE2:'"; GOSUB 9100000; YM.':YMNE2:' = YDTM'
    RETURN
*
*------------------------------------------------------------------------
*
DEFINE.PRESUB.SPACE:
*
    IF YDEC.SEQU = "GLOBAL" THEN YPRESUB = YPRE
    ELSE IF YDEC.SEQU = "GROUP" THEN YPRESUB = YPRETBL:"    "
    RETURN
*
*************************************************************************
*
DEFINE.PRINTOUT.LINE:
*
    YRG<-1> = '    YCOUNT.LIN = 1; YCOUNT.AS.LIN = 1'
    YRG<-1> = '    YCOUNT.TOT2 = 1; YCOUNT.AS.TOT2 = 1'
    GOSUB DEFINE.MNEMONIC.SEQUENCE
    YCURR.FDNO = 1 ; YCURR.PTNO = 0 ; YCURR.COL = 1
    YCURR.TOT1.NO = 0 ; YCURR.TOT2.NO = 0
    YVALTYP.LINE = 0 ; YSUBTYP.LINE = 0
    YVALTYP.TOT2 = 0 ; YSUBTYP.TOT2 = 0
    YPRE = "    " ; YPRE.UPD = YPRE ; YMODTYP = "LIN"
    YANY.PRINT = 0 ; YANY.TOTAL = 0 ; Y1ST.BLK.LIN = 1
    YT.LINE.COL = "" ; YT.TOT1.COL = "" ; YT.TOT2.COL = ""
    IF YCT.LNGG THEN
        YRG<-1> = YPRE:'LOCATE LNGG IN YT.LANGUAGE<1,1> SETTING YLNGG ELSE YLNGG = 1'
    END
    IF YGROUP.LENGTH THEN
        YMAX.CHAR = R.NEW(RG.CRE.GROUP.TEXT.MAX)<1,YIND>
        IF YMAX.CHAR THEN
            IF YCT.LNGG THEN
                YRG<-1> = YPRE:'YT.GROUP.TEXT = "':R.NEW(RG.CRE.GROUP.TEXT)<1,YIND>:'"'
                YRG<-1> = YPRE:'YFD = YT.GROUP.TEXT<1,1,YLNGG>'
                YRG<-1> = YPRE:'IF YFD = "" THEN IF YLNGG <> 1 THEN'
                YRG<-1> = YPRE:'  YFD = YT.GROUP.TEXT<1,1,1>'
                YRG<-1> = YPRE:'END'
            END ELSE
                YRG<-1> = YPRE:'YFD = "':R.NEW(RG.CRE.GROUP.TEXT)<1,YIND>:'"'
            END
            GOSUB DECIDE.HEADER.BLANK.LINE ; Y1ST.BLK.LIN = 0
            YRG<-1> = YPRE:'YFD = FMT(YFD,"':YMAX.CHAR:'L"):" "'
            YRG<-1> = YPRE:'YFD = YFD:FMT("':R.NEW(RG.CRE.GROUP)<1,YIND>:'","':YGROUP.LENGTH:'R")'
            YCHR = YMAX.CHAR+1+YGROUP.LENGTH ; YCOL = ""
            GOSUB UPDATE.LINE
        END
    END
    FOR YAV.WR = 1 TO YCOUNT.WR
        GOSUB DEFINE.MNEMONIC.WITHIN.LOOP
        YDISPLAY.TYPE = R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE>
        IF YDISPLAY.TYPE THEN
            IF YDISPLAY.TYPE = "2 LINE" OR YDISPLAY.TYPE = "3 LINE+TOTAL" OR YDISPLAY.TYPE = "5 CONTIN.TOTAL" THEN
                YANY.PRINT = 1
                IF YDISPLAY.TYPE = "3 LINE+TOTAL" THEN YANY.TOTAL = 1
                YSUFFIX = YT.MNE.VALTYP<YAV.MNE> ; YSUFFIX.TOTAL = ""
                IF YSUFFIX THEN
                    YVALTYP.LINE = 1
                    YCNT.COL = COUNT(R.NEW(RG.CRE.COLUMN)<1,YAV.MNE>,SM)+1
                    IF YCNT.COL = 1 THEN
                        YRG<-1> = '    YCNT = COUNT(YR.REC(':YCURR.FDNO:'),VM)'
                    END ELSE
                        YRG<-1> = '    YCNT = INT(COUNT(YR.REC(':YCURR.FDNO:'),VM)/':YCNT.COL:')'
                    END
                    YRG<-1> = '    IF YCNT >= YCOUNT.LIN THEN YCOUNT.LIN = YCNT+1'
                    IF YSUFFIX = "M" THEN
                        YSUFFIX = "1,1" ; YSUFFIX.TOTAL = ",1"
                    END ELSE
                        YSUBTYP.LINE = 1
                        YSUFFIX = "1,1,1" ; YSUFFIX.TOTAL = ",1,1"
                        IF YCNT.COL = 1 THEN
                            YRG<-1> = '    YCNT = COUNT(YR.REC(':YCURR.FDNO:')<1,1>,SM)'
                        END ELSE
                            YRG<-1> = '    YCNT = INT(COUNT(YR.REC(':YCURR.FDNO:')<1,1>,SM)/':YCNT.COL:')'
                        END
                        YRG<-1> = '    IF YCNT >= YCOUNT.AS.LIN THEN YCOUNT.AS.LIN = YCNT+1'
                    END
                END
                YLINE.COLTYP = 1
* YLINE.COLTYP = 1 = define Colums for YT.LINE.COL and YT.TOT1.COL
                IF Y1ST.BLK.LIN THEN
                    GOSUB DECIDE.HEADER.BLANK.LINE ; Y1ST.BLK.LIN = 0
                END
                GOSUB MODIFY.FIELD
            END
            IF YDISPLAY.TYPE = "4 TOTAL ONLY" OR YDISPLAY.TYPE = "6 FOOTER" THEN
                YSUFFIX = YT.MNE.VALTYP<YAV.MNE> ; YSUFFIX.TOTAL = ""
                IF YSUFFIX THEN
                    YVALTYP.TOT2 = 1
                    YCNT.COL = COUNT(R.NEW(RG.CRE.COLUMN)<1,YAV.MNE>,SM)+1
                    IF YCNT.COL = 1 THEN
                        YRG<-1> = '    YCNT = COUNT(YR.REC(':YCURR.FDNO:'),VM)'
                    END ELSE
                        YRG<-1> = '    YCNT = INT(COUNT(YR.REC(':YCURR.FDNO:'),VM)/':YCNT.COL:')'
                    END
                    YRG<-1> = '    IF YCNT >= YCOUNT.TOT2 THEN YCOUNT.TOT2 = YCNT+1'
                    IF YSUFFIX = "M" THEN
                        YSUFFIX = "1,1" ; YSUFFIX.TOTAL = ",1"
                    END ELSE
                        YSUBTYP.TOT2 = 1
                        YSUFFIX = "1,1,1" ; YSUFFIX.TOTAL = ",1,1"
                        IF YCNT.COL = 1 THEN
                            YRG<-1> = '    YCNT = COUNT(YR.REC(':YCURR.FDNO:')<1,1>,SM)'
                        END ELSE
                            YRG<-1> = '    YCNT = INT(COUNT(YR.REC(':YCURR.FDNO:')<1,1>,SM)/':YCNT.COL:')'
                        END
                        YRG<-1> = '    IF YCNT >= YCOUNT.AS.TOT2 THEN YCOUNT.AS.TOT2 = YCNT+1'
                    END
                END
                YLINE.COLTYP = 4
* YLINE.COLTYP = 4 = define preliminary (Columns of RG.CRE.COLUMN field
* only) YT.TOT2.COL
                GOSUB MODIFY.FIELD
            END
            YCURR.FDNO += 1
        END
    NEXT YAV.WR
    YPRE.DECI = "    " ; GOSUB DECIDE.END.OF.LINE
*
*------------------------------------------------------------------------
*
* Handle multi value lines
*
    IF YVALTYP.LINE THEN
        YLINE.COLTYP = 2
* YLINE.COLTYP = 2 = pick up Column from YT.LINE.COL
        IF YSUBTYP.LINE THEN
            YRG<-1> = '    YAV = 1'
            YPRESUBVAL = "    " ; GOSUB PRINT.SUBVALUE.LINE
        END
        YRG<-1> = '*'
        YRG<-1> = '    FOR YAV = 2 TO YCOUNT.LIN'
        IF YSUBTYP.LINE THEN
            YRG<-1> = '      YCOUNT.AS.LIN = 1'
        END
        YCURR.FDNO = 1 ; YCURR.PTNO = 0 ; YCURR.COL = 1 ; YCURR.TOT1.NO = 0
        YPRE = "      " ; YPRE.UPD = YPRE
        FOR YAV.WR = 1 TO YCOUNT.WR
            GOSUB DEFINE.MNEMONIC.WITHIN.LOOP
            YDISPLAY.TYPE = R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE>
            IF YDISPLAY.TYPE THEN
                IF YDISPLAY.TYPE = "2 LINE" OR YDISPLAY.TYPE = "3 LINE+TOTAL" OR YDISPLAY.TYPE = "5 CONTIN.TOTAL" THEN
                    YSUFFIX = YT.MNE.VALTYP<YAV.MNE>
                    IF YSUFFIX THEN
                        IF YSUFFIX = "M" THEN
                            YSUFFIX = "1,YAV" ; YSUFFIX.TOTAL = ",YAV"
                        END ELSE
                            YSUFFIX = "1,YAV,1" ; YSUFFIX.TOTAL = ",YAV,1"
                            YCNT.COL = COUNT(R.NEW(RG.CRE.COLUMN)<1,YAV.MNE>,SM)+1
                            IF YCNT.COL = 1 THEN
                                YRG<-1> = '      YCNT = COUNT(YR.REC(':YCURR.FDNO:')<1,YAV>,SM)'
                            END ELSE
                                YRG<-1> = '      YCNT = INT(COUNT(YR.REC(':YCURR.FDNO:')<1,YAV>,SM)/':YCNT.COL:')'
                            END
                            YRG<-1> = '      IF YCNT >= YCOUNT.AS.LIN THEN YCOUNT.AS.LIN = YCNT+1'
                        END
                        GOSUB MODIFY.FIELD
                    END
                END
                YCURR.FDNO += 1
            END
        NEXT YAV.WR
        YPRE.DECI = "      " ; GOSUB DECIDE.END.OF.LINE
        IF YSUBTYP.LINE THEN
            YPRESUBVAL = "      " ; GOSUB PRINT.SUBVALUE.LINE
        END
        YRG<-1> = '    NEXT YAV'
    END
*
* Handle multi value totals
*
    IF YVALTYP.TOT2 THEN
        YLINE.COLTYP = 0
* YLINE.COLTYP = 0 = no Column table used
        IF YSUBTYP.TOT2 THEN
            YRG<-1> = '    YAV = 1'
            YPRESUBVAL = "    " ; GOSUB ADD.SUBVALUE.LINE
        END
        YRG<-1> = '*'
        YRG<-1> = '    FOR YAV = 2 TO YCOUNT.TOT2'
        IF YSUBTYP.TOT2 THEN
            YRG<-1> = '      YCOUNT.AS.TOT2 = 1'
        END
        YCURR.FDNO = 1 ; YCURR.COL = 1 ; YCURR.TOT2.NO = 0
        YPRE = "      " ; YPRE.UPD = YPRE
        FOR YAV.WR = 1 TO YCOUNT.WR
            GOSUB DEFINE.MNEMONIC.WITHIN.LOOP
            YDISPLAY.TYPE = R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE>
            IF YDISPLAY.TYPE THEN
                IF YDISPLAY.TYPE = "4 TOTAL ONLY" OR YDISPLAY.TYPE = "6 FOOTER" THEN
                    YSUFFIX = YT.MNE.VALTYP<YAV.MNE>
                    IF YSUFFIX THEN
                        IF YSUFFIX = "M" THEN
                            YSUFFIX = "1,YAV" ; YSUFFIX.TOTAL = ",YAV"
                        END ELSE
                            YSUFFIX = "1,YAV,1" ; YSUFFIX.TOTAL = ",YAV,1"
                            YCNT.COL = COUNT(R.NEW(RG.CRE.COLUMN)<1,YAV.MNE>,SM)+1
                            IF YCNT.COL = 1 THEN
                                YRG<-1> = '      YCNT = COUNT(YR.REC(':YCURR.FDNO:')<1,YAV>,SM)'
                            END ELSE
                                YRG<-1> = '      YCNT = INT(COUNT(YR.REC(':YCURR.FDNO:')<1,YAV>,SM)/':YCNT.COL:')'
                            END
                            YRG<-1> = '      IF YCNT >= YCOUNT.AS.TOT2 THEN YCOUNT.AS.TOT2 = YCNT+1'
                        END
                        GOSUB MODIFY.FIELD
                    END
                END
                YCURR.FDNO += 1
            END
        NEXT YAV.WR
        IF YSUBTYP.TOT2 THEN
            YPRESUBVAL = "      " ; GOSUB ADD.SUBVALUE.LINE
        END
        YRG<-1> = '    NEXT YAV'
    END
*
*-----------------------------------------------------------------------
*
    IF YANY.PRINT OR YANY.TOTAL THEN
        IF R.NEW(RG.CRE.ADD.BLANK.LINE) THEN
            IF R.NEW(RG.CRE.ADD.BLANK.LINE) <> "1 AFTER TOTAL" THEN
                YPRE.DECI = "    " ; GOSUB DECIDE.PRINT.DISPLAY.EMPTY.LINE
            END
        END
    END
    IF YANY.TOTAL THEN IF R.NEW(RG.CRE.SUPPR.SINGLE.TOTAL) THEN
        IF YDIM.TOTAL = 1 THEN
            YRG<-1> = '    YR.TNO(1) = YR.TNO(1) + 1'
        END ELSE
            YRG<-1> = '    FOR YNO = 1 TO ':YDIM.TOTAL
            YRG<-1> = '      YR.TNO(YNO) = YR.TNO(YNO) + 1'
            YRG<-1> = '    NEXT YNO'
        END
    END
    RETURN
*
*************************************************************************
*
* Handle subvalue lines
*
PRINT.SUBVALUE.LINE:
*
    YRG<-1> = '*'
    YRG<-1> = YPRESUBVAL:'FOR YAS = 2 TO YCOUNT.AS.LIN'
    YCURR.FDNO = 1 ; YCURR.PTNO = 0 ; YCURR.COL = 1 ; YCURR.TOT1.NO = 0
    YPRE = YPRESUBVAL:"  " ; YPRE.UPD = YPRE
    FOR YAV.WR = 1 TO YCOUNT.WR
        GOSUB DEFINE.MNEMONIC.WITHIN.LOOP
        YDISPLAY.TYPE = R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE>
        IF YDISPLAY.TYPE THEN
            IF YDISPLAY.TYPE = "2 LINE" OR YDISPLAY.TYPE = "3 LINE+TOTAL" OR YDISPLAY.TYPE = "5 CONTIN.TOTAL" THEN
                YSUFFIX = YT.MNE.VALTYP<YAV.MNE>
                IF YSUFFIX = "S" THEN
                    YSUFFIX = "1,YAV,YAS" ; YSUFFIX.TOTAL = ",YAV,YAS"
                    GOSUB MODIFY.FIELD
                END
            END
            YCURR.FDNO += 1
        END
    NEXT YAV.WR
    YPRE.DECI = YPRESUBVAL:"  " ; GOSUB DECIDE.END.OF.LINE
    YRG<-1> = YPRESUBVAL:'NEXT YAS'
    RETURN
*
*************************************************************************
*
* Handle adding of subvalue lines
*
ADD.SUBVALUE.LINE:
*
    YRG<-1> = '*'
    YRG<-1> = YPRESUBVAL:'FOR YAS = 2 TO YCOUNT.AS.TOT2'
    YCURR.FDNO = 1 ; YCURR.COL = 1 ; YCURR.TOT2.NO = 0
    YPRE = YPRESUBVAL:"  " ; YPRE.UPD = YPRE
    FOR YAV.WR = 1 TO YCOUNT.WR
        GOSUB DEFINE.MNEMONIC.WITHIN.LOOP
        YDISPLAY.TYPE = R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE>
        IF YDISPLAY.TYPE THEN
            IF YDISPLAY.TYPE = "4 TOTAL ONLY" OR YDISPLAY.TYPE = "6 FOOTER" THEN
                YSUFFIX = YT.MNE.VALTYP<YAV.MNE>
                IF YSUFFIX = "S" THEN
                    YSUFFIX = "1,YAV,YAS" ; YSUFFIX.TOTAL = ",YAV,YAS"
                    GOSUB MODIFY.FIELD
                END
            END
            YCURR.FDNO += 1
        END
    NEXT YAV.WR
    YRG<-1> = YPRESUBVAL:'NEXT YAS'
    RETURN
*
*************************************************************************
*
UPDATE.LINE:
*
    IF YCOL = "" THEN
        IF YCURR.COL = 1 THEN YCOL = 1 ELSE YCOL = YCURR.COL + 1
        IF YCOL + YCHR > YLAST.COL THEN YCOL = 1
    END
    IF YCURR.COL > YCOL THEN
        YPRE.DECI = YPRE.UPD ; GOSUB PRINT.DISPLAY.WITH.PREFIX
        YCURR.PTNO = 0 ; YCURR.COL = 1
    END
    IF YCURR.COL = YCOL THEN
        YRG<-1> = YPRE.UPD:'YTOTFD := YFD'
    END ELSE
        YRG<-1> = YPRE.UPD:'YTOTFD := "':STR(" ",YCOL-YCURR.COL):'":YFD'
        YCURR.COL = YCOL
    END
    YCOL = YCURR.COL ; YCURR.COL += YCHR
    YCURR.PTNO += 1 ; RETURN
*
*************************************************************************
*
DEFINE.HEADER.TEXT:
*
    YPREHDR = "" ; YSUBGROUP = 0
    IF YCT.LNGG THEN
        YRG<-1> = YPREHDR:'  YT.LANGUAGE = "':R.NEW(RG.CRE.LANGUAGE.CODE):'"'
        YRG<-1> = YPREHDR:'  LOCATE LNGG IN YT.LANGUAGE<1,1> SETTING YLNGG ELSE YLNGG = 1'
    END
*
DEFINE.HEADER.SUBGROUP:
*
    IF YCT.LNGG THEN
        YRG<-1> = YPREHDR:'  YT.REPORT.TITLE = "':R.NEW(RG.CRE.REPORT.TITLE):'"'
        YRG<-1> = YPREHDR:'  YHDR = YT.REPORT.TITLE<1,YLNGG>'
        YRG<-1> = YPREHDR:'  IF YHDR = "" THEN YHDR = YT.REPORT.TITLE<1,1>'
    END ELSE
        YRG<-1> = YPREHDR:'  YHDR = "':R.NEW(RG.CRE.REPORT.TITLE):'"'
    END
    YRG<-1> = YPREHDR:'  IF YPRINTING THEN'
    YPREHDR := "  "
    BEGIN CASE
    CASE R.NEW(RG.CRE.SPECIAL.HEADING) = "NONE" OR R.NEW(RG.CRE.SPECIAL.HEADING) = "FLAT"
        YRG<-1> = YPREHDR:'  YTYPE = ""'
    CASE R.NEW(RG.CRE.SPECIAL.HEADING) = "STANDARD"
        YRG<-1> = YPREHDR:'  YHDR = "RGP.':YPGM.NAME:' ":YHDR'
        IF R.NEW(RG.CRE.USING.132.COLUMNS) THEN
            YRG<-1> = YPREHDR:'  YTYPE = "HEADER":FM:YHDR'
        END ELSE
            YRG<-1> = YPREHDR:'  YTYPE = "HEADER.80":FM:YHDR'
        END
        YRG<-1> = YPREHDR:'  CALL PST ( YTYPE )'
    CASE OTHERWISE
        YRG<-1> = YPREHDR:'  YTEXT = "Page"; CALL TXT ( YTEXT )'
        YSTML = "'PL'"
        IF R.NEW(RG.CRE.USING.132.COLUMNS) THEN
* GB9700569
            YRG<-1> = YPREHDR:'  YTYPE = FMT(YHDR,"123L"):FMT(YTEXT,"5L"):"':YSTML:'"'
        END ELSE
            YRG<-1> = YPREHDR:'  YTYPE = FMT(YHDR,"71L"):FMT(YTEXT,"5L"):"':YSTML:'"'
        END
    END CASE
    YPREHDR = YPREHDR[3,99]
    YRG<-1> = YPREHDR:'  END ELSE'
    YRG<-1> = YPREHDR:'    YTYPE = YHDR'
    YRG<-1> = YPREHDR:'  END'
*
    YX = RG.CRE.HDR.1.001..040 ; YX1 = 1 ; YX2 = 0          ;* Set YX1 to 1 to reference whole field under unix
    YX3 = "<1,YLNGG>" ; YX4 = "<1,1>"
    GOSUB COMMON.DEFINE.HEADER
*
    YSTML = "'L'"
    IF NOT(YSUBGROUP) THEN
        YRG<-1> = YPREHDR:'  IF YPRINTING THEN YSTML = "':YSTML:'" ELSE YSTML = ""'
    END
    YRG<-1> = YPREHDR:'  IF YHDR1 <> "" OR YHDR2 <> "" OR YHDR3 <> "" OR YHDR4 <> "" THEN'
    YRG<-1> = YPREHDR:'    YTYPE<3> = YTYPE<3>:YSTML'
    YRG<-1> = YPREHDR:'    IF YHDR1 <> "" THEN YTYPE<4> = YHDR1:YSTML'
    YRG<-1> = YPREHDR:'    IF YHDR2 <> "" THEN YTYPE<5> = YHDR2:YSTML'
    YRG<-1> = YPREHDR:'    IF YHDR3 <> "" THEN YTYPE<6> = YHDR3:YSTML'
    YRG<-1> = YPREHDR:'    IF YHDR4 <> "" THEN YTYPE<7> = YHDR4:YSTML'
    YRG<-1> = YPREHDR:'  END'
    IF R.NEW(RG.CRE.NEW.PAGE.FOR.GROUP) OR YSUBGROUP THEN
        GOSUB DEFINE.GROUP.HEADER.TEXT
        YRG<-1> = YPREHDR:'  IF YHDR.GROUP <> "" OR YHDR1 <> "" OR YHDR2 <> "" OR YHDR3 <> "" OR YHDR4 <> "" THEN'
        YRG<-1> = YPREHDR:'    YTYPE<7> = YTYPE<7>:YSTML'
        YRG<-1> = YPREHDR:'    IF YHDR.GROUP <> "" THEN YTYPE<8> = YHDR.GROUP:YSTML'
        YRG<-1> = YPREHDR:'    IF YHDR.GROUP <> "" AND (YHDR1 <> "" OR YHDR2 <> "" OR YHDR3 <> "" OR YHDR4 <> "") THEN'
        YRG<-1> = YPREHDR:'      YTYPE<8> = YTYPE<8>:YSTML'
        YRG<-1> = YPREHDR:'    END'
        YRG<-1> = YPREHDR:'    IF YHDR1 <> "" THEN YTYPE<9> = YHDR1:YSTML'
        YRG<-1> = YPREHDR:'    IF YHDR2 <> "" THEN YTYPE<10> = YHDR2:YSTML'
        YRG<-1> = YPREHDR:'    IF YHDR3 <> "" THEN YTYPE<11> = YHDR3:YSTML'
        YRG<-1> = YPREHDR:'    IF YHDR4 <> "" THEN YTYPE<12> = YHDR3:YSTML'
        YRG<-1> = YPREHDR:'  END'
    END
    YRG<-1> = YPREHDR:'  IF YPRINTING THEN'
*
* GB9701076 - Comment next line, add 5 lines from GWK
* HEADING statement takes no account of
* top margin set via SETPTR
*
* 12/12/97 reverted to old code for EEC as flat file no has headings
    IF R.NEW(RG.CRE.SPECIAL.HEADING) = "FLAT" THEN
        YRG<-1> = YPREHDR:'    HEADING YTYPE<1>:YTYPE<2>:YTYPE<3>:YTYPE<4>:YTYPE<5>:YTYPE<6>:YTYPE<7>:YTYPE<8>:YTYPE<9>:YTYPE<10>:YTYPE<11>:YTYPE<12>'
    END ELSE
*
        YRG<-1> = YPREHDR:'    HEAD.SETTING = YTYPE<1>:YTYPE<2>:YTYPE<3>:YTYPE<4>:YTYPE<5>:YTYPE<6>:YTYPE<7>:YTYPE<8>:YTYPE<9>:YTYPE<10>:YTYPE<11>:YTYPE<12>'
        YRG<-1> = YPREHDR:'  IF HEAD.SETTING = "" THEN'
        YRG<-1> = YPREHDR:'    HEAD.SETTING = " "'
        YRG<-1> = YPREHDR:'  END'
        YRG<-1> = YPREHDR:'  HEADING HEAD.SETTING'
    END
*
* End of GB9701076
*
    YRG<-1> = YPREHDR:'  END ELSE'
    YRG<-1> = YPREHDR:'    PRINT @(25+LEN(SCREEN.TITLE)+LEN(PGM.VERSION),L1ST-4):S.CLEAR.EOL:YTYPE<1>:'
    YRG<-1> = YPREHDR:'    IF YTYPE<5> = "" THEN YTYPE<5> = YTYPE<4>; YTYPE<4> = ""'
    YRG<-1> = YPREHDR:'    PRINT @(0,L1ST-3):S.CLEAR.EOL:YTYPE<4>:'
    YRG<-1> = YPREHDR:'    PRINT @(0,L1ST-2):S.CLEAR.EOL:YTYPE<5>:'
    YRG<-1> = YPREHDR:'    L = L1ST; PRINT @(0,L):'
    YRG<-1> = YPREHDR:'    IF YTYPE<6> <> "" THEN'
    YRG<-1> = YPREHDR:'      YT.PAGE<P,L> = YTYPE<6>; L += 2; PRINT YTYPE<6>:@(0,L):'
    YRG<-1> = YPREHDR:'    END'
    YRG<-1> = YPREHDR:'    IF YTYPE<7> <> "" THEN'
    YRG<-1> = YPREHDR:'      YT.PAGE<P,L> = YTYPE<7>; L += 2; PRINT YTYPE<7>:@(0,L):'
    YRG<-1> = YPREHDR:'    END'
    YRG<-1> = YPREHDR:'    IF YTYPE<8> <> "" THEN'
    YRG<-1> = YPREHDR:'      YT.PAGE<P,L> = YTYPE<8>; L += 2; PRINT YTYPE<6>:@(0,L):'
    YRG<-1> = YPREHDR:'    END'
    YRG<-1> = YPREHDR:'    IF YTYPE<9> <> "" OR YTYPE<10> <> "" OR YTYPE<11> <> "" OR YTYPE<12> <> "" THEN'
    YRG<-1> = YPREHDR:'      IF YTYPE<9> <> "" THEN'
    YRG<-1> = YPREHDR:'        YT.PAGE<P,L> = YTYPE<9>; L += 1; PRINT YTYPE<9>:@(0,L):'
    YRG<-1> = YPREHDR:'      END'
    YRG<-1> = YPREHDR:'      IF YTYPE<10> <> "" THEN'
    YRG<-1> = YPREHDR:'        YT.PAGE<P,L> = YTYPE<10>; L += 1; PRINT YTYPE<10>:'
    YRG<-1> = YPREHDR:'      END'
    YRG<-1> = YPREHDR:'      IF YTYPE<11> <> "" THEN'
    YRG<-1> = YPREHDR:'        YT.PAGE<P,L> = YTYPE<11>; L += 1; PRINT YTYPE<11>:'
    YRG<-1> = YPREHDR:'      END'
    YRG<-1> = YPREHDR:'      IF YTYPE<12> <> "" THEN'
    YRG<-1> = YPREHDR:'        YT.PAGE<P,L> = YTYPE<12>; L += 1; PRINT YTYPE<12>:'
    YRG<-1> = YPREHDR:'      END'
    YRG<-1> = YPREHDR:'      L += 1; PRINT @(0,L):'
    YRG<-1> = YPREHDR:'    END'
    YRG<-1> = YPREHDR:'  END'
    YRG<-1> = YPREHDR:'  YTYPE = ""'
    IF YSUBGROUP THEN RETURN
* Gosub DEFINE.HEADER.SUBGROUP returns here
    YRG<-1> = '*':STR("-",72)
    IF YHEADER.DISPLAY THEN YRG<-1> = '  MAT YR.REC.OLD = "_"'
    RETURN
*
*************************************************************************
*
DEFINE.GROUP.HEADER.TEXT:
*
    IF YCT.LNGG THEN
        YRG<-1> = '  YHDR.GROUP = "':R.NEW(RG.CRE.GROUP.TITLE)<1,YIND>:'"'
        YRG<-1> = '  IF YHDR.GROUP<1,1,YLNGG> <> "" THEN'
        YRG<-1> = '    YHDR.GROUP = YHDR.GROUP<1,1,YLNGG>'
        YRG<-1> = '  END ELSE'
        YRG<-1> = '    YHDR.GROUP = YHDR.GROUP<1,1,1>'
        YRG<-1> = '  END'
    END ELSE
        YRG<-1> = '  YHDR.GROUP = "':R.NEW(RG.CRE.GROUP.TITLE)<1,YIND>:'"'
    END
    YX = RG.CRE.GH1.001..040 ; YX1 = 1 ; YX2 = YIND
    YX3 = "<1,1,YLNGG>" ; YX4 = "<1,1,1>"
*
COMMON.DEFINE.HEADER:
*
    IF YCT.LNGG THEN
        YRG<-1> = YPREHDR:'  YT.1.001..040 = "':R.NEW(YX)<YX1,YX2>:'"'
        YRG<-1> = YPREHDR:'  YT.1.040..080 = "':R.NEW(YX+1)<YX1,YX2>:'"'
        YRG<-1> = YPREHDR:'  YT.1.081..120 = "':R.NEW(YX+2)<YX1,YX2>:'"'
        YRG<-1> = YPREHDR:'  YT.1.121..132 = "':R.NEW(YX+3)<YX1,YX2>:'"'
        YRG<-1> = YPREHDR:'  YHDR1 = TRIMB(FMT(YT.1.001..040':YX3:',"40L"):FMT(YT.1.040..080':YX3:',"40L"):FMT(YT.1.081..120':YX3:',"40L"):YT.1.121..132':YX3:')'
        YRG<-1> = YPREHDR:'  YT.2.001..040 = "':R.NEW(YX+4)<YX1,YX2>:'"'
        YRG<-1> = YPREHDR:'  YT.2.040..080 = "':R.NEW(YX+5)<YX1,YX2>:'"'
        YRG<-1> = YPREHDR:'  YT.2.081..120 = "':R.NEW(YX+6)<YX1,YX2>:'"'
        YRG<-1> = YPREHDR:'  YT.2.121..132 = "':R.NEW(YX+7)<YX1,YX2>:'"'
        YRG<-1> = YPREHDR:'  YHDR2 = TRIMB(FMT(YT.2.001..040':YX3:',"40L"):FMT(YT.2.040..080':YX3:',"40L"):FMT(YT.2.081..120':YX3:',"40L"):YT.2.121..132':YX3:')'
        YRG<-1> = YPREHDR:'  YT.3.001..040 = "':R.NEW(YX+8)<YX1,YX2>:'"'
        YRG<-1> = YPREHDR:'  YT.3.040..080 = "':R.NEW(YX+9)<YX1,YX2>:'"'
        YRG<-1> = YPREHDR:'  YT.3.081..120 = "':R.NEW(YX+10)<YX1,YX2>:'"'
        YRG<-1> = YPREHDR:'  YT.3.121..132 = "':R.NEW(YX+11)<YX1,YX2>:'"'
        YRG<-1> = YPREHDR:'  YHDR3 = TRIMB(FMT(YT.3.001..040':YX3:',"40L"):FMT(YT.3.040..080':YX3:',"40L"):FMT(YT.3.081..120':YX3:',"40L"):YT.3.121..132':YX3:')'
        YRG<-1> = YPREHDR:'  YT.4.001..040 = "':R.NEW(YX+12)<YX1,YX2>:'"'
        YRG<-1> = YPREHDR:'  YT.4.040..080 = "':R.NEW(YX+13)<YX1,YX2>:'"'
        YRG<-1> = YPREHDR:'  YT.4.081..120 = "':R.NEW(YX+14)<YX1,YX2>:'"'
        YRG<-1> = YPREHDR:'  YT.4.121..132 = "':R.NEW(YX+15)<YX1,YX2>:'"'
        YRG<-1> = YPREHDR:'  YHDR4 = TRIMB(FMT(YT.4.001..040':YX3:',"40L"):FMT(YT.4.040..080':YX3:',"40L"):FMT(YT.4.081..120':YX3:',"40L"):YT.4.121..132':YX3:')'
        YRG<-1> = YPREHDR:'  IF YHDR1 = "" THEN IF YHDR2 = "" THEN IF YHDR3 = "" THEN IF YHDR4 = "" THEN IF YLNGG <> 1 THEN'
        YRG<-1> = YPREHDR:'    YHDR1 = TRIMB(FMT(YT.1.001..040':YX4:',"40L"):FMT(YT.1.040..080':YX4:',"40L"):FMT(YT.1.081..120':YX4:',"40L"):YT.1.121..132':YX4:')'
        YRG<-1> = YPREHDR:'    YHDR2 = TRIMB(FMT(YT.2.001..040':YX4:',"40L"):FMT(YT.2.040..080':YX4:',"40L"):FMT(YT.2.081..120':YX4:',"40L"):YT.2.121..132':YX4:')'
        YRG<-1> = YPREHDR:'    YHDR3 = TRIMB(FMT(YT.3.001..040':YX4:',"40L"):FMT(YT.3.040..080':YX4:',"40L"):FMT(YT.3.081..120':YX4:',"40L"):YT.3.121..132':YX4:')'
        YRG<-1> = YPREHDR:'    YHDR4 = TRIMB(FMT(YT.4.001..040':YX4:',"40L"):FMT(YT.4.040..080':YX4:',"40L"):FMT(YT.4.081..120':YX4:',"40L"):YT.4.121..132':YX4:')'
        YRG<-1> = YPREHDR:'  END'
    END ELSE
        YHDR1 = TRIMB(FMT(R.NEW(YX)<YX1,YX2>,"40L"):FMT(R.NEW(YX+1)<YX1,YX2>,"40L"):FMT(R.NEW(YX+2)<YX1,YX2>,"40L"):R.NEW(YX+3)<YX1,YX2>)
        YHDR2 = TRIMB(FMT(R.NEW(YX+4)<YX1,YX2>,"40L"):FMT(R.NEW(YX+5)<YX1,YX2>,"40L"):FMT(R.NEW(YX+6)<YX1,YX2>,"40L"):R.NEW(YX+7)<YX1,YX2>)
        YHDR3 = TRIMB(FMT(R.NEW(YX+8)<YX1,YX2>,"40L"):FMT(R.NEW(YX+9)<YX1,YX2>,"40L"):FMT(R.NEW(YX+10)<YX1,YX2>,"40L"):R.NEW(YX+11)<YX1,YX2>)
        YHDR4 = TRIMB(FMT(R.NEW(YX+12)<YX1,YX2>,"40L"):FMT(R.NEW(YX+13)<YX1,YX2>,"40L"):FMT(R.NEW(YX+14)<YX1,YX2>,"40L"):R.NEW(YX+15)<YX1,YX2>)
        YRG<-1> = YPREHDR:'  YHDR1 = "':YHDR1:'"'
        YRG<-1> = YPREHDR:'  YHDR2 = "':YHDR2:'"'
        YRG<-1> = YPREHDR:'  YHDR3 = "':YHDR3:'"'
        YRG<-1> = YPREHDR:'  YHDR4 = "':YHDR4:'"'
    END
    RETURN
*
*************************************************************************
*
PRINT.GROUP.HEADER:
*
    YPREHDR = "" ; GOSUB DEFINE.GROUP.HEADER.TEXT
    YRG<-1> = '  IF YHDR.GROUP <> "" THEN'
    YPRE.DECI = "    " ; GOSUB PRINT.DISPLAY.WITH.PREFIX
    YRG<-1> = '    YTOTFD = YHDR.GROUP; GOSUB 9000000'
    YRG<-1> = '    IF COMI = C.U THEN RETURN  ;* end of pgm'
    YRG<-1> = '  END'
    YRG<-1> = '  IF YHDR1 <> "" OR YHDR2 <> "" OR YHDR3 <> "" OR YHDR4 <> "" THEN'
    YPRE.DECI = "    " ; GOSUB PRINT.DISPLAY.WITH.PREFIX
    YRG<-1> = '    IF YHDR1 <> "" THEN'
    YRG<-1> = '      YTOTFD = YHDR1; GOSUB 9000000'
    YRG<-1> = '      IF COMI = C.U THEN RETURN  ;* end of pgm'
    YRG<-1> = '    END'
    YRG<-1> = '    IF YHDR2 <> "" THEN'
    YRG<-1> = '      YTOTFD = YHDR2; GOSUB 9000000'
    YRG<-1> = '      IF COMI = C.U THEN RETURN  ;* end of pgm'
    YRG<-1> = '    END'
    YRG<-1> = '    IF YHDR3 <> "" THEN'
    YRG<-1> = '      YTOTFD = YHDR3; GOSUB 9000000'
    YRG<-1> = '      IF COMI = C.U THEN RETURN  ;* end of pgm'
    YRG<-1> = '    END'
    YRG<-1> = '    IF YHDR4 <> "" THEN'
    YRG<-1> = '      YTOTFD = YHDR4; GOSUB 9000000'
    YRG<-1> = '      IF COMI = C.U THEN RETURN  ;* end of pgm'
    YRG<-1> = '    END'
    YRG<-1> = '  END'
    GOTO DECIDE.PRINT.DISPLAY
*
*************************************************************************
*
* Calculate dimension of totals (number of totals)
* There are 2 totals: 1 = Details are printed within line, 2 = Only
* totals are printed
*
DEFINE.TOTAL.FIELDS:
*
    YDIM.TOTAL = 0 ; YDIM.TOT1.COL = 0 ; YDIM.TOT2.COL = 0
    GOSUB DEFINE.MNEMONIC.SEQUENCE
    FOR YAV.WR = 1 TO YCOUNT.WR
        GOSUB DEFINE.MNEMONIC.WITHIN.LOOP
        YKEY.TYPE = R.NEW(RG.CRE.KEY.TYPE)<1,YAV.MNE>
        IF YKEY.TYPE = "2 TOTAL BY CHANGE" OR YKEY.TYPE = "4 TOTAL+PAGING BY CHANGE" THEN
            YDIM.TOTAL += 1
        END
        IF R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE> = "3 LINE+TOTAL" OR R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE> = "4 TOTAL ONLY" OR R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE> = "6 FOOTER" THEN
            YCOUNT.COL = COUNT(R.NEW(RG.CRE.COLUMN)<1,YAV.MNE>,SM)+1
            IF R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE> = "3 LINE+TOTAL" THEN
                YDIM.TOT1.COL += YCOUNT.COL
            END ELSE
                YDIM.TOT2.COL += YCOUNT.COL
            END
            IF R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE> = "6 FOOTER" THEN
                IF NOT(YDIM.TOTAL) OR YDIM.TOTAL = '' THEN YDIM.TOTAL += 1
            END
        END
    NEXT YAV.WR
    IF NOT(YDIM.TOT1.COL) AND NOT(YDIM.TOT2.COL) THEN YDIM.TOTAL = 0
    ELSE YDIM.TOTAL += 1
    IF NOT(YDIM.TOTAL) THEN YDIM.TOT1.COL = 0 ; YDIM.TOT2.COL = 0
    IF YDIM.TOT1.COL THEN
        YRG<-1> = '  DIM YR.TOT1(':YDIM.TOTAL:'); MAT YR.TOT1 = ""'
        YRG<-1> = '  DIM YT.DEC1(':YDIM.TOTAL:'); MAT YT.DEC1 = ""'
    END
    IF YDIM.TOT2.COL THEN
        YRG<-1> = '  DIM YR.TOT2(':YDIM.TOTAL:'); MAT YR.TOT2 = ""'
        YRG<-1> = '  DIM YT.DEC2(':YDIM.TOTAL:'); MAT YT.DEC2 = ""'
    END
    IF YDIM.TOTAL THEN
        IF R.NEW(RG.CRE.SUPPR.SINGLE.TOTAL) THEN
            YRG<-1> = '  DIM YR.TNO(':YDIM.TOTAL:'); MAT YR.TNO = ""'
        END
    END
    RETURN
*
*************************************************************************
*
MODIFY.FIELD:
*
    IF YMODTYP = "TOT1" OR YMODTYP = "TOT2" THEN
        YCOUNT.COL = 1
    END ELSE
        YCOUNT.COL = COUNT(R.NEW(RG.CRE.COLUMN)<1,YAV.MNE>,SM)+1
    END
    YSUFFIX.SAVE = YSUFFIX
    FOR YAS.COL = 1 TO YCOUNT.COL
        YSUFFIX = YSUFFIX.SAVE
        BEGIN CASE
        CASE YMODTYP = "TOT1"
            YRG<-1> = YPRE:'YFD = YR.TOT1(YAV.TOT)':YSUFFIX:'  ;* YM.':YMNE
            YRG<-1> = YPRE:'YR.TOT1(YAV.TOT)':YSUFFIX:' = ""'
        CASE YMODTYP = "TOT2"
            YRG<-1> = YPRE:'YFD = YR.TOT2(YAV.TOT)':YSUFFIX:'  ;* YM.':YMNE
            YRG<-1> = YPRE:'YR.TOT2(YAV.TOT)':YSUFFIX:' = ""'
        CASE OTHERWISE
            YAF.SUFFIX = FIELD(YSUFFIX,",",1)
            YAV.SUFFIX = FIELD(YSUFFIX,",",2)
            YAS.SUFFIX = FIELD(YSUFFIX,",",3)
            IF YAS.SUFFIX THEN
                IF YAS.SUFFIX = 1 THEN YAS.SUFFIX = YAS.COL
                IF YAS.SUFFIX = "YAS" THEN IF YCOUNT.COL > 1 THEN
                    YAS.SUFFIX = "YAS*":YCOUNT.COL
                    IF YAS.COL < YCOUNT.COL THEN
                        YAS.SUFFIX := "-":YCOUNT.COL-YAS.COL
                    END
                END
                YSUFFIX = "<":YAF.SUFFIX:",":YAV.SUFFIX:",":YAS.SUFFIX:">"
            END ELSE
                IF YAV.SUFFIX THEN
                    IF YAV.SUFFIX = 1 THEN YAV.SUFFIX = YAS.COL
                    IF YAV.SUFFIX = "YAV" THEN IF YCOUNT.COL > 1 THEN
                        YAV.SUFFIX = "YAV*":YCOUNT.COL
                        IF YAS.COL < YCOUNT.COL THEN
                            YAV.SUFFIX := "-":YCOUNT.COL-YAS.COL
                        END
                    END
                    YSUFFIX = "<":YAF.SUFFIX:",":YAV.SUFFIX:">"
                END
            END
            IF YMODTYP = "LIN" THEN
                IF YDISPLAY.TYPE = "4 TOTAL ONLY" OR YDISPLAY.TYPE = "6 FOOTER" THEN GOTO TOTAL.ADDING
                IF YDISPLAY.TYPE = "5 CONTIN.TOTAL" THEN
                    YRG<-1> = YPRE:'YFD = YR.REC(':YCURR.FDNO:')':YSUFFIX:' + YR.REC.TOT(':YCURR.FDNO:')':YSUFFIX:'  ;* YM.':YMNE
                    YRG<-1> = YPRE:'YR.REC(':YCURR.FDNO:')':YSUFFIX:' = YFD'
                END ELSE
                    YRG<-1> = YPRE:'YFD = YR.REC(':YCURR.FDNO:')':YSUFFIX:'  ;* YM.':YMNE
                END
            END ELSE
                YRG<-1> = YPRE:'YFD.OLD = YR.REC.OLD(':YCURR.FDNO:')':YSUFFIX:'; YFD = YR.REC(':YCURR.FDNO:')':YSUFFIX:'  ;* YM.':YMNE
                YRG<-1> = YPRE:'IF YHEADER.DISPLAY OR YFD.OLD <> YFD THEN'
                YPRE := "  " ; YPRE.UPD = YPRE
                YRG<-1> = YPRE:'YHEADER.DISPLAY = 1'
            END
        END CASE
        YMASK = R.NEW(RG.CRE.MASK)<1,YAV.MNE>
        YCHR = R.NEW(RG.CRE.NUMBER.OF.CHAR)<1,YAV.MNE>
        BEGIN CASE
        CASE NOT(YMASK)
            YRG<-1> = YPRE:'YFD = FMT(YFD,"':YCHR:'L")'
        CASE YMASK = "@DATE"
            YTEMP =FM:YPRE:'BEGIN CASE'
            YTEMP:=FM:YPRE:'   CASE YFD MATCHES "8N"'
            YTEMP:=FM:YPRE:'      YFD=YFD[7,2]:" ":FIELD(T.REMTEXT(19)," ",YFD[5,2]):" ":YFD[':(IF YCHR=9 THEN '3,2' ELSE '1,4'):']'
            YTEMP:=FM:YPRE:'   CASE YFD MATCHES "6N"'
            YTEMP:=FM:YPRE:'      YFD=YFD[5,2]:" ":FIELD(T.REMTEXT(19)," ",YFD[3,2]):" ":':(IF YCHR=9 THEN "" ELSE "(IF YFD[1,1] LT 5 THEN '20' ELSE '19'):"):'YFD[1,2]'
            YTEMP:=FM:YPRE:'   CASE 1'
            YTEMP:=FM:YPRE:'      YFD=FMT(YFD,"':YCHR:'L")'
            YTEMP:=FM:YPRE:'END CASE'
            YRG:=YTEMP
        CASE YMASK[1,4] = "@AMT"
            YRG<-1> = YPRE:'IF YFD = "" THEN'
            YRG<-1> = YPRE:'  YFD = STR(" ",':YCHR:')'
            YRG<-1> = YPRE:'END ELSE'
            YRG<-1> = YPRE:'  YFD = FMT(YFD,"':YCHR:'R':YMASK[5,1]:',")'
            YRG<-1> = YPRE:'  IF AMOUNT.FORMAT#"" THEN CONVERT ",." TO AMOUNT.FORMAT IN YFD'
            YRG<-1> = YPRE:'END'
        CASE YMASK[1,5]='@RATE'
            YRG<-1> = YPRE:'IF YFD = "" THEN'
            YRG<-1> = YPRE:'  YFD = STR(" ",':YCHR:')'
            YRG<-1> = YPRE:'END ELSE'
            YRG<-1> = YPRE:'  LOOP WHILE YFD[1]="0" DO YFD=YFD[1,LEN(YFD)-1] REPEAT'
            YRG<-1> = YPRE:'  YFD = FMT(YFD,"':YCHR:'R':YMASK[6,1]:'")'
            YRG<-1> = YPRE:'  IF AMOUNT.FORMAT#"" THEN CONVERT "." TO AMOUNT.FORMAT[2,1] IN YFD'
            YRG<-1> = YPRE:'END'
        CASE INDEX(YMASK,"#",1)
            YRG<-1> = YPRE:'IF YFD = "" THEN'
            YRG<-1> = YPRE:'  YFD = STR(" ",':LEN(YMASK)-1:')'
            YRG<-1> = YPRE:'END ELSE'
            YRG<-1> = YPRE:'  YFD = FMT(YFD,"':YMASK:'")'
            YRG<-1> = YPRE:'END'
        CASE OTHERWISE
            YRG<-1> = YPRE:'IF YFD = "" THEN'
            YRG<-1> = YPRE:'  YFD = STR(" ",':YCHR:')'
            YRG<-1> = YPRE:'END ELSE'
            BEGIN CASE
            CASE YMODTYP = "TOT1"
                YRG<-1> = YPRE:'  YFD = FMT(YFD,"':YCHR:'R":YT.DEC1(YAV.TOT)':YSUFFIX:':",")'
                YRG<-1> = YPRE:'  YT.DEC1(YAV.TOT)':YSUFFIX:' = ""'
            CASE YMODTYP = "TOT2"
                YRG<-1> = YPRE:'  YFD = FMT(YFD,"':YCHR:'R":YT.DEC2(YAV.TOT)':YSUFFIX:':",")'
                YRG<-1> = YPRE:'  YT.DEC2(YAV.TOT)':YSUFFIX:' = ""'
            CASE OTHERWISE
                YRG<-1> = YPRE:'  YDEC = INDEX(YFD,".",1)'
                YRG<-1> = YPRE:'  IF YDEC THEN YDEC = LEN(YFD) - YDEC'
                YRG<-1> = YPRE:'  YFD = FMT(YFD,"':YCHR:'R":YDEC:",")'
                YRG<-1> = YPRE:'  IF AMOUNT.FORMAT#"" THEN CONVERT ",." TO AMOUNT.FORMAT IN YFD'
            END CASE
*
            IF YMASK[2] = "DR" THEN     ;* Change -ve to n,nnn.nnDR
                YRG<-1> = YPRE:' IF INDEX(YFD,"-",1) THEN    ;* Negative'
                YRG<-1> = YPRE:'    CONVERT "-" TO " " IN YFD'
                YRG<-1> = YPRE:'    YFD := "DR"'  ;* Add DR
                YRG<-1> = YPRE:' END ELSE'
                YRG<-1> = YPRE:'    YFD :="  "'
                YRG<-1> = YPRE:' END'
                YRG<-1> = YPRE:' IF YFD[1,2] = "  " THEN YFD = YFD[3,99]    ;* Drop first two blanks'
            END
*
            YRG<-1> = YPRE:'END'
        END CASE
        YRG<-1> = YPRE:'IF LEN(YFD) > ':YCHR:' THEN YFD = YFD[1,':YCHR-1:']:"|"'
        YMAX.CHAR = R.NEW(RG.CRE.TEXT.CHAR.MAX)<1,YAV.MNE>
        IF YMAX.CHAR THEN
            IF YCT.LNGG THEN
                YRG<-1> = YPRE:'YT.TEXT = "':R.NEW(RG.CRE.TEXT)<1,YAV.MNE>:'"'
                YRG<-1> = YPRE:'YTXT = YT.TEXT<1,1,YLNGG>'
                YRG<-1> = YPRE:'IF YTXT = "" THEN IF YLNGG <> 1 THEN'
                YRG<-1> = YPRE:'  YTXT = YT.TEXT<1,1,1>'
                YRG<-1> = YPRE:'END'
                YRG<-1> = YPRE:'YFD = FMT(YTXT,"':YMAX.CHAR:'L"):" ":YFD'
            END ELSE
                YRG<-1> = YPRE:'YFD = "':FMT(R.NEW(RG.CRE.TEXT)<1,YAV.MNE>,YMAX.CHAR:"L"):' ":YFD'
            END
            YCHR += YMAX.CHAR + 1
        END
        BEGIN CASE
        CASE YLINE.COLTYP = 2
            YCOL = YT.LINE.COL<YCURR.FDNO,YAS.COL>
        CASE YLINE.COLTYP = 3
            YCOL = YT.TOT1.COL<YCURR.TOT1.NO>
        CASE YLINE.COLTYP > 4
            YCOL = YT.TOT2.COL<YCURR.TOT2.NO>
        CASE OTHERWISE
            YCOL = R.NEW(RG.CRE.COLUMN)<1,YAV.MNE,YAS.COL>
        END CASE
        YCOL.SAVE = YCOL ; YCURR.COL.SAVE = YCURR.COL
        GOSUB UPDATE.LINE
        IF YLINE.COLTYP = 1 THEN
            YT.LINE.COL<YCURR.FDNO,YAS.COL> = YCOL
            IF R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE> = "3 LINE+TOTAL" THEN
                YCURR.TOT1.NO +=1 ; YT.TOT1.COL<YCURR.TOT1.NO> = YCOL
            END
        END
        IF YMODTYP = "HDR" THEN
            IF YCURR.HDRNO < YLAST.HDRNO THEN
                YPRE = YPRE[1,LEN(YPRE)-2] ; YPRE.UPD = YPRE
                YRG<-1> = YPRE:'END ELSE'
                YPRE := "  " ; YPRE.UPD = YPRE
                YRG<-1> = YPRE:'IF YHEADER.STATUS > ':YCURR.HDRNO:' THEN'
                YPRE := "  " ; YPRE.UPD = YPRE ; YFD = STR(" ",YCHR)
                YRG<-1> = YPRE:'YFD = "':YFD:'"'
                YCOL = YCOL.SAVE ; YCURR.COL = YCURR.COL.SAVE
                GOSUB UPDATE.LINE
                YPRE = YPRE[1,LEN(YPRE)-2] ; YPRE.UPD = YPRE
                YRG<-1> = YPRE:'END'
            END
            YPRE = YPRE[1,LEN(YPRE)-2] ; YPRE.UPD = YPRE
            YRG<-1> = YPRE:'END'
        END
*
TOTAL.ADDING:
*
        IF YMODTYP = "LIN" THEN
            IF R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE> = "3 LINE+TOTAL" OR R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE> = "4 TOTAL ONLY" OR R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE> = "6 FOOTER" THEN
                IF YLINE.COLTYP = 1 OR YLINE.COLTYP = 2 THEN
                    YRG<-1> = YPRE:'YFD = YR.REC(':YCURR.FDNO:')':YSUFFIX:'  ;* YM.':YMNE
                    YRG<-1> = YPRE:'IF NUM(YFD) = NUMERIC THEN'
                    IF YLINE.COLTYP = 2 THEN YCURR.TOT1.NO += 1
                    YTOTNO = YCURR.TOT1.NO : YSUFFIX.TOTAL
                    IF YDIM.TOTAL = 1 THEN
                        YRG<-1> = YPRE:'  YR.TOT1(1)<':YTOTNO:'> = YR.TOT1(1)<':YTOTNO:'> + YFD'
                        YRG<-1> = YPRE:'  YDEC = INDEX(YFD,".",1)'
                        YRG<-1> = YPRE:'  IF YDEC THEN YDEC = LEN(YFD) - YDEC'
                        YRG<-1> = YPRE:'  IF YT.DEC1(1)<':YTOTNO:'> = "" THEN'
                        YRG<-1> = YPRE:'    YT.DEC1(1)<':YTOTNO:'> = YDEC'
                        YRG<-1> = YPRE:'  END ELSE'
                        YRG<-1> = YPRE:'    IF YDEC > YT.DEC1(1)<':YTOTNO:'> THEN'
                        YRG<-1> = YPRE:'      YT.DEC1(1)<':YTOTNO:'> = YDEC'
                        YRG<-1> = YPRE:'    END'
                        YRG<-1> = YPRE:'  END'
                    END ELSE
                        YRG<-1> = YPRE:'  FOR YNO = 1 TO ':YDIM.TOTAL
                        YRG<-1> = YPRE:'    YR.TOT1(YNO)<':YTOTNO:'> = YR.TOT1(YNO)<':YTOTNO:'> + YFD'
                        YRG<-1> = YPRE:'    YDEC = INDEX(YFD,".",1)'
                        YRG<-1> = YPRE:'    IF YDEC THEN YDEC = LEN(YFD) - YDEC'
                        YRG<-1> = YPRE:'    IF YT.DEC1(YNO)<':YTOTNO:'> = "" THEN'
                        YRG<-1> = YPRE:'      YT.DEC1(YNO)<':YTOTNO:'> = YDEC'
                        YRG<-1> = YPRE:'    END ELSE'
                        YRG<-1> = YPRE:'      IF YDEC > YT.DEC1(YNO)<':YTOTNO:'> THEN'
                        YRG<-1> = YPRE:'        YT.DEC1(YNO)<':YTOTNO:'> = YDEC'
                        YRG<-1> = YPRE:'      END'
                        YRG<-1> = YPRE:'    END'
                        YRG<-1> = YPRE:'  NEXT YNO'
                    END
                    YRG<-1> = YPRE:'END'
                END ELSE
                    YRG<-1> = YPRE:'YFD = YR.REC(':YCURR.FDNO:')':YSUFFIX:'  ;* YM.':YMNE
                    IF R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE> <> "6 FOOTER" THEN
                        YRG<-1> = YPRE:'IF NUM(YFD) = NUMERIC THEN'
                    END
                    YCURR.TOT2.NO += 1
                    IF YLINE.COLTYP = 4 THEN
                        YCOL = R.NEW(RG.CRE.COLUMN)<1,YAV.MNE,YAS.COL>
                        YT.TOT2.COL<YCURR.TOT2.NO> = YCOL
                    END
                    YTOTNO = YCURR.TOT2.NO : YSUFFIX.TOTAL
                    IF R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE> = "6 FOOTER" THEN
                        YRG<-1> = YPRE:'YR.TOT2(':YDIM.TOTAL:')<':YTOTNO:'> = YFD'
***** CHANGES TO PRINT THE AMOUNT WITH DECIMAL PLACES IF DISPLAY
***** TYPE IS "6 FOOTER" & MASK IS CCY
***** DATE : DEC 16,1991
                        YRG<-1> = YPRE:'IF NUM(YFD) = NUMERIC THEN'
                        YRG<-1> = YPRE:'  YDEC = INDEX(YFD,".",1)'
                        YRG<-1> = YPRE:'  IF YDEC THEN YDEC = LEN(YFD) - YDEC'
                        YRG<-1> = YPRE:'  IF YT.DEC2(2)<':YTOTNO:'> = "" THEN'
                        YRG<-1> = YPRE:'    YT.DEC2(2)<':YTOTNO:'> = YDEC'
                        YRG<-1> = YPRE:'  END ELSE'
                        YRG<-1> = YPRE:'    IF YDEC > YT.DEC2(2)<':YTOTNO:'> THEN'
                        YRG<-1> = YPRE:'      YT.DEC2(2)<':YTOTNO:'> = YDEC'
                        YRG<-1> = YPRE:'    END'
                        YRG<-1> = YPRE:'  END'
                        YRG<-1> = YPRE:'END'
***** CHANGES END HERE
                    END ELSE
                        IF YDIM.TOTAL = 1 THEN
                            YRG<-1> = YPRE:'  YR.TOT2(1)<':YTOTNO:'> = YR.TOT2(1)<':YTOTNO:'> + YFD'
                            YRG<-1> = YPRE:'  YDEC = INDEX(YFD,".",1)'
                            YRG<-1> = YPRE:'  IF YDEC THEN YDEC = LEN(YFD) - YDEC'
                            YRG<-1> = YPRE:'  IF YT.DEC2(1)<':YTOTNO:'> = "" THEN'
                            YRG<-1> = YPRE:'    YT.DEC2(1)<':YTOTNO:'> = YDEC'
                            YRG<-1> = YPRE:'  END ELSE'
                            YRG<-1> = YPRE:'    IF YDEC > YT.DEC2(1)<':YTOTNO:'> THEN'
                            YRG<-1> = YPRE:'      YT.DEC2(1)<':YTOTNO:'> = YDEC'
                            YRG<-1> = YPRE:'    END'
                            YRG<-1> = YPRE:'  END'
                        END ELSE
                            YRG<-1> = YPRE:'  FOR YNO = 1 TO ':YDIM.TOTAL
                            YRG<-1> = YPRE:'    YR.TOT2(YNO)<':YTOTNO:'> = YR.TOT2(YNO)<':YTOTNO:'> + YFD'
                            YRG<-1> = YPRE:'    YDEC = INDEX(YFD,".",1)'
                            YRG<-1> = YPRE:'    IF YDEC THEN YDEC = LEN(YFD) - YDEC'
                            YRG<-1> = YPRE:'    IF YT.DEC2(YNO)<':YTOTNO:'> = "" THEN'
                            YRG<-1> = YPRE:'      YT.DEC2(YNO)<':YTOTNO:'> = YDEC'
                            YRG<-1> = YPRE:'    END ELSE'
                            YRG<-1> = YPRE:'      IF YDEC > YT.DEC2(YNO)<':YTOTNO:'> THEN'
                            YRG<-1> = YPRE:'        YT.DEC2(YNO)<':YTOTNO:'> = YDEC'
                            YRG<-1> = YPRE:'      END'
                            YRG<-1> = YPRE:'    END'
                            YRG<-1> = YPRE:'  NEXT YNO'
                        END
                        YRG<-1> = YPRE:'END'
                    END
                END
            END
        END
    NEXT YAS.COL
    RETURN
*
*************************************************************************
*
DEFINE.MNEMONIC.SEQUENCE:
*
    YIND.WR = YIND
    LOOP UNTIL YIND.WR = 1 OR R.NEW(RG.CRE.MNEMON.SEQU)<1,YIND.WR> DO
        YIND.WR -= 1
    REPEAT
    IF R.NEW(RG.CRE.MNEMON.SEQU)<1,YIND.WR> THEN
        YCOUNT.WR = COUNT(R.NEW(RG.CRE.MNEMON.SEQU)<1,YIND.WR>,SM)+1
        YMNEMONIC.SEQUENCE = 1
    END ELSE
        YCOUNT.WR = COUNT(R.NEW(RG.CRE.DEFINE.MNEMONIC),VM)+1
        YMNEMONIC.SEQUENCE = 0
    END
    RETURN
*
*************************************************************************
*
DEFINE.MNEMONIC.WITHIN.LOOP:
*
    IF NOT(YMNEMONIC.SEQUENCE) THEN
        YMNE = R.NEW(RG.CRE.DEFINE.MNEMONIC)<1,YAV.WR>
        YAV.MNE = YAV.WR
    END ELSE
        YMNE = R.NEW(RG.CRE.MNEMON.SEQU)<1,YIND.WR,YAV.WR>
        YAV.MNE = 1
        LOOP UNTIL YMNE = R.NEW(RG.CRE.DEFINE.MNEMONIC)<1,YAV.MNE> DO
            YAV.MNE += 1
        REPEAT
    END
    RETURN
*
*************************************************************************
*
ASK.FOR.TOTAL.PRINT:
*
* Define Table to compare old and new key
*
    IF NOT(YDIM.TOTAL) THEN RETURN
*
    IF NOT(YGROUP.LENGTH) THEN YKEYCOL = 1
    ELSE YKEYCOL = YGROUP.LENGTH + 1
    YT.KEYCOL = YKEYCOL
    GOSUB DEFINE.MNEMONIC.SEQUENCE
    FOR YAV.WR = 1 TO YCOUNT.WR
        GOSUB DEFINE.MNEMONIC.WITHIN.LOOP
        YKEY.TYPE = R.NEW(RG.CRE.KEY.TYPE)<1,YAV.MNE>
* GB9801237
        YTMASK = R.NEW(RG.CRE.MASK)<1,YAV.MNE>
        IF YKEY.TYPE THEN
            IF NOT(YTMASK) THEN
                YKEYCOL += R.NEW(RG.CRE.NUMBER.OF.CHAR)<1,YAV.MNE>+2
            END ELSE
                YKEYCOL += R.NEW(RG.CRE.NUMBER.OF.CHAR)<1,YAV.MNE>
            END
            IF YKEY.TYPE = "2 TOTAL BY CHANGE" OR YKEY.TYPE = "4 TOTAL+PAGING BY CHANGE" THEN
                YT.KEYCOL<-1> = YKEYCOL
            END
        END
    NEXT YAV.WR
*
* Ask for old/new key change to print totals
*
    YCOUNT.TOTTBL = COUNT(YT.KEYCOL,FM)+1 ; YPRETOT = ""
    YRG<-1> = '*'
    IF R.NEW(RG.CRE.SUPPR.GRAND.TOTAL) THEN YCOUNT.TOTTBL.LOW = 2
    ELSE YCOUNT.TOTTBL.LOW = 1
    FOR YTOTTBL = YCOUNT.TOTTBL TO YCOUNT.TOTTBL.LOW STEP -1
        YKEYCOL = YT.KEYCOL<YTOTTBL>
        YRG<-1> = YPRETOT:'    IF YKEY.OLD[1,':YKEYCOL:'] <> YKEY[1,':YKEYCOL:'] THEN'
        YPRETOT := "  "
        YRG<-1> = YPRETOT:'    YTOTAL.STATUS = ':YTOTTBL
    NEXT YTOTTBL
    LOOP UNTIL LEN(YPRETOT) < 3 DO
        YPRETOT = YPRETOT[3,99]
        YRG<-1> = YPRETOT:'    END'
    REPEAT
*
*------------------------------------------------------------------------
*
    IF YTOT.BLK.LIN THEN
        YRG<-1> = '      Y1ST.LIN = 1'
    END
    IF YANY.CONTIN.TOTAL THEN
        YRG<-1> = '      MAT YR.REC.TOT = 0'
    END
    YRG<-1> = '      FOR YAV.TOT = ':YDIM.TOTAL:' TO YTOTAL.STATUS STEP -1'
    IF YTOT.BLK.LIN = 1 THEN
        YPRE.DECI = "        " ; GOSUB DECIDE.PRINT.DISPLAY.EMPTY.LINE
    END ELSE
        IF YTOT.BLK.LIN = 2 THEN
            YPRE.DECI = "        "
            GOSUB DECIDE.PRINT.DISPLAY.EMPTY.LINE
            GOSUB DECIDE.PRINT.DISPLAY.EMPTY.LINE
        END
    END
    YPRETOT = "        "
    IF R.NEW(RG.CRE.SUPPR.SINGLE.TOTAL) THEN IF NOT(YDIM.TOT2.COL) THEN
        YRG<-1> = YPRETOT:'IF YR.TNO(YAV.TOT) < 2 THEN'
        YRG<-1> = YPRETOT:'  YR.TOT1(YAV.TOT) = ""'
        YRG<-1> = YPRETOT:'END ELSE'
        YPRETOT := "  "
    END
*
* Handle totals (Detail line is printed)
*
    IF NOT(YDIM.TOT1.COL) THEN GOTO ASK.FOR.TOTAL2
    YRG<-1> = '*'
    YRG<-1> = YPRETOT:'YCOUNT.TOT1 = 1; YCOUNT.AS.TOT1 = 1'
    GOSUB DEFINE.MNEMONIC.SEQUENCE
    YCURR.FDNO = 1 ; YCURR.PTNO = 0 ; YCURR.COL = 1 ; YMODTYP = "TOT1"
    YVALTYP.LINE = 0 ; YSUBTYP.LINE = 0
    YPRE = YPRETOT ; YPRE.UPD = YPRE
    YLINE.COLTYP = 3 ; YCURR.TOT1.NO = 0
* YLINE.COLTYP = 3 = pick up Column from YT.TOT1.COL
    FOR YAV.WR = 1 TO YCOUNT.WR
        GOSUB DEFINE.MNEMONIC.WITHIN.LOOP
        YDISPLAY.TYPE = R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE>
        IF YDISPLAY.TYPE THEN
            IF YDISPLAY.TYPE = "3 LINE+TOTAL" OR YDISPLAY.TYPE = "4 TOTAL ONLY" OR YDISPLAY.TYPE = "6 FOOTER" THEN
                IF YDISPLAY.TYPE = "3 LINE+TOTAL" THEN
                    YCNT.TOT1.COL = COUNT(R.NEW(RG.CRE.COLUMN)<1,YAV.MNE>,SM)+1
                    FOR YTOT1 = 1 TO YCNT.TOT1.COL
                        YCURR.TOT1.NO += 1
                        YSUFFIX = YT.MNE.VALTYP<YAV.MNE>
                        IF YSUFFIX THEN
                            YVALTYP.LINE = 1
                            YRG<-1> = YPRETOT:'YCNT = COUNT(YR.TOT1(YAV.TOT)<':YCURR.TOT1.NO:'>,VM)'
                            YRG<-1> = YPRETOT:'IF YCNT >= YCOUNT.TOT1 THEN YCOUNT.TOT1 = YCNT+1'
                            IF YSUFFIX = "M" THEN
                                YSUFFIX = "<":YCURR.TOT1.NO:",1>"
                            END ELSE
                                YSUFFIX = "<":YCURR.TOT1.NO:",1,1>"
                                YSUBTYP.LINE = 1
                                YRG<-1> = YPRETOT:'YCNT = COUNT(YR.TOT1(YAV.TOT)<':YCURR.TOT1.NO:',1>,SM)'
                                YRG<-1> = YPRETOT:'IF YCNT >= YCOUNT.AS.TOT1 THEN YCOUNT.AS.TOT1 = YCNT+1'
                            END
                        END ELSE
                            YSUFFIX = "<":YCURR.TOT1.NO:">"
                        END
                        GOSUB MODIFY.FIELD
                    NEXT YTOT1
                END
            END
            YCURR.FDNO += 1
        END
    NEXT YAV.WR
    YPRE.DECI = YPRETOT ; GOSUB DECIDE.END.OF.LINE
    IF NOT(YVALTYP.LINE) THEN GOTO ASK.FOR.TOTAL2
    IF YSUBTYP.LINE THEN
        YRG<-1> = YPRETOT:'YAV = 1'
        YPRESUBVAL = YPRETOT ; GOSUB PRINT.SUBTOT1.LINE
    END
*
*------------------------------------------------------------------------
*
* Handle multi value totals (Detail line is printed)
*
    YRG<-1> = '*'
    YRG<-1> = YPRETOT:'FOR YAV = 2 TO YCOUNT.TOT1'
    YRG<-1> = YPRETOT:'  YCOUNT.AS.TOT1 = 1'
    YCURR.FDNO = 1 ; YCURR.PTNO = 0 ; YCURR.COL = 1
    YCURR.TOT1.NO = 0 ; YPRE = YPRETOT:"  " ; YPRE.UPD = YPRE
    FOR YAV.WR = 1 TO YCOUNT.WR
        GOSUB DEFINE.MNEMONIC.WITHIN.LOOP
        YDISPLAY.TYPE = R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE>
        IF YDISPLAY.TYPE THEN
            IF YDISPLAY.TYPE = "3 LINE+TOTAL" OR YDISPLAY.TYPE = "4 TOTAL ONLY" OR YDISPLAY.TYPE = "6 FOOTER" THEN
                IF YDISPLAY.TYPE = "3 LINE+TOTAL" THEN
                    YCNT.TOT1.COL = COUNT(R.NEW(RG.CRE.COLUMN)<1,YAV.MNE>,SM)+1
                    FOR YTOT1 = 1 TO YCNT.TOT1.COL
                        YCURR.TOT1.NO += 1
                        YSUFFIX = YT.MNE.VALTYP<YAV.MNE>
                        IF YSUFFIX THEN
                            IF YSUFFIX = "M" THEN
                                YSUFFIX = "<":YCURR.TOT1.NO:",YAV>"
                            END ELSE
                                YSUFFIX = "<":YCURR.TOT1.NO:",YAV,1>"
                                YRG<-1> = YPRETOT:'  YCNT = COUNT(YR.TOT1(YAV.TOT)<':YCURR.TOT1.NO:',YAV>,SM)'
                                YRG<-1> = YPRETOT:'  IF YCNT >= YCOUNT.AS.TOT1 THEN YCOUNT.AS.TOT1 = YCNT+1'
                            END
                            GOSUB MODIFY.FIELD
                        END
                    NEXT YTOT1
                END
            END
            YCURR.FDNO += 1
        END
    NEXT YAV.WR
    YPRE.DECI = YPRETOT:"  " ; GOSUB DECIDE.END.OF.LINE
    IF YSUBTYP.LINE THEN
        YPRESUBVAL = YPRETOT:"  " ; GOSUB PRINT.SUBTOT1.LINE
    END
    YRG<-1> = YPRETOT:'NEXT YAV'
*
*------------------------------------------------------------------------
*
* Handle totals (Totals are printed only)
*
ASK.FOR.TOTAL2:
*
    IF NOT(YDIM.TOT2.COL) THEN GOTO TOTAL1.TOTAL2.END
    YRG<-1> = '*'
    YRG<-1> = YPRETOT:'YCOUNT.TOT2 = 1; YCOUNT.AS.TOT2 = 1'
    GOSUB DEFINE.MNEMONIC.SEQUENCE
    YCURR.FDNO = 1 ; YCURR.PTNO = 0 ; YCURR.COL = 1 ; YMODTYP = "TOT2"
    YVALTYP.TOT2 = 0 ; YSUBTYP.TOT2 = 0 ; YLINE.COLTYP = 5
* YLINE.COLTYP = 5 = use Columns of preliminary YT.TOT2.COL (when
* existing), otherwise calculate Column and complete YT.TOT2.COL
    YPRE = YPRETOT ; YPRE.UPD = YPRE ; YCURR.TOT2.NO = 0
    FOR YAV.WR = 1 TO YCOUNT.WR
        GOSUB DEFINE.MNEMONIC.WITHIN.LOOP
        YDISPLAY.TYPE = R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE>
        IF YDISPLAY.TYPE THEN
            IF YDISPLAY.TYPE = "4 TOTAL ONLY" OR YDISPLAY.TYPE = "6 FOOTER" THEN
                YCNT.TOT2.COL = COUNT(R.NEW(RG.CRE.COLUMN)<1,YAV.MNE>,SM)+1
                FOR YTOT2 = 1 TO YCNT.TOT2.COL
                    YCURR.TOT2.NO += 1
                    YSUFFIX = YT.MNE.VALTYP<YAV.MNE>
                    IF YSUFFIX THEN
                        YVALTYP.TOT2 = 1
                        YRG<-1> = YPRETOT:'YCNT = COUNT(YR.TOT2(YAV.TOT)<':YCURR.TOT2.NO:'>,VM)'
                        YRG<-1> = YPRETOT:'IF YCNT >= YCOUNT.TOT2 THEN YCOUNT.TOT2 = YCNT+1'
                        IF YSUFFIX = "M" THEN
                            YSUFFIX = "<":YCURR.TOT2.NO:",1>"
                        END ELSE
                            YSUFFIX = "<":YCURR.TOT2.NO:",1,1>"
                            YSUBTYP.TOT2 = 1
                            YRG<-1> = YPRETOT:'YCNT = COUNT(YR.TOT2(YAV.TOT)<':YCURR.TOT2.NO:',1>,SM)'
                            YRG<-1> = YPRETOT:'IF YCNT >= YCOUNT.AS.TOT2 THEN YCOUNT.AS.TOT2 = YCNT+1'
                        END
                    END ELSE
                        YSUFFIX = "<":YCURR.TOT2.NO:">"
                    END
                    GOSUB MODIFY.FIELD
                NEXT YTOT2
            END
            YCURR.FDNO += 1
        END
    NEXT YAV.WR
    YPRE.DECI = YPRETOT ; GOSUB DECIDE.END.OF.LINE
    IF NOT(YVALTYP.TOT2) THEN GOTO TOTAL1.TOTAL2.END
    YLINE.COLTYP = 6
* YLINE.COLTYP = 6 = pick up Column from YT.TOT2.COL
    IF YSUBTYP.TOT2 THEN
        YRG<-1> = YPRETOT:'YAV = 1'
        YPRESUBVAL = YPRETOT ; GOSUB PRINT.SUBTOT2.LINE
    END
*
*------------------------------------------------------------------------
*
* Handle multi value totals (Totals are printed only)
*
    YRG<-1> = '*'
    YRG<-1> = YPRETOT:'FOR YAV = 2 TO YCOUNT.TOT2'
    YRG<-1> = YPRETOT:'  YCOUNT.AS.TOT2 = 1'
    YCURR.FDNO = 1 ; YCURR.PTNO = 0 ; YCURR.COL = 1
    YCURR.TOT2.NO = 0 ; YPRE = YPRETOT:"  " ; YPRE.UPD = YPRE
    FOR YAV.WR = 1 TO YCOUNT.WR
        GOSUB DEFINE.MNEMONIC.WITHIN.LOOP
        YDISPLAY.TYPE = R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE>
        IF YDISPLAY.TYPE THEN
            IF YDISPLAY.TYPE = "4 TOTAL ONLY" OR YDISPLAY.TYPE = "6 FOOTER" THEN
                YCNT.TOT2.COL = COUNT(R.NEW(RG.CRE.COLUMN)<1,YAV.MNE>,SM)+1
                FOR YTOT2 = 1 TO YCNT.TOT2.COL
                    YCURR.TOT2.NO += 1
                    YSUFFIX = YT.MNE.VALTYP<YAV.MNE>
                    IF YSUFFIX THEN
                        IF YSUFFIX = "M" THEN
                            YSUFFIX = "<":YCURR.TOT2.NO:",YAV>"
                        END ELSE
                            YSUFFIX = "<":YCURR.TOT2.NO:",YAV,1>"
                            YRG<-1> = YPRETOT:'  YCNT = COUNT(YR.TOT2(YAV.TOT)<':YCURR.TOT2.NO:',YAV>,SM)'
                            YRG<-1> = YPRETOT:'  IF YCNT >= YCOUNT.AS.TOT2 THEN YCOUNT.AS.TOT2 = YCNT+1'
                        END
                        GOSUB MODIFY.FIELD
                    END
                NEXT YTOT2
            END
            YCURR.FDNO += 1
        END
    NEXT YAV.WR
    YPRE.DECI = YPRETOT ; GOSUB DECIDE.END.OF.LINE
    IF YSUBTYP.TOT2 THEN
        YPRESUBVAL = YPRETOT:"  " ; GOSUB PRINT.SUBTOT2.LINE
    END
    YRG<-1> = YPRETOT:'NEXT YAV'
*------------------------------------------------------------------------
*
TOTAL1.TOTAL2.END:
*
    IF R.NEW(RG.CRE.SUPPR.SINGLE.TOTAL) THEN IF NOT(YDIM.TOT2.COL) THEN
        YPRETOT = YPRETOT[3,99]
        YRG<-1> = YPRETOT:'END'
        YRG<-1> = YPRETOT:'YR.TNO(YAV.TOT) = ""'
    END
    IF YCURR.PTNO THEN
        IF R.NEW(RG.CRE.ADD.BLANK.LINE) = "1 AFTER TOTAL" THEN
            YPRE.DECI = YPRETOT ; GOSUB DECIDE.PRINT.DISPLAY.EMPTY.LINE
        END
    END
    YRG<-1> = '      NEXT YAV.TOT'
    YRG<-1> = '    END'
    RETURN
*
*************************************************************************
*
ASK.FOR.PAGING:
*
* Define Table to compare old and new key
*
    IF NOT(YGROUP.LENGTH) THEN YKEYCOL = 1
    ELSE YKEYCOL = YGROUP.LENGTH + 1
    YPAGCOL = 0
    GOSUB DEFINE.MNEMONIC.SEQUENCE
    FOR YAV.WR = 1 TO YCOUNT.WR
        GOSUB DEFINE.MNEMONIC.WITHIN.LOOP
* GB9801237
        YTMASK = R.NEW(RG.CRE.MASK)<1,YAV.MNE>
        IF R.NEW(RG.CRE.KEY.TYPE)<1,YAV.MNE> THEN
            IF NOT(YTMASK) THEN
                YKEYCOL += R.NEW(RG.CRE.NUMBER.OF.CHAR)<1,YAV.MNE> + 2
            END ELSE
                YKEYCOL += R.NEW(RG.CRE.NUMBER.OF.CHAR)<1,YAV.MNE>
            END
            IF R.NEW(RG.CRE.KEY.TYPE)<1,YAV.MNE>[1,1] > 2 THEN
                YPAGCOL = YKEYCOL
            END
        END
    NEXT YAV.WR
    IF NOT(YPAGCOL) THEN RETURN
* no Paging within Group
*
* Ask for old/new key change to print new page
*
    YRG<-1> = '*'
    YRG<-1> = '    IF YKEY.OLD[1,':YPAGCOL:'] <> YKEY[1,':YPAGCOL:'] THEN'
    IF YANY.CONTIN.TOTAL THEN
        YRG<-1> = '      MAT YR.REC.TOT = 0'
    END
    YRG<-1> = '      IF YKEY.OLD[1,':YGROUP.LENGTH+1:'] = YKEY[1,':YGROUP.LENGTH+1:'] THEN'
* no paging when Group changes (Paging by Group at another place)
    YSUBGROUP = 1 ; YPRE.EOG = "        " ; GOSUB COMMON.END.OF.GROUP
    YPREHDR = "      " ; GOSUB DEFINE.HEADER.SUBGROUP
    YRG<-1> = '      END'
    YRG<-1> = '    END'
    RETURN
*
*************************************************************************
*
COMMON.END.OF.GROUP:
*
    YRG<-1> = YPRE.EOG:'YTEXT = "*** END OF GROUP ***"'
    GOSUB COMMON.GROUP
    IF R.NEW(RG.CRE.RESET.PAGE.NO) THEN IF NOT(YSUBGROUP) THEN
        YRG<-1> = YPRE.EOG:'IF YPRINTING THEN'
        YRG<-1> = YPRE.EOG:'  CALL PRINTER.OFF; CALL PRINTER.CLOSE(REPORT.ID,PRT.UNIT,"")'
        YRG<-1> = YPRE.EOG:'  CALL PRINTER.ON(REPORT.ID,PRT.UNIT)'
        YRG<-1> = YPRE.EOG:'END'
    END
    YRG<-1> = YPRE.EOG:'IF NOT(YPRINTING) THEN'
    YRG<-1> = YPRE.EOG:'  L = 999; GOSUB 9000010'
    YRG<-1> = YPRE.EOG:'  IF COMI = C.U THEN RETURN  ;* end of pgm'
    YRG<-1> = YPRE.EOG:'END'
    RETURN
*
*************************************************************************
*
COMMON.GROUP:
*
* If special headings are defined as NONE (usual for advices) then do
* not print the end of group and end of report messages.
*
    IF R.NEW(RG.CRE.SPECIAL.HEADING) # "NONE" AND R.NEW(RG.CRE.SPECIAL.HEADING) # "FLAT" THEN
        YRG<-1> = YPRE.EOG:'IF LNGG <> 1 THEN CALL TXT ( YTEXT )'
        YRG<-1> = YPRE.EOG:'IF YPRINTING THEN'
        YRG<-1> = YPRE.EOG:'  PRINT'
        YRG<-1> = YPRE.EOG:'END ELSE'
*
* Suppress blank line before END-OF-...-line when blank line causes
* carry over to next page:
        YRG<-1> = YPRE.EOG:'  IF L < 19 THEN'
        YPRE.DECI = YPRE.EOG:"    "
        GOSUB PRINT.DISPLAY.WITH.PREFIX
        YRG<-1> = YPRE.EOG:'  END'
        YRG<-1> = YPRE.EOG:'END'
        YRG<-1> = YPRE.EOG:'PRINT YTEXT'
        YRG<-1> = YPRE.EOG:'IF NOT(YPRINTING) THEN YT.PAGE<P,L> = YTEXT; L += 1; PRINT @(0,L):'
    END
*
    RETURN
*
*************************************************************************
*
* Handle subvalue totals (Detail line is printed)
*
PRINT.SUBTOT1.LINE:
*
    YRG<-1> = '*'
    YRG<-1> = YPRESUBVAL:'FOR YAS = 2 TO YCOUNT.AS.TOT1'
    YCURR.FDNO = 1 ; YCURR.PTNO = 0 ; YCURR.COL = 1 ; YCURR.TOT1.NO = 0
    YPRE = YPRESUBVAL:"  " ; YPRE.UPD = YPRE
    FOR YAV.WR = 1 TO YCOUNT.WR
        GOSUB DEFINE.MNEMONIC.WITHIN.LOOP
        YDISPLAY.TYPE = R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE>
        IF YDISPLAY.TYPE THEN
            IF YDISPLAY.TYPE = "3 LINE+TOTAL" OR YDISPLAY.TYPE = "4 TOTAL ONLY" OR YDISPLAY.TYPE = "6 FOOTER" THEN
                IF YDISPLAY.TYPE = "3 LINE+TOTAL" THEN
                    YCNT.TOT1.COL = COUNT(R.NEW(RG.CRE.COLUMN)<1,YAV.MNE>,SM)+1
                    FOR YTOT1 = 1 TO YCNT.TOT1.COL
                        YCURR.TOT1.NO += 1
                        YSUFFIX = YT.MNE.VALTYP<YAV.MNE>
                        IF YSUFFIX = "S" THEN
                            YSUFFIX = "<":YCURR.TOT1.NO:",YAV,YAS>"
                            GOSUB MODIFY.FIELD
                        END
                    NEXT YTOT1
                END
            END
            YCURR.FDNO += 1
        END
    NEXT YAV.WR
    YPRE.DECI = YPRESUBVAL:"  " ; GOSUB DECIDE.END.OF.LINE
    YRG<-1> = YPRESUBVAL:'NEXT YAS'
    RETURN
*
*************************************************************************
*
* Handle subvalue totals (Totals are printed only)
*
PRINT.SUBTOT2.LINE:
*
    YRG<-1> = '*'
    YRG<-1> = YPRESUBVAL:'FOR YAS = 2 TO YCOUNT.AS.TOT2'
    YCURR.FDNO = 1 ; YCURR.PTNO = 0 ; YCURR.COL = 1 ; YCURR.TOT2.NO = 0
    YPRE = YPRESUBVAL:"  " ; YPRE.UPD = YPRE
    FOR YAV.WR = 1 TO YCOUNT.WR
        GOSUB DEFINE.MNEMONIC.WITHIN.LOOP
        YDISPLAY.TYPE = R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE>
        IF YDISPLAY.TYPE THEN
            IF YDISPLAY.TYPE = "4 TOTAL ONLY" OR YDISPLAY.TYPE = "6 FOOTER" THEN
                YCNT.TOT2.COL = COUNT(R.NEW(RG.CRE.COLUMN)<1,YAV.MNE>,SM)+1
                FOR YTOT2 = 1 TO YCNT.TOT2.COL
                    YCURR.TOT2.NO += 1
                    YSUFFIX = YT.MNE.VALTYP<YAV.MNE>
                    IF YSUFFIX = "S" THEN
                        YSUFFIX = "<":YCURR.TOT2.NO:",YAV,YAS>"
                        GOSUB MODIFY.FIELD
                    END
                NEXT YTOT2
            END
            YCURR.FDNO += 1
        END
    NEXT YAV.WR
    YPRE.DECI = YPRESUBVAL:"  " ; GOSUB DECIDE.END.OF.LINE
    YRG<-1> = YPRESUBVAL:'NEXT YAS'
    RETURN
*
*************************************************************************
*
ASK.FOR.HEADER.PRINT:
*
* Define Table to compare old and new key
*
    IF NOT(YHEADER.DISPLAY) THEN RETURN
*
    GOSUB DEFINE.MNEMONIC.SEQUENCE
    YCURR.FDNO = 1 ; YCURR.PTNO = 0 ; YCURR.COL = 1
    YLINE.COLTYP = 0
* YLINE.COLTYP = 0 = no Column table used
    YPRE = "    " ; YPRE.UPD = YPRE ; YMODTYP = "HDR"
    YRG<-1> = '    YHEADER.DISPLAY = 0; YHEADER.STATUS = ""'
    YCURR.HDRNO = 0 ; YLAST.HDRNO = 0
*
    FOR YAV.WR = 1 TO YCOUNT.WR
        GOSUB DEFINE.MNEMONIC.WITHIN.LOOP
        YDISPLAY.TYPE = R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE>
        IF YDISPLAY.TYPE THEN
            IF YDISPLAY.TYPE = "1 HEADER" THEN
                IF NOT(YCURR.HDRNO) THEN YRG<-1> = '    BEGIN CASE'
                YCURR.HDRNO += 1 ; YLAST.HDRNO = YCURR.HDRNO
                YRG<-1> = '      CASE YR.REC.OLD(':YCURR.FDNO:') <> YR.REC(':YCURR.FDNO:'); YHEADER.STATUS = ':YCURR.HDRNO
            END
            YCURR.FDNO += 1
        END
    NEXT YAV.WR
    IF YCURR.HDRNO THEN YRG<-1> = '    END CASE'
*
    IF YHDR.BLK.LIN = 1 OR YTOT.BLK.LIN = 1 THEN
        YRG<-1> = '    IF YHEADER.STATUS THEN'
        YRG<-1> = '      GOSUB 9000010; Y1ST.LIN = 1'
        YRG<-1> = '      IF COMI = C.U THEN RETURN  ;* end of pgm'
        YRG<-1> = '    END'
    END ELSE
        IF YHDR.BLK.LIN = 2 OR YTOT.BLK.LIN = 2 THEN
            YRG<-1> = '    IF YHEADER.STATUS THEN'
            YRG<-1> = '      GOSUB 9000010'
            YRG<-1> = '      IF COMI = C.U THEN RETURN  ;* end of pgm'
            YRG<-1> = '      GOSUB 9000010; Y1ST.LIN = 1'
            YRG<-1> = '      IF COMI = C.U THEN RETURN  ;* end of pgm'
            YRG<-1> = '    END'
        END
    END
    YCURR.FDNO = 1 ; YCURR.HDRNO = 0
    FOR YAV.WR = 1 TO YCOUNT.WR
        GOSUB DEFINE.MNEMONIC.WITHIN.LOOP
        YDISPLAY.TYPE = R.NEW(RG.CRE.DISPLAY.TYPE)<1,YAV.MNE>
        IF YDISPLAY.TYPE THEN
            IF YDISPLAY.TYPE = "1 HEADER" THEN
                YSUFFIX = "" ; YCURR.HDRNO += 1 ; GOSUB MODIFY.FIELD
            END
            YCURR.FDNO += 1
        END
    NEXT YAV.WR
    IF YCURR.PTNO THEN
        YRG<-1> = '    IF YHEADER.DISPLAY THEN'
        YRG<-1> = '      GOSUB 9000010'
        YRG<-1> = '      IF COMI = C.U THEN RETURN  ;* end of pgm'
        YRG<-1> = '    END'
    END
    RETURN
*
*************************************************************************
*
UPDATE.MULTI.AND.SPLIT.TABLE:
*
    IF NOT(YFIELD) THEN RETURN
* exlude empty field or ID-definition
*
    IF R.NEW(RG.CRE.MULTI.SPLIT.TOT)<1,YAV> = "MULTI" THEN
        YT.MNE.VALTYP<YAV> = "S" ; RETURN
* update sub value table when special 'MULTI' definition
    END
*
    IF YFIELD[1,1] < 0 OR YFIELD[1,1] > 9 THEN RETURN
    YFIELD = FIELD(YFIELD,"[",1)
    IF INDEX(YFIELD,".",1) THEN RETURN
* exclude Definitions without Field no. and Fields with value/sub no.
*
    IF YUPDATE.FIELD = "MNEMON" THEN YFORFIL.1 = ""
    ELSE YFORFIL.1 = R.NEW(RG.CRE.MODIF.FILE)<1,YAV,YAS>
    YFORFIL = YFORFIL.1
    IF NOT(YFORFIL) THEN
        YFORFIL = R.NEW(RG.CRE.MNEMON.FILE)<1,YAV,YAS>
        IF NOT(YFORFIL) THEN YFORFIL = R.NEW(RG.CRE.READ.FILE)<1,1>
    END
    IF R.NEW(RG.CRE.MULTI.SPLIT.TOT)<1,YAV> = "SPLIT" THEN
        IF YFORFIL.1 THEN RETURN
* exclude field number of foreign file (in case of REPLACE)
        LOCATE YFORFIL IN R.NEW(RG.CRE.READ.FILE)<1,1> SETTING YAV.FILE
        ELSE RETURN
        LOCATE YFIELD IN YT.SPLIT<YAV.FILE,1> SETTING X
        ELSE YT.SPLIT<YAV.FILE,-1> = YFIELD
* update table with splitted fields (in sequence of READ.FILE)
        RETURN
* Exclude fields which are splitted to several records
    END
*
    V = 1 ; ROUTINE = YFORFIL["$",1,1] ; CALL @ROUTINE
    MAT R = "" ; MAT N = "" ; MAT T = ""
    ID.R = "" ; ID.N = "" ; ID.T = "" ; ID.F = ""
    MAT CHECKFILE = "" ; MAT CONCATFILE = ""
    IF YFIELD > V THEN RETURN
    IF F(YFIELD)[4,2] = "XX" THEN IF F(YFIELD)[7,2] <> "LL" THEN
        YT.MNE.VALTYP<YAV> = "S" ; RETURN
    END
    IF F(YFIELD)[1,2] = "XX" THEN IF F(YFIELD)[4,2] <> "LL" THEN
        IF YT.MNE.VALTYP<YAV> <> "S" THEN YT.MNE.VALTYP<YAV> = "M"
    END
    RETURN
*
*************************************************************************
*
DECIDE.PRINT.DISPLAY:
*
    YPRE.DECI = "  "
*
PRINT.DISPLAY.WITH.PREFIX:
*
    YRG<-1> = YPRE.DECI:'GOSUB 9000000' ; GOTO DECIDE.TOGETHER
*
DECIDE.PRINT.DISPLAY.EMPTY.LINE:
*
    YRG<-1> = YPRE.DECI:'GOSUB 9000010'
*
DECIDE.TOGETHER:
*
    YRG<-1> = YPRE.DECI:'IF COMI = C.U THEN RETURN  ;* end of pgm'
    RETURN
*
*************************************************************************
*
DECIDE.END.OF.LINE:
*
    IF YCURR.PTNO THEN
        YRG<-1> = YPRE.DECI:'GOSUB 9000000'
        YRG<-1> = YPRE.DECI:'IF COMI = C.U THEN RETURN  ;* end of pgm'
    END
    RETURN
*
*************************************************************************
*
DECIDE.HEADER.BLANK.LINE:
*
    IF YHDR.BLK.LIN = 1 THEN
        YRG<-1> = '    IF Y1ST.LIN THEN'
        YRG<-1> = '      Y1ST.LIN = 0; GOSUB 9000010'
        YRG<-1> = '      IF COMI = C.U THEN RETURN  ;* end of pgm'
        YRG<-1> = '    END'
        RETURN
    END
    IF YHDR.BLK.LIN = 2 THEN
        YRG<-1> = '    IF Y1ST.LIN THEN'
        YRG<-1> = '      Y1ST.LIN = 0; GOSUB 9000010'
        YRG<-1> = '      IF COMI = C.U THEN RETURN  ;* end of pgm'
        YRG<-1> = '      GOSUB 9000010'
        YRG<-1> = '      IF COMI = C.U THEN RETURN  ;* end of pgm'
        YRG<-1> = '    END'
    END
    RETURN
*
*************************************************************************
*
* Every used file (READ.FILE or MODIF.FILE) will be controlled by
* User profile in case of SORT or OUTPUT:
*
SMS.FILE.CHECK:
    CALL REPGEN.SMS.FILE(YRG, YT.SMS.FILE)

    RETURN
*
*************************************************************************
*
* Ask for validate file password in connection with Company code:
*
SMS.COMPANY.CHECK:
*
    YRG<-1> = '*'
    YRG<-1> = '* Ask for valid file password in connection with Company code'
    YRG<-1> = '9300000:'
    YRG<-1> = '*'
    YRG<-1> = '  IF X THEN IF R.USER<EB.USE.COMPANY.RESTR,X> THEN'
    YRG<-1> = '    IF R.USER<EB.USE.COMPANY.RESTR,X> <> YID.COMP THEN X = 0'
    YRG<-1> = '  END'
    YRG<-1> = '  RETURN'
    YRG<-1> = STR("*",73)
    RETURN
*
*************************************************************************
*
* Update SMS Table for faster use:
*
CREATE.PW.TABLE:
*
    YRG<-1> = '*'
    YRG<-1> = YPRECOM:'  YT.SMS = ""'
    YCOUNT = COUNT(YT.SMS.FILE,FM)+1
    FOR YAF = 1 TO YCOUNT
        IF YAF = 1 THEN
            YRG<-1> = YPRECOM:'  YT.SMS.FILE = "':YT.SMS.FILE<1>:'"'
        END ELSE
            YRG<-1> = YPRECOM:'  YT.SMS.FILE<-1> = "':YT.SMS.FILE<YAF>:'"'
        END
    NEXT YAF
    YRG<-1> = YPRECOM:'  YCOUNT = COUNT(R.USER<EB.USE.APPLICATION>,VM)+1'
    YRG<-1> = YPRECOM:'  FOR YAV = 1 TO YCOUNT'
    YRG<-1> = YPRECOM:'    IF R.USER<EB.USE.DATA.COMPARISON,YAV> THEN'
    YRG<-1> = YPRECOM:'      YRESTR = R.USER<EB.USE.COMPANY.RESTR,YAV>'
    YRG<-1> = YPRECOM:'      IF YRESTR THEN'
    YRG<-1> = YPRECOM:'         IF YRESTR = YCOM THEN YRESTR = ""'
    YRG<-1> = YPRECOM:'      END'
    YRG<-1> = YPRECOM:'      IF NOT(YRESTR) THEN'
    YRG<-1> = YPRECOM:'        YAPPLI = R.USER<EB.USE.APPLICATION,YAV>'
    YRG<-1> = YPRECOM:'        LOCATE YAPPLI IN YT.SMS.FILE<1> SETTING X ELSE X = 0'
    YRG<-1> = YPRECOM:'        IF X THEN'
**************WAL
    YRG<-1> = YPRECOM:'          IF (INDEX(R.USER<EB.USE.FUNCTION,YAV>,"P",1)) OR (INDEX(R.USER<EB.USE.FUNCTION,YAV>,"S",1)) THEN'
    YRG<-1> = YPRECOM:'          LOCATE YAPPLI IN YT.SMS<1,1> SETTING X ELSE'
    YRG<-1> = YPRECOM:'            YT.SMS<1,-1> = YAPPLI'
    YRG<-1> = YPRECOM:'          END'
    YRG<-1> = YPRECOM:'          YT.SMS<2,X,-1> = YAV'
    YRG<-1> = YPRECOM:'          END'
    YRG<-1> = YPRECOM:'        END'
    YRG<-1> = YPRECOM:'      END'
    YRG<-1> = YPRECOM:'    END'
    YRG<-1> = YPRECOM:'  NEXT YAV'
    YRG<-1> = '*'
    RETURN
*
*************************************************************************
COMPILE.IN.JBASE:   *GB0002062<start>
*---------------
*
* Call the jBASE compiler.
* First check if the program is in exception list. If it is not
* there then compile using jBASE compiler.
*

    LOCATE SOURCE.ITEM IN EXCEPTION.JBC.COMP<1> SETTING POS.FOUND ELSE POS.FOUND = ''
    IF POS.FOUND THEN
        PRINT
        PRINT 'PROGRAM ':SOURCE.ITEM:' WILL NOT BE COMPILED BY jBASE '
        PRINT
    END

    JBASE.ERROR = ''
    IF JBC.INSTALLED THEN
        CALL JBASE.COMPILE('',SOURCE.ITEM,SOURCE.FNAME,JBASE.ERROR)
        E = JBASE.ERROR
    END
    RETURN

*******************GB0002062<end>
**************************************************************
INITIALISE:
*---------

*
* The jBASE compiler should be invoked only if jBASE is installed
* If jBASE is installed then the env variable JBCCONNECT will be set.
* Check for this and then set a flag to use jBASE compiler.
*
    RUNNING.IN.JBASE = INDEX(SYSTEM(1021), 'TEMENOS',1)
    JBC.POS = ''
    OUTPUT.ENV = ''
    JBC.INSTALLED = ''
    EXECUTE 'ENV' CAPTURING OUTPUT.ENV
    JBC.POS = INDEX(OUTPUT.ENV,'JBCCONNECT',1)
    IF JBC.POS THEN
        IF NOT(RUNNING.IN.JBASE) THEN
            JBC.INSTALLED = 1
        END ELSE
            JBC.INSTALLED = ''
        END
    END ELSE
        JBC.INSTALLED = ''
    END
*
* jBASE compiler is invoked using a shell script. If the script is not found,
* then it should create the script.
*
    IF JBC.INSTALLED THEN
        CALL JBASE.SCRIPT.FILE
    END

* Exception list for jBASE compiler.
* The exception programs should be stored in the variable EXCEPTION.JBC.COMP.
* Before the program to be compiled is compiled by jBASE compiler, the progam is
* checked if it is in the exception list or not.
* E.g. EXCEPTION.JBC.COMP<-1> = 'PROGRAM.NAME'
*
    EXCEPTION.JBC.COMP = ''
    CRT "JBC.INSTALLED = ":JBC.INSTALLED
    CRT "RUNNING.IN.JBASE = ":RUNNING.IN.JBASE
    RETURN
***************************************************************
END
