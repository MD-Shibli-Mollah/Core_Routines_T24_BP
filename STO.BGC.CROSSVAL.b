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

* Version 7 25/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>28</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.StandingOrders

    SUBROUTINE STO.BGC.CROSSVAL(R.FT.LOCAL.CLEARING,R.FT.BC.PARAMETER)
*
************************************************************************
* Description:                                                         *
* ============                                                         *
*                                                                      *
* Routine to val transactions for the purposes of the BGC interface    *
* The passed parameters are not used in this routine but are passed to *
* keep to standards.                                                   *
*                                                                      *
************************************************************************
* Modification Log:                                                    *
* =================                                                    *
*                                                                      *
* 31/03/98 - GB9800251                                                 *
*            Force check digit if valid account number.                *
*                                                                      *
* 23/09/02 - GLOBUS_EN_10001180
*          Conversion Of all Error Messages to Error Codes
*                                                                      *
* 02/03/04 - CI_10017578
*            Max and min length validation of field BENEFICIARY when txn type is BC done in
*            STANDING.ORDER. Hence checks removed here.
*
* 17/02/07 - BG_100013036
*            CODE.REVIEW changes. 
*
* 09/02/15 - Enhancement 1214535 / Task 1218721
*            Moved the routine from FT to AC. Also included the Package name
*
************************************************************************

    $USING AC.StandingOrders
    $USING EB.ErrorProcessing
    $USING EB.SystemTables
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_F.ACCOUNT.PARAMETER

*
    BEGIN CASE
            *
        CASE EB.SystemTables.getApplication() EQ "STANDING.ORDER"
            EB.SystemTables.setAf(AC.StandingOrders.StandingOrder.StoBenAcctNo)
            GOSUB CHECK.BEN.ACCT
            IF EB.SystemTables.getEtext() THEN
                EB.ErrorProcessing.StoreEndError()
                RETURN
            END
            EB.SystemTables.setAf(AC.StandingOrders.StandingOrder.StoBeneficiary)
            GOSUB CHECK.BEN.CUST
            IF EB.SystemTables.getEtext() THEN
                EB.ErrorProcessing.StoreEndError()
                RETURN
            END
            *
        CASE EB.SystemTables.getApplication() EQ "BULK.STO"
            NO.METHODS = DCOUNT(EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstPayMethod),@VM)
            FOR AV.POS = 1 TO NO.METHODS
                EB.SystemTables.setAv(AV.POS)
                IF EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstPayMethod)[1,2] = "BC" THEN
                    EB.SystemTables.setAf(AC.StandingOrders.BulkSto.BstBeneficAcctno)
                    GOSUB CHECK.BEN.ACCT
                    IF EB.SystemTables.getEtext() THEN
                        EB.ErrorProcessing.StoreEndError()
                        RETURN
                    END
                    EB.SystemTables.setAf(AC.StandingOrders.BulkSto.BstBeneficiary)
                    GOSUB CHECK.BEN.CUST
                    IF EB.SystemTables.getEtext() THEN
                        EB.ErrorProcessing.StoreEndError()
                        RETURN
                    END
                END
            NEXT AV.POS
            *
    END CASE
*
    RETURN          ;* from this program (SUBROUTINE)
*
CHECK.BEN.ACCT:
*
* This GOSUB uses the insert to check for MOD 11 validity of
* the account numbers
*
    AF.POS = EB.SystemTables.getAf()
    IF EB.SystemTables.getRNew(AF.POS) NE '' THEN
        IF LEN(EB.SystemTables.getRNew(AF.POS)) GE '8' AND EB.SystemTables.getRNew(AF.POS)[1,1] NE 'P' THEN
            IF NUM(EB.SystemTables.getRNew(AF.POS)) THEN
                EB.SystemTables.setComi(EB.SystemTables.getRNew(AF.POS))
                *
                * GB9800251s
                RETURN.ERROR = 1
                * GB9800251e
                *
                $INSERT I_CHECK.ACCT.NO
            END ELSE
                EB.SystemTables.setEtext('FT.SBC.INP.NUMERIC')
            END
        END ELSE
            GOSUB CHECK.BENIFIC.ACCT    ;* BG_100013036 - S / E
        END
        *

    END ELSE
        EB.SystemTables.setEtext('FT.SBC.INP.MAND')
    END
*
    RETURN
*
CHECK.BEN.CUST:
*
* CI_10017578 S
*      IF NOT(R.NEW(AF)<1,1>) THEN
*         ETEXT ="FT.SBC.FIRST.LINE.BENEFICARY.DETAILS.REQUIRED"
*         AV = 1
*         RETURN
*      END
*
*      IF R.NEW(STO.BEN.ACCT.NO)[1,1] = 'P' THEN
*      IF NOT(R.NEW(AF)<1,2>) THEN
*         ETEXT ="FT.SBC.SECOND.LINE.BENEFICARY.DETAILS.REQUIRED"
*        AV = 2
*         RETURN
*      END
*     END
*
*      IF LEN(R.NEW(AF)<1,1>) GT 24 THEN
*         ETEXT ="FT.SBC.FIRST.LINE.BEN.CUST.DETAILS.TOO.LONG"
*         AV = 1
*         RETURN
*      END
*
*      IF LEN(R.NEW(AF)<1,2>) GT 20 THEN
*         ETEXT ="FT.SBC.SECOND.LINE.BEN.CUST.DETAILS.TOO.LONG"
*        AV = 2
*         RETURN
*      END
* CI_10017578 E
*
    RETURN          ;* from GOSUB
*
*-----------------------------------------------------------------
* BG_100013036 - S
*==================
CHECK.BENIFIC.ACCT:
*==================
    AF.POS = EB.SystemTables.getAf()
    IF EB.SystemTables.getRNew(AF.POS)[1,1] NE 'P' THEN
        IF NUM(EB.SystemTables.getRNew(AF.POS)) THEN
            EB.SystemTables.setRNew(AF.POS, FMT(EB.SystemTables.getRNew(AF.POS),'9"0"R'))
            EB.SystemTables.setRNew(AF.POS, 'P':EB.SystemTables.getRNew(AF.POS))
        END ELSE
            EB.SystemTables.setEtext('FT.SBC.INP.NUMERIC')
        END
    END ELSE
        TEMP.AF = EB.SystemTables.getRNew(AF.POS)
        CONVERT " " TO "" IN TEMP.AF
        IF TEMP.AF NE EB.SystemTables.getRNew(AF.POS) THEN
            EB.SystemTables.setEtext('FT.SBC.NO.SPACES.ALLOWED')
        END ELSE
            NUM.LEN = LEN(EB.SystemTables.getRNew(AF.POS))-1
            EB.SystemTables.setRNew(AF.POS, EB.SystemTables.getRNew(AF.POS)[2,NUM.LEN])
            EB.SystemTables.setRNew(AF.POS, FMT(EB.SystemTables.getRNew(AF.POS),'9"0"R'))
            EB.SystemTables.setRNew(AF.POS, 'P':EB.SystemTables.getRNew(AF.POS))
        END
    END
    RETURN          ;* * BG_100013036 - E
*-----------------------------------------------------------------
    END
