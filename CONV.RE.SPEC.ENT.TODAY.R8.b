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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.EntryCreation
    SUBROUTINE CONV.RE.SPEC.ENT.TODAY.R8(RE.SPEC.ENT.TODAY.ID,R.RE.SPEC.ENT.TODAY,FN.RE.SPEC.ENT.TODAY)
*-----------------------------------------------------------------------------
* Modification logs:
* ------------------
*
* 13/11/07 - BG_1000
*            Shorten the RE.SPEC.ENT.TODAY key by removing 2nd consol.key from key.
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE

    ENT.ID = RE.SPEC.ENT.TODAY.ID['*',2,1]
    CONSOL.KEY = RE.SPEC.ENT.TODAY.ID['*',1,1]
    PDATE = RE.SPEC.ENT.TODAY.ID['*',3,1]
    IF ENT.ID[1,2] = 'R!' THEN
        ENT.ID['!',2,1] = ''
        NEW.KEY = CONSOL.KEY:'*':ENT.ID:'*':PDATE
        IF NEW.KEY # RE.SPEC.ENT.TODAY.ID THEN
            DELETE F.FILE,RE.SPEC.ENT.TODAY.ID
            RE.SPEC.ENT.TODAY.ID = NEW.KEY
        END
    END

    RETURN

