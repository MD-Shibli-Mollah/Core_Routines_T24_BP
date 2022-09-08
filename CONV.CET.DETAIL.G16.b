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

*
*-----------------------------------------------------------------------------
* <Rating>-64</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.EntryCreation
    SUBROUTINE CONV.CET.DETAIL.G16
*-----------------------------------------------------------------------------
* Template file routine, to be used as a basis for building a FILE.ROUTINE
* to be run as part of the CONVERSION.DETAILS record.
* This routine should only be used to do such things as change record keys etc
* where ever possible use the RECORD.ROUTINE to convert/populate record data fields.
*-----------------------------------------------------------------------------
* Modification History:
*
* 25/01/05 - EN_10002408
*            Update EOD.CONSOL.UPDATE.DETAIL with CONSOL.ENT.TODAY INFO
*
* 07/06/06 - CI_10041687
*          - Removing BOOKING.DATE from selection of CET and setting
*          - R.CET<25> = TODAY if null, cause this fld is used to update
*          - RE.CONSOL.SPEC.ENTRY . This is done to avoid mismatches when
*          - upgrading from releases lower than G14 to R06. Since BOOKING.DATE
*          - field was not there in the lower releases.
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE


* Equate field numbers to position manually, do no use $INSERT
    EQU SUFFIXES TO 3
    EQU FILE.CONTROL.CLASS TO 6

    SAVE.ID.COMPANY = ID.COMPANY

*
    COMMAND = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
    COMPANY.LIST = ''
    CALL EB.READLIST(COMMAND, COMPANY.LIST, '', '', '')

    LOOP
        REMOVE K.COMPANY FROM COMPANY.LIST SETTING MORE.COMPANIES
    WHILE K.COMPANY:MORE.COMPANIES

        IF K.COMPANY NE ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
        END

        GOSUB INITIALISE

        GOSUB SELECT.CET

        IF SEL.LIST # '' THEN
            GOSUB PROCESS.CET
        END

    REPEAT

    IF ID.COMPANY NE SAVE.ID.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)
    END

    RETURN

*---------*
INITIALISE:
*---------*
* open files etc


    FN.CONSOL.ENT.TODAY = 'F.CONSOL.ENT.TODAY'
    F.CONSOL.ENT.TODAY = ''
    CALL OPF(FN.CONSOL.ENT.TODAY,F.CONSOL.ENT.TODAY)

    FN.EOD.CONSOL.UPDATE.DETAIL = 'F.EOD.CONSOL.UPDATE.DETAIL'
    F.EOD.CONSOL.UPDATE.DETAIL = ''
    CALL OPF(FN.EOD.CONSOL.UPDATE.DETAIL,F.EOD.CONSOL.UPDATE.DETAIL)

    PREV.CET.DETAIL.ID = ''

    RETURN

*---------*
SELECT.CET:
*---------*

    EX.STMT = 'SELECT ':FN.CONSOL.ENT.TODAY:' BY TXN.REF'

    SEL.LIST = "" ; SYS.ERROR = ""
    NO.OF.RECS = ''

    CALL EB.READLIST(EX.STMT, SEL.LIST, "", NO.OF.RECS, SYS.ERROR)

    RETURN

*----------*
PROCESS.CET:
*----------*

    LOOP
        REMOVE CET.ID FROM SEL.LIST SETTING MORE

    WHILE CET.ID:MORE DO

        R.CET = ''

        READ R.CET FROM F.CONSOL.ENT.TODAY, CET.ID ELSE
            CONTINUE
        END

        CONTRACT.ID = R.CET<2>          ;* TXN.REF 
        IF R.CET<25> = '' THEN
            R.CET<25> = TODAY
        END

        CET.DETAIL.ID = CONTRACT.ID:'*':R.CET<25>
        IF PREV.CET.DETAIL.ID = '' THEN
            GOSUB READ.CET.DETAIL
            PREV.CET.DETAIL.ID = CET.DETAIL.ID
        END
        IF PREV.CET.DETAIL.ID # CET.DETAIL.ID THEN
            GOSUB WRITE.CET.DETAIL
            GOSUB READ.CET.DETAIL
            PREV.CET.DETAIL.ID = CET.DETAIL.ID
        END

        DETAIL.LINE = R.CET<1>:'*':CET.ID         ;* Product * CET.ID
        LOCATE DETAIL.LINE IN R.CET.DETAIL<1> BY 'AR' SETTING POS ELSE
            INS DETAIL.LINE BEFORE R.CET.DETAIL<POS>
        END

    REPEAT
    GOSUB WRITE.CET.DETAIL

    RETURN

*--------------*
READ.CET.DETAIL:
*--------------*

    READ R.CET.DETAIL FROM F.EOD.CONSOL.UPDATE.DETAIL,CET.DETAIL.ID ELSE
        R.CET.DETAIL = ''
    END

    RETURN

*---------------*
WRITE.CET.DETAIL:
*---------------*

    WRITE R.CET.DETAIL ON F.EOD.CONSOL.UPDATE.DETAIL,PREV.CET.DETAIL.ID

    RETURN

**************************************************************************
END
