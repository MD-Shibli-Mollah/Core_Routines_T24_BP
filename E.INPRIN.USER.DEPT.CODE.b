* @ValidationCode : MjoxNzQ4NDY0NTU3OkNwMTI1MjoxNDkzMjc2MzY3ODc4OmJyaW5kaGFyOjE6MDotMTI6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDQuMDoxNToxNQ==
* @ValidationInfo : Timestamp         : 27 Apr 2017 12:29:27
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : brindhar
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : -12
* @ValidationInfo : Coverage          : 15/15 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201704.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-30</Rating>
*-----------------------------------------------------------------------------
$PACKAGE OP.ModelBank
SUBROUTINE E.INPRIN.USER.DEPT.CODE

* 04-03-16 - 1653120
*            Incorporation of components

* 27/04/17 - Task : 2003427
*            Defect : 1904698
*            OPF statements exist with null variables as argument hence FATAL.ERROR raised from OPF

    $USING EB.Security
    $USING OP.ModelBank
    $USING ST.Config
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB PROCESS

INITIALISE:
    USER.ID = ''
    DAO.ID = ''
RETURN

PROCESS:
    USER.ID = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrUserName)
    tmp.R.USER = EB.SystemTables.getRUser()
    tmp.R.USER = EB.Security.User.Read(USER.ID, Y.ERR)
* Before incorporation : CALL F.READ(FN.USER,USER.ID,tmp.R.USER,F.USER,Y.ERR)
    EB.SystemTables.setRUser(tmp.R.USER)
    DAO.ID = EB.SystemTables.getRUser()<EB.Security.User.UseDepartmentCode>
    EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrDesignation, DAO.ID)
    R.DAO = ST.Config.DeptAcctOfficer.Read(DAO.ID, Y.ERR)
* Before incorporation : CALL F.READ('F.DEPT.ACCT.OFFICER',DAO.ID,R.DAO,'',Y.ERR)
    CONTACT = R.DAO<ST.Config.DeptAcctOfficer.EbDaoTelephoneNo>
    EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrContactNo, CONTACT)
RETURN
END
