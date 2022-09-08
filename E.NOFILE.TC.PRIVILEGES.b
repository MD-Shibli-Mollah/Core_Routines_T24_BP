* @ValidationCode : MjoxOTA1MzQ2Mzg3OkNwMTI1MjoxNDg3MDczNjM3ODQ2OnJzdWRoYToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxNzAyLjA6NTg6Mjk=
* @ValidationInfo : Timestamp         : 14 Feb 2017 17:30:37
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rsudha
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 29/58 (50.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE AO.ModelBank
    SUBROUTINE E.NOFILE.TC.PRIVILEGES(RESULT.DATA)
*-----------------------------------------------------------------------------
* Description :
* This routine is to process the result of the Product and Arrangment Level privileges and operations
*-----------------------------------------------------------------------------
* Modification History:
*
* 03/10/16 - Enhancement 1812222 / Task 1905849
*            Tc Permissions property class
*-----------------------------------------------------------------------------
    $USING AO.Framework
    $USING EB.SystemTables
    $USING EB.Reports
    $USING AA.Framework
    $USING AA.ProductFramework

*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN
*----------------------------------------------------------------------------
INITIALISE:
*Initialise Required variables
    LOCATE "ARRANGEMENT.ID" IN EB.Reports.getDFields()<1> SETTING FIELD.POS THEN
    ARR.ID = EB.Reports.getDRangeAndValue()<FIELD.POS> ;* Get the arrangement Id
    END
*
    RETURN
*----------------------------------------------------------------------------
PROCESS:
*
    R.AA.ARRANGEMENT=AA.Framework.Arrangement.Read(ARR.ID, ARR.ERR) ;* Read the arrangement
    ProductId=R.AA.ARRANGEMENT<AA.Framework.Arrangement.ArrProduct> ;* Get product Id
    START.DATE=R.AA.ARRANGEMENT<AA.Framework.Arrangement.ArrStartDate> ;* Get arrangement start date
    PROPERTY.ID='TCPERMISSIONS'
*
    Idarrangementcomp=ARR.ID:"//AUTH"
    Currency='' ;* Initialise Currency
    EffectiveDate='' ;* Initialise Effective Date
    OutPropertyList='' ;* Initialise property list
    OutPropertyClassList='' ;* Initialise property class list
    OutArrangementLinkType='' ;* Initilaise arrangement link type
    OutPropertyConditionList='' ;* Initialise property class conditions
    RetErr='' ;* Intialise error variables
*
    AA.ProductFramework.GetProductConditionRecords(ProductId, Currency, EffectiveDate, OutPropertyList, OutPropertyClassList, OutArrangementLinkType, OutPropertyConditionList, RetErr) ;* Get property condition records
*
    LOCATE 'TC.PRIVILEGES' IN OutPropertyClassList<1> SETTING PERMISSION.POS THEN
    PROD.PRIVILEGES.RECORD = RAISE(OutPropertyConditionList<PERMISSION.POS>) ;* Locate and find the Privileges related product condition records
    END
*
    AA.Framework.GetArrangementConditions(Idarrangementcomp, 'TC.PRIVILEGES', Idproperty, Effectivedate, Returnids, Returnconditions, Returnerror) ;* Get arrangement conditions
*
    IF Returnconditions THEN
        ARR.PRIVILEGES.RECORD = RAISE(Returnconditions)
    END

    PRD.CAT.SERVICE.CNT=DCOUNT(PROD.PRIVILEGES.RECORD<AO.Framework.TcPrivileges.AaTcPrivService>,@VM) ;* Get the count of services

    FOR SERVICE.POS=1 TO PRD.CAT.SERVICE.CNT
        RESULT.SERVICE='' ;* Initialise result service
        RESULT.SERVICE.ACTIVE='' ;* Initialise active service result
        RESULT.OPERATION='' ;* Initialsie operations
        RESULT.OPERATION.ACTIVE='' ;* Initialise active operations
        ARR.SERVICE.POS=''
        PRD.SERVICE.OPS.CNT=DCOUNT(PROD.PRIVILEGES.RECORD<AO.Framework.TcPrivileges.AaTcPrivOperation,SERVICE.POS>,@SM) ;* Get the operation count
        FOR PRD.OPS.CNT=1 TO PRD.SERVICE.OPS.CNT
            ARR.SERVICE=ARR.PRIVILEGES.RECORD<AO.Framework.TcPrivileges.AaTcPrivService> ;* Get the services from arrangement
            LOCATE PROD.PRIVILEGES.RECORD<AO.Framework.TcPrivileges.AaTcPrivService,SERVICE.POS> IN ARR.SERVICE<1,1> SETTING ARR.SERVICE.POS THEN
            BEGIN CASE
                CASE ARR.PRIVILEGES.RECORD<AO.Framework.TcPrivileges.AaTcPrivServiceActive,ARR.SERVICE.POS> EQ 'Yes'
                    PROD.PRIVILEGES.RECORD<AO.Framework.TcPrivileges.AaTcPrivServiceActive,SERVICE.POS>='Yes' ;* Make the service as Active, Based on the arrangement condition
                    LOCATE PROD.PRIVILEGES.RECORD<AO.Framework.TcPrivileges.AaTcPrivOperation,SERVICE.POS,PRD.OPS.CNT> IN ARR.PRIVILEGES.RECORD<AO.Framework.TcPrivileges.AaTcPrivOperation,ARR.SERVICE.POS,1> SETTING ARR.OPS.POS THEN
                    PROD.PRIVILEGES.RECORD<AO.Framework.TcPrivileges.AaTcPrivOperationActive,SERVICE.POS,PRD.OPS.CNT> = ARR.PRIVILEGES.RECORD<AO.Framework.TcPrivileges.AaTcPrivOperationActive,ARR.SERVICE.POS,ARR.OPS.POS> ;* Assign the arrangement condition value
                END
            CASE ARR.PRIVILEGES.RECORD<AO.Framework.TcPrivileges.AaTcPrivServiceActive,ARR.SERVICE.POS> NE 'Yes'
                LOCATE PROD.PRIVILEGES.RECORD<AO.Framework.TcPrivileges.AaTcPrivOperation,SERVICE.POS,PRD.OPS.CNT> IN ARR.PRIVILEGES.RECORD<AO.Framework.TcPrivileges.AaTcPrivOperation,ARR.SERVICE.POS,1> SETTING ARR.OPS.POS THEN
                PROD.PRIVILEGES.RECORD<AO.Framework.TcPrivileges.AaTcPrivOperationActive,SERVICE.POS,PRD.OPS.CNT> = ARR.PRIVILEGES.RECORD<AO.Framework.TcPrivileges.AaTcPrivOperationActive,ARR.SERVICE.POS,ARR.OPS.POS>
            END
    END CASE
    END
    RESULT.OPERATION<1,1,-1>=PROD.PRIVILEGES.RECORD<AO.Framework.TcPrivileges.AaTcPrivOperation,SERVICE.POS,PRD.OPS.CNT> ;* Operation list
    RESULT.OPERATION.ACTIVE<1,1,-1>=PROD.PRIVILEGES.RECORD<AO.Framework.TcPrivileges.AaTcPrivOperationActive,SERVICE.POS,PRD.OPS.CNT> ;* Active operation list
    NEXT PRD.OPS.CNT
    RESULT.SERVICE<1,-1>=PROD.PRIVILEGES.RECORD<AO.Framework.TcPrivileges.AaTcPrivService,SERVICE.POS> ;* Service list
    RESULT.SERVICE.ACTIVE<1,-1>=PROD.PRIVILEGES.RECORD<AO.Framework.TcPrivileges.AaTcPrivServiceActive,SERVICE.POS> ;* Active service list
    RESULT.DATA<-1>= RESULT.SERVICE:'*':RESULT.SERVICE.ACTIVE:'*':RESULT.OPERATION:'*':RESULT.OPERATION.ACTIVE ;* Result Array
    NEXT SERVICE.POS

*
    RETURN
*----------------------------------------------------------------------------
    END
