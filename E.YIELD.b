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
* <Rating>-4</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoReports
    SUBROUTINE E.YIELD
*************************************************************************
*
* Return the yield for the yield enquiry
* 24-07-2015 - 1415959
*             Incorporation of components
*
*************************************************************************

    $USING SC.ScoSecurityMasterMaintenance
    $USING EB.Reports

*******************************************


*******************************************
*
    ER =''
    R.SEC.SUPP = SC.ScoSecurityMasterMaintenance.SecuritySupp.Read(EB.Reports.getId(), ER)
* Before incorporation : CALL F.READ('F.SECURITY.SUPP',tmp.ID,R.SEC.SUPP,F.SECURITY.SUPP,ER)

    LOCATE 'M' IN R.SEC.SUPP<SC.ScoSecurityMasterMaintenance.SecuritySupp.SspCallPutMatrty,1> SETTING POSN THEN
    EB.Reports.setOData(R.SEC.SUPP<SC.ScoSecurityMasterMaintenance.SecuritySupp.SspCurrentYield,POSN>)
    END ELSE
    EB.Reports.setOData('')
    END
    END
