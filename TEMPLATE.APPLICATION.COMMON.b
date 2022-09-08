* @ValidationCode : MjoxNjg5OTM4MjkyOkNwMTI1MjoxNjE1Nzg5MTEwMjg4Omt2YW5pOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMy4yMDIxMDMwMS0wNTU2Oi0xOi0x
* @ValidationInfo : Timestamp         : 15 Mar 2021 11:48:30
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kvani
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210301-0556
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
*-----------------------------------------------------------------------------
$PACKAGE EB.Template
SUBROUTINE TEMPLATE.APPLICATION.COMMON(action,MAT cacheData,application,spare)
*-----------------------------------------------------------------------------
*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
*
*  New template method used to cache application level template commons. For a new session
*  .INITIALISE & .FIELDS are called from THE.TEMPATE to load the application template common
*  based on their business logics. The final values are cached using this routine
*  which will re-use by the subsequent calls without executing those business logic again.
*
*** </region>
*-----------------------------------------------------------------------------
* @uses         : EB.LoadApplicationAttributes and THE.TEMPLATE
* @access       : private
* @stereotype   : subroutine
* @author       :
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
*** Arguments

* @action           - Current action to be carried out (STORE/LOAD)
* @cacheData        - Data needs to be store/load to cahce (Max size 500)
* @application      - Current application name (AA.ARR.ACCOUNT,FOREX, etc.)
* @spare            - For future use
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History :
*
* 15/03/2021 - Enhancement 4235992 / Task 4283923
*            - TEMPLATE.APPLICATION.COMMON routine creation
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Common variables and file inserts</desc>
* Inserts
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
*** <region name= Process Logic>
*** <desc>Program Control</desc>

    GOSUB Initialise  ;* Initialise variables
    GOSUB DoProcess
   
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc> Initialise variables </desc>
Initialise:
    
    ApplicationName = application<1>    ;* Current processing application name
    CurrentAction   = action<1>         ;* Whether we need to store the data or load the data?
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= DoProcess>
*** <desc> Do process </desc>
DoProcess:
    BEGIN CASE
        CASE CurrentAction EQ "STORE"       ;* Get the data from common and pass into the cache data
            GOSUB StoreCommon
        CASE CurrentAction EQ "LOAD"        ;* Get the values from cache data and load to common
            GOSUB LoadCommon
    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= StoreCommon>
*** <desc>Get the values in application common and store it into cache data.</desc>
StoreCommon:
    
    Z = 2 ;                                     ;* should be starting position of this array for storing common variable values.
*    cacheData(Z) = CommonVariable.1            ;* <== eg. Z = 2 ; cacheData(Z) = AA.Framework.getPropertyClassId()
*    Z +=1 ; cacheData(Z) = CommonVariable.2    ;* <== eg. Z +=1 ; cacheData(Z) = AA.Framework.getPropertyClassRec()
*    Z +=1 ; cacheData(Z) = CommonVariable.3    ;* <== eg. Z +=1 ; cacheData(Z) = AF.Framework.getProductArr()
*    Z +=1 ; cacheData(Z) = CommonVariable.4    ;* <== eg. Z +=1 ; cacheData(Z) = AF.Framework.getDatedId()
*    Z +=1 ; cacheData(Z) = CommonVariable.5    ;* <== eg. Z +=1 ; cacheData(Z) = AA.Framework.getCcyId()
*
*    Increase Z as required to store the common variables in cache
*
    cacheData(1) = '2,':Z                       ;* store start and end position, this range will be used in EB.TemplateStoreCommon to loop this cacheData and store in system cache after template commons storage
    
RETURN
*** </region>
*----------------------------------------------------------------------------
*** <region name= LoadCommon>
*** <desc>Get the values from cache data and load the values in to the application common</desc>
LoadCommon:
    
    ApplincommonRange = cacheData(1)                        ;* <== eg. AAFmkRange = cacheData(1)        ;* should extract position range from 1st position of this dimensioned array.
    Z = FIELD(ApplincommonRange,',',1)                      ;* <== eg. Z = FIELD(AAFmkRange,',',1)      ;* get starting position from where the variable values can start loading to actual common variables.
*    CommonVariable.1(cacheData(Z))                         ;* <== eg. AA.Framework.setPropertyClassId(cacheData(Z))
*    Z +=1 ; CommonVariable.2(cacheData(Z))                 ;* <== eg. Z +=1 ; AA.Framework.setPropertyClassRec(cacheData(Z))
*    Z +=1 ; CommonVariable.3(cacheData(Z))                 ;* <== eg. Z +=1 ; AF.Framework.setProductArr(cacheData(Z))
*    Z +=1 ; CommonVariable.4(cacheData(Z))                 ;* <== eg. Z +=1 ; AF.Framework.setDatedId(cacheData(Z))
*    Z +=1 ; CommonVariable.5(cacheData(Z))                 ;* <== eg. Z +=1 ; AA.Framework.setCcyId(cacheData(Z))
*
*    Increase Z as required to load the common variables from cache
*
RETURN
*** </region>
*----------------------------------------------------------------------------
END
    
