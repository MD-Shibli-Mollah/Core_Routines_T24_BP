* @ValidationCode : MjozNTQwNTI3Mzk6Y3AxMjUyOjE1NDIxMDY2MTIxMzY6a2FydGhpa2V5YW5rYW5kYXNhbXk6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxODA3LjIwMTgwNjIxLTAyMjE6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Nov 2018 16:26:52
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : karthikeyankandasamy
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201807.20180621-0221
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 11 22/05/01  GLOBUS Release No. G13.0.01 29/07/02
*-----------------------------------------------------------------------------
* <Rating>-90</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScvReports
    SUBROUTINE E.OL.VAL(ENQUIRY.DATA)
****************************************
* ROUTINE CALLED BY SC.VAL.MARKET      *
*                   SC.VAL.COST        *
*                   SC.VAL.MARGIN      *
*                   SC.VAL.PL          *
*                   SC.VAL.EXERCISE    *
*  DURING ENQUIRY                      *
****************************************
*** <region name= Modification History>
*** <desc>Modification History </desc>
*========================================================================
*
* 13/01/95 - GB9500054
*            Adjusted to accept input parameter to become GUI compatible
*
* 02/10/98 - GB981215
*            Don't allow all option, tidy up validation
*
* 03/08/99 - GB9901044
*            Correct validation
*
* 18/10/02 - CI_10004200
*            Printing Enquiry SC.VAL.COST displays errors in desktop
*
* 03/12/02 - CI_10005183
*            Multiple Portfolio selection should be restricted.
*
* 30/12/02 - CI_10005217
*            Enhancement done for shared SEC.ACC.MASTER.
*            Valuation is done only for portfolios belonging to the
*            current company.
*
* 28/01/03 - CI_10006485
*            When running an enquiry, the process doesn't check the product
*            as defined in the enquiry, is installed in the company in which
*            you are running the enquiry. This causes FATAL ERROR.
*
* 11/08/04 - CI_10022032
*            Enquiry SC.VAL.COST - ONLINE option compatible for Browser
* 05/01/05 - EN_10002382
*               SC Phase I non stop processing.
*
* 10/02/05 - CI_10027188
*            NS bug fixes.
*
* 27/03/06 - CI_10040041
*            Online valuation updation problem
*
* 22/10/07 - BG_100015522
*            For AM.ENQUIRIES with the selection field ONLINE.YN, this field should treat YES, yes & Yes as 'Y
*
* 12/01/09 - GLOBUS_BG_100021584 - dgearing@temenos.com
*            Tidy up for ratings.
*
* 12/03/09 - GLOBUS_CI_10061263
*            While processing the Enquiry through OFS, the common variable F.ENQ
*            is not assigned in OFS.ENQUIRY.MANAGER routine.Hence the OPF of Enquiry
*            file is done locally in this routine.
*
* 25/10/13 - EN 727446 / Task 806958
*            Multi Company SAM sharing
*
* 20/04/15 - 1323085
*            Incorporation of components
*
* 18/01/2016 - Task: 1586902
*             Compilation Corrections - Variable  C.U is assigned 
*
* 25/10/18 -  Enhancement:2822501 Task:2826453
*             Componentization - II - Private Wealth 
*==============================================================================================================
*** </region>

    $USING SC.ScvValuationUpdates
    $USING EB.OverrideProcessing
    $USING EB.DataAccess
    $USING SC.ScoPortfolioMaintenance
    $USING SC.SctNonStop
    $USING ST.CompanyCreation
    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.API

    SEC.ACC.NO = ''
    LOCATE 'SECURITY.ACC' IN ENQUIRY.DATA<2,1> SETTING FOUND THEN
    SEC.ACC.NO = ENQUIRY.DATA<4,FOUND>        ;* CI_10022032 S
    END

    ONLINE.FLAG = 'NO'
    LOCATE 'ONLINE.YNO' IN ENQUIRY.DATA<2,1> SETTING POS THEN
    ONLINE.FLAG = UPCASE(ENQUIRY.DATA<4,POS,1>[1,1])    ;*BG_100015522 - S/E
    END   ;* CI_10022032 E
*
* CI_10005183 - Start
    CNT = DCOUNT(SEC.ACC.NO,@VM)
    IF CNT > 1 THEN
        EB.Reports.setEnqError("MULTIPLE PORTFOLIO SELECTION NOT ALLOWED")
        RETURN
    END

    IF SEC.ACC.NO = '' THEN
        SEC.ACC.NO = 'ALL'
    END
    IF SEC.ACC.NO = 'ALL' THEN
        EB.Reports.setEnqError("ALL OPTION NOT ALLOWED")
        RETURN
    END

    LOCATE 'SC' IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING SC.POS ELSE
    SC.POS = 0
    END
    IF NOT(SC.POS) THEN
        RETURN      ;* If SC is not installed in the company, Return
    END

    FN.ENQUIRY = 'F.ENQUIRY'
    F.ENQUIRY = ''
    EB.DataAccess.Opf(FN.ENQUIRY, F.ENQUIRY)

    EB.SystemTables.setEtext('')

    tmp.ETEXT = EB.SystemTables.getEtext()
    R.SAM = SC.ScoPortfolioMaintenance.tableSecAccMaster(SEC.ACC.NO,tmp.ETEXT)
    EB.SystemTables.setEtext(tmp.ETEXT)

* Only proceed with the valuation run if the portfolio exists.

    IF EB.SystemTables.getEtext() THEN
        EB.SystemTables.setEtext('')
        RETURN
    END

* Check for the Classification type of SEC.ACC.MASTER file and
* the OWN.COMP.ID field in SAM for this portfolio.
    SAM.FILE.CLASS.LOCAL = '' ; FILE.NAME = 'SEC.ACC.MASTER'
    SC.ScoPortfolioMaintenance.ScGetFileClassification(FILE.NAME,SAM.FILE.CLASS.LOCAL)

    OWN.COMPANY = R.SAM<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamOwnCompId>
    IF (SAM.FILE.CLASS.LOCAL EQ 'CUS' OR SAM.FILE.CLASS.LOCAL EQ 'INT') AND (OWN.COMPANY NE EB.SystemTables.getIdCompany()) THEN ; * valuation has to run in the company defined in OWN.COMP.ID
        EB.Reports.setEnqError("PORTFOLIO DOES NOT BELONG TO THIS COMPANY")
        RETURN
    END

    GOSUB GET.ONLINE.FLAG     ;*Get value for online valuation flag

    GOSUB CHECK.NS.INSTALLED
    IF EB.SystemTables.getComi()[1,1] = "Y" THEN
        EB.OverrideProcessing.DisplayMessage("UPDATING ONLINE POSITIONS", 1)
        SAVE.APPLICATION = EB.SystemTables.getApplication()
        EB.SystemTables.setApplication('ENQUIRY.SELECT')
        SC.ScvValuationUpdates.OlValSec(SEC.ACC.NO)
        EB.SystemTables.setApplication(SAVE.APPLICATION);* CI_10040041
    END

    RETURN
*
*----------------------------------------------------------------------------
CHECK.NS.INSTALLED:

    COB.IS.ON.LOCAL = ''
    NS.INSTALLED = 0
    ONLINE.SESSION = ''

    SC.SctNonStop.ScGetSystemStatus(ONLINE.SESSION,COB.IS.ON.LOCAL,NS.INSTALLED,'','','')

    SELECTION.FILE.NAME = 'SC.POS.ASSET'

    LOCATE '@ID' IN ENQUIRY.DATA<2,1> SETTING FOUND THEN
    DEL ENQUIRY.DATA<2,FOUND>
    DEL ENQUIRY.DATA<3,FOUND>
    DEL ENQUIRY.DATA<4,FOUND>
    END

    IF NS.INSTALLED AND COB.IS.ON.LOCAL AND ONLINE.SESSION THEN
        LOCATE 'SECURITY.ACC' IN ENQUIRY.DATA<2,1> SETTING FOUND THEN
        ENQUIRY.DATA<2,FOUND> = '@ID'
        ENQUIRY.DATA<3,FOUND> = 'LK'
        ENQUIRY.DATA<4,FOUND> = ENQUIRY.DATA<4,FOUND>:'...'
    END
    SELECTION.FILE.NAME = 'SC.POS.ASSET.WHILE.COB'
    END

    IF EB.Reports.getREnq()<EB.Reports.Enquiry.EnqFileName> NE SELECTION.FILE.NAME THEN
        R.CHANGE.ENQUIRY = ''
        tmp.ID.NEW = EB.SystemTables.getIdNew()
        READ R.CHANGE.ENQUIRY FROM F.ENQUIRY,tmp.ID.NEW THEN
            R.CHANGE.ENQUIRY<EB.Reports.Enquiry.EnqFileName> = SELECTION.FILE.NAME
            WRITE R.CHANGE.ENQUIRY TO F.ENQUIRY,tmp.ID.NEW
            END
        END

        RETURN

        *------------------------------------------------------------------
PRINT.ERROR:

        EB.OverrideProcessing.DisplayMessage("INVALID INPUT",1)

        RETURN

        *-----------------------------------------------------------------------------
*** <region name= GET.ONLINE.FLAG>
GET.ONLINE.FLAG: 
*** <desc>Get value for online valuation flag </desc>

        LOOP
            EB.SystemTables.setComi(ONLINE.FLAG)

            IF ONLINE.FLAG = '' OR ONLINE.FLAG # "Y" THEN
                EB.SystemTables.setComi('NO')
            END         ;* CI_10022032 E
            COMI.LOCAL = EB.SystemTables.getComi()
        WHILE COMI.LOCAL = EB.API.getCU()
            GOSUB PRINT.ERROR
        REPEAT

        RETURN
*** </region>
 
    END 
