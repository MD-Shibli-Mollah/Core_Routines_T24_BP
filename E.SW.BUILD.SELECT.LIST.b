* @ValidationCode : MjoxOTczODY4MTMxOkNwMTI1MjoxNTEwMDUyMzc0MDY4OmhhcnJzaGVldHRncjoyOjA6LTM6MTpmYWxzZTpOL0E6REVWXzIwMTcwNi4wOjIyOjE3
* @ValidationInfo : Timestamp         : 07 Nov 2017 16:29:34
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : harrsheettgr
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : -3
* @ValidationInfo : Coverage          : 17/22 (77.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201706.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 3 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>-4</Rating>
*-----------------------------------------------------------------------------
$PACKAGE SW.Reports
SUBROUTINE E.SW.BUILD.SELECT.LIST(ENQUIRY.DATA)
*-----------------------------------------------------------------------------
    $USING EB.TransactionControl
    $USING EB.SystemTables
    $USING EB.Reports

*                                                                       *
*************************************************************************
*                                                                       *
*  Modifications  :                                                      *
*                                                                       *
* 12/10/98 - GB9801254
*            Special check to allow id's starting with SW00000 thorough
*            this is required for EEC.
*
* 21/09/02 - EN_10001188
*            Conversion of error messages to error codes.
*
* 27/01/03 - BG_100003266
*            In some cases, 'IF' condition with Error Codes does not
*            working properly. Changed back Error Code to Error Message.
*
* 20/01/06 - CI_10038313
*            "Too Many Characters" error in the enquiry SWAP.SCHED.RR
*
* 23/09/08 - BG_100020085
*            Rating Reduction for SWAP routines.
*
* 30/12/15 - Enhancement 1226121
*          - Task 1569212
*          - Routine incorporated
*
* 16/03/17 - Defect 2052705 / Task 2055091
*            "INVALID SWAP CONTRACT ID" error is displayed while running the SWAP.SCHEDULE enquiry
*
* 08/09/17 - Defect 2261582 / Task 2264062
*            Error encountered while accessing enquiry SWAP.SCHEDULE through context enquiries.
*
*************************************************************************
*
*
* select on contract number only
*
    SAVE.ID.N = EB.SystemTables.getIdN()
    SAVE.ID.NEW = EB.SystemTables.getIdNew()
    EB.SystemTables.setIdN("30")
    NO.OF.IDS = DCOUNT(ENQUIRY.DATA<4>,@VM)
    FOR ID.IDX = 1 TO NO.OF.IDS
        EB.SystemTables.setIdNew(ENQUIRY.DATA<4,ID.IDX>)
        ID.NEW.VAL = EB.SystemTables.getIdNew()
        IF ID.NEW.VAL = "ALL" THEN
            EB.Reports.setEnqError("ONLY SWAP CONTRACT ID ALLOWED")
            EXIT    ;* this loop
        END ELSE
            IF (LEN(ID.NEW.VAL) > 12)  THEN
                EB.SystemTables.setE("SW.RTN.INVALID.SWAP.CONTR.ID")
                EB.Reports.setEnqError(EB.SystemTables.getE())
                EXIT          ;* this loop
            END
            ENQUIRY.DATA<4,ID.IDX> = ID.NEW.VAL       ;* populate formatted id
        END
    NEXT ID.IDX
    EB.SystemTables.setIdNew(SAVE.ID.NEW)
    EB.SystemTables.setIdN(SAVE.ID.N)
RETURN
END
