* @ValidationCode : MjotMTE2MDQwNDA0NDpDcDEyNTI6MTYxNTU0ODcxMTQ0MzpzdmFtc2lrcmlzaG5hOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMy4wOi0xOi0x
* @ValidationInfo : Timestamp         : 12 Mar 2021 17:01:51
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : svamsikrishna
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE QI.Reporting
SUBROUTINE QI.MAP.CASH.DETS(USDB.ID,USDB.REC,RES.IN.1,RES.IN.12,RESULT,RES.OUT.1,RES.OUT.2,RES.OUT.3)
*-----------------------------------------------------------------------------
* API to map cash details
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 24/02/2021 - En 4240470 / Task 4240473
*              API to map cash details
*
*-----------------------------------------------------------------------------
    
    $USING QI.Reporting
    $USING SC.SccEntitlements
    $USING SC.SccEventCapture
    $USING ST.ExchangeRate
    $USING EB.SystemTables
    $USING SC.Config
    
    GOSUB INITIALISE ; *Read all the required tables
    GOSUB PROCESS ; *
    
RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>
    ENT.ID = FIELD(USDB.ID,"*",4)
    ENT.ERR = ""
    ENT.REC = SC.SccEntitlements.Entitlement.Read(ENT.ID, ENT.ERR)
    DIA.ID = FIELD(ENT.ID,".",1)
    DIA.ERR = ""
    DIA.REC = SC.SccEventCapture.Diary.Read(DIA.ID, DIA.ERR)
        
RETURN
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    DIM R.DIARY(EB.SystemTables.SysDim)
    MAT R.DIARY = ''
    MATPARSE R.DIARY FROM DIA.REC
    OUT.DETAILS = ""
    SC.SccEntitlements.GetIncomeDetails(MAT R.DIARY, ENT.REC, OUT.DETAILS, "", "", "")  ;*Call SC.GET.INCOME.DETAILS api to get the cash details
    cashReceived = OUT.DETAILS<9>
    rate = OUT.DETAILS<2,1>
    shareReceived = OUT.DETAILS<4>
    sharePrice = OUT.DETAILS<5>
    CHANGE @SM TO @VM IN shareReceived
    CHANGE @SM TO @VM IN sharePrice
    CHANGE @VM TO "~" IN shareReceived
    CHANGE @VM TO "~" IN sharePrice
    totAmtPaid = OUT.DETAILS<1>
    RESULT = cashReceived:"*":rate:"*":shareReceived:"*":sharePrice:"*":totAmtPaid
        
RETURN
*** </region>

END

