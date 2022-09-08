* @ValidationCode : MjotMTE5MzY1NDEyNjpDcDEyNTI6MTYwODIxMzE5ODA2NDpzY2hhbmRpbmk6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMi4xOjE1OjE1
* @ValidationInfo : Timestamp         : 17 Dec 2020 19:23:18
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : schandini
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 15/15 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE T4.ModelBank
SUBROUTINE V.TC.BULK.ITEM.TXN.TYPE
*-----------------------------------------------------------------------------
* This routine is attached to the version FT.BULK.ITEM,TCIB.UPLOAD to update
* transaction type while creating bulk item
*------------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Changes done in the sub-routine </desc>
* Modification history:
*-----------------------
* 24/05/16 - Defect 1906605 / Task 1914616
*            Populate the transaction type field
*
* 08/12/2020 - Enhancement 4020994 / Task 4037076
*              Changing BY.Payments reference to new component reference BY.Payments since
*              beneficiary and beneficiary links table has been moved to new module BY.
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>

    $USING FT.Clearing
    $USING EB.SystemTables
    $USING BY.Payments
    $USING EB.ErrorProcessing

    GOSUB INITIALISE
    GOSUB PROCESS
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise parameters required</desc>
INITIALISE:
*----------
    TXN.TYPE = ''
    BENEFICIARY.ID = ''
    R.BENEFICIARY = ''

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Populate the transaction type field to input bulk item</desc>
PROCESS:
*------
    BENEFICIARY.ID = EB.SystemTables.getRNew(FT.Clearing.BulkItem.BlkItBeneficiaryId)
    IF BENEFICIARY.ID THEN
        R.BENEFICIARY = BY.Payments.Beneficiary.Read(BENEFICIARY.ID, Error)
        TXN.TYPE = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenTransactionType>
    END ELSE
        TXN.TYPE = 'AC'
    END
    EB.SystemTables.setRNew(FT.Clearing.BulkItem.BlkItTransactionType, TXN.TYPE)
RETURN
*** </region>
*----------------------------------------------------------------------------
END
