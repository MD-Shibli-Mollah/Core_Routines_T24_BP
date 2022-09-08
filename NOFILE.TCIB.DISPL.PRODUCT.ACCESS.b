* @ValidationCode : MTotMjExNTgxNDQyMjpDcDEyNTI6MTU4NjE3MTg0MDcwODprdmVua2F0ZXNoOjM6MDotNDE6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE2MDguMDo1Mzo0OA==
* @ValidationInfo : Timestamp         : 06 Apr 2020 16:47:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kvenkatesh
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : -41
* @ValidationInfo : Coverage          : 48/53 (90.5%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201608.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>5</Rating>  
*-----------------------------------------------------------------------------
    $PACKAGE T2.ModelBank         
    SUBROUTINE NOFILE.TCIB.DISPL.PRODUCT.ACCESS(OUT_ARRAY)  
*------------------------------------------------------------------------------
* Attached to : STANDARD.SELECTION record NOFILE.TCIB.DISPL.PRODUCT.ACCESS
* Incoming    : N/A
* Outgoing    : Product Access Details
*------------------------------------------------------------------------------
* Description:
* Routine will populate the EXT variables by reading the Channel Permission
*--------------------------------------------------------------------------------
* Modification History :
*----------------------
* 01/07/14 - Enhancement 1001222/Task 1001223
*            TCIB : User management enhancements and externalisation
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*            Incorporation of T components
*
* 31/03/16 - Defect 1674622 / Task 1682071
*            TCIB User management enquiry design issues in T24 browser
*
* 11/08/16 - Defect 1816296 / Task 1822921
*            TCIB user management simulator displays wrong results when product access alone is setup for external user
*--------------------------------------------------------------------------------

    $USING AA.ARC  
    $USING AA.Framework
    $USING EB.Reports
*
    GOSUB INITIALIZE
    GOSUB MAIN.PROCESS 
*
    RETURN
*------------------------------------------------------------------------------
INITIALIZE:
* Initialise Required Variables
    OUT_ARRAY = ""                          ;* Output array
    COUNTER = ""                           
    PROD.GRP.COUNT = ""                     ;* To find number of Transact product group
    PROD.GRP.COUNT.SEE = ""                 ;* To find number of See product group
    PERMISSION = ""                         ;* Permission for product group
    PROPERTY.CLASS.ID = "PRODUCT.ACCESS"
    PROD.GROUP = ""
    PROD.LIST = ""
*
    RETURN
*--------------------------------------------------------------------------------
MAIN.PROCESS:
* To get Product Access Details
    LOCATE "ARRANGEMENT" IN EB.Reports.getDFields()<1> SETTING ENQ.POS THEN
    ARRANGEMENT.ID = EB.Reports.getDRangeAndValue()<ENQ.POS>         ;* To get arrangement Id
    NEW.ARRANGEMENT.ID = ARRANGEMENT.ID:'//AUTH'        ;*read the AUTH record directly
    AA.Framework.GetArrangementConditions(NEW.ARRANGEMENT.ID,PROPERTY.CLASS.ID,"","",PROPERTY.IDS,PROPERTY.RECORD,RET.ERR) ;* To get product conditions based on the property class
    IF NOT(RET.ERR) THEN
        R.PRODUCT.ACCESS.REC = RAISE(PROPERTY.RECORD)   ;* Tp get product access record
        IF R.PRODUCT.ACCESS.REC<AA.ARC.ProductAccess.ProdaActivity> EQ "" THEN
            EB.Reports.setEnqError("EB-CHNL.PERM.NOT.DEFINE")
        END ELSE
            GOSUB BUILD.FINAL.ARRAY
        END
    END ELSE
        EB.Reports.setEnqError(RET.ERR)
    END
    END ELSE 
    EB.Reports.setEnqError("EB-INVALID.ARRANGEMENT")
    END
*
    RETURN 
*---------------------------------------------------------------------------------------
BUILD.FINAL.ARRAY:
* To build the final output array
    OUT_ARRAY<-1> = R.PRODUCT.ACCESS.REC<AA.ARC.ProductAccess.ProdaActivity>                   ;* To get Product activity
    PROD.LIST = R.PRODUCT.ACCESS.REC<AA.ARC.ProductAccess.ProdaProdGrpTrans>
    IF (PROD.LIST) THEN
    PROD.GROUP<1, -1> = PROD.LIST
    PROD.LIST = ""
    END
    PROD.LIST = R.PRODUCT.ACCESS.REC<AA.ARC.ProductAccess.ProdaProdGrpSee>
    IF (PROD.LIST) THEN
    PROD.GROUP<1, -1> = PROD.LIST
    PROD.LIST = ""
    END
    OUT_ARRAY<-1> = PROD.GROUP               ;* To get Product Group
    PROD.GRP.COUNT = DCOUNT(R.PRODUCT.ACCESS.REC<AA.ARC.ProductAccess.ProdaProdGrpTrans>, @VM) ;* Number of Trans Product Groups
    PROD.GRP.COUNT.SEE = DCOUNT(R.PRODUCT.ACCESS.REC<AA.ARC.ProductAccess.ProdaProdGrpSee>, @VM) ;* Number of See Product Groups
    FOR COUNTER = 1 TO PROD.GRP.COUNT
        PERMISSION<1,-1> = "Transact"                                                 ;* Permission level
    NEXT COUNTER
    FOR COUNTER = 1 TO PROD.GRP.COUNT.SEE
        PERMISSION<1,-1> = "See"                                                      ;* Permission level
    NEXT COUNTER
    OUT_ARRAY<-1> = PERMISSION                                                        ;*To display the permission
    OUT_ARRAY = CHANGE(OUT_ARRAY, @FM, "*")
*    
    RETURN
*---------------------------------------------------------------------------------------
    END
