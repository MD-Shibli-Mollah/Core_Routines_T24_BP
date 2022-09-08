* @ValidationCode : MjotMTM0NzgzNzE4MTpjcDEyNTI6MTYwNzQyNzU3OTAyNzprcmFtYXNocmk6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEwLjIwMjAwOTI5LTEyMTA6LTE6LTE=
* @ValidationInfo : Timestamp         : 08 Dec 2020 17:09:39
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
SUBROUTINE RT.GET.POA.INDICIA(CUSTOMER.ID, REGULATION, INDICIA.CALC, RES.IN.2, INDICIA, RES.OUT.1, RES.OUT.2, RES.OUT.3)
*-----------------------------------------------------------------------------
* Sample API to check POA indicia for a customer
* Arguments:
*------------
* CUSTOMER.ID                (IN)    - Customer ID for which indicia is to be calculated
*
* REGULATION                 (IN)    - CRS/FATCA, for which regulation indicia is to be checked
*
* INDICIA.CALC               (IN)    - AA, in order to calculate POA indicia using Arrangement activity dets
*                                      CU, in order to calculate POA indicia using Customer dets
*                                      BOTH, in order to calculate POA indicia using both AA and Customer dets
*
* RES.IN2                    (IN)    - Incoming Reserved Argument
*
* INDICIA                    (OUT)   - Jurisdiction if indicia is met
*
* RES.OUT1,RES.OUT2,RES.OUT3 (OUT)   - Outgoing Reserved Arguments
*-----------------------------------------------------------------------------
* Modification History :
*
* 14/09/2020    - Enhancement 3972430 / Task 3972443
*			      Sample API to check POA indicia for a customer
*
* 02/11/2020	- Enhancement 3436134 / Task 4059536
*            	  Considering fiscal jurisdiction for indicia calculation
*-----------------------------------------------------------------------------
    $USING RT.BalanceAggregation
    $USING EB.Service
*-----------------------------------------------------------------------------
    
    IF INDICIA.CALC NE 'CU' AND INDICIA.CALC NE 'AA' AND INDICIA.CALC NE 'BOTH' THEN
    	INDICIA = ''
        RETURN
    END
    
    GOSUB INITIALISE
    GOSUB PROCESS
    
RETURN
*-----------------------------------------------------------------------------
INITIALISE:
    
* Check if indicia is to be calculated for CRS or FATCA
    CRS.CHECK = ''
    FATCA.CHECK = ''
    
    BEGIN CASE
        CASE REGULATION EQ 'CRS'
            CRS.CHECK = INDICIA.CALC
        CASE REGULATION EQ 'FATCA'
            FATCA.CHECK = INDICIA.CALC
    END CASE
    
    INDICIA = ''    ;* reset the argument
    CRS.JUR = ''
    FATCA.JUR = ''
    
RETURN
*-----------------------------------------------------------------------------
PROCESS:
    
* Return if both are null
    IF NOT(CRS.CHECK) AND NOT(FATCA.CHECK) THEN
        RETURN
    END

* Call the API to calculate POA indicia based on arrangement
    RT.BalanceAggregation.StGetPoaIndicia(CUSTOMER.ID, '', CRS.CHECK, CRS.JUR, FATCA.CHECK, FATCA.JUR, '')

* Append the jurisidictions met in the final output argument
    IF CRS.CHECK THEN
        INDICIA = LOWER(CRS.JUR)
    END
    IF FATCA.CHECK THEN
        INDICIA = LOWER(FATCA.JUR)
    END
    
RETURN
*-----------------------------------------------------------------------------
END


