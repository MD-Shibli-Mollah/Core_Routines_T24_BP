* @ValidationCode : MjoyMDQ3MTAzNDc1OkNwMTI1MjoxNTk2Njg0ODkyODI5OnNoYWlremFrZWVyYTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjEtMDY1NTotMTotMQ==
* @ValidationInfo : Timestamp         : 06 Aug 2020 09:04:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : shaikzakeera
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE SC.SctOrderCapture
SUBROUTINE V.SC.DEF.UPF.TXN.CODE
*********************************************************************************
*** <region name= Modification History>
*** <desc>Modification History </desc>
* 03/08/2020 - DEFECT:3883782 TASK:3893545
*            Transaction.code in SEC.OPEN.ORDER should be defaulted if SM has upfront configurations

    $USING SC.ScoSecurityMasterMaintenance
    $USING EB.SystemTables
    $USING SC.Config
    $USING ST.CompanyCreation

    GOSUB INITIALISE ; *

    IF SM.ID THEN
    
        GOSUB READ.SECURITY.MASTER ; *
    
        GOSUB CHECK.UPFRONT.INT.ACC ; *
    
    END

RETURN


*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>
    SM.ID = ''
    IF EB.SystemTables.getMessage() = 'VAL' THEN ; * No need to do this processing from CROSSVAL
        RETURN
    END
    ORD.TYPE = EB.SystemTables.getRNew(SC.SctOrderCapture.SecOpenOrder.ScSooOrderType)
**Read SC.ORDER.TYPE
    GOSUB READ.SC.ORDERTYPE ; *
*Check CASH.ORDER equal to YES
    IF R.SC.ORDER.TYPE<SC.SctOrderCapture.OrderType.ScOrtCashOrder> NE 'YES' THEN
        RETURN
    END
*if CASH.ORDER is YES Then get the TRANS.CODE
    TRANS.CODE = EB.SystemTables.getComi()
* Read SC.TRA.CODE using TRANS.CODE as Id
    GOSUB READ.SC.TRA.CODE ; *
    TRA.TYPE = R.SC.TRA.CODE<1>
* Read TRANS.TYPE
    GOSUB READ.SC.TRANS.TYPE ; *
* Check if Txn Security Code is equal to TRANS.CODE then Get the SM.ID for defaulting the TRANSACTION.CODE
    IF R.SC.TRANS.TYPE<SC.Config.TransType.TrnSecurityCrCode> NE TRANS.CODE THEN
        RETURN
    END
    
    SM.ID = EB.SystemTables.getRNew(SC.SctOrderCapture.SecOpenOrder.ScSooSecurityNo)
   
RETURN
*** </region>

*** <region name= READ.SC.PARAM>
READ.SC.PARAM:
*** <desc> </desc>
    READ.ERROR = ''
    R.SC.PARAM = ''
    ST.CompanyCreation.EbReadParameter('F.SC.PARAMETER','N','',R.SC.PARAM,'','',READ.ERROR)

RETURN
*** </region>
** If the security master has upfront int account then default the upfront txn code from SC.PARAMETER to TRANSACTION CODE
CHECK.UPFRONT.INT.ACC:

    IF R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmUpfrontIntAcc> NE '' THEN
        GOSUB READ.SC.PARAM ; *
        IF R.SC.PARAM<SC.Config.Parameter.ParamUpfrontTxnCode,1> THEN
            VALUE = R.SC.PARAM<SC.Config.Parameter.ParamUpfrontTxnCode,1>
            EB.SystemTables.setComi(VALUE)
        END
        
    END

RETURN



*-----------------------------------------------------------------------------

*** <region name= READ.SC.ORDERTYPE>
READ.SC.ORDERTYPE:
*** <desc> </desc>
    R.SC.ORDER.TYPE = ''
    ORD.TYPE.ERR = ''
    R.SC.ORDER.TYPE = SC.SctOrderCapture.OrderType.CacheRead(ORD.TYPE, ORD.TYPE.ERR)

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= READ.SC.TRA.CODE>
READ.SC.TRA.CODE:
*** <desc> </desc>
    R.SC.TRA.CODE = ''
    TRANS.ERR= ''
    R.SC.TRA.CODE = SC.Config.ScTraCode.CacheRead(TRANS.CODE, TRANS.ERR)
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= READ.SC.TRANS.TYPE>
READ.SC.TRANS.TYPE:
*** <desc> </desc>
    TRANS.TYPE.ERR = ''
    R.SC.TRANS.TYPE = ''
    R.SC.TRANS.TYPE = SC.Config.TransType.CacheRead(TRA.TYPE, TRANS.TYPE.ERR)
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= READ.SECURITY.MASTER>
READ.SECURITY.MASTER:
*** <desc> </desc>
    R.SECURITY.MASTER = '' ; SM.ERR = ''
    R.SECURITY.MASTER = SC.ScoSecurityMasterMaintenance.SecurityMaster.Read(SM.ID, SM.ERR)
RETURN
*** </region>

END


