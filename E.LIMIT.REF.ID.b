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

* Version 2 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LI.ModelBank

    SUBROUTINE E.LIMIT.REF.ID(LIMIT.REF.ID, IN.REF)
*-----------------------------------------------------------------------------
*
** Returns the limit reference key
*
*-----------------------------------------------------------------------------
    IF IN.REF MATCHES "1N0N" THEN
        IF IN.REF[4] = "0000" THEN
            LIMIT.REF.ID = IN.REF + 0
        END ELSE
            LIMIT.REF.ID = IN.REF[4] + 0
        END
    END ELSE
        LIMIT.REF.ID = IN.REF
    END
*
    RETURN
*-----------------------------------------------------------------------------
*
    END
