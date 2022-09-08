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
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RE.ConBalanceUpdates
    SUBROUTINE CONV.FD.ECB.R09(ID,R.COMP,FILE)
*-----------------------------------------------------------------------------
*
* This routine will write AC.CONV.ENTRY file to trigger the update of EB.CONTRACT.BALANCES
* for FD.
*
*-----------------------------------------------------------------------------
* Modification History:
*----------------------
*
* 03/10/08 - EN_10003861
*            New conversion routine to update AC.CONV.ENTRY file to trigger
*            FD conversion for EB.CONTRACT.BALANCES update.
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY

***   Main processing   ***
*     ---------------     *
* Take the mnemonic from the current comp
*

    YCOMP.MNE = R.COMP<EB.COM.FINANCIAL.MNE>

    R.AC.CONV.ENTRY = ''

    FN.AC.CONV.ENTRY = 'F':YCOMP.MNE:'.AC.CONV.ENTRY'
    F.AC.CONV.ENTRY = ''

    OPEN FN.AC.CONV.ENTRY TO F.AC.CONV.ENTRY THEN
        AC.CONV.ENTRY.ID = "ECB.CONTRACT"
        READ R.AC.CONV.ENTRY FROM F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID THEN
            LOCATE 'FD' IN R.AC.CONV.ENTRY<1> SETTING POSN ELSE
                INS 'FD' BEFORE R.AC.CONV.ENTRY<POSN>
                WRITE R.AC.CONV.ENTRY ON F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID
            END
        END ELSE
            WRITE 'FD' ON F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID
        END
    END

    RETURN
*
END
******************************************************************************************
