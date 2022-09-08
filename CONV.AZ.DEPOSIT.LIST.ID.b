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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------

    $PACKAGE AZ.Contract
    SUBROUTINE CONV.AZ.DEPOSIT.LIST.ID(YID, R.RECORD, FN.FILE)

*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*
**Conversion Routine for Defect: 211094.
* Conversion done for ID format of AZ.DEPOSIT.LIST file.
*
*-----------------------------------------------------------------------------
** @package retaillending.AZ
* @stereotype subroutine
* @ author psabari@temenos.com
*-----------------------------------------------------------------------------
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AZ.DEPOSIT.LIST
    $INSERT I_F.CONVERSION.DETAILS

* </region>
*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>

    RECORD.CNT = ''

    FN.AZ.DEPOSIT.LIST = 'F.AZ.DEPOSIT.LIST'
    F.AZ.DEPOSIT.LIST = ''
    CALL OPF(FN.AZ.DEPOSIT.LIST,F.AZ.DEPOSIT.LIST)

    RECORD.CNT = DCOUNT(R.RECORD,VM)
    IF RECORD.CNT GT 1 THEN
        ADL.CNT = 2
        LOOP
        WHILE (ADL.CNT LE RECORD.CNT)
            AZ.DEPOSIT.LIST.REC = ''
            AZ.DEP.LIST.ID = R.RECORD<AZ.DEP.ACCOUNT,ADL.CNT>:'-':YID
            AZ.DEPOSIT.LIST.REC<AZ.DEP.ACCOUNT> = R.RECORD<AZ.DEP.ACCOUNT,ADL.CNT>
            AZ.DEPOSIT.LIST.REC<AZ.DEP.B.SCH.DATE> = YID
            CALL F.WRITE(FN.AZ.DEPOSIT.LIST,AZ.DEP.LIST.ID,AZ.DEPOSIT.LIST.REC)
            ADL.CNT += 1
        REPEAT
        CALL F.DELETE(FN.AZ.DEPOSIT.LIST,YID)
    END ELSE
        CALL F.DELETE(FN.AZ.DEPOSIT.LIST,YID)
    END

    R.RECORD<AZ.DEP.ACCOUNT> = R.RECORD<AZ.DEP.ACCOUNT,1>
    R.RECORD<AZ.DEP.B.SCH.DATE> = YID
    YID = R.RECORD<AZ.DEP.ACCOUNT,1>:'-':YID

    RETURN
*
*** </region>
*------------------------------------------------------------------------------
END
