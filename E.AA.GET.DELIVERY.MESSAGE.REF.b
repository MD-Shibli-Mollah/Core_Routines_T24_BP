* @ValidationCode : Mjo5ODI2MDk0MTQ6Q3AxMjUyOjE2MDYyODI5ODEwODI6cmFuZ2FoYXJzaGluaXI6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA2LjIwMjAwNTIxLTA2NTU6LTE6LTE=
* @ValidationInfo : Timestamp         : 25 Nov 2020 11:13:01
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rangaharshinir
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-124</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.DELIVERY.MESSAGE.REF(RETURN.ARRAY)
*
*** <region name= Description>
*** <desc>Task of the sub-routine</desc>
* Program Description
*
** This routine will be used get the delivery message reference from AA.ARRANGEMENT.ACTIIFVTY record.
**
*-----------------------------------------------------------------------------
* @package retaillending.AA
* @class AA.ModelBank
* @stereotype subroutine
* @link STANDARD.SELECTION>NOFILE.AA.DETAILS.MESSAGES
* @author psabari@temenos.com
*-----------------------------------------------------------------------------
*
*** </region>

*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
* Input
*
* @param ENQ.SELECTION - <2,1>   Arrangement id
*
* Output
*
* @param RETURN.ARRAY  - <1>     Activity date
*                      - <2>     Activity
*                      - <3>     Activity reference
*                      - <4>     Delivery message reference
*-----------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History
*
* 28/03/13 - New routine.
*            Defect: 607823
*
* 26/11/13  - Defect : 846936
*             Task   : 847019
*             Return value should be separated by "#" other than "*".Since some activity will have  '*' in their name.
*
* 10/02/15  - Defect : 1247848
*             Task   : 1250600
*             Restricted Backdating: HELOC Statement generated based on the Defer Days disappeared
*
* 21/09/15  - Task   : 1476009
*             Defect : 923916
*             Enquiry enhanced to support .HIST files.
*
* 10/03/17 - Task: 2020813
*            Enhancement: 2020817
*            Stop direct direct read of activity history record for HVT account and
*            call AC.HVT.MERGE to get the merged activity history record.
*
*29/04/20 - Task  : 3723790
*            Defect: 3684150
*            Enquiry AA.DETAILS.MESSAGES should display all carrier details for Delivery Reference in enquiry output.
*
*04/09/20 - Task  : 3904389
*            Enhancement: 3164925
*            To get the participant id as the input and return the delivery messages for the corresponding participant id
*
* 19/11/20  - Enhancement : 4051785
*             Task : 4083926
*             To append the activity names and effective dates to enquiry output correspondingly
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts

    $USING AA.Framework
    $USING EB.Reports
    $USING DE.Config
    $USING EB.DataAccess

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>main control logic in the sub-routine</desc>

    GOSUB INITIALISE

    LOCATE 'PARTICIPANT.ID' IN EB.Reports.getEnqSelection()<2,1> SETTING SIM.POS THEN ;* get the participant id from the enquiry
        PARTICIPANT.ID = EB.Reports.getEnqSelection()<4,SIM.POS>
    END
    
    LOCATE 'ARRANGEMENT.ID' IN EB.Reports.getEnqSelection()<2,1> SETTING ARR.POS THEN
        ARR.ID = EB.Reports.getEnqSelection()<4,ARR.POS>
    END
    LOCATE 'ARCHIVED.ONLY' IN EB.Reports.getEnqSelection()<2,1> SETTING ARC.POS THEN
        ARCHIVED.ONLY = EB.Reports.getEnqSelection()<4,ARC.POS>
    END

    FIX.SEL = EB.Reports.getREnq()<EB.Reports.Enquiry.EnqFixedSelection>

    NO.SEL = DCOUNT(FIX.SEL,@VM)
    FOR CNT.LOOP = 1 TO NO.SEL
        SEL.COND = FIX.SEL<1,CNT.LOOP>

        BEGIN CASE
            CASE SEL.COND[' ',1,1] EQ 'ARCHIVED.ONLY'
                ARCHIVED.ONLY = SEL.COND[' ',3,1]
        END CASE
    NEXT CNT.LOOP
    IF ARR.ID THEN  ;* Process only when arrangement id is present.
        GOSUB OPEN.FILES
        GOSUB PROCESS
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc>File variables and local variables</desc>
INITIALISE:
*----------
    PARTICIPANT.ID = ""
    EFFECTIVE.DATE = ''
    ACTIVITY = ''
    ACTIVITY.REF = ''
    DELIVERY.REF = ''
    ARR.ID = ''
    RETURN.ARRAY = ''
    DELIVERY.REFERENCES = ""
    ADJUSTMENT.REFERENCES = ""
    ARCHIVED.ONLY = ''        ;* Flag to indicate system to return only Archived activities

    F.DE.O.HEADER = ''
    EB.DataAccess.Opf('F.DE.O.HEADER',F.DE.O.HEADER)
RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Open Files>
*** <desc>Open the required files to be used</desc>
OPEN.FILES:
*----------

    F.AA.ACTIVITY.BALANCES = ""

    F.AA.ARRANGEMENT.ACTIVITY = ''

    F.AA.ARRANGEMENT.ACTIVITY$HIS = ''

    F.AA.ARRANGEMENT.ACTIVITY$NAU = ''

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Process>
*** <desc>Set-up action processing</desc>
PROCESS:
*-------

    R.AA.ACTIVITY.HISTORY = ''
    AA.Framework.ReadActivityHistory(ARR.ID, '', '', R.AA.ACTIVITY.HISTORY)     ;* Get the activity history record.
    
    R.AA.ARRANGEMENT = ''
    R.AA.ARRANGEMENT = AA.Framework.Arrangement.Read(ARR.ID, RET.ERROR)
    BEGIN CASE
        CASE ARCHIVED.ONLY EQ "YES"
* If Archived only is set to Yes, then archived records requested so display only the archived records.
            ARC.IDS = R.AA.ACTIVITY.HISTORY<AA.Framework.ActivityHistory.AhArcId>
            R.AA.ACTIVITY.HISTORY = ""
            GOSUB GET.ARCHIVED.ACITIVITY.LIST
        CASE ARCHIVED.ONLY EQ "NO"
* If Archived only is set to No then display all the activities including archival.
        CASE ARCHIVED.ONLY EQ ""
* leave with existing functionality and don't touch anything.
    END CASE

    EFF.DATE.CNT = DCOUNT(R.AA.ACTIVITY.HISTORY<AA.Framework.ActivityHistory.AhEffectiveDate>,@VM)
    INT.DATE.CNT = 1

    LOOP
    WHILE (INT.DATE.CNT LE EFF.DATE.CNT)
        INT.ACCT.CNT = 1
        ACCT.CNT = DCOUNT(R.AA.ACTIVITY.HISTORY<AA.Framework.ActivityHistory.AhActivity,INT.DATE.CNT>,@SM)
        LOOP
        WHILE (INT.ACCT.CNT LE ACCT.CNT)

            ACTIVITY.STATUS = R.AA.ACTIVITY.HISTORY<AA.Framework.ActivityHistory.AhActStatus,INT.DATE.CNT,INT.ACCT.CNT>
            EFFECTIVE.DATE  = R.AA.ACTIVITY.HISTORY<AA.Framework.ActivityHistory.AhEffectiveDate,INT.DATE.CNT>
            ACTIVITY        = R.AA.ACTIVITY.HISTORY<AA.Framework.ActivityHistory.AhActivity,INT.DATE.CNT,INT.ACCT.CNT>
            ACTIVITY.REF    = R.AA.ACTIVITY.HISTORY<AA.Framework.ActivityHistory.AhActivityRef,INT.DATE.CNT,INT.ACCT.CNT>
            ACTIVITY.TYPE   = R.AA.ACTIVITY.HISTORY<AA.Framework.ActivityHistory.AhInitiation,INT.DATE.CNT,INT.ACCT.CNT>

            BEGIN CASE
                CASE ACTIVITY.STATUS EQ 'AUTH'
                    FILE.TO.CHECK = ""
                    GOSUB GET.AAA.FROM.LIVE
                    GOSUB GET.DELIVERY.MESSAGE.REF
                CASE ACTIVITY.STATUS EQ 'DELETE-REV'
                    FILE.TO.CHECK = ""
                    GOSUB GET.AAA.FROM.LIVE
                    GOSUB GET.DELIVERY.MESSAGE.REF
                CASE ACTIVITY.STATUS EQ 'AUTH-REV'
                    FILE.TO.CHECK = "$HIS"
                    GOSUB GET.AAA.FROM.HISTORY.OR.NAU
                    GOSUB GET.DELIVERY.MESSAGE.REF
                CASE ACTIVITY.STATUS EQ 'REVERSE'
                    FILE.TO.CHECK = "$NAU"
                    GOSUB GET.AAA.FROM.HISTORY.OR.NAU
                    GOSUB GET.DELIVERY.MESSAGE.REF
            END CASE

            INT.ACCT.CNT += 1
        REPEAT
        INT.DATE.CNT += 1
    REPEAT

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Get AAA From Live>
*** <desc>Get AA Arrangement Activity Record from Live file</desc>
GET.AAA.FROM.LIVE:
*-----------------

    AAA.TXN.REFERENCE = ACTIVITY.REF
    GOSUB READ.AA.ARRANGEMENT.ACTIVITY
    DELIVERY.REFERENCES = R.AA.ARRANGEMENT.ACTIVITY<AA.Framework.ArrangementActivity.ArrActDeliveryRef>


RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Get AAA From History or INAU>
*** <desc>Get AA Arrangement Activity Record from History or Unauthorised file</desc>
READ.AA.ARRANGEMENT.ACTIVITY:
*----------------------------

    R.AA.ARRANGEMENT.ACTIVITY = ''
    ERR.R.AA.ARRANGEMENT.ACTIVITY = ''

    BEGIN CASE
        CASE FILE.TO.CHECK EQ "$NAU"
            R.AA.ARRANGEMENT.ACTIVITY = AA.Framework.ArrangementActivity.ReadNau(AAA.TXN.REFERENCE, ERR.R.AA.ARRANGEMENT.ACTIVITY)
        CASE FILE.TO.CHECK EQ "$HIS"
            AAA.TXN.REFERENCE := ";2"       ;* Incase History add the Cur No.
            R.AA.ARRANGEMENT.ACTIVITY = AA.Framework.ArrangementActivity.ReadHis(AAA.TXN.REFERENCE, ERR.R.AA.ARRANGEMENT.ACTIVITY)
            AAA.TXN.REFERENCE = AAA.TXN.REFERENCE[";", 1, 1]    ;* Restore it back, we may be using it.
        CASE 1
            R.AA.ARRANGEMENT.ACTIVITY = AA.Framework.ArrangementActivity.Read(AAA.TXN.REFERENCE, ERR.R.AA.ARRANGEMENT.ACTIVITY)
    END CASE

    IF R.AA.ARRANGEMENT.ACTIVITY<AA.Framework.ArrangementActivity.ArrActAdjustment> THEN  ;* Storing adjustement references is important because a user activity Id may already changed by RR and User also reversed the new one manually.

        ADJUSTMENT.REF = R.AA.ARRANGEMENT.ACTIVITY<AA.Framework.ArrangementActivity.ArrActAdjustment>
        LOCATE ADJUSTMENT.REF IN ADJUSTMENT.REFERENCES<1,1> SETTING ADJ.POS ELSE
            ADJUSTMENT.REFERENCES<1,ADJ.POS> = ADJUSTMENT.REF
            ADJUSTMENT.REFERENCES<2,ADJ.POS> = ACTIVITY.STATUS
            NULL
        END

    END

RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Get AAA From History or NAU>
*** <desc>Get AA Arrangement Activity Record from History or NAU</desc>
GET.AAA.FROM.HISTORY.OR.NAU:
*---------------------------

    AAA.TXN.REFERENCE = ACTIVITY.REF
    GOSUB READ.AA.ARRANGEMENT.ACTIVITY
    DELIVERY.REFERENCES = R.AA.ARRANGEMENT.ACTIVITY<AA.Framework.ArrangementActivity.ArrActDeliveryRef>
    REV.MASTER.AAA      = R.AA.ARRANGEMENT.ACTIVITY<AA.Framework.ArrangementActivity.ArrActRevMasterAaa>
    LINKED.ACTIVITY     = R.AA.ARRANGEMENT.ACTIVITY<AA.Framework.ArrangementActivity.ArrActLinkedActivity>

    IF NOT(DELIVERY.REFERENCES) THEN    ;* We don't Need to check the master because it doesn't have a delivery referance generated.
        RETURN
    END

    LOOP
    WHILE ACTIVITY.TYPE EQ "SECONDARY"

        LINKED.ACTIVITY = R.AA.ARRANGEMENT.ACTIVITY<AA.Framework.ArrangementActivity.ArrActLinkedActivity>
        LOCATE LINKED.ACTIVITY IN R.AA.ACTIVITY.HISTORY<AA.Framework.ActivityHistory.AhActivityRef,INT.DATE.CNT,INT.ACCT.CNT> SETTING ACT.POS THEN
            AAA.TXN.REFERENCE = R.AA.ACTIVITY.HISTORY<AA.Framework.ActivityHistory.AhActivityRef, INT.DATE.CNT, ACT.POS> : ";2"
            ACTIVITY.TYPE    = R.AA.ACTIVITY.HISTORY<AA.Framework.ActivityHistory.AhInitiation,INT.DATE.CNT,ACT.POS>
            GOSUB READ.AA.ARRANGEMENT.ACTIVITY
        END ELSE
            ACTIVITY.TYPE = ""
        END

    REPEAT

    LOCATE AAA.TXN.REFERENCE IN ADJUSTMENT.REFERENCES<1,1> SETTING ADJ.REF.POS THEN       ;* Locate the AAA.TXN.REFERENCE in Adjustment Activity list. if it exist then, it means we need to ignore the Delelivery messages generated by him.
        IF ADJUSTMENT.REFERENCES<2,ADJ.REF.POS> EQ "AUTH-REV" THEN
            DELIVERY.REFERENCES = ""
        END
    END ELSE
        IF AAA.TXN.REFERENCE EQ REV.MASTER.AAA THEN         ;* Incase the Original Master AAA is different from Activity Reference.
            DELIVERY.REFERENCES = ""
        END
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

* Paragraph to get the activities list from the Activity History archived file. AA.ACTIVITY.HISTORY.HIST.
GET.ARCHIVED.ACITIVITY.LIST:
***************************

    LOOP
        REMOVE ARC.ID FROM ARC.IDS SETTING ARCPOS
    WHILE ARC.ID : ARCPOS

        GOSUB GET.ACTIVITY.HISTORY.HIST
        IF R.AA.ACTIVITY.HISTORY THEN
            R.AA.ACTIVITY.HISTORY<AA.Framework.ActivityHistory.AhEffectiveDate>  := @VM : R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistory.AhEffectiveDate>
            R.AA.ACTIVITY.HISTORY<AA.Framework.ActivityHistory.AhActivityRef>    := @VM : R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistory.AhActivityRef>
            R.AA.ACTIVITY.HISTORY<AA.Framework.ActivityHistory.AhActivity>       := @VM : R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistory.AhActivity>
            R.AA.ACTIVITY.HISTORY<AA.Framework.ActivityHistory.AhSystemDate>     := @VM : R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistory.AhSystemDate>
            R.AA.ACTIVITY.HISTORY<AA.Framework.ActivityHistory.AhActivityAmt>    := @VM : R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistory.AhActivityAmt>
            R.AA.ACTIVITY.HISTORY<AA.Framework.ActivityHistory.AhActStatus>      := @VM : R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistory.AhActStatus>
            R.AA.ACTIVITY.HISTORY<AA.Framework.ActivityHistory.AhInitiation>     := @VM : R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistory.AhInitiation>
        END ELSE
            R.AA.ACTIVITY.HISTORY<AA.Framework.ActivityHistory.AhEffectiveDate>  = R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistory.AhEffectiveDate>
            R.AA.ACTIVITY.HISTORY<AA.Framework.ActivityHistory.AhActivityRef>    = R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistory.AhActivityRef>
            R.AA.ACTIVITY.HISTORY<AA.Framework.ActivityHistory.AhActivity>       = R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistory.AhActivity>
            R.AA.ACTIVITY.HISTORY<AA.Framework.ActivityHistory.AhSystemDate>     = R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistory.AhSystemDate>
            R.AA.ACTIVITY.HISTORY<AA.Framework.ActivityHistory.AhActivityAmt>    = R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistory.AhActivityAmt>
            R.AA.ACTIVITY.HISTORY<AA.Framework.ActivityHistory.AhActStatus>      = R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistory.AhActStatus>
            R.AA.ACTIVITY.HISTORY<AA.Framework.ActivityHistory.AhInitiation>     = R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistory.AhInitiation>
        END
    REPEAT

RETURN
*-----------------------------------------------------------------------------
GET.ACTIVITY.HISTORY.HIST:
**************************

    R.AA.ACTIVITY.HISTORY.HIST = ""
    ERR.AA.ACTIVITY.HISTORY.HIST = ""

    R.AA.ACTIVITY.HISTORY.HIST = AA.Framework.ActivityHistoryHist.Read(ARC.ID,ERR.AA.ACTIVITY.HISTORY.HIST)

RETURN

*-----------------------------------------------------------------------------
*** <region name= Get DELIVERY.MESSAGE.REF>
*** <desc>Get the delivery message reference from AAA record</desc>
GET.DELIVERY.MESSAGE.REF:
*------------------------
  
    LOOP
        REMOVE DELIVERY.REF FROM DELIVERY.REFERENCES SETTING DEL.POS
    WHILE DELIVERY.REF : DEL.POS
            
        READ YR.HEADER FROM F.DE.O.HEADER, DELIVERY.REF THEN ;* Get the DE.O.HEADER record for delivery Reference
            IF (NOT(PARTICIPANT.ID) AND YR.HEADER<DE.Config.OHeader.HdrCustomerNo> MATCHES R.AA.ARRANGEMENT<AA.Framework.Arrangement.ArrCustomer>) OR PARTICIPANT.ID EQ YR.HEADER<DE.Config.OHeader.HdrCustomerNo> THEN
                CARRIER.ADRESS = YR.HEADER<DE.Config.OHeader.HdrCarrierAddressNo> ;* Get the Carrier Adress
                CAR.ADR.CNT = DCOUNT(CARRIER.ADRESS,@VM) ;* Get the count of total carrier Address
* Append the Carrier Address along with Delivery Reference

                IF CAR.ADR.CNT GT 0 THEN
                    FOR CAR.ADR = 1 TO CAR.ADR.CNT
                        LOCATE EFFECTIVE.DATE IN RET.EFFECTIVE.DATE<1,1> SETTING DATE.POS THEN
                            LOCATE ACTIVITY.REF IN RET.ACTIVITY.REF<1,1> SETTING ACT.REF.POS THEN
                                RETURN.ARRAY<-1> = '###':DELIVERY.REF:'*':CARRIER.ADRESS<1,CAR.ADR>
                            END ELSE
                                RETURN.ARRAY<-1> = '#':ACTIVITY:'#':ACTIVITY.REF:'#':DELIVERY.REF:'*':CARRIER.ADRESS<1,CAR.ADR>
                                RET.ACTIVITY.REF<1,-1> = ACTIVITY.REF
                            END
                        END ELSE
                            RETURN.ARRAY<-1> = EFFECTIVE.DATE:'#':ACTIVITY:'#':ACTIVITY.REF:'#':DELIVERY.REF:'*':CARRIER.ADRESS<1,CAR.ADR>
                            RET.EFFECTIVE.DATE<1,-1> = EFFECTIVE.DATE
                            RET.ACTIVITY.REF<1,-1> = ACTIVITY.REF
                        END
                    NEXT CAR.ADR
                END ELSE
                    LOCATE EFFECTIVE.DATE IN RET.EFFECTIVE.DATE<1,1> SETTING DATE.POS THEN
                        LOCATE ACTIVITY.REF IN RET.ACTIVITY.REF<1,1> SETTING ACT.REF.POS THEN
                            RETURN.ARRAY<-1> = '###':DELIVERY.REF
                        END ELSE
                            RETURN.ARRAY<-1> = '#':ACTIVITY:'#':ACTIVITY.REF:'#':DELIVERY.REF
                            RET.ACTIVITY.REF<1,-1> = ACTIVITY.REF
                        END
                    END ELSE
                        RETURN.ARRAY<-1> = EFFECTIVE.DATE:'#':ACTIVITY:'#':ACTIVITY.REF:'#':DELIVERY.REF
                        RET.EFFECTIVE.DATE<1,-1> = EFFECTIVE.DATE
                        RET.ACTIVITY.REF<1,-1> = ACTIVITY.REF
                    END
                END
            END
        END
    REPEAT

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CHECK.MULTIPE.CARRIER>
*** <desc>Check if multiple carrier address is present for single delivery reference </desc>
CHECK.MULTIPE.CARRIER:
    
    MULTIPE.CARRIER = 0 ;* Initialise Multiple Carrier Flag
* If carrier adress is more than 1, then there are multiple carriers for single delivery reference
    IF CAR.ADR>1 THEN
        MULTIPE.CARRIER = 1 ;* Set Multiple Carrier Flag
        SAVE.EFFECTIVE.DATE = EFFECTIVE.DATE ;* Save Effective Date
        SAVE.ACTIVITY = ACTIVITY ;* Save Activity
* IF multiple carriers are present for single delivery reference for ativity and Effective date - append as Null in next array
        EFFECTIVE.DATE = ""
        ACTIVITY = ""
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= RESTORE.ACTIVITY>
*** <desc>Restore Activity and Effective date values  after appending Return Array </desc>
RESTORE.ACTIVITY:
    
* Restore Activity and Effective date values from saved effective date and saved activity values.
    IF MULTIPE.CARRIER THEN
        EFFECTIVE.DATE = SAVE.EFFECTIVE.DATE
        ACTIVITY = SAVE.ACTIVITY
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
