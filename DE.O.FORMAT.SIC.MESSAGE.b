* @ValidationCode : MjotMTY2MTg2ODc4MzpDcDEyNTI6MTUyNDYzMjgwODMzNzpic2F1cmF2a3VtYXI6MTowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE4MDQuMjAxODAzMDgtMjAwNjo1MDI6NzU=
* @ValidationInfo : Timestamp         : 25 Apr 2018 10:36:48
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bsauravkumar
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 75/502 (14.9%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201804.20180308-2006
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 18 31/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>5091</Rating>
*-----------------------------------------------------------------------------
$PACKAGE DE.Clearing
SUBROUTINE DE.O.FORMAT.SIC.MESSAGE
*
* This routine will extract fields from the DE.O.MSG record as defined
* in DE.FORMAT.SIC. These field definitions are held in common in
* SIC$MESSAGE.MAP for each SIC message. For each message the following
* info is held
*         1. SIC field number
*         2. Position in DE.O.MSG for extraction
*         3. Mandatory field Y/N
*         4. Conversion type for data eg date, amount
* The sic message type is derived from the original message type eg a
* MT100 becomes an A10 and so on.
*
* 21/04/93 - GB9300661
*            A 202 should become a B11 not a B10 automatically
*
* 18/05/93 - GB9300864
*            Read DE.ADDRESS for the company code if present
*
* 13/07/93 - GB9301190
*            Generate B10 when acct with = Ben Bank
*
* 26/07/93 - GB9301233
*            Allow *SHORT options on all address type conversions. If the
*            PRINT address is used, it will display the SHORT NAME only.
*
* 05/04/95 - GB9500100
*            The address fields may be multilanguage
*            E. Kutepov   AviComp Services AG
*
* 23/04/01 - GB0101143
*            For all funds transfers, customer giving the order
*            the content of the field "by order of" must be
*            replaced by the text according to the
*            language code of the beneficiary Bank.
*
* 22/05/01- GB0101460
*            correct error in locating language
* 23/05/01 - GB0101471
*            When SWIFT is not the first product code, then
*            the langauge text is incorrect
*
* 12/03/02 - CI-10000692
*            If the bank itself is a beneficiary the swift in
*            DE.ADDRESS has a special format but the delivery address
*            is taken as 9 characters instead of 8.In the SIC message
*            MT202 if the customer no is more than 6 then the no is
*            displayed inspite of the swift address.
*
* 20/04/02 - CI_10001026
*              Diversion Not correct using Local clearing Payment.

* 18/12/02 - CI_10005659
*            If the content of the tag is SW- and the conversion is
*            SWIFT, then set the tag as S ie 46S .
* 25/03/03 - CI_10007642
*            In  DE.ADDRESS delivery address for swift should have
*            9 or 12 characters. If the ordering bank is a company, When
*            retrieving this address, the length of the address must be 8 or
*           11 characters for SIC. So after reading the address from DE.ADDRESS
*           the address, if it  is 9 character length or 12 character length then
*           the 9th character is removed  to form 8 or 11 character length
*           Address which is acceptable for SIC.
*
* 01/03/05 - CI_10027874
*            MT103 is not converted into a A10 (SIC) message.DE.O.HEADER shows
*            the following error message "Not a recognised base message type".
*
* 11/08/05 - EN_10002614
*            FORMATTING SERVICE - PART 2 - FORMAT MSG VIA SERVICE AND SEND TO INTERFACE
*
* 10/07/09 - CI_10064368
*            System does not format SIC messages when SIC service is run.
*
* 15/09/10 - 42147: Amend Infrastructure routines to use the Customer Service API's
*
* 20/03/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE and generating .component
*
* 30/09/15 - Enhancement 1265068
*		   - Task 1469274
*		   - Routine Incorporated
*
* 19/04/18 - Defect 2555587/ Task 2557255
*          - As SIC$MESSAGE.MAP introduced as common variable, componentisation done on use of SIC$MESSAGE.MAP varible
*---------------------------------------------------------------------

    $USING DE.Config
    $USING DE.Clearing
    $USING MM.Contract
    $USING LD.Contract
    $USING FX.Contract
    $USING FX.Config
    $USING FT.Clearing
    $USING EB.DataAccess
    $USING DE.Outward
    $USING DE.ModelBank
    $USING EB.SystemTables

    $INSERT I_CustomerService_AddressIDDetails
    $INSERT I_CustomerService_Address
    $INSERT I_CustomerService_SWIFTDetails

*
    IF DE.Outward.getVDebug() THEN PRINT "DE.O.FORMAT.SIC.MESSAGE IS RUNNING"
*
* Initialise
*
	V1 = ''
	DEFFUN CHARX(V1)
    DIM R.DETAIL(75)          ;* CI_10001026 S/E
    MAT R.DETAIL = ""         ;* Holds the DE.O.MSG record
    SIC.MESSAGE = ""          ;* The message to be built
    NL = CHARX(010) ;* Line feed character
    I.WAY = ">"     ;* Message direction = out
    O.WAY = "#"     ;* Direction = in
*
* Get hold of the DE.O.MSG record
*
    F.DE.O.MSG.LOC = '' ; EB.DataAccess.Opf('F.DE.O.MSG', F.DE.O.MSG.LOC)
    DE.Outward.setFDeOMsg(F.DE.O.MSG.LOC)
    MAT R.DETAIL = '' ; READ.ERR = ''
    REC.ID = DE.Outward.getRKey()
    R.DETAIL.DYN = DE.ModelBank.OMsg.Read(REC.ID, READ.ERR)
    MATPARSE R.DETAIL FROM R.DETAIL.DYN
    AV1 = EB.SystemTables.getAv()
    IF READ.ERR THEN
        tmp=DE.Outward.getRHead(DE.Config.OHeader.HdrMsgErrorCode); tmp<1,AV1>="Error - Message record does not exist"; DE.Outward.setRHead(DE.Config.OHeader.HdrMsgErrorCode, tmp)
        GOSUB WRITE.REPAIR
        RETURN
    END

    IF DE.Clearing.getSicFilesOpen() NE 1 THEN         ;* We need to open the files for SIC

        F.DE.FORMAT.SIC.LOC = ""
        EB.DataAccess.Opf("F.DE.FORMAT.SIC",F.DE.FORMAT.SIC.LOC)         ;* OPF on DE.FORMAT.SIC
        DE.Clearing.setFDeFormatSic(F.DE.FORMAT.SIC.LOC)
        DE.Clearing.setSicFilesOpen(1);* Don't open each time

        R.FT.LOCAL.CLEARING = ''; READ.ERR = ''   ;*Initialise
        R.FT.LOCAL.CLEARING = FT.Clearing.LocalClearing.CacheRead('SYSTEM', READ.ERR)   ;*Read FT.LOCAL.CLEARING with ID 'SYSTEM'
        IF READ.ERR THEN      ;* Not found
            DE.Outward.clearDelcClearing()  ;*Clear the variable
        END ELSE
            DE.Outward.setDynArrayToDelcClearing(R.FT.LOCAL.CLEARING)  ;* Store the FT LOCAL CLEARING in common.
        END

*    Read  the clearing system record eg SIC

        R.FT.BC.PARAMETER = ''; READ.ERR = ''     ;* Initialise
        R.FT.BC.PARAMETER = FT.Clearing.BcParameter.CacheRead('SIC', READ.ERR)          ;* Read FT.BC.PARAMETER with ID as CLEARING SYSTEM, e.g SIC
        IF READ.ERR THEN
            DE.Outward.clearDelcParams()
        END ELSE
            DE.Outward.setDynArrayToDelcClearing(R.FT.BC.PARAMETER);* Store the FT BC PARAMETER in common.
        END

        DE.Clearing.setSicDiversionFlds("")
        YI = 1
        LOOP
            YMSG = DE.Outward.getDelcParams(FT.Clearing.BcParameter.BcDivertedMsg)<1,YI>    ;* Get diverted message
        UNTIL YMSG = ""
            READ.ERR = ''
            YR.MESS = ''
            YR.MESS = DE.Config.Message.CacheRead(YMSG, READ.ERR) ;* Read message record for divertion message
            FOR YY = FT.Clearing.BcParameter.BcIntermedFd TO FT.Clearing.BcParameter.BcNoDivertFd
                YDL = YY - FT.Clearing.BcParameter.BcDivertedMsg     ;* Diversion location
                YNAMES = DE.Outward.getDelcParams(YY)<1,YI>;* Diversion names
                GOSUB SET.UP.DIVERSION.DETS
            NEXT YY
            YI += 1
        REPEAT
    END

*
* Decide on the SIC Message type
*
    SIC.MESSAGE.TYPE = "" ; SUB.TYPE = ""
    BEGIN CASE
        CASE DE.Outward.getRHead(DE.Config.OHeader.HdrMessageType) = "1200"
            SIC.MESSAGE.TYPE = "A10"
*
        CASE DE.Outward.getRHead(DE.Config.OHeader.HdrMessageType) = "1205"
            SIC.MESSAGE.TYPE = "A11"
*
        CASE DE.Outward.getRHead(DE.Config.OHeader.HdrMessageType) = "1210"
            SIC.MESSAGE.TYPE = "B10"
*
        CASE DE.Outward.getRHead(DE.Config.OHeader.HdrMessageType) = "1215"
            SIC.MESSAGE.TYPE = "B11"
*
        CASE DE.Outward.getRHead(DE.Config.OHeader.HdrMessageType) = "1220"
            SIC.MESSAGE.TYPE = "C10"
*
        CASE DE.Outward.getRHead(DE.Config.OHeader.HdrMessageType) = "1225"
            SIC.MESSAGE.TYPE = "C11"
*
        CASE DE.Outward.getRHead(DE.Config.OHeader.HdrMessageType) = "1230"
            SIC.MESSAGE.TYPE = "C15"
*
        CASE DE.Outward.getRHead(DE.Config.OHeader.HdrMessageType) = "1235"
            SIC.MESSAGE.TYPE = "H70"
*
        CASE DE.Outward.getRHead(DE.Config.OHeader.HdrMessageType) MATCHES "100" :@VM: "103"         ;* CI_10027874 S/E
*
** An MT100 will generate either an A10 in the simple cases, or if a
** ACCT.WITH field is present it will generate an A11.
*
            SUB.TYPE = DE.Outward.getRHead(DE.Config.OHeader.HdrMessageType)    ;* CI_10027874 S/E
            LOCATE DE.Outward.getRHead(DE.Config.OHeader.HdrMessageType) IN DE.Clearing.getSicDiversionType()<1> SETTING YPOS THEN
                IF R.DETAIL(DE.Clearing.getSicDiversionFlds()<YPOS,1>) THEN    ;* Through Intermediary
                    SIC.MESSAGE.TYPE = "A11"
                END
                IF DE.Clearing.getSicDiversionFlds()<YPOS,4> THEN
                    IF R.DETAIL(DE.Clearing.getSicDiversionFlds()<YPOS,4>) THEN          ;* Charges
                        SIC.MESSAGE.TYPE = "A11"
                    END
                END
                IF DE.Clearing.getSicDiversionFlds()<YPOS,5> THEN
                    IF R.DETAIL(DE.Clearing.getSicDiversionFlds()<YPOS,5>) THEN          ;* Bank to Bank
                        SIC.MESSAGE.TYPE = "A11"
                    END
                END
                IF NOT(SIC.MESSAGE.TYPE) THEN SIC.MESSAGE.TYPE = "A10"
            END ELSE NULL
*
        CASE DE.Outward.getRHead(DE.Config.OHeader.HdrMessageType) = "200"      ;* Type B11
            SIC.MESSAGE.TYPE = "B11"
*
        CASE DE.Outward.getRHead(DE.Config.OHeader.HdrMessageType) = "202"      ;* Type B10
*
** An MT202 will generate either an B11 in the simple cases, or if a
** ACCT.WITH field is present it will generate an A11.
*
            SUB.TYPE = "202"
            LOCATE DE.Outward.getRHead(DE.Config.OHeader.HdrMessageType) IN DE.Clearing.getSicDiversionType()<1> SETTING YPOS THEN

                IF R.DETAIL(DE.Clearing.getSicDiversionFlds()<YPOS,1>) AND NOT(R.DETAIL(DE.Clearing.getSicDiversionFlds()<YPOS,3>) ) THEN
                    SIC.MESSAGE.TYPE = "A11"
                END ELSE
                    SIC.MESSAGE.TYPE = "B11"
                END

*
** Uncomment this to generate B10 messages rather than B11
                GOSUB CHECK.ACCT.WITH
*
                IF NOT(SIC.MESSAGE.TYPE) THEN SIC.MESSAGE.TYPE = "B11"
*               IF NOT(SIC.MESSAGE.TYPE) THEN SIC.MESSAGE.TYPE = "B10"
            END ELSE NULL
*
        CASE 1          ;* Not recognised as a SIC base message
            AV1 = EB.SystemTables.getAv()
            tmp=DE.Outward.getRHead(DE.Config.OHeader.HdrMsgErrorCode); tmp<1,AV1>="Error - Not a recognised base message type"; DE.Outward.setRHead(DE.Config.OHeader.HdrMsgErrorCode, tmp)
            GOSUB WRITE.REPAIR
            RETURN
*
    END CASE
*
* Now begin to build up the message
* First we must get the mapping rules from common
*
    YSEARCH.TYPE = SIC.MESSAGE.TYPE
    IF SUB.TYPE THEN YSEARCH.TYPE := "-":SUB.TYPE
    LOCATE YSEARCH.TYPE IN DE.Clearing.getSicMessageType()<1> SETTING SIC.MESS.POS ELSE
*
* The message details are not stored yet so we must add them

        ER = ''
        R.DE.FORMAT.SIC = ''
        R.DE.FORMAT.SIC = DE.Clearing.FormatSic.Read(YSEARCH.TYPE, ER)
        EB.SystemTables.setEtext('')
        tmp=DE.Clearing.getSicMessageType(); tmp<SIC.MESS.POS>=YSEARCH.TYPE; DE.Clearing.setSicMessageType(tmp)
        DE.Clearing.setSicMessageMap(SIC.MESS.POS,1, R.DE.FORMAT.SIC<DE.Clearing.FormatSic.SicfSicField>)
        DE.Clearing.setSicMessageMap(SIC.MESS.POS,2, R.DE.FORMAT.SIC<DE.Clearing.FormatSic.SicfFieldLoc>)
        DE.Clearing.setSicMessageMap(SIC.MESS.POS,3, R.DE.FORMAT.SIC<DE.Clearing.FormatSic.SicfMandatory>)
        DE.Clearing.setSicMessageMap(SIC.MESS.POS,4, R.DE.FORMAT.SIC<DE.Clearing.FormatSic.SicfConversion>)
*
    END
*
    FIELD.LIST = DE.Clearing.getSicMessageMap(SIC.MESS.POS,1)
    MAP.LOC = DE.Clearing.getSicMessageMap(SIC.MESS.POS,2)
    MANDATORY = DE.Clearing.getSicMessageMap(SIC.MESS.POS,3)
    CONVERSION = DE.Clearing.getSicMessageMap(SIC.MESS.POS,4)
*
    SIC.MESSAGE = I.WAY:SIC.MESSAGE.TYPE:NL       ;* Message type
    LOOP
        REMOVE YFLD FROM FIELD.LIST SETTING CODE
        REMOVE YLOC FROM MAP.LOC SETTING YD
        REMOVE YMAND FROM MANDATORY SETTING YD
        REMOVE YCONV FROM CONVERSION SETTING YD
    UNTIL YFLD = ""
*
* We may need to extract value and sub values from YLOC
*
        YF = FIELD(YLOC,".",1) ; YV = FIELD(YLOC,".",2) ; YS = FIELD(YLOC,".",3)
        IF R.DETAIL(YF) NE "" AND YLOC THEN
            BEGIN CASE        ;* extract the detail
                CASE YS ;* Sub value
                    EXTRACTED.DATA = R.DETAIL(YLOC)<1,YV,YS>
                CASE YV ;* Multi value
                    EXTRACTED.DATA = R.DETAIL(YLOC)<1,YV>
                CASE 1  ;* The whole field
                    EXTRACTED.DATA = R.DETAIL(YLOC)
            END CASE
*
* If there is any conversion necessary it must be done here
*
* If the Input is in the SW-Style then remove the leading SW-.
            SAVE.EXTRACTED.DATA = ''
            IF EXTRACTED.DATA[1,3] = 'SW-' THEN
                SAVE.EXTRACTED.DATA = EXTRACTED.DATA
                EXTRACTED.DATA = EXTRACTED.DATA[4,99]
            END

            BEGIN CASE
                CASE YCONV = ""   ;* No conversion
                CASE YCONV = "DATE"         ;* Drop the leading 19
                    EXTRACTED.DATA = EXTRACTED.DATA[3,6]
                CASE YCONV = "AMOUNT"       ;* A "." becomes a ","
                    CONVERT ',' TO '' IN EXTRACTED.DATA
                    CONVERT "." TO "," IN EXTRACTED.DATA
                    Z = INDEX(EXTRACTED.DATA,",",1)
                    IF Z = 0 THEN EXTRACTED.DATA = EXTRACTED.DATA:","
                    IF EXTRACTED.DATA[1,1] = '-' THEN
                        EXTRACTED.DATA = EXTRACTED.DATA[2,99]
                    END
                CASE YCONV = "MULTI"        ;* Convert values into NL
                    CONVERT @VM TO NL IN EXTRACTED.DATA
                CASE YCONV[1,5] = "SWIFT"   ;* Get the SWIFT address
*

* If a SWIFT address exists then use this otherwise take the print
* address.
                    IF SAVE.EXTRACTED.DATA[1,3] = 'SW-' THEN
                        YFLD := "S"
                    END ELSE
*
                        CUS.TEXT.IND.REC = ''         ;* GB0101143
                        GOSUB GET.COMPANY.OR.CUST

                        delivery.confidTxt = ''
                        IF (customerKey OR companyCode) THEN  ;* Try for address record
                            keyDetails = ''
                            keyDetails<AddressIDDetails.customerKey> = customerKey
                            keyDetails<AddressIDDetails.preferredLang> = EB.SystemTables.getLngg()
                            keyDetails<AddressIDDetails.companyCode> = companyCode
                            keyDetails<AddressIDDetails.addressNumber> = 1
                            address = ''
                            CALL CustomerService.getSWIFTAddress(keyDetails, address)
                            IF EB.SystemTables.getEtext() = '' THEN
                                delivery.address = address<SWIFTDetails.code>
                                delivery.confidTxt = address<SWIFTDetails.confidTxt>
*
* trim the Address to either 8 characters  or 11  characters by removing the 9th character
                                LEN.ADDR = LEN(delivery.address)
                                BEGIN CASE
                                    CASE LEN.ADDR = 9
                                        EXTRACTED.DATA = delivery.address[1,8]
                                    CASE LEN.ADDR = 12
                                        EXTRACTED.DATA = delivery.address[1,8]:delivery.address[10,3]
                                    CASE 1
                                        EXTRACTED.DATA = delivery.address
                                END CASE
                                YFLD := "S" ;* Swift address
                            END ELSE
                                YFLD := "A" ;* Full address
                                GOSUB GET.ORD.CUS.TEXT
                                IF CUS.TEXT.IND.REC = '' THEN
                                    GOSUB GET.PRINT.ADDRESS
                                END         ;*GB0101143 E
                            END
                        END ELSE  ;* No conversion to do except change multi fields
                            YFLD := "A"
                            GOSUB GET.ORD.CUS.TEXT
                            IF CUS.TEXT.IND.REC = '' THEN
                                CONVERT @VM TO NL IN EXTRACTED.DATA
                            END   ;*GB0101143 E
                        END
                    END

                CASE YCONV[1,7] = "ADDRESS"
                    GOSUB GET.COMPANY.OR.CUST
                    IF customerKey OR companyCode THEN
                        GOSUB GET.PRINT.ADDRESS
                    END ELSE
                        CONVERT @VM TO NL IN EXTRACTED.DATA
                    END
*
                CASE YCONV[1,3] = "PTT"     ;* Add PTT code
                    YFLD := FIELD(EXTRACTED.DATA,">",1)
                    EXTRACTED.DATA = FIELD(EXTRACTED.DATA,">",2)
                    BEGIN CASE
                        CASE YFLD[1,2] MATCHES "42":@VM:"46"
                            GOSUB GET.COMPANY.OR.CUST
                            IF customerKey OR companyCode THEN
                                GOSUB GET.PRINT.ADDRESS
                            END ELSE
                                CONVERT @VM TO NL IN EXTRACTED.DATA
                            END
                        CASE 1
                            CONVERT @VM TO NL IN EXTRACTED.DATA      ;* Payment dets
                    END CASE
*
** VESR conversion relies on the reference being formatted correctly
** either 15, 16 or 27 numeric with the corresponding Ben account number
** and amount
*
                CASE YCONV = "VESR"
                    BEGIN CASE
                        CASE YFLD = "17"
                            IF LEN(EXTRACTED.DATA) = 11 THEN
                                YFLD := "D"
                            END ELSE
                                YFLD := "E"
                            END
                            CONVERT ',' TO '' IN EXTRACTED.DATA
                            CONVERT "." TO "," IN EXTRACTED.DATA
                            Z = INDEX(EXTRACTED.DATA,",",1)
                            IF Z = 0 THEN EXTRACTED.DATA = EXTRACTED.DATA:","
                        CASE YFLD = "45"
                            IF LEN(EXTRACTED.DATA) = 9 THEN
                                YFLD := "D"
                            END ELSE
                                YFLD := "E"
                            END
                        CASE YFLD = "49"
                            BEGIN CASE
                                CASE LEN(EXTRACTED.DATA) = 16
                                    YFLD := "D"
                                CASE LEN(EXTRACTED.DATA) = 27
                                    YFLD := "E"
                                CASE 1    ;* Old VESR
                                    YFLD := "F"
                                    EXTRACTED.DATA := "  "    ;* Add 2 spaces
                            END CASE
                    END CASE
*
                CASE 1
            END CASE
*
            AV1 = EB.SystemTables.getAv()
            IF DE.Outward.getRHead(DE.Config.OHeader.HdrMsgErrorCode)<1,AV1> = "" THEN
                IF EXTRACTED.DATA THEN
                    SIC.MESSAGE := "<":YFLD:">":EXTRACTED.DATA:NL     ;* Put this into the message
                END
            END ELSE
                GOTO END.PGM
            END
*
        END ELSE
*
            AV1 = EB.SystemTables.getAv()
            BEGIN CASE
                CASE YFLD = "02"  ;* Add BC Code for diverted types
                    IF DE.Outward.getRHead(DE.Config.OHeader.HdrMessageType) LT 1200 OR DE.Outward.getRHead(DE.Config.OHeader.HdrMessageType) GE 1300 THEN
                        SIC.MESSAGE := "<":YFLD:">":DE.Outward.getDelcClearing(FT.Clearing.LocalClearing.LcBcCode)<1,1>:NL      ;* Put this into the message
                    END ELSE
                        tmp=DE.Outward.getRHead(DE.Config.OHeader.HdrMsgErrorCode); tmp<1,AV1>="Error - BC CODE for bank not set up"; DE.Outward.setRHead(DE.Config.OHeader.HdrMsgErrorCode, tmp)
                        GOSUB WRITE.REPAIR
                        RETURN
                    END
                CASE YFLD = "18"
                    IF DE.Outward.getRHead(DE.Config.OHeader.HdrMessageType) LT 1200 OR DE.Outward.getRHead(DE.Config.OHeader.HdrMessageType) GE 1300 THEN
                        SIC.MESSAGE := "<":YFLD:">":DE.Outward.getRHead(DE.Config.OHeader.HdrToAddress)<1,AV1>:NL
                    END ELSE
                        tmp=DE.Outward.getRHead(DE.Config.OHeader.HdrMsgErrorCode); tmp<1,AV1>="Error - no destination BC SORT CODE field 18"; DE.Outward.setRHead(DE.Config.OHeader.HdrMsgErrorCode, tmp)
                        GOSUB WRITE.REPAIR
                        RETURN
                    END
*******************************************************************
* 112  = Spot/Kasse
* 122  = Termin
* 132  = Noten
* 192  = Diverse
*
* 212  = Festgeld
* 222  = Callgeld
* 223  = Treuhandanlagen
* 224  = Diverse
*
* 312  = Spot/Kasse
* 322  = Termin
* 323  = Numismatik und Munzen
* 392  = Diverse
*
* 411  = Emissionen
* 421  = Borse (exkl SEGA)
* 431  = Coupons
* 441  = RuckZahlbare Titel
* 491  = Diverse
*
* 511  = Hypotheken
* 521  = Darlehen
* 531  = Unterbeteiligungen
* 591  = Diverse
*
**********************************************************************
                CASE YFLD = '58'

                    EXTRACTED.DATA = DE.Outward.getRHead(DE.Config.OHeader.HdrTransRef)
                    BEGIN CASE

                        CASE EXTRACTED.DATA[1,2] = 'FX'
                            R.PAR = '' ; R.REC = ''
                            R.REC = FX.Contract.Forex.Read(EXTRACTED.DATA, '')
                            R.PAR = FX.Config.Parameters.Read("FX.PARAMETERS", '')
                            LOCATE R.REC<FX.Contract.Forex.CurrencyBought> IN R.PAR<FX.Config.Parameters.PPreciousMetals> SETTING POS ELSE POS = 0
                            IF POS THEN
                                PAYMENT.CODE = '392'
                                IF R.REC<FX.Contract.Forex.DealType> = 'SP' THEN
                                    PAYMENT.CODE = '312'
                                END ELSE
                                    PAYMENT.CODE = '322'
                                END
                            END ELSE
                                PAYMENT.CODE = '192'
                                IF R.REC<FX.Contract.Forex.DealType> = 'SP' THEN
                                    PAYMENT.CODE = '112'
                                END ELSE
                                    PAYMENT.CODE = '122'
                                END
                            END
                            SIC.MESSAGE := "<":YFLD:">":PAYMENT.CODE:NL
                        CASE EXTRACTED.DATA[1,2] = 'MM'
                            R.REC = MM.Contract.MoneyMarket.Read(EXTRACTED.DATA, '')
                            PAYMENT.CODE = '292'
                            IF R.REC THEN
                                CATEGORY = R.REC<MM.Contract.MoneyMarket.Category>
                                MATURITY.DATE = R.REC<MM.Contract.MoneyMarket.MaturityDate>
                                GOSUB GET.CONTRACT
                            END

                            SIC.MESSAGE := "<":YFLD:">":PAYMENT.CODE:NL

                        CASE EXTRACTED.DATA[1,2] = 'LD'
                            R.REC = ''
                            R.REC = LD.Contract.LoansAndDeposits.Read(EXTRACTED.DATA, '')

                            PAYMENT.CODE = '591'
                            IF R.REC THEN
                                CATEGORY = R.REC<LD.Contract.LoansAndDeposits.Category>
                                MATURITY.DATE = R.REC<LD.Contract.LoansAndDeposits.FinMatDate>
                                GOSUB GET.CONTRACT

                            END
                            SIC.MESSAGE := "<":YFLD:">":PAYMENT.CODE:NL
                        CASE EXTRACTED.DATA[1,2] = 'SC'
                            SIC.MESSAGE := "<":YFLD:">491"
*
                        CASE EXTRACTED.DATA[1,2] = "FD"   ;* Fids
                            SIC.MESSAGE := "<":YFLD:">232"

                    END CASE
                CASE YFLD = "83"  ;* Authenticator to SIC
                    SIC.MESSAGE := "<":YFLD:">":DE.Outward.getDelcClearing(FT.Clearing.LocalClearing.LcAuthentCode)
                CASE 1
                    AV1 = EB.SystemTables.getAv()
                    IF YMAND = "Y" THEN     ;* This field is mandatory
                        tmp=DE.Outward.getRHead(DE.Config.OHeader.HdrMsgErrorCode); tmp<1,AV1>="Error missing mandatory field on SIC message ":SIC.MESSAGE.TYPE:" field ":YFLD; DE.Outward.setRHead(DE.Config.OHeader.HdrMsgErrorCode, tmp)
                        GOSUB WRITE.REPAIR
                        RETURN
                    END
            END CASE
        END
*
    REPEAT
    AV1 = EB.SystemTables.getAv()
    tmp=DE.Outward.getRHead(DE.Config.OHeader.HdrMsgDisp); tmp<1,AV1>="FORMATTED"; DE.Outward.setRHead(DE.Config.OHeader.HdrMsgDisp, tmp)
    DE.Outward.OOutputTelexKey()

    IF DE.Outward.getCarrierService() = '1' THEN       ;* EN_10002614 -s
        DE.Outward.setFDeOMsgSic(DE.Outward.getFDeOMsgCarrier())
    END   ;* EN_10002614 -e

    REC.ID = DE.Outward.getRKey():".":AV1
    DE.ModelBank.OMsgSicWrite(REC.ID, SIC.MESSAGE, '')
**
END.PGM:
RETURN
*
*-----------------------------------------------------------------------
WRITE.REPAIR:
*===========
* Add key to repair file
*
    AV1 = EB.SystemTables.getAv()
    tmp=DE.Outward.getRHead(DE.Config.OHeader.HdrMsgDisp); tmp<1,AV1>='REPAIR'; DE.Outward.setRHead(DE.Config.OHeader.HdrMsgDisp, tmp)
    R.REPAIR = DE.Outward.getRKey():'.':AV1
    DE.Outward.UpdateORepair(R.REPAIR,'')
RETURN
*
* Error has occurred.  Return to calling program
*
*-------------------------------------------------------------------------
GET.CONTRACT:

    CONTRACT = ''

    BEGIN CASE

        CASE CATEGORY GE 21001 AND CATEGORY LE 21039
            CONTRACT = "D"
        CASE CATEGORY GE 21050 AND CATEGORY LE 21074
            CONTRACT = "L"
            PAYMENT.CODE = '521'
        CASE CATEGORY GE 21075 AND CATEGORY LE 21084
            CONTRACT = "P"
        CASE CATEGORY GE 21040 AND CATEGORY LE 21044
            CONTRACT = "F"
        CASE CATEGORY GE 21085 AND CATEGORY LE 21089
            CONTRACT = "F"

    END CASE

    IF CONTRACT = 'D' OR CONTRACT = 'P' THEN
        IF MATURITY.DATE < 1000 THEN
            PAYMENT.CODE = "222"        ;* Call Notice
        END ELSE
            PAYMENT.CODE = "212"
        END
    END ELSE
        IF CONTRACT EQ 'F' THEN
            PAYMENT.CODE = '232'
        END
    END
RETURN
*------------------------------------------------------------------------
CHECK.ACCT.WITH:
*==============
** Check with acct with bank against beneficiary. If they are the same
** then the message is an B10
*
    IF DE.Clearing.getSicDiversionFlds()<YPOS,2> THEN
        IF R.DETAIL(DE.Clearing.getSicDiversionFlds()<YPOS,2>) THEN        ;* Acct With Bank
            IF DE.Clearing.getSicDiversionFlds()<YPOS,3> THEN
                IF R.DETAIL(DE.Clearing.getSicDiversionFlds()<YPOS,2>) EQ R.DETAIL(DE.Clearing.getSicDiversionFlds()<YPOS,3>) THEN          ;* Acct with NE Ben
                    SIC.MESSAGE.TYPE = "B10"
                END
            END ELSE
                SIC.MESSAGE.TYPE = "B10"          ;* No Ben cust field$
            END
        END
    END
*
RETURN
*
*
*-------------------------------------------------------------------------
GET.PRINT.ADDRESS:
*=================
    TRANSL = 1
    LANGCODE = 1
    LOCATE DE.Outward.getRHead(DE.Config.OHeader.HdrTranslation)<1,EB.SystemTables.getAv()> IN EB.SystemTables.getTLanguage()<1> SETTING LANGCODE ELSE LANGCODE = 1

    keyDetails = ''
    keyDetails<AddressIDDetails.customerKey> = customerKey
    keyDetails<AddressIDDetails.preferredLang> = LANGCODE
    keyDetails<AddressIDDetails.companyCode> = companyCode
    keyDetails<AddressIDDetails.addressNumber> = 1
    address = ''
    CALL CustomerService.getPhysicalAddress(keyDetails, address)
    IF EB.SystemTables.getEtext() = '' THEN
        delivery.name1 = address<Address.name1>
        delivery.name2 = address<Address.name2>
        delivery.streetAddress = address<Address.streetAddress>
        delivery.townCounty = address<Address.townCounty>
        delivery.country = address<Address.country>
        delivery.postCode = address<Address.postCode>

        IF YCONV[6] NE "*SHORT" THEN    ;* Full address
            IF SIC.MESSAGE.TYPE NE "C10" THEN
                EXTRACTED.DATA = delivery.name1 ;* This should always be present
            END ELSE
                EXTRACTED.DATA = delivery.name1[1,30]  ;* This should always be present
            END

            LINE.CNT = 1
            thisValue = delivery.name2
            GOSUB AppendValue
            thisValue = delivery.streetAddress
            GOSUB AppendValue
            thisValue = delivery.townCounty
            GOSUB AppendValue
            thisValue = delivery.postCode
            GOSUB AppendValue

        END ELSE
            IF SIC.MESSAGE.TYPE NE "C10" THEN
                EXTRACTED.DATA = delivery.name1
            END ELSE
                EXTRACTED.DATA = delivery.name1[1,30]
            END
        END
    END ELSE
        AV1 = EB.SystemTables.getAv()
        tmp=DE.Outward.getRHead(DE.Config.OHeader.HdrMsgErrorCode); tmp<1,AV1>="ERROR - missing DE.ADDRESS record for CUST ":EXTRACTED.DATA; DE.Outward.setRHead(DE.Config.OHeader.HdrMsgErrorCode, tmp)
        GOSUB WRITE.REPAIR
    END
*
RETURN

*-----------------------------------------------------------------------------
AppendValue:

    IF (thisValue NE '' AND LINE.CNT < 4) THEN ;* Maximum of 4 address lines allowed
        IF SIC.MESSAGE.TYPE NE "C10" THEN
            EXTRACTED.DATA := NL:thisValue
        END ELSE
            IF YFLD[1,3] = "46D" AND LINE.CNT = 2 THEN  ;* Don't add
                EXTRACTED.DATA := NL
            END ELSE
                EXTRACTED.DATA := NL:thisValue[1,30]     ;* Max length 30
            END
        END
        LINE.CNT += 1
    END

RETURN

*-----------------------------------------------------------------------------
GET.COMPANY.OR.CUST:
*==================
** Decide the first part of the DE.ADDRESS key, ie company or customer
*
    customerKey = ''
    companyCode = ''
    BEGIN CASE
        CASE EXTRACTED.DATA MATCHES "1N0N" AND LEN(EXTRACTED.DATA) LE 11  ;* May be a customer id  ; * CI-10000692 S/E
            customerKey = EXTRACTED.DATA
            companyCode = DE.Outward.getRHead(DE.Config.OHeader.HdrCusCompany)
        CASE EXTRACTED.DATA MATCHES "2A7N"  ;* Company code
            companyCode = EXTRACTED.DATA
    END CASE

RETURN
*
*----------------------------------------------------------------
* Standard text in place of customer number
* Code not tested
GET.ORD.CUS.TEXT:
    AV1 = EB.SystemTables.getAv()
    CUS.TEXT.IND.REC = ''
    IF YCONV EQ 'SWIFT*TEXT' THEN
        CUS.TEXT.REC = ''
        IF delivery.confidTxt[1,1] = 'Y' THEN
            REC.COUNTRY.CODE = DE.Outward.getRHead(DE.Config.OHeader.HdrToAddress)<1,AV1> [5,2]
            REC.CODE.ID = 'ORD'
            CUS.TEXT.REC = '' ; READ.ERR = ''
            F.DE.TRANSLATION.LOC = '' ; EB.DataAccess.Opf('F.DE.TRANSLATION', F.DE.TRANSLATION.LOC)
            DE.Outward.setFDeTranslation(F.DE.TRANSLATION.LOC)
            CUS.TEXT.REC = DE.Config.Translation.Read(REC.CODE.ID, READ.ERR)

            IF READ.ERR = '' THEN

                LOCATE REC.COUNTRY.CODE IN EB.SystemTables.getTLanguage()<1> SETTING LANG.POS ELSE LANG.POS = ''
                IF LANG.POS THEN

                    CUS.TEXT.IND.REC = CUS.TEXT.REC<1,LANG.POS>
                    IF CUS.TEXT.IND.REC = 'NO TEXT' THEN
                        CUS.TEXT.IND.REC = ''
                    END
                END

            END

            IF CUS.TEXT.IND.REC THEN
                TEMP.FIELD = CUS.TEXT.IND.REC
            END
        END
    END
RETURN

*---------------------------------------------------------------------
SET.UP.DIVERSION.DETS:
*=====================
** Build up the list of ACCT with and No divert fields in
** SIC$DIVERSION.TYPE<x> - message type eq 100, 200
** SIC$DIVERSION.FLDS<x,1,y> - INTERMED fields
** SIC$DIVERSION.FLDS<x,2,y> - ACCT.WITH fields
** SIC$DIVERSION.FLDS<X,3,Y> - Ben customer / Bank field
** SIC$DIVERSION.FLDS<X,4,Y> - Charge details
** SIC$DIVERSION.FLDS<X,5,Y> - Bank to Bank inFO
** SIC$DIVERSION.FLDS<x,6,y> - No diversion fields
*
    tmp=DE.Clearing.getSicDiversionType(); tmp<YI>=YMSG; DE.Clearing.setSicDiversionType(tmp)

    LOOP REMOVE YFD FROM YNAMES SETTING XX UNTIL YFD = ""
        LOCATE YFD IN YR.MESS<DE.Config.Message.MsgFieldName,1> SETTING YX THEN
            tmp=DE.Clearing.getSicDiversionFlds(); tmp<YI,YDL,-1>=YX; DE.Clearing.setSicDiversionFlds(tmp);* Store position
        END ELSE NULL
    REPEAT
*
RETURN
*---------------
END
