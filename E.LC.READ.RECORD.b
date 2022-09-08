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

* Version 3 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>-6</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.ModelBank

    SUBROUTINE E.LC.READ.RECORD
*****************************************************************
*MODIFICATION.HISTORY
*****************************************************************
*
* 09/12/14 - Task : 1116645 / Enhancement : 990544
* 			 LC Componentization and Incorporation
*
*****************************************************************************************
    $USING EB.Reports
    $USING LC.ModelBank
    $USING LC.Contract


    ! Subroutine to read the LC or DR record either from the Live
    ! or the Unauth file and load it into R.RECORD

    LC.NO = EB.Reports.getOData()
    IF LEN(LC.NO) = 12 THEN            ; ! It is a LC record
        LC.READ.ERR = ''
        LC.REC = ''
        LC.Contract.LetterOfCreditNau(LC.NO, LC.REC, LC.READ.ERR)
        IF LC.READ.ERR # '' THEN
            LC.REC = LC.Contract.tableLetterOfCredit(LC.NO, LC.READ.ERR)
        END
        EB.Reports.setRRecord(LC.REC)
        EB.Reports.setOData('LC')
    END ELSE                           ; ! It is a DR record
        DR.READ.ERR = ''
        DR.REC = '' ; DR.NO = LC.NO
        LC.Contract.DrawingsNau(DR.NO, DR.REC, DR.READ.ERR)
        IF DR.READ.ERR # '' THEN
            DR.REC = LC.Contract.tableDrawings(DR.NO, DR.READ.ERR)
        END
        EB.Reports.setRRecord(DR.REC)
        EB.Reports.setOData('DR')
    END

    RETURN
    END
