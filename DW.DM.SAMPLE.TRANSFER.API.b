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
* <Rating>-36</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DW.BiExport
    SUBROUTINE DW.DM.SAMPLE.TRANSFER.API

    $INSERT I_F.SPF
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DW.EXPORT.PARAM
    $INSERT I_DW.EXPORT.INFO.COMMON
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
* 19/04/2013  - RTC_610183
*              FTP ROUTINE for DW in Oracle BI DataMart
*---------------------------------------------------------------------------------
    GOSUB FORM.DIR
    GOSUB OPEN.FILES
    GOSUB TRANSFER.FILES

    RETURN

*______________________________________________________________________________________
*
*** <region name= FORM.DIR>
*
FORM.DIR:
************
*    DEBUG
    COMPANY.ID = ID.COMPANY
    MNEMONIC = LEAD.MNE
    CURRDATE = MIS.DATE
    CURRDIR = '1':RIGHT(CURRDATE,6)
    RETURN

*______________________________________________________________________________________
*
*** <region name= OPEN.FILES>
*
OPEN.FILES:
************
*    DEBUG
    CALL CACHE.READ('F.DW.EXPORT.PARAM', ID.COMPANY, R.DW.EXPORT.PARAM, YERR)
    IF YERR THEN
        TEXT = "DW.EXPORT record is missing for company ":ID.COMPANY
        RETURN
    END

    OPEN '',R.DW.EXPORT.PARAM<DW.EP.FILE.PATHNAME> TO F.DIRECTORY ELSE
        ETEXT = 'EB-UNABLE.TO.OPEN.DIRECTORY'
        CALL STORE.END.ERROR
        RETURN
    END

    HOMEDIR = R.DW.EXPORT.PARAM<DW.EP.FILE.PATHNAME>
    DESTDIR = HOMEDIR:'/':CURRDIR
*    EXECUTE "SH rm -r ":CURRDIR

    DEST.DIRECTORY = ''
    OPEN DESTDIR TO DEST.DIRECTORY ELSE
        IF CHDIR(HOMEDIR) THEN
            EXECUTE "SH pwd"
            EXECUTE "SH mkdir ":CURRDIR
        END
    END
*    IF CHDIR(HOMEDIR) THEN
*        EXECUTE "SH pwd"
*        EXECUTE "SH rm -r ":CURRDIR
*    END
    RETURN
*______________________________________________________________________________________
*
***<region name= TRANSFER.FILES>
*
TRANSFER.FILES:
***************
*   DEBUG
    IF GETCWD(HOMEDIR) THEN
        EXECUTE "SH pwd"
        EXECUTE "SH cp *.csv ":CURRDIR
        EXECUTE "SH cp *.txt ":CURRDIR
        WRITE MNEMONIC:',':CURRDIR TO F.DIRECTORY, "import_trigger.txt"
    END
    RETURN
END
