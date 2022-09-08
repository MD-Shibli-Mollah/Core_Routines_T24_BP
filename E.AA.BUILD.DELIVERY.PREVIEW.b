* @ValidationCode : MjoyNzYwMTcyMDE6Q3AxMjUyOjE1ODkyNjY4MjUyNDQ6c21pdGhhYmhhdDozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAyLjIwMjAwMTE3LTIwMjY6MTI0Ojcy
* @ValidationInfo : Timestamp         : 12 May 2020 12:30:25
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smithabhat
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 72/124 (58.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>153</Rating> 
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.BUILD.DELIVERY.PREVIEW

** This routine will determine the drill-down enquiry for the delivery
** message enquiry AA.ARRANGEMENT.MESSAGES. The next level will display the
** formatted message where possible, the header if the message is not present,
** or nothing if the message is unformatted
*
** Incoming ID (AA Act ID)
**          S (Current Multivalue No)
**          O.DATA (Next level to execute)
*
* Modification History
*
* 24/04/13 - Defect : 627209
*            Task   : 658799
*            Conditional check is provided to display the drilldown properly for delivery messages
*            in which message disposition is unformatted.
*
* 22/11/13 - Defect : 840964
*            Task   : 843944
*            When Intereface is attached & null value is returned from it get the details from
*            DE.O.MSG.DEFAULT  else get the data from DE.PREVIEW.MSG
*
* 17/05/15 - Defect - 1613300
*            Task - 1700707
*            Delivery message is not opened up when use click binocular in Arrangement Overview
*
* 31/08/17 - Task : 2254924
*            Def  : 2249089
*            If @ID (ID of DE.O.HEADER record) is passed to O.DATA to launch the DE.O.HEADER record, then while using new browser
*            IRIS replases the @ID with the ENQUIRY record ID and results in error.
*
* 26/03/20 - Task : 3631781
*            Def  : 3629393
*            Display the preview message also for an api enquiry when the fixed selection has value
*
* 29/04/20 - Task  : 3723790
*            Defect: 3684150
*            Enquiry AA.DETAILS.MESSAGES should display all carrier address records for Delivery Reference in enquiry output.
*----------------------------------------------------------------------

    $USING DE.Config
    $USING AA.Framework
    $USING EB.DataAccess
    $USING DE.ModelBank
    $USING EB.Reports

	DEFFUN CHARX()
	F.DE.O.HEADER = ''
    EB.DataAccess.Opf('F.DE.O.HEADER',F.DE.O.HEADER)
*
    F.DE.CARRIER = ''
    EB.DataAccess.Opf('F.DE.CARRIER', F.DE.CARRIER)
    
    CARRIER.FORMAT = ''
    R.DE.CARRIER = ''
*
    FV.AA.ARR.ACT = ''
*
    PREVIEW.REC = ''
    EB.Reports.setId(EB.Reports.getOData())
    DEL.ID = EB.Reports.getOData();* Example -Enquiry Data will be D20200424332582213200*EMAIL.1
    CARRIER.ADDRESS = FIELD(DEL.ID,'*',2) ;* Get the Carrier Address from Delivery Reference(Example - EMAIL.1)
    CARRIER =  FIELD(CARRIER.ADDRESS,'.',1) ;* Get the Carrier Address from Delivery Reference (Example-  EMAIL)
    DEL.ID = FIELD(DEL.ID,'*',1);* Get the Delivery Reference from Enquiry Data
   
    READ YR.HEADER FROM F.DE.O.HEADER, DEL.ID THEN
*Get the position of current carrier adress in DE.O.HEADER
        LOCATE CARRIER.ADDRESS IN YR.HEADER<DE.Config.OHeader.HdrCarrierAddressNo,1> SETTING CAR.ADR THEN
        END
        DISP = YR.HEADER<DE.Config.OHeader.HdrDisposition,CAR.ADR>    ;* Obtain the Value of Disposition
        MSG.DISP = YR.HEADER<DE.Config.IHeader.HdrMsgDisp,CAR.ADR>
        MSG.ERR = YR.HEADER<DE.Config.OHeader.HdrMsgErrorCode,CAR.ADR>        ;* Obtain the value of MSG.ERROR.CODE
        COPY.NO = FIELD(YR.HEADER<DE.Config.IHeader.HdrCopyNo,CAR.ADR,'-',1)
        FRAME.NO = YR.HEADER<DE.Config.IHeader.HdrFrameNo,CAR.ADR>
* Defining of form.type and carrier.format are done here

        FORM.TYPE = YR.HEADER<DE.Config.OHeader.FormType,CAR.ADR>

        READ R.DE.CARRIER FROM F.DE.CARRIER,CARRIER['.',1,1] THEN
            CARRIER.FORMAT = R.DE.CARRIER<DE.Config.Carrier.CarrFormatModule>
        END ELSE
            CARRIER.FORMAT = CARRIER['.',1,1]
        END
*
        BEGIN CASE
*       We use DEL.ID instead of @ID decause while launching enquiry in UXP browser, IRIS will replace the @ID with the ID of the Enquiry record.
                                  
            CASE DISP = 'UNFORMATTED'       ;* Still an UNFORMATTED msg.
                EB.Reports.setOData("DE.O.HEADER S ":DEL.ID);* Display DE.O.HEADER

            CASE MSG.DISP[1,5] = 'ERROR'
                EB.Reports.setOData("DE.O.HEADER S ":DEL.ID)
*
            CASE MSG.DISP[1,8] = 'RESUBMIT'
                EB.Reports.setOData("DE.O.HEADER S ":DEL.ID)
*
            CASE MSG.DISP[1,7] MATCHES 'REROUTE':@VM:'DELETED'
                EB.Reports.setOData("DE.O.HEADER S ":DEL.ID)
*
*
            CASE MSG.DISP[1,3] MATCHES 'ACK':@VM:'NAK'
                GOSUB GET.COPY.NO
                EB.Reports.setOData('VIEW F.DE.O.HISTORY>':DEL.ID:'.':COPY.NO)
                IF CARRIER.FORMAT = 'PRINT' THEN
                    GOSUB GET.VIEW.ID
                END
*
            CASE MSG.DISP[1,4] = 'WACK'
                GOSUB GET.COPY.NO
                EB.Reports.setOData('VIEW F.DE.O.HISTORY>':DEL.ID:'.':COPY.NO)
                IF CARRIER['.',1,1] = 'PRINT' THEN
                    GOSUB GET.VIEW.ID
                END
*
            CASE CARRIER['.',1,1] = 'PRINT'

                GOSUB GET.VIEW.ID
                
            CASE MSG.DISP = 'REPAIR' AND MSG.ERR[1,3] NE 'NAK'  ;* Repair during Formatting.But do not display DE.O.HEADER if its NAK.
                
                EB.Reports.setOData("DE.O.HEADER S ":DEL.ID) ;* During Repair Stage display DE.O.HEADER record for Carrier Address in Enquiry

            CASE 1      ;* Other carriers
                GOSUB GET.COPY.NO

                IF CARRIER.FORMAT = 'PRINT' THEN
                    GOSUB GET.VIEW.ID
                END ELSE
                    EB.Reports.setOData('VIEW F.DE.O.MSG.':CARRIER['.',1,1]:'>':DEL.ID:'.':COPY.NO)
                END
*
        END CASE
*
    END ELSE
        EB.Reports.setOData('');* Unformatted
    END
*
RETURN
*
GET.VIEW.ID:
    OUTPUT = ''
    EQU FORMFEED TO CHARX(012)
    IF ( MSG.DISP[1,3] MATCHES 'ACK':@VM:'NAK' ) OR ( MSG.DISP[1,4] = 'WACK') THEN
        FN.VIEW.FILE = 'F.DE.O.HISTORY'
    END ELSE
        FN.VIEW.FILE = 'F.DE.O.MSG.':FORM.TYPE
    END
    FV.VIEW.FILE = ''
    EB.DataAccess.Opf(FN.VIEW.FILE,FV.VIEW.FILE)

    FV.PREVIEW.MSG = ''
    FN.PREVIEW.MSG = 'F.DE.PREVIEW.MSG' ;* Open DE.PREVIEW.MSG files
    EB.DataAccess.Opf( FN.PREVIEW.MSG, FV.PREVIEW.MSG)

    VIEW.ID = DEL.ID:'.':CAR.ADR ;* Append Delivery Reference with Carrier Address Position
    PAGE.NO = 1
    LOOP
        PG.ID = VIEW.ID:'.':PAGE.NO
        EB.DataAccess.FRead(FN.VIEW.FILE,PG.ID,R.MSG,'',VIEW.ERR)
    WHILE NOT(VIEW.ERR)
        IF OUTPUT = '' THEN
            OUTPUT = R.MSG
        END ELSE
            OUTPUT := FORMFEED : R.MSG
        END
        PAGE.NO += 1
    REPEAT

    WRITE OUTPUT TO FV.PREVIEW.MSG,VIEW.ID
    PREVIEW.REC = DE.ModelBank.PreviewMsg.Read(VIEW.ID, PREVIEW.ERR)
* Before incorporation : CALL F.READ('F.DE.PREVIEW.MSG',VIEW.ID,PREVIEW.REC,FV.PREVIEW.MSG,PREVIEW.ERR)
    FIXED.SELECTION = ''
    FIXED.SELECTION = EB.Reports.getREnq()<EB.Reports.Enquiry.EnqFixedSelection>
    MSG.FLG = ''
    
    TOT.SEL = ''
    TOT.SEL = DCOUNT(FIXED.SELECTION,@VM)
    FOR CNT.LOOP = 1 TO TOT.SEL
        SEL.COND = ''
        SEL.COND = FIXED.SELECTION<1,CNT.LOOP>
        IF SEL.COND[' ',1,1] EQ 'API.FLAG' THEN
            MSG.FLG = SEL.COND[' ',3,1]
        END
    NEXT CNT.LOOP
       
    IF NOT(MSG.FLG) THEN
        IF PREVIEW.REC THEN
            EB.Reports.setOData('VIEW F.DE.PREVIEW.MSG>':VIEW.ID)
        END ELSE
            EB.Reports.setOData('VIEW F.DE.O.MSG.DEFAULT>':PG.ID)
        END
    END ELSE
        IF PREVIEW.REC THEN
            CHANGE @FM TO '~' IN PREVIEW.REC
            PREVIEW.REC = TRIM(PREVIEW.REC,"-","A")
            PREVIEW.REC = TRIM(PREVIEW.REC," ","D")
            PREVIEW.REC = TRIM(PREVIEW.REC,"","A") 

            EB.Reports.setOData(PREVIEW.REC) 
        END
    END

RETURN
*************************************************************************************************************
*===========
GET.COPY.NO:
*===========
    IF FRAME.NO GT '1' THEN
        COPY.NO = COPY.NO + (FRAME.NO - 1)
    END
RETURN
*************************************************************************************************************
END
