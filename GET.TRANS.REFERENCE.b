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

*------------------------------------------------------------------------------
* <Rating>-8</Rating>
*------------------------------------------------------------------------------
    $PACKAGE T2.ModelBank
    SUBROUTINE GET.TRANS.REFERENCE
*-----------------------------------------------------------------------------
* Description: Conversion Routine attached in enquiry TCIB.TXNS.TODAY.LIST
* to format the transaction reference if the length of
* reference is greater than 35 characters
*-----------------------------------------------------------------------------
* Modification History:
*---------------------
* 27/12/13 - Enhancement 590517
*            TCIB Retail
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*			 Incorporation of T components
*-----------------------------------------------------------------------------

    $USING EB.Reports

    TRANS.REF = EB.Reports.getOData()
    IF LEN(TRANS.REF) GT 35 THEN
        STMT.TRANS.REFERENCE = ''
        REF.INDEX = 0
        REF.LENGTH.CNT = DIV(LEN(TRANS.REF),35)
        REF.INDEX = INDEX(REF.LENGTH.CNT,".",1)
        IF REF.INDEX THEN
            REF.LENGTH.CNT = REF.LENGTH.CNT[1,REF.INDEX] + 1
        END
        FOR REF = 1 TO REF.LENGTH.CNT
            STMT.TRANS.REFERENCE := TRANS.REF[1,35]:" "
            TRANS.REF = TRANS.REF[36,LEN(TRANS.REF)]
        NEXT REF
        EB.Reports.setOData(STMT.TRANS.REFERENCE)
    END ELSE
        EB.Reports.setOData(TRANS.REF)
    END
    RETURN
    END
