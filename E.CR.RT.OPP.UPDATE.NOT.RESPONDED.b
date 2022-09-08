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
* <Rating>-101</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CR.ModelBank
    SUBROUTINE E.CR.RT.OPP.UPDATE.NOT.RESPONDED
*-----------------------------------------------------------------------------
*<doc>
    !** Simple
* @author karthickm@temenos.com
* @stereotype Check rec routine
* @package CR
*!
*</doc>
*-----------------------------------------------------------------------------
* Check record routine attached in CR.OPPORTUNITY,ACCEPTED.RT version. This routine will read
* CR.OPPORTUNITY table and update OPPOR.STATUS.
*-----------------------------------------------------------------------------
* Modification History :
*
* 02/07/12 - EN 393557 - Task 401305
*            ARC-CRM Real-time opportunity generation
*
* ----------------------------------------------------------------------------
* <region name= Inserts>
    $INSERT I_DAS.CR.OPPORTUNITY

    $USING CR.Operational
    $USING EB.DataAccess
    $USING EB.SystemTables

* * </region>
*-----------------------------------------------------------------------------
*** <region name= Main section>
    GOSUB INITIALISE
* Check call is for real time or batch. If real time the proceed further or return
    IF REAL.TIME.FLAG THEN    ;* Flag will decide call from real time or batch
        GOSUB PROCESS         ;* Main section
    END

    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc> Initialisation of variables </desc>
INITIALISE:
    FN.OPP = 'F.CR.OPPORTUNITY'
    F.OPP = ''
    EB.DataAccess.Opf(FN.OPP,F.OPP)
    REAL.TIME.FLAG = EB.SystemTables.getRNew(CR.Operational.Opportunity.OpParentApplication)['-',2,1]         ;* Flag will decide call from real time or batch
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc> Read data from OPPORTUNITY table and update Opportunity status to COMMUNICATED.NOT.RESPONDED</desc>
PROCESS:
* Build select query
* SEL.CMD = 'SELECT ':FN.OPP :' WITH DIRECTION EQ "INBOUND" AND PARENT.REFERENCE EQ Y.PARENT.REF

    GOSUB CR.DAS.SELECTION    ;* Call DAS to perform query selection
* Process each record
    LOOP
        * Loop through each and every opportunity record
        REMOVE Y.OPPOR.ID FROM SEL.OPPOR.ID SETTING POS
    WHILE Y.OPPOR.ID
        IF EB.SystemTables.getIdNew() NE Y.OPPOR.ID THEN
            GOSUB OPPORTUNITY.READ      ;* Read Opportunity table
            GOSUB UPDATE.OPORTUNITY     ;* Update Opportunity table
        END ELSE
            EB.SystemTables.setRNew(CR.Operational.Opportunity.OpParentApplication, EB.SystemTables.getRNew(CR.Operational.Opportunity.OpParentApplication)['-',1,1]);* Remove flag
        END
    REPEAT

    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CR.DAS.SELECTION>
*** <desc>Call DAS to perform query selection</desc>
CR.DAS.SELECTION:
*Build Arguments
    THE.ARGS<1> = 'INBOUND'
    THE.ARGS<2> = EB.SystemTables.getRNew(CR.Operational.Opportunity.OpParentReference)

    TABLE.SUFFIX = ''
    SEL.OPPOR.ID = dasCROpportunityforUpdateNotResponded
* Call DAS to perform query selection
    EB.DataAccess.Das('CR.OPPORTUNITY',SEL.OPPOR.ID,THE.ARGS,TABLE.SUFFIX)
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= UPDATE.OPPORTUNITY>
*** <desc>Update Opportunity table</desc>
UPDATE.OPORTUNITY:
* Update Opportunity status to COMMUNICATED.NOT.RESPONDED
    IF R.CR.OPPORTUNITY THEN
        R.CR.OPPORTUNITY<CR.Operational.Opportunity.OpOpporStatus> = 'COMMUNICATED.BUT.NOT.RESPONDED'
        GOSUB OPPORTUNITY.WRITE         ;* Write Opportunity table
        EB.SystemTables.setRNew(CR.Operational.Opportunity.OpParentApplication, EB.SystemTables.getRNew(CR.Operational.Opportunity.OpParentApplication)['-',1,1])
    END
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= OPPORTUNITY.READ>
OPPORTUNITY.READ:
* Read cr.opportunity file for direct write. enquiry needs to update immediately with CR.OPPPORTUNITY
* So direct write/Read required
    R.CR.OPPORTUNITY = ''
    READ R.CR.OPPORTUNITY FROM F.OPP, Y.OPPOR.ID ELSE
        RETURN
    END
    RETURN
***
*** </region>
*-----------------------------------------------------------------------------
*** <region name= OPPORTUNITY.WRITE>
OPPORTUNITY.WRITE:
* Read cr.opportunity file for direct write. enquiry needs to update immediately with CR.OPPPORTUNITY
* So direct write/Read required
    WRITE R.CR.OPPORTUNITY TO F.OPP, Y.OPPOR.ID
        RETURN
***
*** </region>
        *-----------------------------------------------------------------------------
    END
