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
* <Rating>-6</Rating>
*-----------------------------------------------------------------------------
* Version 2 02/06/00  GLOBUS Release No. 200508 30/06/05
*
    $PACKAGE SC.ScoReports
    SUBROUTINE E.CHECK.TRANS.TYPE
*
* Routine to take input of a SC.TRANS.NAME ID and return whether it
* is a CREDIT or a DEBIT for Enquiries.
*
* 22/6/15 - 1322379
*           Incorporation of components
*
    $USING EB.Reports
    $USING SC.Config
    $USING EB.SystemTables
    

*
*
    K.SC.TRANS.NAME = EB.Reports.getOData()
    R.SC.TRA.CODE = ''
    EB.SystemTables.setEtext('')
    tmp.ETEXT = EB.SystemTables.getEtext()
    R.SC.TRA.CODE = SC.Config.ScTraCode.Read(K.SC.TRANS.NAME, tmp.ETEXT)
    EB.SystemTables.setEtext(tmp.ETEXT)
* Before incorporation : CALL F.READ('F.SC.TRA.CODE',K.SC.TRANS.NAME,R.SC.TRA.CODE,F.SC.TRA.CODE,ETEXT)
    IF EB.SystemTables.getEtext() ELSE
        K.SC.TRANS.TYPE = R.SC.TRA.CODE<1>
        R.SC.TRANS.TYPE = ''
        tmp.ETEXT = EB.SystemTables.getEtext()
        R.SC.TRANS.TYPE = SC.Config.TransType.Read(K.SC.TRANS.TYPE, tmp.ETEXT)
        EB.SystemTables.setEtext(tmp.ETEXT)
        * Before incorporation : CALL F.READ('F.SC.TRANS.TYPE',K.SC.TRANS.TYPE,R.SC.TRANS.TYPE,F.SC.TRANS.TYPE,ETEXT)
        IF EB.SystemTables.getEtext() ELSE
            IF K.SC.TRANS.NAME = R.SC.TRANS.TYPE<SC.Config.TransType.TrnSecurityDrCode> THEN
                EB.Reports.setOData("DEBIT")
            END
            IF K.SC.TRANS.NAME = R.SC.TRANS.TYPE<SC.Config.TransType.TrnSecurityCrCode> THEN
                EB.Reports.setOData("CREDIT")
            END
        END
    END
*
    RETURN
*
    END
