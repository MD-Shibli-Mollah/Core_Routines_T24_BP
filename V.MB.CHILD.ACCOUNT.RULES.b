* @ValidationCode : MjotNDM0NzI5NzE6Q3AxMjUyOjE2MDY4MTQ2NTYzNzQ6bm1hcnVuOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTEuMjAyMDEwMjktMTc1NDoxMjg6NjI=
* @ValidationInfo : Timestamp         : 01 Dec 2020 14:54:16
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nmarun
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 62/128 (48.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>497</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE V.MB.CHILD.ACCOUNT.RULES
*
* Subroutine Type       :       VERSION API
* Attached to           :       ACCOUNT,CHILD.SB.LCY
* Attached as           :       INPUT.ROUTINE
* Primary Purpose       :       Invoke MB.CALCULATE.AGE and test the age against the requirements for a Child Account
*                               Raise Error if more than 18 and Override if 18. Do nothing if less than 18.
*                               <<Could be expanded to include more rules pertaining the Children Accounts
* Incoming:
* ---------
* None.
*
* Outgoing:
* ---------
*
*
* Error Variables:
* ----------------
*
*
*-----------------------------------------------------------------------------------
* Modification History:
*
* 27 OCT 2010 - Sathish PS
*               New Development for SI RMB1 Refresh Retail Model Bank
*
* 11/01/12 - Task 335791
*            Change the reads to Service api calls.
*
* 08/10/20 - Enhancement : 3930173
*            Task        : 3930176
*            MDAL party changes - Get customer's date of birth by calling CustomerProfile API
*
* 05/11/20 - Enhancement : 3930698
*            Task        : 4070455
*            Fetch Category Description using ReferenceData MDAL API
*
*-----------------------------------------------------------------------------------

    $USING AC.AccountOpening
    $USING ST.Customer
    $USING ST.Config
    $USING AC.Config
    $USING EB.ErrorProcessing
    $USING AC.ModelBank
    $USING EB.OverrideProcessing
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING MDLPTY.Party
    $USING MDLREF.ReferenceData

    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB CHECK.PRELIM.CONDITIONS
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

    IF EB.SystemTables.getEtext() THEN
        EB.SystemTables.setAf(AC.AccountOpening.Account.Customer)
        EB.ErrorProcessing.StoreEndError()
    END

RETURN          ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:

    GOSUB TEST.AGE.RULES

    IF PROCESS.GOAHEAD THEN
        ! Add additional Rules here
    END

RETURN          ;* from PROCESS
*-----------------------------------------------------------------------------------
TEST.AGE.RULES:

    AC.ModelBank.MbCalculateAge(AGE,AGE.ON.DATE,DATE.OF.BIRTH)
    IF EB.SystemTables.getE() THEN
        EB.SystemTables.setEtext(EB.SystemTables.getE())
        PROCESS.GOAHEAD = 0
    END ELSE
        GOSUB TEST.AGE.AND.RAISE.OVERRIDE.OR.ERROR
    END

RETURN
*-----------------------------------------------------------------------------------
TEST.AGE.AND.RAISE.OVERRIDE.OR.ERROR:

    BEGIN CASE
        CASE NOT(NUM(AGE))
            EB.SystemTables.setEtext('EB-RMB1.INVALID.AGE')
            tmp=EB.SystemTables.getEtext(); tmp<2,1>=AGE; EB.SystemTables.setEtext(tmp)
            tmp=EB.SystemTables.getEtext(); tmp<2,2>=DATE.OF.BIRTH; EB.SystemTables.setEtext(tmp)
            tmp=EB.SystemTables.getEtext(); tmp<2,3>=AGE.ON.DATE; EB.SystemTables.setEtext(tmp)
            PROCESS.GOAHEAD = 0

        CASE AGE GT AGE.THRESHOLD
            EB.SystemTables.setEtext('EB-RMB1.CUSTOMER.AGE.NOT.WITHIN.THRESHOLD')
            tmp=EB.SystemTables.getEtext(); tmp<2,1>=AGE; EB.SystemTables.setEtext(tmp)
            tmp=EB.SystemTables.getEtext(); tmp<2,2>=AGE.THRESHOLD; EB.SystemTables.setEtext(tmp)
            tmp=EB.SystemTables.getEtext(); tmp<2,3>=CATEGORY.DESC; EB.SystemTables.setEtext(tmp)
            PROCESS.GOAHEAD = 0

        CASE AGE EQ AGE.THRESHOLD
            EB.SystemTables.setText('RMB1.CUST.CROSS.AGE.THRESHOLD.TODAY')
            tmp=EB.SystemTables.getText(); tmp<2,1>=DATE.OF.BIRTH; EB.SystemTables.setText(tmp)
            tmp=EB.SystemTables.getText(); tmp<2,2>=AGE.THRESHOLD; EB.SystemTables.setText(tmp)
            tmp=EB.SystemTables.getText(); tmp<2,3>=CATEGORY.DESC; EB.SystemTables.setText(tmp)
            EB.OverrideProcessing.StoreOverride(1)

        CASE AGE LE AGE.THRESHOLD AND AGE GE (AGE.THRESHOLD-1)
            EB.SystemTables.setText('RMB1.CUST.TO.CROSS.AGE.THRESHOLD')
            tmp=EB.SystemTables.getText(); tmp<2,1>=AGE; EB.SystemTables.setText(tmp)
            tmp=EB.SystemTables.getText(); tmp<2,2>=AGE.THRESHOLD; EB.SystemTables.setText(tmp)
            tmp=EB.SystemTables.getText(); tmp<2,3>=CATEGORY.DESC; EB.SystemTables.setText(tmp)
            EB.OverrideProcessing.StoreOverride(1)
        CASE 1

    END CASE

RETURN
*-----------------------------------------------------------------------------------
* <New Subroutines>

* </New Subroutines>
*-----------------------------------------------------------------------------------*
*//////////////////////////////////////////////////////////////////////////////////*
*////////////////P R E  P R O C E S S  S U B R O U T I N E S //////////////////////*
*//////////////////////////////////////////////////////////////////////////////////*
INITIALISE:

    PROCESS.GOAHEAD = 1
    AGE.ON.DATE = EB.SystemTables.getToday()
    AGE.THRESHOLD = 18

RETURN          ;* From INITIALISE
*-----------------------------------------------------------------------------------
OPEN.FILES:

    FN.CUS.LOC = 'F.CUSTOMER' ; F.CUS = ''
    FN.CATEG = 'F.CATEGORY' ; F.CATEG = ''
    FN.AC.CLASS = 'F.ACCOUNT.CLASS' ; F.AC.CLASS = ''

RETURN          ;* From OPEN.FILES
*-----------------------------------------------------------------------------------
CHECK.PRELIM.CONDITIONS:
*
    LOOP.CNT = 1 ; MAX.LOOPS = 3
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO

        BEGIN CASE
            CASE LOOP.CNT EQ 1
                ID.CUS = EB.SystemTables.getRNew(AC.AccountOpening.Account.Customer)
                IF NOT(ID.CUS) THEN
                    EB.SystemTables.setEtext('EB-RMB1.CUSTOMER.INPUT.MISSING')
                END

            CASE LOOP.CNT EQ 2

                DATE.OF.BIRTH = ''
                customerKey = ID.CUS
                dataField = ''
                SaveEtext = ''
                SaveEtext = EB.SystemTables.getEtext() ;* Before calling MDAL API, Save EText to restore it later
                EB.SystemTables.setEtext("")  ;* set Error text to Null
                CustomerRecord = ""
                CustomerRecord = MDLPTY.Party.getCustomerProfile(customerKey)
                EB.SystemTables.setEtext(SaveEtext)   ;* Restore the old EText Values
                dataField = CustomerRecord<MDLPTY.Party.CustomerProfile.dateofBirth>
                Y.DOB = dataField
                IF dataField THEN
                    DATE.OF.BIRTH = Y.DOB
                    IF NOT(DATE.OF.BIRTH) THEN
                        EB.SystemTables.setEtext('EB-RMB1.DATE.OF.BIRTH.MISSING.IN.CUSTOMER')
                        tmp=EB.SystemTables.getEtext(); tmp<2,1>=ID.CUS; EB.SystemTables.setEtext(tmp)
                    END
                END ELSE
                    EB.SystemTables.setEtext('EB-RMB1.REC.MISS.FILE')
                    tmp=EB.SystemTables.getEtext(); tmp<2,1>=ID.CUS; EB.SystemTables.setEtext(tmp)
                    tmp=EB.SystemTables.getEtext(); tmp<2,2>=FN.CUS.LOC; EB.SystemTables.setEtext(tmp)
                END

            CASE LOOP.CNT EQ 3
                ID.CATEG = EB.SystemTables.getRNew(AC.AccountOpening.Account.Category)
                GOSUB CHECK.ACCOUNT.CLASS

            CASE LOOP.CNT EQ 4
                CATEGORY.DESC = '' ; R.CATEG = ''
                SAVE.ETEXT = ""
                SAVE.ETEXT = EB.SystemTables.getEtext()  ;* Save Etext Values to restore it later
                EB.SystemTables.setEtext('')
                R.CATEG = MDLREF.ReferenceData.getCategoryDetails(ID.CATEG)  ;* Get Category details to fetch description from it
                EB.SystemTables.setEtext(SAVE.ETEXT)  ;* restore the saved Etext values
                IF R.CATEG THEN
                    CATEGORY.DESC = R.CATEG<MDLREF.ReferenceData.CategoryDetails.descriptions.description,EB.SystemTables.getLngg()>
                END ELSE
                    EB.SystemTables.setEtext('EB-RMB1.REC.MISS.FILE')
                    tmp=EB.SystemTables.getEtext(); tmp<2,1>=ID.CATEG; EB.SystemTables.setEtext(tmp)
                    tmp=EB.SystemTables.getEtext(); tmp<2,2>=FN.CATEG; EB.SystemTables.setEtext(tmp)
                END


        END CASE

        LOOP.CNT += 1

        IF EB.SystemTables.getEtext() THEN
            PROCESS.GOAHEAD = 0
        END

    REPEAT

RETURN          ;* From CHECK.PRELIM.CONDITIONS
*-----------------------------------------------------------------------------------
CHECK.ACCOUNT.CLASS:
    !
    ! U-CHILD.ACCOUNT will have the relevant CATEGORY codes that belong to Children Account
    ! class. If our category is not in there, then no need to validate the age.
    !
    ID.AC.CLASS = 'U-CHILD.ACCOUNT' ; R.AC.CLASS = '' ; ERR.AC.CLASS = ''
    R.AC.CLASS = AC.Config.AccountClass.CacheRead(ID.AC.CLASS, ERR.AC.CLASS)
    IF R.AC.CLASS THEN
        CHILD.CATEGS = R.AC.CLASS<AC.Config.AccountClass.ClsCategory>
        IF NOT(ID.CATEG MATCHES CHILD.CATEGS) THEN
            PROCESS.GOAHEAD = 0
        END
    END ELSE
        EB.SystemTables.setEtext('EB-RMB1.REC.MISS.FILE')
        tmp=EB.SystemTables.getEtext(); tmp<2,1>=ID.AC.CLASS; EB.SystemTables.setEtext(tmp)
        tmp=EB.SystemTables.getEtext(); tmp<2,2>=FN.AC.CLASS; EB.SystemTables.setEtext(tmp)
    END

RETURN
*-----------------------------------------------------------------------------------
END
