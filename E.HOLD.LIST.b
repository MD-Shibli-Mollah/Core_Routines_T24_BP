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
* <Rating>180</Rating>
*-----------------------------------------------------------------------------
* Version 4 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*   
    $PACKAGE EB.ModelBank
    
    SUBROUTINE E.HOLD.LIST
*
*----------------------------------------------------------------------
*
* Enquiry routine to return list of user names to receive report.
* Data has been built by E.HOLD.INIT as first instruction of enquiry.
*
* C$REPORT.LIST <>  Dynamic array containing list of reports
* C$USER.LIST   <>  Corresponding users (m/valued).
*
*----------------------------------------------------------------------
*               MODIFICATION HISTORY
*               --------------------
*
* 04/04/07 - CI_10048263
*            Fix done to check USER(s) company id(s) with that of the
*            report(s) company id to report REQUEST BY column properly.
*
* 10/05/16 - Enhancement 1499014
*          - Task 1626129
*          - Routine incorporated
*----------------------------------------------------------------------
  
    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.Security
    $USING EB.ModelBank
    
    V1 = ''
    DEFFUN CHARX(V1)
*
*-----------------------------------------------------------------------
*
    
    LOCATE EB.Reports.getOData() IN EB.ModelBank.getCReportList()<1> SETTING D ELSE D = 0

    IF D THEN 

        COMP.ID = EB.Reports.getRRecord()<EB.Reports.HoldControl.HcfCompanyId>
        USER.ID = EB.ModelBank.getCUserList()<D>
        GOSUB GET.USER
        LOCATE COMP.ID IN R.USER.REC<EB.Security.User.UseCompanyCode,1> SETTING COMP.POS ELSE COMP.POS = 0      ;* check USER's company id with REPORT's company id

        IF COMP.POS THEN
            temp.CUserList = EB.ModelBank.getCReportList()<D> 
            EB.Reports.setOData(temp.CUserList)
        END ELSE
            EB.Reports.setOData('')
        END
    END
    O.DATA.VAL = EB.Reports.getOData()
    CONVERT CHARX(253) TO ',' IN O.DATA.VAL
    EB.Reports.setOData(O.DATA.VAL)

*
    RETURN
*
*--------------------------------------------------------------------
GET.USER:
*-------
    R.USER.REC = EB.Security.User.CacheRead(USER.ID, '')
    
    RETURN

*
*-----------------------------------------------------------------------
END
