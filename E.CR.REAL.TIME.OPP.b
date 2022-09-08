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
* <Rating>-87</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CR.ModelBank
    SUBROUTINE E.CR.REAL.TIME.OPP(Y.ENQ.DATA)
*-----------------------------------------------------------------------------
*<doc>
    !** Simple
* @author karthickm@temenos.com
* @stereotype NOFILE enq routine
* @package CR
*!
*</doc>
*-----------------------------------------------------------------------------
* Nofile enquiry routine attached in CR.REAL.TIME.OPP. This routine will fetch
* data from CR.OPPORTUNITY table and build selection content.
*
* Y.ENQ.DATA - In/Out - Varible contains selection criteria.
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 04/06/12 - EN 393557 - Task 401305
*            ARC-CRM Real-time opportunity generation
*
* 25/06/12 - Defect 426253 / Task 428773
*            ARC CRM - Real-time opportunity generation - Maintainability
*
* ----------------------------------------------------------------------------
* <region name= Inserts>
    $INSERT I_DAS.CR.OPPORTUNITY

    $USING CR.Operational
    $USING EB.DataAccess
    $USING EB.Reports

* * </region>
*-----------------------------------------------------------------------------
*** <region name= Main section>

    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc> Initialisation of variables </desc>
INITIALISE:

    F.OPP = ''
    Y.USER = ''
    COMMUNICATED.BUT.NOT.RESPONDED.COUNT = 0
    NOT.COMMUNICATED.YET.COUNT = 0
    ACCEPTED.COUNT = 0
    NO.THANKS.COUNT = 0
    ASK.ME.LATER.COUNT = 0

    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc> Get selection criteria from ENQ.SELECTION based on that pick data from OPPORTUNITY table and build final O/P content</desc>
PROCESS:
* Search for different criteria of selection
    LOCATE 'OPPORTUNITY' IN EB.Reports.getEnqSelection()<2,1> SETTING OPP.POS THEN
    Y.OPPORTUNITY = EB.Reports.getEnqSelection()<4,OPP.POS>
    END

    LOCATE 'BANK' IN EB.Reports.getEnqSelection()<2,1> SETTING BANK.POS THEN
    Y.BANK = EB.Reports.getEnqSelection()<4,BANK.POS>
    END

    LOCATE 'BANK.USER' IN EB.Reports.getEnqSelection()<2,1> SETTING USER.POS THEN
    Y.USER = EB.Reports.getEnqSelection()<4,USER.POS>
    END

* Build select query
* SEL.CMD = 'SELECT ':FN.OPP :' WITH OPPOR.DEF.ID LIKE ':Y.OPPORTUNITY:' AND DIRECTION EQ "INBOUND"
* AND PARENT.REFERENCE NE "" AND OPPOR.STATUS EQ "ACCEPTED" "REJECTED" "ASK.ME.LATER" "COMMUNICATED.BUT.NOT.RESPONDED" "NOT.COMMUNICATED.YET"
*Build Arguments
    THE.ARGS<1> = '"ACCEPTED" "REJECTED" "ASK.ME.LATER" "NOT.COMMUNICATED.YET" "COMMUNICATED.BUT.NOT.RESPONDED"'
    THE.ARGS<2> = 'INBOUND'
    THE.ARGS<3> = Y.OPPORTUNITY
    THE.ARGS<4> = ''
    TABLE.SUFFIX = ''
* Pass user and company if user given this selection
    IF Y.BANK AND Y.USER THEN
        SEL.OPPOR.ID = dasCROpportunityforRealTimebyCompanyandUser
        THE.ARGS<5> = Y.BANK
        THE.ARGS<6> = Y.USER
    END ELSE
        BEGIN CASE
            CASE Y.BANK
                SEL.OPPOR.ID = dasCROpportunityforRealTimebyCompany
                THE.ARGS<5> = Y.BANK
            CASE Y.USER
                SEL.OPPOR.ID = dasCROpportunityforRealTimebyUser
                THE.ARGS<5> = Y.USER
            CASE 1
                SEL.OPPOR.ID = dasCROpportunityforRealTime
        END CASE
    END
* Call DAS to perform query selection
    EB.DataAccess.Das('CR.OPPORTUNITY',SEL.OPPOR.ID,THE.ARGS,TABLE.SUFFIX)
* Count Selected Opportunity ids
    SELECTED = DCOUNT(SEL.OPPOR.ID,@FM)

* Process on selection
    LOOP
        * Loop through each and every opportunity record
        REMOVE Y.OPPOR.ID FROM SEL.OPPOR.ID SETTING POS
    WHILE Y.OPPOR.ID
        GOSUB READ.CR.OPPORTUNITY
        IF NOT(CR.ERR) THEN
            GOSUB BUILD.SELECTION
        END
    REPEAT

    Y.OPPORTUNITY = R.CR.OPPORTUNITY<CR.Operational.Opportunity.OpOpporDefId>
    GOSUB READ.CR.OPPORTUNITY.DEFINITION          ;* Read Opportunity Definition file to get short desc
    Y.OPPORTUNITY = R.CR.OPPORTUNITY.DEF<CR.Operational.OpportunityDefinition.OdShortDesc>

    IF Y.USER THEN
        Y.USER = R.CR.OPPORTUNITY<CR.Operational.Opportunity.OpAuthoriser>
        Y.USER = Y.USER['_',2,1]
    END
* Build final enquiry data
    Y.ENQ.DATA<-1> = Y.OPPORTUNITY:'*':Y.BANK:'*':Y.USER:'*':SELECTED:'*':ACCEPTED.COUNT:'*':NO.THANKS.COUNT:'*':ASK.ME.LATER.COUNT:'*':COMMUNICATED.BUT.NOT.RESPONDED.COUNT:'*':NOT.COMMUNICATED.YET.COUNT
    RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= READ.CR.OPPORTUNITY>
*** <desc>Read Opportunity table</desc>
READ.CR.OPPORTUNITY:
    R.CR.OPPORTUNITY = CR.Operational.Opportunity.Read(Y.OPPOR.ID, CR.ERR)
*    Y.USER = R.CR.OPPORTUNITY<CR.OP.AUTHORISER>
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= READ.CR.OPPORTUNITY.DEFINITION>
*** <desc>Read Opportunity Definition file to get short desc</desc>
READ.CR.OPPORTUNITY.DEFINITION:
    R.CR.OPPORTUNITY.DEF = CR.Operational.OpportunityDefinition.Read(Y.OPPORTUNITY, CR.ERR)
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= BUILD.SELECTION>
*** <desc>Count no of different opportunity status </desc>
BUILD.SELECTION:
    Y.OPPOR.STATUS = R.CR.OPPORTUNITY<CR.Operational.Opportunity.OpOpporStatus>

    BEGIN CASE
        CASE Y.OPPOR.STATUS EQ "NOT.COMMUNICATED.YET"
            NOT.COMMUNICATED.YET.COUNT += 1
        CASE Y.OPPOR.STATUS EQ "COMMUNICATED.BUT.NOT.RESPONDED"
            COMMUNICATED.BUT.NOT.RESPONDED.COUNT += 1
        CASE Y.OPPOR.STATUS EQ "ACCEPTED"
            ACCEPTED.COUNT += 1
        CASE Y.OPPOR.STATUS EQ "REJECTED"
            NO.THANKS.COUNT += 1
        CASE Y.OPPOR.STATUS EQ "ASK.ME.LATER"
            ASK.ME.LATER.COUNT += 1
    END CASE
    RETURN
*** </region>
*-----------------------------------------------------------------------------
    END
