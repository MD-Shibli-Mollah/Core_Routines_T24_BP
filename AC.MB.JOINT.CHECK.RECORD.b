* @ValidationCode : MTotMjAxODUzNzA2MTpJU08tODg1OS0xOjE0Nzg2MDg3NzQ3Nzg6aGFyaWtyaXNobmFuazotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxNjEwLjA=
* @ValidationInfo : Timestamp         : 08 Nov 2016 18:09:34
* @ValidationInfo : Encoding          : ISO-8859-1
* @ValidationInfo : User Name         : harikrishnank
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201610.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version n dd/mm/yy  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>-5</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE AC.MB.JOINT.CHECK.RECORD
**************************************************************
* Add joint card
**************************************************************
* 15/12/2010 - New Development
* Purpose: To Initialise Fields
*
* 07/05/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 07/11/16 - Task - 1918047
*            Inclusion of $USING statement for Own component in Insert section.
*            Defect - 1916912
*   
**************************************************************
    $USING AC.ModelBank
    $USING EB.SystemTables

    EB.SystemTables.setRNew(AC.ModelBank.AcAccountOpening.AcAccSixFivAddJointHolder, '')
    EB.SystemTables.setRNew(AC.ModelBank.AcAccountOpening.AcAccSixFivAddRelation, '')
    RETURN
*-----------------------------------------------------------------------------
    END
