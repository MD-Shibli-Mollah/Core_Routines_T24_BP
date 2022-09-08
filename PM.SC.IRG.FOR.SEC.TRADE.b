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
* <Rating>-36</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PM.Engine
    SUBROUTINE PM.SC.IRG.FOR.SEC.TRADE(R.STP,PM.SC.POSN.CLASS,PROCESSED,RESERVED.2,RESERVED.1)

*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Description </desc>

*This subroutine will be attached to the field BOND.YTM.GAP of PM.SC.PARAM.
*
*The input parameters are
*
*R.STP- which holds the SC.TRADING.POSITION record
*PM.SC.POSN.CLASS -  a dynamic array which holds posn class name alone.
*
*The outgoing parameters are
*
*PROCESSED - returns '1' if  rate and amount processing done and returns '0' if unprocessed.
*
*PM.SC.POSN.CLASS - A Dynamic Array which holds the following information.
*                                   PM.MA.ASST.LIAB.CD - null
*                                   PM.MA.POSN.CLASS - Position Class name.
*                                   PM.MA.CCY.AMT - Acquired Amount
*                                   PM.MA.RATE - YTM
*                                   PM.MA.VALUE.DATE - null
*
*Reserved fields:
*
*RESERVED.2,RESERVED.1-Reserved for future use.

*This subroutine makes the PM.GAP enquiry to project constant YTM
*and vary the bond nominal on every day cob such that the premium/discount
*will be amortised evenly over the bond period.

*-----------------------------------------------------------------------------

*** </region>*** <region name= Modification History>
*** <desc>Modification History </desc>

* 19/06/2014 - Enhancement 993576 / Task 993586
*              Amount and YTM in Interest rate gap to be projected as per bank's requirement.
*
* 01/11/15 - EN_1226121/Task 1499688
*			 Incorporation of routine
*** </region>

*-----------------------------------------------------------------------------



*** <region name= INSERTS>
*** <desc>Inserts </desc>



    $USING SC.SctDealerBookPosition
    $USING SC.SctPriceTypeUpdateAndProcessing
    $USING SC.ScoSecurityMasterMaintenance
    $USING EB.DataAccess
    $USING PM.Engine



*** </region>
*-----------------------------------------------------------------------------

*** <region name= Process workflow>
*** <desc>Process workflow </desc>

    GOSUB INITIALISE
    GOSUB PROCESS.RATE        ;*Process rate and amount fetched from STP

    RETURN


*** </region>

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise all variables and open the required files. </desc>

    FN.PRICE.TYPE="F.PRICE.TYPE"
    F.PRICE.TYPE=''
    EB.DataAccess.Opf(FN.PRICE.TYPE,F.PRICE.TYPE);*Open PRICE.TYPE table

    FN.SECURITY.MASTER="F.SECURITY.MASTER"
    F.SECURITY.MASTER=''
    EB.DataAccess.Opf(FN.SECURITY.MASTER,F.SECURITY.MASTER);*Open SCEURITY.MASTER

    SEC.MASTER.ID=R.STP<SC.SctDealerBookPosition.TradingPosition.TrpSecurityCode>;*read security master ID from STP

    R.SEC.MASTER = SC.ScoSecurityMasterMaintenance.SecurityMaster.Read(SEC.MASTER.ID, READ.ERR);*read the respective security master.
* Before incorporation : CALL F.READ('F.SECURITY.MASTER',SEC.MASTER.ID,R.SEC.MASTER,F.SECURITY.MASTER,READ.ERR);*read the respective security master.

    PRICE.TYPE.ID = R.SEC.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmPriceType>;*extract price type id  from security master.

    R.PRICE.TYPE = SC.SctPriceTypeUpdateAndProcessing.PriceType.Read(PRICE.TYPE.ID, READ.ERR);*read price type record.
* Before incorporation : CALL F.READ('F.PRICE.TYPE',PRICE.TYPE.ID,R.PRICE.TYPE,F.PRICE.TYPE,READ.ERR);*read price type record.

    BOND.OR.SHARE = R.SEC.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmBondOrShare>;*extract bond or share value from sec master.

    DISC.INSTRUMENT=R.PRICE.TYPE<SC.SctPriceTypeUpdateAndProcessing.PriceType.PrtDiscInstrument>;*extract disc instrument from price type.

    POSN.CLASS=PM.SC.POSN.CLASS<1,PM.Engine.PmMatActivity.MaPosnClass>

    PROCESSED=''

    RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= PROCESS.RATE>
PROCESS.RATE:
*** <desc>Process rate and amount fetched from STP </desc>


    IF DISC.INSTRUMENT EQ 'Y' AND BOND.OR.SHARE = 'B' AND POSN.CLASS EQ 'SCGSM' THEN

        AMORTISED.AMT= R.STP<SC.SctDealerBookPosition.TradingPosition.TrpAmortisedAmount>       ;*Extract amortised amount from STP.
        COST.OF.POSITION=R.STP<SC.SctDealerBookPosition.TradingPosition.TrpVDateCostOfPos>   ;*Extract Cost of Position from STP.
        AMOUNT=COST.OF.POSITION + AMORTISED.AMT   ;*Current Cost of Bond.
        RATE = R.STP<SC.SctDealerBookPosition.TradingPosition.TrpVDatedYldToMat>   ;*retrieval of YTM.
        PROCESSED = 1


        PM.SC.POSN.CLASS<1,PM.Engine.PmMatActivity.MaAsstLiabCd>=''
        PM.SC.POSN.CLASS<1,PM.Engine.PmMatActivity.MaRate >=RATE
        PM.SC.POSN.CLASS<1,PM.Engine.PmMatActivity.MaCcyAmt>=AMOUNT
        PM.SC.POSN.CLASS<1,PM.Engine.PmMatActivity.MaValueDate >=''


    END ELSE

        PROCESSED=0
        PM.SC.POSN.CLASS=''
    END

    RETURN

    RETURN
*** </region>
