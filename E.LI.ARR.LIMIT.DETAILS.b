* @ValidationCode : MjoxMjQ4NjQ5Njg0OkNwMTI1MjoxNTg4MTUwMzkzNjcyOmhhcmlrcmlzaG5hbms6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNS4yMDIwMDQxNy0xNTQyOjI3OjI3
* @ValidationInfo : Timestamp         : 29 Apr 2020 14:23:13
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : harikrishnank
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 27/27 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202005.20200417-1542
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE LI.ModelBank
SUBROUTINE E.LI.ARR.LIMIT.DETAILS(EnqData)
*-----------------------------------------------------------------------------
* Company Name   : TEMENOS
* Developed By   : manisekarankar@temenos.com
* Program Name   : E.LI.ARR.LIMIT.DETAILS
* Module Name    : LI
* Component Name : LI_ModelBank
*-----------------------------------------------------------------------------
* Description    : Build routine which would return the selection of Limit ID based
*                  on the selection criteria i.e. Arrangement id / Limit id itself
*-----------------------------------------------------------------------------
* Modification History :
*
* 03/01/2010 - Enhancement / Task
*              Build routine which will be attached in File enquriy, to display
*              limit details.
*
* 29/04/2020 - Defect 3680741 / Task 3718935
*              Fetch Validation Limit from Limit Property of arrangement
*
*-----------------------------------------------------------------------------
    $USING LI.ModelBank
    $USING EB.Reports
    $USING EB.SystemTables
    $USING AA.Framework
    $USING AA.Limit
    $USING LI.Config
*-----------------------------------------------------------------------------
    GOSUB Initialise
    GOSUB CheckEnqData
RETURN
*-----------------------------------------------------------------------------
Initialise:
*----------
    ArrangementId = ''
    LimitId = ''
    SelectionPos = ''
    SelectionId = ''
    EffectiveDate = ''
    PropertyClass = ''
RETURN
*-----------------------------------------------------------------------------
CheckEnqData:
*------------
    LOCATE "@ID" IN EnqData<2,1> SETTING SelectionPos THEN
        SelectionId = EnqData<4,SelectionPos> ;* Can be either arrangement id or limit id.
    END
    
    IF SelectionId[1,2] EQ 'AA'  THEN;* Passed id is an arrangement Id

* Fetch the limit id using GET.ARRANGEMENT.CONDITIONS with PROPERTY.CLASS as LIMIT

        EffectiveDate = EB.SystemTables.getToday()
        RArrLimit = ""
        RetError = ""
        ArrangementId = SelectionId
        PropertyClass = "LIMIT"
        AA.Framework.GetArrangementConditions(ArrangementId, PropertyClass, "", EffectiveDate, "", RArrLimit, RetError) ;* Get the Arrangement Limit condition setup
        RArrLimit = RAISE(RArrLimit)
        LimitId = RArrLimit<AA.Limit.Limit.LimValidationLimit>
* Change the selection to LIMIT.ID so that limit details be displayed.
        IF LimitId THEN
            EnqData<4,SelectionPos> = LimitId
        END
                   
    END
RETURN
*-----------------------------------------------------------------------------
END
