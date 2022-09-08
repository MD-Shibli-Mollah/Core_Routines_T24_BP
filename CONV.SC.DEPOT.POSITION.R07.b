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
    $PACKAGE SC.SctSecurityLending
    SUBROUTINE CONV.SC.DEPOT.POSITION.R07(SECURITY.POSITION.ID)

* This conversion routine will create records for depo position in SC.DEPOT.POSITION from the existing record in SECURITY.POSITION
*
* Modification History
*
* 05/09/06 - GLOBUS_EN_10003034
*            Conversion record to built SC.DEPOT.POSITION
*
* 01/12/06 - GLOBUS_CI_10045393
*            Conversion record written as service
*
*--------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SECURITY.POSITION
    $INSERT I_F.SC.DEPOT.POSITION
    $INSERT I_CONV.SC.DEPOT.POSITION.R07.COMMON

    SECURITY.ACC = '' ; SEC.ACC.SUFFIX = ''

    SECURITY.ACC = FIELD(SECURITY.POSITION.ID,'.',1)
    SEC.ACC.SUFFIX = FIELD(SECURITY.ACC,'-',2)

    IF SEC.ACC.SUFFIX EQ 999 THEN
        R.SECURITY.POSITION = '' ; R.SC.DEPOT.POSITION = '' ; READ.ERR = ''
        CALL F.READ(FN.SECURITY.POSITION,SECURITY.POSITION.ID,R.SECURITY.POSITION,F.SECURITY.POSITION,READ.ERR)

        IF NOT(READ.ERR) AND R.SECURITY.POSITION<29> NE '' THEN
            FOR I = 1 TO 7
                R.SC.DEPOT.POSITION<I> = R.SECURITY.POSITION<I>
            NEXT I

            R.SC.DEPOT.POSITION<8> = R.SECURITY.POSITION<29>

            WRITE R.SC.DEPOT.POSITION TO F.SC.DEPOT.POSITION, SECURITY.POSITION.ID
        END

    END

    IF SEC.ACC.SUFFIX EQ 999 OR SEC.ACC.SUFFIX EQ 777 THEN
        CALL F.DELETE(FN.SECURITY.POSITION,SECURITY.POSITION.ID)
    END

    RETURN

END
