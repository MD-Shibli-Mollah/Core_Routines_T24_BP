* @ValidationCode : MjotMTIwNTg4OTc4MjpDcDEyNTI6MTYxNDMyMjE0MTc0ODpzdmFtc2lrcmlzaG5hOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMS4yMDIwMTAyOS0xNzU0Oi0xOi0x
* @ValidationInfo : Timestamp         : 26 Feb 2021 12:19:01
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : svamsikrishna
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE QI.Reporting
SUBROUTINE QI.GET.EXEM.RECP.CODES(CONTRACT.ID,USDB.REC,CUSTOMER.ID,RESERVED,OUT.EXEM.CODES,OUT.RECP.CODES,RES.OUT.1,ERROR.INFO)
*-----------------------------------------------------------------------------
*API to fetch the exemption and recepient codes
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 24/02/2021 - En 4240470 / Task 4240473
*              API to fetch the exemption and recepient codes
*
*-----------------------------------------------------------------------------
    $USING QI.Reporting
    
    GOSUB INITIALISE ; *
    GOSUB PROCESS ; *
RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>
    IF CONTRACT.ID[1,6] EQ "SCADTX" ELSE
        CUSTOMER.ID = FIELD(CONTRACT.ID,"*",1);*customer id is passed
    END
    EXEMP.CODE.CHAP.FOUR = ""
    RECP.CODE.CHAP.THREE = ""
    EXEMP.CODE.CHAP.THREE = ""
    RECP.CODE.CHAP.FOUR = ""
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    IF CONTRACT.ID[1,6] EQ "SCADTX" THEN
        GOSUB PROCESS.FOR.ADJ ; *
    END ELSE
        GOSUB PROCESS.FOR.ENT ; *
    END

    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS.FOR.ADJ>
PROCESS.FOR.ADJ:
*** <desc> </desc>
    TOT.RVCNT = DCOUNT(USDB.REC<QI.Reporting.QiUsDbTxDetails.RevReferenceId>,@VM) ;*get the total reference Id
    INCOME.CODES = USDB.REC<QI.Reporting.QiUsDbTxDetails.RevIncomeCode,TOT.RVCNT>
    TOT.IC.CNT = DCOUNT(INCOME.CODES,@SM)
    
    FOR IC.CNT = 1 TO TOT.IC.CNT
        EXEMP.AND.RECP.CODES = ""
        QI.Reporting.QIGetExempCodesForIcCodes(USDB.REC<QI.Reporting.QiUsDbTxDetails.RevQiStatusTxn,TOT.RVCNT,IC.CNT>, USDB.REC<QI.Reporting.QiUsDbTxDetails.RevIncomeCode,TOT.RVCNT,IC.CNT>, CUSTOMER.ID, "",EXEMP.AND.RECP.CODES, "", "", "")
        EXEMP.CODE.CHAP.FOUR<1,IC.CNT> = EXEMP.AND.RECP.CODES<1>
        RECP.CODE.CHAP.THREE<1,IC.CNT> = EXEMP.AND.RECP.CODES<2>
        EXEMP.CODE.CHAP.THREE<1,IC.CNT> = EXEMP.AND.RECP.CODES<3>
        RECP.CODE.CHAP.FOUR<1,IC.CNT> = EXEMP.AND.RECP.CODES<4>
    NEXT IC.CNT
    OUT.EXEM.CODES = EXEMP.CODE.CHAP.THREE:"*":EXEMP.CODE.CHAP.FOUR
    OUT.RECP.CODES = RECP.CODE.CHAP.THREE:"*":RECP.CODE.CHAP.FOUR
    CONVERT @VM TO "!" IN OUT.EXEM.CODES
    CONVERT @VM TO "!" IN OUT.RECP.CODES
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS.FOR.ENT>
PROCESS.FOR.ENT:
*** <desc> </desc>
    TOT.IC.CNT = DCOUNT(USDB.REC<QI.Reporting.QiUsDbTxDetails.IncomeCode>,@VM)
    
    FOR IC.CNT = 1 TO TOT.IC.CNT
        EXEMP.AND.RECP.CODES = ""
        QI.Reporting.QIGetExempCodesForIcCodes(USDB.REC<QI.Reporting.QiUsDbTxDetails.QiStatusTxn,IC.CNT>, USDB.REC<QI.Reporting.QiUsDbTxDetails.IncomeCode,IC.CNT>, CUSTOMER.ID, "",EXEMP.AND.RECP.CODES, "", "", "")
        EXEMP.CODE.CHAP.FOUR<1,IC.CNT> = EXEMP.AND.RECP.CODES<1>
        RECP.CODE.CHAP.THREE<1,IC.CNT> = EXEMP.AND.RECP.CODES<2>
        EXEMP.CODE.CHAP.THREE<1,IC.CNT> = EXEMP.AND.RECP.CODES<3>
        RECP.CODE.CHAP.FOUR<1,IC.CNT> = EXEMP.AND.RECP.CODES<4>
    NEXT IC.CNT
    
    OUT.EXEM.CODES = EXEMP.CODE.CHAP.THREE:"*":EXEMP.CODE.CHAP.FOUR
    OUT.RECP.CODES = RECP.CODE.CHAP.THREE:"*":RECP.CODE.CHAP.FOUR
    CONVERT @VM TO "~" IN OUT.EXEM.CODES
    CONVERT @VM TO "~" IN OUT.RECP.CODES
RETURN
*** </region>

END


