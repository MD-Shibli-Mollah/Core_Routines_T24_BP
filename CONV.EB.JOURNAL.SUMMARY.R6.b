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
* <Rating>90</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RE.ReportGeneration
    SUBROUTINE CONV.EB.JOURNAL.SUMMARY.R6
*
* 08/02/08 - BG_10001703
*            Trigger REBUILD.GROUP.ACCOUNT
*
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
    F.COMPANY = ''
    CALL OPF("F.COMPANY",F.COMPANY)
    SELECT F.COMPANY
    LOOP
        READNEXT CO.ID ELSE CO.ID = ''
    WHILE CO.ID
        READ CO.REC FROM F.COMPANY,CO.ID THEN
            IF CO.REC<64> = CO.ID THEN
                CONV.WRK = "JNLSUMMARY"
                F.AC.CONV.ENTRY = '' ; FN.AC.CONV.ENTRY = 'F':CO.REC<3>:".AC.CONV.ENTRY"
                CALL OPF(FN.AC.CONV.ENTRY,F.AC.CONV.ENTRY)
                WRITE "" TO F.AC.CONV.ENTRY,CONV.WRK
                CONV.WRK = 'REBUILD.GROUP.ACCOUNT'
                WRITE "" TO F.AC.CONV.ENTRY,CONV.WRK
            END
        END
    REPEAT
*
    RETURN
*
END
