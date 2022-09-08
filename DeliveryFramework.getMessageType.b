* @ValidationCode : MjoxMzkxOTI5OTE0OkNwMTI1MjoxNDg3NzcxNDE1NjQ2OmFiY2l2YW51amE6NDowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDIuMDoxMjE6ODk=
* @ValidationInfo : Timestamp         : 22 Feb 2017 19:20:15
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : abcivanuja
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 89/121 (73.5%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE DE.API
    SUBROUTINE DeliveryFramework.getMessageType(Message,MessageId,fromAddress,ToAddress,Res1,Res2,Res3,Error)
*-----------------------------------------------------------------------------
*Incoming arguments
*Message - contains the message content from Swift queues
*
* Outgoing arguments
* MessageId - DE.MESSAGE record id determined
* fromAddress - FROM.ADDRESS determined from the incoming message
* ToAddress - TO.ADDRESS determined from incoming message
* Error - Error if any
*-----------------------------------------------------------------------------
* Public API to include logic by business applications to determine the DE.MESSAGE record id
* from the incoming message passed during service ISOMX.IN
* Modification History :
*-----------------------------------------------------------------------------
* 25/04/16 - Enhancement 1687042 / Task 1701272
*          - New routine creation
* 08/12/16 - Task 1935601
*            Updated From/To Address and Message Key
* 16/02/17 - Task 2022353
*            Added missing RETURN

*-----------------------------------------------------------------------------

    GOSUB INITIALISE ;* Initialise all varaibles used
    GOSUB SET.MESSAGE.ID ;* Set DE.MESSAGE Key
    GOSUB SET.FROM.ADDRESS ;* Set From Address- Only BIC for now
    GOSUB SET.TO.ADDRESS ;* Set To Address- Only BIC for now

    RETURN

*** <region name= INITIALISE>
*** <desc>Initialise Variables used </desc>
INITIALISE:
    MessageId = '' ;* Key to DE.MESSAGE
    fromAddress = '' ;* Sender of message
    ToAddress = '' ;* Receiver of messages -Ideally T24 Bank
    Error = '' ;* No error to be returned here... may be there is an external API in DE.PARM which will return header details from OFS.DE.PROCESSING

    V1 = "" ;* Init varaible
    DEFFUN CHARX(V1) ;* Declare function
    R.MSG.IN = Message ;*  Take a copy of message for local extraction
    EQU CR TO CHARX(013)      ;* carriage return
    EQU LF TO CHARX(010)      ;* line feed
    CRLF = CR:LF ;* Carriage Return and Line feed


    CONVERT @FM TO '' IN R.MSG.IN        ;*convert the FM to null
    CONVERT CRLF TO '' IN R.MSG.IN     ;*convert the CRLF to null
    CONVERT LF TO '' IN R.MSG.IN        ;*convert the LF to null

* Format: <AppHdr xmlns:Ah="urn:swift:xsd....> </AppHdr>
    APP.HEADER = FIELD(R.MSG.IN,'<AppHdr',2) ;* Extract from  app header start
    APP.HEADER = FIELD( APP.HEADER ,'</AppHdr',1) ;* Extract till app header end

    RETURN
*** </region>

*** <region name= SET.MESSAGE.ID>
*** <desc>Set DE.MESSAGE.KEY as MessageId</desc>
SET.MESSAGE.ID:

*-----------------------------------------------------------------------------
* Step 1)  Get from Message Definition Identifier in App header
*-----------------------------------------------------------------------------
* Used for Interact AppHeader V1.0, BAH
* Format : <MsgDefIdr>setr.010.001.02</MsgDefIdr>

* Get Message Identifier from App header
    MessageId = FIELD(APP.HEADER,'<MsgDefIdr>',2)
    MessageId = FIELD( MessageId,'</',1)


*-----------------------------------------------------------------------------
* Step 2)  Get from RequestType tag in Transport Header
*-----------------------------------------------------------------------------
* Used for IBM WBIFN mq message & Interact AppHdrV1.0 > BAH
* Format :  <RequestType>setr.010.001.02</RequestType> ;
    IF NOT( MessageId) THEN
        MessageId = FIELD(R.MSG.IN,'<RequestType',2)
        IF NOT ( MessageId) THEN

            * <Swint:RequestType>setr.010.001.02</SwintRequestType>
            MessageId = FIELD( MessageId,'RequestType>',2)
        END
        MessageId = FIELD(  MessageId,'</',1)
    END

*-----------------------------------------------------------------------------
* Step 3)  Get from Message Identifier in Transport Header
*-----------------------------------------------------------------------------
* Used for Swift Alliance DataPdu 2.0
* Format:    <MessageIdentifier>setr.010.001.02</MessageIdentifier>
    IF NOT( MessageId) THEN

        MessageId = FIELD(R.MSG.IN,'MessageIdentifier>',2)
        MessageId = FIELD(  MessageId,'</',1)
    END


    MessageId = MessageId[1,4]:MessageId[6,3] ;* get  setr010- remove '.'
    MessageId = UPCASE(MessageId) ;* set as SETR010 as DE.MESSAGE Key should be in this format only

    RETURN
*** </region>

*** <region name= SET.FROM.ADDRESS>
*** <desc>Set From address</desc>
SET.FROM.ADDRESS:


*-----------------------------------------------------------------------------
* Step 1)  Get from From address in App header
*-----------------------------------------------------------------------------


    HEADER.DATA = FIELD(APP.HEADER,'<Fr>',2)
    HEADER.DATA = FIELD(HEADER.DATA ,'</Fr>',1)
    GOSUB GET.ADDRESS.BIC ;* Get from BIC
    fromAddress = ADDRESS.BIC ;* Sender of message



*-----------------------------------------------------------------------------
* Step 2)  Get from Requestor tag in Transport Header
*-----------------------------------------------------------------------------
*Used for Swift interAct in Transport Header. have prefix like Swint

    IF NOT(fromAddress) THEN
        FROM.ADDRESS.BIC = FIELD(R.MSG.IN,'<Requestor',2)
        IF NOT (FROM.ADDRESS.BIC) THEN
            * <Swint:Requestor>ou=abcdus12,o=swift</SwintRequestor>
            FROM.ADDRESS.BIC = FIELD(R.MSG.IN,'Requestor>',2)
        END
        fromAddress = FIELD( FROM.ADDRESS.BIC,'</',1)
    END
*-----------------------------------------------------------------------------
* Step 3)  Get from Sender in Transport Header
*-----------------------------------------------------------------------------
* Used for swift alliance SAA
    IF NOT(fromAddress) THEN ;* Get from tag Sender DN
        FROM.ADDRESS.BIC = FIELD(R.MSG.IN,'<Sender',2)
        FROM.ADDRESS.BIC = FIELD( FROM.ADDRESS.BIC,'</Sender',1)
        FROM.ADDRESS.BIC =FIELD(FROM.ADDRESS.BIC,'<DN>',2)
        fromAddress =FIELD(FROM.ADDRESS.BIC,'</DN>',1)

    END


*-----------------------------------------------------------------------------
* Step 4)  Get final address- may be from Organisational Unit
*-----------------------------------------------------------------------------

    AddressToCheck= fromAddress
    GOSUB GET.FINAL.ADDRESS
    fromAddress= AddressToCheck

*** </region>

    RETURN

*** <region name= SET.TO.ADDRESS>
*** <desc>Set TO.ADDRESS field </desc>
SET.TO.ADDRESS:



*-----------------------------------------------------------------------------
* Step 1)  Get from 'To' tag in App header
*-----------------------------------------------------------------------------

* Get To  Address from App header
    HEADER.DATA = FIELD(APP.HEADER,'<To>',2)
    HEADER.DATA = FIELD(HEADER.DATA ,'</To>',1)
    GOSUB GET.ADDRESS.BIC ;* Get To Bic
    ToAddress = ADDRESS.BIC ;* Receiver of messages -Ideally T24 Bank


*-----------------------------------------------------------------------------
* Step 2)  Get from Responder in Transport Header
*-----------------------------------------------------------------------------
    IF NOT(ToAddress) THEN
        TO.ADDRESS.BIC = FIELD(R.MSG.IN,'<Responder',2)
        IF NOT (TO.ADDRESS.BIC) THEN

            * <Swint:Requestor>ou=abcdus34,o=swift</SwintRequestor>
            TO.ADDRESS.BIC = FIELD(R.MSG.IN,'Responder>',2)
        END
        ToAddress = FIELD( TO.ADDRESS.BIC,'</',1)
    END

*-----------------------------------------------------------------------------
* Step 3)  Get from Receiver tag in Transport Header
*-----------------------------------------------------------------------------
* Used for swift alliance SAA
    IF NOT(ToAddress) THEN ;* Get from tag Sender DN
        TO.ADDRESS.BIC = FIELD(R.MSG.IN,'<Receiver',2)
        TO.ADDRESS.BIC = FIELD( TO.ADDRESS.BIC,'</Receiver',1)
        TO.ADDRESS.BIC =FIELD(TO.ADDRESS.BIC,'<DN>',2)
        ToAddress =FIELD(TO.ADDRESS.BIC,'</DN>',1)
    END

*-----------------------------------------------------------------------------
* Step 4)  Get final address
*-----------------------------------------------------------------------------

    AddressToCheck= ToAddress
    GOSUB GET.FINAL.ADDRESS
    ToAddress= AddressToCheck
    RETURN

*** </region>

*** <region name= GET.ADDRESS.BIC>
*** <desc>Get BIC address details</desc>
GET.ADDRESS.BIC:

    ADDRESS.BIC = '' ;* BIC Address
    IF NOT(HEADER.DATA) THEN ;* There is No  data to extract
        RETURN ;* No data
    END

    TAG.ALL.FROM  = 'AnyBIC':@FM:'BICFI':@FM:'Id' ;* May be in App Header Section
    LOOP
        REMOVE TAG FROM TAG.ALL.FROM SETTING TAGPOS  ;* Repeat for every BIC tag
    WHILE TAG:TAGPOS ;* every BIC tag

        START.TAG = "<":TAG:">" ;* Start tag <AnyBIC>
        END.TAG = "</":TAG:">" ;* End tag </AnyBIC>
        START.TAG.LENGTH = LEN(START.TAG)
        END.TAG.LENGTH = START.TAG.LENGTH + 1
        NODE.DATA.LENGTH = ""

        START.TAG.POS = INDEX(HEADER.DATA,START.TAG,1) ;* Get start position

        IF START.TAG.POS <> 0 THEN ;* Found start tag
            END.TAG.POS = INDEX(HEADER.DATA,END.TAG,1) ;* Get end position

            NODE.DATA.LENGTH = END.TAG.POS - (START.TAG.POS + START.TAG.LENGTH) ;* get total length of BIC
            ADDRESS.BIC = HEADER.DATA[(START.TAG.POS+START.TAG.LENGTH),NODE.DATA.LENGTH] ;* get BIC details
        END
        IF ADDRESS.BIC THEN ;* Got address
            EXIT ;* No need to continue loop
        END

    REPEAT ;* Repeat to check for next tag
    RETURN

*** </region>

*** <region name= GET.FINAL.ADDRESS>
*** <desc>Get Final address </desc>
GET.FINAL.ADDRESS:

* ou -Organisational unit
* o  - Organisation Name

    BEGIN CASE

        CASE (LEN(AddressToCheck) LT 8 )  ;* Not a BIC
            AddressToCheck ='' ;* reset
            RETURN
        CASE LEN(AddressToCheck) GE 8 AND LEN(AddressToCheck) LE 12   ;*Normal BIC address
            * Nothing to do as normal BIC address

        CASE INDEX(AddressToCheck,'ou=',1) ;* Organisation unit found

            AddressToCheck = FIELD(AddressToCheck,'ou=',2) ;* output is ou=abcdus12,o=swift>Id>
            AddressToCheck = FIELD(AddressToCheck,',',1);* output is abcdus12

        CASE INDEX(AddressToCheck,'o=',1) ;* Organisation unit Name found

            AddressToCheck = FIELD(AddressToCheck,'o=',2) ;* output is o=abcdus12,o=swift>Id>
            AddressToCheck = FIELD(AddressToCheck,',',1);* output is abcdus12
    END CASE

    IF (LEN(AddressToCheck) LT 8 )  OR (LEN(AddressToCheck) GT 12)  THEN ;* Cannot be a BIC
        AddressToCheck ='' ;* reset
    END ELSE
        AddressToCheck =UPCASE(AddressToCheck) ;* Delivery BIC are always in upper case only
    END
    RETURN

*** </region>
    END ;* Final exit
