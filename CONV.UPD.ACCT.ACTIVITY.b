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

* Version 3 02/06/00  GLOBUS Release No. G11.0.00 29/06/00
*-----------------------------------------------------------------------------
* <Rating>-135</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.BalanceUpdates
    SUBROUTINE CONV.UPD.ACCT.ACTIVITY(ACCOUNT.ID,R.AC.CONV.ENTRY)
*-----------------------------------------------------------------------------
* Program Description
*
*     The update of ACCT.ACTIVITY (and others AC.VIOLATION etc) are now done
*     online. Any transactions raised during the day before the upgrading to
*     G15.2 would not have updated ACCT.ACTIVIY.
*-----------------------------------------------------------------------------
* Modification History :
*
* 06/01/05 - EN_10002375
*            New routine
*
* 18/03/05 - BG_100008393
*            Ignore entires starting with 'F'
*
* 12/06/06 - CI_10041770 / CI_10041784
*            Call EB.UPD.ENTRY.XREF.WORK to update RE.STMT.ENT.KEY.WORK
*
* 09/01/07 - BG_100012729
*            Changes done to update CONSOL.KEY and OPEN.ASSET.TYPE directly
*            here instead of calling the core routine AC.CONTRACT.BALANCES.UPDATE
*            which has lot of changes in latest release and shouldn't be called
*            for conversion.
*
* 11/02/08 - BG_100017067/ Ref: TTS0800384
*            Do load company before calling RE.INIT.CON for forming consol.key if
*            account company is different from ID.COMPANY.
*
* 17/11/08 - BG_100020887
*            Variable intialization error during cob after upgrading from R05.011.
*
* 12/12/08 - BG_100021277
*            F.READ, F.WRITE, F.DELETE and F.RELEASE are changed to READ, WRITE,
*            DELETE and RELEASE respectively.
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.STMT.ENTRY
    $INSERT I_RE.INIT.COMMON
    $INSERT I_F.DATES
    $INSERT I_F.ACCOUNT
    $INSERT I_F.ACCOUNT.PARAMETER
    $INSERT I_F.RE.CONTRACT.BALANCES
    $INSERT I_F.CONSOLIDATE.COND
    $INSERT I_F.CATEG.ENTRY
    $INSERT I_F.USER
    $INSERT I_EOD.AC.CONV.ENTRY.COMMON
*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB PROCESS.RECORD

    RETURN

*---------*
INITIALISE:
*---------*


    RETURN

*-------------*
PROCESS.RECORD:
*-------------*
    LOOP
        REMOVE ENTRY.ID FROM R.AC.CONV.ENTRY SETTING SOMETHING
    WHILE ENTRY.ID : SOMETHING

        IF ENTRY.ID[1,1] = 'F' THEN
            CONTINUE          ;* Ignore entry
        END

        ENTRY.TYPE = 'S'
        GOSUB READ.STMT.ENTRY
        GOSUB DETERMINE.PROCESSING.DATE
        IF NOT(FORWARD.IND) THEN
            GOSUB UPDATE.CONTRACT.BALANCES        ;* Update the balances record
        END

        GOSUB UPDATE.ACCT.ACTIVITY      ;* For accounts only update the movements


        IF NOT(FORWARD.IND) THEN
            GOSUB UPDATE.CONSOL.WORK    ;* Update work information for CRB
        END

        IF NOT(FORWARD.IND) THEN
            GOSUB UPDATE.XREF.FILES
        END

    REPEAT

    RETURN

*--------------*
READ.STMT.ENTRY:
*--------------*

    ENTRY.REC = ''
    READ ENTRY.REC FROM F.STMT.ENTRY, ENTRY.ID ELSE
        ENTRY.REC = ""
    END

    PROCESSING.DATE = ''
    VD.SYS = ''
    ANY.VD = ''
    CONSOL.KEY = '' ;* CRF key
    ASSET.TYPE = '' ;* CRF TYPE
    FORWARD.IND = 0
    MAT.DATE = ''
*
    ENTRY.IN = ENTRY.REC
    SYSID = ''
    CALL AC.VALUE.DATED.ACCTNG(SYSID, ENTRY.IN, '', '', ANY.VD, VD.SYS)

    IF VD.SYS AND ENTRY.REC<AC.STE.VALUE.DATE> GT R.DATES(EB.DAT.PERIOD.END) AND ENTRY.REC<AC.STE.SUSPENSE.CATEGORY> THEN
        FORWARD.IND = 1
    END

    RETURN

*-------------------*
UPDATE.ACCT.ACTIVITY:
*-------------------*

** For account movements update the activity online
*
    IF ENTRY.TYPE = 'S' THEN
        CALL EB.UPDATE.ACCT.ACTIVITY(ENTRY.ID, ENTRY.REC, PROCESSING.DATE)
    END
*
    RETURN

*------------------------*
DETERMINE.PROCESSING.DATE:
*------------------------*

** For S, R, C and P check to see if we are value dated
** if so processing date becomes the Value date, if not it's
** Today
*
    BEGIN CASE
    CASE VD.SYS AND ENTRY.REC<AC.STE.VALUE.DATE> > R.DATES(EB.DAT.PERIOD.END) AND ENTRY.REC<AC.STE.SUSPENSE.CATEGORY>
        PROCESSING.DATE = ENTRY.REC<AC.STE.VALUE.DATE>
    CASE 1
        PROCESSING.DATE = TODAY
    END CASE
*
    RETURN

*-----------------------*
UPDATE.CONTRACT.BALANCES:
*-----------------------*
** Update the contract balances record with the details of the movement and
** write away
*
    R.CONTRACT.BALANCES = ''  ;* Will be returned
    CONTRACT.BAL.ID = ACCOUNT.ID
    BEGIN CASE
    CASE ENTRY.TYPE = "S"
        BALANCES.ID = CONTRACT.BAL.ID

    CASE 1
        BALANCES.ID = ''
    END CASE

    IF BALANCES.ID THEN
        GOSUB READ.RECORD
    END


    RETURN

*----------------*
UPDATE.XREF.FILES:
*----------------*

** Update the other related files to the entry (eg. ACCT.ACTIVITY, CATEG.ACTIVITY, SPEC.ENT.KEY)
** Be careful here with net entries as we will only need to update these files based on the net
** entry key so will only need to do this the once
** Since this routine updates ACCT.ACTIVITY too we also need the detailed entry record for this
*

    CALL EB.UPD.ENTRY.XREF.WORK(ENTRY.TYPE, ENTRY.ID, ENTRY.REC, PROCESSING.DATE, CONTRACT.BAL.ID, CONSOL.KEY, ASSET.TYPE, MAT.DATE)
*
    RETURN

*-----------------*
UPDATE.CONSOL.WORK:
*-----------------*

** Update CONSOL.UPDATE.WORK or PL.CONSOL.UPDATE.WORK
*
* **      CONSOL.KEY = R.CONTRACT.BALANCES<RCB.CONSOL.KEY>        ;* Use the stored key
    ASSET.TYPE.CCY = ASSET.TYPE
*
    CALL EB.UPD.CONSOL.UPDATE.WORK(ENTRY.TYPE, ENTRY.ID, ENTRY.REC, PROCESSING.DATE, CONTRACT.BAL.ID, CONSOL.KEY, ASSET.TYPE.CCY, MAT.DATE)
*
    RETURN

*----------*
READ.RECORD:
*----------*

** Read and create the RE.CONTRACT.BALANCES record if required
*
    R.ACCOUNT = ''
    UPDATE.ACCOUNT = 0
    READU R.ACCOUNT FROM F.ACCOUNT, BALANCES.ID THEN
        IF R.ACCOUNT<AC.CONSOL.KEY> = '' THEN     ;* We need to build the key online
*
* Assign local file names to 'YLOCAL.FILENAMES'
*  e.g. YLOCAL.FILENAMES = 'ACCOUNT':VM:'CUSTOMER'
* and dimension required arrays and assign 'Y.MAX.DIM'

            YLOCAL.FILENAMES = "ACCOUNT"
            Y.MAX.DIM = AC.AUDIT.DATE.TIME
            YID.CON = "ASSET&LIAB"
            LOCAL7 = "ACCTACTIV"
            Y.RE.ROUTINE = "AC.CONTRACT.BALANCES.UPDATE"

*--         Load company if is different from the ID.COMPANY.
            SAVE.COMPANY = ID.COMPANY
            IF R.ACCOUNT<AC.CO.CODE> # ID.COMPANY THEN
                CALL LOAD.COMPANY(R.ACCOUNT<AC.CO.CODE>)
            END

            CALL RE.INIT.CON
            YKEY.CON = 'AC.':R.ACCOUNT<AC.CURRENCY.MARKET>:'.':R.ACCOUNT<AC.POSITION.TYPE>:'.':R.ACCOUNT<AC.CURRENCY>
            MATPARSE YR.LOCAL.FILE.1 FROM R.ACCOUNT
            Y.LOCAL.FILE.ID = BALANCES.ID
*
            $INSERT I_GOSUB.RE.KEY.GEN.CON
*
            R.ACCOUNT<AC.CONSOL.KEY> = YKEY.CON
            UPDATE.ACCOUNT = 1
            CONSOL.KEY = YKEY.CON

* Revert to original company.
            IF ID.COMPANY # SAVE.COMPANY THEN
                CALL LOAD.COMPANY(SAVE.COMPANY)
            END

        END
        CONSOL.KEY = R.ACCOUNT<AC.CONSOL.KEY>
        IF R.ACCOUNT<AC.OPEN.ASSET.TYPE> = '' THEN
*
** Need to add code here to check for contingent accounts
** By default we won't allocate the account sign for a new account until the
** end of the day. But for performance reasons we may simply want to allocate
** the type based on the sign of the official movement
** this will then get picked up as a SIGN.CHANGE during the day
*
            ASSET.TYPE = ''   ;* Used to differentiate nornal process from recreate
            CALL AC.DETERMINE.INIT.ASSET.TYPE(BALANCES.ID, R.ACCOUNT, ASSET.TYPE, ENTRY.REC<AC.STE.AMOUNT.LCY>)
            R.ACCOUNT<AC.OPEN.ASSET.TYPE> = ASSET.TYPE      ;* New field on AC to hold the type will move to contract balances
            UPDATE.ACCOUNT = 1
        END
*
        IF UPDATE.ACCOUNT THEN
            WRITE R.ACCOUNT TO F.ACCOUNT, BALANCES.ID
        END ELSE
            RELEASE F.ACCOUNT, BALANCES.ID
        END
        ASSET.TYPE = R.ACCOUNT<AC.OPEN.ASSET.TYPE>
*
    END ELSE        ;* Error we can't read the account
    END

    IF ASSET.TYPE[1,7] = 'NILOPEN' THEN
        ASSET.TYPE := "-":CONTRACT.BAL.ID
    END

    RETURN
*
*-----------------------------------------------------------------------------
FATAL.ERROR:
*
    TEXT = E ; CALL FATAL.ERROR ("AC.CONTRACT.BALANCES.UPDATE")
    RETURN
*
END
