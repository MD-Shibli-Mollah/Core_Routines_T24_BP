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
* <Rating>100</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.Customer
    SUBROUTINE CONV.EB.RATING.R6(SC.ID, SC.RATING.REC, FN.SC.RATING)
*
** This subroutine will populate EB.RATING file with data from SC.RATING records
*
*------------------------------------------------------------------------------------
* 08/09/05 - EN_10002618
*            Populating EB.RATING from SC.RATING
*
*------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
*------------------------------------------------------------------------------------
    EQU AGENCY.ID TO 2, SL.HVCRE.RATING TO 3

    SUFFIX.TYPE=FIELD(FN.SC.RATING,"$",2)
    IF SUFFIX.TYPE="HIS" OR SUFFIX.TYPE="NAU" THEN RETURN

    FN.EB.RATING = 'F.EB.RATING'
    FV.EB.RATING = ''
    CALL OPF(FN.EB.RATING,FV.EB.RATING)

    EB.RATING.RECORD = ''
    EB.RATING.RECORD=SC.RATING.REC
    EB.RATING.RECORD=INSERT(EB.RATING.RECORD,AGENCY.ID,0,0,"")
    EB.RATING.RECORD=INSERT(EB.RATING.RECORD,SL.HVCRE.RATING,0,0,"")
    WRITE EB.RATING.RECORD TO FV.EB.RATING, SC.ID
    RETURN
END
