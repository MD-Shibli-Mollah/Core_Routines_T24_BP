* @ValidationCode : Mjo4NTUwNDkxMDA6Q3AxMjUyOjE1ODAyMTQxMDkxNjk6cHJpeWFkaGFyc2hpbmlrOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDEuMjAxOTEyMjQtMTkzNTo2OjY=
* @ValidationInfo : Timestamp         : 28 Jan 2020 17:51:49
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : priyadharshinik
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 6/6 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202001.20191224-1935
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.LEVEL(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
* The routine will be attached as a link routine in TX.TXN.BASE.MAPPING record.
* It returns default value "T"
* This is the common routine for the FX,ND,SWAP,FRA and DX.
*-----------------------------------------------------------------------------
*******************************************************************
*
*
* Incoming parameters:
*
* APPL.ID   - Id of transaction
* APPL.REC  - A dynamic array holding the contract.
* FIELD.POS - Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
* Ret.val- returns default value "T".
*
*
*******************************************************************
* Modification History :
*
* 31/01/2020 - Enhancement 3562849 / Task 3562851
*              CI #3 - Mapping Routines
*
*-----------------------------------------------------------------------------
    GOSUB PROCESS ; *
   
RETURN

*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    IF APPL.ID[1,2] EQ "FX" OR APPL.ID[1,2] EQ "FR" OR APPL.ID[1,2] EQ "ND" OR APPL.ID[1,2] EQ "SW" OR APPL.ID[1,2] EQ "DX" THEN
        RET.VAL = "T"
    END
    
RETURN
*** </region>

END

