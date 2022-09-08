* @ValidationCode : MjozNjI3MTAwMDk6Q3AxMjUyOjE1ODYxNzg2NDg1MzM6cHJpeWFkaGFyc2hpbmlrOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDQuMDo1OjU=
* @ValidationInfo : Timestamp         : 06 Apr 2020 18:40:48
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : priyadharshinik
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 5/5 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202004.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.GEN.MIFID.UNIQUE.ID(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 31/03/20 - Enhancement 3660935 / Task 3660937
*            CI#3 - Mapping Routines - Part I
*
*-----------------------------------------------------------------------------

    $USING EB.API

    APPLICATION = "OC.MIFID.DATA"

    SYS.DATE = OCONV(DATE(),"D-");*convert date to user readable format

    TIME.STAMP=TIMEDATE();*get 24 hour time format

    RET.VAL = TXN.ID:SYS.DATE[9,2]:SYS.DATE[1,2]:SYS.DATE[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]:TIME.STAMP[7,2];*append date and time with transaction reference

RETURN


END
