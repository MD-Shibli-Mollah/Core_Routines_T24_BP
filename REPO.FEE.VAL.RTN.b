* @ValidationCode : MjoyMDE0NDQ2MTkzOkNwMTI1MjoxNjA1MjU4MDUzOTcyOmdhaXNzd2FyeWE6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEwLjIwMjAwOTI5LTEyMTA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Nov 2020 14:30:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : gaisswarya
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200929-1210
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE RP.Contract
SUBROUTINE REPO.FEE.VAL.RTN
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
*****<doc>
* Routine Name      :   REPO.FEE.VAL.RTN
* Attached to       :   REPO,INT.SBL
* Attached as       :   Validation Routine
* Input arguments   :   NA
* Output arguments  :   NA
* Description       :   Routine is used to validate the fields Fee and Spread in REPO,INT.SBL
* @author           :   aisswaryaganesh@temenos.com
* </doc>
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 09/11/2020 - Defect 4052785 / Task 4070874
*              In a REPO deal if FEE AMOUNT populated before committing, failing to get recalculated on amending FEE and SPREAD.
*-----------------------------------------------------------------------------
    $USING RP.Contract
    $USING EB.SystemTables
    GOSUB Initialise ; *Initialize the required variables.

*-----------------------------------------------------------------------------

*** <region name= In
Initialise:
*** <desc> Initialize the required variables. </desc>
    IF EB.SystemTables.getMessage() NE "" THEN
        RETURN
    END
    CUR.VALUE = EB.SystemTables.getComi() ;*
    CUR.AF = EB.SystemTables.getAf()
    EXIST.VALUE = EB.SystemTables.getRNew(CUR.AF)
    EB.SystemTables.setRNew(RP.Contract.Repo.FeeAmt,'')
RETURN
END
