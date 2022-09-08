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
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SL.Config
    SUBROUTINE CONV.SL.PARAMETER.G15.0(SL.ID,SL.REC,SL.FILE)

*   Routine to update the MSG.CLASS and EB.MSG.CLASS fields in SL.PARAMETER
*   Which is not available in field.defintion.

    $INSERT I_COMMON
    $INSERT I_EQUATE

    EQU SL.PARAM.SL.MSG.CLASS TO 21
    EQU SL.PARAM.EB.MSG.CLASS TO 22

    SL.MSG.FIELDS  = 'GRANT NEW FACILITY':VM:'GRANT NEW FACILITY.BORR':VM:'FACI AMENDMENTS':VM:'FACI AMENDMENTS.BORR':VM:'ADVICE FEE SCHEDULES':VM:'ADVICE FEE SCHEDULES.BORR':VM:'NOTICE FEE PAYMENT.BORR':VM:'FACILITY REVERSAL':VM:'FACILITY REVERSAL.BORR':VM:'ADVICE OF CHG':VM:'ADVICE OF CHG.BORR':VM:'NOTICE OF LOAN DD':VM:'LOAN MESSAGE 103':VM:'LOAN MESSAGE 202':VM:'LOAN DD.BORR':VM:'NOTICE OF INT PAYMENT.BORR':VM:'CONFIRM INT PAYMENT':VM:'CONFIRM INT PAYMENT.BORR':VM:'LOAN AMENDMENTS':VM:'LOAN AMENDMENTS.BORR':VM:'LOAN REVERSAL':VM:'FACILITY FEE 202':VM:'LOAN.RATE.CHANGES'
    EB.MSG.FIELDS  = 'ADVICEPART'        :VM:'ADVICEBORR'             :VM:'ADVICEPART'     :VM:'ADVICEBORR'          :VM:'ADVICEPART'          :VM:'ADVICEBORR'               :VM:'ADVICEBORR'             :VM:'ADVICEPART'       :VM:'ADVICEBORR'            :VM:'ADVICEPART'   :VM:'ADVICEBORR'        :VM:'ADVICEPART'       :VM:'PAYMENT'         :VM:'BANKTRANSFER'    :VM:'ADVICEBORR'  :VM:'ADVICEBORR'                :VM:'ADVICEPART'         :VM:'ADVICEBORR'              :VM:'ADVICEPART'     :VM:'ADVICEBORR'          :VM:'ADVICEPART'   :VM:'BANKTRANSFER'    :VM:'ADVICEPART'
    SL.REC<SL.PARAM.SL.MSG.CLASS> = SL.MSG.FIELDS
    SL.REC<SL.PARAM.EB.MSG.CLASS> = EB.MSG.FIELDS

    RETURN
END
