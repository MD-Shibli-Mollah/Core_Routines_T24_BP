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

$PACKAGE PD.Contract
SUBROUTINE CONV.PD.PAYMENT.DUE.R15(PD.ID, R.PD.PAYMENT.REC, FN.FILE)

*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*
** This routine is used to remove SUB accounts from ORIG.STLMNT.ACT of PD.PAYMENT.DUE template.
** Since we do not have SUB accounts above R12, we need to replace SUB accounts with MASTER accounts.
**
*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History
*
*
* 13/04/16 - Task : 1696418
*            Defect : 1693407
*            Include Conversion to replace SUB accounts with MASTER accounts.
*
*** </region>
*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>

    GOSUB INITIALISE

    GOSUB DO.CONVERSION

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc>Initilaise</desc>
INITIALISE:

    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.PD.PAYMENT.DUE

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Do Conversion>
*** <desc>Main control logic in the sub-routine</desc>
DO.CONVERSION:

    BEGIN CASE

    CASE R.PD.PAYMENT.REC<PD.STATUS> MATCHES "FWOF":VM:"WOF"

    CASE R.PD.PAYMENT.REC<PD.ORIG.STLMNT.ACT> AND NOT(R.PD.PAYMENT.REC<PD.RECORD.STATUS>[2,3] MATCHES "NAU":VM:"HLD")

        ACC.NO = R.PD.PAYMENT.REC<PD.ORIG.STLMNT.ACT>
        GOSUB GET.ACCOUNT.RECORD

        IF R.ACCOUNT.REC<AC.MASTER.ACCOUNT> THEN
            R.PD.PAYMENT.REC<PD.ORIG.STLMNT.ACT> = R.ACCOUNT.REC<AC.MASTER.ACCOUNT>
        END

    CASE 1

    END CASE

    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= GET.ACCOUNT.RECORD>
*** <desc>Get Account Record</desc>
GET.ACCOUNT.RECORD:

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    R.ACCOUNT.REC = ""
    CALL F.READ(FN.ACCOUNT, ACC.NO, R.ACCOUNT.REC, F.ACCOUNT, ACC.ERR)
    IF ACC.ERR THEN
      FN.ACCOUNT.HIS = 'F.ACCOUNT$HIS'          ;* history account file name
      F.ACCOUNT$HIS = ''    ;* history file
      ACC.ERR = ''
      CALL OPF(FN.ACCOUNT.HIS,F.ACCOUNT$HIS)    ;* OPF
      CALL EB.READ.HISTORY.REC(F.ACCOUNT$HIS,ACC.NO,R.ACCOUNT.REC,ACC.ERR)          ;* latest history record is read!
    END

    RETURN
*** </region>

*-----------------------------------------------------------------------------
END

