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
* <Rating>-78</Rating>
*-----------------------------------------------------------------------------
* Version n dd/mm/yy  GLOBUS Release No. 200508 30/06/05
*
    $PACKAGE IC.InterestAndCapitalisation
    SUBROUTINE CONV.ACCT.BACK.VALUE.G16
*-----------------------------------------------------------------------------
* Template file routine, to be used as a basis for building a FILE.ROUTINE
* to be run as part of the CONVERSION.DETAILS record.
* This routine should only be used to do such things as change record keys etc
* where ever possible use the RECORD.ROUTINE to convert/populate record data fields.
*
* The existing record contains only date with id as account.  Now this has been updated
* with following fields
* Module, Booking Date and INFO with id as account.
*-----------------------------------------------------------------------------
* Modification History:
*
* 17/08/05 - BG_100009267(EN_10002606)
*            Update ACCT.BACK.VALUE record with module and date
*            Ref - SAR-2005-04-28-0004
*
* 03/06/09 - CI_10063363
*            F.ACCT.BACK.VALUE corrupted by CONV.ACCT.BACK.VALUE.G16.
*
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY
$INSERT I_F.COMPANY.CHECK

* Equate field numbers to position manually, do no use $INSERT
    EQU AC.BK.MODULE TO 1,
    AC.BK.BOOKING.DATE TO 2,
    AC.BK.INFO TO 3,
    AC.CASH.POOL.GROUP TO 173,
    EB.COM.APPLICATIONS TO 38
*
    FN.COMPANY.CHECK = "F.COMPANY.CHECK"
    F.COMPANY.CHECK = ""
    CALL OPF(FN.COMPANY.CHECK, F.COMPANY.CHECK)

    FN.COMPANY = "F.COMPANY"
    F.COMPANY = ""
    CALL OPF(FN.COMPANY, F.COMPANY)
*
    SAVE.ID.COMPANY = ID.COMPANY
*
    ID.COMPANY.CHECK = "FIN.FILE"
    READU R.COMPANY.CHECK FROM F.COMPANY.CHECK, ID.COMPANY.CHECK ELSE
        R.COMPANY.CHECK = ""
    END

    COMMAND = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
    COMPANY.LIST = ''
    CALL EB.READLIST(COMMAND, COMPANY.LIST, '', '', '')

    LOOP
        REMOVE K.COMPANY FROM COMPANY.LIST SETTING MORE.COMPANIES
    WHILE K.COMPANY:MORE.COMPANIES

        READ R.PROCESS.COMPANY FROM F.COMPANY, K.COMPANY ELSE
            R.PROCESS.COMPANY = ""
        END

        * Check financial company has been added to company check
        LOCATE R.PROCESS.COMPANY<EB.COM.FINANCIAL.COM> IN R.COMPANY.CHECK<EB.COC.COMPANY.CODE,1> SETTING FINANCIAL.COM.POS ELSE
            INS R.PROCESS.COMPANY<EB.COM.FINANCIAL.COM> BEFORE R.COMPANY.CHECK<EB.COC.COMPANY.CODE, FINANCIAL.COM.POS>
            INS R.PROCESS.COMPANY<EB.COM.FINANCIAL.MNE> BEFORE R.COMPANY.CHECK<EB.COC.COMPANY.MNE, FINANCIAL.COM.POS>
        END

        IF R.PROCESS.COMPANY<EB.COM.FINANCIAL.COM> = K.COMPANY THEN
            IF K.COMPANY NE ID.COMPANY THEN
                CALL LOAD.COMPANY(K.COMPANY)
            END

            GOSUB INITIALISE

            GOSUB SELECT.ACCT.BACK.VALUE

            IF SEL.LIST # '' THEN
                GOSUB PROCESS.ACCT.BACK.VALUE
            END
        END ELSE
            * Check this branch has been added to company check
            LOCATE K.COMPANY IN R.COMPANY.CHECK<EB.COC.USING.COM, FINANCIAL.COM.POS, 1> SETTING K.COMPANY.POS ELSE
                INS K.COMPANY BEFORE R.COMPANY.CHECK<EB.COC.USING.COM, FINANCIAL.COM.POS, K.COMPANY.POS>
                INS R.PROCESS.COMPANY<EB.COM.MNEMONIC> BEFORE R.COMPANY.CHECK<EB.COC.USING.MNE, FINANCIAL.COM.POS, K.COMPANY.POS>
            END
        END
    REPEAT

    IF ID.COMPANY NE SAVE.ID.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)
    END

    WRITE R.COMPANY.CHECK ON F.COMPANY.CHECK, ID.COMPANY.CHECK

    RETURN

***********
INITIALISE:
***********
* open files etc
    FN.ACCOUNT = 'F.ACCOUNT'
    FV.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,FV.ACCOUNT)
*
    FN.ACCT.BACK.VALUE = 'F.ACCT.BACK.VALUE'
    FV.ACCT.BACK.VALUE = ''
    CALL OPF(FN.ACCT.BACK.VALUE, FV.ACCT.BACK.VALUE)
*
    LOCATE "MI" IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING MI.INSTALLED THEN
    END ELSE
        MI.INSTALLED = ''
    END
    RETURN

***********************
SELECT.ACCT.BACK.VALUE:
***********************

    EX.STMT = 'SELECT ':FN.ACCT.BACK.VALUE

    SEL.LIST = "" ; SYS.ERROR = ""
    NO.OF.RECS = ''

    CALL EB.READLIST(EX.STMT, SEL.LIST, "", NO.OF.RECS, SYS.ERROR)

    RETURN

***********************
PROCESS.ACCT.BACK.VALUE:
***********************

    LOOP
        REMOVE ACCT.ID FROM SEL.LIST SETTING MORE

    WHILE ACCT.ID:MORE DO

        GOSUB READ.ACCT.BACK.VALUE      ;* Get the Old ACCT.BACK.VALUE record
        ABV.REC.NEW = ''
        MODULE = 'IC'
        INFO = ABV.REC        ;* Old back value contains the date (back value)
        GOSUB BUILD.ABV.RECORD          ;* Build the New ACCT.BACK.VALUE record

        * Values get stored in ACCT.BACK.VALUE for MI module
        IF MI.INSTALLED THEN
            MODULE = 'MI'
            GOSUB BUILD.ABV.RECORD
        END
        *
        GOSUB READ.ACCOUNT
        *
        * Values get stored in ACCT.BACK.VALUE for CP module
        IF R.ACCOUNT<AC.CASH.POOL.GROUP> NE '' THEN
            MODULE = 'CP'
            GOSUB BUILD.ABV.RECORD
        END
        GOSUB WRITE.ABV.RECORD
    REPEAT

    RETURN

*********************
READ.ACCT.BACK.VALUE:
*********************
    ABV.REC = ''
    READ ABV.REC FROM FV.ACCT.BACK.VALUE, ACCT.ID THEN
    END
    RETURN
*****************
BUILD.ABV.RECORD:
*****************
    LOCATE MODULE IN ABV.REC.NEW<AC.BK.MODULE,1> SETTING POS ELSE
        INS MODULE BEFORE ABV.REC.NEW<AC.BK.MODULE,POS>
        INS TODAY BEFORE ABV.REC.NEW<AC.BK.BOOKING.DATE,POS>
        INS INFO BEFORE ABV.REC.NEW<AC.BK.INFO,POS>
    END
    RETURN
*************
READ.ACCOUNT:
*************
    R.ACCOUNT = ''
    READ R.ACCOUNT FROM FV.ACCOUNT, ACCT.ID THEN
    END
    RETURN
*****************
WRITE.ABV.RECORD:
*****************
    WRITE ABV.REC.NEW ON FV.ACCT.BACK.VALUE,ACCT.ID
    RETURN
**************************************************************************
    END
