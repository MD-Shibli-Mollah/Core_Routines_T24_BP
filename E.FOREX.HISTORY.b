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

* Version 2 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>99</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FX.Reports
    SUBROUTINE E.FOREX.HISTORY
*
*     FX.ENQ.HISTORY SELECTION
*     ------------------------
*
* 30/12/15 - EN_1226121 / Task 1568411
*			 Incorporation of the routine

    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.Reports

*
    tmp.ID = EB.Reports.getId()
    IF FIELD(tmp.ID,';',2)=1 THEN
        EB.Reports.setId(tmp.ID)
        TEMP.ID=EB.Reports.getId()[1,12]
        EB.Reports.setId(TEMP.ID)
        tmp.ID = EB.Reports.getId()
        EB.DataAccess.Dbr('FOREX':@FM:1:@FM:'.A',tmp.ID,'')
        EB.Reports.setId(tmp.ID)
        IF EB.SystemTables.getEtext()#'' THEN EB.SystemTables.setEtext(''); RETURN        ; * display record
    END
*     don't display records on live file or history versions other than the first
    EB.Reports.setId(''); EB.Reports.setRRecord(''); EB.Reports.setOData('')
    EB.Reports.setVc(EB.Reports.getVc() +1)
    RETURN
    END
