* @ValidationCode : Mjo5MDQ1MzgwMTQ6Q3AxMjUyOjE1NTM3Nzg0ODA0NjE6cnRhbmFzZToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTA0LjIwMTkwMzEwLTA0MTI6MTIwOjExMg==
* @ValidationInfo : Timestamp         : 28 Mar 2019 15:08:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rtanase
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 112/120 (93.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201904.20190310-0412
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AO.Framework
SUBROUTINE AA.E.NOFILE.PRIVILEGES.CONDITIONS(returnData)
*-----------------------------------------------------------------------------
* This nofile routine is build to extract information from the product condition of TC.PRIVILEGES property class.
* For each service/operation, it will be read from TC.SERVICES the dependent services/operations
* The routine is used in SS record NOFILE.AA.API.PRIVILEGES.CONDITIONS, which is called by the enquiry AA.API.NOF.PRIVILEGES.CONDITIONS.1.0.0.
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Changes done to the sub-routine</desc>
* Modification History :
*
* 31-Jan-2019 - Enh 2875458 / Task 2907647
*               IRIS R18 TCUA
*
* 28-Mar-2019 - Enh 2875458 / Task 3017765
*               To convert blank to No for the 4 fields - service/operation Active/Mandatory
*
*** </region>
*-----------------------------------------------------------------------------
    $USING AO.Framework
    $USING AA.Framework
    $USING AA.ProductFramework
    $USING EB.Reports
*-----------------------------------------------------------------------------
    GOSUB initialise                  ;* Initialise variables
    GOSUB process                     ;* Main process
*
RETURN
*-----------------------------------------------------------------------------
*** <region name= initialise>
*** <desc>Initialise Required variables</desc>
initialise:
*
    returnData=""
*
    propertyId = "TC.PRIVILEGES"    ;* this routine it is used only for TC.PRIVILEGES property class
    privilegePrdCondRecord = ""

    LOCATE "PRODUCT.ID" IN EB.Reports.getDFields()<1> SETTING fieldPos THEN
        productId = EB.Reports.getDRangeAndValue()<fieldPos> ;* Get the value completed in productId field (which is mandatory selection field in the enquiry.
    END
*
    serviceNameArr=""        ;* the array with serviceName for all services
    operationNameArr=""      ;* the array with operationName for all operations of all services
    opNameList=""            ;* the list with operation names, for all the operations of a service
*
    mandatoryServiceArr=""   ;* the array with mandatory status of the service, for all the services
    mandatoryOperationArr="" ;* the array with mandatory status of the operations, for all the operations of all services
    mandatoryOpList=""       ;* the list with mandatory status, for all the operations of a service
*
    dependentServiceArr=""   ;* the array with dependent services, for all the operations of all services
    dependentOperationArr="" ;* the array with dependent operations, for all the operations of all services
    dependentSrvList=""      ;* list with dependent services of the current operation
    dependentOpList=""       ;* list with dependent operations of the current operation
*
RETURN
*** <region>
*-----------------------------------------------------------------------------
*** <region name= process>
*** <desc>Main process</desc>
process:
*
    GOSUB getProductConditionDefinition  ;* get the product conditions configured for the product
    GOSUB readTcServicesRecord           ;* read TcServices record, for each service defined in the Privilege product condition
*
RETURN
*** <region>
*-----------------------------------------------------------------------------
*** <region name= getProductConditionDefinition>
*** <desc>Get the definition of Product Condition for the Product specified in selection fields of the enquiry.</desc>
getProductConditionDefinition:
    currency = ''                                                                                   ;* Currency
    effectiveDate = ''                                                                              ;* Effective Date
    outPropertyList = ''                                                                            ;* Property List
    outPropertyClassList = ''                                                                       ;* Property Class List
    outArrangementLinkType = ''                                                                     ;* Arrangement Link Type
    outPropertyConditionList = ''                                                                   ;* Property Condition List
    retErr = ''                                                                                     ;* Error Return
    aaProduct = productId                                                                           ;* AA Product ID received as parameter
    AA.ProductFramework.GetProductConditionRecords(aaProduct, currency, effectiveDate, outPropertyList, outPropertyClassList, outArrangementLinkType, outPropertyConditionList, retErr) ;* get the product conditions configured for the product
    LOCATE propertyId IN outPropertyClassList SETTING pos THEN
        privilegePrdCondRecord = RAISE(outPropertyConditionList<pos>)                                      ;* product condition record of Privilege property class
*
        servicesList = privilegePrdCondRecord<AO.Framework.TcPrivileges.AaTcPrivService>                   ;* Service field from product condition - list of services
        servicesActiveList = privilegePrdCondRecord<AO.Framework.TcPrivileges.AaTcPrivServiceActive>       ;* ServiceActive field from product condition
        operationsList = privilegePrdCondRecord<AO.Framework.TcPrivileges.AaTcPrivOperation>               ;* Operation field from product condition - list of operations for each service
        operationsActiveList = privilegePrdCondRecord<AO.Framework.TcPrivileges.AaTcPrivOperationActive>   ;* OperationActive field from product condition
*
    END
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= readTcServicesRecord>
*** <desc>For each serviceID found in product condition, read TC.SERVICES record</desc>
readTcServicesRecord:
    countServices =  DCOUNT(servicesList,@VM)        ;* count the services contained in the  Service field of product condition record
    FOR servicePos = 1 TO countServices              ;* for each service present in product condition, search the record in TC.SERVICES
        serviceId = servicesList<1,servicePos>             ;* extract current serviceID from list of services from product condition
        serviceActive = servicesActiveList<1,servicePos>   ;* extract serviceActive information of current serviceID, from product condition
        IF serviceActive EQ '' THEN
            serviceActive = 'No'
        END
        serviceOpsList = operationsList<1,servicePos>      ;* extract operations list of current serviceID, from product condition
        serviceOpsActiveList = operationsActiveList<1,servicePos>  ;* extract operationActive listof current serviceID, from product condition
*
        tcServicesRecord = AO.Framework.TCServices.Read(serviceId, serviceErr) ;* Get the service record from TC.SERVICES table
*
        IF tcServicesRecord THEN                           ;* if service record is found
            serviceName = tcServicesRecord<AO.Framework.TCServices.TcSvcDescription>           ;* read the name of the current service
            mandatoryService = tcServicesRecord<AO.Framework.TCServices.TcSvcMandatorySvc>     ;* read if the current service is mandatory
            IF mandatoryService EQ '' THEN
                mandatoryService = 'No'
            END

            countSrvOpList = DCOUNT(serviceOpsList, @SM)          ;* count the operations of the current serviceID
            FOR srvOpPos = 1 TO countSrvOpList                    ;* for each operation
                oneSrvOperationId = serviceOpsList<1,1,srvOpPos>  ;* extract one operation of the current service, from product condition
                oneSrvOperationActive = serviceOpsActiveList<1,1,srvOpPos>    ;* extract active status for the current operation
                IF oneSrvOperationActive EQ '' THEN
                    oneSrvOperationActive = 'No'
                END
* search the position of this operation in TC.SERVICES record
                GOSUB getOpPositionInTcServRecord
                oneSrvOperationName = tcServicesRecord<AO.Framework.TCServices.TcSvcOperationDesc,posOpTCServRec>           ;* read current operation description from TC.SERVICES record
                oneSrvOperationMandatory = tcServicesRecord<AO.Framework.TCServices.TcSvcMandatoryOps,posOpTCServRec>       ;* read current operation mandatory status from TC.SERVICES record
                IF oneSrvOperationMandatory EQ '' THEN
                    oneSrvOperationMandatory = 'No'
                END
*
                GOSUB getDpndServicesAndOperations                ;* for current serviceID, read dependent services and operations from TC.SEVICES record
*
            NEXT srvOpPos
        END
    NEXT servicePos
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= getOpPositionInTcServRecord>
*** <desc>get current Operation position in TC.SERVICES record</desc>
getOpPositionInTcServRecord:
    tcServicesOperationIds = tcServicesRecord<AO.Framework.TCServices.TcSvcOperation>                           ;* extract OperationId field from TC.SERVICES record
    countOpsInTCServRecord = DCOUNT(tcServicesOperationIds, @VM)                                                ;* count the operations TC.SERVICES record
    FOR posOpTCServRec = 1 TO countOpsInTCServRecord
        IF tcServicesRecord<AO.Framework.TCServices.TcSvcOperation,posOpTCServRec> EQ oneSrvOperationId THEN    ;* if operationID from product codnition is equal with operationID in TC.SWERVICES record
            BREAK         ;* stop looping; the position of opertionID in the TC.SERVICES record is set in posOpTCServRec
        END
    NEXT posOpTCServRec
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= getDpndServicesAndOperations>
*** <desc>For current serviceID/operationID, get dependent services and operations from TC.SERVICES record</desc>
getDpndServicesAndOperations:
    oneDpndSrv=""
    oneDpndOp=""
    operationSrvRecord = tcServicesRecord<AO.Framework.TCServices.TcSvcOperation>   ;* read Operation field from TC.SERVICES record
    CHANGE @VM TO @FM IN operationSrvRecord                                         ;* changing of delimiter is necessary for LOCATE

    LOCATE oneSrvOperationId IN operationSrvRecord SETTING opPos THEN               ;* search the current operation, in operation field of service record.
        dpndSvField = ""
        dpndOpField = ""
        IF tcServicesRecord<AO.Framework.TCServices.TcSvcDependentSvc,opPos> NE "" THEN  ;* if a dependent service is defined for the current operation
            dpndSvField = tcServicesRecord<AO.Framework.TCServices.TcSvcDependentSvc,opPos>           ;* read dependent service field
            dpndOpField  = tcServicesRecord<AO.Framework.TCServices.TcSvcDependentOps,opPos>          ;* read dependent operation field
                    
            countDpndSrvOps = DCOUNT(dpndSvField,@SM)  ;* it is possible for an operation to have dependency on more services/operations. count the number of dependent services/operations
            FOR depndtSrvOpPos = 1 TO countDpndSrvOps                    ;* for each dependent service/operation
                oneDpndSrv = FIELD(dpndSvField,@SM,depndtSrvOpPos)
                oneDpndOp  = FIELD(dpndOpField,@SM,depndtSrvOpPos)
                
                GOSUB constructOutputArray                                              ;* generate outputData for the case when the operation has a dependent service/op

            NEXT depndtSrvOpPos
        END ELSE
            GOSUB constructOutputArray                                                  ;* generate outputData for the case when the operation does not have a dependent service/op
        END
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= constructOutputArray>
*** <desc>construct output array</desc>
constructOutputArray:
*
    BEGIN CASE
* the oeration has dependent services/ops (dpndSvField NE "")
        CASE dpndSvField NE "" AND srvOpPos EQ 1 AND servicePos EQ 1                             ;* it is the first operation, it is the first service.
            returnData<-1> = serviceId:"*":serviceName:"*":mandatoryService:"*":serviceActive:"*":oneSrvOperationId:"*":oneSrvOperationName:"*":oneSrvOperationMandatory:"*":oneSrvOperationActive:"*":oneDpndSrv:"*":oneDpndOp:"*":productId:"*":propertyId
        CASE dpndSvField NE "" AND srvOpPos EQ 1 AND servicePos NE 1                             ;* it is the first operation, it is not the first service.
            returnData<-1> = serviceId:"*":serviceName:"*":mandatoryService:"*":serviceActive:"*":oneSrvOperationId:"*":oneSrvOperationName:"*":oneSrvOperationMandatory:"*":oneSrvOperationActive:"*":oneDpndSrv:"*":oneDpndOp:"*":"":"*":""
*
        CASE dpndSvField NE "" AND srvOpPos NE 1 AND depndtSrvOpPos EQ 1                         ;* it is not the first operation, it is the first dependent service.
            returnData<-1> =                                          "":"*":"":"*":"":"*":"":"*":oneSrvOperationId:"*":oneSrvOperationName:"*":oneSrvOperationMandatory:"*":oneSrvOperationActive:"*":oneDpndSrv:"*":oneDpndOp:"*":"":"*":""
        CASE dpndSvField NE "" AND srvOpPos NE 1 AND depndtSrvOpPos NE 1                         ;* it is not the first operation, it is not the first dependent service.
            returnData<-1> =                                                                                                                   "":"*":"":"*":"":"*":"":"*":"":"*":"":"*":"":"*":"":"*":oneDpndSrv:"*":oneDpndOp:"*":"":"*":""
*
* the oeration does not have dependent service/op (dpndSvField EQ "")
        CASE dpndSvField EQ "" AND srvOpPos EQ 1 AND servicePos EQ 1                             ;* it is the first operation, it is the first service.
            returnData<-1> = serviceId:"*":serviceName:"*":mandatoryService:"*":serviceActive:"*":oneSrvOperationId:"*":oneSrvOperationName:"*":oneSrvOperationMandatory:"*":oneSrvOperationActive:"*":"":"*":"":"*":productId:"*":propertyId
        CASE dpndSvField EQ "" AND srvOpPos EQ 1 AND servicePos NE 1                             ;* it is the first operation, it is not the first service.
            returnData<-1> = serviceId:"*":serviceName:"*":mandatoryService:"*":serviceActive:"*":oneSrvOperationId:"*":oneSrvOperationName:"*":oneSrvOperationMandatory:"*":oneSrvOperationActive:"*":"":"*":"":"*":"":"*":""
        CASE dpndSvField EQ "" AND srvOpPos NE 1                                                 ;* it is not the first operation.
            returnData<-1> =                                          "":"*":"":"*":"":"*":"":"*":oneSrvOperationId:"*":oneSrvOperationName:"*":oneSrvOperationMandatory:"*":oneSrvOperationActive:"*":"":"*":"":"*":"":"*":""
    END CASE
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
