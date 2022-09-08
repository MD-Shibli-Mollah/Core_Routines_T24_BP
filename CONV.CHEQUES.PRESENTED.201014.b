* @ValidationCode : MjoyMjEwOTMyOTg6Q3AxMjUyOjE1NjQ1NzgwMzE0NzA6c3JhdmlrdW1hcjotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxOTA4LjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 Jul 2019 18:30:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-32</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqSubmit
SUBROUTINE CONV.CHEQUES.PRESENTED.201014(CHQ.PRE.ID, R.CHQ.PRE, FN.CHQ.PRE)
*
******************************************************************************
*
* Modification History
*
* 10/02/11 - 120329
*            CHEQUES.STOPPED is no more used. Hence converting the same to
*            CHEQUE.REGISTER.SUPPLEMENT records with status 'STOPPED'.
*
* 31/01/14 - Task 902449
*            Changed to PRE.ROUTINE instead of RECORD.ROUTINE to avoid writing of
*            null value.
*
* 20/03/14 - Task 946168
*            While upgrading from lower release to higher, system is not
*            updating the currency value from CHEQUES.PRESENTED table to
*            CHEQUE.REGISTER.SUPPLEMENT table.
*
* 27/03/14 - Defect 949601 / Task 952495
*            To run conversion routine in all branches
*
* 10/04/14 - Defect 949601 / Task 975637
*            Again changing in to RECORD.ROUTINE as performance is slow.
*            Hence removing the Task 952495
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Submit as ST_ChqSubmit and include $PACKAGE
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
******************************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CHEQUE.REGISTER.SUPPLEMENT
    $INSERT I_F.CHEQUES.PRESENTED
    $INSERT I_F.USER
    $INSERT I_F.ACCOUNT

    GOSUB INITIALISE
    GOSUB BUILD.AND.WRITE.CRS

RETURN
*------------------------------------------------------------------------------
INITIALISE:
***********
*** <desc>INITIALISE the Variables </desc>

    FN.CHEQ.REG.SUPP = 'F.CHEQUE.REGISTER.SUPPLEMENT'
    F.CHEQ.REG.SUPP = ''
    CALL OPF(FN.CHEQ.REG.SUPP,F.CHEQ.REG.SUPP)

    FN.CHEQUES.PRESENTED = 'F.CHEQUES.PRESENTED'
    F.CHEQUES.PRESENTED = ''
    CALL OPF(FN.CHEQUES.PRESENTED,F.CHEQUES.PRESENTED)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT  = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    R.CHEQ.REG.SUPP = ''
    AC.CHE.TYPE = FIELD(CHQ.PRE.ID,'-',1)
    CHQ.NO = FIELD(CHQ.PRE.ID,'-',2)
    CRS.ID = AC.CHE.TYPE:'.':CHQ.NO

RETURN
*---------------------------------------------------------------------------------
BUILD.AND.WRITE.CRS:
********************
*** <desc>Build CRS record and write into the disk. </desc>

    R.CHEQ.REG.SUPP<CC.CRS.STATUS> = "PRESENTED"
    Y.ACCT.NO = FIELD(AC.CHE.TYPE,'.',2)
    GOSUB READ.ACCOUNT
    R.CHEQ.REG.SUPP<CC.CRS.CURRENCY> = R.ACCOUNT<AC.CURRENCY>
    R.CHEQ.REG.SUPP<CC.CRS.UPDATED.BY> = "SYSTEM"
    R.CHEQ.REG.SUPP<CC.CRS.ORIGIN> = APPLICATION
    R.CHEQ.REG.SUPP<CC.CRS.ORIGIN.REF> = ID.NEW
    R.CHEQ.REG.SUPP<CC.CRS.DATE.PRESENTED> = R.CHQ.PRE<CHQ.PRE.DATE.PRESENTED>
    R.CHEQ.REG.SUPP<CC.CRS.REPRESENTED.COUNT> = R.CHQ.PRE<CHQ.PRE.REPRESENTED.COUNT>
    R.CHEQ.REG.SUPP<CC.CRS.RECORD.STATUS> = ""

    R.CHEQ.REG.SUPP<CC.CRS.CURR.NO> = 1
    R.CHEQ.REG.SUPP<CC.CRS.INPUTTER> = TNO:'_':OPERATOR

    TIME.STAMP = TIMEDATE()
    X = OCONV(DATE(),"D-")
    X = X[9,2]:X[1,2]:X[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]

    R.CHEQ.REG.SUPP<CC.CRS.DATE.TIME> = X
    R.CHEQ.REG.SUPP<CC.CRS.AUTHORISER> = TNO:'_':OPERATOR
    R.CHEQ.REG.SUPP<CC.CRS.CO.CODE> = ID.COMPANY
    R.CHEQ.REG.SUPP<CC.CRS.DEPT.CODE> = R.USER<EB.USE.DEPARTMENT.CODE>

    WRITE R.CHEQ.REG.SUPP TO F.CHEQ.REG.SUPP,CRS.ID

RETURN
*-------------------------------------------------------------------------------------
READ.ACCOUNT:
*************

    R.ACCOUNT = ''
    ACCT.ERR  = ''
    CALL F.READ(FN.ACCOUNT,Y.ACCT.NO,R.ACCOUNT,F.ACCOUNT,ACCT.ERR)

RETURN
*------------------------------------------------------------------------------------
END
