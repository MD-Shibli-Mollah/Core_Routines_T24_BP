* @ValidationCode : MjoxODQ2ODQ1MTM3OkNwMTI1MjoxNTQ1MTExOTAyMTkxOmFtb25pc2hhOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTgxMi4yMDE4MTEyMy0xMzE5Oi0xOi0x
* @ValidationInfo : Timestamp         : 18 Dec 2018 11:15:02
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : amonisha
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201812.20181123-1319
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>93</Rating>
*-----------------------------------------------------------------------------
* Version 2 02/06/00  GLOBUS Release No. 200509 29/07/05
*
$PACKAGE EB.ModelBank

SUBROUTINE E.HOLD.INIT
*
*---------------------------------------------------------------------
*
* Enquiry routine for HOLD.LIST - stores a list of users and their
* requested reports in a labelled common. Then as each report name
* is displayed in the enquiry a list of users can be printed as
* well - See E.HOLD.LIST
*
* Also opens &HOLD& so that the size of each report can be displayed -
* See E.HOLD.SIZE.
*
* 10/05/16 - Enhancement 1499014
*          - Task 1626129
*          - Routine incorporated
*
* 18/12/18 - Defect 2907034 / Task 2907370
*            Performance Improvement by avoiding read of user record when the user list is already present.
*
*----------------------------------------------------------------------
*

    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.Security
    $USING EB.ModelBank
    $USING EB.DataAccess
    $USING EB.ErrorProcessing
    
*
*----------------------------------------------------------------------
*
*
*-----------------------------------------------------------------------
*
* If the values are not available, then set it to NULL
    IF NOT(EB.ModelBank.getCUserList()) THEN
        EB.ModelBank.setCReportList('') ;* Set the variables to NULL
        EB.ModelBank.setCUserList('') ;* Set the variables to NULL
    END

    IF EB.ModelBank.getCUserList() EQ "Empty" THEN
        RETURN ;* We did not have any values and is only our own Keyword, so return and dont bother further.
    END

    F.USER = ''
    EB.DataAccess.Opf('F.USER',F.USER)
    SELECT F.USER
*
*
    EB.ModelBank.setCReportList('')
    EB.ModelBank.setCUserList('')
*
    LOOP
    READNEXT USER.ID ELSE USER.ID = '' UNTIL USER.ID = ''
        REC.USER = ''
        REC.USER = EB.Security.User.Read(USER.ID, Yerr)     ;* Before Incorporation: READ REC.USER FROM F.USER, USER.ID ELSE REC.USER = ''
        RPT.REC = REC.USER<EB.Security.User.UseRptToReceive>
        LOOP
        REMOVE REPORT FROM RPT.REC SETTING D UNTIL REPORT = ''
            temp.CReportList = EB.ModelBank.getCReportList()
            LOCATE REPORT IN temp.CReportList<1> SETTING POS ELSE
                temp.CReportList<-1> = REPORT
                EB.ModelBank.setCReportList(temp.CReportList)
                temp.CUserList = EB.ModelBank.getCUserList()
                temp.CUserList<-1> = USER.ID
                EB.ModelBank.setCUserList(temp.CUserList)
                POS = 0
            END
            IF POS THEN
                temp.CUserList = EB.ModelBank.getCUserList()
                temp.CUserList<POS,-1> = USER.ID
                EB.ModelBank.setCUserList(temp.CUserList)
            END
        REPEAT
    REPEAT

* Update a keyword as Empty for repeated iterations
    IF NOT(EB.ModelBank.getCUserList()) THEN
        EB.ModelBank.setCUserList("Empty") ;* Since we do not have any other users selected, set it to a keyword "Empty"
    END
*
*------------------------------------------------------------------
*
    C$F.HOLD.VAL = ''
    OPEN '','&HOLD&' TO C$F.HOLD.VAL ELSE
        EB.SystemTables.setText('UNABLE TO OPEN &HOLD& FILE')
        EB.ErrorProcessing.FatalError('E.HOLD.INIT')
    END
    EB.ModelBank.setCFHold(C$F.HOLD.VAL)
*
*------------------------------------------------------------------
RETURN
*
*-------------------------------------------------------------------
END
