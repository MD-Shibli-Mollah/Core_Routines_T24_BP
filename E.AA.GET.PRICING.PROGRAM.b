* @ValidationCode : MjoxNDc2ODA4MTE3OkNwMTI1MjoxNTY1MjY1ODI3MTE5OnZrcHJhdGhpYmE6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwNy4yMDE5MDUzMS0wMzE0Ojg6OA==
* @ValidationInfo : Timestamp         : 08 Aug 2019 17:33:47
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vkprathiba
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 8/8 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190531-0314
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.PRICING.PROGRAM
*-----------------------------------------------------------------------------
*<region name= subroutine Description>
*<desc>To Give the Purpose of the subroutine </desc>
*
* This Api is used to return the Pricing Program concatenated with the name 'AA.PRICING.PROGRAM'
* Accepts PricingProgram Value as : ACCOUNT.PRICING
* Returns AA.PRICING.PROGRAM*ACCOUNT.PRICING
*
* @uses I_ENQUIRY.COMMON
* @class AA.ModelBank
* @package retaillending.AA
* @stereotype subroutine
* @author vkprathiba@temenos.com
*
*</region>
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>Input and output arguments required for the sub-routine</desc>
*
*** </region>
*-----------------------------------------------------------------------------
* Modification History :
*
*  24/05/19 - Task  : 3122114
*             Enhan : 3146732
*             Routine to return the Pricing Program name along with a name 'AA.PRICING.MANAGER'.
*             Since, New browser has issue in returing PricingProgram name if it is a multivalue field
*-----------------------------------------------------------------------------
** <region name = inserts>

    $USING EB.Reports

*** </region>
*-----------------------------------------------------------------------------
*** <region name = Process Logic>
*** <desc>Program Control</desc>

    GOSUB ConcatenateValue      ;* Raise the actual value from TM to SM and pass to out data
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= ConcatenateValue>
*** <desc>Concatenate the Pricing Program field value with a name </desc>
ConcatenateValue:
    
    ActualValue = ''
    ActualValue = EB.Reports.getOData()    ;* Get OData
    IF ActualValue THEN
        EB.Reports.setOData('AA.PRICING.PROGRAM':'*':ActualValue)    ;* Set OData with concatenated value
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
