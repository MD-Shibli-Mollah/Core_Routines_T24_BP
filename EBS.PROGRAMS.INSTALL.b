* @ValidationCode : MjoxMjQ3NDA4ODE3OkNwMTI1MjoxNTUwMjM5MzQwMzQzOnBtYWhhOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTgxMS4yMDE4MTAyMi0xNDA2Oi0xOi0x
* @ValidationInfo : Timestamp         : 15 Feb 2019 19:32:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : pmaha
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 20 07/06/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>3607</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.Upgrade
SUBROUTINE EBS.PROGRAMS.INSTALL
* Version 11 05/01/00  GLOBUS Release No. G10.2.01 25/02/00
*************************************************************************
*     Version 6.49.3 released on 15/12/86
*     PROGRAM : EBS.PROGRAMS.INSTALL AUTHOR: B. FARRELLY  DATE: 09/10/87

*---- OBJECTIVES: To build a select list of programs that can
*     be either :-
*     Compiled
*     Cataloged - deletion of object afterwards
*     Compiled and Cataloged -if compilation success.
*     Delete Catalog entry.
*     If no records selected then program will abort.
*     If compilation at any option fails for a program then
*     any error select list of programs failed is displayed
*     and an Compile.error.list select file written for
*     future use - user and select list specific.
*
*------------------------------------------------------------------------
*
* 08/10/93 - GB9301396
*            Allow local catalog option from SPF
*
* 19/09/93 - GB9400926
*            If R.SPF.SYSTEM is null (i.e. program is being run from
*            outside of GLOBUS), open the SPF file and read the system
*            record so that the preferred catalog option (local or not)
*            can be used
*            Default catalog option is now local (if they want to use
*            Global catalog, they must enter it on the SPF)
*            Allow for a BP existing, instead of BP1 and BP2, e.g. in
*            TEMP.RELEASE
*            Parameters are passed across in INPUT.BUFFER, so that
*            program can be called from within GLOBUS (as part of the
*            release procedures) or can be run outside of GLOBUS (e.g.
*            to compile and catalog all programs).  TXTINP should not be
*            used to get parameters from INPUT.BUFFER as this would not
*            work outside of GLOBUS
*
* 18/08/95 - GB9500958
*            If program is being run from outside of GLOBUS, ensure that
*            R.SPF.SYSTEM is setup correctly
*
* 21/04/97 - GB9700440
*            Do not delete the object code when cataloging globally.
*            Amend program so that it will work with both GLOBUS.BP and
*            BP1 and BP2.
*            Also allow the user to enter "ALL" when prompted for a
*            select list name - this will then compile/catalog programs
*            for all installed products.
*
* 29/05/97 - GB9700661
*            When cataloging a program, delete the VOC entry if it is not
*            a VOC entry for a program.
*
*
* 08/06/00 - GB0001426
*            Hard code RELEASE.PROGS if the select list name is not passed
*           - cures problems when going from unamed to named
*
* 24/05/01 - GB0101476
*            Any progam that ends in .JBASE needs to be recognised as a jbase
*            only routine
*
*============================================================================
* NOTE DO NOT ADD ANY NEW CALLED SUBROUTINES TO THIS PROGRAM - OTHERWISE IT WILL
* CRASH DURING THE RELEASE - THE NEW SUBROUTINES WILL NOT BE RELEASED YET!!!
*23/08/00 - GB0002062
*           jBASE changes.
*           Program must call the jBASE compiler if required . This
*           will allow for jBASE checks to be performed when doing a
*           release to test PRD or GLOBUS.RELEASE there by closing the
*           loop for jBASE compatibility checks.
*
* 17/10/00 - GB0002069
*            Change program to take note of jBASE & UniVerse
*            specific programs
*
* 18/10/00 - GB0002660
*            Make LOGOUT a jBASE specific program
*
* 18/10/00 - GB0002666
*            Make SH a jBASE specific program
*
* 26/03/01 - GB0100873
*            Make JGLOBUS.COPY.JBASE a jBASE specific program
*
* 18/09/01 - GLOBUS_EN_10000148
*            Replace call to COMPILE.IN.JBASE with JBASE.COMPILE
*            (naming problems)
*
* 21/03/2002 - GLOBUS_BG_100000762
*              Changes made so that the program DOS gets compiled
*              only in jGLOBUS
*
* 23/09/09 - EN_10004355
*            Replace Globus.BP with T24.BP in T24 Server Code
*
* 25/11/2009 - BG_100025913
*             Soft code the folder named T24.BP
*
* 18/11/14 - Task:1171942 / Defect:1171562
*		     The field SPF.CATALOG is no longer required. Ref:CI_10024350
*
* 12/02/15 - Defect:1250871 / Task: 1252690
*            !HUSHIT is not supported in TAFJ, hence changed to use HUSHIT().
*
* 19/12/18 - Enhancement 2822523 / Task 2909926
*            Incorporation of EB_Upgrade component
****************************************************************************
*
*=============================================================================
    $INSERT I_COMMON
    $INSERT I_F.SPF
    $INSERT I_F.PGM.DATA.CONTROL
*
*------------------------------------------------------------------------
    GOSUB INITIALISE
    PROMPT ''
    EQUATE TRUE TO 1
    EQUATE FALSE TO 0
    E = ''
    OPEN.BP1.O = 0
    OPEN.BP2.O = 0
    OPEN.BP.O = 0
    BP.NAME = ''
*
    OPEN '','VOC' TO VOC ELSE
        E ='EB.RTN.**.ERROR.**.CANT.OPEN.VOC.FILE'
        GOTO FATAL.ERROR
    END
*
* Open &SAVEDLISTS&
*
    OPEN '','&SAVEDLISTS&' TO SAVEDLISTS ELSE
        E ='EB.RTN.**.ERROR.**.CANT.OPEN.&SAVEDLISTS'
        GOTO FATAL.ERROR
    END
*
* Open &TEMP& (for saving VOC entries which will be deleted if the
    OPEN '','&TEMP&' TO F.TEMP ELSE
        EXECUTE 'CREATE.FILE &TEMP& 2 17'
        OPEN '','&TEMP&' TO F.TEMP ELSE
            E ='EB.RTN.UNABLE.OPEN.&TEMP.FILE'
            GO FATAL.ERROR:
        END
    END
*
* Check to see if either both BP1 and BP2 exist or only T24.BP or BP
* exists
*
    TWO.BPS = 1
    OPEN '','BP1' TO F.BP1 ELSE TWO.BPS = 0
    IF TWO.BPS THEN
        OPEN '','BP2' TO F.BP2 ELSE TWO.BPS = 0
    END
    IF NOT(TWO.BPS) THEN
        BP.NAME = T24$BP
        OPEN BP.NAME TO F.BP ELSE
            BP.NAME = 'BP'
            OPEN '',BP.NAME TO F.BP ELSE
                E ='EB.RTN.**.ERROR.**.CANT.OPEN.BP.FILES'
                GOTO FATAL.ERROR
            END
        END
    END
*
    OPTIONS = 1:@FM:2:@FM:3:@FM:4
    ACCOUNT = TRIM(@WHO)
    PROGS = ''
    SLIST = ''
    USER = @USERNO



* Setup option to be used when cataloging (read the system record from
* the SPF if it is null, i.e. program is being run outside of GLOBUS)
*
    IF R.SPF.SYSTEM = '' OR R.SPF.SYSTEM = 0 THEN
        FILE.OPENED = 1
        OPEN '','F.SPF' TO F.SPF ELSE FILE.OPENED = 0
        IF FILE.OPENED THEN READ R.SPF.SYSTEM FROM F.SPF,'SYSTEM' ELSE NULL
    END

    CATALOG.OPTION = ""   ;* Universe is no longer supported Ref CI_10024350
*
* Open F.PGM.DATA.CONTROL
*
    OPEN '','F.PGM.DATA.CONTROL' TO F.PGM.DATA.CONTROL ELSE
        E ='EB.RTN.**.ERROR.**.CANT.OPEN.F.PGM.DATA.CONTROL'
        GOTO FATAL.ERROR
    END

START.10:
*
* See if there is anything in INPUT.BUFFER (i.e. if called from GLOBUS.
* RELEASE).  NOTE: This piece of coding should not be replaced by
* TXTINP as this would not work when the program is run outside of
* GLOBUS
*
    INPUT.PARAMS = INPUT.BUFFER
    IF NOT(INPUT.PARAMS) THEN
        INPUT.PARAMS = 'RELEASE.PROGS 2'
    END
    INPUT.BUFFER = ''
    CONVERT ' ' TO @FM IN INPUT.PARAMS
    CALL HUSHIT(1)
    CLEARSELECT
    CALL HUSHIT(0)
    PRINT
    PRINT SPACE(12):'GLOBUS PROGRAMS INSTALLATION    ':OCONV(DATE(),'D2E')
    PRINT SPACE(12):STR('*',41)
    PRINT
*
    IF TWO.BPS THEN PRINT 'Using files BP1 and BP2'
    ELSE PRINT 'Using file ':BP.NAME
    PRINT
*
    PRINT 'Enter program select list name : ':
*
    IF INPUT.PARAMS<1> THEN
        SLIST = INPUT.PARAMS<1>
        PRINT SLIST
    END ELSE
        INPUT SLIST
    END
*
    SLIST = TRIM(SLIST)
    IF SLIST <> 'ALL' THEN
        PRINT
        PRINT 'Using select list ':SLIST
        IF SLIST = '' THEN GO TERMINATE:
        PRINT
        DUMMY = @(0,0)                  ; * DISABLE AUTO END OF SCREEN PAUSES
        CALL HUSHIT(1)
        EXECUTE 'GET.LIST ':SLIST
        CALL HUSHIT(0)


        PRINT
        IF @SYSTEM.RETURN.CODE <= 0 THEN
            PRINT '*** No Records Selected ***'
            RETURN                       ; * This does not go through FATAL.ERROR as it is not necessarily wrong
        END
        PRINT '*** ':@SYSTEM.RETURN.CODE:' Records selected ***'

*---- BUILD UP SELECT ARRAY.
        LOOP
            READNEXT V$KEY ELSE V$KEY = ''
        UNTIL V$KEY = ''
            IF V$KEY[1,2] <> 'I_' AND V$KEY[1,2] <> '  ' AND V$KEY[1,1] <> '$' THEN
                IF PROGS = '' THEN PROGS = V$KEY
                ELSE PROGS := @FM:V$KEY
            END
        REPEAT
    END
*
    COMPILE.ERROR.FILE = 'CEL.':SLIST:'.':USER

    PRINT
    PRINT '1. Compile         '
    PRINT '2. Catalog         '
    PRINT '3. Compile AND Catalog (if compilation successful)'
    PRINT '4. Delete catalog entries'
    PRINT
    PRINT 'Enter the option you require : ':
*
    IF INPUT.PARAMS<2> THEN
        RESPONSE = INPUT.PARAMS<2>
        PRINT RESPONSE
    END ELSE
        INPUT RESPONSE,2:
    END
*
    LOCATE RESPONSE IN OPTIONS<1> SETTING POS ELSE STOP '  *** Invalid entry ***'
    PRINT
*
* If "ALL" was entered in replying to the select list prompt, build up
* a list of all installed programs according to the option entered (by
* checking source or object files)
*
    IF SLIST = 'ALL' THEN
        PRINT
        PRINT 'Building list'
        PRINT
*
        IF RESPONSE MATCHES '1':@VM:'3' THEN
            FILE.SUFFIX = ''
        END ELSE FILE.SUFFIX = '.O'
        IF TWO.BPS THEN
            CHECK.FILE = 'BP1':FILE.SUFFIX
            GOSUB BUILD.LIST
            CHECK.FILE = 'BP2':FILE.SUFFIX
            GOSUB BUILD.LIST
        END ELSE
            CHECK.FILE = BP.NAME:FILE.SUFFIX
            GOSUB BUILD.LIST
        END
*
* Write out list (so that it can be checked if necessary)
*
        WRITE PROGS TO SAVEDLISTS,'EBS.PROGRAMS.INSTALL.':USER
    END

    SAVE.LIST = ''

*---- DO COMPILES,COMPARES AND CATALOGING

    PTR = 0
    LOOP
        PTR += 1
    UNTIL PROGS<PTR> = ''
        IF TWO.BPS THEN
            BP.ONE = FALSE
            IF PROGS<PTR>[1,1] >= 'A' AND PROGS<PTR>[1,1] <= 'F' THEN BP.ONE = TRUE
        END
        BEGIN CASE
            CASE RESPONSE = 1
                GOSUB COMPILE.20:
            CASE RESPONSE = 2
                GOSUB CATALOG.30:
            CASE RESPONSE = 3
                PRINT
                GOSUB COMPILE.20:
                GOSUB CATALOG.30:
            CASE RESPONSE = 4
*               GOSUB DELETE.CATALOG.40:
            CASE RESPONSE = 5
                PROGS = ''
            CASE RESPONSE = 'Q'
                PROGS = ''
        END CASE
    REPEAT

    IF SAVE.LIST THEN
        WRITE SAVE.LIST TO SAVEDLISTS,COMPILE.ERROR.FILE
        Q.CNT = COUNT(SAVE.LIST,@FM)+(SAVE.LIST NE '')
        PRINT
        PRINT '*** Error':"'":'s in Select.list : ':COMPILE.ERROR.FILE
        FOR I = 1 TO Q.CNT
            PRINT '*** Program: ':FMT(SAVE.LIST<I>,'L#25'):'  Failed compilation ***'
        NEXT I
    END
    PRINT
    IF RESPONSE = 5 THEN GO START.10:

TERMINATE:
RETURN

*************************************************************************
*                                                                       *
*    S U B R O U T I N E S                                              *
*                                                                       *
*************************************************************************

COMPILE.20:

    IF PTR = 1 THEN
        DELETE SAVEDLISTS,COMPILE.ERROR.FILE
    END

*
** Skip any jBASE specific programs for UniVerse Compile
*
    PROG.NAME = PROGS<PTR>
    GOSUB IS.JBASE.PROGRAM
    IF NOT(IS.JBASE.PROGRAM) THEN
        IF TWO.BPS THEN
            IF BP.ONE THEN
                EXECUTE 'BASIC BP1 ':PROGS<PTR>
                SOURCE.FNAME = "BP1"
            END ELSE
                EXECUTE 'BASIC BP2 ':PROGS<PTR>
                SOURCE.FNAME = "BP2"
            END
        END ELSE
            EXECUTE 'BASIC ':BP.NAME:' ':PROGS<PTR>
            SOURCE.FNAME = BP.NAME
        END
    END                                ; * GB0002069
    SOURCE.ITEM = PROGS<PTR>
    GOSUB JBASE.COMPILE                ; *GB0002062
RETURN

*************************************************************************

CATALOG.30:

*
** Skip any jBASE specific programs for catalog
*
    PROG.NAME = PROGS<PTR>
    GOSUB IS.JBASE.PROGRAM
    IF IS.JBASE.PROGRAM THEN RETURN

    OBJECT.PRESENT = TRUE
    IF TWO.BPS THEN
        IF BP.ONE THEN
            IF OPEN.BP1.O = 0 THEN
                OPEN.BP1.O = 1
                OPEN '','BP1.O' TO F.BP1.O ELSE OPEN.BP1.O = 0
            END
            IF OPEN.BP1.O THEN
                READV R.BP FROM F.BP1.O,PROGS<PTR>,0 ELSE OBJECT.PRESENT = FALSE
            END ELSE OBJECT.PRESENT = FALSE
        END ELSE
            IF OPEN.BP2.O = 0 THEN
                OPEN.BP2.O = 1
                OPEN '','BP2.O' TO F.BP2.O ELSE OPEN.BP2.O = 0
            END
            IF OPEN.BP2.O THEN
                READV R.BP FROM F.BP2.O,PROGS<PTR>,0 ELSE OBJECT.PRESENT = FALSE
            END ELSE OBJECT.PRESENT = FALSE
        END
    END ELSE
        IF OPEN.BP.O = 0 THEN
            OPEN.BP.O = 1
            OPEN '',BP.NAME:'.O' TO F.BP.O ELSE OPEN.BP.O = 0
        END
        IF OPEN.BP.O THEN
            READV R.BP FROM F.BP.O,PROGS<PTR>,0 ELSE OBJECT.PRESENT = FALSE
        END ELSE OBJECT.PRESENT = FALSE
    END
    IF OBJECT.PRESENT THEN
*
        PRINT '*** Cataloging *** ':PROGS<PTR>
*
* If a VOC entry already exists which is not for a program, copy it to
* &TEMP&
*
        READ R.PROG FROM VOC,PROGS<PTR> THEN
            IF R.PROG<1> NE 'V' AND R.PROG<3> NE 'B' THEN
                WRITE R.PROG TO F.TEMP,PROGS<PTR>
                DELETE VOC,PROGS<PTR>
                PRINT '** Voc pointer already existed and not program type so - '
                PRINT '** ':PROGS<PTR>:' was written to &TEMP& file and deleted from VOC file **'
            END
        END
*
        IF TWO.BPS THEN
            IF BP.ONE THEN
                EXECUTE 'CATALOG BP1 ':PROGS<PTR>:" ":CATALOG.OPTION
            END ELSE
                EXECUTE 'CATALOG BP2 ':PROGS<PTR>:" ":CATALOG.OPTION
            END
        END ELSE
            EXECUTE 'CATALOG ':BP.NAME:' ':PROGS<PTR>:" ":CATALOG.OPTION
        END
        IF @SYSTEM.RETURN.CODE THEN
            SAVE.LIST<-1> = PROGS<PTR>
        END
    END ELSE
        SAVE.LIST<-1> = PROGS<PTR>
        PRINT '*** No object code --- can':"'":'t catalog *** ':PROGS<PTR>
    END
RETURN

*************************************************************************

DELETE.CATALOG.40:

*      EXECUTE 'DELETE.CATALOG ':PROGS<PTR>
RETURN

*************************************************************************
*
BUILD.LIST:
*
* Build up a list of all installed programs
*
    CALL HUSHIT(1)
    EXECUTE 'SSELECT ':CHECK.FILE
    CALL HUSHIT(0)
*
    LOOP
        READNEXT ID ELSE ID = ''
    WHILE ID
        IF ID[1,2] <> 'I_' AND ID[1,2] <> '  ' AND ID[1,1] <> '$' THEN
*
* Check product has been installed
*
            READ R.PGM.DATA.CONTROL FROM F.PGM.DATA.CONTROL,'BP>':ID ELSE
                R.PGM.DATA.CONTROL = ''
            END
*
            IF R.PGM.DATA.CONTROL<PDC.PRODUCT> = 'OB' THEN INSTALLED = 0
            ELSE INSTALLED = 1
            IF R.PGM.DATA.CONTROL<PDC.PRODUCT> THEN
                LOCATE R.PGM.DATA.CONTROL<PDC.PRODUCT> IN R.SPF.SYSTEM<SPF.PRODUCTS,1> SETTING INSTALLED ELSE INSTALLED = 0
            END
*
            IF INSTALLED THEN
*
                IF PROGS = '' THEN PROGS = ID
                ELSE PROGS := @FM:ID
            END
        END
    REPEAT
*
RETURN
*
*********
*
JBASE.COMPILE:                           ; *GB0002062
*---------------
*
* Call the jBASE compiler.
* First check if the program is in exception list. If it is not
* there then compile using jBASE compiler.
*

    LOCATE SOURCE.ITEM IN UNIVERSE.SPECIFIC.PROGS<1> SETTING POS.FOUND ELSE POS.FOUND = ''         ; * GB0002069
    IF POS.FOUND THEN
        PRINT
        PRINT 'PROGRAM ':SOURCE.ITEM:' WILL NOT BE COMPILED BY jBASE '
        PRINT
        RETURN
    END

    JBASE.ERROR = ''
    IF JBC.INSTALLED THEN
        CALL JBASE.COMPILE('',SOURCE.ITEM,SOURCE.FNAME,JBASE.ERROR)
        E = JBASE.ERROR
    END
RETURN
INITIALISE:
*---------

* GB0002069 S
*
** Hardcoded list of jBASE specific programs
*
    JBASE.SPECIFIC.PROGS = ''
    JBASE.SPECIFIC.PROGS<-1> = "LOGOUT"
    JBASE.SPECIFIC.PROGS<-1> = "SH"
    JBASE.SPECIFIC.PROGS<-1> = "DOS"   ; *    GLOBUS_BG_100000762   S/E
*
** Hardcoded list of UniVerse specific programs
*
    UNIVERSE.SPECIFIC.PROGS = ''
    UNIVERSE.SPECIFIC.PROGS<-1> = "JOURNAL.UPDATE"
    UNIVERSE.SPECIFIC.PROGS<-1> = "HUSHIT"
    UNIVERSE.SPECIFIC.PROGS<-1> = "SLEEP"
*
* GB0002069 E
*
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

RETURN
*
*************************************************************************
*
IS.JBASE.PROGRAM:
    IS.JBASE.PROGRAM = ''
*
* If the routine name ends in .JBASE then it is a jbase specific program
* This means that we don't need to change this everytime we write
* a routine that will not work in universe. Also check the list for any
* cowboys who don't follow this....
*
    LOCATE PROG.NAME IN JBASE.SPECIFIC.PROGS<1> SETTING IS.JBASE.PROGRAM ELSE
        IS.JBASE.PROGRAM = ''
        IF RIGHT(PROG.NAME,6) = '.JBASE' THEN
            IS.JBASE.PROGRAM = 1
        END
    END
RETURN
FATAL.ERROR:
*
    PRINT
    PRINT E
    PRINT
RETURN

END
