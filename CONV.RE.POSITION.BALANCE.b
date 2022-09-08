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
* <Rating>142</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.CurrencyPosition
    SUBROUTINE CONV.RE.POSITION.BALANCE
*------------------------------------------------------------------------------
* This routine is used to add respective company code in the prefix of
* @ID of existing RE.POSITION.BALANCE records and in the prefix of the field
* POSITION.BAL.ID of existing RE.CONSOL.AL records.
*
* For Example:
* ------------
* Existing RE.POSITION.BALANCE ID : 1TR00USDGBP
* After adding respective CO.CODE, the ID will be : US00100011TR00USDGBP
*
*------------------------------------------------------------------------------
* GLOBUS_CI_10028612 - Changes done to include RE.POSITION.BALANCE id prefixed with
*                      Companycode.
*
*------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
*------------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB LOAD.COMPANY.AND.PROCESS

    RETURN
*------------------------------------------------------------------------------
INITIALISE:
*----------
*--- Initialise the variables here.

    SAVE.COMPANY.ID = ID.COMPANY
    FN.COMP = 'F.COMPANY'
    F.COMP = ''
    CALL OPF(FN.COMP,F.COMP)
    SEL.CMD = 'SELECT ':FN.COMP:' WITH CONSOLIDATION.MARK NE "C"'
    NO.OF.COMPS = ''
    CALL EB.READLIST(SEL.CMD, COMP.IDS,'',NO.OF.COMPS,'')

    RETURN
*------------------------------------------------------------------------------
LOAD.COMPANY.AND.PROCESS:
*------------------------
    FOR Y.CNT = 1 TO NO.OF.COMPS
*--- Load each and every company
        CALL LOAD.COMPANY(COMP.IDS<Y.CNT>)

        FN.RE.POS.BAL = 'F.RE.POSITION.BALANCE'
        F.RE.POS.BAL = ''
        CALL OPF(FN.RE.POS.BAL,F.RE.POS.BAL)

        FN.RE.CONSOL.AL = 'F.RE.CONSOL.AL'
        F.RE.CONSOL.AL = ''
        CALL OPF(FN.RE.CONSOL.AL,F.RE.CONSOL.AL)

*--- Attach ID.COMPANY to ID of RE.POSITION.BALANCE records
        GOSUB CHANGE.RE.POS.ID
*--- Attach ID.COMPANY in RE.CONSOL.BAL records
        GOSUB CHANGE.RE.CONSOL.AL.RECS

    NEXT Y.CNT

*--- Load the default company again here.
    CALL LOAD.COMPANY(SAVE.COMPANY.ID)

    RETURN
*------------------------------------------------------------------------------
CHANGE.RE.POS.ID:
*----------------
    SEL.CMD = 'SELECT ':FN.RE.POS.BAL
    NO.OF.RECS = ''
    CALL EB.READLIST(SEL.CMD, Y.RE.POS.BAL.IDS,'','','')

    LOOP
        REMOVE Y.RE.POS.BAL.ID FROM Y.RE.POS.BAL.IDS SETTING Y.POS

    WHILE Y.RE.POS.BAL.ID:Y.POS

        IF LEN(Y.RE.POS.BAL.ID) EQ 11 THEN
            SAVE.RE.POS.ID = Y.RE.POS.BAL.ID
            READ R.RE.POS.BAL FROM F.RE.POS.BAL,Y.RE.POS.BAL.ID THEN

                Y.RE.POS.BAL.ID = ID.COMPANY:Y.RE.POS.BAL.ID

                WRITE R.RE.POS.BAL TO F.RE.POS.BAL, Y.RE.POS.BAL.ID
                DELETE F.RE.POS.BAL, SAVE.RE.POS.ID

            END
        END
    REPEAT

    RETURN
*------------------------------------------------------------------------------
CHANGE.RE.CONSOL.AL.RECS:
*------------------------

    SEL.CMD = 'SELECT ':FN.RE.CONSOL.AL
    CALL EB.READLIST(SEL.CMD, Y.RE.CON.AL.IDS,'','','')

    Y.POS = ''

    LOOP
        REMOVE Y.RE.CON.AL.ID FROM Y.RE.CON.AL.IDS SETTING Y.POS
    WHILE Y.RE.CON.AL.ID:Y.POS
        Y.RE.POS = ''
        R.RE.CONSOL.AL = ''
        R.TEMP.RE.CONSOL.AL = ''
        READ R.RE.CONSOL.AL FROM F.RE.CONSOL.AL,Y.RE.CON.AL.ID THEN

            LOOP
                REMOVE Y.RE.POS.ID FROM R.RE.CONSOL.AL SETTING Y.RE.POS
            WHILE Y.RE.POS.ID:Y.RE.POS
                IF LEN(Y.RE.POS.ID) EQ 11 THEN
                    Y.RE.POS.ID = ID.COMPANY:Y.RE.POS.ID
                END
                LOCATE Y.RE.POS.ID IN R.TEMP.RE.CONSOL.AL<1> SETTING RE.POS ELSE
                    IF R.TEMP.RE.CONSOL.AL THEN
                        R.TEMP.RE.CONSOL.AL := @FM:Y.RE.POS.ID
                    END ELSE
                        R.TEMP.RE.CONSOL.AL = Y.RE.POS.ID
                    END
                END
            REPEAT
            IF R.TEMP.RE.CONSOL.AL THEN
                WRITE R.TEMP.RE.CONSOL.AL TO F.RE.CONSOL.AL, Y.RE.CON.AL.ID
            END
        END
    REPEAT

    RETURN
*------------------------------------------------------------------------------
END
