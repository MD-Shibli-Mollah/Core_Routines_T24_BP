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
* <Rating>117</Rating>
*-----------------------------------------------------------------------------
* Conversion Routine to update Account Parameter to add SYSTEM.ID 'SC' and
* 'IC' to field VAL.DATE.SYS.ID and corresponding VAL.DATE.BY.SYS.ID fields
* of Account Parameter record.
* This is the record routine for the Conversion of Account Parameter of G150.
*-----------------------------------------------------------------------------
* 21/07/04 - BG_100006967
*            Conversion Routine for ACCOUNT.PARAMETER (RECORD ROUTINE)
*
* 22/04/09 - CI_10062366
*            Variable VAL.SETT is not initialised properly.
*-----------------------------------------------------------------------------

    $PACKAGE AC.Config
    SUBROUTINE CONV.ACCOUNT.PARAMETER.G150(ACC.PAR.ID,R.ACCOUNT.PARAM,ACC.PAR.FILE)
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_F.ACCOUNT.CLASS

    AAC.SETT = 'NO'
    AAC.CMD = '' ; AAC.LIST = '' ; AAC.SELECTED = '' ; AAC.ERR = ''
    AAC.ID = '' ; R.ACC.ARL = '' ; READ.ACC.ERR = ''
    VAL.SETT = 'NO'
    STD.CMD = '' ; STD.LIST = '' ; STD.SELECTED = '' ; STD.ERR = ''
    STD.ID = '' ; R.SC.STD = '' ; READ.STD.ERR = ''


    FN.ACCOUNT.ACCRUAL = 'F.ACCOUNT.ACCRUAL'
    FV.ACCOUNT.ACCRUAL = ''
    CALL OPF(FN.ACCOUNT.ACCRUAL,FV.ACCOUNT.ACCRUAL)

    AAC.CMD = 'SELECT ':FN.ACCOUNT.ACCRUAL
    CALL EB.READLIST(AAC.CMD,AAC.LIST,'',AAC.SELECTED,AAC.ERR)
    LOOP
        REMOVE AAC.ID FROM AAC.LIST SETTING AAC.POS
    WHILE AAC.ID:AAC.POS
        CALL F.READ(FN.ACCOUNT.ACCRUAL,AAC.ID,R.ACC.ARL,FV.ACCOUNT.ACCRUAL,READ.ACC.ERR)
        IF R.ACC.ARL<4> = 'NEXT' THEN AAC.SETT = 'Y'
    UNTIL AAC.SETT = 'Y'
    REPEAT

    LOCATE 'IC' IN R.ACCOUNT.PARAM<3,1> SETTING LOCATED THEN
        IF R.ACCOUNT.PARAM<4,LOCATED> = 'NO' THEN
            R.ACCOUNT.PARAM<4,LOCATED> = AAC.SETT
        END
    END ELSE
        IF R.ACCOUNT.PARAM<3> THEN
            R.ACCOUNT.PARAM<3> :=VM:'IC'
            R.ACCOUNT.PARAM<4> :=VM:AAC.SETT
            R.ACCOUNT.PARAM<5> :=VM:''
            R.ACCOUNT.PARAM<6> :=VM:''
            R.ACCOUNT.PARAM<7> :=VM:''
        END ELSE
            R.ACCOUNT.PARAM<3> = 'IC'
            R.ACCOUNT.PARAM<4> = AAC.SETT
            R.ACCOUNT.PARAM<5> = ''
            R.ACCOUNT.PARAM<6> = ''
            R.ACCOUNT.PARAM<7> = ''
        END
    END



    LOCATE 'SC' IN R.COMPANY(38)<1,1> SETTING FOUND.SC THEN
        FN.SC.STD.SEC.TRADE = 'F.SC.STD.SEC.TRADE'
        FV.SC.STD.SEC.TRADE = ''
        CALL OPF(FN.SC.STD.SEC.TRADE,FV.SC.STD.SEC.TRADE)
        STD.CMD = 'SELECT ':FN.SC.STD.SEC.TRADE
        CALL EB.READLIST(STD.CMD,STD.LIST,'',STD.SELECTED,STD.ERR)
        LOOP
            REMOVE STD.ID FROM STD.LIST SETTING STD.POS
        WHILE STD.ID:STD.POS
            CALL F.READ(FN.SC.STD.SEC.TRADE,STD.ID,R.SC.STD,FV.SC.STD.SEC.TRADE,READ.STD.ERR)
            IF R.SC.STD<42> = 'SETTLEMENT' THEN VAL.SETT = 'Y'
        UNTIL VAL.SETT = 'Y'
        REPEAT

        LOCATE 'SC' IN R.ACCOUNT.PARAM<3,1> SETTING LOCATED THEN
            IF R.ACCOUNT.PARAM<4,LOCATED> = 'NO' THEN
                R.ACCOUNT.PARAM<4,LOCATED> = VAL.SETT
            END
        END ELSE
            IF R.ACCOUNT.PARAM<3> THEN
                R.ACCOUNT.PARAM<3> :=VM:'SC'
                R.ACCOUNT.PARAM<4> :=VM:VAL.SETT
                R.ACCOUNT.PARAM<5> :=VM:''
                R.ACCOUNT.PARAM<6> :=VM:''
                R.ACCOUNT.PARAM<7> :=VM:''
            END

        END
    END
    CATEG.CODE = R.ACCOUNT.PARAM<15>
    IF NOT(CATEG.CODE) AND (VAL.SETT = 'Y' OR AAC.SETT = 'Y') THEN
        SUSP.CODE = ''
        CALL DBR('ACCOUNT.CLASS':FM:AC.CLS.CATEGORY,'SUSPENSE',SUSP.CODE)
        R.ACCOUNT.PARAM<15> = SUSP.CODE<1,1>
        R.ACCOUNT.PARAM<16> = '601'
        R.ACCOUNT.PARAM<17> = '602'
    END

    R.ACCOUNT.PARAMETER = R.ACCOUNT.PARAM         ;* Refresh Common variable

    RETURN
END
