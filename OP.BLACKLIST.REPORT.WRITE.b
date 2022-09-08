* @ValidationCode : MjotMTQ1MzY4MDk1MDpDcDEyNTI6MTU4MDgxNTI2NDcwMjpsb2dhbmF0aGFuZzotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDIuMjAyMDAxMTctMjAyNjotMTotMQ==
* @ValidationInfo : Timestamp         : 04 Feb 2020 16:51:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : loganathang
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE OP.ModelBank
SUBROUTINE OP.BLACKLIST.REPORT.WRITE(RecId, Record)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 04/02/20 - Defect 3569476 / Task 3569590
*            Replace F.WRITE with table writes
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

    
    OP.ModelBank.EbBlacklistReport.Write(RecId, Record)  

RETURN
END
