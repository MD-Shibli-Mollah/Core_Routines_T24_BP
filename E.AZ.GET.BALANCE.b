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
    $PACKAGE AZ.ModelBank
    SUBROUTINE E.AZ.GET.BALANCE


* 26/12/06 - BG_100009924
*            ACCT.ACTIVITY is built online and as ACCT.ENT.TODAY is read
*            to build entries for TODAY, system shows double amount.
*            Hence reading  ACCT.ENT.TODAY to get the actual balance
*            for today is removed.


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.STMT.ENTRY

    AC.ID = FIELD(O.DATA,'*',1)
    SCH.DATE = FIELD(O.DATA,'*',2)
    VAL.BALANCE = 0
    IF SCH.DATE LE TODAY THEN
        CALL GET.ENQ.BALANCE(AC.ID,SCH.DATE,VAL.BALANCE)
    END

    O.DATA =  VAL.BALANCE
    RETURN
END
