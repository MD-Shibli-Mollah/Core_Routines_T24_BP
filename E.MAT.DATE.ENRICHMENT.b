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
* <Rating>-3</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.MAT.DATE.ENRICHMENT
*********************************
* This subroutine is called from enquiry to return the
* remaining term
*

    $USING AA.Framework
    $USING EB.API
    $USING EB.SystemTables
    $USING EB.Reports

*
    CMP.DATE = EB.SystemTables.getToday()
    IF EB.Reports.getEnqSimRef() THEN
        SIM.REF = EB.Reports.getEnqSimRef()
        R.SIM = ''
        R.SIM = AA.Framework.SimulationRunner.Read(SIM.REF, RET.ERR)
        CMP.DATE = R.SIM<AA.Framework.SimulationRunner.SimSimEndDate>
    END
*
    MAT.DATE = EB.Reports.getOData()
    TEXT.ENRI = ''
    EB.API.MatDateEnrichment(MAT.DATE,CMP.DATE,TEXT.ENRI)   ;*Get the enrichment as remaining term
    EB.Reports.setOData(TEXT.ENRI)

    RETURN
