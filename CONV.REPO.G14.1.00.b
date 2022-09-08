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
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RP.Contract
    SUBROUTINE CONV.REPO.G14.1.00(REPO.ID, REPO.REC, REPO.FILE)

*********************************************************************

* 07/08/03 - EN_10001924
*		The position of few fields have been changed likewise,
*		Old position / Field name   -     New position/Field name
*		38 - RESERVEDX9             -        38 - GRP.TRD.ID
*		39 - GRP.TRD.ID               -        39 - GRP.TRD.PROC
*		40 - GRP.TRD.PROC           -        40 - RESERVEDX9
*		83 - RESERVEDXX10          -        83 - OLD.GP.TD.ID
*		84 - RESERVEDXX9           -        84 - OLD.GP.TD.PR
*            Values in GRP.TRD.ID is mapped into OLD.GP.TD.ID and values
*            GRP.TRD.PROC is mapped into OLD.GP.TD.PR. Since the
*            positions of GRP.TRD.ID and GRP.TRD.PROC are changed, their
*            corresponding values are assigned back to the fields in its
*            new position.
*
* 25/09/03 - EN_10001997
*                  Margin Call Enhancement.
*                 The position of few fields have been changed likewise,
*                 Old position / Field name   -     New position/Field name
*               38 - RESERVEDX9          -        RP.RESERVEDX9 - GRP.TRD.ID
*               39 - GRP.TRD.ID            -        RP.GRP.TRD.ID - GRP.TRD.PROC
*               40 - GRP.TRD.PROC       -        RP.GRP.TRD.PROC - FX.RATE
*               83 - RESERVEDXX10      -        RP.RESERVEDXX10 - OLD.GP.TD.ID
*               84 - RESERVEDXX9        -        RP.RESERVEDXX9 - OLD.GP.TD.PR
*                
***********************************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
***********************************************************************

    GOSUB INITIALISE

    GOSUB PROCESS.RECS

    RETURN

***********************************************************************
INITIALISE:
***********

    RP.RESERVEDX9 = 43
    RP.GRP.TRD.ID = 44
    RP.GRP.TRD.PROC = 45
    RP.RESERVEDXX10 = 88
    RP.RESERVEDXX9 = 89

    RETURN

***********************************************************************
PROCESS.RECS:
*************

    IF REPO.REC<RP.RESERVEDX9> EQ '' THEN
        REPO.REC<RP.RESERVEDX9> = REPO.REC<RP.GRP.TRD.ID>
        REPO.REC<RP.GRP.TRD.ID> = REPO.REC<RP.GRP.TRD.PROC>
        REPO.REC<RP.RESERVEDXX10> = REPO.REC<RP.RESERVEDX9>
        REPO.REC<RP.RESERVEDXX9> = REPO.REC<RP.GRP.TRD.ID>
        REPO.REC<RP.GRP.TRD.PROC> = ''
    END
    RETURN

************************************************************************

END
