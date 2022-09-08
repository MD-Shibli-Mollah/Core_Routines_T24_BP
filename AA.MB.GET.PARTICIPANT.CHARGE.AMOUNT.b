* @ValidationCode : MjoyMjkxMjU3Nzk6Q3AxMjUyOjE2MDIwNjk1NDA2NDQ6cmFuZ2FoYXJzaGluaXI6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNi4yMDIwMDUyMS0wNjU1OjI2OjI2
* @ValidationInfo : Timestamp         : 07 Oct 2020 16:49:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rangaharshinir
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 26/26 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AA.ModelBank
SUBROUTINE AA.MB.GET.PARTICIPANT.CHARGE.AMOUNT(ArrangementId, ArrActivityId, ArrangementCurrency, StartDate, ParticipantId, ChargeProperty, BorrChargePropAmount, PartChargePropAmount, RetError)
*** <region name= Synopsis of the Routine>
***
** This subroutine returns the Charge Property Amounts of Borrower and Participant for the incomimg activity reference.
**
***
*-----------------------------------------------------------------------------
* Input Arguments
*------------------
* ArrangementId : Arrangement ID
* ArrActivityId : Arrangement Activity ID
* ArrangementCurrency : Arrangement Currency
* StartDate : Start Date
* ParticipantId   : Participant ID
* ChargeProperty : Charge Property
*
* Output Arguments
*-----------------
* BorrChargePropAmount : Bill Charge Amount of the Borrower
* PartChargePropAmount : Bill Charge Amount of the Participant
*
* @uses         : AA.PaymentSchedule.GetParticipantChargeAmount, AA.ActivityCharges.ChargeDetails
* @access       : module
* @stereotype   : subroutine
* @author       : rangaharshinir@temenos.com
*-----------------------------------------------------------------------------
*
*** </region>
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 07/10/2020 - Task:3969739
*             Enhancement:3969736
*             To update charge details in the handoff
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
*** <region name= Inserts
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING AA.PaymentSchedule
    $USING AA.ActivityCharges
    $USING AA.Framework
    
*** </region>
*-----------------------------------------------------------------------------

    GOSUB ValidateArguments ; *To return error when there are no sufficient arguments passed

    IF NOT(RetError) THEN
        GOSUB Initialise ; *To initialise the variables
        GOSUB GetChargePropertyAmounts ; *To get Borrower and Participant Charge Property Amounts
    END

RETURN

*-----------------------------------------------------------------------------

*** <region name= Initialise>
Initialise:
*** <desc>To initialise the variables </desc>
    
    ChargeDetailsId = ""
    ChargeDetailsRec = ""
    ArrangementDetails = ""
    BorrChargePropAmount = ""
    PartChargePropAmount = ""
    RetError = ""

    ArrangementDetails<1> = ArrangementId
    ArrangementDetails<2> = ArrangementCurrency
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= ValidateArguments>
ValidateArguments:
*** <desc>To return error when there are no sufficient arguments passed </desc>
    IF NOT(ArrangementId) OR NOT(ArrangementCurrency) OR NOT(ArrActivityId) OR NOT(StartDate) OR NOT(ChargeProperty) THEN
        RetError = "Arguments Missing"
    END
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= GetChargePropertyAmounts>
GetChargePropertyAmounts:
*** <desc>To get Borrowerand Participant Charge Property Amounts </desc>
    ChargeDetailsId = ArrangementId:AA.Framework.Sep:ChargeProperty
    ChargeDetailsRec = AA.ActivityCharges.ChargeDetails.Read(ChargeDetailsId, "")

    LOCATE ArrActivityId IN ChargeDetailsRec<AA.ActivityCharges.ChargeDetails.ChgDetArrActivityId, 1> SETTING ActPos THEN
        BorrChargePropAmount = ChargeDetailsRec<AA.ActivityCharges.ChargeDetails.ChgDetBillAmt, ActPos>
    END

    AA.PaymentSchedule.GetParticipantChargeAmount(ArrangementDetails, StartDate, ParticipantId, ChargeProperty,BorrChargePropAmount,PartChargePropAmount,"","", RetError) ;* Routine to get the participant charge amount
RETURN
*** </region>

*-----------------------------------------------------------------------------

END



