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
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.RulesEngine
    SUBROUTINE CONV.EB.RULES.VERSION.200712(REC.ID, PROP.REC, YFILE)
*-----------------------------------------------------------------------------
* Conversion routine to populate  audit fields
*-----------------------------------------------------------------------------
*MODIFICATION HISTORY:
*--------------------
* 11/10/07 - EN_10003534
*            Locking and history file update for EB.RULES.VERSION.
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.USER

    FLD.NO = 33     ;* no: of fields
    PROP.REC<FLD.NO-7> = "1"  ;*curr no
    PROP.REC<FLD.NO-2> = R.USER<EB.USE.DEPARTMENT.CODE>     ;*department code
    PROP.REC<FLD.NO-6,1> = TNO:'_':OPERATOR       ;*inputter
    PROP.REC<FLD.NO-3> = ID.COMPANY     ;*company code
    PROP.REC<FLD.NO-4,1> = TNO:'_':OPERATOR       ;*authoriser
    PROP.REC<FLD.NO-5,1> = OCONV(DATE(),"D-")[9,2]:OCONV(DATE(),"D-")[1,2]:OCONV(DATE(),"D-")[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]          ;*date time
    RETURN
END
