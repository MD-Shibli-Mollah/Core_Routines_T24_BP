* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 4 29/05/01  GLOBUS Release No. G12.2.00 04/04/02
*-----------------------------------------------------------------------------
* <Rating>126</Rating>

    $PACKAGE FT.Contract
    SUBROUTINE VALIDATE.BANK.FIELD(SW.ADDR.INDICATOR, VALIDATION.TYPE)
**************************************************************************
*                                                                        *
*  Description    : This routine validates the input to the Bank field.  *
*                   If there in no input then no validation is done      *
*                   Checks for number of lines entered, if more than 1   *
*                   lines are entered then the sub checks that this      *
*                   does not exceed the maximum permitted number of lines*
*                   If SWIFT ID is entered then it checks that this is   *
*                   in correct SWIFT format.                             *
*                   If customer number is entered then it ensures        *
*                   that the customer has a SWIFT ADDRESS                *
*                                                                        *
**************************************************************************
*
* PARAMETERS
*
*The field to be checked is in R.NEW(AF)
*
* SW.ADDR.INDICATOR
*   Y            Bank field can have Swift ID prefixed by SW-
*
*VALIDATION.TYPE
*
*      1            Customer no is valid customer and should have SWIFT ID
*      2            Customer no should be in Agency record
*
*      3            Customer number or if prefixed by SW- is a valid swift
*                   ID should be on agency file
*
*      all other validations are still performed
*      4            If prefixed by SW- then should be on agency file. This is
*                   to validate the customer with sw- and no checks for number
*                   of lines etc. are done in this case
*
*      5            It checks for valid customer. If it is valid customer,
*                   it checks whether customer has valid swift address.
*                   Values entered must be either valid customer or valid swift BIC code.
*** RETURN PARAMETERS
*
*   Field 2  :       Maximum lines allowed.

*Returns ETEXT with error message
**
**
*************************************************************************
*                                                                       *
*  Modifications  :                                                     *
*
* 26/06/ 00 - GB0001591
*              Allow a single line of text in bank field
*                                                                                                                                             *
*
* 10/07/00 -  GB0001721
*              Add extra cases of validations
*
* 28/11/01 - CI-10000535
*            When committing the Outward Telegraphic Transfer
*            how an error message as "Swift Address is Missing".
*
* 20/05/02 - CI_10002050
*            BEN.CUSTOMER Field accepts only 2 lines .

*
* 23/06/02 - CI_10002387
*            For inward Transactions if the Ordering bank is customer
*            Allow maximum 4 lines to be input.

* 23/09/02 - GLOBUS_EN_10001180
*          Conversion Of all Error Messages to Error Codes
*
* 01/02/03 - EN_10001616
*            Supporting 103+ and 103 extended remittance in FT.
*            Validation type 5 is introduced in this routine to
*            validate the valid customer and valid swift code.
* 02/06/03 - CI_100019550 / CI_10009573
*            Checking the no.of multivalues of the field BEN.CUSTOMER
*            in FT with NO.LINES in FT.BC.PARAMETER is only for the TXN.
*            TYPES deifined in the FT.LOCAL.CLEARING
*
* 18/08/03 - CI_10011732
*            If the bank fields has more than one line and non bic code is
*            present ETEXT must be set.
*
* 18/11/03 - CI_10014913
*            REF: HD0314866
*            INSERT and OPF of FT.CUSTOMER.CONDITION is removed, since
*            the pgm is made obsolete.
*
* 24/12/03 - EN_10002100
*            BIC Addresses used needs to be validated against BIC
*            Table. The 11 and 8 digit BIC.CODE is checked with BIC
*            table and if not found , the 8 digit code is padded with XXX.
*      The 11 digit and padded 8 digit , if not found in BIC table
*      pops up an error message.
*
* 30/03/05 - CI_10028748
*            Maximum lines allowed can be defined in VALIDATION.TYPE<2>.
*
* 08/03/07 - BG_100013209
*            CODE.REVIEW changes.
*
* 15/07/10 - Task 66080
*            Change the reads to Customer to use the Customer
*            Service api calls
*
* 10/09/15 - Enhancement 1265068 / Task 1466516
*          - Routine incorporated
*************************************************************************

    $USING FT.Contract
    $USING AC.AccountOpening
    $USING FT.Clearing
    $USING FT.Config
    $USING ST.Config
    $USING ST.CompanyCreation
    $USING DE.Config
    $USING EB.ErrorProcessing
    $USING EB.Template
    $USING DE.API
    $USING EB.SystemTables

    $INSERT I_CustomerService_NameAddress
    $INSERT I_CustomerService_AddressIDDetails
    $INSERT I_CustomerService_SWIFTDetails

** Open files


* save comi value
    COMI.SAVE = EB.SystemTables.getComi()
    EB.SystemTables.setEtext("")
    YENRI = ""
    CUS.LENGTH = 11 ;* EN_10001616 S/E
*no input - so no check
    AF1 = EB.SystemTables.getAf()
    IF EB.SystemTables.getRNew(AF1) = '' THEN
        RETURN
    END

    AF1 = EB.SystemTables.getAf()
    IF SW.ADDR.INDICATOR[1,1] NE 'Y' AND EB.SystemTables.getRNew(AF1)<1,1>[1,3] EQ "SW-" THEN
        EB.SystemTables.setAv(1)
        EB.SystemTables.setEtext('FT.RTN.INVALID.TRANSACTION.TYPE')
        EB.ErrorProcessing.StoreEndError()
        RETURN
    END

* CI_10028748 S
    LINE.MAX = ''
    LINE.MAX = VALIDATION.TYPE<2>
    VALIDATION.TYPE = VALIDATION.TYPE<1>
* CI_10028748 E

    NO.LINES = ''
    AF1 = EB.SystemTables.getAf()
    NO.LINES = COUNT(EB.SystemTables.getRNew(AF1),@VM) + 1
    G$LINE.MAX = ''


    IF NO.LINES GT 1 THEN
        * CI_10002050 S
        *         IF FTLC$BC.DEF(AF)<1> THEN
        * CI_10009550 - S
        *         IF (R.NEW(FT.TRANSACTION.TYPE)[1,2] MATCHES ('BC':VM:'BI':VM:'BD') ) AND FTLC$BC.DEF(AF)<1> THEN
        GOSUB GET.MAX.LINES   ;*BG_100013209 - S / E
    END ELSE

        **single line of SWIFT Address or Customer number
        * 6 changed as CUS.LENGTH since length of the customer is increased.
        AF1 = EB.SystemTables.getAf()
        IF EB.SystemTables.getRNew(AF1)<1,1>[1,3] NE "SW-" THEN
            GOSUB CHECK.VALIDATION.TYPE ;* BG_100013209 - S / E
            **GB0001591
            **code removed to allow single line of text
            **Swift Id

        END ELSE

            GOSUB VALIDATE.VALIDATION.TYPE        ;* BG_100013209 - S / E
        END
    END
*Code may be added to check if the SWIFT ID is an existing SWIFT CODE
*at later stage



**End of sub final return and end
    EB.SystemTables.setComi(COMI.SAVE)
*for other validations
    RETURN
*
*************************************************************************************************************
*
* BG_100013209 - S
*=============
GET.MAX.LINES:
*=============

    CLR.TYPES = FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcTxnType)
    LOCATE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.TransactionType) IN CLR.TYPES<1,1> SETTING CLR.POS ELSE
    CLR.POS = 0 ;* BG_100013209 - S
    END   ;* BG_100013209 -E

    AF1 = EB.SystemTables.getAf()
    IF CLR.POS AND FT.Clearing.getFtlcBcDef(AF1)<1> THEN
        * CI_10009550 - E
        AF1 = EB.SystemTables.getAf()
        LINE.MAX = FT.Clearing.getFtlcBcDef(AF1)<1>
        G$LINE.MAX = LINE.MAX
    END ELSE
        * CI_10028748 S
        * Default 4 only if undefined in Validation type<2>.

        IF NOT(LINE.MAX) THEN
            LINE.MAX = 4
        END
        * CI_10028748 E
    END
**Get max lines from common area if set else
** use 4
    AF1 = EB.SystemTables.getAf()
    IF NO.LINES > LINE.MAX THEN
        FOR AV.CNT = LINE.MAX+1 TO NO.LINES
            EB.SystemTables.setAv(AV.CNT)
            IF G$LINE.MAX THEN
                EB.SystemTables.setEtext('FT.RTN.EXCEEDED.LINES.ALLOWED.BY.LOCAL.CLEARING')
                * CI_10002050 E
            END ELSE
                EB.SystemTables.setEtext("FT.RTN.MAX.NO.LINES.EXCEEDED")
            END
            EB.ErrorProcessing.StoreEndError()
        NEXT AV.CNT
    END ELSE
        **check for null fields
        EB.Template.FtNullsChk()
    END
    IF EB.SystemTables.getRNew(AF1)<1,1>[1,3] EQ "SW-" THEN
        **Multi values are not allowed with SWIFT Address
        FOR AV.CNT = 2 TO NO.LINES
            EB.SystemTables.setAv(AV.CNT)
            EB.SystemTables.setEtext('FT.RTN.MULTI.VALUE.NOT.ALLOWED.WITH.SWIFT.ADDRESS')
            EB.ErrorProcessing.StoreEndError()
        NEXT AV.CNT
    END
    IF EB.SystemTables.getRNew(AF1)<1,1> MATCHES "1N0N" THEN
        **multivalue lines not allowed with customer number
        * CI_10002387 S
        * In case of Inward Type of Ft Transactions, Skip the validation.
        IF NOT ( EB.SystemTables.getRNew(FT.Contract.FundsTransfer.TransactionType)[1,1] = 'I' AND AF1 = FT.Contract.FundsTransfer.OrderingBank ) THEN
            * CI_10002387 E
            FOR AV.CNT = 2 TO NO.LINES
                EB.SystemTables.setAv(AV.CNT)
                EB.SystemTables.setEtext('FT.RTN.MULTI.VALUE.NOT.ALLOWED.WITH.CU.NO')
                EB.ErrorProcessing.StoreEndError()
            NEXT AV.CNT
        END
    END   ;* CI_10002387 S/E
* CI_10011732 s
    IF VALIDATION.TYPE EQ 5 THEN
        IF EB.SystemTables.getRNew(AF1)<1,1>[1,3] NE "SW-" AND NOT(EB.SystemTables.getRNew(AF1)<1,1> MATCHES "1N0N") THEN
            EB.SystemTables.setAv(1)
            EB.SystemTables.setEtext("FT.RTN.VALUE.CUST.NO.OR.SWIFT.CODE")
        END
    END
* CI_10011732 e

    RETURN
*
*************************************************************************************************************
*
*=====================
CHECK.VALIDATION.TYPE:
*=====================


    AF1 = EB.SystemTables.getAf()
    IF EB.SystemTables.getRNew(AF1) MATCHES "1N0N" AND LEN(EB.SystemTables.getRNew(AF1)) LE CUS.LENGTH THEN ;* EN_10001616 S/E
        SW.CUST.NO = EB.SystemTables.getRNew(AF1)
        ERR.MSG = ""
        EB.SystemTables.setEtext("")

        GOSUB CHECK.ON.VALIDATION.TYPE  ;* BG_100013209 - S / E
        * EN_10001616 - S
        *            END
    END ELSE
        IF VALIDATION.TYPE = 5 THEN
            EB.SystemTables.setEtext("FT.RTN.VALUE.CUST.NO.OR.SWIFT.CODE")
        END
    END
* EN_10001616 - E

    RETURN
*
*************************************************************************************************************
*
*========================
CHECK.ON.VALIDATION.TYPE:
*=========================


    BEGIN CASE
            * Deleted the test Case for VALIDATION.TYPE = 1 for CI-10000535

        CASE VALIDATION.TYPE = 2 OR VALIDATION.TYPE = 3

            YENRI = ""
            R.AG.REC = ST.Config.Agency.Read(SW.CUST.NO, ER)
            YENRI = R.AG.REC<ST.Config.Agency.EbAgAutorouting>
            EB.SystemTables.setEtext(ER)
            IF ER NE '' THEN
                EB.SystemTables.setAv(1)
                EB.ErrorProcessing.StoreEndError()
            END
            **GB0001721S
        CASE VALIDATION.TYPE = 4
            *valid customer
            *Insert validate against BIC file then agency.
            YENRI = ""
            EB.SystemTables.setEtext('')
            customerKey = SW.CUST.NO
            customerNameAddress = ''
            prefLang = EB.SystemTables.getLngg()
            CALL CustomerService.getNameAddress(customerKey,prefLang,customerNameAddress)
            YENRI = customerNameAddress<NameAddress.shortName>

            IF EB.SystemTables.getEtext() NE '' THEN
                EB.SystemTables.setAv(1)
                EB.ErrorProcessing.StoreEndError()
            END
            * EN_10001616 - S
        CASE VALIDATION.TYPE = 5
            YENRI = ""
            EB.SystemTables.setEtext('')
            customerKey = SW.CUST.NO
            customerNameAddress = ''
            prefLang = EB.SystemTables.getLngg()
            CALL CustomerService.getNameAddress(customerKey,prefLang,customerNameAddress)
            YENRI = customerNameAddress<NameAddress.shortName>
            IF EB.SystemTables.getEtext() NE '' THEN
                EB.SystemTables.setAv(1)
            END ELSE
                keyDetails = ''
                keyDetails<AddressIDDetails.customerKey> = SW.CUST.NO
                keyDetails<AddressIDDetails.preferredLang> = 1
                keyDetails<AddressIDDetails.companyCode> = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCustomerCompany)
                keyDetails<AddressIDDetails.addressNumber> = 1
                address = ''
                CALL CustomerService.getSWIFTAddress(keyDetails, address)
                IF EB.SystemTables.getEtext() = '' THEN
                    YENRI = address<SWIFTDetails.code>
                END ELSE
                    * Error processing
                    EB.SystemTables.setEtext("FT.RTN.MISSING.SWIFT.REC")
                    EB.SystemTables.setAv(1)
                END
            END
            * EN_10001616 - E
    END CASE
**GB0001721E
    RETURN
*
*************************************************************************************************************
*
*========================
VALIDATE.VALIDATION.TYPE:
*========================

    EB.SystemTables.setEtext('')
    AF1 = EB.SystemTables.getAf()
    EB.SystemTables.setComi(EB.SystemTables.getRNew(AF1)[4,99])
    EB.SystemTables.setAv(1)
    BEGIN CASE
        CASE VALIDATION.TYPE = 1 OR VALIDATION.TYPE = 2
            DE.API.ValidateSwiftAddress("1","1")
            IF EB.SystemTables.getEtext() NE '' THEN

                EB.ErrorProcessing.StoreEndError()
            END
            **GB0001721S

        CASE VALIDATION.TYPE = 3 OR VALIDATION.TYPE = 4 OR VALIDATION.TYPE = 5      ;* EN_10001616 S/E

            YENRI = ""
            AF1 = EB.SystemTables.getAf()
            BIC.AGENCY = EB.SystemTables.getRNew(AF1)          ;* agent with sw-
            R.AG.REC = ST.Config.Agency.Read(BIC.AGENCY, ER)
            YENRI = R.AG.REC<ST.Config.Agency.EbAgAutorouting>
            EB.SystemTables.setEtext(ER)
            IF ER NE '' THEN

                GOSUB CALL.DE.VALIDATE.SW.ADDR        ;* BG_100013209 - S / E
                ** EN_10002100 - S
                **  For VALIDATION.TYPE 3 , 4 & 5 , the check for the existence of the BIC record in DE.BIC table is done irrespective of the existence in AGENCY record.
            END ELSE

                DE.API.ValidateSwiftAddress("1","1")
                IF EB.SystemTables.getEtext() NE "" THEN
                    EB.ErrorProcessing.StoreEndError()
                    RETURN
                END
            END
            ** EN_10002100 - E

    END CASE
**GB0001721E
    RETURN
*
**************************************************************************************************************
*
*========================
CALL.DE.VALIDATE.SW.ADDR:
*========================


    IF VALIDATION.TYPE NE 4 AND VALIDATION.TYPE NE 5 THEN   ;* EN_10001616 S/E
        EB.SystemTables.setAv(1)
        EB.ErrorProcessing.StoreEndError()
    END ELSE
        ** EN_10002100 - S/E  ** Removed the duplicate checks that pre-exists in the DE.VALIDATE.SWIFT.ADDRESS program.
        DE.API.ValidateSwiftAddress("1","1")
        IF EB.SystemTables.getEtext() NE '' AND VALIDATION.TYPE NE 5 THEN        ;* EN_10001616 S/E
            EB.ErrorProcessing.StoreEndError()
        END
    END

    RETURN          ;* BG_100013209 - E
*
**************************************************************************************************************
*
    END
