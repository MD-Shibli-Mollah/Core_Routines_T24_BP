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

* Version 10 07/06/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>2874</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.Foundation
    SUBROUTINE SYSTEM.CALL(COMMAND.TYPE, OP.SYSTEM, PARAMS, RESULT, RETURN.CODE)
*
*************************************************************************
*
* This subroutine is used for all the commands from GLOBUS to the
* operating system.
*
* INPUT
* COMMAND.TYPE              "EXECUTE" just run it
*                           SYSTEM.COMMAND key to generic command type
* OPS.SYSTEM                "UNIX" - unix only
*                           "NT"   - NT only
*                           ""     - both i.e. generic
* PARAMETER                 straight command or generic parameters
* RESULT                    string returned from operating system
* RETURN.CODE               Success or Failure
*
* 16/06/98 - GB9800716
*             Allow unix specific shell scripts to be run as opposed
*             to executed.
*
* 22/06/98 - GB9800780
*            UNIX mkdir command string not correctly constructed.
*
* 09/09/98 - GB9801122
*            Remove unnecessary quotes and change / to \ for NT path strings.
*
* 18/12/98 - GB9801499
*            Tidyup the NT commands to perform more like the UNIX
*            commands.
*
* 25/02/00 - GB0000285
*            Add find for NT + check for phantom PID is passed
*
* 17/11/00 - GB0002369
*            Remote Journaling was not updated Properly
*
* 24/09/01 - BG-100000088/GB0102161
*            Use new central routine to determine OS
*
* 07/12/01 - BG-100000296
*            Don't add the DOS /c part to the windows shell when
*            running in jBASE as this is not required and causes a failure.
*
* 03/04/2002 - GLOBUS_CI_10001474
*              NT GLOBUS was failing when the program
*              PC.CREATE.DATABASE is run,this is because
*              of a call to the routine SYSTEM.CALL which
*              will return a value ie the number of files
*              copied when the commands "COPY" or "XCOPY"
*              are executed. Changes made so that if the copy
*              commands are success then the value of RESULT
*              is made null.
*
* 23/07/02 - GLOBUS_BG_100001659
*            Changes made to XCOPY command syntax
*
* 31/07/02 - GLOBUS_CI_10002829
*            Changes made to make patch mechanism compatible with NT.
*            UVRESTORE and format.conv is taken care of here.
*
* 21/10/02 - GLOBUS_EN_10001430
*          Conversion Of all Error Messages to Error Codes
* 31/01/03 - GLOBUS_CI_10006569
*            Changes made under the CD GLOBUS_BG_100001659 was creating
*            problem in Universe Windows NT since NT does not
*            support /Y option in XCOPY commands.changes to
*
* 28/05/03 - EN_10001845
*            Replace READ of SPF with call to EB.READ.SPF
*
* 12/06/03 - GLOBUS_CI_10009892
*            Changes made under the CD GLOBUS_CI_10001474 was creating
*            problems if a directory is copied with no records inside.
*
* 07/07/03 - GLOBUS_CI_10010415
*            Changes made under GLOBUS_CI_10009892 was failing OPEN command
*            in Universe NT while trying to call XCOPY ie.COPY_R if the
*            file copied contain 0 record.Changes done to Fix this.
*            CSS Ref No. HD0301819
*
* 16/07/03 - GLOBUS_CI_10010848
*            While Spooling batch comos,("&UFD&>BC_BNK" or""&UFD&>BATCH.COMO")
*            Error - cp: cannot access &UFD& : No such file or directory.
*            So, remove "&UFD&" from the command parameter,
*            while coping a file from root directory(&UFD&).
*
* 22/07/03 - GLOBUS_CI_10011021
*            While running EOD, COPY command is failing in jBASE/Universe NT.
*            In jBASE NT, the source & destination directory should be
*            enclosed in a double(") quotes.(..\eb\&HOLD& -> "..\eb\&HOLD&").
*            In Universe NT, the source & destination with '&' file/directory,
*            should be enclosed in a double(") quotes.(Ex:&HOLD& -> "&HOLD&").
*
* 04/05/06 - GLOBUS_CI_10040943
*            can't create directory or get mkdir: 0653-357 Cannot access directory
*            Include -p in cmd.
*
* 12/02/15 - Defect:1250871 / Task: 1252690
*            !HUSHIT is not supported in TAFJ, hence changed to use HUSHIT().
*
* 02/03/16 - Defect 1636210 / Task 1650838
*            Replacing the XCOPY command with ROBOCOPY
*
*************************************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SPF
*
*Initialisation:
*
    GOSUB INITIALISE
*
    IF ETEXT <>'' THEN
        IF TEST.MODE THEN CRT 'ETEXT = ':ETEXT
        ETEXT = ''
        RETURN.CODE = 1
        RETURN
    END
*
    GOSUB RUN.COMMAND
*
    RETURN
*
*------------------------------------------------------------------------
*
INITIALISE:
*
    PARAMETER = PARAMS
    ETEXT = ''
    RETURN.CODE = ''
    TEST.MODE = 0
    NO.OF.S = ''    ;* CI_10040943
    AMP.FILE.DIR = '' ; FMT.PARAMETER = ''        ;* CI_10011021 S/E
    IF R.SPF.SYSTEM<SPF.OPERATING.SYSTEM> = "" THEN
        F.SPF = ""
        OPEN "F.SPF" TO F.SPF ELSE
            ETEXT ="EB.RTN.COULD.NOT.OPEN.SPF"
            RETURN
        END
        CALL EB.READ.SPF
    END
    OPERATING.SYSTEM = R.SPF.SYSTEM<SPF.OPERATING.SYSTEM>
*
    UNIVERSE.OP = ''          ;* GB0102161 S
    CALL EB.GET.OS(UNIVERSE.OP)         ;* GB0102161 E
*
    BEGIN CASE
    CASE OPERATING.SYSTEM NE UNIVERSE.OP
        ETEXT ='EB.RTN.SPF.OPERATING.SYSTEM.NOT.CORRECTLY.DEFINED'
    CASE OP.SYSTEM AND OP.SYSTEM NE OPERATING.SYSTEM
        ETEXT ='EB.RTN.COMMAND.NOT.DEFINED.OPERATING.SYSTEM'
    CASE PARAMETER = ""
        ETEXT ="EB.RTN.NULL.PARAMETER"
    CASE OP.SYSTEM NE "UNIX" AND OP.SYSTEM NE "NT" AND OP.SYSTEM NE ""
        ETEXT ="EB.RTN.INVALID.OPERATING.SYSTEM"
    CASE COMMAND.TYPE = ""
        ETEXT ="EB.RTN.INVALID.COMMAND.TYPE"
    CASE OP.SYSTEM = "" AND COMMAND.TYPE = ""
        ETEXT ="EB.RTN.INVALID.OP.SYSTEM.COMMAND.TYPE"
    CASE OP.SYSTEM = "" AND COMMAND.TYPE = "EXECUTE"
        ETEXT ="EB.RTN.INVALID.COMMAND.TYPE"
    END CASE
*
    RETURN
*
*-----------------------------------------------------------------------
*
RUN.COMMAND:
*
    IF OPERATING.SYSTEM = "UNIX" THEN
        SHELL.CMD = 'SH -c '
    END ELSE
* CI_10002829
* IF it is running under jbase the SHELL.CMD must be DOS /c, previously
* it was null.
        SHELL.CMD = 'DOS /c '
    END
    V$SQUOTE = "'"
    V$DQUOTE = '"'
*
*  run it
*
    BEGIN CASE
    CASE OP.SYSTEM = "UNIX"
*
* Just run the command
*
        BEGIN CASE
        CASE COMMAND.TYPE = "EXECUTE"
            IF PARAMETER [1,5] = "SH -c" THEN
* remove SH -c ' (OR ") and closing quote
                PARAMETER = PARAMETER[8,LEN(PARAMETER)-8]
            END
            EXECUTE 'SH -c "':PARAMETER:'"' CAPTURING RESULT
        CASE COMMAND.TYPE = "START"     ;* GB9800716
            COMMAND = "SH ":PARAMETER
            EXECUTE COMMAND
        END CASE

    CASE OP.SYSTEM = "NT"
*
* Just run it
*
    CASE OP.SYSTEM = ""
*
* Interpret a generic command
*
        BEGIN CASE
        CASE COMMAND.TYPE[1,4] = "COPY"
            IF FIELD(PARAMETER<1>,'/',1) EQ "&UFD&" THEN PARAMETER<1> = FIELD(PARAMETER<1>,'/',2)   ;* CI_10010848 S/E
            IF OPERATING.SYSTEM = "UNIX" THEN
                IF COMMAND.TYPE = "COPY" THEN
                    CMD = " cp "
                END ELSE
                    CMD = " cp -r "
                END
                COMMAND = SHELL.CMD:V$DQUOTE:CMD:V$SQUOTE:PARAMETER<1>:V$SQUOTE:" ":V$SQUOTE:PARAMETER<2>:V$SQUOTE:V$DQUOTE
            END ELSE
* GB9801499s
                CONVERT '/' TO '\' IN PARAMETER
* GB9801499e
                IF COMMAND.TYPE = 'COPY' THEN
                    CMD = " COPY "
* GB9801499s
* Move command to here from outside IF statement.
* CI_10011021 /S
                    IF RUNNING.IN.JBASE THEN
                        COMMAND = SHELL.CMD:V$SQUOTE:CMD:V$DQUOTE:PARAMETER<1>:V$DQUOTE:" ":V$DQUOTE:PARAMETER<2>:V$DQUOTE:V$SQUOTE
                    END ELSE
                        FOR I = 1 TO 2
                            IF PARAMETER<I>[1,1] = '&' THEN ;* If parameter starts with '&'file/directory, prefix path.
                                OPEN '',FIELD(PARAMETER<I>,'\',1) TO DIR.PATH THEN
                                    DIR.PATH = FILEINFO(DIR.PATH,2)
                                    CONVERT '/' TO '\' IN DIR.PATH
                                    FMT.PARAMETER<I> = DIR.PATH:'\':FIELD(PARAMETER<I>,'\',2,99)
                                END
                            END ELSE
                                FMT.PARAMETER<I> = PARAMETER<I>
                            END
                            GOSUB CONV.AMP.WITH.QUOTES
                        NEXT I
                        COMMAND = SHELL.CMD:V$SQUOTE:CMD:FMT.PARAMETER<1>:" ":FMT.PARAMETER<2>:V$SQUOTE
                    END
* CI_10011021 /E
* GB9801499e
                END ELSE      ;* Directory copy
                    CMD = " ROBOCOPY "        ;* Replacing XCOPY with ROBOCOPY
* GB9801499s
* Move command to here from outside IF statement.
* GLOBUS_BG_100001659  S/E , Add /Y to supress prompting when XCOPY command is executed.
* GLOBUS_CI_10006569 ,Changes made under CD BG_100001659 was creating problems for Universe on NT.
                    IF RUNNING.IN.JBASE THEN      ;*  GLOBUS_CI_10006569 S
                        COMMAND = SHELL.CMD:V$SQUOTE:CMD:PARAMETER<1>:" ":PARAMETER<2>:' /S /E /V':V$SQUOTE			;* /Y and /I options are not supported in ROBOCOPY
                    END ELSE
                        COMMAND = SHELL.CMD:V$SQUOTE:CMD:PARAMETER<1>:" ":PARAMETER<2>:' /S /E /V':V$SQUOTE         ;* /Y and /I options are not supported in ROBOCOPY
                    END       ;*  GLOBUS_CI_10006569  E
* GB9801499e
                END
            END
            GOSUB EXEC.SHELL
            IF OPERATING.SYSTEM = "NT" THEN       ;*  GLOBUS_CI_10001474   S
                CNT1 = '' ; Y = '' ; RES = '' ; RET.VAL = ''
* Changes Under CI_10009892 is removed here.
                IF CMD = " ROBOCOPY " THEN       ;* XCOPY replaced by ROBOCOPY
                    CNT1 = DCOUNT(RESULT,@FM) - 1 ;*  For dir copy RESULT will have the files copied and the string "File(s) copied separated by FM
                END ELSE
                    CNT1 = 1
                END
                RES = RESULT
                Y = 'ile(s) copied'     ;* Single file copy returns "file(s) copied" and dir copy returns "File(s) copied".
                RET.VAL = INDEX(TRIM(RES<CNT1>),Y,1)
                IF RET.VAL THEN         ;* GLOBUS_CI_10010415 - S/E
                    RES = FIELD(TRIM(RES<CNT1>)," ",1)
                    IF RES GE 1 OR (RES EQ 0 AND CMD = " ROBOCOPY ") THEN          ;* GLOBUS_CI_10010415 - S/E
                        RESULT = ''
                    END
                END
            END     ;* GLOBUS_CI_10001474   E
        CASE COMMAND.TYPE = "MOVE"
            IF OPERATING.SYSTEM = "UNIX" THEN
                CMD = " mv "
                COMMAND = SHELL.CMD:V$DQUOTE:CMD:V$SQUOTE:PARAMETER<1>:V$SQUOTE:" ":V$SQUOTE:PARAMETER<2>:V$SQUOTE:V$DQUOTE
            END ELSE
                CMD = " MOVE "
                CONVERT '/' TO '\' IN PARAMETER
                COMMAND = SHELL.CMD:V$DQUOTE:CMD:PARAMETER<1>:" ":PARAMETER<2>:V$DQUOTE
            END
            GOSUB EXEC.SHELL
        CASE COMMAND.TYPE[1,6] = "REMOVE"
            IF OPERATING.SYSTEM = "UNIX" THEN
                IF COMMAND.TYPE = "REMOVE" THEN
                    CMD = " rm "
* GB9801499s
                    PARAMETER = V$SQUOTE:PARAMETER:V$SQUOTE
* GB9801499e
                END ELSE
                    CMD = " rm -r "
                END
            END ELSE
                IF COMMAND.TYPE = "REMOVE" THEN
                    CMD = " DEL "
                END ELSE
* GB9801499s
* Add switches to removed Directory even if data exists.
                    CMD = " RMDIR /S /Q "
* GB9801499e
                END
                CONVERT '/' TO '\' IN PARAMETER
            END
            COMMAND = SHELL.CMD:V$DQUOTE:CMD:PARAMETER:V$DQUOTE
            GOSUB EXEC.SHELL
        CASE COMMAND.TYPE = "MKDIR"
            IF OPERATING.SYSTEM = "UNIX" THEN
                NO.OF.S = COUNT(PARAMETER, '/')   ;* CI_10040943
                IF NO.OF.S THEN
                    CMD = " mkdir -p "
                END ELSE
                    CMD = " mkdir "
                END ;* CI_10040943
                COMMAND = SHELL.CMD:V$DQUOTE:CMD:V$SQUOTE:PARAMETER:V$SQUOTE:V$DQUOTE     ;* GB9800780
            END ELSE
                CMD = " MKDIR "
                CONVERT '/' TO '\' IN PARAMETER
                COMMAND = SHELL.CMD:V$DQUOTE:CMD:PARAMETER:V$DQUOTE   ;* GB9800780
            END
            GOSUB EXEC.SHELL
        CASE COMMAND.TYPE = "LIST"
            IF OPERATING.SYSTEM = "UNIX" THEN
                CMD = " ls "
                COMMAND = SHELL.CMD:V$DQUOTE:CMD:V$SQUOTE:PARAMETER:V$SQUOTE:V$DQUOTE
            END ELSE
* GB9801499s
                CMD = " DIR /B "
* GB9801499e
                CONVERT '/' TO '\' IN PARAMETER
                COMMAND = SHELL.CMD:V$DQUOTE:CMD:PARAMETER:V$DQUOTE
            END
            GOSUB EXEC.SHELL
        CASE COMMAND.TYPE = "FIND"
            IF OPERATING.SYSTEM = "UNIX" THEN
                CMD1 = " ps -ef | grep  "
                CMD2 = " | grep -v grep"
                COMMAND = SHELL.CMD:V$DQUOTE:CMD1:V$SQUOTE:PARAMETER:V$SQUOTE:CMD2:V$DQUOTE
                GOSUB EXEC.SHELL
            END ELSE
* Don't know NT equivalent
* GB0000285 we do now
*
                COMMAND = "STATUS ME NO.PAGE"
                GOSUB EXEC.SHELL
                IF PARAMETER THEN
                    FINDSTR "phantom:":PARAMETER IN RESULT SETTING POS THEN
                        RESULT = RESULT<POS>
                    END ELSE
                        RESULT = ""
                    END
                END
            END
        CASE COMMAND.TYPE = "RCP"
            IF OPERATING.SYSTEM = "UNIX" THEN
                CMD = " rcp "
                COMMAND = SHELL.CMD:V$DQUOTE:CMD:PARAMETER<1>:" ":PARAMETER<2>:PARAMETER<3>:V$DQUOTE
            END ELSE
*
* treat rcp as normal copy ie to a network drive
*
                CMD = " COPY "
                CONVERT '/' TO '\' IN PARAMETER
                COMMAND = SHELL.CMD:V$DQUOTE:CMD:PARAMETER<1>:" ":PARAMETER<2>:V$DQUOTE
            END
            GOSUB EXEC.SHELL
        CASE COMMAND.TYPE = "START"
            IF OPERATING.SYSTEM = "UNIX" THEN
                COMMAND = "SH ":PARAMETER
                EXECUTE COMMAND
            END ELSE
                COMMAND = SHELL.CMD:PARAMETER
                GOSUB CALL.SHELL
            END
* CI_10002829S
* UVRESTORE the patch file to create a patch unit.
        CASE COMMAND.TYPE = "UVRESTORE"
            IF OPERATING.SYSTEM = "UNIX" THEN
                COMMAND = SHELL.CMD:'"uvrestore -U ':PARAMETER:'UB"'
            END ELSE
                PATH = SYSTEM(32)
                COMMAND = SHELL.CMD: PATH:'\bin\uvrestore -U -V ':PARAMETER:'UB'
            END
            EXECUTE COMMAND CAPTURING RESULT
            CALL HUSHIT(1)
*
* Format.conv patch release to current machine class
*
            RESULT = ''
            ID = RIGHT(PARAMETER,7)
            COMMAND = 'FORMAT.CONV -s ':ID
            EXECUTE COMMAND CAPTURING RESULT
            CALL HUSHIT(0)
* CI_10002829E
        END CASE
    END CASE
*
    RETURN
*
CONV.AMP.WITH.QUOTES:
*--------------------
* GLOBUS_CI_10011021
* Conversion of ..\eb\&HOLD& to ..\eb\"&HOLD&"
    AMP.FILE.DIR = FIELD(FMT.PARAMETER<I>,'&',2)
    AMP.FILE.DIR = '&':AMP.FILE.DIR:'&'
    FMT.PARAMETER<I> = CHANGE(FMT.PARAMETER<I>,AMP.FILE.DIR,QUOTE(AMP.FILE.DIR))
*
    RETURN
*
EXEC.SHELL:
    IF TEST.MODE THEN CRT "COMMAND = ":COMMAND
    EXECUTE COMMAND CAPTURING RESULT
    RETURN.CODE = @SYSTEM.RETURN.CODE   ;* GB0002369 S/E
    IF TEST.MODE THEN CRT 'RESULT = ':RESULT
    RETURN
*
CALL.SHELL:
    IF TEST.MODE THEN CRT "COMMAND = ":COMMAND
    EXECUTE COMMAND

*
* Final END statement
*
END
