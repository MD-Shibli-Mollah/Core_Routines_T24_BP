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

* Version 3 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>954</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.ModelBank
    
    SUBROUTINE E.BUILD.GUI.EXCEPTION(TEST)
REM "EXCEPTION",840731,"MAINPGM" * list unauth. records
*
* 05/05/93 - GB9300766
*            Check that the program exists in the VOC otherwise don't
*            attempt to analyse the unauthorised file.
*
* 12/02/02 - BG_10000485
*            Get the position of RECORD.STATUS from Standard selection
*            rather calling the application. And read Standard selection
*            file to find if the application exists.
*
* 04/04/02 - GLOBUS_EN_100000794
*            1.  Convert E.BUILD.GUI.EXCEPTION so that EXCEPTION application
*                can run multi-user.
*                Change the structure of the RECORD ID in E.GUI.EXCEPTION
*                so that the Terminal number name is prefixed to the ID.
*            2.  No-longer need to OPEN "VOC" file
*            3.  Change  SSELECT VOC statement to use CALL EB.READLIST
*            4.  Change all direct READ, READV & MATREAD record statements to use
*                CALL F.READ, F.READV & F.MATREAD respectively.
*            5.  Change all direct OPEN "filename" statements to CALL OPF
*            6.  Call F.MATWRITE when writing the R.GUI record.
*            7.  Moved location of GET.STANDARD.SELECTION.DETS
*            8.  Remove redundant records from E.GUI.EXCEPTION file.
*
* 05/07/02 - GLOBUS_EF_60
*            Call to OPF causing FATAL.ERRORS if file does not exist.
*            Changed OPF to not call FATAL.ERORRS if file does not
*            exist.
*
*
* 15/03/07 - EN_10003192
*            DAS Implementation
*
* 09/03/09 - GLOBUS_CI_10062036
*            Call to DISPLAY.MESSAGE causes Run-time error in Desktop.
*            HD Ref# HD0911150
**
* 10/05/16 - Enhancement 1499014
*          - Task 1626129
*          - Routine incorporated
*
* 18/05/16 - DEFECT 1729581 / Task 1735017
*          - Code fix for TAFC compilation issue
* 
* 18/05/16 - DEFECT 1735238 / Task 1735256
*          - Code fix for Cache exceeded error during ENQ EXCEPTION
*-------------------------------------------------------------------------
*
    $USING EB.SystemTables
    $USING EB.Desktop
    $USING EB.API
    $USING EB.OverrideProcessing 
    $USING EB.ErrorProcessing
    $USING EB.Display
    $USING EB.TransactionControl
    $USING EB.DataAccess
    $USING EB.ModelBank
        
*
    
*************************************************************************
*
    EB.DataAccess.Opf("F.STANDARD.SELECTION",F.STANDARD.SELECTION)
    IF EB.SystemTables.getEtext()<> "" THEN
        EB.SystemTables.setText("Unable to open STANDARD.SELECTION file")
        EB.ErrorProcessing.FatalError("EXCEPTION")
        RETURN
    END

*
     FN.GUI.EXCEPTION = 'F.GUI.EXCEPTION'
    F.GUI.EXCEPTION = ''
    EB.DataAccess.Opf(FN.GUI.EXCEPTION, F.GUI.EXCEPTION)
    
    LL = 3
    LNGG.VAL = EB.SystemTables.getLngg()
    YTEXT = "NAME OF FILE" ; IF LNGG.VAL<> 1 THEN EB.Display.Txt ( YTEXT )
    YTEXT2 = "TOTAL" ; IF LNGG.VAL<> 1 THEN EB.Display.Txt ( YTEXT2 )
    YTEXT3 = "NAU    NA2    NAO    HLD    ERR"
    IF LNGG.VAL<> 1 THEN EB.Display.Txt ( YTEXT3 )
    YTEXT4 = "UNDEF." ; IF LNGG.VAL<> 1 THEN EB.Display.Txt ( YTEXT4 )
    YTEXT = "" ; YTEXT2 = "" ; YTEXT3 = "" ; YTEXT4 = ""
    YT.FILES = ""

* Remove previous results...

    THE.LIST = EB.Desktop.dasGuiExceptionId
    THE.ARGS = EB.SystemTables.getTno():"*..."
    TABLE.SUFFIX = ""
    EB.DataAccess.Das("GUI.EXCEPTION",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    ID.LIST = THE.LIST

    LOOP
        REMOVE K.GUI.EXCEPTION FROM ID.LIST SETTING POS
    WHILE K.GUI.EXCEPTION:POS ;*EN_10003192 E
        DELETE F.GUI.EXCEPTION, K.GUI.EXCEPTION
    REPEAT

    THE.LIST = EB.SystemTables.dasVocId
    THE.ARGS = "...$NAU"
    TABLE.SUFFIX = ""
    KEY.LIST = ''
    EB.DataAccess.Das("VOC",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    KEY.LIST = THE.LIST
    LOOP
        REMOVE YFNAME FROM KEY.LIST SETTING MARK
    WHILE YFNAME : MARK

        V$PROG = YFNAME[".",2,99]       ;* Fxxx.prog$NAU to prog$NAU
        V$PROG = V$PROG["$",1,1]        ;* prog$NAU to prog

        ER = ""
        R.SS = EB.SystemTables.StandardSelection.Read(V$PROG, ER) ;* Before incorporation CALL READV("STANDARD.SELECTION",V$PROG,R.SS,0,F.STANDARD.SELECTION,ER)
        IF NOT(ER) THEN
            YT.FILES<-1> = YFNAME       ;* Add to list of files
        END
    REPEAT
*
*------------------------------------------------------------------------
*
    LOOP UNTIL YT.FILES = "" DO
        YFNAME = YT.FILES<1> ; YT.FILES = DELETE(YT.FILES,1,0,0)
        tmp.F.FILE$NAU = EB.SystemTables.getFFileNau()
        EB.DataAccess.Opf(YFNAME:@FM:"NO.FATAL.ERROR",tmp.F.FILE$NAU)
        EB.SystemTables.setFFileNau(tmp.F.FILE$NAU)
        IF EB.SystemTables.getEtext()<> "" THEN
            GOTO SKIP.FILE
        END

        YPGM.NAME = FIELD(YFNAME,".",2,99)
        YPGM.NAME = FIELD(YPGM.NAME,"$",1)
* Calling pgm. to get Field no. of Status
        EB.API.GetStandardSelectionDets(YPGM.NAME,R.STANDARD.SELECTION)
        LOCATE 'RECORD.STATUS' IN R.STANDARD.SELECTION<EB.SystemTables.StandardSelection.SslSysFieldName,1> SETTING POS THEN
            YSTFD = R.STANDARD.SELECTION<EB.SystemTables.StandardSelection.SslSysFieldNo,POS>
        END
* Call to DISPLAY.MESSAGE is removed as it causes Run-time error in Desktop

        DIM Y.COUNTER(7) ; MAT Y.COUNTER = 0
        tmp.F.FILE$NAU = EB.SystemTables.getFFileNau()
        SELECT tmp.F.FILE$NAU
        LOOP
            READNEXT YID ELSE YID = ""
        UNTIL YID = "" DO

            tmp.F.FILE$NAU = EB.SystemTables.getFFileNau()
            EB.DataAccess.FRead(YFNAME,YID,temp.RNew,tmp.F.FILE$NAU,ER)  ;* Before Incorporation : CALL F.MATREAD((YFNAME,YID,MAT R.NEW,C$SYSDIM,F.FILE$NAU,ER))
            EB.SystemTables.setDynArrayToRNew(temp.RNew)
            IF ER THEN
                EB.SystemTables.setE("EB.RTN.MISS.FILE..ID.":@FM:YFNAME:@VM:YID) 
*                  GOSUB FATAL.ERROR ; GOTO PGM.END
                YID = ""
            END
            IF YID <> "" THEN
                YSTATUS = EB.SystemTables.getRNew(YSTFD)[2,3]
                BEGIN CASE
                CASE YSTATUS = "NAU" ; Y.COUNTER(2) = Y.COUNTER(2)+1
                CASE YSTATUS = "NA2" ; Y.COUNTER(3) = Y.COUNTER(3)+1 
                CASE YSTATUS = "NAO" ; Y.COUNTER(4) = Y.COUNTER(4)+1
                CASE YSTATUS = "HLD" ; Y.COUNTER(5) = Y.COUNTER(5)+1
                CASE YSTATUS = "ERR" ; Y.COUNTER(6) = Y.COUNTER(6)+1
                CASE 1 ; Y.COUNTER(7) = Y.COUNTER(7)+1
* undefined status - should not occure
                END CASE
                Y.COUNTER(1) = Y.COUNTER(1)+1
            END
        REPEAT
* 
*------------------------------------------------------------------------
*
        REC.ID = FIELD(YFNAME,"$",1)
        IF Y.COUNTER(1) > 0 THEN
            K.GUI.EXCEPTION = EB.SystemTables.getTno() : "*" : REC.ID
            MATBUILD TEMP.Y.COUNTER FROM Y.COUNTER
            EB.Desktop.GuiExceptionWrite(K.GUI.EXCEPTION, TEMP.Y.COUNTER, '') ;* Before Incorporation : CALL F.MATREAD(FN.GUI.EXCEPTION,K.GUI.EXCEPTION,MAT Y.COUNTER,7)
        END 
SKIP.FILE:
    REPEAT
    TXN.ID = "EXCEPTION*" : EB.SystemTables.getTno()
    EB.TransactionControl.JournalUpdate(TXN.ID)
*
*------------------------------------------------------------------------
*
*
PGM.END:
*
    CLEARSELECT ; RETURN      ;* end of pgm
*
*************************************************************************
*
FATAL.ERROR:
*
    EB.SystemTables.setText(EB.SystemTables.getE()); EB.OverrideProcessing.Ove() ; RETURN
*
*************************************************************************
END
