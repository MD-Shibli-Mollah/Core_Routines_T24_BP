* @ValidationCode : Mjo3ODA0NDgwNDU6Q3AxMjUyOjE1NjQ1NzgwMzE1Nzk6c3JhdmlrdW1hcjotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxOTA4LjA6LTE6LTE=
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
SUBROUTINE CONV.DEL.CHQ.PRESENTED.201014(CRS.ID, R.CRS, FN.CHEQ.REG.SUPP)
*
******************************************************************************
*
* Modification History
*
* 10/04/14 - Defect 949601 / Task 975637
*            Included this routine to delete the CHEQUES.PRESENTED record
*            To avoid writing of null values.
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
******************************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CHEQUES.PRESENTED
    $INSERT I_F.CHEQUES.STOPPED
    $INSERT I_F.CHEQUE.REGISTER.SUPPLEMENT

    GOSUB INITIALISE
    GOSUB DELETE.CHQ.PRESENTED

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

    FN.CHEQUES.STOPPED = 'F.CHEQUES.STOPPED'
    F.CHEQUES.STOPPED = ''
    CALL OPF(FN.CHEQUES.STOPPED,F.CHEQUES.STOPPED)

RETURN
*------------------------------------------------------------------------------
DELETE.CHQ.PRESENTED:
*********************
*** <desc>Delete the Cheque Presented record</desc>

    AC.CHE.TYPE = FIELD(CRS.ID,'.',1)
    ACC.NO = FIELD(CRS.ID,'.',2)
    CHQ.NO = FIELD(CRS.ID,'.',3)
    CHQ.PRE.ID = AC.CHE.TYPE:".":ACC.NO:"-":CHQ.NO
    CHQ.STOP.ID = ACC.NO:"*":CHQ.NO

    DELETE F.CHEQUES.PRESENTED,CHQ.PRE.ID
    DELETE F.CHEQUES.STOPPED,CHQ.STOP.ID

RETURN
*---------------------------------------------------------------------------------
END
