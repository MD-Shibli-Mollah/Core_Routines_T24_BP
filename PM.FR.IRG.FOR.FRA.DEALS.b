* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-41</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FR.PositionAndReval
    SUBROUTINE PM.FR.IRG.FOR.FRA.DEALS(MAT DEAL.DETAILS,PM.FR.POSN.CLASS,PROCESSED,RESERVED.1,RESERVED.2)

*** <region name= Description>
*** <desc> </desc>
*      This subroutine should be attached to the local reference field FRA.LONG.RATE of PM.POSN.REFERENCE of 'GAP'.
*      The parameters of the routine are
*      Incoming Parameters :
*          DEAL.DETAILS           - Dimensioned array , which holds the contract details.
*
*     Outgoing Parameters :
*          PM.FR.POSN.CLASS - A Dynamic Array which holds the following information.
*                                   PM.MA.ASST.LIAB.CD - Asset / Liability
*                                   PM.MA.POSN.CLASS - Position Class
*                                   PM.MA.CCY.AMT - Amount
*                                   PM.MA.RATE - Reference Rate / Settlement Rate
*                                   PM.MA.VALUE.DATE - Start date / Maturity Date
*                PROCESSED - A flag to indicate whether the user exit routine has generated the position classes.
*                    RESERVED.1  -  Reserved for Future Use.
*                    RESERVED.2  -  Reserved for Future Use.
*
*      This routine returns an array of position classes and its corresponding rate , amount, asset / liability information.
*
*     For a Hedge Purchase deal, the position classes FRXDS, FRXDM should be assigned with the reference price.
*     For a Hedge Sale deal, the position classes FRXLS, FRXLM should be assigned with the reference prioe.
*
*      This routine can be modified in future , if needed to include any other position classes locally.
*
*** </region>
*------------------------------------------------------------------------------------------------------------------------------------
*<region name = Modification History>
* Modification History
*****************************************************
* 25/05/2014 - Enhancement 993576/ Task 993583
*              PM FRA Synthetic Modelling
*
* 30/12/15 - EN_1226121 / Task 1568411
*			 Incorporation of the routine
*</region>
*-----------------------------------------------------------------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc> </desc>



    $USING FR.Contract
    $USING PM.Engine


*** </region>

*** <region name= Process flow>
*** <desc> </desc>

    GOSUB INITIALISE
    GOSUB TO.MODIFY.MAT.ACTIVITY
    RETURN

*** </region>

*** <region name= INITIALISE>
*** <desc> </desc>
*-----------------------------------------
INITIALISE:
*-----------------------------------------

    PROCESSED = 0
    IF DEAL.DETAILS(FR.Contract.FraDeal.FrdFraType) NE 'HEDGE' THEN
        RETURN
    END

    AMT = ''
    SHORT.DATE = '' ; LONG.DATE = ''
    LOAN.RATE = '' ; DEPOSIT.RATE = ''
    ROW.COUNT = 0

    POSN.CLASS.DEPOSIT = '' ; POSN.CLASS.LOAN = '' ; NET.POSN.CLASS = ''
    VDATE = '' ; PM.FR.POSN.CLASS = ''

    ASST.CODE.LOAN = ''
    ASST.CODE.DEPOSIT = ''
    SIZE = FR.Contract.FraDeal.FrdAuditDateTime
    DIM DEAL.DETAILS(SIZE)

    AMT = DEAL.DETAILS(FR.Contract.FraDeal.FrdFraAmount)
    SHORT.DATE = DEAL.DETAILS(FR.Contract.FraDeal.FrdStartDate)
    LONG.DATE = DEAL.DETAILS(FR.Contract.FraDeal.FrdMaturityDate)
    IF DEAL.DETAILS(FR.Contract.FraDeal.FrdPurchaseSale) EQ 'SALE' THEN
        LOAN.RATE = DEAL.DETAILS(FR.Contract.FraDeal.FrdReferencePrice)
        DEPOSIT.RATE = DEAL.DETAILS(FR.Contract.FraDeal.FrdSettlementRate)
    END ELSE
        LOAN.RATE = DEAL.DETAILS(FR.Contract.FraDeal.FrdSettlementRate)
        DEPOSIT.RATE = DEAL.DETAILS(FR.Contract.FraDeal.FrdReferencePrice)
    END


    RETURN

*** </region>


*** <region name= TO.MODIFY.MAT.ACTIVITY>
*** <desc>PRE.START.ACTIVITY And POST.START.ACTIVITY </desc>
*------------------------------------------------------
TO.MODIFY.MAT.ACTIVITY:
*------------------------------------------------------

* Start Activity - Generation of FRXDS, FRXLS and net FRXNS activities.

    IF SHORT.DATE GE PM.Engine.getToday() THEN
        POSN.CLASS.DEPOSIT = 'FRXDS'
        POSN.CLASS.LOAN ='FRXLS'
        NET.POSN.CLASS = 'FRXNS'
        VDATE = SHORT.DATE
        ASST.CODE.LOAN = 2
        ASST.CODE.DEPOSIT = 1
        GOSUB BUILD.ACTIVITY
    END

* Mat Activity - Generation of FRXLM, FRXDM and net FRXNM activities.

    POSN.CLASS.DEPOSIT = 'FRXDM'
    POSN.CLASS.LOAN ='FRXLM'
    NET.POSN.CLASS = 'FRXNM'
    VDATE = LONG.DATE
    ASST.CODE.LOAN = 1
    ASST.CODE.DEPOSIT = 2
    GOSUB BUILD.ACTIVITY
    PROCESSED = 1

    RETURN

*** </region>

*** <region name= BUILD.ACTIVITY>
*** <desc>Builds the activity array </desc>
*---------------------------------------------------------
BUILD.ACTIVITY:
*---------------------------------------------------------

* Position Class for Loan

    ROW.COUNT = ROW.COUNT + 1
    PM.FR.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaAsstLiabCd> = ASST.CODE.LOAN
    PM.FR.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaPosnClass> = POSN.CLASS.LOAN
    PM.FR.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaCcyAmt> = AMT
    PM.FR.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaRate> = LOAN.RATE
    PM.FR.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaValueDate> = VDATE

* Position class for Deposit

    ROW.COUNT = ROW.COUNT+1
    PM.FR.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaAsstLiabCd> = ASST.CODE.DEPOSIT
    PM.FR.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaPosnClass> = POSN.CLASS.DEPOSIT
    PM.FR.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaCcyAmt> = AMT
    PM.FR.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaRate> = DEPOSIT.RATE
    PM.FR.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaValueDate> = VDATE

* Net Position Class

    ROW.COUNT = ROW.COUNT + 1

    BEGIN CASE
        CASE NET.POSN.CLASS = 'FRXNS'

            IF LOAN.RATE LE DEPOSIT.RATE THEN
                PM.FR.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaAsstLiabCd> = 1
            END ELSE
                PM.FR.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaAsstLiabCd> = 2
            END

        CASE 1
            IF LOAN.RATE GT DEPOSIT.RATE THEN
                PM.FR.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaAsstLiabCd> = 1
            END ELSE
                PM.FR.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaAsstLiabCd> = 2
            END

    END CASE

    PM.FR.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaPosnClass> = NET.POSN.CLASS
    PM.FR.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaCcyAmt> = AMT
    PM.FR.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaRate> =  ABS(LOAN.RATE - DEPOSIT.RATE)
    PM.FR.POSN.CLASS<ROW.COUNT,PM.Engine.PmMatActivity.MaValueDate> = VDATE


    RETURN

*** </region>

    END
