* @ValidationCode : MjotMTUyNjI3MzI1NTpDcDEyNTI6MTU4MjAzNTQxODIwNDpzdGFudXNocmVlOjI6MjowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDMuMjAyMDAyMTItMDY0NjoxMjU6MTIw
* @ValidationInfo : Timestamp         : 18 Feb 2020 19:46:58
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : stanushree
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 2
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 120/125 (96.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.20200212-0646
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE DE.Channels
SUBROUTINE E.NOFILE.TC.DELIVERY.ADVICE(RET.DATA)
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
*
* This routine fetches delivery advice details associated with a transaction reference
*
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : No-file routine
* Attached To        : Enquiry > TC.NOF.DELIVERY.ADVICE using the Standard selection NOFILE.TC.DELIVERY.ADVICE
* IN Parameters      : Transaction Ref (TRANSACTION.REF)
* Out Parameters     : Array of delivery message details such as Disposition, Application, Delivery Reference, Message Type, Bank Date, Transaction Reference,
*                      Message Category, Carrier Address No and Short Name (RET.DATA)
*
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 11/01/2018  - Enhancement 2389785 / Task 2410871
*             TCIB2.0 Corporate - Advanced Functional Components - Delivery
*
* 17/02/2020 - Task 3592107
*              Removal of DE.Config reference
*
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INSERTS>
*** <desc>File inserts and common variables used in the subroutine. </desc>
* Inserts

    $USING DE.Channels
    $USING DE.ModelBank
    $USING EB.SystemTables
    $USING EB.Reports
    $USING DE.Config
    $USING ST.CompanyCreation
    $USING LC.Config
    $USING EB.DataAccess
    $USING EB.Browser
    $USING PY.Config
    $INSERT I_DAS.DE.I.HEADER
    $INSERT I_DAS.DE.O.HEADER
    $INSERT I_DAS.DE.ADDRESS

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main processing logic. </desc>

    GOSUB INITIALISE                    ;*Initialise variables
    GOSUB GET.TRANSACTION.REF           ;*Retrieve the transaction reference
    GOSUB DELIVERY.ADVICE.INWARD        ;*Retrieve the inward message details
    GOSUB DELIVERY.ADVICE.OUTWARD       ;*Retrieve the outward message details
    RET.DATA = FIN.ARRAY                ;*Final output array
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise variables used in this routine. </desc>
INITIALISE:
*----------
*initialise the variables

    RET.DATA = ''; ERR = ''; TRANSACTION.REF = ''; DISPOSITION = ''; APPLICATION.NAME = ''; DA.REF = ''; MSG.TYPE = ''; BANK.DATE = ''; TRANS.REF = '';
    MSG.CAT = ''; CARRIER.ADDRESS.NO = ''; SHORT.NAME = ''; DELIVERY.FLAG = ''; CUSTOMER.NO = ''; TO.ADDRESS = '';AMEND.TRANSACTION.REF = '';
    DISPOSITION.VAL = 'FORMATTED';                             ;*Setting Disposition as "FORMATTED"
    EXT.CUSTOMERS  = EB.Browser.SystemGetvariable("EXT.SMS.CUSTOMERS")  ;*Get Corporate Customer Id

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= GET.TRANSACTION.REF>
*** <desc>Reads the transaction reference</desc>
GET.TRANSACTION.REF:
*-------------------
*Locate the position of the field in SS

    LOCATE 'TRANSACTION.REF' IN EB.Reports.getDFields()<1> SETTING ID.POS THEN  ;* Locate the criteria field TRANSACTION.REF
        TRANSACTION.REF = EB.Reports.getDRangeAndValue()<ID.POS>              ;* Read the value of the field TRANSACTION.REF
        TXN.REF         = TRANSACTION.REF
    END

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name=Delivery Advice Inward>
*** <desc>This processes the inward delivery advices</desc>
DELIVERY.ADVICE.INWARD:
*----------------------
    ADVICE.LIST = ''
    ADVICE.LIST = dasTransRefWithDispositionInward                      ;* Selection criteria in DAS

* For 707 & 747 need to pass LC ID instead of LC Amendment ID
    AMENDMENT.IDENTITY=SUBSTRINGS(TXN.REF,13,1) ;*Retrieve the Amendment entity part in the transaction reference of an amendment record
    IF (AMENDMENT.IDENTITY EQ 'A') THEN ;*Check if amendment
        AMEND.TRANSACTION.REF = SUBSTRINGS(TXN.REF,1,12) ;*Retrieve the transaction reference without the amendment sequence
        TXN.REF               = AMEND.TRANSACTION.REF
    END ELSE
        TXN.REF               = TRANSACTION.REF
    END
    ADVICE.ARGS=TXN.REF:@FM:DISPOSITION.VAL                      ;* Conditonal values criteria in DAS
    TABLE.SUFFIX=''
    EB.DataAccess.Das("DE.I.HEADER",ADVICE.LIST,ADVICE.ARGS,TABLE.SUFFIX) ;* Call DAS for fetching inward message details
    SEL.LIST=ADVICE.LIST

    LOOP
        REMOVE DE.I.HEADER.ID FROM SEL.LIST SETTING POS                           ;* Loop through the DE.I.HEADER.ID from and to
    WHILE DE.I.HEADER.ID:POS
        R.DE.I.HEADER = DE.Config.IHeader.Read(DE.I.HEADER.ID, ERR)
        DISPOSITION        = R.DE.I.HEADER<DE.Config.OHeader.HdrDisposition>                        ;* Allowed disposition
        APPLICATION.NAME   = R.DE.I.HEADER<DE.Config.IHeader.HdrApplication>                        ;* Allowed application
        DA.REF             = DE.I.HEADER.ID                                           ;* Allowed delivery reference
        MSG.TYPE           = R.DE.I.HEADER<DE.Config.IHeader.HdrMessageType>                       ;* Allowed message type
        BANK.DATE          = R.DE.I.HEADER<DE.Config.IHeader.HdrBankDate>                          ;* Allowed bank date
        TRANS.REF          = R.DE.I.HEADER<DE.Config.OHeader.HdrT24InwTransRef>                  ;* Allowed transaction reference
        MSG.CAT            = "Inward"                                                 ;* Allowed message category
        CARRIER.ADDRESS.NO = R.DE.I.HEADER<DE.Config.OHeader.HdrCarrierAddressNo,1>                 ;* Allowed carrier address number
        SHORT.NAME         = R.DE.I.HEADER<DE.Config.IHeader.HdrNameTitle,1>                         ;* Allowed short name
        CUSTOMER.NO        = R.DE.I.HEADER<DE.Config.IHeader.HdrCustomerNo>                        ;* Allowed customer number
        TO.ADDRESS         = FIELD(R.DE.I.HEADER<DE.Config.IHeader.HdrFromAddress,1>,"X",1)                    ;* Allowed From address

* For inward swift we need to show TO.ADDRESS as Delivered to/from
        SHORT.NAME = TO.ADDRESS
        GOSUB GET.SHORTNAME ;*Get the short name of BIC

        GOSUB FINAL.ARRAY

    REPEAT
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name=Delivery Advice Outward>
*** <desc>This processes the outward delivery advices</desc>
DELIVERY.ADVICE.OUTWARD:
*-----------------------
    ADVICE.LIST = ''
    ADVICE.LIST = dasTransRefWithDispositionOutward                                  ;* Selection criteria in DAS
    ADVICE.ARGS=TRANSACTION.REF:@FM:DISPOSITION.VAL                                  ;* Conditonal values criteria in DAS
    TABLE.SUFFIX=''
    EB.DataAccess.Das("DE.O.HEADER",ADVICE.LIST,ADVICE.ARGS,TABLE.SUFFIX)                 ;* Call DAS
    SEL.LIST=ADVICE.LIST

    LOOP
        REMOVE DE.O.HEADER.ID FROM SEL.LIST SETTING POS                              ;* Loop through the DE.I.HEADER.ID from and to
    WHILE DE.O.HEADER.ID:POS
        R.DE.O.HEADER = DE.Config.OHeader.Read(DE.O.HEADER.ID, ERR)
        DISPOSITION        = R.DE.O.HEADER<DE.Config.OHeader.HdrDisposition>                             ;* Allowed disposition
        APPLICATION.NAME   = R.DE.O.HEADER<DE.Config.IHeader.HdrApplication>                           ;* Allowed application
        DA.REF             = DE.O.HEADER.ID                                              ;* Allowed delivery reference
        MSG.TYPE           = R.DE.O.HEADER<DE.Config.IHeader.HdrMessageType>                             ;* Allowed message type
        BANK.DATE          = R.DE.O.HEADER<DE.Config.IHeader.HdrBankDate>                             ;* Allowed bank date
        TRANS.REF          = R.DE.O.HEADER<DE.Config.OHeader.HdrTransRef>                             ;* Allowed transaction reference
        MSG.CAT            = "Outward"                                                   ;* Allowed message category
        CARRIER.ADDRESS.NO = R.DE.O.HEADER<DE.Config.OHeader.HdrCarrierAddressNo,1>                    ;* Allowed carrier address number
        SHORT.NAME         = R.DE.O.HEADER<DE.Config.IHeader.HdrNameTitle,1>                             ;* Allowed short name
        CUSTOMER.NO        = R.DE.O.HEADER<DE.Config.IHeader.HdrCustomerNo>                           ;* Allowed customer number
        TO.ADDRESS         = R.DE.O.HEADER<DE.Config.IHeader.HdrToAddress,1>                       ;* Allowed to address

        GOSUB DELIVERY.ADVICE

    REPEAT
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name=DELIVERY.ADVICE>
*** <desc>This processes the delivery advices</desc>
DELIVERY.ADVICE:
*------------
    MSGSERIES = SUBSTRINGS(MSG.TYPE,1,1)                                          ;* Filter 7** message type records
    CARRIER=SUBSTRINGS(CARRIER.ADDRESS.NO,1,5)                                     ;*Retrieve the carrier details
    LOCATE "PRINT" IN CARRIER<1,1> SETTING CARRIER.POS THEN
        LOCATE CUSTOMER.NO IN EXT.CUSTOMERS<1,1> SETTING CUS.POS THEN
            MSG.TYPE = 'Advice'                                                    ;*Set message type as advice for display related to corporate customer
            DELIVERY.FLAG=1
        END ELSE
            DELIVERY.FLAG=0
        END
        GOSUB CHECK.OWN.BANK
    END ELSE
        IF MSGSERIES MATCHES '7':@VM:'4' AND NOT(MSG.TYPE MATCHES '790':@VM:'791':@VM:'490':@VM:'491') THEN      ;* Exclude message type 790,791,490 and 491
            DELIVERY.FLAG=1
            SHORT.NAME = FIELD(R.DE.O.HEADER<DE.Config.IHeader.HdrToAddress,1>,"X",1)                  ;* For outward swift.1 we need to show TO.ADDRESS as Delivered to/from
            GOSUB GET.SHORTNAME ;*Get the short name of BIC
        END ELSE
            DELIVERY.FLAG=0
        END
    END

    IF DELIVERY.FLAG=1 THEN
        GOSUB FINAL.ARRAY
    END

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name=FINAL.ARRAY>
*** <desc>Form Final Array of delivery advice details</desc>
FINAL.ARRAY:
*-----------
    FIN.ARRAY<-1> = DISPOSITION:"*":APPLICATION.NAME:"*":DA.REF:"*":MSG.TYPE:"*":BANK.DATE:"*":TRANS.REF:"*":MSG.CAT:"*":CARRIER.ADDRESS.NO:"*":SHORT.NAME
    DISPOSITION = '' ;APPLICATION.NAME = ''; DA.REF  = '' ; MSG.TYPE = '' ; BANK.DATE = ''; TRANS.REF = ''; MSG.CAT = ''; CARRIER.ADDRESS.NO = ''; SHORT.NAME = ''
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name=CHECK.OWN.BANK>
*** <desc>Check for own bank advices</desc>
CHECK.OWN.BANK:
*--------------
    ST.CompanyCreation.EbReadParameter('F.LC.PARAMETERS', '', '', R.LC.PARAMETER, '','', LC.PAR.ERR) ;*Read LC parameters record
    OWN.BANK = R.LC.PARAMETER<LC.Config.Parameters.ParaCustByOrder> ;*Retrieve the customer id from the parameters record
    IF CUSTOMER.NO EQ OWN.BANK THEN ;* Check if the corporate customer is the same as the one defined in parameters record
        MSG.TYPE = 'Advice' ;*Set message type as advice
        DELIVERY.FLAG = 1
    END
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name=GET.SHORTNAME>
*** <desc>Retrieves shortname associated with bank for swift advices </desc>
GET.SHORTNAME:
*-------------
    TABLE.SUFFIX = ''
    THE.LIST = ''
    TABLE.NAME = "DE.ADDRESS"
    THE.LIST = DAS.DE.ADDRESS$DELVRYADD ;*Select DE Address based on Delivery Address
    THE.ARGS<1> = SHORT.NAME ;*Delivery Address Id
    EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX) ;*Call to DAS routine based on THE.ARGS
    DE.ADDRESS.LIST = THE.LIST ;*List of DE Addresses
    LOOP
        REMOVE DE.ADDRESS.ID FROM DE.ADDRESS.LIST SETTING ADDRESS.POS
    WHILE DE.ADDRESS.ID:ADDRESS.POS
        FINDSTR "SWIFT" IN DE.ADDRESS.ID SETTING DE.ADDRESS.POS THEN ;*Retrieve short name only for Swift addresses
            R.DE.ADDRESS = PY.Config.Address.Read(DE.ADDRESS.ID, DE.ADDRESS.ERR) ;*Read DE Address record
            SHORT.NAME = R.DE.ADDRESS<PY.Config.Address.AddBranchnameTitle> ;*Retrieve Short name from DE Address record
        END
    REPEAT
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------

END
