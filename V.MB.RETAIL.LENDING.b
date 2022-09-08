* @ValidationCode : MjotMTA3OTg5NjkxMzpDcDEyNTI6MTQ5OTE3Mzc0MjgzMjpkc2F0aGlzaDotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxNzA1LjIwMTcwNTA1LTE0NDg6LTE6LTE=
* @ValidationInfo : Timestamp         : 04 Jul 2017 18:39:02
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : dsathish
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201705.20170505-1448
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-61</Rating>
*-----------------------------------------------------------------------------
* This subroutine is attached as an validation routine in the version EB.LENDING.HP,RETAIL.LENDING
* This routine is basically for validating the data input by the user and to throw error messages.
*===========================================================================================================
$PACKAGE EB.ModelBank
	
SUBROUTINE V.MB.RETAIL.LENDING
    
*
* 10/05/16 - Enhancement 1499014
*          - Task 1626129
*          - Routine incorporated
* 02/06/17 - Task - 2126511 /Enhancement - 2117822
*            Check has been done to execute AA line of codes only when product id is available
*------------------------------------------------------------------------------------------------------------
    $USING EB.SystemTables 
    $USING EB.ModelBank
    $USING LI.Config
    $USING AA.ProductManagement
    $USING EB.ErrorProcessing
	$USING EB.DataAccess
    $INSERT I_DAS.LIMIT

    GOSUB INITIALISE
    GOSUB VALIDATE.INPUT
    IF (LIM.REF) AND (YLIM.CUST) THEN
        GOSUB GET.LIMIT.NO
        GOSUB CHECK.PARENT.LIMIT
    END

RETURN

************
INITIALISE:
************
* All Initialisations done here

    YR.SYSTEM = ""

    LIM.REF = EB.SystemTables.getRNew(EB.ModelBank.EbLendingHp.EbLenEigNinLimitReference)
    YLIM.CUST = EB.SystemTables.getRNew(EB.ModelBank.EbLendingHp.EbLenEigNinCustomer)
        
    DAS.LIST = ""
    TABLE.SUFFIX = ""

RETURN

***************
VALIDATE.INPUT:
***************
* Validate the data input in the fields and throw error messages by calling the
* core routine ERR. Core routine LIMIT.GET.PRODUCT is called with Ccy, Customer No and Limit ref Id
* to check whether the given limit reference Id matches with the given product/category code based on
* the setup in LIMIT.PARAMETER.
*


    PRD.CCY = EB.SystemTables.getRNew(EB.ModelBank.EbLendingHp.EbLenEigNinCurrency)

  
    BEGIN CASE

        CASE EB.SystemTables.getRNew(EB.ModelBank.EbLendingHp.EbLenEigNinLimitReqd) NE 'YES'

            IF (EB.SystemTables.getRNew(EB.ModelBank.EbLendingHp.EbLenEigNinSecuredLimit) NE '') THEN

                EB.SystemTables.setAf(EB.ModelBank.EbLendingHp.EbLenEigNinSecuredLimit)
                EB.SystemTables.setE("Input allowed only when Limit Required is 'Yes'")
                EB.ErrorProcessing.Err()

            END

            IF (EB.SystemTables.getRNew(EB.ModelBank.EbLendingHp.EbLenEigNinLimitReference) NE '') THEN


                EB.SystemTables.setAf(EB.ModelBank.EbLendingHp.EbLenEigNinLimitReference)
                EB.SystemTables.setE("Input allowed only when Limit Required is 'Yes'")
                EB.ErrorProcessing.Err()

            END


        CASE EB.SystemTables.getRNew(EB.ModelBank.EbLendingHp.EbLenEigNinLimitReqd) EQ 'YES'

            IF (EB.SystemTables.getRNew(EB.ModelBank.EbLendingHp.EbLenEigNinSecuredLimit) EQ '') THEN

                EB.SystemTables.setAf(EB.ModelBank.EbLendingHp.EbLenEigNinSecuredLimit)
                EB.SystemTables.setE("Input mandatory  when Limit Required is 'Yes'")
                EB.ErrorProcessing.Err()
            END

            IF (EB.SystemTables.getRNew(EB.ModelBank.EbLendingHp.EbLenEigNinLimitReference) EQ '') THEN

                EB.SystemTables.setAf(EB.ModelBank.EbLendingHp.EbLenEigNinLimitReference)
                EB.SystemTables.setE("Input mandatory when Limit Required is 'Yes'")
                EB.ErrorProcessing.Err()

            END

    END CASE
    
 

    R.PRODUCT.ID = EB.SystemTables.getRNew(EB.ModelBank.EbLendingHp.EbLenEigNinAaProduct)
    
    IF R.PRODUCT.ID THEN ;* Only if Product ID is available
        R.ERR = ''
        R.PRODUCT.REC = AA.ProductManagement.ProductDesignerDatedXref.Read(R.PRODUCT.ID, R.ERR)

        IF NOT(R.ERR) THEN

            R.PRODUCT.ID = R.PRODUCT.ID:"-":R.PRODUCT.REC
            R.PRODUCT.REC = AA.ProductManagement.ProductDesigner.Read(R.PRODUCT.ID, R.ERR)

            LOCATE PRD.CCY IN R.PRODUCT.REC<AA.ProductManagement.ProductCatalog.PrdCurrency,1> SETTING POS ELSE

                EB.SystemTables.setE("Not A Valid Currency for this Product")
                EB.SystemTables.setAf(EB.ModelBank.EbLendingHp.EbLenEigNinCurrency)
                EB.ErrorProcessing.Err()

            END

        END
    END

RETURN

**************
GET.LIMIT.NO:
**************
* To form the next available limit for the given customer by getting the list of
* already existing Limit reference Ids.


    DAS.LIST = dasLimitIdsLike
    YLIM.REF = FMT(LIM.REF,"7'0'R")
    MY.ARGS = YLIM.CUST:".":YLIM.REF:"..."

    EB.DataAccess.Das("LIMIT",DAS.LIST,MY.ARGS,TABLE.SUFFIX)

    IF DAS.LIST THEN
        IDS.LIST = DAS.LIST
    END

    GOSUB GET.LIMIT.NO.NAU

RETURN

*****************
GET.LIMIT.NO.NAU:
****************

    TABLE.SUFFIX = "$NAU"

    DAS.LIST = dasLimitIdsLike

    EB.DataAccess.Das("LIMIT",DAS.LIST,MY.ARGS,TABLE.SUFFIX)

    IF DAS.LIST THEN
        IDS.LIST:=@FM:DAS.LIST
    END

    GOSUB GET.LIMIT.NO.HIS

RETURN

**************
GET.LIMIT.NO.HIS:
**************

    TABLE.SUFFIX = "$HIS"

    DAS.LIST = dasLimitIdsLike

    NEW.HIS.LIST = ''

    EB.DataAccess.Das("LIMIT",DAS.LIST,MY.ARGS,TABLE.SUFFIX)

    LOOP

        REMOVE LMT.HIS.ID FROM DAS.LIST SETTING LMT.HIS.POS

    WHILE LMT.HIS.ID:LMT.HIS.POS

        NEW.HIS.LIST<-1> = FIELD(LMT.HIS.ID,";",1)

    REPEAT

    IF NEW.HIS.LIST THEN

        IDS.LIST:=@FM:NEW.HIS.LIST

    END

    GOSUB FORM.FINAL.LIMIT.ID

RETURN

*******************
FORM.FINAL.LIMIT.ID:
*******************

    LOOP

        REMOVE LIMIT.ID FROM IDS.LIST SETTING POS
    WHILE LIMIT.ID:POS

        CNT<-1> = FMT(FIELD(LIMIT.ID,".",3),"2'0'R")

    REPEAT

    LIMIT.SER.NO = (MAXIMUM(CNT) + 1)

    LIMIT.SER.NO = FMT(LIMIT.SER.NO,"2'0'R")

    EB.SystemTables.setRNew(EB.ModelBank.EbLendingHp.EbLenEigNinLimitId, YLIM.CUST:".":YLIM.REF:".":LIMIT.SER.NO)


RETURN

*******************
CHECK.PARENT.LIMIT:
*******************
* To check if the given limit is child/parent limit, if it is a child limit
* then we check if the parent limit exists already else throw error message.


    YLIM.REF = FMT(LIM.REF,"7'0'R")

    IF YLIM.REF[6,2] THEN

        R.PARENT.KEY = YLIM.REF[1,5]:"00"

    END ELSE

        IF YLIM.REF[1,3] THEN

            IF YLIM.REF[4,4] THEN

                R.PARENT.KEY = YLIM.REF[1,3]:"0000"

            END ELSE

                IF YLIM.CUST THEN
                    R.PARENT.KEY = YLIM.REF
                END

            END
        END
    END

    IF R.PARENT.KEY THEN

        R.PARENT.KEY = YLIM.CUST:".":R.PARENT.KEY:".":LIMIT.SER.NO

        R.ERR = ''
        R.PARENT.REC = LI.Config.Limit.Read(R.PARENT.KEY, R.ERR)

        IF R.ERR THEN

            EB.SystemTables.setE("Parent Line not defined")
            EB.SystemTables.setAf(EB.ModelBank.EbLendingHp.EbLenEigNinLimitReference)

            EB.ErrorProcessing.Err()
        END

    END

RETURN
