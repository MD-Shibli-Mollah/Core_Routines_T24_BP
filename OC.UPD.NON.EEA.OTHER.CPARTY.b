* @ValidationCode : MjotNjMzNzAwNjE4OmNwMTI1MjoxNDg3MDc3ODA3NTEyOmhhcnJzaGVldHRncjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE2MTIuMjAxNjExMDItMTE0MjotMTotMQ==
* @ValidationInfo : Timestamp         : 14 Feb 2017 18:40:07
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : harrsheettgr
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201612.20161102-1142
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.NON.EEA.OTHER.CPARTY(APPL.ID, APPL.REC, FIELD.POS, RET.VAL)
*-----------------------------------------------------------------------------
*****
*<Routine desc>
*
*The routine can be attached as LINK routine in tax mapping record
*to determine whether the deal counterparty has traded with non EEA bank.
*
* Incoming parameters:
*
* APPL.ID  - Id of transaction
* APPL.REC  - A dynamic array holding the contract.
* FIELD.POS - Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
*Ret.val - "Y" if trade with non -EEA t24 bank.
*		 - "N" if trade with European t24 bank.
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*
*-----------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING ST.Config
    $USING ST.CompanyCreation
*-----------------------------------------------------------------------------

    GOSUB INITIALIZE
    GOSUB PROCESS

    RETURN

INITIALIZE:
***<desc>Initialise the necessary variables</desc>

    COUNTRY.ID = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalCountry)

    R.COUNTRY = ''
    READ.ERR = ''

    RETURN

PROCESS:

    R.COUNTRY = ST.Config.Country.Read(COUNTRY.ID, READ.ERR);*read country record.
* Before incorporation : CALL F.READ(FN.COUNTRY, COUNTRY.ID, R.COUNTRY, F.COUNTRY, READ.ERR);*read country record.

    IF R.COUNTRY<ST.Config.Country.EbCouGeographicalBlock> EQ 'EUROPE' THEN;*check for geographical block.
        RET.VAL = 'N'
    END ELSE
        RET.VAL = 'Y'
    END

    RETURN

    END
