* @ValidationCode : MjoxNzkzNzA5NTYyOkNwMTI1MjoxNjA0ODM3NTAxMDI1OnJkZWVwaWdhOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDkuMjAyMDA4MjgtMTYxNzoxMToxMQ==
* @ValidationInfo : Timestamp         : 08 Nov 2020 17:41:41
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 11/11 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.BASE.RECORD(TXN.ID,TXN.REC,MAPPING.REC,MAPPING.ID,TXN.IDS,TXN.BASE.RECS,APPL.MODE)
*-----------------------------------------------------------------------------
* This routine will update the Transaction Base record SCDX.ARM.MIFID.DATA
* after mapping done using TX.TXN.BASE.MAPPING
* Attached as the link routine in TX.TXN.BASE.MAPPING for updation in
* Database SCDX.ARM.MIFID.DATA
* Parameters:
*************
* TXN.ID            -   Transaction ID of the contract.
* TXN.REC           -   A dynamic array holding the contract.
* MAPPING.ID        -   Transaction Base id
* MAPPING.REC       -   Updated Transaction base record
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 22/10/2020 - SI - 3754772 / ENH - 3994136 / TASK - 3994144
*              TRS Reporting / Mapping Routines
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Inserts and control logic</desc>
    $USING EB.API
    $USING EB.SystemTables

    
*** </region>
*-----------------------------------------------------------------------------

    GOSUB INITIALISE    ; *Initialise the variables required for processing
    GOSUB PROCESS       ; *Process to update the Transaction Base record
           
RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the variables required for processing </desc>

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
PROCESS:
*** <desc>Process to update the Transaction Base record for reporting purpose </desc>
    
* Get the field position of SUBMISSION.ID from the SS Of SCDX.ARM.MIFID.DATA
    SS.ID = 'SCDX.ARM.MIFID.DATA' ; SS.REC = ''
    EB.API.GetStandardSelectionDets(SS.ID,SS.REC)

* Update the submission id with Transaction base id
    LOCATE 'SUBMISSION.ID' IN SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName,1> SETTING POS THEN
        FIELD.POS = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo,POS>
        MAPPING.REC<FIELD.POS> = MAPPING.ID
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
