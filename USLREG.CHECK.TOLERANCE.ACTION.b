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
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE USLREG.Foundation
    SUBROUTINE USLREG.CHECK.TOLERANCE.ACTION
* ----------------------------------------------------------------------------
*Company   Name    : USMB
*Developed By      : cmadhan@temenos.com
*--------------------------------------------------------------------------------
* Description   : To validate the tolerance action field under overdue property class.
* Type          : Validation Routine.
* Linked With   : N/A
* In Parameter  : N/A
* Out Parameter : N/A
* -------------------------------------------------------------------------------
* Modification History :
*-----------------------
* 11/05/14 - Defect - 1171180
*            Task   - 1172076
*            Initial routine creation to validate the tolerance action.
**
*17-MAR-2016 - Enhancement - 1504339
*            - Task - 1664583
*            - US Feature Encapsulation
*--------------------------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Inserts used in the sub-routine</desc>

    $USING EB.SystemTables
    $USING AA.Overdue
    $USING EB.ErrorProcessing

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process Logic>
*** <desc>Program Control</desc>

    GOSUB INITIALISE
    GOSUB TOLERANCE.VALIDATE   ;* Validate for tolerance actions
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>

INITIALISE:

    PAY.TOLERANCE = ''
    TOL.CCY = ''
    TOL.AMOUNT = ''
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Tolerance validate>
*** <desc>Validate the action fields under overdue property</desc>

TOLERANCE.VALIDATE:
    TEMP.VALUE = EB.SystemTables.getRNew(AA.Overdue.Overdue.OdBillType)
    MV.COUNT = DCOUNT(TEMP.VALUE, @VM)  ;* Get the count of bill type.
    FOR BILL.TYPE.POS = 1 TO MV.COUNT
        EB.SystemTables.setAv(BILL.TYPE.POS)
            PAY.TOLERANCE = EB.SystemTables.getRNew(AA.Overdue.Overdue.OdPayTolerance)<1,BILL.TYPE.POS>
            TOL.CCY = EB.SystemTables.getRNew(AA.Overdue.Overdue.OdTolCcy)<1,BILL.TYPE.POS,1>
            TOL.AMOUNT = EB.SystemTables.getRNew(AA.Overdue.Overdue.OdTolAmount)<1,BILL.TYPE.POS,1>
            IF PAY.TOLERANCE NE '' OR  TOL.CCY NE '' OR  TOL.AMOUNT  NE '' THEN   ;* If either of the pay tolerance fields are set, and bill type is not set throw error.
                IF EB.SystemTables.getRNew(AA.Overdue.Overdue.OdTolAction)<1,BILL.TYPE.POS> NE "REMAIN" THEN
                    EB.SystemTables.setAf(AA.Overdue.Overdue.OdTolAction)
                    EB.SystemTables.setEtext("AA-AA.OD.SHD.DEF.TOL.ACT.FOR.PAY.TOL")
                    EB.ErrorProcessing.StoreEndError()
                END
            END
    NEXT BILL.TYPE.POS

    RETURN
*** </region>
*-----------------------------------------------------------------------------
END
