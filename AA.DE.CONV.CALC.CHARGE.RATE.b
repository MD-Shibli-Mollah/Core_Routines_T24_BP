* @ValidationCode : MjotNzU3NjY4MDMzOkNwMTI1MjoxNjAxNTY3MzUwMDgzOmtza2F2aW5rdW1hcmFuOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjctMDQzNToyNDoxMQ==
* @ValidationInfo : Timestamp         : 01 Oct 2020 21:19:10
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kskavinkumaran
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 11/24 (45.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE AA.DE.CONV.CALC.CHARGE.RATE(InValue,HeaderRec,MvNo,OutValue,ErrorMsg)
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>/desc>
* Arguments
*
* Input
*
*** </region>
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 15/09/20 - Enhancement : 3954049
*            Task        : 3967045
*            To calculate the charge rate and return it when the amounts are provided
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Common variables and file inserts</desc>
* Inserts

    $USING DE.Outward
    $USING DE.Config
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process Logic>
*** <desc>Program Control</desc>

    GOSUB Initialise            ;* Initialise variables
    GOSUB DoProcess             ;* Main processing
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise all local variables required</desc>
Initialise:
    
    DIM RDetail(500)
    MAT RDetail = ''
    OutValue = ''
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= DoProcess>
*** <desc>Main Logic</desc>
DoProcess:

    tmp.FDO = DE.Outward.getFDeOMsg()
    tmp.Rkey = DE.Outward.getRKey()
    MATREAD RDetail FROM tmp.FDO,tmp.Rkey ELSE
        RETURN
    END

    DeMessageId = HeaderRec<DE.Config.IHeader.HdrMessageType>
    RDeMessage = DE.Config.tableMessage(DeMessageId,DeErr)

    DeMsgFldName = 'TOTAL BORR/PART AMT'
    GOSUB GetFieldValue
    TotAmt = DeMsgFieldData
    
    ChargeRate = (InValue/TotAmt)*100
    OutValue = DROUND(ChargeRate,2) ;* Return the charge rate by rounding it with 2 precision
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetFieldValue>
*** <desc>To get field data</desc>
GetFieldValue:

    LOCATE DeMsgFldName IN RDeMessage<DE.Config.Message.MsgFieldName,1> SETTING Pos THEN
        DeMsgFieldData = RDetail(Pos)
    END

RETURN
END
