* @ValidationCode : MjotMjk4MTY4NzgzOmNwMTI1MjoxNjA3NDI3NTc4OTcyOmtyYW1hc2hyaTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTAuMjAyMDA5MjktMTIxMDotMTotMQ==
* @ValidationInfo : Timestamp         : 08 Dec 2020 17:09:38
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : kramashri
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200929-1210
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE RT.BalanceAggregation
SUBROUTINE RT.GET.HOLD.MAIL.INDICIA(CUSTOMER.ID, REGULATION, RES.IN.1, RES.IN.2, INDICIA, RES.OUT.1, RES.OUT.2, RES.OUT.3)
*-----------------------------------------------------------------------------
* Sample API to calculate hold mail indicia for a customer
* Arguments:
*------------
* CUSTOMER.ID                (IN)    - Customer ID for which indicia is to be calculated
*
* REGULATION                 (IN)    - CRS/FATCA, for which regulation indicia is to be checked
*
* RES.IN1, RES.IN2           (IN)    - Incoming Reserved Arguments
*
* INDICIA                    (OUT)   - Jurisdiction if indicia is met
*
* RES.OUT1,RES.OUT2,RES.OUT3 (OUT)   - Outgoing Reserved Arguments
*-----------------------------------------------------------------------------
* Modification History :
*
* 14/09/2020    - Enhancement 3972430 / Task 3972443
*				  Sample API to calculate hold mail indicia for a customer
*
* 02/11/2020 	- Enhancement 3436134 / Task 4059536
*            	  Considering fiscal jurisdiction for indicia calculation
*-----------------------------------------------------------------------------
    $USING RT.BalanceAggregation
    $USING EB.SystemTables
*-----------------------------------------------------------------------------
   
    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
*-----------------------------------------------------------------------------
INITIALISE:
    
* Check if hold mail indicia is to be calculated for CRS or FATCA
    CRS.HOLD.MAIL = ''
    FATCA.HOLD.MAIL = ''
    
    BEGIN CASE
        CASE REGULATION EQ 'CRS'
            CRS.HOLD.MAIL = 1
        CASE REGULATION EQ 'FATCA'
            FATCA.HOLD.MAIL = 1
    END CASE
    
    INDICIA = ''    ;* reset the argument
    R.TRIGGER = ''
    TRIG.ER = ''

RETURN
*-----------------------------------------------------------------------------
PROCESS:
    
* Return if both are null
    IF NOT(CRS.HOLD.MAIL) AND NOT(FATCA.HOLD.MAIL) THEN
        RETURN
    END

* Call the API to get hold mail status
    HOLD.DETS = ''
    RT.BalanceAggregation.StGetHoldMailIndicia(CUSTOMER.ID, '', HOLD.DETS, '', CRS.HOLD.MAIL, FATCA.HOLD.MAIL, '', '')
    
    HOLD.END.DATE = HOLD.DETS<3>
    FUTURE.DATED.HOLDMAIL = HOLD.DETS<5>

* Write trigger only when CRS/FATCA indicia is met or hold end date is future dated
    IF CRS.HOLD.MAIL OR FATCA.HOLD.MAIL OR FUTURE.DATED.HOLDMAIL THEN           ;* check for *HOLD trigger
        TRIG.ID = CUSTOMER.ID:'*HOLD'
        R.TRIGGER = RT.BalanceAggregation.StIndiciaTrigger.CacheRead(TRIG.ID, TRIG.ER)
        
        IF TRIG.ER OR (HOLD.END.DATE NE R.TRIGGER<1>) THEN     ;* write when trigger rec not available or when there is a change in hold end date
            R.TRIGGER<1> = HOLD.END.DATE
            RT.BalanceAggregation.StIndiciaTrigger.Write(TRIG.ID, R.TRIGGER)
        END
    END
    
* Append the respective jurisdiction in the output
    IF CRS.HOLD.MAIL THEN
        INDICIA = CRS.HOLD.MAIL<2>
    END
    IF FATCA.HOLD.MAIL THEN
        INDICIA = FATCA.HOLD.MAIL<2>
    END

RETURN
*-----------------------------------------------------------------------------
END

