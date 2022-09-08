* @ValidationCode : MTotMTM5NjUwMTY1ODpJU08tODg1OS0xOjE0Nzg2MDg3MjY1ODk6aGFyaWtyaXNobmFuazotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxNjEwLjA=
* @ValidationInfo : Timestamp         : 08 Nov 2016 18:08:46
* @ValidationInfo : Encoding          : ISO-8859-1
* @ValidationInfo : User Name         : harikrishnank
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201610.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-6</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE VAL.JOINT.CARD

**************************************************************
* Field validation Routine
**************************************************************
* 13/12/2010 - New Development
* Purpose    -  Field validation for cross check the Joint holder Option
* Developed By - Abinanthan K B
*
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
    $USING EB.ErrorProcessing

    IF EB.SystemTables.getMessage() EQ 'VAL' THEN
        RETURN
    END

    IF EB.SystemTables.getRNew(AC.ModelBank.AcAccountOpening.AcAccSixFivJointCustomer) EQ '' OR EB.SystemTables.getRNew(AC.ModelBank.AcAccountOpening.AcAccSixFivJointCustomer) EQ 'No' THEN
        IF EB.SystemTables.getComi() EQ 'Yes' THEN
            EB.SystemTables.setAf(AC.ModelBank.AcAccountOpening.AcAccSixFivJointCustomer)
            EB.SystemTables.setE("Cannot choose addon card, If Joint holder is not choosen")
            EB.ErrorProcessing.Err()
        END
    END
    RETURN
*-----------------------------------------------------------------------------
    END
