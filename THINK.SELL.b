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
* <Rating>362</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.ModellingAddins
    SUBROUTINE THINK.SELL(SAM.CODE,R.POSITION,TOT.DIFF.VALUE,REBALANCE,R.RET)
*========================================================================
* SAM.CODE : SEC.ACC.MASTER id for which positions are to be sold.
* R.POSITION<1> : Security codes for which positions are held.
* R.POSITION<2> : Position of securities in R.POSITION<1>
* R.POSITION<3> : Nominal of securities in R.POSITION<1>
* TOT.DIFF.VALUE<1> : The total valuation of the portfolio.
* TOT.DIFF.VALUE<2> : The difference value to be sold.
* REBALANCE : Indicate if rebalancing is to be done using
*             recommended stock list.
* R.RET<1> : Security codes for which selling is recommended.
* R.RET<2> : Value of the securities to be sold.
*     Author : XXX
*     Date   : 01/06/2001
*========================================================================
* Details of all modifications in the format :
*
* 14/09/00 - GLOBUS_EN_10000185 - DEFINE NATURE OF EACH CELL
*            Append REBALANCE field
*
* 20/06/2003 - GLOBUS_CI_10010069 AM-Reco Neg. Rating not properly
*              read in JBase
*
* 26/03/2008 - BG_100017852
*              Rebalancing does not open the correct investment program.
*
* 05/03/12 - Enhancement_322511 Task_340838
*            Group Portfolio Rebalancing
*
* 23/05/12 - Enhancement_355641 Task_396337
*            Rebalancing of a Parent portfolio.
*
* 24/03/15 - Enhancement_1269516 Task_1292920
*            Componentisation.
*
* 29/07/15 -  ENHANCEMENT:1322379 TASK:1421332
*             Incorporation of AM.ModellingAddins
*========================================================================

    $USING AM.Foundation
    $USING EB.ErrorProcessing
    $USING SC.ScoPortfolioMaintenance
    $USING AM.Group
    $USING AM.Modelling
    $USING EB.SystemTables
*========================================================================
* Main controlling section
*========================================================================

    R.RET = ''
    RATING.LIST = ''
    OPTIONS = ''
    DIFF.REST = TOT.DIFF.VALUE<2>
    VALUATION.AMT = TOT.DIFF.VALUE<1>
    TMP.POSN = ''

    IF REBALANCE EQ "RCD" THEN
        * Get the target sizing

        R.SEC.ACC.MASTER = ''
        YERR = ''
        INVESTMENT.PROGRAM = ''
        ID.SEC.ACC.MASTER = SAM.CODE
        R.SEC.ACC.MASTER = SC.ScoPortfolioMaintenance.SecAccMaster.Read(ID.SEC.ACC.MASTER, YERR)
        * Before incorporation : CALL F.READ('F.SEC.ACC.MASTER',ID.SEC.ACC.MASTER,R.SEC.ACC.MASTER,"",YERR)

        IF AM.Modelling.getGrpFlag() THEN		; * If it is for group, then pick up the invest prog from AM.PORT.TYPE or AM.GROUP.TYPE.
            AM.PORT.TYPE.ID = R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamPortClassType>
            R.PORT.TYPE = AM.Group.PortType.Read(AM.PORT.TYPE.ID, APT.ERR)
            * Before incorporation : CALL F.READ('F.AM.PORT.TYPE',AM.PORT.TYPE.ID,R.PORT.TYPE,"",APT.ERR)
            INVESTMENT.PROGRAM = R.PORT.TYPE<AM.Group.PortType.PtySupportModel>
            IF NOT(INVESTMENT.PROGRAM) THEN
                tmp.RBL.GRP.CODE = AM.Modelling.getRblGrpCode()
                R.GROUP.PORT = AM.Group.GroupPort.Read(tmp.RBL.GRP.CODE, AGP.ERR)
                AM.Modelling.setRblGrpCode(tmp.RBL.GRP.CODE)
                * Before incorporation : CALL F.READ('F.AM.GROUP.PORT',RBL.GRP.CODE,R.GROUP.PORT,"",AGP.ERR)
                INVESTMENT.PROGRAM = R.GROUP.PORT<AM.Group.GroupPort.AgpInvestmentProgram>
            END
        END ELSE
            INVESTMENT.PROGRAM = R.SEC.ACC.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamInvestmentProgram>
        END

        * MWT    CALL DBR("SEC.ACC.MASTER":FM:SC.SAM.INVESTMENT.PROGRAM,SAM.CODE,INVESTMENT.PROGRAM)

        ID.INVESTMENT.PROGRAM = INVESTMENT.PROGRAM
        R.INVESTMENT.PROGRAM = SC.ScoPortfolioMaintenance.InvestmentProgram.CacheRead(ID.INVESTMENT.PROGRAM, YERR)
        * Before incorporation : CALL CACHE.READ('F.INVESTMENT.PROGRAM',ID.INVESTMENT.PROGRAM,R.INVESTMENT.PROGRAM,YERR)
        INV.SIZING    = R.INVESTMENT.PROGRAM<SC.ScoPortfolioMaintenance.InvestmentProgram.ScInvSizing>
        INV.OBJECTIVE = R.INVESTMENT.PROGRAM<SC.ScoPortfolioMaintenance.InvestmentProgram.ScInvInvObjective>
        * MWT        CALL DBR("INVESTMENT.PROGRAM":FM:SC.INV.SIZING,INVESTMENT.PROGRAM,INV.SIZING)
        * MWT        CALL DBR("INVESTMENT.PROGRAM":FM:SC.INV.INV.OBJECTIVE,INVESTMENT.PROGRAM,INV.OBJECTIVE)

        OPTIONS<1> = INV.OBJECTIVE
        OPTIONS<2> = INV.SIZING

        * Get the rating and ranks of the securities.
        AM.Foundation.GetRating(R.POSITION<1>,OPTIONS,RATING.LIST)
        R.POSITION<4> = RATING.LIST<1>
        R.POSITION<5> = RATING.LIST<2>

        * Sort by rank.
        FOR I = 1 TO DCOUNT(R.POSITION<1>,@VM)
            LOCATE R.POSITION<5,I> IN TMP.POSN<5,1> BY "AN" SETTING POSN ELSE NULL
            TMP.POSN = INSERT(TMP.POSN,1,POSN,0;R.POSITION<1,I>)
            TMP.POSN = INSERT(TMP.POSN,2,POSN,0;R.POSITION<2,I>)
            TMP.POSN = INSERT(TMP.POSN,3,POSN,0;R.POSITION<3,I>)
            TMP.POSN = INSERT(TMP.POSN,4,POSN,0;R.POSITION<4,I>)
            TMP.POSN = INSERT(TMP.POSN,5,POSN,0;R.POSITION<5,I>)
        NEXT I

        R.POSITION = TMP.POSN

    END

    NB.POS = DCOUNT(R.POSITION<1>,@VM)

    FOR POS = 1 TO NB.POS
        IF DIFF.REST # 0 THEN
            RECOMMEND.SELL = R.POSITION<2,POS>
            IF RECOMMEND.SELL GT 0 THEN
                IF RECOMMEND.SELL < DIFF.REST THEN
                    POS.SELL = RECOMMEND.SELL
                END ELSE
                    POS.SELL = DIFF.REST
                END
                DIFF.REST = DIFF.REST - POS.SELL
                R.RET<1,-1> = R.POSITION<1,POS>
                R.RET<2,-1> = POS.SELL
            END
        END
    NEXT POS

    RETURN

*========================================================================
* Subroutines
*========================================================================
*
*------------
FATAL.ERROR:
*------------
    EB.SystemTables.setText(EB.SystemTables.getE())
    EB.ErrorProcessing.FatalError('THINK.SELL')

    END
