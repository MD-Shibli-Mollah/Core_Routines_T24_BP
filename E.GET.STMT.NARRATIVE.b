* @ValidationCode : MjoxMDIwNDA2MzU5OkNwMTI1MjoxNTY4MTEzNDAxNDYyOnN0YW51c2hyZWU6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTA4LjIwMTkwNzIzLTAyNTE6LTE6LTE=
* @ValidationInfo : Timestamp         : 10 Sep 2019 16:33:21
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : stanushree
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.20190723-0251
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-7</Rating>
*-----------------------------------------------------------------------------
* Version 2 28/09/00  GLOBUS Release No. 200508 30/06/05
*     GLOBUS Release No 14.2.0   = 23/09/94
$PACKAGE AC.ModelBank

SUBROUTINE E.GET.STMT.NARRATIVE
*-----------------------------------------------------------------------------
* Subroutine to extract the Stmt narrative when a Stmt.Entry.Id is given
*----------------------------------------------------------------------------*
*Modification Details :                                                      *
******************************************************************************
*
* 13/03/15 - Defect 1273822 / Task 1282047
*            Changes done to display all the mutil-valued narratives.
*
* 30/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 19/07/19 - Enhancement 3106221 / Task 3181541
*            Moving account statement components and tables from ST to Account
*
*************************************************************************

    $USING EB.Reports
    $USING AC.AccountStatement
*************************************************************************
*  Initialise Variables
***************************
*
*
    STMT.ID = EB.Reports.getOData()
*
    NARR = ''
    AC.AccountStatement.GetNarrative(STMT.ID,"",NARR)
    tmp=EB.Reports.getRRecord(); tmp<42>=NARR; EB.Reports.setRRecord(tmp)

    IF NARR NE '' THEN
        EB.Reports.setVmCount(DCOUNT(NARR,@VM))
    END

RETURN
*-----------------------------------------------------------------------------
END
