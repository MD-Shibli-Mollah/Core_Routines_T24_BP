* @ValidationCode : Mjo5NTI1ODY2NTY6Q3AxMjUyOjE2MTYxNjA2NTQzOTU6dGhhbm1heWlrbDoxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTAzLjA6MTI2OjEx
* @ValidationInfo : Timestamp         : 19 Mar 2021 19:00:54
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : thanmayikl
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 11/126 (8.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE AA.DE.CONV.SUB.PART.SHARE.PERCENT(InValue, HeaderRec, MvNo, OutValue, ErrorMsg)
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 12/03/21 - Enhancement: 4203207
*            Task: 4226990
*            Conversion routine for Sub participant share transfer percentage
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Common variables and file inserts</desc>
* Inserts

    $USING DE.Outward
    $USING DE.Config
    $USING AA.Framework
    $USING AA.Participant
    $USING EB.API
    $USING EB.SystemTables
    $USING AA.ProductFramework
    $USING AA.PaymentSchedule
    $USING AF.Framework
    $USING AA.ShareTransfer
    $USING AC.BalanceUpdates
    
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
    
    ArrActivityId = HeaderRec<DE.Config.OHeader.HdrTransRef>
    
    DeMsgFldName = 'REFERENCE NUMBER'
    GOSUB GetFieldValue
    ArrId = DeMsgFieldData
    
    DeMsgFldName = 'EFF DATE'
    GOSUB GetFieldValue
    EffectiveDate = DeMsgFieldData
    
    DeMsgFldName = 'SHARE TRANSFER AMT'
    GOSUB GetFieldValue
    ShareTransferAmt= DeMsgFieldData
    
    RArrangement = ''
    RetError = ''
    AA.Framework.GetArrangement(ArrId, RArrangement, RetError)
    ArrStartDate = RArrangement<AA.Framework.Arrangement.ArrStartDate>
    ArrCustomer = RArrangement<AA.Framework.Arrangement.ArrCustomer>
    
    AA.Framework.GetArrangementConditions(ArrId, "TERM.AMOUNT", "", EffectiveDate, Property, '', RecErr) ;* get the participant record for the arrangement
    
    AA.Framework.GetArrangementConditions(ArrId, "PARTICIPANT", "", EffectiveDate,'', ParticipantRec, RecErr) ;* get the participant record for the arrangement
    ParticipantRec = RAISE(ParticipantRec)
    
    PartAccMode = ParticipantRec<AA.Participant.Participant.PrtAcctngType> ;* Accounting mode of the participant
    
    AA.Framework.GetArrangementAccountId(ArrId, AccountId, '' , RecErr)   ;*Get corresponding accountId of Drawings Sub arrangement
    
    IF InValue EQ EB.SystemTables.getIdCompany() THEN
        Participant = "BOOK"
    END ELSE
        Participant = InValue
    END
*** To get the seller balances before share transfer read activity balances for amount transferred during share transfer and add this to current balance   
    GOSUB GetFwdBalances ;*To get FWD balances
    
    GOSUB GetPropertyBalances
    GOSUB GetActivityBalances   ;*Get the amount which is transferred as part of share transfer
    GOSUB GetBalances           ;*Get after share transfer amount
    
    GOSUB CalculateBalances     ;*To get before share transfer balances add amount transferred during share transfer to the current balance
    
    IF EffectiveDate GT EB.SystemTables.getToday() THEN
        PartShareAmt = CurAmt + UtlAmt + OvdAmt + ABS(FwdShareCurAmt) + ABS(FwdShareUtlAmt) + ABS(FwdShareOvdAmt)
    END ELSE
        PartShareAmt = CurAmt + UtlAmt + OvdAmt + ABS(ShareCurAmount) + ABS(ShareUtlAmount) + ABS(ShareOvdAmount)
    END
    
    TransferPercent = (ShareTransferAmt/PartShareAmt)*100
    
    OutValue = OCONV(ICONV(TransferPercent, "MD2"), "MD2")
        
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetFieldValue>
*** <desc>To get field data</desc>
GetFieldValue:

    DeMsgFieldData = ''
    LOCATE DeMsgFldName IN RDeMessage<DE.Config.Message.MsgFieldName,1> SETTING Pos THEN
        DeMsgFieldData = RDetail(Pos)
    END

RETURN
*-----------------------------------------------------------------------------

*** <region name= GetPropertyBalances>
GetPropertyBalances:
*** <desc> </desc>

   IF Participant EQ "BOOK" THEN
        PartAccMode = "REAL"
        PartEcbId = AccountId:"*":ArrCustomer
        PartBalType = Property ;* For Book, get original balance type
    END ELSE
        PartEcbId = AccountId:"*":Participant
        IF PartAccMode EQ 'MEMO' THEN
            PartBalType = Property:'PARTINF' ;* For MEMO Participant, suffix with PARTINF
        END ELSE
            PartBalType = Property:'PART' ;* For CONTINGENT Participant, suffix with PART
        END
    END
   
IF FwdFlag THEN
    PartBalType = PartBalType:'FWD'
END

*Accounting balance type for CUR type
    CurBalType = "CUR":PartBalType
    
*Accounting balance type for UTL type
    UtlBalType = "UTL":PartBalType
    
*Accounting balance type for OVD type
    OvdBalType = "OVD":PartBalType
     
    
RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= GetBalances>
GetBalances:
*** <desc> </desc>
    
    BalDetails = ''
    ReqType = ''
    ReqType<2> = "ALL"
    ReqType<7> = PartAccMode
    ReqType<8> = 1
    AA.Framework.GetPeriodBalances(PartEcbId, UtlBalType, ReqType, EffectiveDate, "", "", BalDetails,RET.ERROR)
    
    UtlAmt = BalDetails<AC.BalanceUpdates.AcctActivity.IcActBalance>
    
    BalDetails = ''
    AA.Framework.GetPeriodBalances(PartEcbId, CurBalType, ReqType, EffectiveDate, "", "", BalDetails,RET.ERROR)
    
    CurAmt = BalDetails<AC.BalanceUpdates.AcctActivity.IcActBalance>
    
    BalDetails = ''
    AA.Framework.GetPeriodBalances(PartEcbId, OvdBalType, ReqType, EffectiveDate, "", "", BalDetails,RET.ERROR)
    
    OvdAmt = BalDetails<AC.BalanceUpdates.AcctActivity.IcActBalance>
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GetActivityBalances>
GetActivityBalances:
*** <desc> </desc>

    ProcessType = "GET"
    ActivityBalancesRec = ""
*Activity balances are updated with share transfer ratio and share transfer amounts for termamount and account properties
    AA.Framework.ProcessActivityBalances(ArrId, ProcessType, ActivityBalancesRec, ArrActivityId, "", "", "", RetError)
    
    LOCATE ArrActivityId IN ActivityBalancesRec<AA.Framework.ActivityBalances.ActBalActivityRef,1> SETTING ActPos THEN
        
        BalProperty = ActivityBalancesRec<AA.Framework.ActivityBalances.ActBalProperty,ActPos>
        BalAmounts = ActivityBalancesRec<AA.Framework.ActivityBalances.ActBalPropertyAmt,ActPos>
    END
    
       
    ActProperty = FIELD(Property,@FM,1):".":CurBalType:".":Participant
*Get the correct share transfer amount which is updated in AA.ACTIVITY.BALANCES
    LOCATE ActProperty IN BalProperty<1,1,1> SETTING BalPos THEN
        ShareCurAmount = BalAmounts<1,1,BalPos>
    END
        
    ActProperty = FIELD(Property,@FM,1):".":UtlBalType:".":Participant
    LOCATE ActProperty IN BalProperty<1,1,1> SETTING BalPos THEN
        ShareUtlAmount = BalAmounts<1,1,BalPos>
    END
    
    ActProperty = FIELD(Property,@FM,1):".":OvdBalType:".":Participant
    LOCATE ActProperty IN BalProperty<1,1,1> SETTING BalPos THEN
        ShareOvdAmount = BalAmounts<1,1,BalPos>
    END
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GetFwdBalances>
GetFwdBalances:
*** <desc> </desc>
    FwdFlag = 1
    GOSUB GetPropertyBalances
    GOSUB GetActivityBalances
    GOSUB GetBalances
    FwdCurAmt = CurAmt
    FwdUtlAmt = UtlAmt
    FwdOvdAmt = OvdAmt
    FwdShareCurAmt =  ShareCurAmount
    FwdShareUtlAmt =  ShareUtlAmount
    FwdShareOvdAmt =  ShareOvdAmount
    FwdFlag = ''
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= CalculateBalances>
CalculateBalances:
*** <desc> </desc>
    
    CurAmt = ABS(FwdCurAmt + CurAmt)
    UtlAmt = ABS(FwdUtlAmt + UtlAmt)
    OvdAmt = ABS(FwdOvdAmt + OvdAmt)
    
RETURN
*** </region>

END
