* @ValidationCode : MjotMTY0ODMyNzU0OkNwMTI1MjoxNTU3MjMzODgxOTE2OmtzbXVrZXNoOjE6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxOTA0LjIwMTkwNDEwLTAyMzk6Mzg2OjIzNQ==
* @ValidationInfo : Timestamp         : 07 May 2019 18:28:01
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ksmukesh
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 235/386 (60.8%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201904.20190410-0239
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-562</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.HighVolume
SUBROUTINE CONV.SUB.ACCOUNT.TO.HVT(ACCOUNT.KEY)

* 11/04/2011 - Enhancement 211042 / TASK 211365
*              Conversion to change existing Sub Accounts to New HVT Design.
*
* 05/12/2011 - Defect 317404 / Task 319336
*              Initializing uninitialized variables
*
* 21/01/2012 - Defect 343665 / Task 343675
*              While conversion account balance informations are moved to ECB and the values in account
*              will be nullified. Hence before writing Readu and then write so that the information processed
*              in other routines are not overwritten.
*
* 23/01/2012 - Defect 343664 / Task 343537
*              CONV.SUB.ACCOUNT routine is renamed to CONV.SUB.ACCOUNT.TO.HVT
*
* 28/11/12 - Defect 489197 / Task 507898
*            In order to avoid locking problem while removing closed sub account reference from customer
*            related files. A new routine CLOSE.SUB.ACCOUNT is introduced which is a copy of DELTE.CLOSED.ACCOUNTS
*            and the process of deleting customer related files is moved to this routine.
*
* 17/10/13 - Defect 809977 / Task 810568
*            Removed the insert files which causes error on Cross compilation for the amendment on I_DELETE.CLOSED.ACCOUNTS.POST.COMMON.
*
* 20/11/13 - Task 842197
*            Merge ACCT.ENT.LWORK.DAY files, since IC entries will directly update acct.ent.lwork.day directly during cob
*
* 27/02/14 - Defect 900620 / Task 927015
*            Sub account related files not merged to master account & deleted from system
*
* 04/08/14 - Defect 1074107 / Task 1076126
*            While upgrading to higher release (R13) system completely removes the category from CATEG.INT.ACCT
*            file instead of removing the sub account reference alone from the CATEG.INT.ACCT
*
* 08/08/14 - Defect 975424 / Task 1023608
*            Reversal of Consol update work is done from each sub account ecb instead of from final merged ECB.
*            Check if consol key is shared between master account and sub account and decide whether to individually
*            reverse sub account balances or not by setting SHARED CONSOL KEY flag.
*
* 11/12/14 - Defect 1136644 / Task 1195719
*            Initialised the variables CUST.ACCT.READ, CUST.ACCT.CCY.READ
*
* 21/12/15 - Defect 1547290 / Task 1575998
*            When Sub Account structure is converted to HVT, START.YEAR.BAL of Master Account
*            is updated correctly.
*
* 02/05/19 - Defect 3093180 / Task 3111891
*            When merge Sub Accounts with Master Account we missed to merge the Last
*            balancesin Account Statment record. Changes done to consolidate the Sub
*            accounts FQU1.LAST.BALANCES and FQU2.LAST.BAL and merge it with Master
*            Account
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_BATCH.FILES
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.AC.HVT.TRIGGER
    $INSERT I_AC.HVT.MERGE.COMMON
    $INSERT I_F.ACCOUNT.PARAMETER
    $INSERT I_CONV.SUB.ACCOUNT.TO.HVT.COMMON
    $INSERT I_F.STATIC.CHANGE.TODAY
    $INSERT I_DAS.AC.HVT.TRIGGER
    $INSERT I_F.ACCOUNT
    $INSERT I_F.EB.CONTRACT.BALANCES
    $INSERT I_F.CUST.ACCT.CCY.REC
    $INSERT I_F.AC.STMT.PARAMETER
    $INSERT I_F.AC.AUTO.ACCOUNT
    $INSERT I_F.COMPANY
    $INSERT I_F.ACCOUNT.STATEMENT
    
*----------------------------------------------------------------------------
* For merge service trigger id is passed as parameter not account id
* For Del nostro account id from DEL.CCY.WORK is passed
    IF NOT(CONTROL.LIST<1,1> MATCHES 'CALL.AC.HVT.MERGE':@VM:'DEL.NOSTRO.ACCT') THEN
        GOSUB READ.ACCOUNT
        IF R.ACCOUNT.RECORD<AC.ALL.IN.ONE.PRODUCT> THEN
            RETURN  ;* Dont process sub accounts related to AZ Contracts.
        END

        IF YERR  THEN
            CALL F.DELETE(FN.AC.SUB.ACCOUNT,ACCOUNT.KEY)
        END
    END

    BEGIN CASE

        CASE CONTROL.LIST<1,1> EQ 'CALL.AC.HVT.MERGE' ;* Call the AC.HVT.MERGE servcie to merge the records updated in trigger by UNAUTH.PROCESSING
            CALL AC.HVT.MERGE(ACCOUNT.KEY)

        CASE CONTROL.LIST<1,1> = "MERGE.AC.SUB.ACCOUNT.TO.MASTER"
*
* If already HVT account donot process
            IF R.ACCOUNT.RECORD<AC.HVT.FLAG> EQ 'YES' THEN
                RETURN
            END
            GOSUB REAL.MERGE.PROCESS

        CASE CONTROL.LIST<1,1> = "DEL.NOSTRO.ACCT"

            IF ACCOUNT.KEY['*',1,1] EQ "DEL.ACC" THEN ;* Passed is account details to delete concat files
                GOSUB DELETE.FILES
            END ELSE
                CALL DELETE.CLOSED.ACCOUNTS.POST(ACCOUNT.KEY)   ;* Passed id is CCY to delete nostro related files
            END

        CASE CONTROL.LIST<1,1> = "DELETE.AC.SUB.ACCOUNT"

            GOSUB DELETE.AC.SUB.ACCOUNT

    END CASE

RETURN
*
*-------------------------------------------------------------------------------------------
REAL.MERGE.PROCESS:
*----------
* Read each sub account to fetch the START.YEAR.BAL and add to the variable which holds consolidated balance.
* Finally add the START.YEAR.BAL of the master account to that variable.

    CALL F.READ(FN.AC.SUB.ACCOUNT,ACCOUNT.KEY,R.AC.SUB.ACCOUNT,F.AC.SUB.ACCOUNT,YERR)
    SUB.ACCOUNTS = ''
    SUB.CNT = DCOUNT(R.AC.SUB.ACCOUNT,FM)
    FOR I = 1 TO SUB.CNT
        IF R.AC.SUB.ACCOUNT<I> THEN
            SUB.ACCOUNTS<-1> = R.AC.SUB.ACCOUNT<I>
        END
    NEXT I

* Put the AC.SUB.ACCOUNT ID in common variable and set conversion flag to yes.
    SAVE.MASTER.ACCOUNT.ID = ACCOUNT.KEY
    GOSUB CHECK.ACCOUNT.TYPE
    CONVERSION = 'YES'
    HVT.CLOSURE = 'YES'

    IF SUB.ACCOUNTS THEN
        ACCOUNT.KEYS = LOWER(SUB.ACCOUNTS)
        GOSUB INITIALISE
        LOOP
            REMOVE SUB.ACCOUNT.ID FROM SUB.ACCOUNTS SETTING AC.POS
        WHILE SUB.ACCOUNT.ID:AC.POS
            CALL F.READ(FN.ACCOUNT.RECORD, SUB.ACCOUNT.ID, R.SUB.ACCOUNT.RECORD, FV.ACCOUNT.RECORD, YERR)
            IF NOT(YERR) AND R.SUB.ACCOUNT.RECORD<AC.START.YEAR.BAL> THEN
                CONSOLIDATED.START.YEAR.BAL += R.SUB.ACCOUNT.RECORD<AC.START.YEAR.BAL>
            END
            GOSUB MERGE.SUFFIXED.RECORDS
        REPEAT
        CONSOLIDATED.START.YEAR.BAL += R.ACCOUNT.RECORD<AC.START.YEAR.BAL>
        GOSUB MERGE.WITH.MAIN.RECORDS   ;* Finally merge with the main record
    END

    SAVE.MASTER.ACCOUNT.ID = ""
    CONVERSION = ''
    HVT.CLOSURE = ''

RETURN
*
*-------------------------------------------------------------------------------------------
INITIALISE:
*----------
*
    NOTIONAL.MERGE = ''
    STMT.ACTION = ''
    ACTION = ''
    R.MAIN.ACCOUNT.RECORD = ''
    MERGED.AELT = ''
    HVT.YT.YEARM = ''
    R.MERGED.IDS = ''
    R.MERGED.MONTHS = ''
    R.MERGED.RECORDS = ''
    MERGED.AEF = ''
    MERGED.ECB = ''
    MERGED.AET = ''
    MERGED.SVE.IDS = ''
    MERGED.SVE = ''
    MERGED.ASP = ''
    MERGED.STMT.PRINTED = ''
    MERGED.FWD.STMT.PRINTED = ''
    MERGED.AC.VIOLATION = ''
    MERGED.DATE.EXPOSURE = ''
    DATE.EXPOSURE.IDS = ''
    DATE.EXPOSURE.ENTRIES = ''
    CONSOLIDATED.START.YEAR.BAL = 0
    FQU1.LAST.BAL = 0 ;* Consolidated Sub Accounts FQU1.LAST.BALANCES value in Account Statement
    FQU2.LAST.BAL = 0 ;* Consolidated Sub Accounts FQU1.LAST.BAL value in Account Statement
    R.AC.HVT.TRIGGER= ''

    FN.AC.STMT.PARAMETER = 'F.AC.STMT.PARAMETER'
*
    CALL CACHE.READ(FN.AC.STMT.PARAMETER,"SYSTEM",R.AC.STMT.PARAM,PARAM.ERR)
    FWD.MVMT.REQD = ''
    IF R.AC.STMT.PARAM THEN
        FWD.MVMT.REQD = R.AC.STMT.PARAM<AC.STP.FWD.MVMT.REQD>
    END
*
RETURN
*--------------------------------------------------------------------------------------------
MERGE.ACCOUNT.INFORMATION:
*------------------------
*** <region name= MERGE.ACCOUNT.INFORMATION>

* Write the master record when call is for master
* Lock and write the account record to update the correct informations
    CALL F.READU(FN.ACCOUNT.RECORD,ACCOUNT.KEY,R.ACCOUNT.RECORD,FV.ACCOUNT.RECORD,YERR,'')
    IF R.ACCOUNT.RECORD<AC.HVT.FLAG> NE "YES" THEN
        R.ACCOUNT.RECORD<AC.START.YEAR.BAL> = CONSOLIDATED.START.YEAR.BAL
        R.ACCOUNT.RECORD<AC.HVT.FLAG> = "YES"
        R.ACCOUNT.RECORD<AC.MAX.SUB.ACCOUNT> = ""
        CALL F.WRITE(FN.ACCOUNT.RECORD,ACCOUNT.KEY,R.ACCOUNT.RECORD)
    END ELSE
        CALL F.RELEASE(FN.ACCOUNT.RECORD,ACCOUNT.KEY,FV.ACCOUNT.RECORD)
    END
*
RETURN
*---------------------------------------------------------------------------------------------
DELETE.AC.SUB.ACCOUNT:
*--------------------
*** <desc>Mark all Master accounts with HVT.FLAG as 'YES' and also update EB.CONTRACT.BALANCES appropriately </desc>
*
    CALL F.DELETE(FN.AC.SUB.ACCOUNT,ACCOUNT.KEY)

RETURN
*-------------------------------------------------------------------------------------------
*** <region name= MERGE.SUFFIXED.RECORDS>
MERGE.SUFFIXED.RECORDS:
*** <desc> </desc>

    ACTION = 'MERGE'
    STMT.ACTION  = 'MERGE'

    MASTER.ACCOUNT.ID = FIELD(SUB.ACCOUNT.ID,"!",1)

    GOSUB MERGE.SUFFIXED.ECB  ;* Merge the suffixed ECB records
    GOSUB MERGE.SUFFIXED.AET  ;* Merge the suffixed ACCT.ENT.TODAY entries
    GOSUB MERGE.SUFFIXED.SVE  ;* Merge the suffixed STMT.VAL.ENTRY entries
    GOSUB MERGE.SUFFIXED.AEF  ;* Merge  the suffixed ACCT.ENT.FWD file
    GOSUB MERGE.ACCT.ACTIVITY ;* Merge the suffixed Activity records
    GOSUB MERGE.SUFFIXED.STMT.PRINTED   ;* Merge  the suffixed STMT.PRINTED , ACCT.STMT.PRINT records.
    GOSUB MERGE.AC.VIOLATION
    GOSUB MERGE.SUFF.DATE.EXPOSURE      ;* Merge  the suffixed DATE.EXPOSURE file
    GOSUB MERGE.ACCOUNT.STATEMENT       ;* Merge Sub Accounts Last balances value
    GOSUB CALL.DELETE.CLOSED.ACCOUNTS   ;* Delete the trigger record after merging.
    

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= MERGE.WITH.MAIN.RECORDS>
MERGE.WITH.MAIN.RECORDS:
*** <desc> </desc>

    MASTER.ACCOUNT.ID = SAVE.MASTER.ACCOUNT.ID    ;* The ID of AC.SUB.ACCOUNT record will be passed as the Master account during conversion
    ECB.ID = MASTER.ACCOUNT.ID

    GOSUB MERGE.MAIN.ECB      ;* merge the suffixed data into the main record
    GOSUB MERGE.MAIN.AET      ;* Merge the entries to main ACCT.ENT.TODAY record
    GOSUB MERGE.MAIN.SVE      ;*Merge the entries to main STMT.VAL.ENTRY record
    GOSUB MERGE.MAIN.ACCT.ACTIVITY      ;* Merge the suffixed Activity records
    GOSUB MERGE.MAIN.AC.VIOLATION       ;* Merge the suffixed AC.VIOLATION records
    GOSUB MERGE.MAIN.AEF      ;* Update the ACCT.ENT.FWD record with the merged entries
    GOSUB MERGE.MAIN.STMT.PRINTED       ;* Sort and Write the merged STMT.PRINTED and ACCT.STMT.PRINT to their main account
    GOSUB MERGE.MAIN.DATE.EXPOSURE      ;* Update the DATE.EXPOSURE record with the merged entries
    GOSUB MERGE.MAIN.ACCOUNT.STATEMENT  ;* Update Last balance value of Account statement in Master Account
    GOSUB MERGE.ACCOUNT.INFORMATION

RETURN
*** </region>

*-----------------------------------------------------------------------------
CALL.DELETE.CLOSED.ACCOUNTS:
*-------------------

    CALL CLOSE.SUB.ACCOUNT(SUB.ACCOUNT.ID)

RETURN
*
*-------------------------------------------------------------------------------------------
READ.ECB:
*--------

    CALL F.READ(FN.CONTRACT.BALANCES, ECB.ID, R.ECB, FV.CONTRACT.BALANCES,'')   ;* No locking during notional balance requests
*
RETURN
*
*-----------------------------------------------------------------------------
ECB.MERGER:
*-------------------------
* Merging Asset type balance

    IF SHARED.CONSOL.KEY EQ 'NO' THEN
        SAVE.MASTER.ACCOUNT.ID<2> = 'CATEG'
    END
    CALL ECB.SUB.ACCOUNT.MERGER(ECB.ID,MERGED.ECB,ACTION,NOTIONAL.MERGE)

    SAVE.MASTER.ACCOUNT.ID = SAVE.MASTER.ACCOUNT.ID<1>      ;* To be safe as it is a common variable shared accross mergers

RETURN
*
*--------------------------------------------------------------------------------------------
*** <region name= MERGE.ACCT.ACTIVITY>
MERGE.ACCT.ACTIVITY:
*** <desc> </desc>

    ACTION = "MERGE"
    CALL ACCT.ACTIVITY.MERGER(SUB.ACCOUNT.ID,R.AC.HVT.TRIGGER,ACTIVITY.DETAIL,ACTION,NOTIONAL.MERGE)

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MERGE.MAIN.ACCT.ACTIVITY>
MERGE.MAIN.ACCT.ACTIVITY:
*** <desc> </desc>

    ACTION = 'UPDATE'
    CALL ACCT.ACTIVITY.MERGER(MASTER.ACCOUNT.ID,R.AC.HVT.TRIGGER,ACTIVITY.DETAIL,ACTION,NOTIONAL.MERGE)

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MERGE.AC.VIOLATION>
MERGE.AC.VIOLATION:
*** <desc> </desc>

    ACTION = "MERGE"
    CALL AC.VIOLATION.MERGER(SUB.ACCOUNT.ID,R.AC.HVT.TRIGGER,R.AC.VIOLATION,ACTION,NOTIONAL.MERGE)

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MERGE.MAIN.AC.VIOLATION>
MERGE.MAIN.AC.VIOLATION:
*** <desc> </desc>

    ACTION = 'UPDATE'
    CALL AC.VIOLATION.MERGER(MASTER.ACCOUNT.ID,R.AC.HVT.TRIGGER,R.AC.VIOLATION,ACTION,NOTIONAL.MERGE)

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MERGE.SUFFIXED.ECB>
MERGE.SUFFIXED.ECB:
*** <desc> </desc>
    ECB.ID = SUB.ACCOUNT.ID
    GOSUB ECB.MERGER

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MERGE.MAIN.ECB>
MERGE.MAIN.ECB:
*** <desc> </desc>

    ACTION = 'MERGE'
    CONVERSION = 'MASTER.MERGE'
    GOSUB ECB.MERGER
    ACTION = 'UPDATE'
    CONVERSION = 'MASTER.UPDATE'
    GOSUB ECB.MERGER

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= MERGE.SUFFIXED.AET>
MERGE.SUFFIXED.AET:
*** <desc> </desc>
    AET.ID = SUB.ACCOUNT.ID
    ACTION = 'MERGE'
    GOSUB AET.MERGER          ;*

RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= MERGE.MAIN.AET>
MERGE.MAIN.AET:
*** <desc> </desc>

    AET.ID = MASTER.ACCOUNT.ID

    ACTION = 'MERGE'
    GOSUB AET.MERGER          ;*

    ACTION = 'UPDATE'
    GOSUB AET.MERGER          ;*

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= AET.MERGER>
AET.MERGER:
*** <desc> </desc>

    CALL ACCT.ENT.TODAY.MERGER(AET.ID,MERGED.AET,MERGED.AELT,ACTION,NOTIONAL.MERGE)

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MERGE.SUFFIXED.SVE>
MERGE.SUFFIXED.SVE:
*** <desc>Merge the suffixed STMT.VAL.ENTRY entries </desc>

    STMT.VAL.ENTRY.ID = SUB.ACCOUNT.ID
    ACTION = 'MERGE'
    GOSUB SVE.MERGER          ;* Merge the suffixed record
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= MERGE.MAIN.SVE>
MERGE.MAIN.SVE:
*** <desc>Merge the entries to main STMT.VAL.ENTRY record </desc>

    STMT.VAL.ENTRY.ID = MASTER.ACCOUNT.ID
    ACTION = 'UPDATE'
    GOSUB SVE.MERGER          ;*

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= SVE.MERGER>
SVE.MERGER:
*** <desc> </desc>

    CALL STMT.VAL.ENTRY.MERGER(STMT.VAL.ENTRY.ID,MERGED.SVE.IDS,MERGED.SVE,ACTION,NOTIONAL.MERGE)

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MERGE.SUFFIXED.AEF>
MERGE.SUFFIXED.AEF:
*** <desc>Merge the suffixed ACCT.ENT.FWD file </desc>

    AEF.ID = SUB.ACCOUNT.ID
    ACTION = 'MERGE'
    GOSUB AEF.MERGER          ;*

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= MERGE.MAIN.AEF>
MERGE.MAIN.AEF:
*** <desc>Update the ACCT.ENT.FWD record with the merged entries </desc>

    AEF.ID = MASTER.ACCOUNT.ID
    ACTION = 'UPDATE'
    GOSUB AEF.MERGER
RETURN
*** </region>
*-----------------------------------------------------------------------------
MERGE.SUFFIXED.STMT.PRINTED:
***************************
**Merge the STMT.PRINTED and ACCT.STMT.PRINT with suffixed ids

    CALL AC.HVT.MERGE.STMT.CONCAT(SUB.ACCOUNT.ID,STMT.ACTION,FWD.MVMT.REQD)     ;* returns merged STMT.PRINTED and ASP.

RETURN
*-------------------------------------------------------------------------------
MERGE.MAIN.STMT.PRINTED:
************************
**Merge the STMT.PRINTED and ACCT.STMT.PRINT with to their MAIN account.

    CALL AC.HVT.MERGE.STMT.CONCAT(MASTER.ACCOUNT.ID,"UPDATE",'')      ;* returns merged STMT.PRINTED and ASP

RETURN
*--------------------------------------------------------------------------------
*** <region name= MERGE.SUFF.DATE.EXPOSURE>
MERGE.SUFF.DATE.EXPOSURE:
*** <desc> </desc>

    ACTION = 'MERGE'
    CALL DATE.EXPOSURE.MERGER(MASTER.ACCOUNT.ID,ACTION,R.AC.HVT.TRIGGER, NOTIONAL.MERGE,MERGE.ERROR)

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MAIN.DATE.EXPOSURE.MERGE>
MERGE.MAIN.DATE.EXPOSURE:
*** <desc> </desc>
    ACTION = 'UPDATE'
    CALL DATE.EXPOSURE.MERGER(MASTER.ACCOUNT.ID,ACTION,R.AC.HVT.TRIGGER, NOTIONAL.MERGE,MERGE.ERROR)

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= AEF.MERGER>
AEF.MERGER:
*** <desc> </desc>

    CALL ACCT.ENT.FWD.MERGER(AEF.ID, MERGED.AEF, ACTION, NOTIONAL.MERGE)

RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
MERGE.ACCOUNT.STATEMENT:
*-----------------------
* Consolidate FQU1.LAST.BALANCE and FQU2.LAST.BAL value from Sub Accounts Account statment
* record.
*
    ACCT.STMT.ID = SUB.ACCOUNT.ID ;* Sub Account ID
    GOSUB READ.LOCK.ACCOUNT.STATEMENT

    IF R.ACCT.STMT<AC.STA.FQU1.LAST.BALANCE> THEN
        FQU1.LAST.BAL += R.ACCT.STMT<AC.STA.FQU1.LAST.BALANCE>
    END

* FQU2.LAST.BAL is multi value set so loop through each multi value and
* consolidate the balances separately for each multi value.
    FQU2.COUNT = DCOUNT(R.ACCT.STMT<AC.STA.FQU2.LAST.BAL>, VM)
    FOR FQU2 = 1 TO FQU2.COUNT
        FQU2.LAST.BAL<FQU2> += R.ACCT.STMT<AC.STA.FQU2.LAST.BAL,FQU2>
    NEXT FQU2

RETURN
*--------------------------------------------------------------------------------------------------------------
MERGE.MAIN.ACCOUNT.STATEMENT:
*----------------------------
* Update the consolidated FQU1.LAST.BAL and FQU2.LAST.BAL with Master Accounts Account Statement Record.

    ACCT.STMT.ID = ACCOUNT.KEY ;* Master Account ID
    GOSUB READ.LOCK.ACCOUNT.STATEMENT

    IF FQU1.LAST.BAL THEN
        R.ACCT.STMT<AC.STA.FQU1.LAST.BALANCE> += FQU1.LAST.BAL ;* Update it with existing Master Account balance
    END

* Since the FQU2.LAST.BAL is multi value, merge the consolidated balance with master account in corresponding
* Multi value field.
    FQU2.COUNT = DCOUNT(R.ACCT.STMT<AC.STA.FQU2.LAST.BAL>, VM)
    FOR FQU2 = 1 TO FQU2.COUNT
        R.ACCT.STMT<AC.STA.FQU2.LAST.BAL,FQU2> += FQU2.LAST.BAL<FQU2>
    NEXT FQU2

    CALL F.WRITE("F.ACCOUNT.STATEMENT", ACCT.STMT.ID, R.ACCT.STMT)

RETURN
*--------------------------------------------------------------------------------------------------------------
READ.LOCK.ACCOUNT.STATEMENT:
*----------------------
* Read the Account statement record of the Account ID passed in ACCT.STMT.ID.

    R.ACCT.STMT = ""
    F.ACCT.STMT = ""
    Y.ERR = ""
    CALL F.READU("F.ACCOUNT.STATEMENT", ACCT.STMT.ID, R.ACCT.STMT, F.ACCT.STMT, Y.ERR, '')

RETURN
*--------------------------------------------------------------------------------------------------------------
LOG.EXCEPTION:
*=============
*
    CALL EXCEPTION.LOG("", "AC", "ACCOUNT", "ACCOUNT", "", "", "CONV.SUB.ACCOUNT", EXCEPT.ID, "", EXCEPT.MSG, "")
*
RETURN
*--------------------------------------------------------------------------------------------------------------
DELETE.FILES:
*============
* Delete customer related CONCAT.FILES
* For internal accounts delete from CATEG.INT.ACCT
* Passed id contains CUST.NO*INT.ACCT.CATEG*ACCOUNT.LIST(Seperated by /)
* Where ACCOUNT.LIST is ACCT.ID#ACCT.CCY#ACCT.CCY.MKT

    YACCT.CUST = ''
    YACCT.CCY = ''
    YACCT.CCY.MKT = ''
    YACCT.CATEG = ''
    ACCOUNT.LIST = ''
    CUST.ACCT.READ = 0        ;* Initialised the variable
    CUST.ACCT.CCY.READ = 0    ;* Initialised the variable

    YACCT.CUST = ACCOUNT.KEY['*',2,1]
    YACCT.CATEG = ACCOUNT.KEY['*',3,1]
    ACCOUNT.LIST = ACCOUNT.KEY['*',4,1]
    CONVERT '/' TO @FM IN ACCOUNT.LIST

* In order to avoid numerous io lock the cusomer related file and update the record
* after removing all the closed accounts by looping ACCOUNT.LIST
    IF NOT(YACCT.CATEG) THEN
        GOSUB READ.LOCK.CUST.ACCT
        GOSUB READ.LOCK.CUST.CCY
    END

    LOOP
        REMOVE YID.ACCT FROM ACCOUNT.LIST SETTING ACCT.POS
    WHILE YID.ACCT:ACCT.POS

* YID.ACCT is in the form ACCT.ID#ACCT.CCY#ACCT.CCY.MKT
* Get the CCY and CCY MKT
        YACCT.CCY = YID.ACCT['#',2,1]
        YACCT.CCY.MKT = YID.ACCT['#',3,1]
        YID.ACCT = YID.ACCT['#',1,1]

* Only for internal accounts YACCT.CATEG is updated
* Remove internal account number from CATEG.INT.ACCT and return
        IF YACCT.CATEG THEN
            GOSUB DEL.CATEG.INT.ACCT
            CONTINUE          ;* Process the next account.
        END

        GOSUB DELETE.CUSTOMER.ACCT      ;*
        GOSUB DELETE.CUST.CCY.ACCT      ;*
        GOSUB DELETE.CUST.ACCT.CCY.REC  ;*
    REPEAT

* Update CUSTOMER.ACCOUNT file after removing closed account references
    IF CUST.ACCT.READ THEN
        GOSUB UPDATE.CUST.ACCT
    END

    IF CUST.ACCT.CCY.READ THEN
        GOSUB UPDATE.CUST.ACCT
    END

RETURN
*--------------------------------------------------------------------------------------------------------------
DEL.CATEG.INT.ACCT:
*==================
* Categ int acct is not updated for sub accounts from R08 release
* So to avoid locking read the file and check whether account present in the record
* and then process

    YDEL.ID = YID.ACCT
    YREC = ''
    CALL F.READ('F.CATEG.INT.ACCT', YACCT.CATEG, YREC ,F.CATEG.INT.ACCT, '')
    LOCATE YDEL.ID IN YREC<1> SETTING YLOC THEN   ;* Account id is located in record
        CALL F.READU('F.CATEG.INT.ACCT',YACCT.CATEG, YREC ,F.CATEG.INT.ACCT, YER, YRETRY)
        DEL YREC<YLOC,0,0>    ;* Remove the acct id from the file
        GOSUB UPDATE.CATEG.INT.ACCT
    END

RETURN
*--------------------------------------------------------------------------------------------------------------
UPDATE.CATEG.INT.ACCT:
*=====================

    IF YREC = "" THEN         ;* There is no account in the record delete the record
        CALL F.DELETE('F.CATEG.INT.ACCT', YACCT.CATEG)
    END ELSE
        CALL F.WRITE('F.CATEG.INT.ACCT',YACCT.CATEG, YREC )
    END

RETURN
*--------------------------------------------------------------------------------------------------------------
LOCATE.AND.DELETE.REC:
*=====================
* This para will locate and delete the account id from the passed record

    LOCATE YDEL.ID IN YREC<1> SETTING YLOC THEN
        DEL YREC<YLOC,0,0>
    END ELSE
        YLOC = ''
    END

RETURN

*--------------------------------------------------------------------------------------------------------------
READ.LOCK.CUST.ACCT:
*====================

    R.CUST.ACCT = ''
* This flag variable is used to check whether update has to be done
* Since in update if the record is NULL it  will be deleted, but there may be case
* where the record might have updated in any other session since we have not locked
    CUST.ACCT.READ = 1        ;* Flag to indicate CUSTOMER.ACCOUNT is exist

    CALL F.READU('F.CUSTOMER.ACCOUNT', YACCT.CUST, R.CUST.ACCT, F.CUSTOMER.ACCOUNT, '','')
    IF R.CUST.ACCT EQ '' THEN
        CALL F.RELEASE('F.CUSTOMER.ACCOUNT', YACCT.CUST, F.CUSTOMER.ACCOUNT)
        CUST.ACCT.READ = 0
    END

RETURN
*--------------------------------------------------------------------------------------------------------------
READ.LOCK.CUST.CCY:
*====================

    R.CUST.ACCT.CCY.REC = ''
    CUST.ACCT.CCY.READ = 1
    CALL F.READU( 'F.CUST.ACCT.CCY.REC',YACCT.CUST, R.CUST.ACCT.CCY.REC , F.CUST.ACCT.CCY.REC, ER,'')
    IF R.CUST.ACCT EQ '' THEN
        CALL F.RELEASE('F.CUST.ACCT.CCY.REC', YACCT.CUST, F.CUST.ACCT.CCY.REC)
        CUST.ACCT.CCY.READ = 0
    END

RETURN
*--------------------------------------------------------------------------------------------------------------
UPDATE.CUST.ACCT:
*=================

    IF R.CUST.ACCT = "" THEN
        CALL F.DELETE('F.CUSTOMER.ACCOUNT', YACCT.CUST)
    END ELSE
        CALL F.WRITE('F.CUSTOMER.ACCOUNT',YACCT.CUST, R.CUST.ACCT)
    END

RETURN
*--------------------------------------------------------------------------------------------------------------
UPDATE.CUST.CCY:
*=================

    IF R.CUST.ACCT.CCY.REC = '' THEN
        CALL F.DELETE('F.CUST.ACCT.CCY.REC', YACCT.CUST)
    END ELSE
        CALL F.WRITE('F.CUST.ACCT.CCY.REC',YACCT.CUST,  R.CUST.ACCT.CCY.REC)

    END

RETURN
*--------------------------------------------------------------------------------------------------------------
DELETE.CUSTOMER.ACCT:
*=====================

    YDEL.ID = YID.ACCT
    YREC = ""
    IF R.CUST.ACCT THEN
        YREC = R.CUST.ACCT    ;* Pass REC as customer account so account id is removed
        GOSUB LOCATE.AND.DELETE.REC
        R.CUST.ACCT = YREC
    END

RETURN
*-----------------------------------------------------------------------------
DELETE.CUST.CCY.ACCT:
*=====================

    YREC.ID = YACCT.CUST:YACCT.CCY:YACCT.CCY.MKT
    YDEL.ID = YID.ACCT
    CALL F.READU('F.CUSTOMER.CCY.ACCT', YREC.ID, YREC ,F.CUSTOMER.CCY.ACCT, '','')
    IF YREC <> "" THEN
        GOSUB LOCATE.AND.DELETE.REC
        IF YREC = "" THEN
            CALL F.DELETE('F.CUSTOMER.CCY.ACCT', YREC.ID)
        END ELSE
            CALL F.WRITE('F.CUSTOMER.CCY.ACCT',YREC.ID, YREC)
        END
    END ELSE
        CALL F.RELEASE('F.CUSTOMER.CCY.ACCT', YREC.ID,F.CUSTOMER.CCY.ACCT)
    END

RETURN
*-----------------------------------------------------------------------------
DELETE.CUST.ACCT.CCY.REC:
*========================
* Read the CUST.ACCT.CCY.REC record. Get the account that is closed.
* Delete the entry that is there for that customer.

    LOOP
        CUST.ACCT.CCY.ACCTS = R.CUST.ACCT.CCY.REC<CUS.ACR.RECEIVE.ACCOUNT>
        LOCATE YID.ACCT IN CUST.ACCT.CCY.ACCTS<1,1> SETTING POS ELSE
            POS = ''
        END
    WHILE POS NE ''
        DEL R.CUST.ACCT.CCY.REC<1,POS>
        DEL R.CUST.ACCT.CCY.REC<2,POS>
    REPEAT

RETURN
*-----------------------------------------------------------------------------
CHECK.ACCOUNT.TYPE:
*-----------------
*
    INTERCO = ''
    GOSUB READ.ACCOUNT
    AC.AUTO.ID = R.ACCOUNT.RECORD<AC.CATEGORY>
    LOCATE AC.AUTO.ID IN R.COMPANY(EB.COM.INTER.COM.CATEGORY)<1,1> SETTING POS THEN
        INTERCO = 'YES'
    END ELSE
        ER = ''
        AUTO.REC = ''
        CALL CACHE.READ("F.AC.AUTO.ACCOUNT",AC.AUTO.ID,AUTO.REC,ER)
    END
*
    SHARED.CONSOL.KEY = 'YES'
    BEGIN CASE
        CASE INTERCO EQ 'YES'
            SHARED.CONSOL.KEY = 'NO'        ;* For Interco INT.ACC.TYPE is always hard coded as CATEG in AC.SUB.ACCOUNT.DISTRIBUTE
        CASE AUTO.REC<AC.AUT.INT.ACC.TYPE> EQ 'CATEG'
            SHARED.CONSOL.KEY = 'NO'
    END CASE
*
RETURN
*-----------------------------------------------------------------------------
READ.ACCOUNT:
*-------------
* Read the account record
    CALL F.READ(FN.ACCOUNT.RECORD,ACCOUNT.KEY,R.ACCOUNT.RECORD,FV.ACCOUNT.RECORD,YERR)
*
RETURN
*
*-----------------------------------------------------------------------------
END
