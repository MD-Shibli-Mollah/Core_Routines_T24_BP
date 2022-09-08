* @ValidationCode : Mjo0OTA4MDY2MjpDcDEyNTI6MTU4MjAyODUzMzkxNjpzdGFudXNocmVlOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDMuMjAyMDAyMTItMDY0NjozOTozNg==
* @ValidationInfo : Timestamp         : 18 Feb 2020 17:52:13
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : stanushree
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 36/39 (92.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.20200212-0646
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>19</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE  E.MB.FETCH.AC.950.ADDRESS(ENQ.DATA)
***************************************************
* Subroutine Type : Subroutine
* Attached to     : Enquiry ACCOUNT.STATEMENT
* Attached as     : Build Routine in the field BUILD.ROUTINE
* Incoming        : Common Variable O.DATA
* Outgoing        : Common Variable ENQ.DATA
* Purpose         : This subroutine will get the Account id from the ENQ DATA
*                 : Check if an alternate address has be specified for that account
*                 : to route print statements using DE.PRODUCT
*                 : If yes then set the 4th position of the passed id as the
*                 : print address number
* @author         : srajadurai@temenos.com
* Change history  :
* Version         : First Version

***************************************************
*
* 30/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 02/08/19 - Enhancement 3257457 / Task 3257461
*            Direct access to DE.PRODUCT removed
*
* 17/09/19 - Enhancement 3357571 / Task 3357573
*            Changes done for Movement of contact preferences to a separate Master Data Module from Delivery
*
*******************************************************************

    $USING EB.Reports
    $USING EB.SystemTables
    $USING DE.Config
    $USING EB.API
    $USING DE.API
    $USING ST.CompanyCreation
    $USING PF.Config

    DE.PRODUCT.REC = ""
    AC.ID=ENQ.DATA<4>
    IF INDEX(AC.ID,'.',1) THEN
        RETURN ;* Passed value is NOT just the account Id
    END


    SAVE.COMI=EB.SystemTables.getComi()
    EB.SystemTables.setComi(AC.ID)
    EB.API.In2Call('KEY','16.1','ANT')
    IF NOT(EB.SystemTables.getEtext()) THEN
        AC.ID=EB.SystemTables.getComi()
        
;* Setting up the Parameter of API DetermineCarrier
        companyId = EB.SystemTables.getIdCompany() ;* customer id
        cusCompany = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCustomerCompany) ;*customer Company Id
        customer = '' ;* Keeping null, To fetch account specific record.
        account = AC.ID ;* Account Id
        msgType = '950' ;* message type
        applic = '' ;* Application name
        prodKey = '' ;* Outparam
        errorMsg=''
            
        DE.API.DetermineCarrier(companyId,cusCompany,customer,account,msgType,applic,prodKey,DE.PRODUCT.REC,errorMsg) ;* API call to get the DE.PROCUCT record
        IF DE.PRODUCT.REC EQ '' THEN
            msgType = '' ;* Only there is no record for message type 950
            DE.API.DetermineCarrier(companyId,cusCompany,customer,account,msgType,applic,prodKey,DE.PRODUCT.REC,errorMsg) ;* API call to get the DE.PROCUCT record
        END

        IF DE.PRODUCT.REC THEN

* Check if there is a print carrier
* If yes, then fetch the Address Number

            NO.OF.ADDR=DCOUNT(DE.PRODUCT.REC<PF.Config.Product.PrdCarrAddNo>,@VM)
            FOR I = 1 TO NO.OF.ADDR
                IF FIELD(DE.PRODUCT.REC<PF.Config.Product.PrdCarrAddNo,I>,'.',1) ='PRINT' THEN
                    ADDR.NO=FIELD(DE.PRODUCT.REC<PF.Config.Product.PrdCarrAddNo,I>,'.',2)
                    EXIT
                END
            NEXT I
            IF ADDR.NO='1' THEN
* Nothing to do..

            END ELSE

* Also pass the address to choose

                RETURN.DATA=AC.ID:'...':ADDR.NO
                ENQ.DATA<4>=RETURN.DATA
            END

        END
    END

RETURN
*********
PROG.END:
*********
END

