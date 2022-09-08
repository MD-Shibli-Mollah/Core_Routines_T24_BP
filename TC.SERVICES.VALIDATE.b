* @ValidationCode : MjotMTI3NjIwMTYyOkNwMTI1MjoxNTU0ODI0MTY1ODg2OnJ0YW5hc2U6MTI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDQuMjAxOTA0MDYtMDIzOToxMzQ6MTM0
* @ValidationInfo : Timestamp         : 09 Apr 2019 18:36:05
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rtanase
* @ValidationInfo : Nb tests success  : 12
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 134/134 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201904.20190406-0239
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AO.Framework
SUBROUTINE TC.SERVICES.VALIDATE
*-----------------------------------------------------------------------------
* Description :
* Validation routine for TC.SERVICES
*-----------------------------------------------------------------------------
* Modification History:
**
* 03/10/2016 - Enhancement 1812222 / Task 1905849
*              Tc Services and Operations
* 16/06/2017 - Defect 2012008 / Task 2184329
*              Validations added/updated
* 29/10/2018 - Defect 2830003 / Task 2830193
*              TC.SERVICES record is missing Administration as dependency
*              To not be thrown error when an operation of a TC.SERVICES record is containing dependency on another operation of the same TC.SERVICES record
* 09/04/2019 - Defect 3068353 / Task 3077431
*              R18 to 201904 Upgrade - unable to authorize TC.SERVICES record Administration
*              Moved the code to be validated dependency first against current RNEW record
*-----------------------------------------------------------------------------
*** <region name = Main section>
*** <desc>Main section</desc>

    $USING AO.Framework
    $USING EB.Template
    $USING EB.SystemTables
    $USING EB.ErrorProcessing
    $USING EB.Versions

    GOSUB Initialise
    GOSUB Validate
    
RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name = Initialise>
*** <desc>Initialise local variables and file variables</desc>
Initialise:

    av = ''
    as = ''
    noOfOperations = ''
    noOfDependentOps = ''
    dependentOpsId = ''
    dependentSvcId = ''
    tcServicesRec = ''
    tcServicesErr = ''
    tcServicesOps = ''
    availableOpsPos = ''
    noOfVersions = ''

RETURN
*** </region>

*-----------------------------------------------------------------------------
*** < region name = Validation>
*** <desc>Validations</desc>
Validate:

* Set AF, av and as to the field, multi value and sub value and invoke STORE.END.ERROR
* Set ETEXT to point to the EB.ERROR.TABLE
* validation for the Services and Operations

    EB.SystemTables.setAf(AO.Framework.TCServices.TcSvcOperation)
    EB.Template.Dup()    ;* Check Duplicate

    IF EB.SystemTables.getRNew(AO.Framework.TCServices.TcSvcMandatorySvc) THEN
        LOCATE 'Yes' IN EB.SystemTables.getRNew(AO.Framework.TCServices.TcSvcMandatoryOps)<1,1> SETTING mandatoryPos ELSE ;* Throw error when MandatorySvc is set to Yes and all MandatoryOps are set to No
            EB.SystemTables.setAs('')
            EB.SystemTables.setAv('')
            EB.SystemTables.setAf(AO.Framework.TCServices.TcSvcMandatorySvc)
            EB.SystemTables.setEtext('AO-SET.MANDATORY.OPERATION') ;* Set Error
            GOSUB RaiseError
        END
    END

    noOfOperations = DCOUNT(EB.SystemTables.getRNew(AO.Framework.TCServices.TcSvcOperation),@VM) ;* Get the count of operations for validation
    FOR av = 1 TO noOfOperations
        newServOpList = ''

        noOfDependentSvc = ''
        noOfDependentOps = ''

        noOfDependentSvc = DCOUNT(EB.SystemTables.getRNew(AO.Framework.TCServices.TcSvcDependentSvc)<1,av>,@SM) ;* Get the number of dependent services for validation
        noOfDependentOps = DCOUNT(EB.SystemTables.getRNew(AO.Framework.TCServices.TcSvcDependentOps)<1,av>,@SM) ;* Get the number of dependent operations for validation

        IF (noOfDependentSvc NE 0) AND (noOfDependentOps EQ 0) THEN ;* Throw error when no dependent operation is defined for dependent service
            EB.SystemTables.setAv(av)
            EB.SystemTables.setAf(AO.Framework.TCServices.TcSvcDependentOps)
            EB.SystemTables.setEtext('AO-OPERATION.MISSING') ;* Set Error
            GOSUB RaiseError
        END

        FOR as = 1 TO noOfDependentOps ;* Loop all dependent operations
            servOpList = ''
            servOpListPos = ''

            IF EB.SystemTables.getRNew(AO.Framework.TCServices.TcSvcDependentSvc)<1,av,as> EQ '' THEN ;* Throw error when no dependent service is defined for the dependent operation
                EB.SystemTables.setAs(as)
                EB.SystemTables.setAv(av)
                EB.SystemTables.setAf(AO.Framework.TCServices.TcSvcDependentSvc)
                EB.SystemTables.setEtext('AO-SERVICE.MISSING') ;* Set Error
                GOSUB RaiseError
            END ELSE
                IF EB.SystemTables.getRNew(AO.Framework.TCServices.TcSvcDependentOps)<1,av,as> EQ '' THEN ;* Throw error when no dependent operation is defined for dependent service
                    EB.SystemTables.setAs(as)
                    EB.SystemTables.setAv(av)
                    EB.SystemTables.setAf(AO.Framework.TCServices.TcSvcDependentOps)
                    EB.SystemTables.setEtext('AO-OPERATION.MISSING') ;* Set Error
                    GOSUB RaiseError
                END ELSE
                    servOpList = EB.SystemTables.getRNew(AO.Framework.TCServices.TcSvcDependentSvc)<1,av,as>:'.':EB.SystemTables.getRNew(AO.Framework.TCServices.TcSvcDependentOps)<1,av,as>

                    LOCATE servOpList IN newServOpList SETTING servOpListPos THEN ;* Throw error for duplicate service and operation
                        EB.SystemTables.setAs(as)
                        EB.SystemTables.setAv(av)
                        EB.SystemTables.setAf(AO.Framework.TCServices.TcSvcDependentSvc)
                        EB.SystemTables.setEtext('AO-DUPLICATE.SERVICE.AND.OPERATION') ;* Set Error
                        GOSUB RaiseError
                    END ELSE
                        newServOpList = newServOpList :@FM: servOpList ;* Build the array of dependent services and operations

                        dependentOpsId = EB.SystemTables.getRNew(AO.Framework.TCServices.TcSvcDependentOps)<1,av,as>
                        dependentSvcId = EB.SystemTables.getRNew(AO.Framework.TCServices.TcSvcDependentSvc)<1,av,as>
                        IF (dependentOpsId OR dependentSvcId) THEN
                            GOSUB ProcessDependency  ;* check dependent service and operations
                        END
                    END
                END
            END
        NEXT as
    NEXT av

    noOfVersions = DCOUNT(EB.SystemTables.getRNew(AO.Framework.TCServices.TcSvcRecordName),@VM) ;* Get the count for Records
    FOR av = 1 TO noOfVersions
        rVersionError = ''
        IF EB.SystemTables.getRNew(AO.Framework.TCServices.TcSvcRecordType)<1,av> EQ 'VERSION' THEN ;* Validate the version record
            ebVersionRec = ''
            rVersionError = ''
            ebVersionRec = EB.Versions.Version.Read(EB.SystemTables.getRNew(AO.Framework.TCServices.TcSvcRecordName)<1,av>, rVersionError) ;* Read the version record
            IF rVersionError THEN
                EB.SystemTables.setAf(AO.Framework.TCServices.TcSvcRecordName) ;* Throw error for invalid version
                EB.SystemTables.setAv(av)
                EB.SystemTables.setEtext('EB-INVALID.INPUT') ;* Set Error
                GOSUB RaiseError
            END
        END
    NEXT av

RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name = Raise Error>
*** <desc>Raise Error</desc>
RaiseError:

    IF EB.SystemTables.getEtext() THEN     ;* Check the error
        EB.ErrorProcessing.StoreEndError() ;* Raise Error
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name = ProcessDependency>
*** <desc>Check dependent service and operations</desc>
ProcessDependency:
* The Dependent Service is searched first in existing TC.SERVICES records. If it is not found, it is searched the ID of the current record. Otherwise error is thrown.
*
    IF dependentSvcId EQ EB.SystemTables.getIdNew() THEN     ;* Check first if the dependency is on current record
        GOSUB CheckValidDependentOperation                   ;* it is dependency on current record; check the operations of the current record
    END ELSE                                                 ;* If the dependent service is not on the current service/record, check if dependent service is on another record from TC.Services table
        tcServicesRec = AO.Framework.TCServices.Read(dependentSvcId, tcServicesErr) ;* Get the TC Services record
        IF tcServicesRec THEN
            tcServicesOps = tcServicesRec<AO.Framework.TCServices.TcSvcOperation>
            LOCATE dependentOpsId IN tcServicesOps<1,1> SETTING availableOpsPos ELSE ;* Throw error for invalid operation
                EB.SystemTables.setAs(as)
                EB.SystemTables.setAv(av)
                EB.SystemTables.setAf(AO.Framework.TCServices.TcSvcDependentOps)
                EB.SystemTables.setEtext('EB-INVALID.INPUT') ;* Set Error
                GOSUB RaiseError
            END
        END ELSE
            EB.SystemTables.setAs(as)
            EB.SystemTables.setAv(av)
            EB.SystemTables.setAf(AO.Framework.TCServices.TcSvcDependentSvc) ;* Throw error for invalid service
            EB.SystemTables.setEtext('EB-INVALID.INPUT') ;* Set Error
            GOSUB RaiseError
        END
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name = CheckValidDependentOperation>
*** <desc>The Dependent Service is on the current record. Check the Dependent operation in the current record.</desc>
CheckValidDependentOperation:
*
    IF EB.SystemTables.getRNew(AO.Framework.TCServices.TcSvcDependentOps)<1,av,as> EQ EB.SystemTables.getRNew(AO.Framework.TCServices.TcSvcOperation)<1,av> THEN
* if the field Dependent Operation is completed with associated Operation (from current multivalue set)
        EB.SystemTables.setAs(as)
        EB.SystemTables.setAv(av)
        EB.SystemTables.setAf(AO.Framework.TCServices.TcSvcDependentOps)
        EB.SystemTables.setEtext('AO-DEP.OP.CANNOTBE.CURR.OP') ;* Set Error - Dependent Operation cannot refer current operation
        GOSUB RaiseError
    END ELSE
        tcServicesOps = EB.SystemTables.getRNew(AO.Framework.TCServices.TcSvcOperation)  ;* read Operation field. Operations are separated by VM.
        FIND dependentOpsId IN tcServicesOps SETTING availableOpsPos ELSE ;* Throw error for invalid operation if Dependent Operation is not found in Operationslist.
            EB.SystemTables.setAs(as)
            EB.SystemTables.setAv(av)
            EB.SystemTables.setAf(AO.Framework.TCServices.TcSvcDependentOps)
            EB.SystemTables.setEtext('EB-INVALID.INPUT') ;* Set Error
            GOSUB RaiseError
        END
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
