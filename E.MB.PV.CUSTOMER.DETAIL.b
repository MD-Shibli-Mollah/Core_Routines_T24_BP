* @ValidationCode : MjoxNzcwOTI1MDE2OkNwMTI1MjoxNTg3OTc1NTYxNTY3OmphYmluZXNoOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDEuMjAxOTEyMjQtMTkzNToxMjM6MTE3
* @ValidationInfo : Timestamp         : 27 Apr 2020 13:49:21
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jabinesh
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 117/123 (95.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202001.20191224-1935
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*---------------------------------------------------------------------------------------
* <Rating>-94</Rating>
*---------------------------------------------------------------------------------------
* Subroutine to select the records of both PV.CUSTOMER.DETAIL and PV.CUSTOMER.DETAIL.HIS for a particular contract or for
* all based on the selection criteria
* attached in STANDARD.SELECTION for the NOFILE enquiry PV.CUSTOMER.DETAIL.
$PACKAGE PV.ModelBank
SUBROUTINE E.MB.PV.CUSTOMER.DETAIL(Y.DATA)
**************************************************************************************************
* Modification History:
***********************
* 13/04/2015 - Defect - 1293675/ Task - 1314727
*              Incorrect variable used in PV.CUSTOMER.DETAIL.HIST opf.
*
* 15/06/2015 - Defect -  1369505 / Task - 1379106
*              Enquiry PV.CUSTOMER.DETAIL show all records from history files, since
*              variable CUSTOMER.NO is nullified before use in select query of history file.
*
* 01/02/2017 - Defect - 1998436 / Task - 2005022
*              Enquiry PV.CUSTOMER.DETAIL shows manual class at wrong dates where originally
*              no manual classification has been done.
*
* 21/04/2020 - Enhancemnet 3688922 / Task 3688770
*              Capture position type details in the enquiry data of multi Gaap provisioning
**************************************************************************************************

    $USING PV.Config
    $USING EB.DataAccess
    $USING EB.Reports
    $USING PV.ModelBank


*MAIN PROCESSING
    GOSUB INITIALISE
    GOSUB OPENFILES
    GOSUB SELECTFILES

RETURN
*---------------------------------------------------------------------------------------
INITIALISE:
*---------------------------------------------------------------------------------------
*Variables for opening PV.CUSTOMER.DETAIL and PV.CUSTOMER.DETAIL.HIS

    FN.PV.CUSTOMER.DETAIL = 'F.PV.CUSTOMER.DETAIL'
    F.PV.CUSTOMER.DETAIL = ''

    FN.PV.CUSTOMER.DETAILHIS = 'F.PV.CUSTOMER.DETAIL.HIST'
    F.PV.CUSTOMER.DETAILHIS = ''

*---------------------------------------------------------------------------------------

    SEL.CMD = ''
    SEL1.CMD = ''
    SEL.LIST = ''
    SEL1.LIST = ''
    NO.OF.SEL = ''
    NO.OF.SEL1 = ''
    SEL.ERR = ''
    SEL1.ERR = ''
    CUSTOMERDETAILS.ID = ''
    CUSTOMERDETAILHIS.ID = ''
    R.CUSTOMERDETAIL = ''
    R.CUSTOMERDETAILHIS = ''
    POS = ''
    POS1 = ''
    MGMT.ID = ''    ;* Holds list of Management id for a customer
    HIS.MGMT.ID = ''          ;* Holds list of Management id for a customer from history record
    
*----------------------------------------------------------------------------------------
* Variables to hold the both PV.CUSTOMER.DETAIL and PV.CUSTOMER.DETAIL.HIS Details
* Initilaise them with DUMMY values in order to maintain null values at their positions
*
    CUSTOMER.ID = ''
    PROFILE.ID = 'DUMMY'
    LAST.CLASS.DATE = 'DUMMY'
    AUTO.CLASS = 'DUMMY'
    MANUAL.CLASS = 'DUMMY'
*-----------------------------------------------------------------------------------------

    ARRAY = ''
    ARRAY1 = ''
    Y.DATA = ''

*---------------------------------------------------------------------------------------
* Getting the Customer Id from the Selection Criteria

    LOCATE '@ID' IN EB.Reports.getEnqSelection()<2,1> SETTING CUSTOMER.ID THEN
        CUSTOMER.NO = EB.Reports.getEnqSelection()<4,CUSTOMER.ID>
    END

RETURN

*---------------------------------------------------------------------------------------
OPENFILES:

    EB.DataAccess.Opf(FN.PV.CUSTOMER.DETAIL,F.PV.CUSTOMER.DETAIL)
    EB.DataAccess.Opf(FN.PV.CUSTOMER.DETAILHIS,F.PV.CUSTOMER.DETAILHIS)

RETURN

*---------------------------------------------------------------------------------------
SELECTFILES:
*---------------------------------------------------------------------------------------
* Selecting the PV.CUSTOMER.DETAIL record based on the selection criteria
    IF CUSTOMER.NO EQ '' THEN
        SEL.CMD = 'SELECT ':FN.PV.CUSTOMER.DETAIL:' BY @ID'
    END ELSE
        SEL.CMD = 'SELECT ':FN.PV.CUSTOMER.DETAIL:' WITH @ID EQ ':CUSTOMER.NO
        SEL1.CMD = 'SELECT ':FN.PV.CUSTOMER.DETAIL:" WITH @ID LIKE ":CUSTOMER.NO:"*..."     ;* Command to select multi Gaap provision for the customer
    END

    GOSUB READ.LIVE.FILE      ;* Fetch customer provision details from live file
    
RETURN
*---------------------------------------------------------------------------------------
READ.LIVE.FILE:
*---------------

* Selecting the PV.CUSTOMER.DETAIL.HIS record based on the selection criteria
    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,'',NO.OF.SEL,SEL.ERR)
    
*** Selecting Multi Gaap provision for the provided customer.
*** Multi Gaap Customer detail Id contain Customer and Position type, both are seperated by '*' delimiter,
*** therefore the multi Gaap selection will be based on the customer with '*' delimiter.
    IF SEL.LIST AND SEL1.CMD THEN
        EB.DataAccess.Readlist(SEL1.CMD,SEL1.LIST,'',NO.OF.SEL1,SEL1.ERR)
        IF SEL1.LIST THEN
            SEL.LIST<-1> = SEL1.LIST
        END
    END

*Loop begins here

    LOOP
        REMOVE CUSTOMERDETAIL.ID FROM SEL.LIST SETTING POS
    WHILE CUSTOMERDETAIL.ID:POS

* Reading the PV.CUSTOMER.DETAIL record for the particular Contract Id

        R.CUSTOMERDETAIL = PV.Config.CustomerDetail.Read(CUSTOMERDETAIL.ID, CUSTOMER.ERR)
        
*** If the customer detial is GAAP specific, then position type should be extracted from the @ID and the position detail updated in the seperate column
        POSITION.TYPE = FIELD(CUSTOMERDETAIL.ID,'*',2)
        IF POSITION.TYPE THEN
            CUSTOMER.NO = FIELD(CUSTOMERDETAIL.ID,'*',1)
        END ELSE
            CUSTOMER.NO = CUSTOMERDETAIL.ID
        END
* Get the count of Management Id and for each management id get the available classification details
* such as Last class date, Auto class and Manual calss
        MGMT.ID = R.CUSTOMERDETAIL<PV.Config.CustomerDetail.PvcdManagementId>
        MGMT.CNT = DCOUNT(MGMT.ID,@VM)
        FOR MGMT.POS = 1 TO MGMT.CNT
            CUR.CLASS.CNT = DCOUNT(R.CUSTOMERDETAIL<PV.Config.CustomerDetail.PvcdPrClassDte,MGMT.POS>,@SM)
            PROFILE.ID<1,-1> = R.CUSTOMERDETAIL<PV.Config.CustomerDetail.PvcdManagementId,MGMT.POS>
            LAST.CLASS.DATE<1,-1> = R.CUSTOMERDETAIL<PV.Config.CustomerDetail.PvcdLastClassDate,MGMT.POS>
            AUTO.CLASS<1,-1> = R.CUSTOMERDETAIL<PV.Config.CustomerDetail.PvcdAutoClass,MGMT.POS>
            MANUAL.CLASS<1,-1> = R.CUSTOMERDETAIL<PV.Config.CustomerDetail.PvcdManualClass,MGMT.POS>
* Get the count of prrevious calssification details such as Previous class date, previous auto
* Manual class for individaual management id for display
            FOR CUR.CLASS.POS = 1 TO CUR.CLASS.CNT
                PROFILE.ID<1,-1> = ''
                LAST.CLASS.DATE<1,-1> = R.CUSTOMERDETAIL<PV.Config.CustomerDetail.PvcdPrClassDte,MGMT.POS,CUR.CLASS.POS>
                AUTO.CLASS<1,-1> = R.CUSTOMERDETAIL<PV.Config.CustomerDetail.PvcdPrAutoClass,MGMT.POS,CUR.CLASS.POS>
                MANUAL.CLASS<1,-1> = R.CUSTOMERDETAIL<PV.Config.CustomerDetail.PvcdPrManClass,MGMT.POS,CUR.CLASS.POS>
            NEXT CUR.CLASS.POS
        NEXT MGMT.POS

*----------------------------------------------------------------------------------------
* Forming the Final array which contains all the necessary details from PV.CUSTOMER.DETAIL
* each data seperated by '*' to be returned from the routine

* For Reference, the positions in which each data will be hold in the array seperated by '*' are
*-----------------------------------------------------------------------------------------
* PV.CUSTOMER.DETAIL Data
*-----------------------------------------------------------------------------------------
* POS<1> = CUSTOMER , POS<2> = MANAGEMENT.ID , POS<3> = LAST.CLASS.DATE , POS<4> = AUTO.CLASS
* POS<5> = MANUAL.CLASS , POS<6> = POSITION.TYPE
* Delete initial zero value in order to maintain the value position
        GOSUB DEL.FROM.ARRAY
        ARRAY = CUSTOMER.NO:'~':PROFILE.ID:'~':LAST.CLASS.DATE:'~':AUTO.CLASS:'~':MANUAL.CLASS:'~':POSITION.TYPE

        Y.DATA<-1> = ARRAY

*--------------------------------------------------------------------------------------
* All the Variables holding the data are made null to hold new data in the next Loop
* Initilaise them with DUMMY values in order to maintain null values at their positions

        PROFILE.ID = 'DUMMY'
        LAST.CLASS.DATE = 'DUMMY'
        AUTO.CLASS = 'DUMMY'
        MANUAL.CLASS = 'DUMMY'
        MGMT.ID = ''
        GOSUB READ.HIST.FILE
    REPEAT
*loop ends here

RETURN
*---------------------------------------------------------------------------------------
READ.HIST.FILE:
*--------------
* Selecting the PV.CUSTOMER.DETAIL.HIS record based on the pv customer detail seq no last updated

    HIS.IDS.MAX = R.CUSTOMERDETAIL<PV.Config.CustomerDetail.PvcdSeqNo>
    LOOP
    WHILE HIS.IDS.MAX

* Reading the PV.CUSTOMER.DETAIL.HIS record for the particular Contract Id
        CUSTOMERDETAILHIS.ID = CUSTOMERDETAIL.ID:";":HIS.IDS.MAX
        R.CUSTOMERDETAILHIS = PV.Config.CustomerDetailHist.Read(CUSTOMERDETAILHIS.ID, CUSTOMERDETAILHIS.ERR)
* Get the count of prrevious calssification details such as Previous class date, previous auto
* Manual class for individaual management id for display from history file
        HIS.MGMT.ID = R.CUSTOMERDETAILHIS<PV.Config.CustomerDetail.PvcdManagementId>
        HIS.MGMT.CNT = DCOUNT(HIS.MGMT.ID,@VM)
        FOR HIS.MGMT.POS = 1 TO HIS.MGMT.CNT
            HIS.CLASS.CNT = DCOUNT(R.CUSTOMERDETAILHIS<PV.Config.CustomerDetail.PvcdPrClassDte,HIS.MGMT.POS>,@SM)
            PROFILE.ID<1,-1> = R.CUSTOMERDETAILHIS<PV.Config.CustomerDetail.PvcdManagementId,HIS.MGMT.POS>
            FOR HIS.CLASS.POS = 1 TO HIS.CLASS.CNT
                PROFILE.ID<1,-1> = ''
                LAST.CLASS.DATE<1,-1> = R.CUSTOMERDETAILHIS<PV.Config.CustomerDetail.PvcdPrClassDte,HIS.MGMT.POS,HIS.CLASS.POS>
                AUTO.CLASS<1,-1> = R.CUSTOMERDETAILHIS<PV.Config.CustomerDetail.PvcdPrAutoClass,HIS.MGMT.POS,HIS.CLASS.POS>
                MANUAL.CLASS<1,-1> = R.CUSTOMERDETAILHIS<PV.Config.CustomerDetail.PvcdPrManClass,HIS.MGMT.POS,HIS.CLASS.POS>
            NEXT HIS.CLASS.POS
        NEXT HIS.MGMT.POS

*----------------------------------------------------------------------------------------
* Forming the Final array which contains all the necessary details from PV.CUSTOMER.DETAIL
* each data seperated by '*' to be returned from the routine
* For Reference, the positions in which each data will be hold in the array seperated by '*' are
*-----------------------------------------------------------------------------------------
* PV.CUSTOMER.DETAIL Data
*-----------------------------------------------------------------------------------------
* POS<1> = CUSTOMER , POS<2> = MANAGEMENT.ID , POS<3> = LAST.CLASS.DATE , POS<4> = AUTO.CLASS
* POS<5> = MANUAL.CLASS , POS<6> = POSITION.TYPE
* Delete initial zero value in order to maintain the value position
        GOSUB DEL.FROM.ARRAY
        ARRAY1 = CUSTOMER.NO:'~':PROFILE.ID:'~':LAST.CLASS.DATE:'~':AUTO.CLASS:'~':MANUAL.CLASS:'~':POSITION.TYPE

        Y.DATA<-1> = ARRAY1

*--------------------------------------------------------------------------------------
* All the Variables holding the data are made null to hold new data in the next Loop
* Initilaise them with DUMMY values in order to maintain null values at their positions
        PROFILE.ID = 'DUMMY'
        LAST.CLASS.DATE = 'DUMMY'
        AUTO.CLASS = 'DUMMY'
        MANUAL.CLASS = 'DUMMY'
        HIS.MGMT.ID = ''
        HIS.IDS.MAX -= 1
    REPEAT
*Loop ends here

RETURN
*---------------------------------------------------------------------------------------
DEL.FROM.ARRAY:
*--------------
* Delete the first position array since it is only to ensure the position of dates and calssification
* value does not changes due to appending to arrays

    DEL PROFILE.ID<1,1>
    DEL LAST.CLASS.DATE<1,1>
    DEL AUTO.CLASS<1,1>
    DEL MANUAL.CLASS<1,1>

RETURN
*---------------------------------------------------------------------------------------

END
