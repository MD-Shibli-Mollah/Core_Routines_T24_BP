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

    $PACKAGE FD.Reports
*-----------------------------------------------------------------------------
* <Rating>-35</Rating>
*-----------------------------------------------------------------------------
* Version 4 29/05/01  GLOBUS Release No. G12.0.00 29/06/01
*
* Modifications
* -------------
*
* 29/03/00 - GB0000612
*            jBASE changes.
*           (1) R.RECORD  is a Dynamic array , it is changed to Dynamic array
*               where ever it is used as Dimensioned array.
*           (2) Illegal syntax of Dynamic array used in the variable
*               R.RECORD
    SUBROUTINE E.FD.DEALER.REC
*
** This routine will extract the fiduciary record from either the
** live or unauthorised fiduciary record.
*
** Input : O.DATA ;*Key to the record
*
** Output: R.RECORD
**         O.DATA : Status of the contract ie new, inc, reimburse, dec
**              <2> : Number of orders
*
*
* 10/09/96 - GB9601219
*            Modifications to allow notice orders to be pooled.
*
* 22/05/08 - BG_100018526
*            Reducing the compiler rating
*
* 15/5/15 - 1322379
*           Incorporation of components
*

    $USING EB.Reports
    $USING FD.Contract

    FID.KEY = EB.Reports.getOData()
    EB.Reports.setRRecord(""); YERR = ""
    tmp.R.RECORD = EB.Reports.getRRecord()
    tmp.R.RECORD = FD.Contract.Fiduciary.ReadNau(FID.KEY, YERR)
* Before incorporation : CALL F.READ("F.FD.FIDUCIARY$NAU", FID.KEY, tmp.R.RECORD, F.FD.FIDUCIARY$NAU, YERR)
    EB.Reports.setRRecord(tmp.R.RECORD)
    IF YERR THEN
        tmp.R.RECORD = EB.Reports.getRRecord()
        tmp.R.RECORD = FD.Contract.Fiduciary.Read(FID.KEY, "")
        * Before incorporation : CALL F.READ("F.FD.FIDUCIARY", FID.KEY, tmp.R.RECORD, F.FD.FIDUCIARY, "")
        EB.Reports.setRRecord(tmp.R.RECORD)
    END
*
** Check the status of the action to be approved. This can be NEW, or a
** combination of Increase, Decrease or Reimbursement
*
    EB.Reports.setOData("  ")
    IF EB.Reports.getRRecord()<FD.Contract.Fiduciary.CurrNo> LT 1 THEN
        EB.Reports.setOData("NW")
    END ELSE
        IF EB.Reports.getRRecord()<FD.Contract.Fiduciary.ReimburseStatus> = "REQUESTED" THEN
            EB.Reports.setOData("M");* Mature
        END
        YI = 1 ; CHANGE.AMT = ""
        GOSUB CHANGE.AMOUNT     ;* BG_100018526 S/E
        IF CHANGE.AMT THEN
            IF CHANGE.AMT LT 0 THEN
                EB.Reports.setOData("-")
            END ELSE
                EB.Reports.setOData("+")
            END
        END
        *
    END
*
    EB.Reports.setOData("*":DCOUNT(EB.Reports.getRRecord()<FD.Contract.Fiduciary.OrderNos>,@VM))
*
    RETURN
*
******************************************************************
*
CHANGE.AMOUNT:
**************

    LOOP
        *
        * Loop through each of the date multi values
        *
    WHILE EB.Reports.getRRecord()<FD.Contract.Fiduciary.ChangeDate,YI>
        ORDER.COUNT = DCOUNT(EB.Reports.getRRecord()<FD.Contract.Fiduciary.OrderId,YI>, @SM)  ;*GB0000612
        FOR XI = 1 TO ORDER.COUNT
            IF EB.Reports.getRRecord()<FD.Contract.Fiduciary.ChngStatus,YI, XI> = "REQUESTED" THEN
                CHANGE.AMT += EB.Reports.getRRecord()<FD.Contract.Fiduciary.PrinChange,YI, XI>
            END
        NEXT XI
        YI += 1
    REPEAT
    RETURN

    END
