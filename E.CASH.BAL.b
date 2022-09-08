* @ValidationCode : MjotNTE5MTYwODMzOmNwMTI1MjoxNjE1OTgwODMwMzIwOmplbGl6ZWJldGg6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMy4yMDIxMDMwMS0wNTU2OjQ4OjQz
* @ValidationInfo : Timestamp         : 17 Mar 2021 17:03:50
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : jelizebeth
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 43/48 (89.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210301-0556
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
*-----------------------------------------------------------------------------
* <Rating>-44</Rating>
*-----------------------------------------------------------------------------
* Version 3 29/09/00  GLOBUS Release No. G11.0.00 29/06/00
*************************************************************************
*
$PACKAGE SC.ScoReports
SUBROUTINE E.CASH.BAL
*
*************************************************************************
*
    $USING EB.Reports
    $USING AC.AccountOpening
    $USING EB.SystemTables
    $USING EB.API
    $USING AC.CashFlow

*
*************************************************************************
*
* This routine is called by the enquiry 'NOSTRO.POS' which displays
* the nostro balances for the next five working days.
*
* The routine will calculate the next five working days based on the
* current account currency passed in R.RECORD and determine the
* balance for each day by analysing the value dated balance fields on
* the account record.
*
* The results will be passed back in the O.DATA string as :-
*
*  R.RECORD         =   Account record - from correct company
*  O.DATA<1,1>      =   VAL.DATE:@SM:VAL.DATE:@SM:... (5)
*  O.DATA<1,2>      =   BALANCE:@SM:BALANCE:@SM:... (5)
*
*************************************************************************
*MODIFICATION.HISTORY:
*=====================
* PIF GB9301840; Added Country code to call to CDT.
*
* 16/05/06 - GLOBUS_CI_10041102
*            The obsolete account fields should be changed
*
*
* 20/05/11 - Enhancement - 182581 / Task- 191536
*            Moving Balances to ECB from Account Balance Fields.
*
*
* 06/06/11 - ENHANCEMENT 182577 / Task 191523
*            Moving Balances from ACCOUNT to ECB
*    	     Moving Cashflow Management Fields to ECB
*
* 22/6/15 - 1322379 Task:1336841
*           Incorporation of components
* 02-03-16 - Task 1650466
*            Compliation Warnings
*
* 15/03/21 - Defect 4280268 / Task 4290496
*            Enquiry CASH.AVAIL is not displaying the balance amount instead it displays 0 for all currency.
*************************************************************************
    GOSUB INITIALISE
    GOSUB PROCESS
RETURN
*--------------------------------------------------------------------------
INITIALISE:
***********
    HOLD.RECORD = EB.Reports.getRRecord()

* Read account from correct company.
*

    tmp.R.RECORD = EB.Reports.getRRecord()
    tmp.O.DATA = EB.Reports.getOData()
    tmp.R.RECORD = AC.AccountOpening.Account.Read(tmp.O.DATA, "")
* Before incorporation : CALL F.READ("F.ACCOUNT",tmp.O.DATA,tmp.R.RECORD,tmp.F.ACCOUNT,"")

    EB.Reports.setRRecord(tmp.R.RECORD)

*
* get balance using service routine.
    accountKey = EB.Reports.getOData()
    response.Details = ''
    Workingbal = ''
    AC.CashFlow.AccountserviceGetworkingbalance(accountKey, Workingbal, response.Details)

*
* ACCOUNT SERVICE FOR CASH POOL
    AC.AVAIL.BAL.DET.LOCAL=''
    Responsedetails = ''



    AC.CashFlow.AccountserviceGetavailablebalancedetails(accountKey, AC.AVAIL.BAL.DET.LOCAL, Responsedetails)


RETURN
*--------------------------------------------------------------------------
PROCESS:
*********

    C.DATE = EB.SystemTables.getToday()
    C.BAL = Workingbal

    V.DATE = AC.AVAIL.BAL.DET.LOCAL<AC.CashFlow.AvailablebalancedetailsAvailabledate>
    D.MOV = AC.AVAIL.BAL.DET.LOCAL<AC.CashFlow.AvailablebalancedetailsAvauthdbmvmt>
    C.MOV = AC.AVAIL.BAL.DET.LOCAL<AC.CashFlow.AvailablebalancedetailsAvauthcrmvmt>
    V.BAL.LOCAL = AC.AVAIL.BAL.DET.LOCAL<AC.CashFlow.AvailablebalancedetailsAvailablebal>

    COUNTRY.CODE = tmp.R.RECORD<AC.AccountOpening.Account.Currency>[1,2]
    REGION.CODE = COUNTRY.CODE:'00'
    V$DIV = 1000
    EB.Reports.setOData('')

    IF NOT(C.BAL) THEN
        C.BAL = 0
    END
    FOR I = 1 TO 5
        LOCATE C.DATE IN V.DATE<1,1> BY 'AL' SETTING POS THEN
            C.BAL = V.BAL.LOCAL<1,POS>
        END ELSE
            BEGIN CASE
                CASE V.DATE EQ ''
                    NULL
                CASE V.DATE<1,POS>
                    C.BAL = V.BAL.LOCAL<1,POS> - D.MOV<1,POS> - C.MOV<1,POS>
                CASE 1
                    C.BAL = V.BAL.LOCAL<1,POS-1>
            END CASE
        END
        tmp=EB.Reports.getOData(); tmp<1,1,I>=C.DATE; EB.Reports.setOData(tmp)
        tmp=EB.Reports.getOData(); tmp<1,2,I>=C.BAL / V$DIV; EB.Reports.setOData(tmp)

        EB.API.Cdt(REGION.CODE,C.DATE,'+1W')

    NEXT I

    EB.Reports.setRRecord(HOLD.RECORD)
RETURN
*
***************************************************************************
*
END
