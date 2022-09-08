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

* Version 9 16/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>-118</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CR.ModelBank
    SUBROUTINE E.CR.REAL.TIME.OPPOR.UPDATE(ENQ.DATA)
*-----------------------------------------------------------------------------
* Program Description
* This is a build routine attached with enquiry REAL.TME.OPP. This routine does the following.
* After transaction completed, composite screen REAL.TIME.OPP get loaded with ENQ REAL.TIME.OPP.
* At that time there is no value of CR.OPPORTUNITY.ID. So REAL.TIME.CR.UPDATE build routine doesn't do anything.
* Enquiry has four drill downs.
*
*       Apply Now
*       Nothanks
*       Ask Me Later
*       More Info
*
* Apply Now - Trigger PW activity of corresponding opportunity
* More Info - Load static html page about product information
* For Ask Me Later and Nothanks process as follows.
* Both will trigger/Lad same enquiry with extra selection criteria. CR.OPPORTUNITY.ID and corresponding OPPOR.STATUS.
* Get the CR.OPPORTUNITY.ID from enquiry selection criteria to read the record from CR.OPOORTUNITY application.
* Update CR.OPPOR.STATUS with No-ThankYou/Ask.Me.Later depending upon selection criteria value.
* Write  into CR.OPPORTUNITY file.
*-----------------------------------------------------------------------------
*! ENQ.DATA - In/Out - Common Varible contains selection criteria.
*-----------------------------------------------------------------------------
* Modification History :
*
* 02/06/12 - Enhancement_393557
*           Creation of REAL.TIME.CR.UPDATE
*
* 22/07/12 - Enhancement_393557 (Defect - 447077/Task 448017)
*            ARC-CRM Real-time opportunity generation
*            The same product is displayed again for customer even after selecting “No thanks”
*            during the previous transaction
*
*-----------------------------------------------------------------------------

    $USING CR.Operational
    $USING EB.DataAccess
    $USING EB.SystemTables


    GOSUB INITIALISE
    GOSUB OPPORTUNITY.READ
    GOSUB DO.PROCESS
    RETURN
***
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
***
* Check @ID passed as arguement or not.
    LOCATE '@ID' IN ENQ.DATA<2,1> SETTING CR.ID.POS THEN
    FN.CR.OPPORTUNITY = 'F.CR.OPPORTUNITY'
    F.CR.OPPORTUNITY = ''
    R.CR.OPPOR = ''
    OPPOR.ID = ''
    EB.DataAccess.Opf(FN.CR.OPPORTUNITY,F.CR.OPPORTUNITY)
* Contains value then select
    IF ENQ.DATA<4,CR.ID.POS> NE '' THEN
        OPPOR.ID = ENQ.DATA<4,CR.ID.POS>
    END
* Change selection criteria for CR.OPPORTUNITY.ID (@ID)
    ENQ.DATA<3,CR.ID.POS> = "NE"
    END

    RETURN
***
*** </region>
*-----------------------------------------------------------------------------
*** <region name= OPPORTUNITY.READ>
OPPORTUNITY.READ:
* Read cr.opportunity file for direct write. enquiry needs to update immediately with CR.OPPPORTUNITY
* So direct write/Read required
    IF OPPOR.ID THEN
        READ R.CR.OPPOR FROM F.CR.OPPORTUNITY, OPPOR.ID ELSE
            RETURN
        END
    END
    RETURN
***
*** </region>
*-----------------------------------------------------------------------------
*** <region name= DO.PROCESS>
*CR.OPPORTUNITY record status updated based on enquiry slection
DO.PROCESS:
    IF R.CR.OPPOR THEN
        LOCATE 'OPPOR.STATUS' IN ENQ.DATA<2,1> SETTING CR.OPP.POS THEN
        OPPOR.STATUS = ENQ.DATA<4,CR.OPP.POS>
        R.CR.OPPOR<CR.Operational.Opportunity.OpOpporStatus> = OPPOR.STATUS
        IF OPPOR.STATUS EQ 'REJECTED' THEN
            R.CR.OPPOR<CR.Operational.Opportunity.OpEndDate> = EB.SystemTables.getToday()
            GOSUB UPDATE.CUST.OPPOR.HIST          ;* Updates the customer history file for the opportunity created/amended.
        END
        GOSUB OPPORTUNITY.WRITE

    END
    END
    RETURN
***
*** </region>
*-----------------------------------------------------------------------------
*** <region name= OPPORTUNITY.WRITE>
OPPORTUNITY.WRITE:
* cr.opportunity file for direct write. enquiry needs to update immediately with CR.OPPPORTUNITY
* So direct write/Read required
    WRITE R.CR.OPPOR TO F.CR.OPPORTUNITY, OPPOR.ID
        RETURN
***
*** </region>
        *-----------------------------------------------------------------------------
*** <region name= UPDATE.CUST.OPPOR.HIST>
UPDATE.CUST.OPPOR.HIST:
        * Update customer opportunity history

        GOSUB READ.CUST.OPPOR.HIST ;* get the corresponding cr.cust.oppor.hist rec if exists
        LOCATE R.CR.OPPOR<CR.Operational.Opportunity.OpProduct> IN R.CR.CUST.OPPOR.HIST<CR.Operational.CustOpporHist.CophProduct,1> SETTING PROD.POS ELSE     ;* if a oppor already exists for that customer with same prodct
        RETURN
    END
    LOCATE OPPOR.ID IN R.CR.CUST.OPPOR.HIST<CR.Operational.CustOpporHist.CophOpportunityId,PROD.POS,1> SETTING OP.POS THEN    ;* if this same oppor already existts
    R.CR.CUST.OPPOR.HIST<CR.Operational.CustOpporHist.CophDateRejected,PROD.POS,OP.POS> = EB.SystemTables.getToday() ;* set the rejection date in the hist
    GOSUB WRITE.CUST.OPPOR.HIST
    END
    RETURN
*
*** </region>
*-----------------------------------------------------------------------------
READ.CUST.OPPOR.HIST:
* Get customer opportunity history
    FN.CR.CUST.OPPOR.HIST = 'F.CR.CUST.OPPOR.HIST'
    F.CR.CUST.OPPOR.HIST = ''
    EB.DataAccess.Opf(FN.CR.CUST.OPPOR.HIST,F.CR.CUST.OPPOR.HIST)    ;* open the cr.cust.oppor.hist record
*
    CUSTOMER.ID = R.CR.OPPOR<CR.Operational.Opportunity.OpCustomer>
    READ R.CR.CUST.OPPOR.HIST FROM F.CR.CUST.OPPOR.HIST, CUSTOMER.ID ELSE  ;*read the hist record
        RETURN
    END
    RETURN
*
*** </region>
*-----------------------------------------------------------------------------
WRITE.CUST.OPPOR.HIST:
* CR.CUST.OPPOR.HIST file for direct write. enquiry needs to update immediately with CR.CUST.OPPOR.HIST
* So direct write/Read required
    WRITE R.CR.CUST.OPPOR.HIST TO F.CR.CUST.OPPOR.HIST, CUSTOMER.ID       ;* write back the hist record
        RETURN
        *
*** </region>
        *-----------------------------------------------------------------------------
    END
