* @ValidationCode : MjotMjk2ODQwNzM1OkNwMTI1MjoxNTcyMzQxODM4ODE1OmFtaXRoYTotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxOTEwLjI6LTE6LTE=
* @ValidationInfo : Timestamp         : 29 Oct 2019 15:07:18
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : amitha
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.2
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-68</Rating>
*-----------------------------------------------------------------------------
$PACKAGE DW.BiExport
SUBROUTINE DW.TRANSFER.ROUTINE

    $INSERT I_F.SPF
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DW.EXPORT.PARAM
*______________________________________________________________________________________
*-----------------------------------------------------------------------------
* Modifications:
* --------------
*
* 13/07/2009 - GLOBUS_BG_100024454
*              Uncommenting the variable DESTINATION
*
* 24/11/2010 - RTC_75913
*              Packaging DW EXPORT.
*
* 06/04/2011 - RTC 186478
*              Changes made to transfer in binary mode
*
* 22/02/2019 - Enhancement 2822523/ Task 3003382
*			 - Incorporation of DW_BiExport component.
*
* 24/10/2019 - Defect 3390377
*              In case of TAFJ, if TRANSFER.RTN is used then DW service is crashing with error
*              Program '?kftp' is missing or not compiled/deployed. Class missing : com.temenos.t24.?kftp_4_cl
*---------------------------------------------------------------------------------
    GOSUB OPEN.FILES
    GOSUB FORM.TEXT.FILE
    GOSUB FTP.PROCESS
    
RETURN
*______________________________________________________________________________________
*
*** <region name= OPEN.FILES>
*
OPEN.FILES:
************
     
    CALL CACHE.READ('F.DW.EXPORT.PARAM', ID.COMPANY, R.DW.EXPORT.PARAM, YERR)
    IF YERR THEN
        TEXT = "DW.EXPORT record is missing for company ":ID.COMPANY
        RETURN
    END

    FTP.CMD  = ''
    OPEN '',R.DW.EXPORT.PARAM<DW.EP.FILE.PATHNAME> TO F.CURRENT.DIRECTORY ELSE
        ETEXT = 'EB-UNABLE.TO.OPEN.DIRECTORY'
        CALL STORE.END.ERROR
        RETURN
    END
    RUN.DIR = ''

    OPEN '.' TO RUN.DIR ELSE
* Open file in run directory to get the login details and the destination details
        ETEXT = 'EB-UNABLE.TO.OPEN.DIRECTORY'
        CALL STORE.END.ERROR
        RETURN
    END
RETURN

*______________________________________________________________________________________
*
*** <region name= FORM.TEXT.FILE>
*
FORM.TEXT.FILE:
***************
    FILE.NAME = R.DW.EXPORT.PARAM<DW.EP.FILE.PATHNAME>
    READ REC.FTP.DETS FROM RUN.DIR, 'FTP.DETAILS' ELSE
        ETEXT = 'FTP.DETAILS record not found'
        CALL STORE.END.ERROR
        RETURN      ;* record not found
    END
    USER.NAME = REC.FTP.DETS<1>
    USER.PASSWORD = REC.FTP.DETS<2>
    DESTINATION = REC.FTP.DETS<3>

    IF R.SPF.SYSTEM<SPF.OPERATING.SYSTEM> EQ "UNIX" THEN
        FTP.CMD<-1> = "user ":USER.NAME:" ":USER.PASSWORD   ;* framing the ftp commands
    END ELSE
        FTP.CMD<-1> = USER.NAME
        FTP.CMD<-1> = USER.PASSWORD
    END
    FTP.CMD<-1> = "bin"
    FTP.CMD<-1> = "prompt"
    FTP.CMD<-1> = 'cd ':DESTINATION
    FTP.CMD<-1> = 'lcd ':R.DW.EXPORT.PARAM<DW.EP.FILE.PATHNAME>
    SEL.CMD = 'SELECT ':FILE.NAME:' LIKE ':'...':'.csv ': 'OR ....txt'          ;* select the filenames with the extension .csv and .txt
    EXECUTE SEL.CMD SETTING SETTING.MSG CAPTURING OUTPUT
    READLIST ID.LIST ELSE
        ID.LIST = ''
    END
    LOOP
        REMOVE FN.NAMES FROM ID.LIST SETTING FN.POS
    WHILE FN.NAMES:FN.POS DO
        IF FN.NAMES MATCHES "DW.EXPORT.FTP.txt":@VM:"IMPORT_trigger.txt" THEN    ;* do not transfer the text file that stores the ftp commands
            CONTINUE
        END
        FTP.CMD<-1> = "mput ":FN.NAMES  ;* ftp command to put the record in the destination path
    REPEAT

    FTP.CMD<-1> = "mput IMPORT_trigger.txt"
    FTP.CMD<-1> = "bye"       ;* end of the ftp transfer

    WRITE FTP.CMD TO RUN.DIR,"DW.EXPORT.FTP.txt"  ;* ftp commands written to a text file and saved under the current dir.
    WRITE '' TO F.CURRENT.DIRECTORY, "IMPORT_trigger.txt"

RETURN
*______________________________________________________________________________________
*
*** <region name= FTP.PROCESS>
FTP.PROCESS:
*----------
    IP.ADDRESS = REC.FTP.DETS<4>        ;* get the destination ip address for doing ftp

    IF R.SPF.SYSTEM<SPF.OPERATING.SYSTEM> EQ "UNIX" THEN
        EXECUTE "SH -c chmod 777 DW.EXPORT.FTP.txt"
        EXE.FTP.CMD = 'ftp -n -v ':IP.ADDRESS:' < DW.EXPORT.FTP.txt'  ;* process the ftp command for unix os
        EXECUTE 'SH -c ':EXE.FTP.CMD CAPTURING OUTPUT          ;* execute the ftp command
    END ELSE
        EXE.FTP.CMD = 'ftp -v -s:DW.EXPORT.FTP.txt ':IP.ADDRESS       ;* process the ftp command for other os (say windows)
        EXECUTE EXE.FTP.CMD CAPTURING OUTPUT      ;* execute the ftp command
    END
    PRINT OUTPUT    ;* display the output of the process and writes it into &COMO&

RETURN
END
