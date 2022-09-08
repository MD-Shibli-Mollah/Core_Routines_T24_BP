* @ValidationCode : Mjo5OTY2OTY5NjY6Q3AxMjUyOjE1NjQ1NzExNjkwOTg6c3JhdmlrdW1hcjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDguMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 Jul 2019 16:36:09
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version n dd/mm/yy  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>45</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CQ.ChqFees
    
    SUBROUTINE VAL.CHG.CODE

*
* 21/09/02 - EN_10001178
*            Conversion of error messages to error codes.
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Fees as ST_ChqFees and include $PACKAGE
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
* 07/11/16 - Task - 1917319
*            Inclusion of $USING statement for Own component in Insert section.
*            Defect - 1916912
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
    $USING CQ.ChqFees
    $USING EB.SystemTables
    $USING EB.ErrorProcessing


* Check for the presence of value in field charge.code

    CNT = DCOUNT(EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgChequeStatus),@VM)
    FOR I = 1 TO CNT
        EB.SystemTables.setAv(I)
        IF EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgChequeStatus)<1,EB.SystemTables.getAv()> NE '' THEN
            SCNT = DCOUNT(EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgChequeStatus)<1,EB.SystemTables.getAv()>,@SM)
            FOR J = 1 TO SCNT
                EB.SystemTables.setAs(J)
                IF EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> EQ '' THEN
                    EB.SystemTables.setEtext("ST.RTN.SHOULD.HAVE.VALUE")
                    EB.SystemTables.setAf(CQ.ChqFees.ChequeCharge.ChequeChgChargeCode)
                    EB.ErrorProcessing.StoreEndError()
                END
            NEXT J
        END
    NEXT I
    RETURN
    END



