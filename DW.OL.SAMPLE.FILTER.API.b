* @ValidationCode : MjoyMDk2OTMwMDE4OkNwMTI1MjoxNTY4NjA0NjIwNTU5OmNuaXZldGhhZGV2aTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDkuMTotMTotMQ==
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

$PACKAGE DW.BiExport
SUBROUTINE DW.OL.SAMPLE.FILTER.API(AppName, T.BI.ID , rRecordImage, SkipAll)
*______________________________________________________________________________________
*
* Incoming Parameters:
* -------------------

*    AppName   - Parent application of the transaction
*    T.BI.ID   - Record id of the child application
*    rRecordImage - Work file record image

* Outgoing Parameters:
* --------------------

*    T.BI.ID   - If filtered out return null, else return T.BI.ID
*    SkipAll - 'SKIPALL' to skip all the records in transaction, else return empty

* Program Description:
* --------------------
*     API for handling filtering of records before committing to the work file
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

    
    
    GOSUB INITIALISE ;*Initialise the variables
    GOSUB FILTER.IDS ;*Implement the filtering logic
    
INITIALISE:
    
* Initialise all the required local variables
    PROCESS.VALUES = ''
    FIELD.NAMES = ''
    DELIM = '~'
    
* OPF for AppName can be done
    FN.FILE.NAME = 'F.':AppName
    F.FILE.NAME = ''
    EB.DataAccess.Opf(FN.FILE.NAME, F.FILE.NAME)
        
RETURN


FILTER.IDS:

*   rRecordImage will be available in the format "rec1~rec2~rec3"

*   Implement the filtering logic here

*   This sample filter routines allows only netted entries from respective categ, stmt and spec entries
    IF T.BI.ID[1,2] NE 'S!' AND T.BI.ID[1,2] NE 'C!' AND T.BI.ID[1,2] NE 'R!' THEN
        T.BI.ID = ''
    END

*   Also, if the parent application of the transaction is FUNDS.TRANSFER,
*   then the whole transaction is skipped and not written to work file
    IF T.BI.ID EQ '' AND AppName EQ 'FUNDS.TRANSFER' THEN
        SkipAll = 'SKIPALL'
    END ELSE
        SkipAll = ''
    END



RETURN
END
