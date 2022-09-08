* @ValidationCode : Mjo4NzM1NDUyODg6Q3AxMjUyOjE1NjQ1NjMyMjI2NTA6c3JhdmlrdW1hcjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDcuMjAxOTA2MTItMDMyMTotMTotMQ==
* @ValidationInfo : Timestamp         : 31 Jul 2019 14:23:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190612-0321
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AC.StmtPrinting
SUBROUTINE AC.STMT.LINES.WRITE(recId, record,suffix)
*-----------------------------------------------------------------------------
* This routine performs Write operation on file AC.STMT.LINES
*-----------------------------------------------------------------------------
* Modification History :
* 30/07/2019 - Enhancement 3246717 / Task 3181742
*              TI Changes - Component moved from ST to AC.
*
*-----------------------------------------------------------------------------
    $USING AC.StmtPrinting
    $USING EB.SystemTables

    GOSUB globalValidate ; *Validating the incoming arguments
    IF validationError EQ 1 THEN
        RETURN ;*No point in going further
    END
    GOSUB tableValidate ; *Validation specific to this table
    IF validationError EQ 1 THEN
        RETURN
    END
    GOSUB tableOperation ; *Do the Operation they wanted and return back

RETURN
    
*** <region name= validate>
globalValidate:
*** <desc>Validating the incoming arguments </desc>
    validationError = 0 ;*Start with the assummption that there wont be any errors
    tabOperation = 3 ; *write operation
    retValue = ''
    EB.SystemTables.ValidateTableUpdate(recId,tabOperation,record,'',retValue)
    IF retValue NE '' THEN
        validationError = 1
    END


RETURN

*** </region>


*-----------------------------------------------------------------------------

*** <region name= tableValidate>
tableValidate:
*** <desc>Validation specific to this table </desc>
*No validation for now but we can do validation like no deletion possible .....
    validationError = 0
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= tableOperation>
tableOperation:
***<desc> Call Write operation on file AC.STMT.LINES </desc>

    AC.StmtPrinting.AcStmtLines.Write(recId, record)
RETURN
*** </region>
END
