* @ValidationCode : MjotODkyNzQyNTkwOkNwMTI1MjoxNTY0NTc4MDMxNTE3OnNyYXZpa3VtYXI6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTkwOC4wOi0xOi0x
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
* <Rating>-22</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqSubmit
SUBROUTINE CONV.CHEQUES.STOPPED.201014(CHQ.STO.ID, R.CHQ.STO, FN.CHQ.STO)
*
******************************************************************************
*
* Modification History
*
* 10/02/11 - 120329
*            CHEQUES.STOPPED is no more used. Hence converting the same to
*            CHEQUE.REGISTER.SUPPLEMENT records with status 'STOPPED'.
*
* 26/04/13 - Defect 639262 / Task 660446
*            RECORD.ROUTINE has been changed as PRE.ROUTINE to avoid writing
*            null values in CHEQUES.STOPPED file
*
* 11/02/14 - Task 909919
*            While upgrading from lower release to higher, system is not
*            updating the currency value from CHEQUES.STOPPED table to
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
    $INSERT I_F.CHEQUES.STOPPED
    $INSERT I_F.USER

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

    FN.CHEQUES.STOPPED = 'F.CHEQUES.STOPPED'
    F.CHEQUES.STOPPED = ''
    CALL OPF(FN.CHEQUES.STOPPED,F.CHEQUES.STOPPED)

    R.CHEQ.REG.SUPP = ''

    ACC.NO = FIELD(CHQ.STO.ID,'*',1)
    CHQ.NO = FIELD(CHQ.STO.ID,'*',2)

RETURN
*------------------------------------------------------------------------------
BUILD.AND.WRITE.CRS:
********************
*** <desc>Build CRS record and write into the disk. </desc>

    PAY.STOP.TYPE.CNT = DCOUNT(R.CHQ.STO<CHQ.STP.PAYM.STOP.TYPE>,@VM)
    FOR CNT = 1 TO PAY.STOP.TYPE.CNT

        R.CHEQ.REG.SUPP<CC.CRS.STATUS> = 'STOPPED'
        R.CHEQ.REG.SUPP<CC.CRS.UPDATED.BY> = 'SYSTEM'
        R.CHEQ.REG.SUPP<CC.CRS.ORIGIN> = APPLICATION
        R.CHEQ.REG.SUPP<CC.CRS.ORIGIN.REF> = ID.NEW
        R.CHEQ.REG.SUPP<CC.CRS.CURRENCY>     = R.CHQ.STO<CHQ.STP.CURRENCY,CNT>
        R.CHEQ.REG.SUPP<CC.CRS.DATE.STOPPED> = R.CHQ.STO<CHQ.STP.STOP.DATE,CNT>
        R.CHEQ.REG.SUPP<CC.CRS.PAYM.STOP.TYPE> = R.CHQ.STO<CHQ.STP.PAYM.STOP.TYPE,CNT>
        R.CHEQ.REG.SUPP<CC.CRS.AMOUNT.FROM> = R.CHQ.STO<CHQ.STP.AMOUNT.FROM,CNT>
        R.CHEQ.REG.SUPP<CC.CRS.AMOUNT.TO> = R.CHQ.STO<CHQ.STP.AMOUNT.TO,CNT>
        R.CHEQ.REG.SUPP<CC.CRS.BENEFICIARY> = R.CHQ.STO<CHQ.STP.BENEFICIARY,CNT>
        R.CHEQ.REG.SUPP<CC.CRS.REMARKS>  = RAISE(R.CHQ.STO<CHQ.STP.REMARKS,CNT>)
        R.CHEQ.REG.SUPP<CC.CRS.PS.CURR.NO> = R.CHQ.STO<CHQ.STP.PS.CURR.NO,CNT>
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
        CRS.ID = R.CHQ.STO<CHQ.STP.CHQ.TYP,CNT>:'.':ACC.NO:'.':CHQ.NO
        WRITE R.CHEQ.REG.SUPP TO F.CHEQ.REG.SUPP,CRS.ID
    NEXT CNT

RETURN
*--------------------------------------------------------------------------------------------
END
