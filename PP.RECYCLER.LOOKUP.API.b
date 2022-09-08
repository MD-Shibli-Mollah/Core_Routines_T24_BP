* @ValidationCode : Mjo1MTg2MTYyMDc6Q3AxMjUyOjE1OTEwOTI1NDc0OTI6c2F0aGl5YXZlbmRhbjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDIuMjAyMDAxMTctMjAyNjotMTotMQ==
* @ValidationInfo : Timestamp         : 02 Jun 2020 15:39:07
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sathiyavendan
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------

$PACKAGE PP.BalanceCheckService

SUBROUTINE PP.RECYCLER.LOOKUP.API(irPaymentObject, orRequestTypeSubType)

*-----------------------------------------------------------------------------
* Company Name   : TEMENOS
* Developed By   : sathiyavendan@temenos.com
* Program Name   : PP.RECYCLER.LOOKUP.API
* Module Name    : PP
* Component Name : PP_BalanceCheckService
*-----------------------------------------------------------------------------
* Description    : This is a sample API for Recycler lookup process
* Linked with    : Balance Check processes
* In Parameter   :
*                  irPaymentObject = Payment Object Array
* Out Parameter  :
*                  orRequestTypeSubType = Request sub type used in recycler
*-----------------------------------------------------------------------------
* Modification Details:
* ---------------------
* 29/04/2020 - Enhancement-3171122/Task-3171123 - sathiyavendan@temenos.com
*              Newly created
*-----------------------------------------------------------------------------

*** <region name= inserts>
*** <desc>Insert Files </desc>

    $USING PP.BalanceCheckService

*** </region>


*-----------------------------------------------------------------------------

*** <region name= methodStart>
*** <desc>Start Of the Program </desc>

    GOSUB initialise ;* Para for initialise variable used by this method
    GOSUB process ;* Para for main process

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc>Para for initialise variable used by this method </desc>

    orRequestTypeSubType = ''
    originatingSource = irPaymentObject<PP.BalanceCheckService.PaymentRecord.originatingSource>
    outputChannel = irPaymentObject<PP.BalanceCheckService.PaymentRecord.outputChannel>

RETURN
*** </region>


*----------------------------------------------------------------------------

*** <region name= process>
process:
*** <desc>Para for main process </desc>

    BEGIN CASE
        CASE (originatingSource EQ "POA") AND (outputChannel EQ "STEP2")
            orRequestTypeSubType = "PP1"
        CASE (originatingSource EQ "POA") AND (outputChannel EQ "LEDGER")
            orRequestTypeSubType = "PP2"
        CASE (originatingSource EQ "OE") AND (outputChannel EQ "STEP2")
            orRequestTypeSubType = "PP5"
        CASE (originatingSource EQ "OE") AND (outputChannel EQ "LEDGER")
            orRequestTypeSubType = "PP6"
        CASE (originatingSource EQ "POA") AND NOT(outputChannel)
            orRequestTypeSubType = ''
    END CASE
    
RETURN
*** </region>


*----------------------------------------------------------------------------

END
