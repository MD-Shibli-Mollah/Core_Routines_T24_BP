* @ValidationCode : MjoyMTM2ODI5NDkyOmNwMTI1MjoxNTg5MzQ3MDUxNDAxOmluZGh1bWF0aGlzOjU6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDQuMjAyMDA0MDItMDU0OToxNjY6MTIx
* @ValidationInfo : Timestamp         : 13 May 2020 10:47:31
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : indhumathis
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 121/166 (72.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202004.20200402-0549
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-50</Rating>
*-----------------------------------------------------------------------------
$PACKAGE DE.Reports
SUBROUTINE DE.MSG.SUMMARIES(STMT.DET)

* No file routine for the enquiry DE.MSG.SUM .
* To overcome IDESC and TRANS functionality in TAFJ we introduced this routine
*----------------------------------------------------------------------------
* MODIFICATION HISTORY
* 21/07/2017 - Defect 2176941 / Task 2205313
*              Modifications done to accept FT reference in the enquiry and
*              display the delivery references in the enquiry output.
*
* 22/01/2018 - Defect 2160161 / Task 2419881
*              Modifications done to display header and message status separately
*
* 08/10/2018 - Defect 2712288/Task 2800605
*              Modification to generate appropriate Drill Value, depending on different combinations of Header Disposition, and Header Message Disposition,
*              and ensure record is fetched from DE.O.HEADER, if no other Delivery Message file is relevant.
*
* 28/04/2020 - Defect 3705519 / Task 3717502
*              Modification to generate appropriate Drill Value, to view the delivery message of SWIFT NAK
*              response without any error.
*----------------------------------------------------------------------------

    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.Reports
    $USING DE.Config
    $USING DE.ModelBank
    $USING FT.Contract

    GOSUB INITIALISE

RETURN

INITIALISE:
***********
   
    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
    CARRIER.FORMAT = ''
    R.DE.CARRIER = ''
    MSG.DISP = ''
    CARRIER = ''
    TITLE = ''
    DRILL.VAL = ''

    LOCATE "DELIVERY.REF" IN EB.Reports.getDFields()<1> SETTING DEL.POS THEN
        REF = EB.Reports.getDRangeAndValue()<DEL.POS>
    END

* Check if FT reference is given in the enquiry and if so get the delivery references
* corresponding to the FT reference
    IF REF[1,2] = "FT" THEN
        FT.REF = REF
        GOSUB READ.FT
    END ELSE
        DELIVERY.REF = FIELD(REF,"-",1)
    END

* Loop for all the delivery references in FT
    DEL.REF.CNT = DCOUNT(DELIVERY.REF, @FM)
    FOR REF.CNT = 1 TO DEL.REF.CNT
        DE.ID = DELIVERY.REF<REF.CNT>
        GOSUB MAIN.PROCESS
    NEXT REF.CNT

RETURN
*-------------------------------------------------------------------------------
READ.FT:
********
* Read FT record to get the delivery references

    IF FT.REF NE '' THEN

        R.FT.REC = FT.Contract.FundsTransfer.Read(FT.REF,READ.ERR)

        IF READ.ERR THEN
            R.FT.REC = FT.Contract.FundsTransfer.ReadHis(FT.REF,HIS.READ.ERR)
        END
        IF R.FT.REC NE "" THEN
            GOSUB GET.DEL.REF.FROM.FT
        END
    END

RETURN
*-------------------------------------------------------------------------------
GET.DEL.REF.FROM.FT:
********************
* Assign delivery references to an array for processing

    OUT.REF.IDS = R.FT.REC<FT.Contract.FundsTransfer.DeliveryOutref>
    NO.OF.DELS = DCOUNT(OUT.REF.IDS,@VM)
    LOOP
        REMOVE DEL.ID FROM OUT.REF.IDS SETTING DEL.ID.POS
    WHILE DEL.ID:DEL.ID.POS
        DELIVERY.REF<-1> = FIELD(DEL.ID,'-',1)
    REPEAT

RETURN
*-------------------------------------------------------------------------------
MAIN.PROCESS:
*************
   
    R.DE.O.HANDOFF = ''
    YERR = ''
    R.DE.O.HANDOFF = DE.ModelBank.OHandoff.Read(DE.ID, YERR)
    LINE1 = FIELD(R.DE.O.HANDOFF,@FM,1)
    TYPE = FIELD(LINE1,'.',1)
    H.DATE = FIELD(LINE1,'.',3)
    Y.DATES = FIELD(H.DATE,'*',2,1)
    Y.DATES = Y.DATES[1,8]
   
    GOSUB GET.HEADER.VALUES
    CNT = DCOUNT(CARR.ADDR,@VM)
*
    DISP = ROHeader<DE.Config.OHeader.HdrDisposition,I>
    FOR I = 1 TO CNT
        CARRIER = CARR.ADDR<1,I>
        MSG.DISP = ROHeader<DE.Config.OHeader.HdrMsgDisp,I>
        TITLE = ROHeader<DE.Config.OHeader.HdrNameTitle,I>
        MSG.ERR = ROHeader<DE.Config.OHeader.HdrMsgErrorCode,I>        ;* Obtain the value of MSG.ERROR.CODE
        COPY.NO = FIELD(ROHeader<DE.Config.OHeader.HdrCopyNo,I>,'-',1)
        FRAME.NO = ROHeader<DE.Config.OHeader.HdrFrameNo,I>
        FORM.TYPE = ROHeader<DE.Config.OHeader.FormType,I>
        Y.DATE = ROHeader<DE.Config.OHeader.HdrBankDate>

        GOSUB GET.DRILL.VALUE

* Checks for FT reference and assign the values to STMT.DET array accordingly
        GOSUB ASSIGN.TO.STMT.DET

    NEXT I

    IF STMT.DET = '' THEN
        GOSUB GET.DRILL.VALUE
        STMT.DET<-1> = DE.ID:"*":Y.DATES:"*":TYPE:"*":DISP:"*":MSG.DISP:"*":CARRIER:"*":TITLE:"*":DRILL.VAL
    END

RETURN
*--------------------------------------------------------------------------------
ASSIGN.TO.STMT.DET:
*******************
    
    BEGIN CASE

        CASE REF[1,2] = "FT"
            STMT.DET<-1> = DE.ID:"*":Y.DATE:"*":TYPE:"*":DISP:"*":MSG.DISP:"*":CARRIER:"*":TITLE:"*":DRILL.VAL

        CASE 1
            IF DE.ID.S = '' THEN
                DE.ID.S = DE.ID
                STMT.DET<-1> = DE.ID:"*":Y.DATE:"*":TYPE:"*":DISP:"*":MSG.DISP:"*":CARRIER:"*":TITLE:"*":DRILL.VAL
            END ELSE
                STMT.DET<-1> = '':"*":'':"*":'':"*":DISP:"*":MSG.DISP:"*":CARRIER:"*":TITLE:"*":DRILL.VAL
            END

    END CASE

RETURN
*--------------------------------------------------------------------------------
GET.HEADER.VALUES:
******************
* Getting the DE.O.HEADER record

    YErr = ''
    ROHeader = DE.Config.OHeader.Read(DE.ID, YErr)
    IF ROHeader THEN
        CARR.ADDR = ROHeader<DE.Config.OHeader.HdrCarrierAddressNo>
    END

RETURN
*------------------------------------------------------------------------------------
GET.DRILL.VALUE:
****************
* Defining of form.type and carrier.format are done here
    
    CARR.ID = CARRIER['.',1,1]
    CAR.ER = ''
    R.DE.CARRIER = ''
    R.DE.CARRIER = DE.Config.Carrier.CacheRead(CARR.ID, CAR.ER)
    IF R.DE.CARRIER THEN
        CARRIER.FORMAT = R.DE.CARRIER<DE.Config.Carrier.CarrFormatModule>
    END ELSE
        CARRIER.FORMAT = CARRIER['.',1,1]
    END


    BEGIN CASE

        CASE DISP = 'UNFORMATTED'                     ;* Still an UNFORMATTED msg.
            DRILL.VAL = 'DE.O.HEADER S ':DE.ID           ;* Display DE.O.HEADER

        CASE DISP  = 'REPAIR'                         ;* DISPOSITION is REPAIR. Possible Mapping error
            DRILL.VAL = 'DE.O.HEADER S ':DE.ID        ;* Display DE.O.HEADER
            
        CASE MSG.DISP = 'REPAIR' AND MSG.ERR[1,3] NE 'NAK'  ;* Repair during Formatting.But do not display DE.O.HEADER if its NAK.
            DRILL.VAL = 'DE.O.HEADER S ':DE.ID               ;* Display DE.O.HEADER

        CASE MSG.DISP[1,8] = 'RESUBMIT'
            DRILL.VAL = 'DE.O.HEADER S ':DE.ID

        CASE MSG.DISP[1,7] MATCHES 'REROUTE':@VM:'DELETED'
            DRILL.VAL = 'DE.O.HEADER S ':DE.ID

        CASE MSG.DISP[1,3] MATCHES 'ACK':@VM:'NAK'
            DRILL.VAL = 'VIEW F.DE.O.HISTORY>':DE.ID:'.':I
* checking of carrier = print is changed to carrier.format = print
            IF CARRIER.FORMAT = 'PRINT' THEN
                GOSUB GET.VIEW.ID
            END

        CASE MSG.DISP[1,4] = 'WACK'
            DRILL.VAL = 'VIEW F.DE.O.HISTORY>':DE.ID:'.':I
            IF CARRIER['.',1,1] = 'PRINT' THEN
                GOSUB GET.VIEW.ID
                DRILL.VAL = 'VIEW F.DE.PREVIEW.MSG>':VIEW.ID
            END

        CASE CARRIER['.',1,1] = 'PRINT'
            GOSUB GET.VIEW.ID

        CASE MSG.DISP = ''       ;* MSG.DISP is null
            DRILL.VAL = 'DE.O.HEADER S ':DE.ID              ;* Display DE.O.HEADER
        
        CASE 1      ;* Other carriers

            IF CARRIER.FORMAT = 'PRINT' THEN
                GOSUB GET.VIEW.ID
            END ELSE
                DRILL.VAL = 'VIEW F.DE.O.MSG.':CARRIER['.',1,1]:'>':DE.ID:'.':I
            END
        
    END CASE

RETURN
*--------------------------------------------------------------------------------
GET.VIEW.ID:
************

    OUTPUT = ''
    EQU FORMFEED TO CHARX(012)
    IF ( MSG.DISP[1,3] MATCHES 'ACK':@VM:'NAK' ) OR ( MSG.DISP[1,4] = 'WACK') THEN
        FN.VIEW.FILE = 'F.DE.O.HISTORY'
    END ELSE
        FN.VIEW.FILE = 'F.DE.O.MSG.':FORM.TYPE
    END
    FV.VIEW.FILE = ''
    EB.DataAccess.Opf(FN.VIEW.FILE,FV.VIEW.FILE)

    FN.PREVIEW.MSG = 'F.DE.PREVIEW.MSG' ; FV.PREVIEW.MSG = ''
    EB.DataAccess.Opf( FN.PREVIEW.MSG, FV.PREVIEW.MSG)

    VIEW.ID = DE.ID:'.':I

    EB.DataAccess.FRead(FN.VIEW.FILE,VIEW.ID,R.MSG,'',VIEW.ERR)
    IF NOT(VIEW.ERR) THEN
        GOSUB PRINT.OUTPUT
    END ELSE
        PAGE.NO = 1
        LOOP
            PG.ID = VIEW.ID:'.':PAGE.NO
            EB.DataAccess.FRead(FN.VIEW.FILE,PG.ID,R.MSG,'',VIEW.ERR)
        WHILE NOT(VIEW.ERR)
            GOSUB PRINT.OUTPUT
            PAGE.NO += 1
        REPEAT
    END

    WRITE OUTPUT TO FV.PREVIEW.MSG,VIEW.ID
    DRILL.VAL = 'VIEW F.DE.PREVIEW.MSG>':VIEW.ID

RETURN
*---------------------------------------------------------------------------------------------------
PRINT.OUTPUT:
*************

    IF OUTPUT = '' THEN
        OUTPUT = R.MSG
    END ELSE
        OUTPUT := FORMFEED : R.MSG
    END

RETURN
*---------------------------------------------------------------------------------------------------
END






