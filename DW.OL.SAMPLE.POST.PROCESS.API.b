* @ValidationCode : MjoxNjc1NzAxNjI0OkNwMTI1MjoxNTY4NjA0NjIwNTcxOmNuaXZldGhhZGV2aTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDkuMTotMTotMQ==
* @ValidationInfo : Timestamp         : 16 Sep 2019 09:00:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : cnivethadevi
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201909.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-60</Rating>
*-----------------------------------------------------------------------------
$PACKAGE DW.BiExport
SUBROUTINE DW.OL.SAMPLE.POST.PROCESS.API(BI.FILE.NAME, rDwExport, rDwExportApi, T.BI.ID, rRecordImage, rProcessedValue)
*______________________________________________________________________________________
*
* Incoming Parameters:
* -------------------

*    BI.FILE.NAME   - Current processing file name
*    rDwExport    - DW.EXPORT record for BI.FILE.NAME
*    rDwExportApi - DW Export API record for BI.FILE.NAME:PROCESS
*    T.BI.ID   - Record id of the BI.FILE.NAME
*    rRecordImage - Record image

* Outgoing Parameters:
* --------------------

*    rProcessedValue - Record to be added to the full record image

* Program Description:
* --------------------
*     API for handling additional processing of transaction during the online service
* Modification History:
*----------------------
*
* 11/07/2019 - Task 3159706 / Enhancement 3130181
*              DW - Online & Online Intra framework for APIs (Process, Filter, Transform)
*
* Inserts:
*----------------------
* Insert files can be added here
    $USING EB.DataAccess
    $USING DW.BiExportFramework


    GOSUB INITIALISE ;*Initialise the variables
    GOSUB PROCESS ;*Implement the processing logic

RETURN


INITIALISE:
    
* Initialise all the required local variables
    PROCESS.VALUES = ''
    FIELD.NAMES = ''
    DELIM = @FM
    
* OPF for BI.FILE.NAME can be done
    FN.FILE.NAME = 'F.':BI.FILE.NAME
    F.FILE.NAME = ''
    EB.DataAccess.Opf(FN.FILE.NAME, F.FILE.NAME)

RETURN


PROCESS:

*   rRecordImage will be available in the format "field1@FMfield2@FMfield3..."
    
    FOR I=1 TO 10
*       Additional processing
        INCR += 1
        PROCESS.VALUES<-1> = 'PostProcess_Field_number_':INCR
    NEXT I
    
*   rProcessedValue should be returned with the new records delimited by @FM for every new field'
    CALL DW.RECORD.SANITY.CHECK(PROCESS.VALUES)
    rProcessedValue = PROCESS.VALUES
    
    

RETURN

END
