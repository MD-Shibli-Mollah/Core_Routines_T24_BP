* @ValidationCode : MjoxMjU2Mjk5NTYzOkNwMTI1MjoxNjE5MzQxNzQ3NzQxOmVuYW5kaGluaTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIxMDMuMjAyMTAzMDUtMDYzNjotMTotMQ==
* @ValidationInfo : Timestamp         : 25 Apr 2021 14:39:07
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : enandhini
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210305-0636
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.MANUAL.AGEING.DATE
*-----------------------------------------------------------------------------
*This is a conversion routine for the field containing
*an arrangement Id to display the start date of the manual ageing status after manaul ageing a contact
*-----------------------------------------------------------------------------
* Modification History :
*
* 05/05/20 - Task : 3728164
*            Defect : 3722568
*            Conversion routine to display the date on which the contact moved to worst overdue status
*
* 04/06/20 - Defect: 3768197
*            Task : 3727435
*            Model defect fix for customer asset classification
*
* 25/04/2021 - Defect: 4353708
*              Task : 4353878
*              TAFC/TAFJ difference inconsistent issue- regression fix. Passing arrangement id with quotes to avoid Pattern matching and to return records of the arrangement properly.
*-----------------------------------------------------------------------------
    $USING EB.Reports
    $USING AA.Overdue
    $USING AA.PaymentSchedule
    $USING EB.DataAccess
          
*-----------------------------------------------------------------------------
   
    GOSUB INITIALISE ; *
    IF MANUAL.AGEING EQ "YES" THEN
        GOSUB PROCESS ; *
    END ELSE
        EB.Reports.setOData("") ;*set output null for contact that is not manually aged.
    END
RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>
 
    ARRANGEMENT.ID = EB.Reports.getOData()
     
    AG.ERR = ''
    R.ACCOUNT.DETAILS = AA.PaymentSchedule.AccountDetails.Read(ARRANGEMENT.ID, AG.ERR)
    MANUAL.AGEING = R.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdManualAgeing>
    
    FN.AA.OVERDUE.STATS = 'F.AA.OVERDUE.STATS'
    F.AA.OVERDUE.STATS = ''
    EB.DataAccess.Opf(FN.AA.OVERDUE.STATS,F.AA.OVERDUE.STATS)
        
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>

    OUT.DATA = ''
    SEL.CMD = ''
    AA.SEL.REC = ''
    Error = ''
    SEL.CMD = 'SSELECT ':FN.AA.OVERDUE.STATS:' WITH @ID LIKE "':SQUOTE(ARRANGEMENT.ID):'..."'
    
    EB.DataAccess.Readlist(SEL.CMD,AA.SEL.REC,'',NO.OF.REC,ERR.RECS)
    R.OVERDUE.STATS = AA.Overdue.OverdueStats.Read(AA.SEL.REC, Error)
    
    TOT.OD.STATUS = DCOUNT(R.OVERDUE.STATS<AA.Overdue.OverdueStats.OdStOdStatus>,@VM) ;* getting the last ageing status of contarct
    STATUS.START.DATE = R.OVERDUE.STATS<AA.Overdue.OverdueStats.OdStStartDate , TOT.OD.STATUS> ;* get start date of the last ageing status
    CONVERT @SM TO @VM IN STATUS.START.DATE
    COUNT.DATE = DCOUNT(STATUS.START.DATE ,@VM)
    IF COUNT.DATE GT 1 THEN
        STATUS.START.DATE = STATUS.START.DATE<1, COUNT.DATE>
    END
    OUT.DATA = STATUS.START.DATE
    EB.Reports.setOData(OUT.DATA)
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END


