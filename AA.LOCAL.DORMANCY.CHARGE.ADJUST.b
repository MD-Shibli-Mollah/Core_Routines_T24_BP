* @ValidationCode : Mjo2MjE2MDM1MDc6Q3AxMjUyOjE1NDY1MTA2MDI1Njg6cmplZXZpdGhrdW1hcjoxOjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTkwMS4yMDE4MTIyNS0wMzQ5OjM5OjMz
* @ValidationInfo : Timestamp         : 03 Jan 2019 15:46:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rjeevithkumar
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 33/39 (84.6%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201901.20181225-0349
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-106</Rating>
*-----------------------------------------------------------------------------

$PACKAGE AA.Dormancy

SUBROUTINE AA.LOCAL.DORMANCY.CHARGE.ADJUST(ArrangementId, ArrCcy, EffectiveDate, ChargeProperty, ChargeType, RChargeRecord, BaseAmount, PeriodStartDate, PeriodEndDate, SourceActivity, ChargeAmount, AdjustedChargeAmount, NewChargeAmount, AdjustmentReason)

*** <region name= Description>
*** <desc>Task of the sub-routine</desc>
* Program Description
*
** This program will return avaialble working balance as charge amount
** when the charge amount is greater than the balance amount
** to avoid overdrawing of dormant account.
** Applicable only for debit type charge property
** Sample API to adjust the charge calculated by the core engine.
*
** In order to adjust the calculated charge this routine should be attached in the field
** CHARGE.OVERRIDE.ROUTINE in the AA.XXX.CHARGE application.
*
*-----------------------------------------------------------------------------
* @package AA.Dormancy
* @stereotype subroutine
* @author mdeepa@temenos.com
*-----------------------------------------------------------------------------
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Arguments>
*** <desc>Input and output arguments required for the sub-routine</desc>
* Arguments
* Input
*
* ArrangementId           - Arrangement ID of the contract.
* ArrCcy                  - Arrangement Currency
* EffectiveDate           - Activity effective date
* ChargeProperty          - Charge property on which the adjustment has to be done.
* ChargeType              - Charge property type
* RChargeRecord           - Arrangement charge condition
* BaseAmount              - Arrangement base balance or count
* PeriodStartDate         - Start of the period within which charges have to be calculated
* PeriodEndDate           - End of the period
* SourceActivity          - Activity references
* ChargeAmount            - Core calculated charge amount
*
* Output
*
* AdjustedChargeAmount    - Adjusted charge amount based on this routine's logic.
* NewChargeAmount         - Return the new Amount after doing the adjustment, this will be treated as the new charge amount by core.
* AdjustmentReason        - Reason for the charge adjustment, if not reason specified then send back the API's description or API name (from EB.API)
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name = Modification History>
*** <desc>Changes done in the sub-routine</desc>
*-----------------------------------------------------------------------------
* Modification History :
*
* 30/03/16 - Task : 1682755
*            Enhancement : 1224672
*            New local API routine to adjust the calculated charge(only for debit type) for dormant account
*
* 13/02/17 - Task : 2018366
*            Defect : 2018346
*            When the available balance is less than or equal to zero API should return 0 as charge amount.
*-----------------------------------------------------------------------------

    $USING AA.Framework
    $USING AA.Settlement
    $USING AA.PaymentSchedule

*-----------------------------------------------------------------------------

    GOSUB Initialise               ;* Initialise the local variables
    GOSUB AdjustCharge             ;* Do the main logic of adjusting charge of dormant account

RETURN

*-----------------------------------------------------------------------------

*** <region name= Initialise>
Initialise:
*** <desc>Initialise the local variables </desc>

    AdjustedChargeAmount = ""
    NewChargeAmount = ""
    AdjustmentReason = ""
    
    DormancyStatus = ""
    
    WorkingBalance = 0
    RetErr = ""

RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= AdjustCharge>
AdjustCharge:
*** <desc>Main process of this routine starts here </desc>

    IF ChargeAmount THEN                                    ;* Go further only when there is charge amount
        GOSUB GetArrDormancyStatus                          ;* Get the dormancy status of the arrangement
        IF DormancyStatus AND ChargeType EQ "DEBIT" THEN    ;* Go further only when the arrangement account is dormanct and the charge type is debit
            GOSUB GetWorkingBalance                         ;* Get the working balance
            GOSUB CalculateCharge                           ;* Calculate the charge based on avaialble working balance
        END
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetArrDormancyStatus>
GetArrDormancyStatus:
*** <desc>Get the dormancy status </desc>

    AA.PaymentSchedule.GetDormancyStatus(ArrangementId,DormancyStatus,'','','')

RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= GetWorkingBalance>
GetWorkingBalance:
*** <desc> Get the working balance of the arrangement</desc>
    
    AA.Framework.GetArrangementAccountId(ArrangementId,ArrAccount,'',RetErr)    ;* Get the arrangement account number
    IF NOT(RetErr) THEN
        InOutParam = ArrAccount
        AA.Settlement.GetAccountsWorkingBalance(InOutParam,"EXCL.LIMIT",ArrCcy)    ;* Get the available working balance for the arrangement
        WorkingBalance = InOutParam
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= CalculateCharge>
CalculateCharge:
*** <desc> Calculate the charge based on the available working balance </desc>

    BEGIN CASE
        CASE WorkingBalance LE 0
            NewChargeAmount = 0                                     ;*
            AdjustmentReason = "Balance already overdrawn/zero. Cannot overdraw a Dormant Account"
         
        CASE ChargeAmount GT WorkingBalance                          ;* Calculate NewChargeAmount only when the charge amount is greater than available working balance
            NewChargeAmount = WorkingBalance                            ;* when actual charge amount is greater than the available working balance then deduct only the working abalance available.
            AdjustedChargeAmount = ChargeAmount - NewChargeAmount
            AdjustmentReason = "Insufficient Balance. Cannot overdraw a Dormant Account"
        CASE 1
            NewChargeAmount = ChargeAmount
    END CASE

RETURN

*** </region>

*-----------------------------------------------------------------------------


END
