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

* Version 4 22/05/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-13</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoReports
    SUBROUTINE E.VAL.SEC.ACC
*
************************************************************
*
*    SUBROUTINE TO CALL IN2CUS TO CONVERT SECURITY NUMBER
*
* 24-07-2015 - 1415959
*             Incorporation of components
*
* 13/08/15 - DEFECT:1436944 TASK:1437051
*            TAFC compilation error
************************************************************

    $USING SC.ScoPortfolioMaintenance
    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.DataAccess

*
*
    IF INDEX(EB.Reports.getOData(),'-',1) THEN

        *         COMI = FIELD(O.DATA,'-',1)
        *         PORT.SEQ = FIELD(O.DATA,'-',2)
    END ELSE
        EB.SystemTables.setComi(EB.Reports.getOData())
        ENRIX = ''
        EB.DataAccess.Dbr("SEC.ACC.CUST":@FM:SC.ScoPortfolioMaintenance.SecAccMaster.ScSamCustomerNumber:@FM:"..S",EB.SystemTables.getComi(),ENRIX)

        *O.DATA = ENRIX

        tmp.ETEXT = EB.SystemTables.getEtext()
        IF NOT(tmp.ETEXT) THEN
            EB.Reports.setOData(ENRIX)
        END ELSE
            EB.Reports.setOData(EB.SystemTables.getComi())
        END
        EB.SystemTables.setEtext(tmp.ETEXT)
        PORT.SEQ = '1'
    END
*      CALL IN2CUS(10,"CUS")
*      IF NOT(ETEXT) THEN
*         O.DATA = COMI:'-':PORT.SEQ
*         O.DATA = ENRIX
*      END ELSE ETEXT = ''
*
    EB.SystemTables.setEtext('')
    RETURN
*
    END
