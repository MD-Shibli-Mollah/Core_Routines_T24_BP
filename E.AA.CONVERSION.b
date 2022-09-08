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
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.CONVERSION
*
* Assumpiton
* Fields are delimited by '^'
*
    $USING EB.Reports

*
    REC.VALUE = EB.Reports.getOData()
    EB.Reports.setVmCount(0)
    EB.Reports.setRRecord('')
    FOR LOOP.CNT = 1 TO DCOUNT(REC.VALUE,'^')
        CUR.VALUE = REC.VALUE['^',LOOP.CNT,1]
        tmp=EB.Reports.getRRecord(); tmp<-1>=CUR.VALUE; EB.Reports.setRRecord(tmp)
        IF DCOUNT(CUR.VALUE,@VM) GT EB.Reports.getVmCount() THEN
            EB.Reports.setVmCount(DCOUNT(CUR.VALUE,@VM))
        END
    NEXT LOOP.CNT
*
    RETURN
