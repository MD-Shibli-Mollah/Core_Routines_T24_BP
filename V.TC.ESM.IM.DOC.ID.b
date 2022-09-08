* @ValidationCode : MjotMTkyMjE2NTg0NTpDcDEyNTI6MTQ5ODEyMTc1NTA1MDprYW5hbmQ6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTcwNy4yMDE3MDYxNC0wMDQyOjExNjoxMDk=
* @ValidationInfo : Timestamp         : 22 Jun 2017 14:25:55
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kanand
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 109/116 (93.9%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201707.20170614-0042
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE EB.Channels
SUBROUTINE V.TC.ESM.IM.DOC.ID
*-----------------------------------------------------------------------------------------------
* Description : Routine that handles EB.SECURE.MESSAFE and IM.DOCUMENT.UPLOAD all under same
*               transaction boundary. This routine will create the IM.DOUMENT.IMAGE for documents
*               captured.
*-----------------------------------------------------------------------------------------------
* Modification History:
*---------------------
* 16/05/2017 - Enhancement 2004874 / Task 2127622
*              Secure message attachment upload
*
* 22/06/2017 - Defect 2168054 / Task 2170000
*              Too many character error, when upload a file with long name.
*-----------------------------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.ARC
    $USING EB.Interface
    $USING EB.ErrorProcessing
    $USING ST.CompanyCreation
    $USING IM.Foundation
    $USING EB.TransactionControl
    $USING EB.DataAccess
    $USING EB.API
    $USING EB.Foundation
*
    GOSUB CHECK.IM.INSTALLED        ;*Check whether IM component available
    IF IM.INSTALLED THEN
        GOSUB INITIALISE
        GOSUB PROCESS
    END
RETURN

*-----------------------------------------------------------------------------------------------
INITIALISE:
*---------
* initialise and open parameters
    IMG.REF = ''
    Y.OFS.REQ.ERR = ''
    REQ.USER.ID = EB.ErrorProcessing.getExternalUserId()
*
RETURN
*-----------------------------------------------------------------------------------------------
PROCESS:
*-------
* Create IM.DOCUMENT.IMAGE record and update EB.SECURE.MESSAGE record with Id
    IF EB.SystemTables.getRNew(EB.ARC.SecureMessage.SmFileUpload) AND EB.SystemTables.getRNew(EB.ARC.SecureMessage.SmUploadId) EQ '' THEN
        FN.IM.DOCUMENT.IMAGE='F.IM.DOCUMENT.IMAGE'
        F.IM.DOCUEMNT.IMAGE=''
        EB.DataAccess.Opf( FN.IM.DOCUMENT.IMAGE,F.IM.DOCUEMNT.IMAGE)
        IMG.REF=EB.SystemTables.getIdNew()        ;*Message id is fetched ,so that it can be added to IMAGE.REFERENCE field in IM.DOCUMENT.IMAGE
        FILE.NAME.TYPE = EB.SystemTables.getRNew(EB.ARC.SecureMessage.SmFileUpload)
        FILE.NAME = FIELDS(FILE.NAME.TYPE,':',2)  ;* File name to be set as descritption / short description
        IMAGE.TYPE = FIELDS(FILE.NAME.TYPE,':',1) ;* Image type
*
        IF FILE.NAME THEN        ;* Create image file if provided
            GOSUB BACKUP.COMMON.DATA    ;*Backup the values in common data
            GOSUB SET.DATA.FOR.NEXT.ID  ;*Set data values to get the new id for IM.DOCUMENT.IMAGE
            EB.TransactionControl.GetNextId(YBASEID,YTYPE) ;*Existing call routine which brings the next id for the application
            EB.SystemTables.setIdNew(EB.SystemTables.getComi())  ;*assigning the comi variable to id.new variable
            EB.TransactionControl.FormatId('IM') ;*existing call routine to format the id
            IM.DOC.IMAGE.KEY.FRONT =  EB.SystemTables.getIdNew();* ID.NEW       ;*get the id value for IM.DOCUMENT.IMAGE from ID.NEW
*
            var_ofsApplication = 'IM.DOCUMENT.IMAGE'
            var_ofsFunction = 'I'
            var_ofsProcess = 'PROCESS'
            var_ofsVersion='IM.DOCUMENT.IMAGE,TC'
            var_ofsGtsmode=''
            var_ofsNoOfAuth=''
            var_ofsTxnId=IM.DOC.IMAGE.KEY.FRONT
            var_record<IM.Foundation.DocumentImage.DocImageType>=IMAGE.TYPE
            var_record<IM.Foundation.DocumentImage.DocImageApplication>="EB.SECURE.MESSAGE"
            var_record<IM.Foundation.DocumentImage.DocImageReference>=IMG.REF
            var_record<IM.Foundation.DocumentImage.DocShortDescription>=IMG.REF ;* Image reference added for Description and Short Description
            var_record<IM.Foundation.DocumentImage.DocDescription>=IMG.REF
            var_record<IM.Foundation.DocumentImage.DocMultiMediaType>="DOCUMENT"
            var_ofsOptions      =REQ.USER.ID
            var_ofsMessage=''
*
            GOSUB PROCESS.LOCAL.REQUEST
            IF NOT(Y.OFS.REQ.ERR) THEN
                var_ofsApplication = 'IM.DOCUMENT.UPLOAD'
                var_ofsMessage=''
                var_ofsVersion='IM.DOCUMENT.UPLOAD,TC'
                var_ofsTxnId=IM.DOC.IMAGE.KEY.FRONT
                var_record=''
                var_record<IM.Foundation.DocumentUpload.UpFileUpload>=FILE.NAME
                var_record<IM.Foundation.DocumentUpload.UpUploadId>=IM.DOC.IMAGE.KEY.FRONT
*
                GOSUB PROCESS.LOCAL.REQUEST
                GOSUB RESTORE.COMMON.DATA
            END
            IF Y.OFS.REQ.ERR EQ '' THEN
                EB.SystemTables.setRNew(EB.ARC.SecureMessage.SmUploadId, IM.DOC.IMAGE.KEY.FRONT)
            END ELSE
                EB.SystemTables.setAf(EB.ARC.SecureMessage.SmUploadId)
                EB.SystemTables.setE("Y.OFS.REQ.ERR")
            END
            GOSUB GET.FILE.PATH
        END ELSE
            EB.SystemTables.setAf(EB.ARC.SecureMessage.SmUploadId)
            EB.SystemTables.setE("EB-FILE.UPLOAD.SYSTEM.ERROR")
        END
    END
*
RETURN
*-----------------------------------------------------------------------------------------------
CHECK.IM.INSTALLED:
*------------------
* To check IM product installed
    IM.INSTALLED = ''
    EB.API.ProductIsInCompany('IM', IM.INSTALLED) ;* IM product instalation check
*
RETURN
*-----------------------------------------------------------------------------------------------
PROCESS.LOCAL.REQUEST:
* Process local request
    EB.Foundation.OfsBuildRecord(var_ofsApplication,var_ofsFunction,var_ofsProcess,var_ofsVersion,var_ofsGtsmode,var_ofsNoOfAuth,var_ofsTxnId,var_record,var_ofsMessage)
    EB.Interface.OfsAddlocalrequest(var_ofsMessage,'',Y.OFS.REQ.ERR)  ;*Call the API ofs.addLocalRequest to create IM.DOCUMENT.IMAGE record
*
RETURN
*--------------------------------------------------------------------------------------------------------
BACKUP.COMMON.DATA:
*-------------------
*backup and Store the  common variables
*
    SAVE.APPLICATION = EB.SystemTables.getApplication()  ;*storing the application
    SAVE.FULL.FNAME  = EB.SystemTables.getFullFname() ;*storing the full name
    SAVE.FUNCTION  = EB.SystemTables.getVFunction() ;*storing V fucntion variable
    SAVE.ID.CONCATFILE = EB.SystemTables.getIdConcatfile() ;* stroing concat file
    SAVE.ID.N   = EB.SystemTables.getIdN() ;* storing N value
    SAVE.ID.NEW = EB.SystemTables.getIdNew()   ;*storing the id.new variable
    SAVE.ID.T   = EB.SystemTables.getIdT() ;* stroing T value
    SAVE.LIVE.REC.MAN  = EB.SystemTables.getLiveRecordMandatory()
    SAVE.PGM.TYPE   = EB.SystemTables.getPgmType()  ;*storing the application pgm type
    SAVE.COMI  = EB.SystemTables.getComi() ;*storing the comi variable
    SAVE.TEXT  = EB.SystemTables.getText() ;* stroing TEXT value
*
RETURN
*-----------------------------------------------------------------------------------------------
SET.DATA.FOR.NEXT.ID:
*---------------------
*initialising parameters to pass to the call routine to find next id
    EB.SystemTables.setComi('') ;*nullyfying the variable
    EB.SystemTables.setIdNew('')
    YBASEID = ''
    EB.SystemTables.setFullFname(FN.IM.DOCUMENT.IMAGE)
    EB.SystemTables.setVFunction('I')
    EB.SystemTables.setIdF('KEY')
    EB.SystemTables.setIdN('12.1')
    EB.SystemTables.setIdT('A')
    EB.SystemTables.setPgmType('.IDA')
    EB.SystemTables.setApplication('IM.DOCUMENT.IMAGE')
    YTYPE = 'F'     ;*argument to be passed to call routine
*
RETURN
*------------------------------------------------------------------------------------------------
RESTORE.COMMON.DATA:
*---------------------
*restoring the common variables to its original values
    EB.SystemTables.setApplication(SAVE.APPLICATION)  ;*restoring application
    EB.SystemTables.setFullFname(SAVE.FULL.FNAME) ;*restoring full name
    EB.SystemTables.setVFunction(SAVE.FUNCTION) ;*restoring function
    EB.SystemTables.setIdConcatfile(SAVE.ID.CONCATFILE)
    EB.SystemTables.setIdN(SAVE.ID.N)
    EB.SystemTables.setIdNew(SAVE.ID.NEW) ;*restoring id.new variable
    EB.SystemTables.setIdT(SAVE.ID.T)
    EB.SystemTables.setLiveRecordMandatory(SAVE.LIVE.REC.MAN)
    EB.SystemTables.setPgmType(SAVE.PGM.TYPE) ;*restoring pgm type
    EB.SystemTables.setComi(SAVE.COMI) ;*restoring comi variable
    EB.SystemTables.setText(SAVE.TEXT)
*
RETURN
*------------------------------------------------------------------------------------------------
GET.FILE.PATH:
*------------
* Get the path where image is stored
    R.IMG.TYPE = ''
    R.IMG.TYPE=IM.Foundation.ImageType.Read(IMAGE.TYPE, IMG.ERR) ;* Read Image type record to get the path
    IF R.IMG.TYPE<IM.Foundation.ImageType.TypDefaultDrive> THEN
        FILE.NAME = R.IMG.TYPE<IM.Foundation.ImageType.TypDefaultDrive>:R.IMG.TYPE<IM.Foundation.ImageType.TypPath>:FILE.NAME
    END ELSE
        FILE.NAME = R.IMG.TYPE<IM.Foundation.ImageType.TypPath>:FILE.NAME
    END
    EB.SystemTables.setRNew(EB.ARC.SecureMessage.SmFileUpload, FILE.NAME)  ;* Assign file path field
*
RETURN
*------------------------------------------------------------------------------------------------
END
