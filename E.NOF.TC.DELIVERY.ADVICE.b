* @ValidationCode : Mjo4Mzc1Njg3MjI6Q3AxMjUyOjE1NjUwODMzMTA1MDU6dmFpc2huYXZpdjo0OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTA4LjIwMTkwNzE3LTAyNTQ6MTM1OjEzMw==
* @ValidationInfo : Timestamp         : 06 Aug 2019 14:51:50
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vaishnaviv
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 133/135 (98.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.20190717-0254
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE DE.ModelBank
SUBROUTINE E.NOF.TC.DELIVERY.ADVICE(RET.DATA)
*------------------------------------------------------------------------------------------
* Description
*------------
* This routine fetches delivery advice details associated with a transaction reference
*
*------------------------------------------------------------------------------------------
* Routine type       : Enquiry Nofile routine
* Attached To        : TC.DELIVERY.ADVICE
*
*------------------------------------------------------------------------------------------
* Modification History :
*
* 29/09/15 - Enhancement 1270337 / Task 1457642
*            Trade - Export LC Amendment
* 11/11/15 - Defect 1528682 / Task 1528687
*            Componentisation Incorporation
* 13/11/16 - Defect 1913899 / Task 1920531
*            Only live record details need to be displayed to TCIB customer.
* 08/01/17 - Defect 1933261 / Task 1933257
*            Logic to fetch own bank advices has been added
*
* 11/03/17 - Defect 2021446 / Task 2049832
*            Short Name to be displayed for Swift Messages in Delivery Section.
*
* 30/10/18 - Enhancement 2822520 / Task 2849706
*            Code changed done for componentisation and to avoid errors while compilation
*            using strict compile
*
* 31/07/19 - Enhancement 3257432 / Task 3257434
*            Direct access to DE.ADDRESS removed
*-------------------------------------------------------------------------------

    $USING DE.ModelBank
    $USING EB.SystemTables
    $USING EB.Reports
    $USING DE.Config
    $USING ST.CompanyCreation
    $USING LC.Config
    $USING EB.DataAccess
    $USING ST.CustomerService
    $INSERT I_DAS.DE.I.HEADER
    $INSERT I_DAS.DE.O.HEADER
    
    GOSUB INITIALISE                    ;*Initialise variables
    GOSUB LCID.RETRIEVAL                ;*Read the transaction reference
    GOSUB DELIVERY.ADVICE.INWARD        ;*Retrive the inward message details
    GOSUB DELIVERY.ADVICE.OUTWARD       ;*Retrive the outward message details
    RET.DATA = FIN.ARRAY                ;*Final output array

RETURN

*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise Required Variables </desc>
*==========
INITIALISE:
*==========
*initialise the variables

    RET.DATA = ''; ERR = ''; TRANSACTION.REF = ''; DISPOSITION = ''; APPLICATION.NAME = ''; DA.REF = ''; MSG.TYPE = ''; BANK.DATE = ''; TRANS.REF = '';
    MSG.CAT = ''; CARRIER.ADDRESS.NO = ''; SHORT.NAME = ''; DELIVERY.FLAG = ''; CUSTOMER.NO = ''; TO.ADDRESS = '';AMEND.TRANSACTION.REF = '';
    DISPOSITION.VAL = 'FORMATTED';                             ;*Disposition status should be "FORMATTED"
    DEFFUN System.getVariable()
    EXT.CUSTOMERS  = System.getVariable("EXT.SMS.CUSTOMERS")   ;*Corporate Customer

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= LC ID retrive>
*** <desc>LC ID retrive</desc>
*==============
LCID.RETRIEVAL:
*===============
*Locate the position of the field in SS

    LOCATE 'TRANSACTION.REF' IN EB.Reports.getDFields()<1> SETTING ID.POS THEN  ;* To check TRANSACTION REF availability in SPF
        TRANSACTION.REF = EB.Reports.getDRangeAndValue()<ID.POS>              ;* Get the LC ID from enquiry selection
        TXN.REF         = TRANSACTION.REF
    END

RETURN
*** </region>
*------------------------------------------------------------------------------
*** <region name=Delivery Advice Inward>
*** <desc>Delivery Advice Inward</desc>
*======================
DELIVERY.ADVICE.INWARD:
*=======================
    ADVICE.LIST = ''
    ADVICE.LIST = dasTransRefWithDispositionInward                      ;* Selection criteria in DAS

* For 707 & 747 need to pass LC ID instead of LC Amendment ID
    AMENDMENT.IDENTITY=SUBSTRINGS(TXN.REF,13,1)
    IF (AMENDMENT.IDENTITY EQ 'A') THEN
        AMEND.TRANSACTION.REF = SUBSTRINGS(TXN.REF,1,12)
        TXN.REF               = AMEND.TRANSACTION.REF
    END ELSE
        TXN.REF               = TRANSACTION.REF
    END
    ADVICE.ARGS=TXN.REF:@FM:DISPOSITION.VAL                      ;* Conditonal values criteria in DAS
    TABLE.SUFFIX=''
    EB.DataAccess.Das("DE.I.HEADER",ADVICE.LIST,ADVICE.ARGS,TABLE.SUFFIX)        ;* Call DAS
    SEL.LIST=ADVICE.LIST

    LOOP
        REMOVE DE.I.HEADER.ID FROM SEL.LIST SETTING POS                           ;* loop through the DE.I.HEADER.ID from and to
    WHILE DE.I.HEADER.ID:POS
        R.DE.I.HEADER = DE.Config.IHeader.Read(DE.I.HEADER.ID, ERR)
        DISPOSITION        = R.DE.I.HEADER<DE.Config.OHeader.HdrDisposition>                        ;* allowed disposition
        APPLICATION.NAME   = R.DE.I.HEADER<DE.Config.IHeader.HdrApplication>                        ;* allowed application
        DA.REF             = DE.I.HEADER.ID                                           ;* allowed delivery reference
        MSG.TYPE           = R.DE.I.HEADER<DE.Config.IHeader.HdrMessageType>                       ;* allowed message type
        BANK.DATE          = R.DE.I.HEADER<DE.Config.IHeader.HdrBankDate>                          ;* allowed bank date
        TRANS.REF          = R.DE.I.HEADER<DE.Config.OHeader.HdrT24InwTransRef>                  ;* allowed transaction reference
        MSG.CAT            = "Inward"                                                 ;* allowed message category
        CARRIER.ADDRESS.NO = R.DE.I.HEADER<DE.Config.OHeader.HdrCarrierAddressNo,1>                 ;* allowed carrier address number
        SHORT.NAME         = R.DE.I.HEADER<DE.Config.IHeader.HdrNameTitle,1>                         ;* allowed short name
        CUSTOMER.NO        = R.DE.I.HEADER<DE.Config.IHeader.HdrCustomerNo>                        ;* allowed customer number
        TO.ADDRESS         = FIELD(R.DE.I.HEADER<DE.Config.IHeader.HdrFromAddress,1>,"X",1)                    ;* allowed From address

* For inward swift we need to show TO.ADDRESS as Delivered to/from
        SHORT.NAME = TO.ADDRESS
        GOSUB GET.DESCRIPTION ;*Get the short name of BIC

        GOSUB FINAL.ARRAY

    REPEAT
RETURN
*** </region>
*-------------------------------------------------------------------------------------------
*** <region name=Delivery Advice Outward>
*** <desc>Delivery Advice Outward</desc>
*=======================
DELIVERY.ADVICE.OUTWARD:
*=======================
    ADVICE.LIST = ''
    ADVICE.LIST = dasTransRefWithDispositionOutward                                  ;* Selection criteria in DAS
    ADVICE.ARGS=TRANSACTION.REF:@FM:DISPOSITION.VAL                                  ;* Conditonal values criteria in DAS
    TABLE.SUFFIX=''
    EB.DataAccess.Das("DE.O.HEADER",ADVICE.LIST,ADVICE.ARGS,TABLE.SUFFIX)                     ;* Call DAS
    SEL.LIST=ADVICE.LIST

    LOOP
        REMOVE DE.O.HEADER.ID FROM SEL.LIST SETTING POS                              ;* loop through the DE.I.HEADER.ID from and to
    WHILE DE.O.HEADER.ID:POS
        R.DE.O.HEADER = DE.Config.OHeader.Read(DE.O.HEADER.ID, ERR)
        DISPOSITION        = R.DE.O.HEADER<DE.Config.OHeader.HdrDisposition>                             ;* allowed disposition
        APPLICATION.NAME   = R.DE.O.HEADER<DE.Config.IHeader.HdrApplication>                           ;* allowed application
        DA.REF             = DE.O.HEADER.ID                                              ;* allowed delivery reference
        MSG.TYPE           = R.DE.O.HEADER<DE.Config.IHeader.HdrMessageType>                             ;* allowed message type
        BANK.DATE          = R.DE.O.HEADER<DE.Config.IHeader.HdrBankDate>                             ;* allowed bank date
        TRANS.REF          = R.DE.O.HEADER<DE.Config.OHeader.HdrTransRef>                             ;* allowed transaction reference
        MSG.CAT            = "Outward"                                                   ;* allowed message category
        CARRIER.ADDRESS.NO = R.DE.O.HEADER<DE.Config.OHeader.HdrCarrierAddressNo,1>                    ;* allowed carrier address number
        SHORT.NAME         = R.DE.O.HEADER<DE.Config.IHeader.HdrNameTitle,1>                             ;* allowed short name
        CUSTOMER.NO        = R.DE.O.HEADER<DE.Config.IHeader.HdrCustomerNo>                           ;* allowed customer number
        TO.ADDRESS         = R.DE.O.HEADER<DE.Config.IHeader.HdrToAddress,1>                       ;* allowed to address

        GOSUB DELIVERY.ADVICE

    REPEAT
RETURN
*** </region>
*--------------------------------------------------------------------------------------------
*** <region name=Delivery Advice>
*** <desc>Delivery Advice</desc>
*===============
DELIVERY.ADVICE:
*===============
*-----------------------------------------------------------------------------
    MSGSERIES = SUBSTRINGS(MSG.TYPE,1,1)                                          ;* filter 7** message type records
    CARRIER=SUBSTRINGS(CARRIER.ADDRESS.NO,1,5)                                     ;* get the carrier
    LOCATE "PRINT" IN CARRIER<1,1> SETTING CARRIER.POS THEN
        LOCATE CUSTOMER.NO IN EXT.CUSTOMERS<1,1> SETTING CUS.POS THEN
            MSG.TYPE = 'Advice'                                                    ;*for corporate customer need to show the message type as advice
            DELIVERY.FLAG=1
        END ELSE
            DELIVERY.FLAG=0
        END
        GOSUB CHECK.OWN.BANK
    END ELSE
        IF MSGSERIES MATCHES '7':@VM:'4' AND NOT(MSG.TYPE MATCHES '790':@VM:'791':@VM:'490':@VM:'491') THEN      ;* exclude message type 790,791,490 and 491
            DELIVERY.FLAG=1
            SHORT.NAME = FIELD(R.DE.O.HEADER<DE.Config.IHeader.HdrToAddress,1>,"X",1)                  ;* For outward swift.1 we need to show TO.ADDRESS as Delivered to/from
            GOSUB GET.DESCRIPTION ;*Get the short name of BIC
        END ELSE
            DELIVERY.FLAG=0
        END
    END

    IF DELIVERY.FLAG=1 THEN
        GOSUB FINAL.ARRAY
    END

RETURN
*** </region>
*------------------------------------------------------------------------------
*** <region name=Final Array>
*** <desc>Final Array</desc>
*===========
FINAL.ARRAY:
*===========
    FIN.ARRAY<-1> = DISPOSITION:"*":APPLICATION.NAME:"*":DA.REF:"*":MSG.TYPE:"*":BANK.DATE:"*":TRANS.REF:"*":MSG.CAT:"*":CARRIER.ADDRESS.NO:"*":SHORT.NAME
    DISPOSITION = '' ;APPLICATION.NAME = ''; DA.REF  = '' ; MSG.TYPE = '' ; BANK.DATE = ''; TRANS.REF = ''; MSG.CAT = ''; CARRIER.ADDRESS.NO = ''; SHORT.NAME = ''
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name=Find Own Bank>
*** <desc>Find Own Bank Customer Id</desc>
*==============
CHECK.OWN.BANK:
*==============
    ST.CompanyCreation.EbReadParameter('F.LC.PARAMETERS', '', '', R.LC.PARAMETER, '','', LC.PAR.ERR)
    OWN.BANK = R.LC.PARAMETER<LC.Config.Parameters.ParaCustByOrder>
    IF CUSTOMER.NO EQ OWN.BANK THEN
        MSG.TYPE = 'Advice'
        DELIVERY.FLAG = 1
    END
RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name=Find Own Bank>
*** <desc>Find Own Bank Customer Id</desc>
*===============
GET.DESCRIPTION:
*===============
    BIC.DETAILS = ''
    ADDRESS.KEY = ''
    BIC.DETAILS<ST.CustomerService.AddressIDDetails.bic> = SHORT.NAME
    ST.CustomerService.getAddressIdFromBIC(BIC.DETAILS,ADDRESS.KEY)
    DE.ADDRESS.LIST = ADDRESS.KEY<ST.CustomerService.AddressKey.deAddressKey>
    LOOP
        REMOVE DE.ADDRESS.ID FROM DE.ADDRESS.LIST SETTING ADDRESS.POS
    WHILE DE.ADDRESS.ID:ADDRESS.POS
        FINDSTR "SWIFT" IN DE.ADDRESS.ID SETTING DE.ADDRESS.POS THEN ;*Retrieve short name only for Swift addresses
            keyDetails = ''
            CUS.NO = FIELD(DE.ADDRESS.ID,'.',2)
            IF FIELD(CUS.NO,'-',1) EQ 'C' THEN
                keyDetails<ST.CustomerService.AddressIDDetails.customerKey> = FIELD(CUS.NO,'-',2)
            END ELSE
                keyDetails<ST.CustomerService.AddressIDDetails.customerKey> = ''
            END
            keyDetails<ST.CustomerService.AddressIDDetails.preferredLang> = EB.SystemTables.getLngg()
            keyDetails<ST.CustomerService.AddressIDDetails.companyCode> = FIELD(DE.ADDRESS.ID,'.',1)
            keyDetails<ST.CustomerService.AddressIDDetails.addressNumber> = DE.ADDRESS.ID[LEN(DE.ADDRESS.ID),LEN(DE.ADDRESS.ID)-1]
            keyDetails<ST.CustomerService.AddressIDDetails.getDefault> = 'NO'
            address = ''
            ST.CustomerService.getSWIFTAddress(keyDetails, R.DE.ADDRESS)
            SHORT.NAME = R.DE.ADDRESS<ST.CustomerService.SWIFTDetails.shortName> ;*Retrieve Short name from DE Address record details retrieved from the API
        END
    REPEAT
RETURN

*** </region>
END
*-----------------------------------------------------------------------------
