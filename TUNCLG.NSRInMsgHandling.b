* @ValidationCode : MjotMTA3MjM3NTE5MTpDcDEyNTI6MTYwMzI5MTA2OTU2MjpzYXJtZW5hczotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDguMjAyMDA3MzEtMTE1MTotMTotMQ==
* @ValidationInfo : Timestamp         : 21 Oct 2020 20:07:49
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sarmenas
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PPTNCL.Foundation
SUBROUTINE TUNCLG.NSRInMsgHandling(NSRValue,iBatchFileStoreRecID,oNSROutput)
*-----------------------------------------------------------------------------
*TestApi to accept NSR deatils
*-----------------------------------------------------------------------------
* Modification History :
*15/09/2020 - Enhancement 3579741/Task 3970816-Payments-BTunisia- CHEQUE OPERATIONS
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    GOSUB initialise
    
RETURN

*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc> </desc>
    oNSROutput = 1
RETURN
*** </region>


*-----------------------------------------------------------------------------


END
