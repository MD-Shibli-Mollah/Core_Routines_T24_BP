* @ValidationCode : MjotOTM2MDg1ODU6Y3AxMjUyOjE1NDE3MzkyMDAwMTg6aGFycnNoZWV0dGdyOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDkuMjAxNzA3MzAtMDYyNzo1OjU=
* @ValidationInfo : Timestamp         : 09 Nov 2018 10:23:20
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : harrsheettgr
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 5/5 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201709.20170730-0627
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
$PACKAGE OC.Parameters
SUBROUTINE OC.GEN.UNIQUE.ID(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)

* Modification History :
*
* 18/03/15 - EN 1047936 / Task 1252419
*            FX - Mapping & COB scheduling
*
* 06/04/15 - EN 1177301 / Task 1284514
*            FRA - Mapping & COB scheduling
*
* 22/04/15 - EN 1177300 / Task 1320631
*            NDF - Mapping & COB scheduling
*
* 30/12/15 - EN_1226121 / Task 1568411
*            Incorporation of the routine
*
* 21/04/17 - Defect 2083695 / Task 2097245
*            Changes to Id generation logic as its not ensuring the amendment order by its Id
*
* 10/08/17 - Defect 2223308 / Task 2229248
*            Deals in OC.TXN.DATA enquiry get updated incorrectly
*
*-----------------------------------------------------------------------------

    $USING EB.API

    APPLICATION = "OC.TRADE.DATA"

    SYS.DATE = OCONV(DATE(),"D-");*convert date to user readable format

    TIME.STAMP=TIMEDATE();*get 24 hour time format

    RET.VAL = TXN.ID:SYS.DATE[9,2]:SYS.DATE[1,2]:SYS.DATE[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]:TIME.STAMP[7,2];*append date and time with transaction reference

RETURN

