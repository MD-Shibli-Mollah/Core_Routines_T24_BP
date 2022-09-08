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

* Version 2 15/05/01  GLOBUS Release No. G13.0.00 21/06/02
*-----------------------------------------------------------------------------
* <Rating>161</Rating>
    $PACKAGE DE.Reports
    SUBROUTINE E.DE.MSG.SUM.NEXT.LEVEL

** This routine will determine the drill-down enquiry for the delivery
** message enquiry DE.MSG.SUM. The next level will display the formatted
** message where possible, the header if the message is not present, or
** nothing if the message is unformatted
*
** Incoming ID (Delivery Ref)
**          S (Current Multivalue No)
**          O.DATA (Next level to execute)
*
* 30/03/01 - GB0100933
*            For Multiple Delivery Recepients - Obtain copy no.
*            COPY.NO contains copy.no-MDR.customer
*
* 11/04/02 - CI_10001567
*            The records are picked from the DE.O.SWIFT/PRINT
*            based on the copy number but the frame number should
*            be taken into consideration
*
* 16/07/02 - CI_10002692
*            When the Delivery Message goes to many pages , the same
*            Cannot be viewed through the enquiry.
*
* 22/07/02 - CI_10003277
*            Unable to preview the delivery messages as it takes long time to
*            process.  Instead of SSELECT on the DE.O.MSG.formtype which results
*            in performance issue, do a READ on DE.O.MSG.formtype.
*
* 02/07/03 - CI_10010455
*            Unable to view DELIVERY MESSAGE from  Enquiry DE.MSG.SUM
*            for CARRIER FAX and has FORMAT.MODULE(DE.CARRIER) as PRINT
*
*            This routine has been cleanedup along with this CD.
*            Repeated defining of common variables are done once
*            and the comman variable is used at the appropriate places.
*
* 21/02/07 - BG_100013037
*            CODE.REVIEW changes.
*
* 23/06/08 - CI_10056239
*            Enquiry Crashes during Drilldown.
*            Ref: HD08113312
*
* 04/11/08 - CI_10058604
*            Delivery messages with multiple frames which is sent to more
*            than one swift address are displayed incorrectly.
*
* 23/11/09 - CI_10067739
*            While trying to view the Delivery message which is in NAK status via the enquiry DE.MSG.SUM,
*            system displays DE.O.HEADER record, instead of displaying Delivery message.
*
* 04/10/12 - Task 494582 / Defect 490704
*            Problem in Viewing the formatted delivery messages.
*
* 10/04/13 - Defect 618691 / Task 644653
*			 Conditional check is provided to display the drilldown properly for delivery messages
*			 in which message disposition is null and disposition is not formatted.
*
* 31/07/2015 - Enhancement 1265068
*              Task 1391515
*              Routine Incorporated
*
*----------------------------------------------------------------------
    $USING DE.Config
    $USING EB.DataAccess
    $USING DE.Reports
    $USING EB.Reports


    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
    CARRIER.FORMAT = ''
    R.DE.CARRIER = ''
*
    DEL.ID = EB.Reports.getId()
    DE.ER = ''
    YR.HEADER = ''
    YR.HEADER = DE.Config.OHeader.Read(DEL.ID, DE.ER)
    IF YR.HEADER THEN
        *
        DISP = YR.HEADER<DE.Config.OHeader.HdrDisposition,EB.Reports.getS()>    ;* Obtain the Value of Disposition
        CARRIER = YR.HEADER<DE.Config.OHeader.HdrCarrierAddressNo,EB.Reports.getS()>
        MSG.DISP = YR.HEADER<DE.Config.OHeader.HdrMsgDisp,EB.Reports.getS()>
        MSG.ERR = YR.HEADER<DE.Config.OHeader.HdrMsgErrorCode,EB.Reports.getS()>        ;* Obtain the value of MSG.ERROR.CODE
        tmp.S = EB.Reports.getS()
        COPY.NO = FIELD(YR.HEADER<DE.Config.OHeader.HdrCopyNo,tmp.S>,'-',1)
        FRAME.NO = YR.HEADER<DE.Config.OHeader.HdrFrameNo,EB.Reports.getS()>
        * Defining of form.type and carrier.format are done here

        FORM.TYPE = YR.HEADER<DE.Config.OHeader.FormType,EB.Reports.getS()>
        CARR.ID = CARRIER['.',1,1]
        CAR.ER = ''
        R.DE.CARRIER = ''
        R.DE.CARRIER = DE.Config.Carrier.CacheRead(CARR.ID, CAR.ER)
        IF R.DE.CARRIER THEN
            CARRIER.FORMAT = R.DE.CARRIER<DE.Config.Carrier.CarrFormatModule>
        END ELSE
            CARRIER.FORMAT = CARRIER['.',1,1]
        END
        *
        BEGIN CASE

            CASE DISP = 'UNFORMATTED'       ;* Still an UNFORMATTED msg.
                EB.Reports.setOData('DE.O.HEADER S @ID');* Display DE.O.HEADER

            CASE DISP  = 'REPAIR' ;* DISPOSITION is REPAIR. Possible Mapping error
                EB.Reports.setOData('DE.O.HEADER S @ID');* Display DE.O.HEADER

            CASE MSG.DISP = 'REPAIR' AND MSG.ERR[1,3] NE 'NAK'  ;* Repair during Formatting.But do not display DE.O.HEADER if its NAK.
                EB.Reports.setOData('DE.O.HEADER S @ID');* Display DE.O.HEADER
                *
            CASE MSG.DISP[1,8] = 'RESUBMIT'
                EB.Reports.setOData('DE.O.HEADER S @ID')
                *
            CASE MSG.DISP[1,7] MATCHES 'REROUTE':@VM:'DELETED'
                EB.Reports.setOData('DE.O.HEADER S @ID')
                *
                *
            CASE MSG.DISP[1,3] MATCHES 'ACK':@VM:'NAK'
                tmp.S = EB.Reports.getS()
                tmp.ID = EB.Reports.getId()
                EB.Reports.setOData('VIEW F.DE.O.HISTORY>':tmp.ID:'.':tmp.S)
                * checking of carrier = print is changed to carrier.format = print
                IF CARRIER.FORMAT = 'PRINT' THEN      ;* CI_10010455 S/E
                    GOSUB GET.VIEW.ID
                END
                *
            CASE MSG.DISP[1,4] = 'WACK'
                tmp.S = EB.Reports.getS()
                tmp.ID = EB.Reports.getId()
                EB.Reports.setOData('VIEW F.DE.O.HISTORY>':tmp.ID:'.':tmp.S)
                IF CARRIER['.',1,1] = 'PRINT' THEN
                    * CI_10002692 S
                    GOSUB GET.VIEW.ID
                    EB.Reports.setOData('VIEW F.DE.PREVIEW.MSG>':VIEW.ID)
                    * CI_10002692 E
                END
                *
            CASE CARRIER['.',1,1] = 'PRINT'

                GOSUB GET.VIEW.ID

            CASE MSG.DISP = '' AND DISP NE 'FORMATTED'       ;* MSG.DISP is null and DISPOSITON is not formatted.
                EB.Reports.setOData('DE.O.HEADER S @ID');* Display DE.O.HEADER

            CASE 1      ;* Other carriers

                * CI_10010455 - STARTS
                IF CARRIER.FORMAT = 'PRINT' THEN
                    GOSUB GET.VIEW.ID
                END ELSE
                    tmp.S = EB.Reports.getS()
                    tmp.ID = EB.Reports.getId()
                    EB.Reports.setOData('VIEW F.DE.O.MSG.':CARRIER['.',1,1]:'>':tmp.ID:'.':tmp.S)
                END
                * CI_10010455 - ENDS

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

    FN.PREVIEW.MSG = 'F.DE.PREVIEW.MSG' ; FV.PREVIEW.MSG = ''
    EB.DataAccess.Opf( FN.PREVIEW.MSG, FV.PREVIEW.MSG)

    VIEW.ID = EB.Reports.getId():'.':EB.Reports.getS()

** CI_10003277 -S
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
** CI_10003277 -E

    WRITE OUTPUT TO FV.PREVIEW.MSG,VIEW.ID
        EB.Reports.setOData('VIEW F.DE.PREVIEW.MSG>':VIEW.ID);* CI_10010455 S/E
        RETURN
*************************************************************************************************************
PRINT.OUTPUT:

        IF OUTPUT = '' THEN
            OUTPUT = R.MSG
        END ELSE
            OUTPUT := FORMFEED : R.MSG
        END
        RETURN
    END
