* @ValidationCode : MjoxNzU0NjcyMDEzOkNwMTI1MjoxNjAyOTQ4MDQ5MDU5OmFzdXJ5YTo3OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEwLjIwMjAxMDAxLTA1MTU6ODU6ODQ=
* @ValidationInfo : Timestamp         : 17 Oct 2020 20:50:49
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : asurya
* @ValidationInfo : Nb tests success  : 7
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 84/85 (98.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20201001-0515
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AC.AccountOpening
SUBROUTINE AC.GET.ALT.ACCT.ID(MAT AccountRecord, AltAcctIdErr)
*-----------------------------------------------------------------------------
*** <region name= Desc>
*** <desc>It describes the routine </desc>
* This is an api to get alternate account id from local rotine attached in the application ALT.ACCT.PARAMETER.
*
* AC.GET.ALT.ACCT.ID is an api to capture alternate account id from local routine
*-----------------------------------------------------------------------------
* @uses AC.AccountOpening
* @uses EB.SystemTables
* @uses EB.API
* @uses ST.CompanyCreation
* @package AC.AccountOpening
* @class AC.GET.ALT.ACCT.ID
* @stereotype application
* @author jabinesh@temenos.com
*** </region>
*-----------------------------------------------------------------------------
* Incoming Arguments:
*-----------------------------------------------------------------------------
* AccountRecord        - Holds the account record values and alternate account id get from local api is also updated in the same argument
* AltAcctIdErr         - Holds the account number value
*
*-----------------------------------------------------------------------------
* Outgoing Arguments:
*-----------------------------------------------------------------------------
* AltAcctIdErr<1, xx>      - Holds the error value returned while executing the local api
* AltAcctIdErr<2, xx>      - Holds the position of alt acct id which failed
* AltAcctIdErr<3, xx>      - Holds the Override message id
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 21/12/18 - Enhancement 2849854 / Task 2849880
*            New api AC.GET.ALT.ACCT.ID is introduced to get alternate account id from local routine
*
* 12/06/19 - Defect 3186632 / Task 3195070
*            Account number is passed to as incoming argument and duplications of alternate ids are checked.
*
* 08/04/20 - Enhancement 3401453 / Task 3688280
*            ALT.ACCT.GEN.API has been enable to attach the L3 java program.
*            Changes has been done to support the user exit calls through java interface.
*
* 31/07/2020 - Defect 3873539 / Task 3888772
*              ALT.ACCT.PARAMETER read changed to CACHE.READ
*-----------------------------------------------------------------------------
    $USING AC.AccountOpening
    $USING EB.API
    $USING ST.CompanyCreation
    $USING EB.SystemTables
*-----------------------------------------------------------------------------
    GOSUB initialise
    GOSUB Process
RETURN
*-----------------------------------------------------------------------------
*** <region name= initialise>
*** <desc>Initialisation </desc>
initialise:
    
    AccNum = AltAcctIdErr
    AltAcctIdErr = ''
    NoOfAltAcctType = DCOUNT(AccountRecord(AC.AccountOpening.Account.AltAcctType), @VM)
    Application = EB.SystemTables.getApplication()
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process>
*** <desc>Process </desc>
Process:
    
    FOR AltAcctTypeCnt = 1 TO NoOfAltAcctType
        AltAcctId = AccountRecord(AC.AccountOpening.Account.AltAcctId)<1, AltAcctTypeCnt>
        AltAcctType = AccountRecord(AC.AccountOpening.Account.AltAcctType)<1, AltAcctTypeCnt>
        OveRaised = ''                                                  ;* Flag indicates override raised for that particular alt acct type
        
        BEGIN CASE
                
            CASE Application EQ 'AA.SIM.ACCOUNT' AND AltAcctId          ;* When this api is called from AA.SIM.ACCOUNT, alternate account ids duplication should be checked
                GOSUB CheckAltIdDup                                     ;* Check ALT.ACCT.ID duplication
                IF NOT(OveRaised) THEN                                  ;* When there is no override, then move to next alt acct id
                    CONTINUE
                END
        
            CASE AltAcctId OR AltAcctType EQ 'T24.IBAN'                 ;* When this api is called from other applications expect AA.SIM.ACCOUNT
                CONTINUE
        END CASE
    
        RAltAcctParameter = ''
        AltAcctErr = ''
        RAltAcctParameter = AC.AccountOpening.AltAcctParameter.CacheRead(AltAcctType, AltAcctErr)    ;* Read the ALT.ACCT.PARAMETER record

        IF AltAcctErr THEN
            CONTINUE
        END
    
        AltAcctGenApi = RAltAcctParameter<AC.AccountOpening.AltAcctParameter.AlacParAltAcctGenApi>
        
        IF AltAcctGenApi THEN
            EbApiRec = ''
            CompiledOrNot = ''
            ReturnInfo = ''
            
            EbApiRec = EB.SystemTables.Api.Read(AltAcctGenApi, ApiErr)
            SourceType = EbApiRec<EB.SystemTables.Api.ApiSourceType>
            IF SourceType EQ "BASIC" THEN
                EB.API.CheckRoutineExist(AltAcctGenApi, CompiledOrNot, ReturnInfo) ;* Check the local routine availability and compilation
            END ELSE
                CompiledOrNot = 1
            END
            IF CompiledOrNot THEN
                IF AltAcctType EQ 'T24.IBAN' THEN
                    IF OveRaised THEN               ;* When duplication occured in IBAN and local api also attached in the T24.IBAN type, then set the alt acct id value to null. So that new IBAN will be regenerated in the AC.GET.IBAN
                        AccountRecord(AC.AccountOpening.Account.AltAcctId)<1, AltAcctTypeCnt> = ''
                    END
                    CONTINUE
                END
                GOSUB GenerateAltId ; *Alternate Id generation
                AccountRecord(AC.AccountOpening.Account.AltAcctId)<1, AltAcctTypeCnt> =  AltAcctId<1>
            END
        END
    NEXT AltAcctTypeCnt
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CheckAltIdDup>
CheckAltIdDup:
*** <desc>Check ALT.ACCT.ID duplication </desc>
*** Read the alternate account table with alt acct id and check the globus account no should be same as the account number passed as incoming.
*** Otherwise override should be raised.
    AltAcEr = ''
    AltAcRec = AC.AccountOpening.AlternateAccount.Read(AltAcctId, AltAcEr)
    IF AltAcRec AND AltAcRec<AC.AccountOpening.AlternateAccount.AacGlobusAcctNumber> NE AccNum THEN
        OveDetail = 'AC-REGENERATE.ALT.ACCT.ID'
        OveRaised = 1                       ;* Flag indicate override is raised for this alt acct id
        AltAcctIdErr<3, -1> =  OveDetail    ;* Update override message
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GenerateAltId>
GenerateAltId:
*** <desc>Alternate Id generation </desc>
    EB.SystemTables.setEtext('')
    EbApi = ''
    AltAcctId = ''
    HookId = "HOOK.ALT.ACCT.PARAM.ALT.ACCT.GEN" ;*Name of the data record which will contains the interface details
    EbApi<1> = AltAcctGenApi   ;* assign the name of the hook attached
    EbApi<4> = "1" ;* Number of arguments to be attached
    EbApi<6> = HookId ;*
    Arguments = ""
    EB.SystemTables.CallApi(EbApi, Arguments)  ;* Trigger the attached hook through EB.CALL.API
    AltAcctId<1> = Arguments
    IF EB.SystemTables.getEtext() THEN
        AltAcctIdErr<1, -1> = EB.SystemTables.getEtext()
        AltAcctIdErr<2, -1> = AltAcctTypeCnt
    END ELSE
        IF Application EQ 'AA.SIM.ACCOUNT' THEN
            GOSUB CheckGenAltIdDup ; *Check Generated Alt id duplication
        END
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CheckGenAltIdDup>
CheckGenAltIdDup:
*** <desc>Check Generated Alt id duplication </desc>
*** Alt Acct Ids generated from the local api is checked against duplication. If duplication is occured, new ids will be regenerated.
    AltAcEr = ''
    AltAcRec = AC.AccountOpening.AlternateAccount.Read(AltAcctId, AltAcEr)
    IF AltAcRec AND AltAcRec<AC.AccountOpening.AlternateAccount.AacGlobusAcctNumber> NE AccNum THEN
        GOSUB GenerateAltId ; *Alternate Id regeneration
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------

END
