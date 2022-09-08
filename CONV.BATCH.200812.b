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
* <Rating>-105</Rating>
*-----------------------------------------------------------------------------
* Version 3 02/06/00  GLOBUS Release No. G11.0.00 29/06/00
    $PACKAGE IC.InterestAndCapitalisation
    SUBROUTINE CONV.BATCH.200812
*-----------------------------------------------------------------------------
* Program Description
*
* Remove the job PRINT.CUST.INT.REPORTS / PRINT.INT.STMT.AND.ADV
* from the AC.REPORTS record.
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 28/08/08 - EN_10003793
*            Performance imporovements for PRINT.INT.STMT.AND.ADV.
*
* 12/12/08 - BG_100021277
*            F.READ, F.WRITE, F.DELETE and F.RELEASE are changed to READ, WRITE,
*            DELETE and RELEASE respectively.
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DAS.COMMON
    $INSERT I_F.COMPANY
*-----------------------------------------------------------------------------

* Initialise
    GOSUB INITIALISE

* Select companies
    GOSUB SELECT.COMPANIES

* Process companies
    GOSUB PROCESS.COMPANIES

    RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise </desc>

    FN.COMPANY = "F.COMPANY"
    F.COMPANY = ""
    CALL OPF(FN.COMPANY, F.COMPANY)

    FN.BATCH = "F.BATCH"
    F.BATCH = ""
    CALL OPF(FN.BATCH, F.BATCH)

    RETURN

*** </region>

*-----------------------------------------------------------------------------

*** <region name= SELECT.COMPANIES>
SELECT.COMPANIES:
*** <desc>Select companies </desc>

    COMPANIES.LIST = dasAllIds
    CALL DAS("COMPANY", COMPANIES.LIST, "", "")

    RETURN

*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS.COMPANIES>
PROCESS.COMPANIES:
*** <desc>Process companies </desc>

    LOOP
        REMOVE ID.CONV.COMPANY FROM COMPANIES.LIST SETTING MARK
    WHILE ID.CONV.COMPANY : MARK DO
* Process company
        GOSUB PROCESS.COMPANY
    REPEAT

    RETURN

*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS.COMPANY>
PROCESS.COMPANY:
*** <desc>Process company </desc>

* Read company record
    GOSUB READ.COMPANY.RECORD

* Read batch record
    GOSUB READ.BATCH.RECORD

* If batch record exists...
    IF NOT(ERR) THEN
* Remove job
        GOSUB REMOVE.JOB

* Write batch record
        GOSUB WRITE.BATCH.RECORD
    END

    RETURN

*** </region>

*-----------------------------------------------------------------------------

*** <region name= READ.COMPANY.RECORD>
READ.COMPANY.RECORD:
*** <desc>Read company record </desc>

    R.CONV.COMPANY = ""
    READ R.CONV.COMPANY FROM F.COMPANY, ID.CONV.COMPANY ELSE
        R.CONV.COMPANY = ""
    END

    RETURN

*** </region>

*-----------------------------------------------------------------------------

*** <region name= READ.BATCH.RECORD>
READ.BATCH.RECORD:
*** <desc>Read batch record </desc>

    ID.BATCH = R.CONV.COMPANY<EB.COM.MNEMONIC> : "/AC.REPORTS"
    ERR = 0
    R.BATCH = ""
    READU R.BATCH FROM F.BATCH, ID.BATCH ELSE
        ERR = 1
    END

    RETURN

*** </region>

*-----------------------------------------------------------------------------

*** <region name= REMOVE.JOB>
REMOVE.JOB:
*** <desc>Remove job </desc>

    LOCATE "PRINT.CUST.INT.REPORTS" IN R.BATCH<6, 1> SETTING JOB.POS THEN
        FOR FIELD.NO = 6 TO 15
            DEL R.BATCH<FIELD.NO, JOB.POS>
        NEXT FIELD.NO
    END

    RETURN

*** </region>

*-----------------------------------------------------------------------------

*** <region name= WRITE.BATCH.RECORD>
WRITE.BATCH.RECORD:
*** <desc>Write batch record </desc>

    WRITE R.BATCH TO F.BATCH, ID.BATCH

    RETURN

*** </region>

END
