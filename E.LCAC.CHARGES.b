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

* Version 1 20/10/00  GLOBUS Release No.
*-----------------------------------------------------------------------------
* <Rating>-19</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.ModelBank

    SUBROUTINE E.LCAC.CHARGES

*****************************************************************************
*
* 19/02/07 - BG_100013043
*            CODE.REVIEW changes.
*
* 09/12/14 - Task : 1116645 / Enhancement : 990544
* 			 LC Componentization and Incorporation
*
******************************************************************************
    $USING EB.Reports
    $USING LC.ModelBank
    $USING LC.Foundation
    $USING EB.DataAccess


*// If drawing is input, only corresponding charge will show

    EB.Reports.setRRecord('')
    LCAC.ER = ''
    LCAC.ID = EB.Reports.getId()[1,12]
    LCAC.REC = LC.Foundation.tableAccountBalances(LCAC.ID,LCAC.ER)
    EB.Reports.setRRecord(LCAC.REC)
    IF LEN(EB.Reports.getId()) > 12 THEN
        TF.LISTS = EB.Reports.getRRecord()<LC.Foundation.AccountBalances.LcacTfReference>
        CNT = 0
        LOOP
            CNT += 1
            REMOVE TF.REF FROM TF.LISTS SETTING POS
        WHILE TF.REF:POS DO
            GOSUB DEL.RECORD  ;* BG_100013043 - S / E
        REPEAT
    END
    RETURN
***********************************************************************************
* BG_100013043  - S
DEL.RECORD:
    IF TF.REF # EB.Reports.getId() THEN
        FOR JCNT = 5 TO LC.Foundation.AccountBalances.LcacTfReference
            tmp = EB.Reports.getRRecord()
            DEL tmp<JCNT,CNT>
            tmp.RRECORD = tmp
            EB.Reports.setRRecord(tmp.RRECORD)
        NEXT JCNT
        CNT -= 1
    END
    RETURN
*BG_100013043 - E
***********************************************************************************
    END
