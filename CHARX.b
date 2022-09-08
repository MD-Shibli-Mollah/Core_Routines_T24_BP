* @ValidationCode : MjotNDE3ODk4MTQ4OkNwMTI1MjoxNTcwNTE1NTk5NjE0OmFtb25pc2hhOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE5MTAuMjAxOTA5MjAtMDcwNzotMTotMQ==
* @ValidationInfo : Timestamp         : 08 Oct 2019 11:49:59
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : amonisha
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-14</Rating>
*-----------------------------------------------------------------------------
* Version 3 04/10/00  GLOBUS Release No. 200508 30/06/05
$PACKAGE EB.API
FUNCTION CHARX(CHAR.NO.PASSED)
*
************************************************************
*
* This function will return a character at the position
* specified by the argument CHAR.NO.PASSED in the array
* CHARX set up in the common area
*
************************************************************
*
* CHANGE CONTROL
* --------------
*
* 18/04/00 - GB0001078
*            New function
*
* 06/07/00 - GB0001723
*            return values compatible with CHAR function for
*            0 and > 255.
*
* 04/10/00 - GB0002473
*            This means a null byte not ""
*
* 18/12/2002 - GLOBUS_EN_10001548
*              If running in UTF8 mode then use CHAR functno
*
************************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
    IF RUNNING.IN.UTF8 THEN
        CHAR.RETURNED = CHAR(CHAR.NO.PASSED)
    END ELSE
        IF NOT(C$SEQX) THEN
            CALL CONVERT.ASCII.EBCDIC
        END
        IF CHAR.NO.PASSED = 0 OR CHAR.NO.PASSED > 255 THEN
            CHAR.RETURNED = CHAR(0)      ; * return null BYTE
        END ELSE
            CHAR.RETURNED = C$CHARX(CHAR.NO.PASSED)
        END
    END
RETURN(CHAR.RETURNED)
END
