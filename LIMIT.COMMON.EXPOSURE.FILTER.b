* @ValidationCode : MjoxNzA0OTYxNzIyOmNwMTI1MjoxNTE0NTQ3NDAzNTUyOnBibGFpcjotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxODAxLjIwMTcxMjE2LTE1NTU6LTE6LTE=
* @ValidationInfo : Timestamp         : 29 Dec 2017 11:36:43
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : pblair
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201801.20171216-1555
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
**************************************************************
* Routine to filter out the internal accounts
*
**************************************************************
* MODIFICATIONS
*
* 28/10/14 - Defect 1135569 / Task 1151441
*            Performance issue:LIMIT.COMMON.EXPOSURE job takes more time
*            So, FILTER routine has been introduced for processing only the customer and nostro accounts
*
* 03/11/17 - Enhancement 2205157 / Task 2329866
*            Skip processing of new format LIMIT IDs as a temporary fix to get the Regression COB to complete.
*
* 23/11/17 - EN 2232358 / Task 2232361
*            Updated code to handle new format LIMIT ID
*
**************************************************************
$PACKAGE LI.Reports
SUBROUTINE LIMIT.COMMON.EXPOSURE.FILTER(ACCT.ID)

    $USING AC.AccountOpening
    $USING EB.Service

    INT.ACC = ''
    AC.AccountOpening.IntAcc(ACCT.ID,INT.ACC)
    IF INT.ACC THEN       ;*Filter internal accounts
        ACCT.ID = ''
    END
    
RETURN

END
