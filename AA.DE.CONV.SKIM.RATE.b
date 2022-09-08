* @ValidationCode : MjoyMjg1OTYxNTQ6Q3AxMjUyOjE1OTk3MTUzNTgyNzA6ZGl2eWFzYXJhdmFuYW46MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNi4yMDIwMDUyMS0wNjU1OjM0OjEx
* @ValidationInfo : Timestamp         : 10 Sep 2020 10:52:38
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : divyasaravanan
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 11/34 (32.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE AA.DE.CONV.SKIM.RATE(InValue,HeaderRec,MvNo,OutValue,ErrorMsg)
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
* 03/09/20 - Enhancement : 3164932
*            Task        : 3931550
*            To return the skim rate of the participant after handling with the respective property's effective rate
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

    DeMsgFldName = 'PART CUR SKIM PROPERTY'
    GOSUB GetFieldValue
    CurrentSkimProp = DeMsgFieldData

    DeMsgFldName = 'PART SKIM PROPERTY'
    GOSUB GetFieldValue
    SkimPropList = DeMsgFieldData
    
    DeMsgFldName = 'PART SKIM RATE'
    GOSUB GetFieldValue
    SkimRateList = DeMsgFieldData
    
    LOCATE CurrentSkimProp IN SkimPropList<1,1> SETTING SkimPropPos THEN
        CurrentSkimRate = SkimRateList<1, SkimPropPos>
        OutValue = InValue - CurrentSkimRate
    END ELSE
        OutValue = InValue
    END
    
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
