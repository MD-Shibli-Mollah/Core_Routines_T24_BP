* @ValidationCode : MjotNzI5MTcxMDQ2OkNwMTI1MjoxNTgwODE1NDA1MDU1OmxvZ2FuYXRoYW5nOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDIuMjAyMDAxMTctMjAyNjoxNTM6MTIy
* @ValidationInfo : Timestamp         : 04 Feb 2020 16:53:25
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : loganathang
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 122/153 (79.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-129</Rating>
*-----------------------------------------------------------------------------
!
! This routine is purely a sales demo routine and only to illustrate the workflow
! of what will happen when there is a blacklist violation during customer onboarding
! or transaction processing
!
*-----------------------------------------------------------------------------
! Modification History
!
! 29 OCT 2010 - Arjun V
!               New Development for SI RMB1, to demonstrate Black list checking
!
! 25 JUN 2018 - DEF 2644716/ TASK 2639116
!               POSTING.RESTRICT field to be reinitialised based on black listed/non black listed customer
!
! 19 JUL 2019 - Enhancement 2822523/Task 2990408
!               Componentization - PW.ModelBank
*
* 04/02/20 - Defect 3569476 / Task 3569590
*            Replace F.WRITE with table writes
*-----------------------------------------------------------------------------

$PACKAGE PW.ModelBank
SUBROUTINE V.CHECK.BLACKLIST.CUST
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING OP.ModelBank
    $USING EB.TransactionControl
    $USING ST.Customer
    $USING EB.OverrideProcessing
    $USING EB.Interface

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
*-----------------------------------------------------------------------------------------
INITIALISE:
    
    ! Initialise Variables
    Y.BL.FIELDS = "FULL.NAME":@FM:"FIRST.NAME":@FM:"SHORT.NAME":@FM:"ALIAS.2":@FM:"SURNAME":@FM:"ALIAS.1":@FM:"ALIAS.3"
    CUST.ID = EB.SystemTables.getIdNew()
    Y.FLD.COUNT = DCOUNT(Y.BL.FIELDS,@FM)

    ! File Pointers
    FN.CUSTOMER = 'F.CUSTOMER' ;  FV.CUSTOMER = ''
    FN.BLACKLIST.CUSTOMER = 'F.EB.BLACKLIST.CUSTOMER' ;  FV.BLACKLIST.CUSTOMER = ''
    EB.DataAccess.Opf(FN.BLACKLIST.CUSTOMER,FV.BLACKLIST.CUSTOMER)
    FN.BLACKLIST.REPORT = 'F.EB.BLACKLIST.REPORT' ; FV.BLACKLIST.REPORT = ''
    TOTAL.MULTI.SET ='' ;* Variable to count the Multivalue set POSTING.RESTRICT
    DOB.OF.CUS=''       ;* Variable to store the Birth date of customer
    STATUS.BL=''        ;* Variable to set the status of Black listed customer
RETURN
*-----------------------------------------------------------------------------------------
PROCESS:
   
    SEL.CMD= 'SELECT ':FN.BLACKLIST.CUSTOMER
    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,'',NO.OF.SEL,RET.CODE)
    
    LOOP
        REMOVE BL.ID FROM SEL.LIST SETTING BL.POS
    WHILE BL.ID:BL.POS AND STATUS.BL EQ '' DO
    
        GOSUB INITIALISE.THIS.R.BL.REP
        EB.DataAccess.FRead(FN.BLACKLIST.CUSTOMER,BL.ID,R.BL,FV.BLACKLIST.CUSTOMER,RD.ERR)
       
        GOSUB FETCH.CUSTOMER.DATA.FROM.R.NEW
        IF DOB.OF.CUS NE '' THEN
            IF DOB.OF.CUS EQ R.BL<OP.ModelBank.EbBlacklistCustomer.EbBlaThrFouDateOfBirth> THEN
                R.BL.REP<OP.ModelBank.EbBlacklistReport.EbBlaTwoOneDateOfBirth>= R.BL<OP.ModelBank.EbBlacklistCustomer.EbBlaThrFouDateOfBirth>
            END
        END

        GOSUB TEST.AGAINST.THIS.BLACKLIST

        GOSUB GET.NEXT.ID.FOR.BLACKLIST.REPORT         
        PW.ModelBank.WriteOpBlacklistReport("OP.ModelBank.OpBlacklistReportWrite", ID.BL.REP, R.BL.REP)
        
        VIO.STATUS=R.BL.REP<OP.ModelBank.EbBlacklistReport.EbBlaTwoOneViolation> ;* Variable initialised to store the value of field VIOLATION
        ! Set Posting Restriction if there is a Violation
        TOTAL.MULTI.SET = DCOUNT(EB.SystemTables.getRNew(ST.Customer.Customer.EbCusPostingRestrict),@VM) ;* variable to store the count of number of MV's in CUSTOMER, POSTING.RESTRICT field
        IF VIO.STATUS EQ "YES" THEN
            EB.SystemTables.setRNew(ST.Customer.Customer.EbCusPostingRestrict,"1") ;* Set value to 1 when CUSTOMER find to be black listed
        END ELSE
            FOR MV = 1 TO TOTAL.MULTI.SET
                
                IF EB.SystemTables.getROld(ST.Customer.Customer.EbCusPostingRestrict)<1,MV> EQ '1' AND EB.SystemTables.getRNew(ST.Customer.Customer.EbCusPostingRestrict)<1,MV> NE '1' THEN
                    EB.SystemTables.setRNew(ST.Customer.Customer.EbCusPostingRestrict,EB.SystemTables.getROld(ST.Customer.Customer.EbCusPostingRestrict)<1,MV>) ;* Black listed customer when modified the older value in POSTING.RESTRICT to be retained
                END
                IF EB.SystemTables.getROld(ST.Customer.Customer.EbCusPostingRestrict)<1,MV> NE '1' AND EB.SystemTables.getRNew(ST.Customer.Customer.EbCusPostingRestrict)<1,MV> EQ '1' THEN
                    EB.SystemTables.setRNew(ST.Customer.Customer.EbCusPostingRestrict,EB.SystemTables.getROld(ST.Customer.Customer.EbCusPostingRestrict)<1,MV>) ;* Modified to black listed customer hence POSTING.RESTRICT to be over written with 1
                END
            NEXT MV
        END
    REPEAT   
  
RETURN
*-----------------------------------------------------------------------------------------
INITIALISE.THIS.R.BL.REP:

    R.BL.REP = ''
    R.BL.REP<OP.ModelBank.EbBlacklistReport.EbBlaTwoOneCustomerId> = CUST.ID
    R.BL.REP<OP.ModelBank.EbBlacklistReport.EbBlaTwoOneReferenceNumber> = BL.ID
    R.BL.REP<OP.ModelBank.EbBlacklistReport.EbBlaTwoOneDateIdentified> = EB.SystemTables.getToday()
    R.BL.REP<OP.ModelBank.EbBlacklistReport.EbBlaTwoOneTimeIdentified> = OCONV(TIME(),'MTS')
    ! Set this to NO by default. Will be overwritten in RAISE.VIOLATION.OVERIDE Gosub
    R.BL.REP<OP.ModelBank.EbBlacklistReport.EbBlaTwoOneViolation> = 'NO'

RETURN
*-----------------------------------------------------------------------------------------
FETCH.CUSTOMER.DATA.FROM.R.NEW:
    SHORT.NAME = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusShortName)
    NAME1 = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusNameOne)
    NAME2 = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusNameTwo)
    GIV.NAME=EB.SystemTables.getRNew(ST.Customer.Customer.EbCusGivenNames)
    FAM.NAME = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusFamilyName)
    PREV.NAME = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusPreviousName)
    DOB.OF.CUS = EB.SystemTables.getRNew(ST.Customer.Customer.EbCusDateOfBirth)

RETURN
*-----------------------------------------------------------------------------------------
TEST.AGAINST.THIS.BLACKLIST:
    
    BLACKLIST.NAME = R.BL<OP.ModelBank.EbBlacklistCustomer.EbBlaThrFouBlacklistName>

    !Short Name
    FINDSTR SHORT.NAME IN R.BL SETTING REP.POS THEN
        R.BL.REP<OP.ModelBank.EbBlacklistReport.EbBlaTwoOneMatchShortname> = SHORT.NAME
        BLACKLIST.FIELD = 'SHORT.NAME'
        BLACKLIST.VALUE = SHORT.NAME
        GOSUB RAISE.VIOLATION.OVERRIDE
    END
    ! Name.1
    FINDSTR NAME1 IN R.BL SETTING REP.POS1 THEN
        R.BL.REP<OP.ModelBank.EbBlacklistReport.EbBlaTwoOneMatchFirstname> = NAME1
        BLACKLIST.FIELD = 'NAME.1'
        BLACKLIST.VALUE = NAME1
        GOSUB RAISE.VIOLATION.OVERRIDE
    END
    ! Name.2
    FINDSTR NAME2 IN R.BL SETTING REP.POS2 THEN
        R.BL.REP<OP.ModelBank.EbBlacklistReport.EbBlaTwoOneMatchSurname> = NAME2
        BLACKLIST.FIELD = 'NAME.2'
        BLACKLIST.VALUE = NAME2
        GOSUB RAISE.VIOLATION.OVERRIDE
    END
    ! Given Names
    FINDSTR GIV.NAME IN R.BL SETTING REP.POS3 THEN
        R.BL.REP<OP.ModelBank.EbBlacklistReport.EbBlaTwoOneMatchAliasOne> = GIV.NAME
        BLACKLIST.FIELD = 'GIVEN.NAMES'
        BLACKLIST.VALUE = GIV.NAME
        GOSUB RAISE.VIOLATION.OVERRIDE
    END
    ! Family Name
    FINDSTR FAM.NAME IN R.BL SETTING REP.POS4 THEN
        R.BL.REP<OP.ModelBank.EbBlacklistReport.EbBlaTwoOneMatchAliasTwo> = FAM.NAME
        BLACKLIST.FIELD = 'FAMILY.NAME'
        BLACKLIST.VALUE = FAM.NAME
        GOSUB RAISE.VIOLATION.OVERRIDE
    END
    ! Previous Name
    FINDSTR PREV.NAME IN R.BL SETTING REP.POS5 THEN
        R.BL.REP<OP.ModelBank.EbBlacklistReport.EbBlaTwoOneMatchAliasTwo> = PREV.NAME
        BLACKLIST.FIELD = 'PREVIOUS.NAME'
        BLACKLIST.VALUE = PREV.NAME
        GOSUB RAISE.VIOLATION.OVERRIDE
    END

RETURN
*-----------------------------------------------------------------------------------------
RAISE.VIOLATION.OVERRIDE:

    tmp = 'RMB1.CU.BLACKLIST.VIOLATION'
    tmp<2,1> = BLACKLIST.FIELD
    tmp<2,2> = BLACKLIST.VALUE
    tmp<2,3> = BLACKLIST.NAME
    EB.SystemTables.setText(tmp)
    EB.OverrideProcessing.StoreOverride(1)
    STATUS.BL=1 ;* Variable set to 1 to indicate VIOLATION field is set to YES
    R.BL.REP<OP.ModelBank.EbBlacklistReport.EbBlaTwoOneViolation> = 'YES'

RETURN
*-----------------------------------------------------------------------------------------
GET.NEXT.ID.FOR.BLACKLIST.REPORT:

    GOSUB SAVE.COMMON
    GOSUB SET.COMMON
    GOSUB GET.NEXT.ID
    GOSUB RESTORE.COMMON

RETURN
*-----------------------------------------------------------------------------------------
SAVE.COMMON:

    SAVE.APPLICATION = EB.SystemTables.getApplication()
    SAVE.FUNCTION = EB.SystemTables.getVFunction()
    SAVE.FULL.FNAME = EB.SystemTables.getFullFname()
    SAVE.PGM.TYPE = EB.SystemTables.getPgmType()
    SAVE.ID.T = EB.SystemTables.getIdT()
    SAVE.ID.N = EB.SystemTables.getIdN()
    SAVE.RUB = EB.SystemTables.getRunningUnderBatch()
    SAVE.ID.NEW = EB.SystemTables.getIdNew()
    SAVE.COMI = EB.SystemTables.getComi()

RETURN
*-----------------------------------------------------------------------------------------
SET.COMMON:

    EB.SystemTables.setApplication('EB.BLACKLIST.REPORT')
    EB.SystemTables.setVFunction('I')
    FN.BL.REP = 'F.':EB.SystemTables.getApplication() ; F.BL.REP = '' ; EB.DataAccess.Opf(FN.BL.REP,F.BL.REP)
    EB.SystemTables.setFullFname(FN.BL.REP)
    EB.SystemTables.setPgmType('.IDA')
    EB.SystemTables.setIdT('A')
    EB.SystemTables.setIdN('35')
    EB.SystemTables.setRunningUnderBatch(1) ;* UNIQUE.CONTRACT.ID does a Stupid thing... calls JOURNAL.UPDATE. Suppress it
    EB.SystemTables.setIdNew('')
    EB.SystemTables.setComi('')

RETURN
*-------------------------------------------------------------------------------------------
GET.NEXT.ID:
    EB.TransactionControl.GetNextId('', 'F')
    EB.SystemTables.setIdNew(EB.SystemTables.getComi())
    EB.TransactionControl.FormatId('AMLBL')
    IF EB.SystemTables.getE() THEN
        ERR.MSG = EB.SystemTables.getE()
    END ELSE
        ID.BL.REP = EB.SystemTables.getIdNew()
    END

RETURN
*-------------------------------------------------------------------------------------------
RESTORE.COMMON:
    EB.SystemTables.setApplication(SAVE.APPLICATION)
    EB.SystemTables.setVFunction(SAVE.FUNCTION)
    EB.SystemTables.setFullFname(SAVE.FULL.FNAME)
    EB.SystemTables.setPgmType(SAVE.PGM.TYPE)
    EB.SystemTables.setIdT(SAVE.ID.T)
    EB.SystemTables.setIdN(SAVE.ID.N)
    EB.SystemTables.setRunningUnderBatch(SAVE.RUB)
    EB.SystemTables.setIdNew(SAVE.ID.NEW)
    EB.SystemTables.setComi(SAVE.COMI)

RETURN
*------------------------------------------------------------------------------------------
END
