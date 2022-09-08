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
* Version 2 02/06/00  GLOBUS Release No. 200508 30/06/05
*
    $PACKAGE SC.SccReports
    SUBROUTINE E.ENTITLEMENT.FILL
*
* This subroutine, called from the Enquiry ENTL.FULL.ENQ will return
* an Entitlement record for each Entitlement ID passed to it.
* The entitlement record could be on the live or unauthorised files.
*
* 19/1/16 - 1322379
*           Incorporation
***************************************************************************************************

    $USING SC.SccEntitlements
    $USING EB.SystemTables
    $USING EB.Reports


*
    ENT.ID = EB.Reports.getOData()
    ENT.REC = ''
*
    EB.SystemTables.setEtext('')
    tmp.ETEXT = EB.SystemTables.getEtext()
    ENT.REC = SC.SccEntitlements.Entitlement.ReadNau(ENT.ID, tmp.ETEXT)
* Before incorporation : CALL F.READ('F.ENTITLEMENT$NAU',ENT.ID,ENT.REC,F.ENTITLEMENT$NAU,tmp.ETEXT)
    EB.SystemTables.setEtext(tmp.ETEXT)
    IF EB.SystemTables.getEtext() THEN
        EB.SystemTables.setEtext('')
        tmp.ETEXT = EB.SystemTables.getEtext()
        ENT.REC = SC.SccEntitlements.Entitlement.Read(ENT.ID, tmp.ETEXT)
        * Before incorporation : CALL F.READ('F.ENTITLEMENT',ENT.ID,ENT.REC,F.ENTITLEMENT,tmp.ETEXT)
        EB.SystemTables.setEtext(tmp.ETEXT)
    END
*
    EB.Reports.setRRecord(ENT.REC)
*
    RETURN                             ; * To Enquiry
*
    END
