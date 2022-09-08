* @ValidationCode : MjotMjExODI0MzAzMzpDcDEyNTI6MTQ5NDM5Mjk4NDk4MDp5Z2F5YXRyaToxOjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTcwMy4yMDE3MDMwNC0wMTM5Ojc3OjY1
* @ValidationInfo : Timestamp         : 10 May 2017 10:39:44
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ygayatri
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 65/77 (84.4%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201703.20170304-0139
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-31</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CL.ModelReport
    SUBROUTINE E.CL.DUE.SUMMARY(BLD.ENQ.LIST)
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*** <doc>
* This No file enquiry routine. It is helpful to list out the all overdues relevant AA contract.
*
* @author johnson@temenos.com
* @stereotype template
* @uses ENQUIRY>CL.DC.DUE.SUMMARY
* @uses
* @package retaillending.CL
*
*** </doc>
*** </region>

*** <region name= Modification History>
*** <desc>Changes done in the sub-routine</desc>
* Modification History :
*-----------------------
* 11/04/14 -  ENHANCEMENT - 908020 /Task - 988392
*          -  Loan Collection process
*
* 09/09/15 - Task : 1447056
*            Enhancement : 1434821
*            Get the GL Custoemr by calling AA.GET.ARRANGEMENT.CUSTOMER routine.
*
* 24/02/17 - Defect : 2024964
*            Task   : 2031544
*            Gets the GL customer by calling AA.GET.ARRANGEMENT.CONDITIONS and AA.GET.ARRANGEMENT.CUSTOMER 
*
*** </region>

*** <region name= Arguments>
*** <desc>Input and output arguments required for the sub-routine</desc>
* Arguments
*
* Input :
*
*
*
*
* Output
*
* BLD.ENQ.LIST = It return final result
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= INSERTS>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING AA.Framework
    $USING AA.Overdue
    $USING EB.Reports
    $USING AA.Account
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING AA.Customer
    $USING EB.API

*** </region>

*** <region name= Main Section>
*** <desc>Main control logic in the sub-routine</desc>

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN
*** </region>

*** <region name= INITIALISE>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts


INITIALISE:
***********

* Initialise the required variables and Open the files

    FN.CL.COLLECTION.ITEM = 'F.CL.COLLECTION.ITEM'
    F.CL.COLLECTION.ITEM = ''

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''

    FN.AA.ARR.ACCOUNT = 'F.AA.ARR.ACCOUNT'
    F.AA.ARR.ACCOUNT = ''

    FN.AA.OVERDUE.STATS = 'F.AA.OVERDUE.STATS'
    F.AA.OVERDUE.STATS = ''
    EB.DataAccess.Opf(FN.AA.OVERDUE.STATS,F.AA.OVERDUE.STATS)

    CATEG.ID = ''
    OD.REC.CNT = ''
    OD.REC.ID = ''
    START.DATE = ''
    DIFFERENCE = ''
    END.DATE = ''
    TOT.OD.DAYS = ''
    OD.MVMT.CRDT = ''
    AA.ARR.ID = ''
    ARR.STRT.DATE = ''
    ARR.CUS.ID = ''
    AA.AR.ACC.ID = ''
    AA.ARR.CATEG = ''
    BLD.ENQ.LIST = ''


    RETURN

*** </region>

*** <region name= PROCESS>
*** <desc>Main Process for selection & Display record's on Enquiry</desc>


PROCESS:
*********

    IF EB.Reports.getDummy12(3) EQ 'Y' THEN
        EB.Reports.setDummy12(3, '0')
        RETURN
    END

* Take the Category from User Selection.

    LOCATE "CATEGORY" IN EB.Reports.getDFields()<1> SETTING CAT.POS THEN
    CATEG.ID = EB.Reports.getDRangeAndValue()<CAT.POS>
    END ELSE
    CATEG.ID = ''
    END

* Select all the AA.OVERDUE.STATS record's.
    SEL.CMD = ''
    SEL.CMD = 'SELECT ':FN.AA.OVERDUE.STATS
    EB.DataAccess.Readlist(SEL.CMD,AA.SEL.REC,'',NO.OF.REC,ERR.RECS)
    OD.REC.CNT = DCOUNT(AA.SEL.REC,@FM)

    BLD.ENQ.LIST = ''

* Read the AA.OVERDUE.STATS record one by one.

    FOR INIT.AA.OD = 1 TO OD.REC.CNT
        OD.REC.ID = AA.SEL.REC<INIT.AA.OD>
        R.AA.OVERDUE.STATS = ''
        ERR.OD.REC = ''
        R.AA.OVERDUE.STATS = AA.Overdue.OverdueStats.Read(OD.REC.ID, ERR.OD.REC)

        FINDSTR "GRC" IN R.AA.OVERDUE.STATS<AA.Overdue.OverdueStats.OdStOdStatus> SETTING FMP,VMP,SMP THEN
            START.DATE = R.AA.OVERDUE.STATS<AA.Overdue.OverdueStats.OdStStartDate,VMP,SMP>
            DIFFERENCE = "C"
            END.DATE = EB.SystemTables.getToday()
            EB.API.Cdd("",START.DATE,END.DATE,DIFFERENCE)
            TOT.OD.DAYS = DIFFERENCE
            * Find out the Credit Movement.

            OD.MVMT.CRDT = R.AA.OVERDUE.STATS<AA.Overdue.OverdueStats.OdStMvmtDebit,VMP,SMP>
        END


        * Read the AA.ARRANGEMENT record by using AA Id.

        AA.ARR.ID = FIELD(OD.REC.ID,'-',1)
        R.AA.ARRANGEMENT = ''
        ERR.ARR = ''
        R.AA.ARRANGEMENT = AA.Framework.Arrangement.Read(AA.ARR.ID, ERR.ARR)
        ARR.STRT.DATE = R.AA.ARRANGEMENT<AA.Framework.Arrangement.ArrStartDate>

* During enquiry launch, system should not rely on common variables.
* Hence instead of fetching customer record from AA.GET.PROPERTY.RECORD which relies on common variable inside AA.GET.ARRANGEMENT.CUSTOMER,
* get record by calling AA.GET.ARRANGEMENT.CONDITIONS by reading the record from the database.

        EFF.DATE = EB.SystemTables.getToday()
        RCustomer = ''   ;* stores customer record
        AA.Framework.GetArrangementConditions(AA.ARR.ID, "CUSTOMER", "", EFF.DATE, "", RCustomer, "")  ;* get customer record
        RCustomer = RAISE(RCustomer)    ;* raise the record    
    
        AA.Customer.GetArrangementCustomer(AA.ARR.ID, "", RCustomer, "", "", ARR.CUS.ID, RET.ERROR)  ;* returns the arrangement customer

        AA.AR.ACC.ID = AA.ARR.ID:'-ACCOUNT-':ARR.STRT.DATE:'.1'
        R.AA.ARR.ACC = AA.Account.ArrAccount.Read(AA.AR.ACC.ID, ERR.ACC)
        AA.ARR.CATEG = R.AA.ARR.ACC<3>

        * Form the Final Array to display .

        IF CATEG.ID NE '' THEN
            IF AA.ARR.CATEG EQ CATEG.ID THEN
                BLD.ENQ.LIST<-1> = AA.ARR.ID:'*':AA.ARR.CATEG:'*':TOT.OD.DAYS:'*':OD.MVMT.CRDT:'*':ARR.CUS.ID
            END
        END ELSE
            BLD.ENQ.LIST<-1> = AA.ARR.ID:'*':AA.ARR.CATEG:'*':TOT.OD.DAYS:'*':OD.MVMT.CRDT:'*':ARR.CUS.ID
        END
    NEXT INIT.AA.OD

    EB.Reports.setDummy12(3, 'Y')

    RETURN

*** </region>

    END
