* @ValidationCode : MjoxMDczMDI4NjAxOkNwMTI1MjoxNTgyMjgxODkwOTYwOnByaXlhZGhhcnNoaW5pazoyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAyLjA6MjI6MjI=
* @ValidationInfo : Timestamp         : 21 Feb 2020 16:14:50
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : priyadharshinik
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 22/22 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.ID.TYPE.BENEFICIARY(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
* The routine will be attached as a link routine in TX.TXN.BASE.MAPPING record.
* It returns "LEI" else "BLANK" from the table OC.PARAMETER.
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
* Ret.val- returns "LEI" else "BLANK" from the table OC.PARAMETER.
*
*
*******************************************************************
* Modification History :
*
* 31/01/2020 - Enhancement 3562849 / Task 3562851
*              CI #3 - Mapping Routines
*
*-----------------------------------------------------------------------------

    $USING OC.Parameters
    $USING FR.Contract
    $USING EB.SystemTables
    $USING ST.CompanyCreation
    
    GOSUB INITIALISE ; *
    GOSUB PROCESS ; *
    
RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>
    OcParamId = ""
    OcParamRec = ""
    BankLei = ""
    RET.VAL = ""

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    IF (APPL.ID[1,2] EQ "FX") OR (APPL.ID[1,2] EQ "FR") OR (APPL.ID[1,2] EQ "ND") OR (APPL.ID[1,2] EQ "SW") OR (APPL.ID[1,2] EQ "DX") THEN
        OcParamId = EB.SystemTables.getIdCompany()
        OcParamErr = ''
        ST.CompanyCreation.EbReadParameter('F.OC.PARAMETER', '', '', OcParamRec, OcParamId, '', OcParamErr)
        
        IF OcParamRec THEN
            BankLei = OcParamRec<OC.Parameters.OcParameter.ParamBankLei>
        
            IF BankLei THEN
                RET.VAL = "LEI"
            END ELSE
                RET.VAL = ""
            END
        END
    END

RETURN
*** </region>

END


