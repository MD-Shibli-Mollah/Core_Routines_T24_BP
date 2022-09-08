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
* <Rating>296</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AZ.Contract
    SUBROUTINE CONV.MB.AZ.ACCOUNT.G14.2(ID,YREC,FILE)
*
* This conversion routine is to convert the value in the field ALL.IN
* ONE.PRODUCT (existing string or numeric into 'STRING OR NUMERIC ' * COMPANY.ID)
* of the files AZ.ACCOUNT and ACCOUNT.
*
* Note: This conversion should be run before the conversion of account for MB...
*-----------------------------------------------------------------------*
* Modification History *
*----------------------*
* 14.01.04 - BG_100006020
*            This routine convert other than Master company code
*
*-----------------------------------------------------------------------*
*
    $INSERT I_COMMON
    $INSERT I_EQUATE

* BG_100006020 - S

    FN.COMPANY.CHECK = 'F.COMPANY.CHECK' ; FV.COMPANY.CHECK = ''
    CALL OPF(FN.COMPANY.CHECK, FV.COMPANY.CHECK)
    R.COMPANY.CHECK = ''
    COM.MAST.ID = 'MASTER'
    READ R.COMPANY.CHECK FROM FV.COMPANY.CHECK,COM.MAST.ID THEN

        COMP.ID = YREC<109>   ;* Company.code...
        IF COMP.ID EQ R.COMPANY.CHECK<1,1> THEN RETURN      ;* COMP.ID is a master company code exit from the routine

        APP.ID = YREC<4>      ;* All.in.one.product id...
        YCOM.CHK = FIELD(APP.ID,'*',2)
        IF YCOM.CHK THEN RETURN         ;* Already converted BG_100006020 - E

        FV.ACC = 'F.ACCOUNT'
        FP.ACC = ''
        CALL OPF(FV.ACC,FP.ACC)

        YREC<4> = APP.ID:'*':COMP.ID
100:    READU ACC.REC FROM FP.ACC,ID LOCKED
            SLEEP 1
            GOTO 100
        END THEN
            ACC.REC<144> = APP.ID:'*':COMP.ID     ;* All.in.one.product id...
            WRITE ACC.REC ON FP.ACC,ID
        END
    END
    RETURN
*
END
