* @ValidationCode : MjotMTE1OTMzNjU3MjpDcDEyNTI6MTU2NDU2NzQwNDA3MDpzcmF2aWt1bWFyOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDcuMjAxOTA2MTItMDMyMTotMTotMQ==
* @ValidationInfo : Timestamp         : 31 Jul 2019 15:33:24
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190612-0321
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.AccountStatement
SUBROUTINE CONV.DET.STMT.PRINTED.R09(ID,R.COMP,FILE)
*-----------------------------------------------------------------------------
**** This routine will write in AC.CONV.ENTRY file to trigger the Conversion routine
*CONV.STMT.PRINTED.R09
*-----------------------------------------------------------------------------
* Modification History:
*----------------------
* 03/10/08 - EN_10003871
*            New conversion routine to update AC.CONV.ENTRY file to trigger Conversion
*            routine CONV.STMT.PRINTED.R09
*
* 30/07/19 - Enhancement 3181538 / Task 3181750
*            TI Changes - Component moved from ST to AC.
*
*-----------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY

    YCOMP.MNE = R.COMP<EB.COM.FINANCIAL.MNE>
    CNT.CONV.ID = 2
    Y.CNT = ''

    R.AC.CONV.ENTRY = ''

    FN.AC.CONV.ENTRY = 'F':YCOMP.MNE:'.AC.CONV.ENTRY'
    F.AC.CONV.ENTRY = ''

    OPEN FN.AC.CONV.ENTRY TO F.AC.CONV.ENTRY THEN
        FOR Y.CNT = 1 TO CNT.CONV.ID
            AC.CONV.ENTRY.ID = "CONVSTMTFQU":Y.CNT
            READ R.AC.CONV.ENTRY FROM F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID ELSE
                WRITE '' ON F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID
            END
        NEXT Y.CNT
    END
RETURN
END
