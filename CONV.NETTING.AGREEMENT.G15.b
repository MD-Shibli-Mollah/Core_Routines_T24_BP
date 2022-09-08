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
* <Rating>-67</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.PaymentNetting
    SUBROUTINE CONV.NETTING.AGREEMENT.G15

* This subroutine converts NETTING.AGREEMENT with id as Customer.FT
* as Customer.203
*
* 06/05/04 - EN_10002261
*            Initial version
* 27/05/03 - BG_100006684
*            Replace FT with 203 in the ID
* 27/05/03 - BG_100006966
*            If netting agreement exist for FT then create netting agreement
*            record for message type 101 and 203 from the existing record and
*            write the new records in IHOLD status
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SPF
    $INSERT I_F.NETTING.AGREEMENT

*=======================
* Open files :
*=======================

    FN.NET.AGR.NAU = "F.NETTING.AGREEMENT$NAU"
    FV.NET.AGR.NAU = ''
    CALL OPF(FN.NET.AGR.NAU,FV.NET.AGR.NAU)

* Process  Live records

    FN.NET.AGR = "F.NETTING.AGREEMENT"
    FV.NET.AGR = ''
    CALL OPF(FN.NET.AGR,FV.NET.AGR)

    SEL.CMD = "SELECT ":FN.NET.AGR: " WITH @ID LIKE ...FT"
    CALL EB.READLIST(SEL.CMD,KEY.LIST,'',SELECTED,'')
    IF SELECTED > 0 THEN
        GOSUB WRITE.REC
    END
*
* Process Nau records
*
    FN.NET.AGR = FN.NET.AGR.NAU
    FV.NET.AGR = FV.NET.AGR.NAU

    SEL.CMD = "SELECT ":FN.NET.AGR.NAU: " WITH @ID LIKE ...FT"
    CALL EB.READLIST(SEL.CMD,KEY.LIST,'',SELECTED,'')
    IF SELECTED > 0 THEN
        GOSUB WRITE.REC
    END
    RETURN

WRITE.REC:
    LOOP
        REMOVE NA.ID FROM KEY.LIST SETTING DONTCARE
    WHILE NA.ID:DONTCARE
        ID.SUFFIX = FIELD(NA.ID,'.',2)
        IF ID.SUFFIX = 'FT' THEN
            R.NET.AGR = ''
            CALL F.READ(FN.NET.AGR,NA.ID,R.NET.AGR,FV.NET.AGR,TERR)
***  Write 101 record
            IF R.NET.AGR<NP.AG.AGREED.CUSTS> THEN
                T.NA.ID = FIELD(NA.ID,'.',1):'.101'         ;* BG_100006684 s/e
                GOSUB UPDATE.AUDIT
                WRITE R.NET.AGR TO FV.NET.AGR.NAU, T.NA.ID
            END

***  Write 203 record
            T.NA.ID = FIELD(NA.ID,'.',1):'.203'   ;* BG_100006684 s/e
            R.NET.AGR<NP.AG.RECORD.STATUS> = 'IHLD'
            R.NET.AGR<NP.AG.AGREED.CUSTS> = ''
            GOSUB UPDATE.AUDIT
            WRITE R.NET.AGR TO FV.NET.AGR.NAU, T.NA.ID
            DELETE FV.NET.AGR, NA.ID
        END
    REPEAT
    RETURN
******************************************
UPDATE.AUDIT:
    CURR.TIME = OCONV(DATE(),"D-")
    CURR.TIME = CURR.TIME[9,2]:CURR.TIME[1,2]:CURR.TIME[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]
    IF R.SPF.SYSTEM<SPF.DATE.TIME.MV> = "YES" THEN
        INS "CONV.NA.G15_":OPERATOR BEFORE R.NET.AGR<NP.AG.INPUTTER,1>
        INS CURR.TIME BEFORE R.NET.AGR<NP.AG.DATE.TIME,1>
    END ELSE
        R.NET.AGR<NP.AG.INPUTTER> = "CONV.NA.G15_":OPERATOR
        R.NET.AGR<NP.AG.DATE.TIME> = CURR.TIME
    END
    R.NET.AGR<NP.AG.RECORD.STATUS> = 'IHLD'
    R.NET.AGR<NP.AG.AUTHORISER> = ''
    RETURN
******************************************
END
