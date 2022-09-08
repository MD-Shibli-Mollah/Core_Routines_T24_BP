* @ValidationCode : MjoxOTEyMjMzMjk4OkNwMTI1MjoxNTgzOTI4MDk4MTE3OnJ2YXJhZGhhcmFqYW46LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAzLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 11 Mar 2020 17:31:38
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rvaradharajan
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>994</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqFees
SUBROUTINE CHEQUE.CHARGE.BAL.HOLD


*
* 20/09/02 - EN_10001178
*            Conversion of error messages to error codes.
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Fees as ST_ChqFees and include $PACKAGE
*
*12/10/15 -  Enhancement 1265068
*         -  Task 1497940
*		     Changing Dbr to table Read
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
* 31/01/20 - Enhancement 3367949 / Task 3565098
*            Changing reference of routines that have been moved from ST to CG*-----------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING CG.ChargeConfig
    $USING EB.Display
    $USING EB.TransactionControl
    $USING EB.ErrorProcessing
    $USING CQ.ChqFees

*-----------------------------------------------------------------------------

    GOSUB INITIALISE                   ; * Special Initialising

    GOSUB DEFINE.PARAMETERS


    IF LEN(EB.SystemTables.getVFunction()) GT 1 THEN
        GOTO V$EXIT
    END

    EB.Display.MatrixUpdate()


*-----------------------------------------------------------------------------
* Main Program Loop

    LOOP

        EB.TransactionControl.RecordidInput()

    UNTIL EB.SystemTables.getMessage() = 'RET' DO

        V$ERROR = ''

        IF EB.SystemTables.getMessage() = 'NEW FUNCTION' THEN

            GOSUB CHECK.FUNCTION         ; * Special Editing of Function

            IF EB.SystemTables.getVFunction() EQ 'E' OR EB.SystemTables.getVFunction() EQ 'L' THEN
                EB.Display.FunctionDisplay()
                EB.SystemTables.setVFunction('')
            END

        END ELSE

            GOSUB CHECK.ID               ; * Special Editing of ID
            IF V$ERROR THEN GOTO MAIN.REPEAT

            EB.TransactionControl.RecordRead()

            IF EB.SystemTables.getMessage() = 'REPEAT' THEN
                GOTO MAIN.REPEAT
            END

            EB.Display.MatrixAlter()

            GOSUB CHECK.RECORD

            GOSUB PROCESS.DISPLAY        ; * For Display applications

        END

MAIN.REPEAT:
*-----------
    REPEAT

V$EXIT:
*------
RETURN                             ; * From main program
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
*                      S u b r o u t i n e s                                 *
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
PROCESS.DISPLAY:
*---------------

* Display the record fields.

    IF EB.SystemTables.getScreenMode() EQ 'MULTI' THEN
        EB.Display.FieldMultiDisplay()
    END ELSE
        EB.Display.FieldDisplay()
    END

RETURN
*-----------(Process.Display)
*-----------------------------------------------------------------------------



*-----------------------------------------------------------------------------
*                      Special Tailored Subroutines                          *
*-----------------------------------------------------------------------------

CHECK.ID:
*--------
* Validation and changes of the ID entered.  Set ERROR to 1 if in error.


RETURN
*-----------(Check.Id)
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
CHECK.FUNCTION:
*--------------
* Validation of function entered.  Set FUNCTION to null if in error.

    IF INDEX('V', EB.SystemTables.getVFunction(),1) THEN
        EB.SystemTables.setE('ST.RTN.FUNT.NOT.ALLOW.APP.1')
        EB.ErrorProcessing.Err()
        EB.SystemTables.setVFunction('')
    END

RETURN
*-----------(Check.Function)
*-----------------------------------------------------------------------------

INITIALISE:
*----------
* Define often used checkfile variables
*
RETURN
*-----------(Initialise)
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
DEFINE.PARAMETERS: ;* SEE 'I_RULES' FOR DESCRIPTIONS *
*-----------------

    CQ.ChqFees.ChequeChargeBalFieldDefinitions()

RETURN
*-----------(Define.Parameters)
*-----------------------------------------------------------------------------



*-----------------------------------------------------------------------------
CHECK.RECORD:
*------------
    LNGG.POS = EB.SystemTables.getLngg()
    CTR2 = DCOUNT(EB.SystemTables.getRNew(CQ.ChqFees.ChequeChargeBal.CcBalChequeStatus),@VM)
    FOR J.CNT = 1 TO CTR2

        COUNTER1 = DCOUNT(EB.SystemTables.getRNew(CQ.ChqFees.ChequeChargeBal.CcBalChrgCode)<1,J.CNT>,@SM)
        JS.X = 0
        FOR JS.X = 1 TO COUNTER1
            CHG.ID = ''
            CHG.ID = EB.SystemTables.getRNew(CQ.ChqFees.ChequeChargeBal.CcBalChrgCode)<1,J.CNT,JS.X>
            ENRI = '' ; ER = ''
            R.REC = CG.ChargeConfig.FtChargeType.Read(CHG.ID,ER)
            EB.SystemTables.setEtext(ER)
            ENRI = R.REC<CG.ChargeConfig.FtChargeType.FtFivShortDescr,LNGG.POS>
            IF NOT(ENRI) THEN
                ENRI = R.REC<CG.ChargeConfig.FtChargeType.FtFivShortDescr,1>
            END
            IF EB.SystemTables.getEtext() THEN
                ENRI = '' ; ER = ''
                R.REC = CG.ChargeConfig.FtCommissionType.Read(CHG.ID,ER)
                EB.SystemTables.setEtext(ER)
                ENRI = R.REC<CG.ChargeConfig.FtCommissionType.FtFouShortDescr,LNGG.POS>
                IF NOT(ENRI) THEN
                    ENRI = R.REC<CG.ChargeConfig.FtCommissionType.FtFouShortDescr,1>
                END
            END
            GOSUB SET.ENRICH
        NEXT JS.X
        CHG.ID = ''

        COUNTER2 = DCOUNT(EB.SystemTables.getRNew(CQ.ChqFees.ChequeChargeBal.CcBalTaxCode)<1,J.CNT>,@SM)
        JS.X = 0
        FOR JS.X = 1 TO COUNTER2
            TAX.ID = ''
            TAX.ID = EB.SystemTables.getRNew(CQ.ChqFees.ChequeChargeBal.CcBalTaxCode)<1,J.CNT,JS.X>
            ENRI = '' ; ER = ''
            R.REC = CG.ChargeConfig.Tax.Read(TAX.ID,ER)
            EB.SystemTables.setEtext(ER)
            ENRI = R.REC<CG.ChargeConfig.Tax.EbTaxShortDescr,LNGG.POS>
            IF NOT(ENRI) THEN
                ENRI = R.REC<CG.ChargeConfig.Tax.EbTaxShortDescr,1>
            END
            GOSUB SET.ENRICH
        NEXT JS.X
    NEXT J.CNT

RETURN
*-----------(Check.Record)
*-----------------------------------------------------------------------------


*-----------------------------------------------------------------------------
SET.ENRICH:
*----------
    BEGIN CASE
        CASE CHG.ID NE ''
            FLD = CQ.ChqFees.ChequeChargeBal.CcBalChrgCode:".":J.CNT:".":JS.X
        CASE TAX.ID NE ''
            FLD = CQ.ChqFees.ChequeChargeBal.CcBalTaxCode:".":J.CNT:".":JS.X
    END CASE
    LOCATE FLD IN EB.SystemTables.getTFieldno()<1> SETTING J ELSE GOTO SET.ENRICH.EXIT

    tmp=EB.SystemTables.getTEnri(); tmp<J,-1>=ENRI; EB.SystemTables.setTEnri(tmp)
*
SET.ENRICH.EXIT:
*---------------

RETURN
*-----------(Set.Enrich)
*-----------------------------------------------------------------------------


END
