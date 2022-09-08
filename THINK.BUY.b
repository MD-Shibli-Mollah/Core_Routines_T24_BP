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

* Version 1 31/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>9</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.ModellingAddins
    SUBROUTINE THINK.BUY(SAM.CODE,R.IN,TOT.DIFF.VALUE,REBALANCE,R.OUT)
*========================================================================
* SAM.CODE : SEC.ACC.MASTER id for which positions are to be bought.
* R.IN<1> : Securities which are eligible for buying.
* R.IN<2> : Position of securities in R.IN<1>
* R.IN<3> : Nominal of securities in R.IN<1>
* TOT.DIFF.VALUE<1> : The total valuation of the portfolio.
* TOT.DIFF.VALUE<2> : The difference value to be bought.
* REBALANCE : Indicate if rebalancing is to be done using
*             recommended stock list.
* R.OUT<1> : Security codes for which buying is recommended.
* R.OUT<2> : Value of the securities to be bought.
*     Author :
*     Date   : 01/06/2001
*========================================================================
* Details of all modifications in the format :
*
* 14/09/00 - GLOBUS_EN_10000185 - DEFINE NATURE OF EACH CELL
*            Append REBALANCE field
*
* 21/01/2003 - GLOBUS_EN_10001613 - Performance optimisation.
*
* 20/06/2003 - GLOBUS_CI_10010069 AM-Reco Neg. Rating not properly
*              read in JBase
*
* 17/05/07 - CI_10049112
*            Am.compare recommended ORDERS are wrong when comparison
*            is done against a MATRIX built using AM.BUILD.MODEL.
*
* 27/03/2008 - BG_100017886
*              Incorrect weighting is being applied to securities.
*
* 05/03/12 - Enhancement_322511 Task_340838
*            Group Portfolio Rebalancing
*
* 24/03/15 - Enhancement_1269516 Task_1292920
*            Componentisation.
*
* 29/07/15 -  ENHANCEMENT:1322379 TASK:1421332
*             Incorporation of AM.ModellingAddins
*========================================================================

    $USING AM.Foundation
    $USING SC.ScoPortfolioMaintenance
    $USING AM.Group
    $USING AM.Modelling
    $USING EB.ErrorProcessing
    $USING EB.SystemTables
*========================================================================
* Main controlling section
*========================================================================
    R.OUT = ''
    RATING.LIST = ''
    OPTIONS = ''
    DIFF.REST = TOT.DIFF.VALUE<2>
    VALUATION.AMT = TOT.DIFF.VALUE<1>
    TMP.POSN = ''
*
* Get the target sizing

    GOSUB GET.INVESTMENT.DETAILS
*
    IF REBALANCE EQ "RCD" THEN
        OPTIONS<1> = INV.OBJECTIVE
        OPTIONS<2> = INV.SIZING
        *
        * Get the rating and ranks of the securities.
        AM.Foundation.GetRating(R.IN<1>,OPTIONS,RATING.LIST)
        R.IN<4> = RATING.LIST<1>
        R.IN<5> = RATING.LIST<2>
        * Get the target weight for the recommendation.
        R.IN<6> = RATING.LIST<3>
        *
        * Sort by rank.
        FOR I = 1 TO DCOUNT(R.IN<1>,@VM)
            LOCATE R.IN<5,I> IN TMP.POSN<5,1> BY "DN" SETTING POSN ELSE NULL
            * Security Code
            TMP.POSN = INSERT(TMP.POSN,1,POSN,0;R.IN<1,I>)
            * Security Position (Value)
            TMP.POSN = INSERT(TMP.POSN,2,POSN,0;R.IN<2,I>)
            * Security Nominal
            TMP.POSN = INSERT(TMP.POSN,3,POSN,0;R.IN<3,I>)
            * Security Rating
            TMP.POSN = INSERT(TMP.POSN,4,POSN,0;R.IN<4,I>)
            * Security Rank
            TMP.POSN = INSERT(TMP.POSN,5,POSN,0;R.IN<5,I>)
            * Security Weight or Allowed percentage value of portfolio from Recommendation
            TMP.POSN = INSERT(TMP.POSN,6,POSN,0;R.IN<6,I>)
        NEXT I
        *
        R.IN = TMP.POSN
    END
*
    NB.POS = DCOUNT(R.IN<1>,@VM)
    FOR POS = 1 TO NB.POS
        IF REBALANCE EQ "MOD" OR R.IN<4,POS> NE '' THEN
            GOSUB CHECK.IDEAL.WEIGHT
        END
    UNTIL DIFF.REST LE 0
    NEXT POS

    RETURN
*========================================================================
* Subroutines
*========================================================================

*-----------------------------------------------------------------------------

*** <region name= GET.INVESTMENT.DETAILS>
GET.INVESTMENT.DETAILS:
***
    R.SEC.ACC.MASTER = ''
    YERR = ''
    INVESTMENT.PROGRAM = ''
    ID.SEC.ACC.MASTER = SAM.CODE
    IF ID.SEC.ACC.MASTER NE '' THEN
        R.SEC.ACC.MASTER = SC.ScoPortfolioMaintenance.SecAccMaster.Read(ID.SEC.ACC.MASTER, YERR)
        * Before incorporation : CALL F.READ('F.SEC.ACC.MASTER',ID.SEC.ACC.MASTER,R.SEC.ACC.MASTER,"",YERR)
    END

    IF AM.Modelling.getGrpFlag() THEN		; * If it is for group, then pick up the invest prog from AM.PORT.TYPE or AM.GROUP.TYPE.
        AM.PORT.TYPE.ID = R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamPortClassType>
        R.PORT.TYPE = AM.Group.PortType.Read(AM.PORT.TYPE.ID, APT.ERR)
        * Before incorporation : CALL F.READ('F.AM.PORT.TYPE',AM.PORT.TYPE.ID,R.PORT.TYPE,"",APT.ERR)
        INVESTMENT.PROGRAM = R.PORT.TYPE<AM.Group.PortType.PtySupportModel>
        IF NOT(INVESTMENT.PROGRAM) THEN
            tmp.RBL.GRP.CODE = AM.Modelling.getRblGrpCode()
            R.GROUP.PORT = AM.Group.GroupPort.Read(tmp.RBL.GRP.CODE, AGP.ERR)
            * AM.Modelling.setRblGrpCode(tmp.RBL.GRP.CODE)
            * Before incorporation : CALL F.READ('F.AM.GROUP.PORT',RBL.GRP.CODE,R.GROUP.PORT,"",AGP.ERR)
            INVESTMENT.PROGRAM = R.GROUP.PORT<AM.Group.GroupPort.AgpInvestmentProgram>
        END
    END ELSE
        INVESTMENT.PROGRAM = R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamInvestmentProgram>
    END

    INVESTMENT.PROGRAM.ID = INVESTMENT.PROGRAM
    R.INVESTMENT.PROGRAM = ''
    IF INVESTMENT.PROGRAM.ID NE '' THEN
        R.INVESTMENT.PROGRAM = SC.ScoPortfolioMaintenance.InvestmentProgram.CacheRead(INVESTMENT.PROGRAM.ID, YERR)
        * Before incorporation : CALL CACHE.READ('F.INVESTMENT.PROGRAM',INVESTMENT.PROGRAM.ID,R.INVESTMENT.PROGRAM,YERR)
    END
    INV.SIZING = R.INVESTMENT.PROGRAM<SC.ScoPortfolioMaintenance.InvestmentProgram.ScInvSizing>
    INV.OBJECTIVE = R.INVESTMENT.PROGRAM<SC.ScoPortfolioMaintenance.InvestmentProgram.ScInvInvObjective>

    AM.SIZING.ID = INV.SIZING
    R.AM.SIZING = ''
    IF AM.SIZING.ID NE '' THEN
        R.AM.SIZING = AM.Foundation.Sizing.CacheRead(AM.SIZING.ID, YERR)
        * Before incorporation : CALL CACHE.READ('F.AM.SIZING',AM.SIZING.ID,R.AM.SIZING,YERR)
    END

    TARGET.WEIGHT = R.AM.SIZING<AM.Foundation.Sizing.SizTargetWeight>
*... The target weight on the AM.SIZING record allows us to specify the maximum holding
*... for any individual security bought under this investement program.
*... i.e. No more than 5% of the portfolios value in any single security.
*... If no sizing record is specified on the the Investment program or the sizing record is
*... not specified then we have chosen not impose a restriction at this level so we allow 100%
    IF TARGET.WEIGHT EQ '' THEN
        TARGET.WEIGHT = 100
    END

    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= CHECK.IDEAL.WEIGHT>
CHECK.IDEAL.WEIGHT:
***
    RECCOMENDED.WEIGHT =  R.IN<6,POS>
    IF RECCOMENDED.WEIGHT NE '' AND RECCOMENDED.WEIGHT LT TARGET.WEIGHT THEN
        *... If we have a weighting from the recommendation and it is smaller than
        *... the weighting from the sizing record then use the
        IDEAL.WEIGHT = RECCOMENDED.WEIGHT
    END ELSE
        *... Use the weight from the sizing record.
        IDEAL.WEIGHT = TARGET.WEIGHT
    END

    CURRENT.HOLDING = R.IN<2,POS>
    MAX.ALLWD.HOLDING = VALUATION.AMT * IDEAL.WEIGHT / 100
    RECOMMEND.BUY = MAX.ALLWD.HOLDING - CURRENT.HOLDING


    IF RECOMMEND.BUY GT 0 THEN
        *... If we do not already have more of this security than we are allowed to hold
        IF RECOMMEND.BUY < DIFF.REST THEN
            *... If we want all that we are allowed then take it all.
            POS.BUY = RECOMMEND.BUY
        END ELSE
            *... Otherwise limit it to the amount specified in the grid.
            POS.BUY = DIFF.REST
        END

        *... Set the variable that deternines how much more we need to buy.
        DIFF.REST = DIFF.REST - POS.BUY
        *... Security code
        R.OUT<1,-1> = R.IN<1,POS>
        *... Value to buy
        R.OUT<2,-1> = POS.BUY

    END

    RETURN
*** </region>

*------------
FATAL.ERROR:
*------------

    EB.SystemTables.setText(EB.SystemTables.getE())
    EB.ErrorProcessing.FatalError('THINK.BUY')

    END
