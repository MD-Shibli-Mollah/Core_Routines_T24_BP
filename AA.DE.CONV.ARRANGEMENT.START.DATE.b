* @ValidationCode : MjoxNTg5MTU2MDQ1OkNwMTI1MjoxNjE1NDc0MTA1NTk0OnRoYW5tYXlpa2w6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTAzLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 11 Mar 2021 20:18:25
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : thanmayikl
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE AA.DE.CONV.ARRANGEMENT.START.DATE(InValue,HeaderRec,MvNo,OutValue,ErrorMsg)
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 12/03/21 - Enhancement: 4203207
*            Task: 4226990
*            Arrangement start date conversion routine
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Common variables and file inserts</desc>
* Inserts

    $USING DE.Outward
    $USING AA.Framework
    $USING AA.PaymentSchedule
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process Logic>
*** <desc>Program Control</desc>

    GOSUB Initialise            ;* Initialise variables
    GOSUB DoProcess             ;* Main processing
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise all local variables required</desc>
Initialise:
    
    DIM RDetail(500)
    MAT RDetail = ''
    OutValue = ''
    
    ArrId = InValue
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= DoProcess>
*** <desc>Main Logic</desc>
DoProcess:

    tmp.FDO = DE.Outward.getFDeOMsg()
    tmp.Rkey = DE.Outward.getRKey()
    MATREAD RDetail FROM tmp.FDO,tmp.Rkey ELSE
        RETURN
    END

    GOSUB GET.ARRANGEMENT.START.DATE ;* Fetch arrangement start date
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.ARRANGEMENT.START.DATE>
GET.ARRANGEMENT.START.DATE:
*** <desc>Fetch arrangement start date</desc>
    
    AccountDetailsRec = ''
    StartDate = ''
    AA.PaymentSchedule.ProcessAccountDetails(ArrId, "GET" ,"GET", AccountDetailsRec, returnError)
    StartDate = AccountDetailsRec<AA.PaymentSchedule.AccountDetails.AdValueDate>
    OutValue = OCONV(ICONV(StartDate ,"D4"),"D4E")
    
RETURN
*** </region>

END

