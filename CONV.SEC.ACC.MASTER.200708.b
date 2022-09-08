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
* <Rating>-23</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoPortfolioMaintenance
    SUBROUTINE CONV.SEC.ACC.MASTER.200708(ID.SEC.ACC.MASTER, R.SEC.ACC.MASTER, FN.SEC.ACC.MASTER)
*-----------------------------------------------------------------------------
* This conversion routine will update the value of CATEGORY and PRODCAT fields
* that are introduced as part of the IDESC cleanup - SC SAR.
* These two fields would be updated based on the condition as explained in the related
* IDESC fields PRODCAT and CATEGORY.
*-----------------------------------------------------------------------------
* Modification History:
*
* 13/04/07 - EN_10003308
*            IDESC Cleanup - SC
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE

* Initialise
    GOSUB INITIALISATION

* Clear fields
    GOSUB PROCESS.FIELDS

    RETURN

*-----------------------------------------------------------------------------
INITIALISATION:

    RETURN

*-----------------------------------------------------------------------------

PROCESS.FIELDS:
** Based on the conditions as in related IDESC fields of CATEGORY & PRODCAT
** the values have been populated here.

    IF R.SEC.ACC.MASTER<37> EQ "CRF00" THEN
        R.SEC.ACC.MASTER<147> = "22999"
        R.SEC.ACC.MASTER<148> = "22999"
    END

    RETURN
END
