* @ValidationCode : Mjo1NzI3NjA4OTI6Q3AxMjUyOjE1OTU1MTA4NjQwNzg6ZHBvb3JuaW1hOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDcuMjAyMDA2MjQtMTUyODo3Mzo2MA==
* @ValidationInfo : Timestamp         : 23 Jul 2020 18:57:44
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : dpoornima
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 60/73 (82.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202007.20200624-1528
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.ModelBank
SUBROUTINE SC.GET.CG.UNREALIZED.GAIN(ID.CG.TXN.BASE, END.DATE, RETURN.CG.BASE.DATA)
*-----------------------------------------------------------------------------
*
* Incoming parameter :
* ID.CG.TXN.BASE    - Id of CG.TXN.BASE
* END.DATE          - Date till which unallocation to be performed
*
* Outgoing parameter :
* RETURN.CG.BASE.DATA   - Details fetched from CG.TXN.BASE
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 22/07/2020 - TASK 3870782
*              CGT API - No File Enquiry routines to be converted as API with Public access
*-----------------------------------------------------------------------------
    $USING SC.SctCapitalGains
    $USING EB.SystemTables
    $USING SC.ScoSecurityMasterMaintenance
    
    GOSUB INITIALISE ; *
    GOSUB BUILD.CG.TXN.BASE.DATE ; *Read Cg Txn Base Record from id and frame the base DATA
 
RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>

    SECURITY.NO = FIELD(ID.CG.TXN.BASE,'.',3)
    RETURN.CG.BASE.DATA = ''

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= BUILD.CG.TXN.BASE.DATE>
BUILD.CG.TXN.BASE.DATE:
*** <desc>Read Cg Txn Base Record from id and frame the base DATA </desc>

    E.CG.TXN.BASE = ''
    R.CG.TXN.BASE = SC.SctCapitalGains.CgTxnBase.Read(ID.CG.TXN.BASE, E.CG.TXN.BASE)
    GOSUB UNALLOCATE.TXNS          ; *Unallocate all the disposal transactions that has taken place after portfolio lock date if mentioned
    GOSUB ASSIGN.COMMON ; *Assign the common vaiables with R.CG.TXN.BASE record

RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= UNALLOCATE.TXNS>
UNALLOCATE.TXNS:
*** <desc>Unallocate all the disposal transactions that has taken place after portfolio lock date if mentioned </desc>

    IF END.DATE THEN
* Unallocate all the txn after EFFECTIVE DATE so that all the open lots will be presented to user
        INPUT.ID = ID.CG.TXN.BASE
        INPUT.REC = ""
        INPUT.REC<SC.SctCapitalGains.CgUnallocateTillDate> = END.DATE
        ACTION = "UNALLOCATE"
        OVERRIDE.MSGS = ""
        ORIGIN = "UNALLOCATE"
        ORIGIN<3> = "" ;* Donot update Other files when CG.ENH.PROCESS is set like CG.TXN.EFF.LIST , CG.TXN.DETS
        TRA.CODE = ""
        SC.SctCapitalGains.ScPrepareCgBaseUpdate(R.CG.TXN.BASE, INPUT.REC, INPUT.ID, ACTION, OVERRIDE.MSGS, ORIGIN, TRA.CODE)
    END ELSE
*To get CgParameter, CgCalcParam values incommon variables, calling InitCgCommmon routine
        SC.SctCapitalGains.setCgBuildCgTxnBase(R.CG.TXN.BASE)                     ;*setting common variable as CgTxnBase record        INPUT.REC = ''
        INPUT.REC<SC.SctCapitalGains.CgTxnBase.CgTxnOrigSam> = FIELD(ID.CG.TXN.BASE,'.',2)
        INPUT.ID = ID.CG.TXN.BASE
        ORIGIN = "MANUAL"
        SC.SctCapitalGains.ScInitCgCommon("INITIALISE", R.CG.TXN.BASE, INPUT.REC, INPUT.ID, ACTION, OVERRIDE.MSGS, ORIGIN, R.TXN.RULES)
        SC.SctCapitalGains.ScInitCgCommon("INIT.SECURITY", R.CG.TXN.BASE, INPUT.REC, INPUT.ID, ACTION, OVERRIDE.MSGS, ORIGIN, R.TXN.RULES)
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= ASSIGN.COMMON>
ASSIGN.COMMON:
*** <desc>Assign the common vaiables with R.CG.TXN.BASE record </desc>

    BASE.SECURITY = FIELD(ID.CG.TXN.BASE,'.',3)
    SECURITY.NO = BASE.SECURITY
    GOSUB READ.SM ; *Get SecurityMaster record
    GOSUB GET.SALE.PRICE ; *Get SalePrice for Unrealised enquiry
    SC.SctCapitalGains.setCgBuildCgTxnBase(R.CG.TXN.BASE)                     ;*setting common variable as CgTxnBase record
    CG.TXN.POS = DCOUNT(R.CG.TXN.BASE<SC.SctCapitalGains.CgTxnBase.CgTxnTradeDateTime>,@VM)  ;* No.of Transactions in CgTxnBase record
*Passing Income param follows
* [1,1] -> 'UNREAL.ENQ' - To indicate it is Enquiry requirement to get the credit transaction details
* [1,2] -> LastPrice of SM -> for unrealized scenario, Gain/Loss of each credit txn is determined by LastPrice of SM
* [1,3] -> Total No.of.Transactions from which the credit txn details needs to get
    ENQ.VAL = 'UNREAL.ENQ':@VM:SALE.PRICE:@VM:CG.TXN.POS:@VM:END.DATE
*Routine which will return the credit txn details
    SC.SctCapitalGains.GetCgMinmaxList('','','',ENQ.VAL,'')
*set returned values of CgTxnBase
    RETURN.CG.BASE.DATA = RAISE(ENQ.VAL)

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= READ.SM>
READ.SM:
*** <desc>Get SecurityMaster record </desc>

    R.SM = ''                            ;* Record variable of SecurityMaster
    SM.ERR = ''                          ;* Read Err
    R.SM = SC.ScoSecurityMasterMaintenance.SecurityMaster.Read(SECURITY.NO, SM.ERR) ;*Reading SecurityMaster record
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.SALE.PRICE>
GET.SALE.PRICE:
*** <desc>Get SalePrice for Unrealised enquiry </desc>

    SALE.PRICE = ''   ;*SalePrice
*Check the current processing CgTxnBase belongs to Child Staple Security
    IF R.CG.TXN.BASE<SC.SctCapitalGains.CgTxnBase.CgTxnStapledSecurity> = 'CHILD' THEN
        PARENT.SEC = ''
        PARENT.SEC = R.SM<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmStapledParentSec>  ;*Parent Staple Security
        R.STAPLE.COMP = ''
        TRD.DATE = ''
        TRD.DATE = EB.SystemTables.getToday()       ;*Date in which report is running
        R.STAPLE.COMP = ''
        CHILD.SEC = ''
        SC.SctCapitalGains.GetStapledCompRecord(PARENT.SEC,TRD.DATE,R.STAPLE.COMP,'','')  ;*Get Staple Component split
*If Staple Component is available then Sale Price will beParent Last price apportioned with child value split
        IF R.STAPLE.COMP THEN
            CHILD.SEC = SECURITY.NO  ;*Child Staple Security
            CHD.POS = ''
*Check Child staple is available in StapledComponent then get the Value split for that child
            LOCATE CHILD.SEC IN R.STAPLE.COMP<SC.SctCapitalGains.StapledComponent.SscStapledComp,1> SETTING CHD.POS THEN
                SECURITY.NO = PARENT.SEC
                GOSUB READ.SM  ;*read parent security
                PARENT.LAST.PRICE = ''
                PARENT.LAST.PRICE = R.SM<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmLastPrice>  ;*Last price of parent
*Sale Price for Child is Value Split applied on Parent LastPrice
                SALE.PRICE = PARENT.LAST.PRICE * (R.STAPLE.COMP<SC.SctCapitalGains.StapledComponent.SscValueSplit,CHD.POS> / 100)
            END ELSE
*If child is not available in Stapled Component, then Last price of Child will be taken for processing
                SALE.PRICE = R.SM<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmLastPrice>
            END
        END ELSE
*If Stapled Component is not available, then Last price of Child will be taken for processing
            SALE.PRICE = R.SM<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmLastPrice>
        END
    END ELSE
*If if is not a Stapled Component's CgTxnBase, then Last price of Security in CgTxnBase id will be taken for processing
        SALE.PRICE = R.SM<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmLastPrice>
    END
    
RETURN
*** </region>

END
