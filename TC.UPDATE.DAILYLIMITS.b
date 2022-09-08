* @ValidationCode : MjoyMDY3Nzk2NDkxOkNwMTI1MjoxNTc4NjY4MTEyMDE5OnNtdWdlc2g6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkxMC4yMDE5MDkyMC0wNzA3OjEwNzoxMDA=
* @ValidationInfo : Timestamp         : 10 Jan 2020 20:25:12
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smugesh
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 100/107 (93.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
$PACKAGE AO.Framework
SUBROUTINE TC.UPDATE.DAILYLIMITS(SubarrangementId,OfsArrActivityRecord)
*-----------------------------------------------------------------------------
* This routine is called from AA.TC.PRIVILEGES.UPDATE.SUBARR
* Routine used for Master Update validations, for Protection Limit property, in order to update sub-arrangements
* The routine include changes for Protection Limit into AA.Arrangement.Activity record that will be sent with OFS message
*-----------------------------------------------------------------------------
* In/out parameters:
* SubarrangementId - string, INOUT
* OfsArrActivityRecord - string, INOUT
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Changes done to the sub-routine</desc>
* Modification History:
*
* 12/02/2018 - Enhancement 2379129 / Task 2433777
*              Master update validations for Protection Limit
*
* 22/05/18 - Enhancement 2587968 / Task 2633901
*            TCUA - Extensions to Sub Arrangements - rebuild the external variables based on the flag from AA.ARRANGEMENT.EXTUSER table
*
* 04/01/20 - Enhancement 3504695 / Task 3521090
*            TCIB Limit Authorisation Enhancement changes - Add the customer limit fields in OFS message with validation
*** </region>
*-----------------------------------------------------------------------------
    $USING AO.Framework
    $USING AA.Framework
    $USING AA.ARC
    $USING AA.ProductFramework
    $USING EB.SystemTables
*-----------------------------------------------------------------------------
    GOSUB Initialise
    GOSUB Process
RETURN
*-----------------------------------------------------------------------------
Process:
    GOSUB GetMasterArrangementLimitData
    GOSUB GetSubArrangementLimitData
    GOSUB DoLimitValidations
RETURN
*-----------------------------------------------------------------------------
GetMasterArrangementLimitData:
*   get data for master arrangement record, to read new Limit Amount
    masterArrangementId = AA.Framework.getArrId()
    effectiveDate = AA.Framework.getPropEffDate()
    aaProperyClassId = 'PROTECTION.LIMIT'
    protectionLimitRec=''
    newLimitAmount=''
    retErr = ''
    AA.ProductFramework.GetPropertyRecord('', masterArrangementId, '', '', aaProperyClassId, '', protectionLimitRec, retErr)
    IF retErr EQ '' AND protectionLimitRec NE '' THEN
        newLimitAmount = protectionLimitRec<AA.ARC.ProtectionLimit.PrctLimitAmount>
        masCusMaxLimit = protectionLimitRec<AA.ARC.ProtectionLimit.PrctCustomerMaxLimit>
        masDefinedCustomers = protectionLimitRec<AA.ARC.ProtectionLimit.PrctDefinedCustomer>
        masCustomerLimits = protectionLimitRec<AA.ARC.ProtectionLimit.PrctCustomerLimit>
    END
RETURN
*-----------------------------------------------------------------------------
GetSubArrangementLimitData:
*   get data for current SubarrangementId received in Input variable, to read sub arrangement Limit Amount
    aaPropertyClassId = 'PROTECTION.LIMIT'
    propertyIds = ''
    propertyRecords = ''
    retErr = ''
    AA.Framework.GetArrangementConditions(SubarrangementId, aaPropertyClassId, '', '', propertyIds, propertyRecords, retErr)      ;* Get arrangement condition for Protection Limit Property class
    IF retErr EQ '' AND propertyRecords NE '' THEN
        subArrLimitAmount = propertyRecords<1,AA.ARC.ProtectionLimit.PrctLimitAmount>
        subArrCusMaxLimit = propertyRecords<1,AA.ARC.ProtectionLimit.PrctCustomerMaxLimit>
        subArrDefinedCustomers = propertyRecords<1,AA.ARC.ProtectionLimit.PrctDefinedCustomer>
        subArrCustomerLimits = propertyRecords<1,AA.ARC.ProtectionLimit.PrctCustomerLimit>
        
        subArrDefinedCustomers = RAISE(subArrDefinedCustomers);
        subArrCustomerLimits = RAISE(subArrCustomerLimits);
    END
RETURN
*-----------------------------------------------------------------------------
DoLimitValidations:
* compare the existing sub arrangement Limit Amount value with new master Limit Amount value
    masterLevelFlag = '';
    IF newLimitAmount LT subArrLimitAmount THEN
*       the new Limit Amount in master is lower value
        GOSUB updateMasterLevel

        OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countV,countFieldName> = "LIMIT.AMOUNT"
        OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countV,countFieldName> = newLimitAmount
        
        countFieldName = countFieldName + 1 
    END
    
*Check master customer max limit amount and sub cus max limit amount
 
    IF masCusMaxLimit LT subArrCusMaxLimit THEN
        IF masterLevelFlag NE "UPDATED" THEN
            GOSUB updateMasterLevel
        END
        cusMaxLimitUpdated = "YES"
        OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countV,countFieldName> = "CUSTOMER.MAX.LIMIT"
        OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countV,countFieldName> = masCusMaxLimit
        countFieldName = countFieldName + 1
    END
    
*Check each customer and update the restricted changes :
    totalCustomers = DCOUNT(subArrDefinedCustomers, @VM);
    IF NOT(totalCustomers) THEN
        totalCustomers = DCOUNT(subArrCustomerLimits, @VM)
    END
    
    FOR CNT=1 TO totalCustomers
        subArrCustomer = subArrDefinedCustomers<1,CNT>
        LOCATE subArrCustomer IN masDefinedCustomers<1,1> SETTING cusPos THEN
            subArrCustomerLimit = subArrCustomerLimits<1,CNT>
            masCustomerLimit = masCustomerLimits<1,cusPos>
            IF masCustomerLimit LT subArrCustomerLimit AND masCustomerLimit NE '' THEN ;*If limit is less then update the limit in exact position
                IF masterLevelFlag NE "UPDATED" THEN
                    GOSUB updateMasterLevel
                END
                OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countV,countFieldName> = "CUSTOMER.LIMIT:":CNT:":1"
                OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countV,countFieldName> = masCustomerLimit
                countFieldName = countFieldName + 1
            
            END ELSE
                IF subArrCustomerLimit NE '' AND masCustomerLimit EQ '' THEN  ;*If limit validated against sub cus max limit then update with mas cus max limit
                    IF masterLevelFlag NE "UPDATED" THEN
                        GOSUB updateMasterLevel
                    END
                    IF cusMaxLimitUpdated EQ "YES" AND subArrCustomerLimit GT masCusMaxLimit THEN
                        OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countV,countFieldName> = "CUSTOMER.LIMIT:":CNT:":1"
                        OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countV,countFieldName> = masCusMaxLimit
                        countFieldName = countFieldName + 1
                    END
                END
            END
        END
    NEXT CNT

*The new Limit Amount in master is higher value
    IF masterLevelFlag EQ '' THEN
        masterLvl = "AUGMENTED-"
        GOSUB PropertyUpdate
    END
RETURN
*-----------------------------------------------------------------------------
updateMasterLevel:
    
*Update master level change and flag
    masterLvl = "RESTRICTED-"
    GOSUB PropertyUpdate
    masterLevelFlag = "UPDATED";
    
RETURN
*-----------------------------------------------------------------------------
PropertyUpdate:
*   include Protection Limit details into AA.Arrangement.Activity record that will be sent with OFS message
    tempDate = OCONV(DATE(),'D-')
    tempDate = tempDate[7,4]:tempDate[1,2]:tempDate[4,2]
    tempTime =  OCONV(TIME(),'MTS')
    tempTime = tempTime[1,2]:tempTime[4,2]
    timeStamp = tempDate:tempTime
    IF OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActProperty> NE "" THEN
        countV=DCOUNT(OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActProperty>, @VM)
    END

    OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActProperty,countV> = "DAILYLIMITS"
        
    OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldName,countV,countFieldName> = "MASTER.LVL.CHANGE:1:1"
    OfsArrActivityRecord<AA.Framework.ArrangementActivity.ArrActFieldValue,countV,countFieldName> = masterLvl:timeStamp
    countFieldName = countFieldName + 1
RETURN
*-----------------------------------------------------------------------------
Initialise:
    countV=1
    countFieldName=1
    masterLvl=''
RETURN
*-----------------------------------------------------------------------------
END
