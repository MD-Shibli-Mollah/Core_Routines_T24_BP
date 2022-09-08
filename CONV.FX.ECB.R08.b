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
* Version n dd/mm/yy  GLOBUS Release No. 200709
*
    $PACKAGE RE.ConBalanceUpdates
    SUBROUTINE CONV.FX.ECB.R08(ID,R.COMP,FILE)
*-----------------------------------------------------------------------------
*
* This routine will write AC.CONV.ENTRY file to trigger to update EB.CONTRACT.BALANCES
* for FOREX.
*
*-----------------------------------------------------------------------------
* Modification History:
*
* 21/08/07 - EN_10003479
*            New routine for SAR-2007-03-09-0002 - FX to update EB.CONTRACT.BALANCES
*            Update AC.CONV.ENTRY with ID as FX to trigger the FX conversion at COB.
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
            LOCATE 'FX' IN R.AC.CONV.ENTRY<1> SETTING POSN ELSE
                INS 'FX' BEFORE R.AC.CONV.ENTRY<POSN>
            END
            WRITE R.AC.CONV.ENTRY ON F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID
        END ELSE
            WRITE 'FX' ON F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID
        END
    END
*
    RETURN
*
END
******************************************************************************************
