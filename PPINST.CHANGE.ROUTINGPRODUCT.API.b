* @ValidationCode : MjoxNzYyNzkyNTQ1OkNwMTI1MjoxNjA2ODAwOTM2Nzg4OnZlbHVtYW5pLnBvbm51c2FteToyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDExLjIwMjAxMDI5LTE3NTQ6MTY6MTY=
* @ValidationInfo : Timestamp         : 01 Dec 2020 11:05:36
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : velumani.ponnusamy
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 16/16 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE PPINST.Foundation
SUBROUTINE PPINST.CHANGE.ROUTINGPRODUCT.API(iTransactionContext, iProductDetails, iAdditionalInfo,iReserved2,oOutput,oOutProductDetails,outResponse)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------
* 25/11/2020 - Defect 4094416 / Task 4095614 - Determine the routing product based on the product installed

*-----------------------------------------------------------------------------
    $USING EB.API
   
    GOSUB Initialise ; *Initialise the variables
    GOSUB Process ; *Determine the routing product based on the product installed
    
RETURN
*-----------------------------------------------------------------------------

*** <region name= Initialise>
Initialise:
*** <desc>Initialise the variables </desc>
    oOutput=''
    oOutProductDetails=''
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Process>
Process:
*** <desc> check if the product is installed </desc>
    productId1 = 'PPITIP'
    ppitipInstalled = ''
    EB.API.ProductIsInSystem(productId1, ppitipInstalled) ;* Check if PPITIP is installed in the System
    
    BEGIN CASE
        CASE ppitipInstalled EQ 1
            oOutput ="TIPS"
        CASE 1
            oOutput =""
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
    
END
