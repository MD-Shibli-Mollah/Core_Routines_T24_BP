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
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
* Routine to remove the Check of TRADE/SETTLEMENT check from SC.STD.SEC.TRADE
* to add in ACCOUNT.PARAMETER so that EB.ACCOUNTING will do the necessary Check.

    $PACKAGE SC.Config
    SUBROUTINE CONV.SC.ACCTNG.SETUP(LOCAL.ID,LOCAL.REC,LOCAL.FILE)

*--------------------------------------------------------------------------------
* 15/07/04 - BG_100006960
*            BG for the EN_10002167. Suspense Category Not set up if Value Dated
*            Acctng field is set to NO and SC is value dated acctng.
*
* 21/07/04 - BG_100006967
*            BG for the EN_10002167. Removed update to Account Parameter record
*            which is done as a seperate conversion record. This conversion will
*            remove the value from field TRADE.SETTLE.ACCTG and raise Real Entries
*            from SC.HOLD.ENTRIES and remove F Entries.
*
* 11/05/06 - GLOBUS_CI_10041014
*            Remove the call to CONV.SC.HOLD.ENTRIES.G150 and call it from a
*            separate CONVERSION.DETAILS record.
*
*---------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE

    Y.FILE.TYPE = LOCAL.FILE[4]
    IF Y.FILE.TYPE = '$HIS' OR Y.FILE.TYPE='$NAU' THEN
        LOCAL.REC<42> = ''
    END ELSE

        LOCAL.REC<42> = ''    ;* TRADE.SETTLE.ACCTG is renamed as reserved
*                              So, the position is hardcoded

        SAVE.COMPANY = ID.COMPANY
        IF SAVE.COMPANY NE LOCAL.ID THEN
            CALL LOAD.COMPANY(LOCAL.ID)
        END

        CALL CONV.CONSOL.ENT.TODAY.G150

        IF SAVE.COMPANY NE LOCAL.ID THEN
            CALL LOAD.COMPANY(SAVE.COMPANY)
        END

    END

    RETURN
END
