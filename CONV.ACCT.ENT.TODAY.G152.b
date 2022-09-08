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
* <Rating>-91</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.EntryCreation
    SUBROUTINE CONV.ACCT.ENT.TODAY.G152
*-----------------------------------------------------------------------------
* Template file routine, to be used as a basis for building a FILE.ROUTINE
* to be run as part of the CONVERSION.DETAILS record.
* This routine should only be used to do such things as change record keys etc
* where ever possible use the RECORD.ROUTINE to convert/populate record data fields.
*-----------------------------------------------------------------------------
* Modification History:
*
* 01/03/05 - BG_100008233
*            Unassigned variable.
* 18/03/05 - BG_100008393
*            Include ACCT.ENT.FWD in the conversion.
* 03/06/09 - CI_10063344
*            Performance problem during conversion in a multi-book environment
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY.CHECK


***   Main processing   ***
*     ---------------     *

    SAVE.ID.COMPANY = ID.COMPANY
*
* Loop through each company
*
    FN.COMPANY.CHECK = 'F.COMPANY.CHECK'
    F.COMPANY.CHECK = ''
    CALL OPF(FN.COMPANY.CHECK, F.COMPANY.CHECK)

    R.COMP.CHECK = ''
    CALL F.READ(FN.COMPANY.CHECK, "FIN.FILE", R.COMP.CHECK, F.COMPANY.CHECK, "")
    COMPANY.LIST = R.COMP.CHECK<EB.COC.COMPANY.CODE>

    LOOP
        REMOVE K.COMPANY FROM COMPANY.LIST SETTING COMP.MARK
    WHILE K.COMPANY:COMP.MARK

        IF K.COMPANY <> ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
        END
*
* Check whether product is installed
*

        GOSUB INITIALISE

        GOSUB SELECT.ACCT.ENT.TODAY

        IF SEL.LIST # '' THEN
            GOSUB PROCESS.ACCT.ENT.TODAY
        END

        GOSUB SELECT.ACCT.ENT.FWD       ;* BG_100008393/S
        IF SEL.LIST # '' THEN
            GOSUB PROCESS.ACCT.ENT.FWD
        END         ;* BG_100008393/E

    REPEAT

*Restore back ID.COMPANY if it has changed.

    IF ID.COMPANY <> SAVE.ID.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)
    END

    RETURN


*---------*
INITIALISE:
*---------*

    FN.ACCT.ENT.TODAY = 'F.ACCT.ENT.TODAY'
    F.ACCT.ENT.TODAY = ''
    CALL OPF(FN.ACCT.ENT.TODAY,F.ACCT.ENT.TODAY)

    FN.ACCT.ENT.FWD = 'F.ACCT.ENT.FWD'  ;* BG_100008393/S
    F.ACCT.ENT.FWD = ''
    CALL OPF(FN.ACCT.ENT.FWD,F.ACCT.ENT.FWD)      ;* BG_100008393/E

    FN.AC.CONV.ENTRY = 'F.AC.CONV.ENTRY'
    F.AC.CONV.ENTRY = ''
    CALL OPF(FN.AC.CONV.ENTRY,F.AC.CONV.ENTRY)

*     -----------------------------------------------     *
***   Write one off record 'ASSETTYPE' to trigger the   ***
***   update of OPEN.ASSET.TYPE on the ACCOUNT file     ***
***   during the EOD                                    ***
*     -----------------------------------------------     *

    DUMMY = ''
    WRITE DUMMY ON F.AC.CONV.ENTRY,'ASSETTYPE'

    SEL.LIST = ''
    ACC.ENT.TODAY.ID = ''

    RETURN

*--------------------*
SELECT.ACCT.ENT.TODAY:
*--------------------*

    SEL.STMT = 'SELECT ':FN.ACCT.ENT.TODAY
    SEL.LIST = ""
    SELECTED = ""
    RET.CODE = ""
    CALL EB.READLIST(SEL.STMT, SEL.LIST, '', SELECTED, RET.CODE)
    RETURN

*---------------------*
PROCESS.ACCT.ENT.TODAY:
*---------------------*

    LOOP
        REMOVE ACCT.ENT.TODAY.ID FROM SEL.LIST SETTING MORE
    WHILE ACCT.ENT.TODAY.ID:MORE

        GOSUB READ.ACCT.ENT.TODAY

        R.AC.CONV.ENTRY = R.ACCT.ENT.TODAY        ;* BG_100008393/S
        AC.CONV.ENTRY.ID = 'ACCENTTODAY.':ACCT.ENT.TODAY.ID ;* BG_100008393/E

        GOSUB WRITE.AC.CONV.ENTRY

    REPEAT

    RETURN


*------------------*
READ.ACCT.ENT.TODAY:
*------------------*

    R.ACCT.ENT.TODAY = ''
    YERR = ''
    RETRY = ""
    READ R.ACCT.ENT.TODAY FROM F.ACCT.ENT.TODAY,ACCT.ENT.TODAY.ID ELSE
        R.ACCT.ENT.TODAY = ''
    END

    RETURN

*------------------*
SELECT.ACCT.ENT.FWD:
*------------------*

* BG_100008393/S

    SEL.STMT = 'SELECT ':FN.ACCT.ENT.FWD
    SEL.LIST = ""
    SELECTED = ""
    RET.CODE = ""
    CALL EB.READLIST(SEL.STMT, SEL.LIST, '', SELECTED, RET.CODE)
    RETURN

*-------------------*
PROCESS.ACCT.ENT.FWD:
*-------------------*

    LOOP
        REMOVE ACCT.ENT.FWD.ID FROM SEL.LIST SETTING MORE
    WHILE ACCT.ENT.FWD.ID:MORE

        GOSUB READ.ACCT.ENT.FWD
        R.AC.CONV.ENTRY = R.ACCT.ENT.FWD
        AC.CONV.ENTRY.ID = 'ACCENTFWD.':ACCT.ENT.FWD.ID

        GOSUB WRITE.AC.CONV.ENTRY

    REPEAT

    RETURN


*----------------*
READ.ACCT.ENT.FWD:
*----------------*

    R.ACCT.ENT.FWD = ''
    YERR = ''
    RETRY = ""
    READ R.ACCT.ENT.FWD FROM F.ACCT.ENT.FWD,ACCT.ENT.FWD.ID ELSE
        R.ACCT.ENT.FWD = ''
    END

    RETURN          ;* BG_100008393

*------------------*
WRITE.AC.CONV.ENTRY:
*------------------*

    WRITE R.AC.CONV.ENTRY ON F.AC.CONV.ENTRY,AC.CONV.ENTRY.ID

    RETURN

END
