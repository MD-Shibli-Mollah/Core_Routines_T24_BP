* @ValidationCode : MTo4ODY3NTQ3OTA6Q3AxMjUyOjE0NzkxMzEzNzkwODg6Y2hqYWhuYXZpOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE2MDguMA==
* @ValidationInfo : Timestamp         : 14 Nov 2016 19:19:39
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : chjahnavi
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201608.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
    $PACKAGE IM.ModelBank
    SUBROUTINE V.TC.UPDATE.NOTES
*-----------------------------------------------------------------------------
* This routine is attached to the version IM.DOCUMENT.IMAGE,TC to update
* image details of the application to which it is attached
*------------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Changes done in the sub-routine </desc>
* Modification history:
*-----------------------
* 14/10/16 - Enhancement 1648966
*            Update the live table IM.IMAGE.DETAILS
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>

    $USING EB.SystemTables
    $USING IM.Foundation
    $USING EB.Utility

    GOSUB INITIALISE
    GOSUB PROCESS
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise parameters required</desc>
INITIALISE:
*----------
    UPDATE.IMAGE.NAME = '' ; UpdateImageRef = '';
    ImUpdateRec = ''; DocImageRec = '';
    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= MAIN PROCESSING>
*** <desc>Check whether to update the concat file or delete the file</desc>
PROCESS:
*------
* Set the record details for IM.IMAGE.DETAILS

    ImageUploadId = EB.SystemTables.getIdNew()
    ImageNotes = EB.SystemTables.getRNew(IM.Foundation.DocumentImage.DocNotes)
    ImageReference = EB.SystemTables.getRNew(IM.Foundation.DocumentImage.DocImageReference)
    DocImageRec = IM.Foundation.DocumentImage.Read(ImageUploadId,ImageErr) ;* Read IM.DOCUMENT.IMAGE record

    IF NOT(DocImageRec) OR (DocImageRec AND DocImageRec<IM.Foundation.DocumentImage.DocImageApplication> EQ 'STMT.ENTRY') THEN ;* Update IM.IMAGE.DETAILS for statement entry application
        UpdateImageRef = ImageReference
        ImUpdateRec = IM.Foundation.ImImageDetails.Read(UpdateImageRef, Error)
        IF NOT(ImUpdateRec) OR (ImUpdateRec AND ImUpdateRec<IM.Foundation.ImImageDetails.ImNotes> NE ImageNotes) THEN
            GOSUB UPDATE.NOTES ;* Update notes
        END
    END
    RETURN
*** </region>
*----------------------------------------------------------------------------
*** <region name= UPDATE IMAGE DETAILS>
*** <desc>Write the details into live file IM.IMAGE.DETAILS</desc>
UPDATE.NOTES:
*-----------
* Update IM.IMAGE.DETAILS for statement entry application
    GOSUB GET.DATE.TIME ;* Get current date and time
    IF NOT(ImUpdateRec) THEN
        ImUpdateRec<IM.Foundation.ImImageDetails.ImApplicationName> = EB.SystemTables.getRNew(IM.Foundation.DocumentImage.DocImageApplication)
        ImUpdateRec<IM.Foundation.ImImageDetails.ImImageType> = EB.SystemTables.getRNew(IM.Foundation.DocumentImage.DocImageType)
        ImUpdateRec<IM.Foundation.ImImageDetails.ImImageId> = ImageUploadId
    END
    ImUpdateRec<IM.Foundation.ImImageDetails.ImNotes> = ImageNotes
    ImUpdateRec<IM.Foundation.ImImageDetails.ImCompany> = EB.SystemTables.getIdCompany()
    ImUpdateRec<IM.Foundation.ImImageDetails.ImDateCreated> = YSYSDATE
    ImUpdateRec<IM.Foundation.ImImageDetails.ImTimeCreated> = TIME.HHMM
    IM.Foundation.ImImageDetailsWrite(UpdateImageRef,ImUpdateRec,'') ;* Write record details into IM.IMAGE.DETAILS

    RETURN
*** </region>
*-------------------------------------------------------------------------------
*** <region name= GET TIME AND DATE>
*** <desc>Get local zone date and time based on the SPF setup </desc>
GET.DATE.TIME:
*------------
    INOPTIONS='' ; OUTOPTIONS=''        ;* Initialise
    INOPTIONS<1> ='':@VM:'D4E' ;* local zone date
    INOPTIONS<2> ='':@VM:'MTH' ;* local zone time

    EB.Utility.Getlocalzonedatetime('','',INOPTIONS,localZoneDate,localZoneTime,OUTOPTIONS, reserved1)

    YSYSDATE = localZoneDate<1>[7,4]:localZoneDate<1>[1,2]:localZoneDate<1>[4,2]          ;* date
    HHMM = localZoneTime<1>:' ':localZoneDate<2>  ;* TIMEDATE() output
    TIME.HHMM = HHMM
    TIME.HHMM = TIME.HHMM[1,2]:TIME.HHMM[4,2] : TIME.HHMM[7,2]
    RETURN
*** </region>
*-----------------------------------------------------------------------------
    END
