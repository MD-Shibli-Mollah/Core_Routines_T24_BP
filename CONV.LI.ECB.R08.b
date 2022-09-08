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
    $PACKAGE LI.Reports
    SUBROUTINE CONV.LI.ECB.R08(ID,R.COMP,FILE)
*--------------------------------------------------------------------------------
* Record routine to write AC.CONV.ENTRY file to trigger the update EB.CONTRACT.BALANCES
* from the LI balance file.
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY

***   Main processing   ***
*     ---------------     *
*
* Take the mnemonic from the current comp
*
    YCOMP.MNE = R.COMP<EB.COM.FINANCIAL.MNE>
    CURRENT.COMP = R.COMP<EB.COM.FINANCIAL.COM>

    IF R.COMP<EB.COM.CUSTOMER.COMPANY> NE CURRENT.COMP THEN
        RETURN
    END

    R.AC.CONV.ENTRY = ''

    FN.AC.CONV.ENTRY = 'F':YCOMP.MNE:'.AC.CONV.ENTRY'
    F.AC.CONV.ENTRY = ''

    OPEN FN.AC.CONV.ENTRY TO F.AC.CONV.ENTRY THEN
        AC.CONV.ENTRY.ID = "ECB.CONTRACT"
        READ R.AC.CONV.ENTRY FROM F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID THEN

            LOCATE 'LI'  IN R.AC.CONV.ENTRY<1> SETTING POSN ELSE
                INS 'LI' BEFORE R.AC.CONV.ENTRY<POSN>
            END
            WRITE R.AC.CONV.ENTRY ON F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID
        END ELSE
            WRITE 'LI' ON F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID
        END
    END

    RETURN
*
END
