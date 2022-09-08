* @ValidationCode : MjotNTIwMTI4MzEzOkNwMTI1MjoxNTk5NjQyMDI2MDQxOmFuaXR0YXBhdWw6NDowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNi4yMDIwMDUyNy0wNDM1OjI2OjI2
* @ValidationInfo : Timestamp         : 09 Sep 2020 14:30:26
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : anittapaul
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 26/26 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 2 25/05/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.ACCOUNT.IBAN

*--------------------------------------------------------------------------------
*** <region name= Program Description>
***
*  This routine will get the IBAN number for given customer account.
*
*** </region>
*--------------------------------------------------------------------------------

*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
* Input
*
* Output
*
*** </region>
*--------------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Change descriptions</desc>
* Modification History :
*
* 03/11/2016 - Task : 1902891
*              Enhancement : 1864620
*              Get IBAN number of customer account.
*
* 25/08/2020 - Task        : 3930267
*              Enhancement : 3930273
*              Skip IBAN processing if account id is arrangement id in case of microservices and fetch from arrangement conditions if present.
*
*** </region>
*--------------------------------------------------------------------------------
*
*** <region name= Inserts>
*** <desc>Inserts used in the sub-routine</desc>

    $USING EB.Reports
    $USING AC.AccountOpening
    $USING AA.Framework
    $USING AA.Account

*** </region>
*--------------------------------------------------------------------------------
*
*** <region name= Main Program block>
*** <desc>Main processing logic</desc>

    GOSUB GET.IBAN.NO

RETURN
*** </region>
*--------------------------------------------------------------------------------

*** <region name= Get Iban No>
*** <desc>Get the IBAN number from the account record</desc>
GET.IBAN.NO:
    
    ACC.NUM =  EB.Reports.getOData()
    IBAN = ''
    IF ACC.NUM[1,2] NE "AA" THEN ;*if account number is arrangement id skip IBAN processing.
    
        DIM R.ACCOUNT(AC.AccountOpening.Account.AuditDateTime)
        MAT R.ACCOUNT = ''
        
        ACCOUNT.REC = AC.AccountOpening.Account.Read(ACC.NUM, READ.ERROR)
        MATPARSE R.ACCOUNT FROM ACCOUNT.REC

        GENERATE.IBAN = ''
        

        AC.AccountOpening.AcGetIban(ACC.NUM, MAT R.ACCOUNT, COMPANY.CODE, GENERATE.IBAN, IBAN, ERROR.RESULT, CALL.FROM.AA, RESERVED.1, RESERVED.2)
    
    END ELSE
    
        ACCOUNT.RECORD = ""
        AA.Framework.GetArrangementConditions(ACC.NUM, "ACCOUNT", "", "","" , ACCOUNT.RECORD, "") ;* get account property record.
        ACCOUNT.RECORD = RAISE(ACCOUNT.RECORD)
        TYPE.POS = ''
        LOCATE "T24.IBAN" IN ACCOUNT.RECORD<AA.Account.Account.AcAltIdType,1> SETTING TYPE.POS THEN ;*if T24.IBAN alternate id type present, then get the corresponding Iban number.
            IBAN = ACCOUNT.RECORD<AA.Account.Account.AcAltId,TYPE.POS>
        END ELSE
            LOCATE "IBAN" IN ACCOUNT.RECORD<AA.Account.Account.AcAltIdType,1> SETTING TYPE.POS THEN ;* if IBAN alternate id type present, then get the corresponfing Iban number.
                IBAN =  ACCOUNT.RECORD<AA.Account.Account.AcAltId,TYPE.POS>
            END
        END
    END
    
    EB.Reports.setOData(IBAN)

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
