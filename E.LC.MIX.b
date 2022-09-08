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

* Version 3 28/02/01  GLOBUS Release No. G11.2.00 28/03/01
*-----------------------------------------------------------------------------
* <Rating>-18</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.ModelBank

    SUBROUTINE E.LC.MIX

*27/01/01   - GB0100540
*        The extraction of LC ID was not proper which was
*        fixed.
*
* 20/02/07 - BG_100013043
*            CODE.REVIEW changes.
*
* 11/05/07 - CI_10049012
*            Drill down not working for DX transactions.
*
* 31/10/07 - CI_10052347
*            Drill down not working for FACILITY.
*
* 14/04/10 - Defect 39450 / Task 40503
*            Revert the  changes done through CI_10052347.
*            In MC environment, transaction other than in sign on company
*            are not able to view.
*
* 09/12/14 - Task : 1116645 / Enhancement : 990544
* 			 LC Componentization and Incorporation
*
*******************************************************************************
    $USING EB.Reports
    $USING LC.ModelBank


    LCNOS = ''
    LC.ID = EB.Reports.getOData()
    E.TYPE = LC.ID[1,2]
    IF E.TYPE EQ 'TF' THEN
        *GB0100540/GB0100551
        IF LC.ID[13,2] MATCHES '2A' THEN
            IF LC.ID[13,2] EQ 'AC' THEN
                LCNOS = 10    ;* BG_100013043 - S
            END     ;* BG_100013043 - E
            IF LC.ID[13,2] EQ 'SP' THEN
                LCNOS = 10    ;* BG_100013043 - S
            END     ;* BG_100013043 - E
            LCNOS += 12
            XY = LC.ID[LCNOS+1,LEN(EB.Reports.getOData())]
            EB.Reports.setOData(LC.ID[1,12]:XY)
        END
        *GB0100540/GB0100551
    END

    IF E.TYPE EQ 'DX' THEN    ;* CI_10049012
        tmp.O.DATA = EB.Reports.getOData()
        EB.Reports.setOData(FIELD(tmp.O.DATA,'.',1))
    END
    RETURN
    END
