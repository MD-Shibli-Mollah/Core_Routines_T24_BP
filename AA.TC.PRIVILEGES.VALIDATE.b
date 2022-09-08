* @ValidationCode : MjoyMDEwNDY1MjcxOkNwMTI1MjoxNTcxNzM3Nzc3NzA3OnN1ZGhhcmFtZXNoOjE3OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTEwLjIwMTkwOTIwLTA3MDc6NTcwOjQ3OA==
* @ValidationInfo : Timestamp         : 22 Oct 2019 15:19:37
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sudharamesh
* @ValidationInfo : Nb tests success  : 17
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 478/570 (83.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
$PACKAGE AO.Framework
SUBROUTINE AA.TC.PRIVILEGES.VALIDATE
*-----------------------------------------------------------------------------
* Description:
* Provides cross-validation of data entered in TC.PRIVILEGES property class
* at product designer and arrangement levels
*-----------------------------------------------------------------------------
* Modification History:
*
* 03/10/16 - Enhancement 1812222 / Task 1905849
*            Tc Privileges property class
* 16/06/2017 - Defect 2012008 / Task 2184329
*              Validations added/updated
* 09/01/2018 - Enhancement 2379129 / Task 238097 - SubArrangements validation for TC.PRIVILEGES when create or update
*
* 12/03/2018 - Defect 2484378 / Task 2499429 - Validations against dependencies from TC.SERVICES are not done properly
* Enhancement 2584357 / Task 2624936 - Arrangements validation against product conditions
*
*
* 13/09/18 -  Defect 2761187 / Task 2767024
*
*  21/10/19 - Enhancement : 2851854
*             Task : 3396231
*             Code changes has been done as a part of AA to AF Code segregation
*-----------------------------------------------------------------------------
*** <region name = Main section>
*** <desc>Main section</desc>

    $USING EB.SystemTables
    $USING AA.Framework
    $USING EB.ErrorProcessing
    $USING AO.Framework
    $USING EB.Template
    $USING EB.OverrideProcessing
	$USING AA.ProductFramework
    $USING AA.ARC
    $USING AF.Framework
    
    GOSUB Initialise
    GOSUB ProcessCrossVal

RETURN
*** </region>
    
*-----------------------------------------------------------------------------
*** <region name = Initialise>
*** <desc>Initialise local variables and file variables</desc>
Initialise:

    serviceAf = ''
    servicePos = ''
    operationPos = ''
    servicesCnt = ''
    operationsCnt = ''
    serviceId = ''
    servicesRec = ''
    servicesErr = ''
    operationActive = ''
    opPos = ''
	masterArrId = ''
* generalValidation flag will be set to False if the common validation dont pass, in this case the validation will not continue
	generalValidation = ''

RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name = Process Cross validation>
*** <desc>Cross validation stages</desc>
ProcessCrossVal:

    
    IF EB.SystemTables.getMessage() EQ '' THEN     ;* Only during commit...
        TEMP.V.FUN = EB.SystemTables.getVFunction()
        BEGIN CASE
            CASE TEMP.V.FUN EQ 'D'
            CASE TEMP.V.FUN EQ 'R'
            CASE 1      ;* The real crossval...
                GOSUB RealCrossVal
        END CASE
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name = Real Crossval>
*** <desc>Real Crossvalidation stages</desc>
RealCrossVal:

* Real cross validation goes here....
    TEMP.PROD.ARR = AF.Framework.getProductArr()
    TEMP.AA.PROD = AA.Framework.Product
    TEMP.AA.ARR = AA.Framework.AaArrangement
    BEGIN CASE
        CASE TEMP.PROD.ARR EQ TEMP.AA.PROD   ;* If its from the designer level
            GOSUB DesignerDefaults           ;* Ideally no defaults at the product level
        CASE TEMP.PROD.ARR EQ TEMP.AA.ARR    ;* If its from the arrangement level
            GOSUB ArrangementDefaults        ;* Arrangement defaults
    END CASE

	GOSUB CommonCrossVal


    BEGIN CASE
        CASE AF.Framework.getProductArr() EQ AA.Framework.Product
            GOSUB DesignerCrossVal          ;* Designer specific cross validations
        CASE AF.Framework.getProductArr() EQ AA.Framework.AaArrangement
		    IF generalValidation EQ '' THEN
				GOSUB ArrangementCrossVal       ;* Arrangement specific cross validations
			END
    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <desc>Do any defaults for Product designer here</desc>
DesignerDefaults:

    servicesCnt = DCOUNT(EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivService),@VM) ;* Get the count for services
    FOR servicePos = 1 TO servicesCnt

        IF EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivOperation)<1,servicePos> ELSE
            serviceId = EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivService)<1,servicePos>
            servicesRec = AO.Framework.TCServices.Read(serviceId, serviceErr) ;* Get the service record
            IF servicesRec THEN

                serviceActive = EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivServiceActive)
                serviceActive<1,servicePos> = 'Yes' ;* Default ServiceActive as 'Yes'

                operationsCnt   = DCOUNT(servicesRec<AO.Framework.TCServices.TcSvcOperation>,@VM)            ;* Get the count of operations
                operationName   = EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivOperation)       ;* Get the operations
                operationActive = EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivOperationActive) ;* Get the operations status
                operationName<1,servicePos>   = '' ;* Nullify the operations
                operationActive<1,servicePos> = '' ;* Nullify the operations status
                FOR operationPos = 1 TO operationsCnt
                    operationName<1,servicePos,operationPos> = servicesRec<AO.Framework.TCServices.TcSvcOperation><1,operationPos>
                    operationActive<1,servicePos,operationPos> = 'Yes' ;* Default all OperationActive as 'Yes'
                NEXT operationPos
            
                EB.SystemTables.setRNew(AO.Framework.TcPrivileges.AaTcPrivServiceActive,serviceActive)
                EB.SystemTables.setRNew(AO.Framework.TcPrivileges.AaTcPrivOperation,operationName)
                EB.SystemTables.setRNew(AO.Framework.TcPrivileges.AaTcPrivOperationActive,operationActive)
            END
        END
    NEXT servicePos
    
RETURN

*-----------------------------------------------------------------------------
*** <region name = Arrangement Defaults>
*** <desc>Do any defaults for Arrangement here</desc>
ArrangementDefaults:

RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name = Common Cross-validations>
*** <desc>Common cross-validations for both Product and Arrangement</desc>
CommonCrossVal:
    arrangementId = AA.Framework.getArrId()
    arrangementRecord = AA.Framework.Arrangement.Read(arrangementId, errMsg)
    masterArrId = arrangementRecord<AA.Framework.Arrangement.ArrMasterArrangement>
    productId = arrangementRecord<AA.Framework.Arrangement.ArrProduct>
* check if services or operations are deleted in order to be reinitiate
    IF AF.Framework.getProductArr() EQ AA.Framework.AaArrangement AND masterArrId EQ '' THEN
        GOSUB CheckMissingProdService
    END
    IF AF.Framework.getProductArr() EQ AA.Framework.AaArrangement AND masterArrId NE '' THEN
        GOSUB CheckMissingMarService
    END

    GOSUB CheckDuplicateService ;* Check Duplicate Services
    IF EB.SystemTables.getEtext() ELSE
        servicesCnt = DCOUNT(EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivService),@VM) ;* Get the count for services
        FOR servicePos = 1 TO servicesCnt

            GOSUB CheckDuplicateOperation ;* Check Duplicate Operations
            servicesRec = ''
            servicesRec = AO.Framework.TCServices.Read(serviceId,servicesErr)
            IF servicesRec<AO.Framework.TCServices.TcSvcMandatorySvc> EQ 'Yes' THEN ;* If service is mandatory
                IF EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivServiceActive)<1,servicePos> EQ 'Yes' ELSE ;* For a mandatory service - if ServiceActive is set to No, then throw an error
                    EB.SystemTables.setAs('')
                    EB.SystemTables.setAv(servicePos)
                    EB.SystemTables.setAf(AO.Framework.TcPrivileges.AaTcPrivService)
                    EB.SystemTables.setEtext('AO-MANDATORY.SERVICE') ;* Set Error
                    GOSUB RaiseError
					generalValidation = 'False'
                END
            END ELSE ;* If service is not mandatory
                IF EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivServiceActive)<1,servicePos> EQ 'Yes' THEN ;* If ServiceActive is set to Yes, but no underlying OperationActive is set to Yes, then throw an error
                    operationActive = EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivOperationActive)<1,servicePos>
                    LOCATE 'Yes' IN operationActive<1,1,1> SETTING opPos ELSE
                        EB.SystemTables.setAv(servicePos)
                        EB.SystemTables.setAf(AO.Framework.TcPrivileges.AaTcPrivService)
                        EB.SystemTables.setEtext('AO-ACTIVE.OPERATION') ;* Set Error
                        GOSUB RaiseError
						generalValidation = 'False'
                    END
                END
            END

            operationPos = '' operationsCnt = '' operationsList = '' opsPos = ''
            operationsList = servicesRec<AO.Framework.TCServices.TcSvcOperation>
            CONVERT @VM TO @FM IN operationsList
            operationsCnt = DCOUNT(EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivOperation)<1,servicePos>,@SM);* Get the count of operations

            IF EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivServiceActive)<1,servicePos> EQ 'Yes' THEN ;* If service is set to yes
                FOR operationPos = 1 TO operationsCnt ;* For a mandatory operation - if OperationActive is set to No, then throw an error
                    IF EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivOperation)<1,servicePos,operationPos> NE '' THEN
                        LOCATE EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivOperation)<1,servicePos,operationPos> IN operationsList SETTING opsPos THEN
                            IF (servicesRec<AO.Framework.TCServices.TcSvcMandatoryOps><1,operationPos> EQ 'Yes') AND (EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivOperationActive)<1,servicePos,operationPos> NE 'Yes') THEN
                                EB.SystemTables.setAv(servicePos)
                                EB.SystemTables.setAs(operationPos)
                                EB.SystemTables.setAf(AO.Framework.TcPrivileges.AaTcPrivOperationActive)
                                EB.SystemTables.setEtext('AO-MANDATORY.OPERATION') ;* Set Error
                                GOSUB RaiseError
								generalValidation = 'False'
                            END
                        END ELSE
                            EB.SystemTables.setAv(servicePos)
                            EB.SystemTables.setAs(operationPos)
                            EB.SystemTables.setAf(AO.Framework.TcPrivileges.AaTcPrivOperation)
                            EB.SystemTables.setEtext('AO-INVALID.OPERATION') ;* Set Error
                            GOSUB RaiseError
							generalValidation = 'False'
                        END
                    END
                NEXT operationPos
            END
        
            operationList = EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivOperationActive)<1,servicePos> ;* Get the list of operations defined in TC.PRIVILEGES, for the service (servicePos)
            CONVERT @SM TO @FM IN operationList
            IF EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivServiceActive)<1,servicePos> EQ '' THEN  ;* If ServiceActive is set to No, then set all underlying OperationActive to No
                LOCATE 'Yes' IN operationList SETTING opsPos THEN
                    CURR.NO = ''
                    EB.SystemTables.setAf(servicePos)
                    overrideMsg = 'AO-SET.OPERATIONS.INACTIVE':@FM:serviceId
                    EB.SystemTables.setText(overrideMsg);* Throw Override
                    EB.OverrideProcessing.StoreOverride(CURR.NO)

                    operationActive = EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivOperationActive) ;* Get the operations status
                    operationActive<1,servicePos> = '' ;* Nullify the operations status

                    EB.SystemTables.setRNew(AO.Framework.TcPrivileges.AaTcPrivOperationActive,operationActive) ;* Set all underlying OperationActive to No
                END
            END

            IF EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivServiceActive)<1,servicePos> EQ 'Yes' THEN ;* If ServiceActive is set to Yes
                operationPos = ''
                operationsCnt = ''
                currentOperation = ''
                dependentpOperationList = ''
                tcServOperPosFM = ''
                tcServOperPosVM = ''
                operationsCnt = DCOUNT(EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivOperation)<1,servicePos>,@SM) ;* Get the count of underlying operations for the service (servicePos)
                FOR operationPos = 1 TO operationsCnt ;* For each underlying operation, get the list of dependencies from TC.SERVICES
                    currentOperation = EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivOperation)<1,servicePos,operationPos>
                    IF EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivOperationActive)<1,servicePos,operationPos> THEN
                        dependentpOperationList = servicesRec<AO.Framework.TCServices.TcSvcOperation>
* check if the operation from TC Privileges is found in TC.SERVICES record
                        FIND currentOperation IN dependentpOperationList SETTING tcServOperPosFM, tcServOperPosVM THEN
                            dependentSvc = servicesRec<AO.Framework.TCServices.TcSvcDependentSvc,tcServOperPosVM> ;* Get the list of dependent services (TcSvcDependentSvc) for each operation (AaTcPrivOperation)
                            dependentOps = servicesRec<AO.Framework.TCServices.TcSvcDependentOps,tcServOperPosVM> ;* Get the list of dependent operations (TcSvcDependentOps) for each operation (AaTcPrivOperation)
                            IF dependentOps THEN
                                GOSUB CheckDependencies ;* Search dependencies in TC.SERVICES
                            END
                        END
                    END
                NEXT operationPos
            END
        NEXT servicePos
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------
CheckDependencies:
*** <region name = Check Dependencies>
*** <desc>Check for dependencies in TC.SERVICES </desc>

    serviceList = EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivService) ;* Get the list of services defined in TC.PRIVILEGES
    CONVERT @VM TO @FM IN serviceList

    count = 0
    opsPos = ''
    LOOP ;* Loop through the list of dependent services
        REMOVE dependentServiceId FROM dependentSvc SETTING pos
    WHILE dependentServiceId ;* Repeat for every dependent service
        servPos = ''
        LOCATE dependentServiceId IN serviceList SETTING servPos THEN ;* If dependent service is present in the list of services defined in TC.PRIVILEGES
            count += 1

            operationList = EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivOperation)<1,servPos> ;* Get the list of operations defined in TC.PRIVILEGES, for the service (servicePos)
            CONVERT @SM TO @FM IN operationList
            CONVERT @SM TO @FM IN dependentOps

            dependentOpsId = dependentOps<count>

            opServ = '' depOpServ = ''
            opServ = EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivService)<1,servicePos> : '.' : EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivOperation)<1,servicePos,operationPos>
            depOpServ = dependentServiceId : '.' : dependentOpsId

            LOCATE dependentOpsId IN operationList SETTING opsPos THEN ;* If dependent operation is present in the list of operations defined in TC.PRIVILEGES
                IF EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivOperationActive)<1,servPos,opsPos> EQ 'Yes' ELSE ;* Check if OperationActive is set to Yes. If no, throw an error
                    EB.SystemTables.setAs(operationPos)
                    EB.SystemTables.setAv(servicePos)
                    EB.SystemTables.setAf(AO.Framework.TcPrivileges.AaTcPrivOperationActive)
                    errorMsg = 'AO-DEPENDENT.OPERATION.NOT.ACTIVE':@FM:opServ:@VM:depOpServ
                    EB.SystemTables.setEtext(errorMsg) ;* Set Error
                    GOSUB RaiseError
					generalValidation = 'False'
                END
            END ELSE ;* If dependent operation is missing from the list of operations defined in TC.PRIVILEGES
                EB.SystemTables.setAs(operationPos)
                EB.SystemTables.setAv(servicePos)
                EB.SystemTables.setAf(AO.Framework.TcPrivileges.AaTcPrivOperation)
                errorMsg = 'AO-DEPENDENT.OPERATION.MISSING':@FM:opServ:@VM:depOpServ
                EB.SystemTables.setEtext(errorMsg) ;* Set Error
                GOSUB RaiseError
				generalValidation = 'False'
            END
        END ELSE ;* If dependent service is missing from the list of services defined in TC.PRIVILEGES
            EB.SystemTables.setAs('')
            EB.SystemTables.setAv(servicePos)
            EB.SystemTables.setAf(AO.Framework.TcPrivileges.AaTcPrivService)
            errorMsg = 'AO-DEPENDENT.SERVICE.MISSING':@FM:EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivService)<1,servicePos>:@VM:dependentServiceId
            EB.SystemTables.setEtext(errorMsg) ;* Set Error
            GOSUB RaiseError
			generalValidation = 'False'
        END
    REPEAT

RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name = Designer Crossvalidations>
*** <desc>Designer level cross validations</desc>
DesignerCrossVal:

RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name = Arrangement Crossvalidations>
*** <desc>Arrangement level cross-validations</desc>
ArrangementCrossVal:
    IF masterArrId NE '' THEN
        GOSUB ValidateAgainstMasterArr
    END
RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name = Raise Error>
*** <desc>Raise Error</desc>
RaiseError:

    IF EB.SystemTables.getEtext() THEN     ;* Check the error
        EB.ErrorProcessing.StoreEndError() ;* Store the error
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name = Check Duplicate>
*** <desc>Check Duplicate Services</desc>
CheckDuplicateService:

    serviceAf = AO.Framework.TcPrivileges.AaTcPrivService ;* Get Service field position
    EB.SystemTables.setAf(serviceAf)
    EB.Template.Dup() ;* Check Duplicate
    EB.SystemTables.setAf('')

RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name = Check Duplicate>
*** <desc>Check Duplicate for Operations</desc>
CheckDuplicateOperation:

    EB.SystemTables.setAv(servicePos)
    EB.SystemTables.setAf(AO.Framework.TcPrivileges.AaTcPrivOperation) ;* Get the operation field position
    EB.Template.Dup() ;* Check Duplicate
    serviceId = EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivService)<1,servicePos>

RETURN
*** </region>
*-----------------------------------------------------------------------------
GetArrangementData:
* get information from arrangement
* this data will be used for the master validation against product conditions or for the subArr validation against masterArr
    arrPrivService = ''
    arrPrivServiceActive = ''
    arrPrivOperation = ''
    arrPrivOperationActive = ''

    arrPrivService = EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivService)
    arrPrivServiceActive = EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivServiceActive)
    arrPrivOperation = EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivOperation)
    arrPrivOperationActive = EB.SystemTables.getRNew(AO.Framework.TcPrivileges.AaTcPrivOperationActive)
	
    subArrPrivService = arrPrivService
    subArrPrivServiceActive = arrPrivServiceActive
    subArrPrivOperation = arrPrivOperation
    subArrPrivOperationActive = arrPrivOperationActive
    
    insertArrPrivService = arrPrivService
    insertArrPrivServiceActive = arrPrivServiceActive
    insertArrPrivOperation = arrPrivOperation
    insertArrPrivOperationActive = arrPrivOperationActive
RETURN
*-----------------------------------------------------------------------------
GetMasterArrangementData:
* get information from masterArrangement using GetArrangementConditions
    maArrPrivService = ''
    maArrPrivServiceActive = ''
    maArrPrivOperation = ''
    maArrPrivOperationActive = ''
    propertyIds = ''
    propertyRecords = ''
    retErr = ''
    aaProperyClassId = 'TC.PRIVILEGES'
    AA.Framework.GetArrangementConditions(masterArrId, aaProperyClassId, '', '', propertyIds, propertyRecords, retErr)      ;* Get arrangement condition for Protection Limit Property class
    IF retErr = '' AND propertyRecords NE '' THEN
        maArrPrivService = RAISE(propertyRecords<1,AO.Framework.TcPrivileges.AaTcPrivService>)
        maArrPrivServiceActive = RAISE(propertyRecords<1,AO.Framework.TcPrivileges.AaTcPrivServiceActive>)
        maArrPrivOperation = RAISE(propertyRecords<1,AO.Framework.TcPrivileges.AaTcPrivOperation>)
        maArrPrivOperationActive = RAISE(propertyRecords<1,AO.Framework.TcPrivileges.AaTcPrivOperationActive>)
    END
* validations

RETURN
*-----------------------------------------------------------------------------
GetProductData:
* get the data for the Product Conditions using GetProductConditionRecords
    prodPrivService = ''
    prodPrivServiceActive = ''
    prodPrivOperation = ''
    prodPrivOperationActive = ''
    OutPropertyList = ''
    OutPropertyConditionList = ''
    RetErr = ''
* get the information for each property from product conditions
    AA.ProductFramework.GetProductConditionRecords(productId , "", "", OutPropertyList, "", "", OutPropertyConditionList, RetErr)
    IF RetErr = '' AND OutPropertyList NE '' THEN
        FIND "TCPRIVILEGES" IN OutPropertyList SETTING PropPos THEN
            prodPrivService = RAISE(OutPropertyConditionList<PropPos,AO.Framework.TcPrivileges.AaTcPrivService>)
            prodPrivServiceActive = RAISE(OutPropertyConditionList<PropPos,AO.Framework.TcPrivileges.AaTcPrivServiceActive>)
            prodPrivOperation = RAISE(OutPropertyConditionList<PropPos,AO.Framework.TcPrivileges.AaTcPrivOperation>)
            prodPrivOperationActive = RAISE(OutPropertyConditionList<PropPos,AO.Framework.TcPrivileges.AaTcPrivOperationActive>)

        END
    END
    
RETURN
*-----------------------------------------------------------------------------
* validate the services for the subArrangements against the master
ValidateAgainstMasterArr:
* get the data for the arrangement using RNew
    GOSUB GetArrangementData
* get information from masterArrangement using GetArrangementConditions
    GOSUB GetMasterArrangementData
    subServiceType = ''
    typePos = ''
    countPrivService = 1
* loop all the Services
    LOOP
        REMOVE subServiceType FROM subArrPrivService SETTING typePos
    WHILE subServiceType
        masterPosAf = ''
        masterPosAv = ''
        FIND subServiceType IN maArrPrivService SETTING masterPosAf,masterPosAv THEN
            IF (maArrPrivServiceActive<1,masterPosAv> EQ '') AND (subArrPrivServiceActive<1,countPrivService> NE maArrPrivServiceActive<1,masterPosAv>) THEN
                EB.SystemTables.setAs('')
                EB.SystemTables.setAv(countPrivService)
                EB.SystemTables.setAf(AO.Framework.TcPrivileges.AaTcPrivServiceActive)
                EB.SystemTables.setEtext('AO-SERVICEACTIVE.NOT.VALID':@FM:subArrPrivServiceActive<1,countPrivService>)
                EB.ErrorProcessing.StoreEndError()
            END ELSE
                GOSUB CheckSubArrOperation
            END
        END ELSE
            EB.SystemTables.setAs('')
            EB.SystemTables.setAv(countPrivService)
            EB.SystemTables.setAf(AO.Framework.TcPrivileges.AaTcPrivServiceActive)
            EB.SystemTables.setEtext('AO-SERVICE.NOT.PRESENT':@FM:subServiceType)
            EB.ErrorProcessing.StoreEndError()
        END
        countPrivService = countPrivService + 1
    REPEAT
    
RETURN
*-----------------------------------------------------------------------------
* validate the operations for the subArrangements against the master
CheckSubArrOperation:
    countSubArrPrivOperation = 1
    tempsubArrPrivOperation = subArrPrivOperation<1,countPrivService>
    tempMasArrPrivOperation = maArrPrivOperation<1,masterPosAv>

    subValues = ''

* loop all the intervals from subArr
    LOOP
        REMOVE subValues FROM tempsubArrPrivOperation SETTING subTypePos
    WHILE subValues
        subTypePos = ''
        subMasterPosAv = ''
        subMasterPosAs = ''
        FIND subValues IN tempMasArrPrivOperation SETTING subMasterPos,subMasterPosAv,subMasterPosAs THEN
            IF (maArrPrivOperationActive<1,masterPosAv,subMasterPosAs> EQ '') AND (subArrPrivOperationActive<1,countPrivService,countSubArrPrivOperation> NE maArrPrivOperationActive<1,masterPosAv,subMasterPosAs>) THEN
                EB.SystemTables.setAs(countSubArrPrivOperation)
                EB.SystemTables.setAv(countPrivService)
                EB.SystemTables.setAf(AO.Framework.TcPrivileges.AaTcPrivOperationActive)
                EB.SystemTables.setEtext('AO-OPERATIONACTIVE.NOT.VALID':@FM:subArrPrivOperationActive<1,countPrivService,countSubArrPrivOperation>)
                EB.ErrorProcessing.StoreEndError()
            END

            countSubArrPrivOperation = countSubArrPrivOperation + 1
        END ELSE
            EB.SystemTables.setAs(countSubArrPrivOperation)
            EB.SystemTables.setAv(countPrivService)
            EB.SystemTables.setAf(AO.Framework.TcPrivileges.AaTcPrivOperationActive)
            EB.SystemTables.setEtext('AO-OPERATION.NOT.PRESENT':@FM:subValues)
            EB.ErrorProcessing.StoreEndError()
        END
    REPEAT
RETURN

*-----------------------------------------------------------------------------
CheckMissingProdService:
    GOSUB GetArrangementData
    GOSUB GetProductData
* loop all the Services, search for missing service, operation
    serviceType = ''
    typePos = ''
    countPrivService = 1
    serviceMissing = ''
    operationMissing = ''
    serviceMissingDel = ""
    operationMissingDel = ''
*
* delete services/operations not found in product conditions
    GOSUB DeleteServicesNotFoundProd
* add new services/operations found in product conditions
    LOOP
        REMOVE serviceType FROM prodPrivService SETTING typePos
    WHILE serviceType
        prodPosAf = ''
        prodPosAv = ''
        FIND serviceType IN arrPrivService SETTING prodPosAf,prodPosAv THEN
            GOSUB CheckMissingProdOperation
        END ELSE
            serviceMissing = 'True'
			generalValidation = 'False'
*   reinitiate services
            insertArrPrivService = INSERT(insertArrPrivService, 1,countPrivService; serviceType)
*   reinitiate services active
            insertArrPrivServiceActive = INSERT(insertArrPrivServiceActive, 1,countPrivService; prodPrivServiceActive<1,countPrivService>)
*   reinitiate operations
            insertArrPrivOperation = INSERT(insertArrPrivOperation, 1,countPrivService; prodPrivOperation<1,countPrivService>)
*   reinitiate operations active
            insertArrPrivOperationActive = INSERT(insertArrPrivOperationActive, 1,countPrivService; prodPrivOperationActive<1,countPrivService>)
        END
        countPrivService = countPrivService + 1
    REPEAT
*  Throw Override if Services are missing from arrangement
    IF serviceMissing NE ''  OR serviceMissingDel NE '' THEN
        EB.SystemTables.setAf('')
        IF serviceMissing NE '' THEN
            EB.SystemTables.setText("AO-PRD.COND.NO.CHANGE":@FM:"Services")
        END
        IF serviceMissing EQ '' AND serviceMissingDel NE '' THEN
            EB.SystemTables.setText("AO-LIST.REINITIATED":@FM:"Services ":@VM:" the product condition level.")  ;*  Throw Override if Services list was re-initiated from the product condition
        END
        EB.OverrideProcessing.StoreOverride('')
* reinitiate privileges data
        EB.SystemTables.setRNew(AO.Framework.TcPrivileges.AaTcPrivService, insertArrPrivService)
        EB.SystemTables.setRNew(AO.Framework.TcPrivileges.AaTcPrivServiceActive, insertArrPrivServiceActive)
        EB.SystemTables.setRNew(AO.Framework.TcPrivileges.AaTcPrivOperation, insertArrPrivOperation)
        EB.SystemTables.setRNew(AO.Framework.TcPrivileges.AaTcPrivOperationActive, insertArrPrivOperationActive)
    END
*
*  Throw Override if Operations are missing from arrangement
    IF operationMissing NE '' OR operationMissingDel NE '' THEN
        EB.SystemTables.setAf('')
        IF operationMissing NE '' THEN
            EB.SystemTables.setText("AO-PRD.COND.NO.CHANGE":@FM:"Operations")
        END
        IF operationMissing EQ '' AND operationMissingDel NE '' THEN
            EB.SystemTables.setText("AO-LIST.REINITIATED":@FM:"Operations ":@VM:" the product condition level.")  ;*  Throw Override if Operations list was re-initiated from the product condition
        END
        EB.OverrideProcessing.StoreOverride('')
        EB.SystemTables.setRNew(AO.Framework.TcPrivileges.AaTcPrivOperation, insertArrPrivOperation)
        EB.SystemTables.setRNew(AO.Framework.TcPrivileges.AaTcPrivOperationActive, insertArrPrivOperationActive)
    END
RETURN
*-----------------------------------------------------------------------------
CheckMissingProdOperation:
    subValues = ''
    countArrPrivOperation = 1
    tempArrPrivOperation = arrPrivOperation<1,prodPosAv>
    FIND serviceType IN prodPrivService SETTING tmpPosAf,tmpprodPosAv THEN
        tempProdPrivOperation = prodPrivOperation<1,tmpprodPosAv>
    END
* loop all the intervals from arr
    LOOP
        REMOVE subValues FROM tempProdPrivOperation SETTING subTypePos
    WHILE subValues
        subProdPosAf = ''
        FIND subValues IN tempArrPrivOperation SETTING subProdPosAf ELSE
            operationMissing = 'True'
			generalValidation = 'False'
*   reinitiate operations
            insertArrPrivOperation = INSERT(insertArrPrivOperation, 1,countPrivService,countArrPrivOperation; subValues)
*   reinitiate operations active
            insertArrPrivOperationActive = INSERT(insertArrPrivOperationActive, 1,countPrivService,countArrPrivOperation; prodPrivOperationActive<1,countPrivService,countArrPrivOperation>)
        END
        countArrPrivOperation = countArrPrivOperation + 1
    REPEAT
RETURN
*-----------------------------------------------------------------------------
DeleteServicesNotFoundProd:
    LOOP
        REMOVE serviceType FROM arrPrivService SETTING typePos
    WHILE serviceType
        prodPosAf = ''
        prodPosAv = ''
        FIND serviceType IN prodPrivService SETTING prodPosAf,prodPosAv THEN
            GOSUB DeleteOperationsNotFoundProd
        END ELSE
            serviceMissingDel = 'True'
            generalValidation = 'False'
*   reinitiate services
            FIND serviceType IN insertArrPrivService SETTING fmPos, vmPos THEN
                DEL insertArrPrivService<1,vmPos>
*   reinitiate services active
                DEL insertArrPrivServiceActive<1,vmPos>
*   reinitiate operations
                DEL insertArrPrivOperation<1,vmPos>
*   reinitiate operations active
                DEL insertArrPrivOperationActive<1,vmPos>
            END
        END
    REPEAT
RETURN
*-----------------------------------------------------------------------------
DeleteOperationsNotFoundProd:
    subValues = ''
    tempProdPrivOperation = prodPrivOperation<1,prodPosAv>
    FIND serviceType IN arrPrivService SETTING tmpPosAf,tmpprodPosAv THEN
        tempArrPrivOperation = arrPrivOperation<1,tmpprodPosAv>
    END
* loop all the intervals from arr
    LOOP
        REMOVE subValues FROM tempArrPrivOperation SETTING subTypePos
    WHILE subValues
        subProdPosAf = ''
        FIND subValues IN tempProdPrivOperation SETTING subProdPosAf ELSE
            operationMissingDel = 'True'
            generalValidation = 'False'
*   reinitiate operations
            FIND subValues IN insertArrPrivOperation SETTING fmPos,vmPos,smPos THEN
                DEL insertArrPrivOperation<1,vmPos,smPos>
*   reinitiate operations active
                DEL insertArrPrivOperationActive<1,vmPos,smPos>
            END
        END
    REPEAT
RETURN
*-----------------------------------------------------------------------------
CheckMissingMarService:
    GOSUB GetArrangementData
    GOSUB GetMasterArrangementData
* loop all the Services, search for missing service, operation
    serviceType = ''
    typePos = ''
    countPrivService = 1
    serviceMissing = ''
    operationMissing = ''
    serviceMissingDel = ''
    operationMissingDel = ''
* delete services/operations not found in master
    GOSUB DeleteServicesNotFoundMas
* add new services/operations found in master
    LOOP
        REMOVE serviceType FROM maArrPrivService SETTING typePos
    WHILE serviceType
        prodPosAf = ''
        prodPosAv = ''
        FIND serviceType IN subArrPrivService SETTING prodPosAf,prodPosAv THEN
            GOSUB CheckMissingMarOperation
        END ELSE
            serviceMissing = 'True'
            generalValidation = 'False'
*   reinitiate services
            insertArrPrivService = INSERT(insertArrPrivService, 1,countPrivService; serviceType)
*   reinitiate services active
            insertArrPrivServiceActive = INSERT(insertArrPrivServiceActive, 1,countPrivService; maArrPrivServiceActive<1,countPrivService>)
*   reinitiate operations
            insertArrPrivOperation = INSERT(insertArrPrivOperation, 1,countPrivService; maArrPrivOperation<1,countPrivService>)
*   reinitiate operations active
            insertArrPrivOperationActive = INSERT(insertArrPrivOperationActive, 1,countPrivService; maArrPrivOperationActive<1,countPrivService>)
        END
        countPrivService = countPrivService + 1
    REPEAT
*  Throw Override if Services are missing from arrangement
    IF serviceMissing NE '' OR serviceMissingDel NE '' THEN
        EB.SystemTables.setAf('')
        IF serviceMissing NE '' THEN
            EB.SystemTables.setText("AO-MAS.COND.NO.CHANGE":@FM:"Services")
        END
        IF serviceMissing EQ '' AND serviceMissingDel NE '' THEN
            EB.SystemTables.setText("AO-LIST.REINITIATED":@FM:"Services ":@VM:" the master arrangement level.")  ;*  Throw Override if Services list was re-initiated from the master arrangement level.
        END
        EB.OverrideProcessing.StoreOverride('')
* reinitiate privileges data
        EB.SystemTables.setRNew(AO.Framework.TcPrivileges.AaTcPrivService, insertArrPrivService)
        EB.SystemTables.setRNew(AO.Framework.TcPrivileges.AaTcPrivServiceActive, insertArrPrivServiceActive)
        EB.SystemTables.setRNew(AO.Framework.TcPrivileges.AaTcPrivOperation, insertArrPrivOperation)
        EB.SystemTables.setRNew(AO.Framework.TcPrivileges.AaTcPrivOperationActive, insertArrPrivOperationActive)
    END
*  Throw Override if Operations are missing from arrangement
    IF operationMissing NE '' OR operationMissingDel NE '' THEN
        EB.SystemTables.setAf('')
        IF operationMissing NE '' THEN
            EB.SystemTables.setText("AO-MAS.COND.NO.CHANGE":@FM:"Operations")
        END
        IF operationMissing EQ '' AND operationMissingDel NE '' THEN
            EB.SystemTables.setText("AO-LIST.REINITIATED":@FM:"Operations ":@VM:" the master arrangement level.")  ;*  Throw Override if Operations list was re-initiated from the master arrangement level.
        END
        EB.OverrideProcessing.StoreOverride('')
        EB.SystemTables.setRNew(AO.Framework.TcPrivileges.AaTcPrivOperation, insertArrPrivOperation)
        EB.SystemTables.setRNew(AO.Framework.TcPrivileges.AaTcPrivOperationActive, insertArrPrivOperationActive)
    END
RETURN
*-----------------------------------------------------------------------------
CheckMissingMarOperation:
    subValues = ''
    countArrPrivOperation = 1
    tempSubArrPrivOperation = subArrPrivOperation<1,prodPosAv>
    FIND serviceType IN maArrPrivService SETTING tmpPosAf,tmpprodPosAv THEN
        tempMasPrivOperation = maArrPrivOperation<1,tmpprodPosAv>
    END
* loop all the intervals from arr
    LOOP
        REMOVE subValues FROM tempMasPrivOperation SETTING subTypePos
    WHILE subValues
        subProdPosAf = ''
        FIND subValues IN tempSubArrPrivOperation SETTING subProdPosAf ELSE
            operationMissing = 'True'
            generalValidation = 'False'
*   reinitiate operations
            insertArrPrivOperation = INSERT(insertArrPrivOperation, 1,countPrivService,countArrPrivOperation; subValues)
*   reinitiate operations active
            insertArrPrivOperationActive = INSERT(insertArrPrivOperationActive, 1,countPrivService,countArrPrivOperation; maArrPrivOperationActive<1,countPrivService,countArrPrivOperation>)
        END
        countArrPrivOperation = countArrPrivOperation + 1
    REPEAT
RETURN
*-----------------------------------------------------------------------------
DeleteServicesNotFoundMas:
    LOOP
        REMOVE serviceType FROM subArrPrivService SETTING typePos
    WHILE serviceType
        prodPosAf = ''
        prodPosAv = ''
        FIND serviceType IN maArrPrivService SETTING prodPosAf,prodPosAv THEN
            GOSUB DeleteOperationsNotFoundMas
        END ELSE
            serviceMissingDel = 'True'
            generalValidation = 'False'
*   reinitiate services
            FIND serviceType IN insertArrPrivService SETTING fmPos, vmPos THEN
                DEL insertArrPrivService<1,vmPos>
*   reinitiate services active
                DEL insertArrPrivServiceActive<1,vmPos>
*   reinitiate operations
                DEL insertArrPrivOperation<1,vmPos>
*   reinitiate operations active
                DEL insertArrPrivOperationActive<1,vmPos>
            END
        END
    REPEAT
RETURN
*-----------------------------------------------------------------------------
DeleteOperationsNotFoundMas:
    subValues = ''
    tempMasPrivOperation = maArrPrivOperation<1,prodPosAv>
    FIND serviceType IN subArrPrivService SETTING tmpPosAf,tmpprodPosAv THEN
        tempSubArrPrivOperation = subArrPrivOperation<1,tmpprodPosAv>
    END
* loop all the intervals from arr
    LOOP
        REMOVE subValues FROM tempSubArrPrivOperation SETTING subTypePos
    WHILE subValues
        subProdPosAf = ''
        FIND subValues IN tempMasPrivOperation SETTING subProdPosAf ELSE
            operationMissingDel = 'True'
            generalValidation = 'False'
*   reinitiate operations
            FIND subValues IN insertArrPrivOperation SETTING fmPos,vmPos,smPos THEN
                DEL insertArrPrivOperation<1,vmPos,smPos>
*   reinitiate operations active
                DEL insertArrPrivOperationActive<1,vmPos,smPos>
            END
        END
    REPEAT
RETURN
END
