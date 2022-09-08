* @ValidationCode : MjotMTUwMzE3NzUwMjpDcDEyNTI6MTYxODgzNjM3MDczNjpsYWxpdGhhbGFrc2htaTotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDIxMDMuMjAyMTAzMDEtMDU1NjotMTotMQ==
* @ValidationInfo : Timestamp         : 19 Apr 2021 18:16:10
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : lalithalakshmi
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210301-0556
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.








*-----------------------------------------------------------------------------
$PACKAGE CK.Channels
SUBROUTINE E.NOFILE.TC.AA.CONSENT.TYPE(CONSENT.DETAILS)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
* This Enquiry(Nofile) routine used to get details of consent for external user
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Nofile routine
* Attached To        : Enquiry > TC.NOF.AA.CONSENT.TYPE using the Standard selection NOFILE.TC.AA.CONSENT.TYPE
* IN Parameters      : Customer Id and Property Class
* Out Parameters     : CONSENT.DETAILS (Array of consent details such as Arrangement id, Effective date, Product, Consent type, Consent given, Consent sub given, Consent sub type)
*
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 18/05/18 - Enhancement 2560539  / Task 2601640
*            GDPR Consent - Fetch details of consent related to external user
*
* 06/06/18 - Enhancement 2560539  / Task 2621160
*            GDPR Consent - Fetch Expiry date  of consent related to external user
*
* 18/06/18 - Defect 2632257 / Task 2639180
*            GDPR Consent - Fetch Consent Type Description
*
* 19/04/21 - Defect 4334192 / Task 4339240
*            Infinity - When there is a change which is pending authorization in T24, user is unable to make a change from OLB. No error is displayed when the user tries to make a change in OLB

*-----------------------------------------------------------------------------
*** <region name = Inserts>
    $USING CK.Channels
    $USING EB.Reports
    $USING CK.Consent
    $USING AA.Framework
	$USING EB.Interface

*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Main Process>

    GOSUB INITIALISE                  ;* Initialise variables
    GOSUB ARRANGEMENT.DETAILS                 ;* Get the arrangement details
    GOSUB BUILD.CONSENT.ARRAY.DETAILS       ;* Build final output array
*
RETURN

*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Initialise Variables>
INITIALISE:
*-----------
    CustomerPosition ='' ; PropertyPosition ='' ; CustomerId='' ; PropertyClass ='' ; ArrangementId ='' ; RPropertyClassCondition ='' ; RConsentType ='' ; EffectiveDate ='' ; Product ='' ; ConsentType ='' ; ConsentTypeDesc ='' ; ConsentGiven ='' ;
    ConsentSubType ='' ; ConsentSubGiven =''; ConsentBlock ='' ; BlockNotes ='' ; ConsentWithdraw = '' ; WithdrawNotes = '' ; CONSENT.DETAILS ='';CONSENT.POS = 0 ; CONSENT.DESC.POS =1 ; NO.OF.CONSENT.TYPE='' ;

    LOCATE "CUSTOMER.ID" IN EB.Reports.getDFields()<1> SETTING CustomerPosition THEN
        CustomerId = EB.Reports.getDRangeAndValue()<CustomerPosition>
    END
 
    LOCATE "PROPERTY.CLASS" IN EB.Reports.getDFields()<1> SETTING PropertyPosition THEN
        PropertyClass = EB.Reports.getDRangeAndValue()<PropertyPosition>
    END
*
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name = Arrangement Details>
ARRANGEMENT.DETAILS:
*-------------------
*****Get consent details from arrangement*****

    ArrangementId = CK.Consent.CdpConsentXref.Read(CustomerId, ConsentError)   ;* Get arrangement id of consent
    InParam = ArrangementId:"//AUTH"
    AA.Framework.GetArrangementConditions(InParam,PropertyClass,'','','',RPropertyClassCondition,PropertyClassConditionError)  ;* Get arrangement conditions based on the property class.
    RPropertyClassCondition = RAISE(RPropertyClassCondition)    ;* Raise the Position of the record
    EffectiveDate = RPropertyClassCondition<CK.Consent.CdpConsent.IdCompThr> ;* Get start date of consent
    Product = RPropertyClassCondition<CK.Consent.CdpConsent.IdCompTwo>    ;* Get product details
    ExpiryDate = RPropertyClassCondition<CK.Consent.CdpConsent.ExpiryDate>    ;* Get Expiry date related to consent type
    ConsentType = RPropertyClassCondition<CK.Consent.CdpConsent.ConsentType> ;*Get the consent type list
    
    NO.OF.CONSENT.TYPE = DCOUNT(ConsentType,@VM)
    FOR CONSENT.POS = 1 TO NO.OF.CONSENT.TYPE
        RConsentType =CK.Consent.ConsentType.Read(ConsentType<1,CONSENT.POS>, ConsentTypeError)    ;* Get the consent type record
        ConsentTypeDesc<1,CONSENT.DESC.POS> = RConsentType<CK.Consent.ConsentType.Description>    ;* Get the description of the consent type
        CONSENT.DESC.POS += 1
    NEXT CONSENT.POS

    ConsentGiven = RPropertyClassCondition<CK.Consent.CdpConsent.ConsentGiven>   ;*Get the consent given for all consent type
    ConsentSubType = RPropertyClassCondition<CK.Consent.CdpConsent.ConsentSubType>  ;*Get the consent sub type list
    ConsentSubGiven = RPropertyClassCondition<CK.Consent.CdpConsent.SubTypeConsentGiven>    ;*Get the consent sub given for all consent sub type
    ConsentBlock =  RPropertyClassCondition<CK.Consent.CdpConsent.ConsentBlock>    ;*Get the consent block details
    BlockNotes =  RPropertyClassCondition<CK.Consent.CdpConsent.BlockNotes>    ;*Get the consent block notes details
    ConsentWithdraw =  RPropertyClassCondition<CK.Consent.CdpConsent.ConsentWithdraw>    ;*Get the consent withdraw details
    WithdrawNotes = RPropertyClassCondition<CK.Consent.CdpConsent.WithdrawNotes>    ;*Get the withdraw notes details
*
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
*** <region name= Build the Array according to Enquiry requirements>
BUILD.CONSENT.ARRAY.DETAILS:
*---------------------------
* Build consent array details
	IF ('OFS.OVERRIDE' MATCHES  EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcAttributes>) ELSE
	    CHANGE @VM TO "|" IN ConsentType  ;* Convert value marker into | in consent type
	    CHANGE @VM TO "|" IN ConsentGiven  ;* Convert value marker into | in consent given
	    CHANGE @VM TO "|" IN ConsentSubType   ;* Convert value marker into | in consent sub type
	    CHANGE @VM TO "|" IN ConsentSubGiven  ;* Convert value marker into | in consent sub type given
	    CHANGE @VM TO "|" IN ConsentBlock  ;* Convert value marker into | in consent block
	    CHANGE @VM TO "|" IN BlockNotes  ;* Convert value marker into | in block notes
	    CHANGE @VM TO "|" IN ConsentWithdraw   ;* Convert value marker into | in consent withdraw
	    CHANGE @VM TO "|" IN WithdrawNotes  ;* Convert value marker into | in withdraw notes
	    CHANGE @VM TO "|" IN ConsentTypeDesc  ;* Convert value marker into | in consent type description
	    
	    CHANGE @SM TO "#" IN ConsentType  ;* Convert sub marker into # in consent type
	    CHANGE @SM TO "#" IN ConsentGiven  ;* Convert sub marker into # in consent given
	    CHANGE @SM TO "#" IN ConsentSubType   ;* Convert sub marker into # in consent sub type
	    CHANGE @SM TO "#" IN ConsentSubGiven  ;* Convert sub marker into # in consent sub type given
	    CHANGE @SM TO "#" IN ConsentBlock   ;* Convert sub marker into # in consent block
	    CHANGE @SM TO "#" IN BlockNotes  ;* Convert sub marker into # in block notes
	    CHANGE @SM TO "#" IN ConsentWithdraw   ;* Convert sub marker into # in consent withdraw
	    CHANGE @SM TO "#" IN WithdrawNotes  ;* Convert sub marker into # in withdraw notes
	    CHANGE @SM TO "#" IN ConsentTypeDesc   ;* Convert sub marker into # in consent type description
    END
    CONSENT.DETAILS<-1> =ArrangementId:"*":EffectiveDate:"*":Product:"*":ExpiryDate:"*":ConsentType:"*":ConsentGiven:"*":ConsentSubType:"*":ConsentSubGiven:"*":ConsentBlock:"*":BlockNotes:"*":ConsentWithdraw:"*":WithdrawNotes:"*":ConsentTypeDesc
*
RETURN
*** </region>
*--------------------------------------------------------------------------------------------------------------
END
