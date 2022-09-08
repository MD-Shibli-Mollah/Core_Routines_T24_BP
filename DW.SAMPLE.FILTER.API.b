* @ValidationCode : MjotMTEyODczOTYyOTpDcDEyNTI6MTU2ODYwNDYyMDYwNjpjbml2ZXRoYWRldmk6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTA5LjE6LTE6LTE=
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
SUBROUTINE DW.SAMPLE.FILTER.API(T.BI.ID)
*______________________________________________________________________________________
*
* Incoming Parameters:
* -------------------

*    T.BI.ID   - Record id

* Outgoing Parameters:
* --------------------

*    T.BI.ID   - If filtered out return null, else return T.BI.ID

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
    GOSUB INITIALISE ;*Initialise the variables
    GOSUB FILTER.IDS ;*Implement the filteration logic
    
INITIALISE:
    
    LENGTH.ID = ''
    
RETURN


FILTER.IDS:
    
    LENGTH.ID = LEN(T.BI.ID)
    
*Condition to filer the ID - return null if ID is to be filtered, else return value
    IF LENGTH.ID GT 5 THEN
        T.BI.ID = ''
    END


RETURN
END
