* @ValidationCode : MjotMzYzODM5OTQzOkNwMTI1MjoxNTcxNDAxMTYyMDA4Om1raXJ0aGFuYTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MTAuMjAxOTA5MjAtMDcwNzotMTotMQ==
* @ValidationInfo : Timestamp         : 18 Oct 2019 17:49:22
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mkirthana
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
$PACKAGE AA.PaymentRules
SUBROUTINE AA.PROCESS.PAYMENT.RULES.REPAYMENT(ArrangementIds,RepaymentAmount)
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
* Inout
* @param ArrangementIds                -  Arrangement ids
* @param RepaymentAmount               -  Repayment amount
*
*** </region>
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 27/09/19 - Task:
*            Enhancement:
*
* 18/10/19 - Task :3393874
*            RoundAmt is called for rounding the amount.
*            Defect : 3389588
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
*

    $USING EB.SystemTables
    $USING AA.PaymentPriority
    $USING AA.Framework
    $USING EB.API

*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>
  
    GOSUB Initialise
    GOSUB ProcessRepayment
    GOSUB ReturnValues

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialisation>
*** <desc>Initialise local variables and file variables</desc>
*==========*
Initialise:
*==========*
    
    InArrIds = ArrangementIds
    InRepayAmt = RepaymentAmount
            
* Clear incoming values
    ArrangementIds = ''
    RepaymentAmount = ''
    Localccy = EB.SystemTables.getLccy()
    
RETURN
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= ReturnValues>
*** <desc>Return values</desc>
*==========*
ReturnValues:
*==========*
    ArrangementIds = TermArrId
    RepaymentAmount = TempArrAmt
    
RETURN
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= ProcessRepayment>
*** <desc>Process Repayment</desc>
*===============*
ProcessRepayment:
*===============*
    
    ArrCnt = COUNT(InArrIds,@FM) + 1
    ArrAmt = InRepayAmt/ArrCnt           ;* Equally divide the repayment amount among all the arrangements
    EB.API.RoundAmount(Localccy, ArrAmt, '', '')
    FOR ArrPos = 1 TO ArrCnt
        TermArrId<ArrPos> = InArrIds<ArrPos>
        TempArrAmt<ArrPos> = ArrAmt
    NEXT ArrPos
    IF SUM(TempArrAmt) NE InRepayAmt THEN
        DiffAmt =  InRepayAmt - SUM(TempArrAmt)
        TempArrAmt<ArrPos> += DiffAmt
    END
RETURN
*
*** </region>
*-----------------------------------------------------------------------------
END
