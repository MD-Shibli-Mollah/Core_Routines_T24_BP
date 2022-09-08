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
* <Rating>-19</Rating>
*-----------------------------------------------------------------------------
* Version n dd/mm/yy  GLOBUS Release No. 200508 30/06/05
*
    $PACKAGE AC.AccountOpening
    SUBROUTINE CONV.ACCOUNT.200512
*-----------------------------------------------------------------------------
* Template file routine, to be used as a basis for building a FILE.ROUTINE
* to be run as part of the CONVERSION.DETAILS record.
* This routine should only be used to do such things as change record keys etc
* where ever possible use the RECORD.ROUTINE to convert/populate record data fields.
*-----------------------------------------------------------------------------
* Modification History:
*
* 16/06/06 - BG_100011481
*            Unnecessary records written to AC.CONV.ENTRY. No need to write
*            the individual records, since the dummy record has been written
*            to AC.CONV.ENTRY.
*
* 27/10/09 - CI_10067066
*            New record CONTSELFBAL is written to AC.CONV.ENTRY for raising self
*            balancing entries for contingent accounts.
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE


***   Main processing   ***
*     ---------------     *

    SAVE.ID.COMPANY = ID.COMPANY
*
* Loop through each company
*
    COMMAND = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
    COMPANY.LIST = ''
    CALL EB.READLIST(COMMAND, COMPANY.LIST, '', '', '')

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

    REPEAT

*Restore back ID.COMPANY if it has changed.

    IF ID.COMPANY <> SAVE.ID.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)
    END

    RETURN


*---------*
INITIALISE:
*---------*



    FN.AC.CONV.ENTRY = 'F.AC.CONV.ENTRY'
    F.AC.CONV.ENTRY = ''
    CALL OPF(FN.AC.CONV.ENTRY,F.AC.CONV.ENTRY)

*     -----------------------------------------------     *
***   Write one off record 'CONTRACT.BALANCE' to trigger the   ***
***   update of OPEN.ASSET.TYPE on the ACCOUNT file     ***
***   during the EOD                                    ***
*     -----------------------------------------------     *

    DUMMY = ''
    WRITE DUMMY ON F.AC.CONV.ENTRY,'CONTRACTBALANCE'
    WRITE DUMMY ON F.AC.CONV.ENTRY,'CONTSELFBAL'

    SEL.LIST = ''
    ACCT.ID = ''

    RETURN



END
