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
* <Rating>-181</Rating>
*-----------------------------------------------------------------------------
* Version 1 GLOBUS Release No. 200608 22/06/06
*********************************************************************************
*
    $PACKAGE AC.ValueDatedProcess
    SUBROUTINE CONV.CET.ENTRY(CONSOL.REC)
*
*********************************************************************************
*  1. This routine will update the RE.CONSOL.SPEC.ENTRY and EB.CONTRACT.BALANCES records
*     for the  passed in record (CONSOL.ENT.TODAY or CONSOl.ENT.FWD)(via EB.ENNTRY.REC.UPDATE)
*  2. Raises the Self balancing entry(if required)
*  3. Raises Suspense entries for CATEG.ENT.FWD by calling CONV.CEF.ENTRY
*
*===============================================================================
*** <region name= Modifications>
* Modifications:
* ==============
* 14/06/06 - EN_10002964
*            Routine to Update EB.CONTRACT.BALANCES for MM CONTRACTS from CONSOL.ENT.TODAY
*            SAR-2006-05-17-0005 MM to update EB.CONTRACT.BALANCES
*
* 28/08/06 - BG_100011882
*            Routine modified to do the Conversion of CATEG.ENT.TODAY entries as generic processing.
*
* 08/10/06 - EN_10003043 / REF:SAR-2006-05-30-0001
*            Routine modified to do the conversion for CATEG.ENT.FWD entries and also raise
*            Self balancing entry and Suspense entries
*
* 08/11/06 - BG_100012387
*            Suspense entries not raised properly for CONSOL.ENT.FWD
*
* 10/11/06 - BG_100012413 /REF: TTS0605139
*            Entry array populated with MAT.DATE of Security master in case the Entry is
*            raised BY an SC application.
*
* 13/07/07 - BG_100014613
*            Missing Return statement in the paragraph UPDATE.FILES is fixed.
*            Also when an entry is passed to EB.ENTRY.REC.UPDATE the asset.type
*            becomes null. Therefore it is saved into SAVE.ENTRY.REC before being
*            assigned to BAL.REC so that self-balancing entries are raised properly.
*
* 13/08/06 - EN_10003355
*            SAR-2007-01-05-0003 MD to update EB.CONTRACT.BALANCES.
*            Selfbal entries for MD contracts needs change of forward dated value date
*            to TODAY.
*
* 26/07/07 - EN_10003421
*            Balancing entries should be raised only if CONT.SELF.BAL in CONSOLIDATE.COND
*            is set to Y.
*
* 13/08/07 - BG_100014862
*            CAL not updated for balancing asset types leading to mismatches,since processing.
*            date is assigned with value date instead of todayand hence treated like a value
*            dated system.
*
* 05/10/07 - EN_10003479
*            FX to update EB.CONTRACT.BALANCES
*
* 16/09/07 - EN_10003508 /REF: SAR-2007-02-08-0002
*            LC to Update EB.CONTRACT.BALANCES
*
* 05/02/08 - CI_10053574
*            Trans.journal does report differently after cob when upgraded.
*            The processing date is set as value date in eb.entry.rec.update because
*            of the check for value dated entry.
*
* 05/03/08 - CI_100017476/Ref: TTS0800857
*            The COMPANY.CODE is not updated properly from CONSOL.ENT.TODAY records to ENTRY.REC array.
*
* 01/07/08 - EN_10003684
*            DX to update EB.CONTRACT.BALANCES instead of updating CRF balance file
*            RE.CONTRACT.BALANCES
*
* 01/12/08 - CI_10059196
*            Trans.Journal and GL-difference after upgrading R05 area to R7
*            Because of difference in suspense entries raised.
*
* 09/11/12 - Defect 510819 / Task 516363
*           When a contract is reversed in lower CONSOL.ENT.TODAY is updated to raise reversal CRF entry
*           ECB will not be created for these contracts since contract details file is deleted online during reversal
*           Now if we call EB.ENTRY.REC.UPDATE to raise CRF entry system created ECB updating only reversal amount
*           This leads to mismatch between CAL and ECB balances, Changes done to call RE.UPDATE.SPEC.ENTRY only to raise
*           CRF entry without updating ECB
*
* 25/01/13 - Defect 532017 / Task 571872
*            When the conversion EOD.AC.CONV.ENTRY is run as service, immediately after upgrade from lower release
*            to convert CET details for "BL" product, it does not update the CATEGORY code in the CONSOL.KEY
*            of EB.CONTRACT.BALANCE record for the bill.
*            Update AC.STE.CONTRACT.BAL.ID in ENTRT.REC with bill.register*bill.no and pass it to EB.ENTRY.REC.UPDATE
*            
*** </region>
*<<----------------------------------------------------------------------------->>
*** <region name= Inserts>
***
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DATES
    $INSERT I_F.CONSOL.ENT.TODAY
    $INSERT I_F.STMT.ENTRY
    $INSERT I_BATCH.FILES
    $INSERT I_EOD.CONV.ECB.COMMON
    $INSERT I_F.ACCOUNT.PARAMETER
    $INSERT I_F.SECURITY.MASTER
    $INSERT I_RE.PARAMS.CON
    $INSERT I_F.STANDARD.SELECTION
    $INSERT I_F.BL.REGISTER
    
*** </region>
*<<----------------------------------------------------------------------------->>

*** <region name= Main Para>
*
    GOSUB INITIALISE

* When LETTER.OD.CREDIT is reversed RE.CONTRACT.DETAIL is deleted instantly hence 
* While upgrading ECB cannot be build so handle reversal of LC contract seperatly
* Call RE.UPDATE.SPEC.ENT instead of EB.ENTRY.REC.UPDATE so that only entry is raised 
* without updating link files.

    IF CONSOL.REC<RE.CET.TXN.CODE> EQ "REV" AND PRODUCT[1,2] = "LC" THEN
        GOSUB PROCESS.REVERSED.CONTRACTS ; *Process the Reversal entry for LC contract
    END ELSE
        GOSUB BUILD.ENTRY.REC     ;* Build the Entry in STMT.ENTRY format from CRF entry passed in.
    END
*
    RETURN

*** </region>

*<<----------------------------------------------------------------------------->>

*** <region name= INITIALISE>
INITIALISE:
***********
    ASSET.TYPE = ''
    CONT.POS = ''
    ENTRY.REC = ''
    BAL.REC = ''
    VD.ENTRY = ''
    SUSPENSE.CATEGORY = ''
    FLAG = ''

*--   Build a list of contingent types
    CONT.TYPES = ''
    CALL RE.TYPES("ALL.CB", CONT.TYPES)

*--   Build a list of contingent types
    NON.CONTIG.LIST = ""
    CALL RE.TYPES("ALL.N",NON.CONTIG.LIST)

    PRODUCT = ''
    PRODUCT = CONSOL.REC<RE.CET.PRODUCT>

    RETURN
*** </region>

*<<----------------------------------------------------------------------------->>

*** <region name= BUILD.ENTRY.REC>
BUILD.ENTRY.REC:
*** <desc> Build STMT.ENTRY format array from respective CONSOL.RECORD</desc>

    ENTRY.REC<AC.STE.COMPANY.CODE> = CONSOL.REC<RE.CET.CO.CODE>
    ENTRY.REC<AC.STE.OUR.REFERENCE> = CONSOL.REC<RE.CET.TXN.REF>
    ENTRY.REC<AC.STE.SYSTEM.ID> = CONSOL.REC<RE.CET.PRODUCT>
    ENTRY.REC<AC.STE.CURRENCY.MARKET> = CONSOL.REC<RE.CET.CURRENCY.MARKET>
    ENTRY.REC<AC.STE.CURRENCY> = CONSOL.REC<RE.CET.CURRENCY>
    ENTRY.REC<AC.STE.CRF.TYPE> =  CONSOL.REC<RE.CET.TYPE>
    ENTRY.REC<AC.STE.CRF.TXN.CODE> = CONSOL.REC<RE.CET.TXN.CODE>
    ENTRY.REC<AC.STE.SUPPRESS.POSITION> = CONSOL.REC<RE.CET.SUPPRESS.POSITION>
    ENTRY.REC<AC.STE.CRF.MAT.DATE> = CONSOL.REC<RE.CET.MAT.DATE>
    ENTRY.REC<AC.STE.CRF.PROD.CAT> = CONSOL.REC<RE.CET.PRODUCT.CATEGORY>
    ENTRY.REC<AC.STE.PRODUCT.CATEGORY> = CONSOL.REC<RE.CET.PRODUCT.CATEGORY>
    ENTRY.REC<AC.STE.CUSTOMER.ID> = CONSOL.REC<RE.CET.CUSTOMER>
    ENTRY.REC<AC.STE.EXCHANGE.RATE> = CONSOL.REC<RE.CET.EXCHANGE.RATE>
    ENTRY.REC<AC.STE.ACCOUNT.OFFICER> =  CONSOL.REC<RE.CET.ACCOUNT.OFFICER>
    ENTRY.REC<AC.STE.VALUE.DATE> = CONSOL.REC<RE.CET.VALUE.DATE>
    ENTRY.REC<AC.STE.BOOKING.DATE>    = CONSOL.REC<RE.CET.BOOKING.DATE>
    ENTRY.REC<AC.STE.POSITION.TYPE> = CONSOL.REC<RE.CET.POSITION.TYPE>
    ENTRY.REC<AC.STE.BOOKING.DATE> = CONSOL.REC<RE.CET.BOOKING.DATE>

    BEGIN CASE
        CASE CONSOL.REC<RE.CET.PRODUCT> EQ 'SC'
            GOSUB PROCESS.SC      ;* Special processing for the conversion of SC records

        CASE CONSOL.REC<RE.CET.PRODUCT> = 'FX'
            IF ENTRY.REC<AC.STE.CRF.TYPE>[3] MATCHES 'SEL':VM:'ELL' THEN
                ENTRY.REC<AC.STE.CONTRACT.BAL.ID> = ENTRY.REC<AC.STE.OUR.REFERENCE>:'.S'
            END ELSE
                ENTRY.REC<AC.STE.CONTRACT.BAL.ID> = ENTRY.REC<AC.STE.OUR.REFERENCE>:'.B'
            END

        CASE CONSOL.REC<RE.CET.PRODUCT> = 'LCC'       ;* Id of ECB for LC charges needs to be amended with Currency.
            ENTRY.REC<AC.STE.CONTRACT.BAL.ID> = ENTRY.REC<AC.STE.OUR.REFERENCE>:'-':ENTRY.REC<AC.STE.CURRENCY>

        CASE CONSOL.REC<RE.CET.PRODUCT> = 'DX'
            ID = ENTRY.REC<AC.STE.OUR.REFERENCE>
            DX.ID = FIELD(ID,".",1)
            CALL DX.GET.LATEST.TRANSACTION.ID ("",DX.ID, "", LATEST.DX.TXN.ID)
            IF LATEST.DX.TXN.ID <> '' THEN
                CNT.DX = DCOUNT(LATEST.DX.TXN.ID,FM)
                FOR I = 1 TO CNT.DX
                    TXN.ID = LATEST.DX.TXN.ID<I>
                    IF TXN.ID[".",1,2] = ID THEN
                        DX.TXN.ID = TXN.ID
                    END
                NEXT I
                ID = ID:".":ENTRY.REC<AC.STE.CURRENCY>
                ENTRY.REC<AC.STE.CONTRACT.BAL.ID> = ID:"*":DX.TXN.ID:"*":DX.ID
            END ELSE
                * For DX, if the contract is reversed on the same day, then the DX.TRANS.KEYS are deleted. So consol
                * key cannot be generated as DX.TRANSACTION.ID cannot be formed.
                FLAG = "NO"
            END
            
        CASE CONSOL.REC<RE.CET.PRODUCT> = 'BL'
	    	BL.REGISTER.ID = CONSOL.REC<RE.CET.TXN.REF>
            F.BL.REGISTER = ''
            IF BL.REGISTER.ID THEN
               R.BL.REGISTER = '' ; ERR1 = ''
               CALL F.READ('F.BL.REGISTER',BL.REGISTER.ID,R.BL.REGISTER,F.BL.REGISTER,ERR1)
               ENTRY.REC<AC.STE.CONTRACT.BAL.ID> = ENTRY.REC<AC.STE.OUR.REFERENCE>:"*":R.BL.REGISTER<BL.REG.TRANS.REFERENCE>
            END
    END CASE

    IF CONSOL.REC<RE.CET.LOCAL.DR> <> "" THEN
        ENTRY.REC<AC.STE.AMOUNT.LCY> = CONSOL.REC<RE.CET.LOCAL.DR>
    END ELSE
        ENTRY.REC<AC.STE.AMOUNT.LCY> = CONSOL.REC<RE.CET.LOCAL.CR>
    END

    IF ENTRY.REC<AC.STE.CURRENCY> NE LCCY THEN
        IF CONSOL.REC<RE.CET.FOREIGN.DR> <> "" THEN
            ENTRY.REC<AC.STE.AMOUNT.FCY> =    CONSOL.REC<RE.CET.FOREIGN.DR>
        END ELSE
            ENTRY.REC<AC.STE.AMOUNT.FCY> = CONSOL.REC<RE.CET.FOREIGN.CR>
        END
    END

    IF ENTRY.REC<AC.STE.COMPANY.CODE> = "" THEN
        ENTRY.REC<AC.STE.COMPANY.CODE> = ID.COMPANY
    END

    IF ENTRY.REC<AC.STE.BOOKING.DATE> = "" THEN
        ENTRY.REC<AC.STE.BOOKING.DATE> = TODAY
    END

    GOSUB DETERMINE.SUSPENSE.CATEGORY   ;* Find the suspense category to be included in entry rec

    IF VD.ENTRY AND ENTRY.REC<AC.STE.SYSTEM.ID>[1,2] EQ 'SC' THEN
        ENTRY.REC<AC.STE.SUSPENSE.CATEGORY> = SUSPENSE.CATEGORY
    END

    IF NOT(FLAG) THEN
        GOSUB UPDATE.FILES    ;* Update the respective files by calling respective routines
    END
*
    RETURN

*** </region>

*<<----------------------------------------------------------------------------->>

*** <region name= DETERMINE.SUSPENSE.CATEGORY>
DETERMINE.SUSPENSE.CATEGORY:
*** <desc>Find the suspense category to be included in entry rec</desc>

    VD.SYS = ''
    SYS.ID.IN = ''
    CALL AC.VALUE.DATED.ACCTNG(SYS.ID.IN, ENTRY.REC, '', '', '', VD.SYS)
    IF VD.SYS AND ENTRY.REC<AC.STE.VALUE.DATE> GT R.DATES(EB.DAT.PERIOD.END) THEN
        VD.ENTRY =1
        ENTRY.CATEGORY = ENTRY.REC<AC.STE.PRODUCT.CATEGORY>
        CATEG.POS = ""
        LOCATE ENTRY.CATEGORY IN R.ACCOUNT.PARAMETER<AC.PAR.ENTRY.CATEGORY,1> BY 'AR' SETTING CATEG.POS ELSE
            IF CATEG.POS > 1 THEN       ;* 1 = default
                CATEG.POS -= 1          ;* one prior in 'range'
            END
        END
        SUSPENSE.CATEGORY = R.ACCOUNT.PARAMETER<AC.PAR.SUS.CATEGORY,CATEG.POS>
    END

    RETURN
*** </region>

*<<----------------------------------------------------------------------------->>

*** <region name= UPDATE.FILES>
UPDATE.FILES:
*** <desc>Update the respective files by calling respective routines</desc>
*
*--   Now directly call EB.ENTRY.REC.UPDATE as changes were made to raise spec entries for those applications
*--   which have moved to EB.CONTRACT.BALANCES.
*
    GOSUB ALLOC.UNIQUE.ID
    SAVE.ENTRY.REC = ENTRY.REC
    CALL EB.ENTRY.REC.UPDATE(UNIQUE.ID, ENTRY.REC, "R")
*
*--   Now raise the Self balancing CRF entry (If Req)
    IF SELF.BALANCING.REQ[1,1] = 'Y' THEN
        GOSUB RAISE.BL.ENTRY
    END
*
* Raise Suspense entries for CONSOL.ENT.FWD entries by calling CONV.CEF.ENTRY
*
*--- Check if the entry is Noncontingent.
    ASSET.TYPE = CONSOL.REC<RE.CET.TYPE>
    NON.CONTINGENT = 0
    CALL AC.CHECK.ASSET.TYPE(ASSET.TYPE,NON.CONTIG.LIST,NON.CONTINGENT)

    IF CONTROL.LIST<1,1> = 'CONV.CEF' AND VD.ENTRY THEN
        IF NON.CONTINGENT THEN
            CALL CONV.CEF.ENTRY(ENTRY.REC,SUSPENSE.CATEGORY)
        END
    END
    RETURN
*
*** </region>
*<<----------------------------------------------------------------------------->>

*** <region name= RAISE.BL.ENTRY>
RAISE.BL.ENTRY:
*** <desc>Create the Self balancing entries</desc>

    BAL.REC = SAVE.ENTRY.REC
    ASSET.TYPE = BAL.REC<AC.STE.CRF.TYPE>:'BL'

*--   Check whether the Asset type is Contingent or not
    CALL AC.CHECK.ASSET.TYPE(ASSET.TYPE, CONT.TYPES, CONT.POS)
    IF CONT.POS THEN
        *--      Populate the SB type and negate the amount.
        BAL.REC<AC.STE.CRF.TYPE> = ASSET.TYPE
        IF BAL.REC<AC.STE.AMOUNT.FCY> THEN
            BAL.REC<AC.STE.AMOUNT.FCY> = BAL.REC<AC.STE.AMOUNT.FCY> * -1
        END
        BAL.REC<AC.STE.AMOUNT.LCY> = BAL.REC<AC.STE.AMOUNT.LCY> * -1
        BAL.REC<AC.STE.TRANSACTION.CODE> = "CSB"

        GOSUB ALLOC.UNIQUE.ID
        CALL EB.ENTRY.REC.UPDATE(UNIQUE.ID, BAL.REC, "R")

    END
*
    RETURN
*
*** </region>

*<<----------------------------------------------------------------------------->>

*** <region name= ALLOC.UNIQUE.ID>
ALLOC.UNIQUE.ID:
***
    CURRTIME = ""   ;* Used for Id update
    TDATE = DATE()  ;* Date part
    CALL ALLOCATE.UNIQUE.TIME(CURRTIME)
    UNIQUE.ID = TDATE:CURRTIME

    RETURN
*** </region>

*<<----------------------------------------------------------------------------->>

*** <region name= PROCESS.SC>
PROCESS.SC:
*** <desc>Special processing for the conversion of SC records</desc>

    STP.KEY = FIELD(CONSOL.REC<RE.CET.TXN.REF>,'*',2)
    SM.ID = FIELD(STP.KEY,'.',2)

    R.SEC.MASTER.TODAY = ''
    CALL F.READ('F.SEC.MASTER.TODAY',SM.ID,R.SEC.MASTER.TODAY,F.SEC.MASTER.TODAY,"")

    R.SECURITY.MASTER = ''
    CALL F.READ('F.SECURITY.MASTER',SM.ID,R.SECURITY.MASTER,F.SECURITY.MASTER,"")

    BEGIN CASE
        CASE R.SEC.MASTER.TODAY<1,1>
            MAT.DATE = R.SEC.MASTER.TODAY<1,1>
        CASE R.SECURITY.MASTER<SC.SCM.MATURITY.DATE>
            MAT.DATE = R.SECURITY.MASTER<SC.SCM.MATURITY.DATE>
        CASE 1
            MAT.DATE = '0'
    END CASE

    ENTRY.REC<AC.STE.CRF.MAT.DATE> = MAT.DATE
    ENTRY.REC<AC.STE.CONTRACT.BAL.ID> = STP.KEY
    IF CONSOL.REC<RE.CET.VALUE.DATE> GT TODAY AND CONTROL.LIST<1,1> EQ 'CONV.CET' THEN
        ENTRY.REC<AC.STE.VALUE.DATE> = TODAY
    END

    RETURN

*** </region>

*<<----------------------------------------------------------------------------->>
*** <region name= PROCESS.REVERSED.CONTRACTS>
PROCESS.REVERSED.CONTRACTS:
*** <desc>Process the Reversal entry </desc>

** Initialise the CRF parameters by calling RE.APPLICATIONS
** APP.ABBREV = Application abbreviation
** APP.FILES  = Associated files
** APP.CUST   = Position of Customer in record
** APP.KEY.FILE = File Holding Crf key
** APP.KEYS   = Position of Consol Key in record
** APP.LENGTH = Length of record
*
    APP.ABBREV = "COND.LOC.FILES" ; APP.RETURN = ""
    CALL RE.APPLICATIONS(APP.ABBREV, APP.RETURN)
    APP.FILES = APP.RETURN<2>
    APP.CUST = APP.RETURN<3>
    APP.KEY.FILE = APP.RETURN<4>
    APP.KEYS = APP.RETURN<5>
    APP.LENGTH = APP.RETURN<6>


** Call RE.APPLICATIONS to get a list of COMBined products
** COMB.APP.ABBREV<1> will contain a list of SPLIT applications
** COMB.APP.ABBREV<2> contains a sub valued list of valid split abbrevs
*
    COMB.APP.ABBREV = "COMB" ; COMB.RETURN = ""
    CALL RE.APPLICATIONS(COMB.APP.ABBREV, COMB.RETURN)

    PRODUCT = CONSOL.REC<RE.CET.PRODUCT>

    CONTRACT.ID = CONSOL.REC<RE.CET.TXN.REF>

* Set up MAIN.CONTRACT.ID to be used in PROCESS.APPLICATION
*
    MAIN.CONTRACT.ID = CONTRACT.ID
* If PRODUCT is more than 2 characters see if we should reduce it
* to 2 characters to find the file data such as MGP and MMR

    MAIN.APP.ABB = PRODUCT
    LOCATE PRODUCT[1,2] IN COMB.APP.ABBREV<1,1> SETTING CPOS THEN
        LOCATE PRODUCT IN COMB.APP.ABBREV<2,CPOS,1> SETTING CPOS THEN     ;* Valid sub product
            MAIN.APP.ABB = PRODUCT
            LAST.TXN = '' ;* Cleared so correct record is read
        END ELSE
            MAIN.APP.ABB = PRODUCT[1,2]
        END
    END ELSE    ;* No splits for APPLICATION
        MAIN.APP.ABB = PRODUCT[1,2]
    END
*
    LOCATE MAIN.APP.ABB IN APP.ABBREV<1> SETTING APP.POS THEN     ;*Get app params
        APPLICATION.FILE = APP.FILES<1, APP.POS>        ;* Main file
        CUST.FLD.NO = APP.CUST<1, APP.POS>    ;* Customer fld loc
        CRF.KEY.FILE = APP.KEY.FILE<1, APP.POS>         ;* Crf key file
        CRF.KEY.FLD = APP.KEYS<1, APP.POS>    ;* Crf key location
        Y.MAX.DIM = APP.LENGTH<1, APP.POS>    ;* Record length
    END ELSE
        TEXT = "INVALID PRODUCT ":PRODUCT
    END

* Open the application file and the history file and also the crf file
* if required

    CONTRACT.FILE = ""
    CONTRACT.FILE.NAME = "F.":APPLICATION.FILE
    CALL OPF(CONTRACT.FILE.NAME, CONTRACT.FILE)

    CONTRACT.FILE.HIS = ""
    CONTRACT.FILE.HIS.NAME = "F.":APPLICATION.FILE:"$HIS"
    CONTRACT.FILE.HIS.NAME<2> = "NO.FATAL.ERROR"        ;* may not be one
    CALL OPF(CONTRACT.FILE.HIS.NAME, CONTRACT.FILE.HIS)
*
    F.CRF.KEY.FILE = ""
    CRF.KEY.FILE.NAME = "F.":CRF.KEY.FILE
    CALL OPF(CRF.KEY.FILE.NAME, F.CRF.KEY.FILE)

    YID.CON = "ASSET&LIAB"
    CRF.SUFF = ""         ;* Suffix to file containing ACCOUNT BALANCES
    IF MAIN.APP.ABB MATCHES "LD":VM:"MM":VM:"MMI" THEN
        CRF.SUFF = "00"
    END


    BEGIN CASE
        CASE CONSOL.REC<RE.CET.TXN.REF>[1,2] = 'SL'
            CRF.SUFF = ".":FIELD(CONTRACT.ID, ".", 2)
            CONTRACT.ID = FIELD(CONTRACT.ID, ".", 1)
            MAIN.CONTRACT.ID = CONTRACT.ID
            GOSUB PROCESS.APPLICATION
        CASE CONSOL.REC<RE.CET.TXN.REF>[1,2] = 'SW'
            CRF.SUFF = ""     ;* don't need this for Swap
            MAIN.CONTRACT.ID = FIELD(CONTRACT.ID, ".", 1)   ;* this is the main contract id
            GOSUB PROCESS.APPLICATION
        CASE CONSOL.REC<RE.CET.TXN.REF>[1,2] = 'DX'
            CONTRACT.ID = CONTRACT.ID:'.':CONSOL.REC<RE.CET.CURRENCY>
            MAIN.CONTRACT.ID = CONTRACT.ID
            GOSUB PROCESS.APPLICATION
        CASE 1      ;* Process standard app
            GOSUB PROCESS.APPLICATION   ;* Special entries raised via CONSOL.UPDATE
    END CASE

    IF CALL.ENTRY.REC.UPDATE THEN
        GOSUB BUILD.ENTRY.REC     ;* Build the Entry in STMT.ENTRY format from CRF entry passed in.
    END ELSE
        GOSUB UPDATE.SPEC.ENT ;* Only existing contracts
    END

    RETURN
*** </region>
*-----------------------------------------------------------------------------
PROCESS.APPLICATION:
*********************

    APPL.SS.REC = ''
    CALL GET.STANDARD.SELECTION.DETS( APPLICATION.FILE, APPL.SS.REC )

* Get the LAST FIELD NUMBER (V)
    LOCATE "AUDIT.DATE.TIME" IN APPL.SS.REC<SSL.SYS.FIELD.NAME,1> SETTING MAX.POS THEN
        Y.MAX.DIM = APPL.SS.REC<SSL.SYS.FIELD.NO,MAX.POS>
    END

* Get the CONSOL.KEY FIELD NUMBER (V)
    LOCATE "CONSOL.KEY" IN APPL.SS.REC<SSL.SYS.FIELD.NAME,1> SETTING CON.POS THEN
        Y.CONSOL.KEY = APPL.SS.REC<SSL.SYS.FIELD.NO,CON.POS>
    END

    CALL.ENTRY.REC.UPDATE = 0
    R.CONTRACT.REC = ""
    YERROR = ''
    CALL F.READ(CONTRACT.FILE.NAME, MAIN.CONTRACT.ID, R.CONTRACT.REC, CONTRACT.FILE, YERROR)
    IF YERROR THEN ;* Contract is reversed
        ** Get the HISTORY record
        YERROR = "" ; HIS.ID = MAIN.CONTRACT.ID
        CALL EB.READ.HISTORY.REC(CONTRACT.FILE.HIS, HIS.ID, R.CONTRACT.REC, YERROR)
        IF YERROR THEN
            E = YERROR
            GOSUB FATAL.ERROR
        END
        IF NOT(YERROR) AND R.CONTRACT.REC<Y.MAX.DIM - 8> NE "REVE" THEN
            IF R.CONTRACT.REC<Y.MAX.DIM - 8> NE 'MAT' THEN
                E ="AC.RTN.MISS.REC":FM:CONTRACT.FILE.NAME:VM:MAIN.CONTRACT.ID
                GOSUB FATAL.ERROR
            END
        END
    END ELSE
        CALL.ENTRY.REC.UPDATE = 1
        RETURN
    END

* If the crf key file is not the application file then read the crf key
* file.
    R.CRF.REC = ""
    IF CRF.KEY.FILE EQ APPLICATION.FILE THEN
        R.CRF.REC = R.CONTRACT.REC  ;* Use the contract record
    END ELSE
        CALL F.READ(CRF.KEY.FILE.NAME, CONTRACT.ID:CRF.SUFF, R.CRF.REC, F.CRF.KEY.FILE, YERROR)
    END

    IF R.CONTRACT.REC<Y.CONSOL.KEY> THEN
        CRF.KEY = R.CONTRACT.REC<Y.CONSOL.KEY>
    END ELSE
        CRF.KEY = R.CRF.REC<CRF.KEY.FLD>
    END

    RETURN
*-----------------------------------------------------------------------------
UPDATE.SPEC.ENT:
*----------------
* We raise one special entry per CONSOL.ENT.TODAY record for AC and CP
* movements. For general applications we will raise one entry for each
* asset type and consol key by calling RE.CONSOL.UPDATE at each change
* this will alos raise the self balancing entries required

    PARAMS = ''

    PARAMS<RE.PC.CONSOL.KEY> = CRF.KEY
    PARAMS<RE.PC.CURRENCY> = CONSOL.REC<RE.CET.CURRENCY>

* Suppose Consol.ent.today record's TYPE itself is having CCY.MKT, then no need of adding currency market here.

    IF NOT(FIELD(CONSOL.REC<RE.CET.TYPE>,'.',2)) THEN
        PARAMS<RE.PC.TYPE.MKT> = CONSOL.REC<RE.CET.TYPE>:'.':CONSOL.REC<RE.CET.CURRENCY.MARKET>
    END ELSE
        PARAMS<RE.PC.TYPE.MKT> = CONSOL.REC<RE.CET.TYPE>
    END

    PARAMS<RE.PC.SPEC.TXN.CODE> = CONSOL.REC<RE.CET.TXN.CODE>
    PARAMS<RE.PC.VALUE.DATE> = CONSOL.REC<RE.CET.VALUE.DATE>
    PARAMS<RE.PC.ACCOUNT.OFFICER> = CONSOL.REC<RE.CET.ACCOUNT.OFFICER>

    IF PARAMS<RE.PC.CURRENCY> EQ LCCY THEN
        PARAMS<RE.PC.AMOUNT.DR> = CONSOL.REC<RE.CET.LOCAL.DR>
        PARAMS<RE.PC.AMOUNT.CR> = CONSOL.REC<RE.CET.LOCAL.CR>
    END ELSE
        PARAMS<RE.PC.AMOUNT.DR> = CONSOL.REC<RE.CET.FOREIGN.DR>
        PARAMS<RE.PC.AMOUNT.CR> = CONSOL.REC<RE.CET.FOREIGN.CR>
        PARAMS<RE.PC.LOC.AMOUNT.DR> = CONSOL.REC<RE.CET.LOCAL.DR>
        PARAMS<RE.PC.LOC.AMOUNT.CR> = CONSOL.REC<RE.CET.LOCAL.CR>
    END

    PARAMS<RE.PC.REMOVE.CONTRACT> = CONSOL.REC<RE.CET.TXN.REF>
    PARAMS<RE.PC.CUSTOMER> = CONSOL.REC<RE.CET.CUSTOMER>
    PARAMS<RE.PC.CATEGORY> = CONSOL.REC<RE.CET.PRODUCT.CATEGORY>

* Calculate the exchange rate if required

    IF PARAMS<RE.PC.CURRENCY> NE LCCY THEN
        LOC.EQUIV = ""
        IF PARAMS<RE.PC.AMOUNT.CR> THEN
            FOR.AMT = PARAMS<RE.PC.AMOUNT.CR>
            LOC.EQUIV = PARAMS<RE.PC.LOC.AMOUNT.CR>
        END ELSE
            FOR.AMT = PARAMS<RE.PC.AMOUNT.DR>
            LOC.EQUIV = PARAMS<RE.PC.LOC.AMOUNT.DR>
        END
        IF CONSOL.REC<RE.CET.EXCHANGE.RATE> = "" THEN
            EXCH.RATE = ""
            CALL CALC.ERATE.LOCAL(LOC.EQUIV, PARAMS<RE.PC.CURRENCY>, FOR.AMT, EXCH.RATE)
            PARAMS<RE.PC.EXCH.RATE> = EXCH.RATE
        END ELSE
            PARAMS<RE.PC.EXCH.RATE> = CONSOL.REC<RE.CET.EXCHANGE.RATE>
        END
    END

    IF CRF.KEY THEN
        CONSOL.TYPE = CONSOL.REC<RE.CET.TYPE>
        GOSUB RAISE.SPEC.ENT

        * update the work file for the CRF.KEY
        ASSET.TYPE.CCY =  CONSOL.REC<RE.CET.TYPE>
        GOSUB BUILD.CRF

        IF SELF.BALANCING.REQ[1,1] = 'Y' THEN
            GOSUB RAISE.SELF.BL.ENTRY
        END
    END


    RETURN

*-------------------------------------------------------------------------
RAISE.SPEC.ENT:
*--------------

    CONSOL.TYPE<2> = 1    ;* Set a flag not to udpate CONSOL.UPDATE.WORK again
    CONSOL.TODAY.ID = ''   ;* Pass CET id as NULL so entry id is newly generated
    CONSOL.TODAY.ID<2> = 1;* Return CSE entry
    CALL RE.UPDATE.SPEC.ENT(PARAMS, CONSOL.TYPE, CONSOL.TODAY.ID)
    R.CSE.ENTRY = RAISE(CONSOL.TODAY.ID<2>)
    ENTRY.ID = CONSOL.TODAY.ID<1>

    RETURN

*-----------------------------------------------------------------------------
BUILD.CRF:
*---------

* Now the work file is updated with data from PARAM and not CONSOL.ENT.TODAY
* Update CRF work file for P&L and A&L entries for accounts

    ENTRY.TYPE='R'
    PROCESSING.DATE = TODAY
    CONSOL.KEY = CRF.KEY
    CONTRACT.BAL.ID = CONTRACT.ID
    MAT.DATE = CONSOL.REC<RE.CET.MAT.DATE>

    CALL EB.UPD.CONSOL.UPDATE.WORK(ENTRY.TYPE, ENTRY.ID, R.CSE.ENTRY, PROCESSING.DATE, CONTRACT.BAL.ID, CONSOL.KEY, ASSET.TYPE.CCY, MAT.DATE)

    RETURN

*----------------------------------------------------------------------------
RAISE.SELF.BL.ENTRY:
*-------------------
* Raise self balancing entry for contingent types.

    CONSOL.TYPE := "BL"        ;* Asset type for self bal

    CALL AC.CHECK.ASSET.TYPE(CONSOL.TYPE, CONT.TYPES, CONT.POS)
    IF CONT.POS THEN

        SBPARAMS = PARAMS
        SBPARAMS<RE.PC.TYPE.MKT> = CONSOL.TYPE:'.':CONSOL.REC<RE.CET.CURRENCY.MARKET>
        CONSOL.TODAY.ID = ""        ;* Consol.ent.today key. set to null

        SBPARAMS<RE.PC.AMOUNT.DR> = - PARAMS<RE.PC.AMOUNT.CR>
        IF SBPARAMS<RE.PC.AMOUNT.DR> THEN
            SBPARAMS<RE.PC.SCHEDULE.AMT> = SBPARAMS<RE.PC.AMOUNT.DR>
        END
        SBPARAMS<RE.PC.AMOUNT.CR> = - PARAMS<RE.PC.AMOUNT.DR>
        IF SBPARAMS<RE.PC.AMOUNT.CR> THEN
            SBPARAMS<RE.PC.SCHEDULE.AMT> = SBPARAMS<RE.PC.AMOUNT.CR>
        END
        SBPARAMS<RE.PC.LOC.AMOUNT.DR> = - PARAMS<RE.PC.LOC.AMOUNT.CR>
        SBPARAMS<RE.PC.LOC.AMOUNT.CR> = - PARAMS<RE.PC.LOC.AMOUNT.DR>

        PARAMS = SBPARAMS
        GOSUB RAISE.SPEC.ENT
        ASSET.TYPE.CCY =  CONSOL.TYPE
        GOSUB BUILD.CRF
    END

    RETURN
*----------------------------------------------------------------------------
FATAL.ERROR:

    TEXT = E
    CALL FATAL.ERROR('EOD.CONSOL.UPDATE')
    RETURN

*-------------------------------------------------------------------------

    END
