* @ValidationCode : MjotMTEyNDUwNjUzMTpDcDEyNTI6MTU1ODQ0MDcyMjcyMTpnYXlhdGhyaWs6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwNC4yMDE5MDMyMy0wMzU4OjY6Ng==
* @ValidationInfo : Timestamp         : 21 May 2019 17:42:02
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : gayathrik
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 6/6 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201904.20190323-0358
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.ACTUAL.VALUE
*-----------------------------------------------------------------------------
*** <region name = Program Description>
*** <desc>Purpose of the sub-routine</desc>
*
***   This API is used to convert the TM to SM in actual value and send it to out data for display
*
*** </region>
*-----------------------------------------------------------------------------
* @uses         :
* @access       : private
* @stereotype   : subroutine
* @author       : gayathrik@temenos.com
*-----------------------------------------------------------------------------
*** <region name = Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
*** Arguments
*
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name = Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History :
*
* 07/02/18 - Defect : 3122133
*            Task : 3137982
*            When actual value has values seperated by TM convert TM to SM to display the records
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Common variables and file inserts</desc>
* Inserts

    $USING EB.Reports
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name = Process Logic>
*** <desc>Program Control</desc>

    GOSUB GetActualValue      ;* Raise the actual value from TM to SM and pass to out data
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetActualValue>
*** <desc>Raise the actual value from TM to SM </desc>
GetActualValue:
    
    ActualValue = EB.Reports.getOData()    ;* Get OData
    OutActualValue = RAISE(ActualValue)    ;* Raise TM to SM
    EB.Reports.setOData(OutActualValue)    ;* Set OData with converted actual value
     
RETURN
*** </region>
*-----------------------------------------------------------------------------
END

