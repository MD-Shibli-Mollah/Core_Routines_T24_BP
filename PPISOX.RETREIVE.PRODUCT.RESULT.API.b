* @ValidationCode : MjozMjA5NzA5NzA6Q3AxMjUyOjE2MDgxMjQxNzQ1MjA6c2hhcm1hZGhhczoyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA2LjIwMjAwNTI3LTA0MzU6Mjc6MjU=
* @ValidationInfo : Timestamp         : 16 Dec 2020 18:39:34
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sharmadhas
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 25/27 (92.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.



$PACKAGE PPISOX.Foundation
*
* API to determine routing product
*

*----------------------------------------------------------------
*Modification History :

* 31/08/2020 - Enhancement-3624412  Task -3936788 - Determine routing product
* 12/12/2020 - Enhancement-3777154  Task -4036061 - Determine routing product- PPESIC
* 16/12/2020 - Enhancement-3777154  Task -4136628 - Regression issue fix

*-----------------------------------------------------------------
SUBROUTINE PPISOX.RETREIVE.PRODUCT.RESULT.API(iTransactionContext, iProductDetails, iAdditionalInfo,iReserved2,oOutput,oOutProductDetails,outResponse)
   
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

    productId1 = 'PPEWSP'
    ppewspInstalled = ''
    EB.API.ProductIsInSystem(productId1, ppewspInstalled) ;* Check if PPEWSP is installed in the System
    
    productId2 = 'PPSPCT'
    ppspctInstalled = ''
    EB.API.ProductIsInSystem(productId2, ppspctInstalled) ;* Check if PPSPCT is installed in the System
    
    productId3 = 'PPSPDD'
    ppspddInstalled = ''
    EB.API.ProductIsInSystem(productId3, ppspddInstalled) ;* Check if PPSPDD is installed in the System
    
    productId4 = 'PPESIC'
    ppesicInstalled = ''
    EB.API.ProductIsInSystem(productId4, ppesicInstalled)
        
    BEGIN CASE
        CASE (ppewspInstalled EQ 1)  AND (ppspctInstalled EQ 1 OR ppspddInstalled EQ 1)
            oOutput ="SEPA"
        CASE (ppewspInstalled EQ 1)
            oOutput ="EWSEPA"
        CASE (ppesicInstalled EQ 1)
            oOutput ="EUROSIC"
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
