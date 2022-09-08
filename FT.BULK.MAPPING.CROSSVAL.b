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

* Version 2 02/06/00  GLOBUS Release No. G14.1.01 04/12/03
*-----------------------------------------------------------------------------
* <Rating>-99</Rating>
    $PACKAGE FT.BulkProcessing
    SUBROUTINE FT.BULK.MAPPING.CROSSVAL
************************************************************************
* Cross Validation Routine
*
************************************************************************
* 29/06/04 - EN_10002298
*            New Version
*
*
* 26/02/07 - BG_100013036
*            CODE.REVIEW changes.
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
*17/07/15 - Defect 1409118 / Task 1411647
*         - Code fixes for tafc compilation
************************************************************************
    $USING EB.SystemTables
    $USING EB.Interface
    $USING EB.ErrorProcessing
    $USING EB.Template
    $USING FT.BulkProcessing
*
************************************************************************
*
*
************************************************************************
*
    GOSUB INITIALISE
*
    GOSUB REPEAT.CHECK.FIELDS
*
    GOSUB REAL.CROSSVAL
*
    RETURN
*
************************************************************************
*
REAL.CROSSVAL:
*
* Real cross validation goes here....
*
************************************************

    EB.SystemTables.setAf(FT.BulkProcessing.BulkMapping.BkmapApplication)

* Read the SS of the application defined in this field
    SS.ERR = ''
    ID.STD.APPL = EB.SystemTables.getRNew(FT.BulkProcessing.BulkMapping.BkmapApplication)
    R.SS.STD.APPL = EB.SystemTables.StandardSelection.Read(ID.STD.APPL, SS.ERR)
    IF SS.ERR THEN
        EB.SystemTables.setEtext('FT-SS.NOT.FOUND')
        EB.ErrorProcessing.StoreEndError()
        RETURN
    END

************************************************

    EB.SystemTables.setAf(FT.BulkProcessing.BulkMapping.BkmapBulkFieldName)

* Read the SS of the Dynamic template defined in the ID
    SS.ERR = ''
    R.TABLE.DEF = EB.SystemTables.TableDefinition.Read(EB.SystemTables.getIdNew(), ER)
    BULK.PRODUCT = R.TABLE.DEF<EB.SystemTables.TableDefinition.DynActProduct>
    ID.BULK.APPL = BULK.PRODUCT:'.':EB.SystemTables.getIdNew()
    R.SS.BULK.APPL = EB.SystemTables.StandardSelection.Read(ID.BULK.APPL, SS.ERR)
    IF SS.ERR THEN
        EB.SystemTables.setAv(1)
        EB.SystemTables.setEtext('FT-SS.OF.ID.NOT.FOUND')
        EB.ErrorProcessing.StoreEndError()
        RETURN
    END

* Clear the Field numbers of the Dynamic tempalte and build it newly by reading SS
    EB.SystemTables.setRNew(FT.BulkProcessing.BulkMapping.BkmapBulkFieldNo, '')


* Check if all the fields in BULK.FIELD.NAME is a valid one in SS
    SS.FLDS = R.SS.BULK.APPL<EB.SystemTables.StandardSelection.SslSysFieldName>
    BULK.FLDS.CNT = DCOUNT(EB.SystemTables.getRNew(FT.BulkProcessing.BulkMapping.BkmapBulkFieldName), @VM)
    FOR I = 1 TO BULK.FLDS.CNT
        EB.SystemTables.setAv(I)
        BULK.FLD = EB.SystemTables.getRNew(FT.BulkProcessing.BulkMapping.BkmapBulkFieldName)<1,EB.SystemTables.getAv()>
        LOCATE BULK.FLD IN SS.FLDS<1,1> SETTING SS.POS THEN
        SS.FLD.NO = R.SS.BULK.APPL<EB.SystemTables.StandardSelection.SslSysFieldNo, SS.POS, 1>
        * I or J descriptors not allowed
        IF NUM(SS.FLD.NO) THEN
        AV1 = EB.SystemTables.getAv()
            tmp=EB.SystemTables.getRNew(FT.BulkProcessing.BulkMapping.BkmapBulkFieldNo); tmp<1, AV1>=SS.FLD.NO; EB.SystemTables.setRNew(FT.BulkProcessing.BulkMapping.BkmapBulkFieldNo, tmp);* Assign the proper field no
        END ELSE
            EB.SystemTables.setEtext('FT-NOT.VALID.FLD')
        END
    END ELSE
        EB.SystemTables.setEtext('FT-FLD.NOT.IN.DYN.TEMPLATE')
        EB.ErrorProcessing.StoreEndError()
    END
    NEXT I

************************************************

    EB.SystemTables.setAf(FT.BulkProcessing.BulkMapping.BkmapApplFieldName)

* Check if all the fields in APPL.FIELD.NAME is a valid one in SS
    SS.FLDS = R.SS.STD.APPL<EB.SystemTables.StandardSelection.SslSysFieldName>
    STD.FLDS.CNT = DCOUNT(EB.SystemTables.getRNew(FT.BulkProcessing.BulkMapping.BkmapApplFieldName), @VM)
    FOR I = 1 TO STD.FLDS.CNT
        EB.SystemTables.setAv(I)
        STD.FLD = EB.SystemTables.getRNew(FT.BulkProcessing.BulkMapping.BkmapApplFieldName)<1,EB.SystemTables.getAv()>
        LOCATE STD.FLD IN SS.FLDS<1,1> SETTING SS.POS ELSE
        EB.SystemTables.setEtext('FT-FLD.NOT.IN.APPLN')
        EB.ErrorProcessing.StoreEndError()
    END
    NEXT I

************************************************

    EB.SystemTables.setAf(FT.BulkProcessing.BulkMapping.BkmapOfsSource)

* SOURCE.TYPE field in OFS.SOURCE record should be 'GLOBUS'
    OFS.SRC = EB.SystemTables.getRNew(EB.SystemTables.getAf())
    R.OFS.SOURCE = EB.Interface.OfsSource.Read(OFS.SRC, ER)
    SRC.TYPE = R.OFS.SOURCE<EB.Interface.OfsSource.OfsSrcSourceType>
    IF SRC.TYPE NE 'GLOBUS' THEN
        EB.SystemTables.setEtext('FT-SRC.TYPE.NOT.GLOBUS.IN.OFS')
        EB.ErrorProcessing.StoreEndError()
    END


************************************************

    EB.SystemTables.setAf(FT.BulkProcessing.BulkMapping.BkmapVersion)

* Version should be a real version and should be for the same application defined in field 1
    VER = EB.SystemTables.getRNew(EB.SystemTables.getAf())
    APPL.ID = FIELD(VER, ',', 1)
    VER.ID = FIELD(VER, ',', 2)
    IF APPL.ID NE EB.SystemTables.getRNew(FT.BulkProcessing.BulkMapping.BkmapApplication) THEN
        EB.SystemTables.setEtext('FT-VER.NOT.FOR.APPLN')
        EB.ErrorProcessing.StoreEndError()
    END

    IF NOT(VER.ID) THEN
        EB.SystemTables.setEtext('FT-VER.SHOULD.BE.REAL')
        EB.ErrorProcessing.StoreEndError()
    END

************************************************

    RETURN
*
************************************************************************
*
REPEAT.CHECK.FIELDS:
*
* Loop through each field and repeat the check field processing if there is any defined
*
    XX.CONTRACT.STATUS = ''   ;* Should be changed with the no. of fields
    FOR I = 1 TO XX.CONTRACT.STATUS
        EB.SystemTables.setAf(I)
        IF INDEX(EB.SystemTables.getN(EB.SystemTables.getAf()), "C", 1) THEN
            *
            * Is it a sub value, a multi value or just a field
            *
            BEGIN CASE
                CASE EB.SystemTables.getF(EB.SystemTables.getAf())[4,2] = 'XX'      ;* Sv
                    GOSUB CHECK.SUB.VALUES  ;* BG_100013036 - S / E
                CASE EB.SystemTables.getF(EB.SystemTables.getAf())[1,2] = 'XX'      ;* Mv
                    GOSUB CHECK.MULTI.VALUES          ;* BG_100013036 - S / E
                CASE 1
                    EB.SystemTables.setAv(''); EB.SystemTables.setAs('')
                    GOSUB DO.CHECK.FIELD
            END CASE
        END
    NEXT I
    RETURN
*
************************************************************************
*
DO.CHECK.FIELD:
** Repeat the check field validation - errors are returned in the
** variable E.
*
    EB.SystemTables.setComiEnri("")
    BEGIN CASE
        CASE EB.SystemTables.getAs()
            EB.SystemTables.setComi(EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>)
        CASE EB.SystemTables.getAv()
            EB.SystemTables.setComi(EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv()>)
        CASE EB.SystemTables.getAf()
            EB.SystemTables.setComi(EB.SystemTables.getRNew(EB.SystemTables.getAf()))
    END CASE
*
    EB.Template.XxCheckFields()
    IF EB.SystemTables.getE() THEN
        EB.SystemTables.setEtext(EB.SystemTables.getE())
        EB.ErrorProcessing.StoreEndError()
    END ELSE
        AS1 = EB.SystemTables.getAs()
        AV1 = EB.SystemTables.getAv()
        AF1 = EB.SystemTables.getAf()
        BEGIN CASE
            CASE AS1
                tmp=EB.SystemTables.getRNew(AF1); tmp<1,AV1,AS1>=EB.SystemTables.getComi(); EB.SystemTables.setRNew(AF1, tmp)
                YENRI.FLD = AF1:".":AV1:".":AS1 ; YENRI = EB.SystemTables.getComiEnri()
                GOSUB SET.UP.ENRI
            CASE AV1
                tmp=EB.SystemTables.getRNew(AF1); tmp<1,AV1>=EB.SystemTables.getComi(); EB.SystemTables.setRNew(AF1, tmp)
                YENRI.FLD = AF1:".":AV1 ; YENRI = EB.SystemTables.getComiEnri()
                GOSUB SET.UP.ENRI
            CASE AF1
                EB.SystemTables.setRNew(AF1, EB.SystemTables.getComi())
                YENRI.FLD = AF1 ; YENRI = EB.SystemTables.getComiEnri()
                GOSUB SET.UP.ENRI
        END CASE
    END
    RETURN
*
************************************************************************
*
SET.UP.ENRI:
*
    LOCATE YENRI.FLD IN EB.SystemTables.getTFieldno()<1> SETTING YPOS THEN
*         T.ENRI<YPOS> = YENRI
    END
    RETURN
*
************************************************************************
*
INITIALISE:
*
    RETURN
*
************************************************************************
*
* BG_100013036 - S
*================
CHECK.SUB.VALUES:
*================
    NO.OF.AV = DCOUNT(EB.SystemTables.getRNew(EB.SystemTables.getAf()), @VM)
    IF NO.OF.AV = 0 THEN
        NO.OF.AV = 1
    END
    FOR I = 1 TO NO.OF.AV
        EB.SystemTables.setAv(I)
        NO.OF.SV = DCOUNT(EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv()>, @SM)
        IF NO.OF.SV = 0 THEN
            NO.OF.SV = 1
        END
        FOR K = 1 TO NO.OF.SV
            EB.SystemTables.setAs(K)
            GOSUB DO.CHECK.FIELD
        NEXT K
    NEXT I
    RETURN
************************************************************************
*===================
CHECK.MULTI.VALUES:
*===================
    EB.SystemTables.setAs('')
    NO.OF.AV = DCOUNT(EB.SystemTables.getRNew(EB.SystemTables.getAf()), @VM)
    IF NO.OF.AV = 0 THEN
        NO.OF.AV = 1
    END
    FOR I = 1 TO NO.OF.AV
        EB.SystemTables.setAv(I)
        GOSUB DO.CHECK.FIELD
    NEXT I
    RETURN          ;* BG_100013036 - E
************************************************************************
    END
