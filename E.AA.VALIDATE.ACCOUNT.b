* @ValidationCode : Mjo3MjgxNDk3NDk6Q3AxMjUyOjE2MDcxMDY2MDQxNTM6c3JkZWVwaWdhOjY6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDkuMDo0MDo0MA==
* @ValidationInfo : Timestamp         : 05 Dec 2020 00:00:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : srdeepiga
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 40/40 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-43</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.VALIDATE.ACCOUNT(RET.ERROR)

*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*
** The nofile routine returns the account closure validation errors
*
*-----------------------------------------------------------------------------
* @class AA.ModelBank
* @package retaillending.AA
* @stereotype Nofile Routine
* @author sivakumark@temenos.com
*-----------------------------------------------------------------------------

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Arguments>
*** <desc>Input and output arguments required for the sub-routine</desc>
* Arguments
*
* None
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Changes done in the sub-routine</desc>
* Modification History
*
* 03/09/15 - Task : 1496616
*            Ref : 1224661
*            Nofile routine for account closure validation
*
* 11/06/18 - Task : 2628538
*            Ref : 2593260
*            Routine Change for AC.CLOSURE.VALIDATE enquiry
*
* 04/12/2020 - Task : 4114207
*            Def : 4085525
*            Handle override msgs as OVERRIDE and error msgs as ERROR
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts

    $USING EB.Reports
    $USING AA.Reporting
    $USING AA.Payoff

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>

    GOSUB PROCESS.ACTION

RETURN
*** </region>
*-----------------------------------------------------------------------------
PROCESS.ACTION:

    LOCATE 'ARRANGEMENT.ID' IN EB.Reports.getEnqSelection()<2,1> SETTING ARRPOS THEN
        ARR.ID = EB.Reports.getEnqSelection()<4,ARRPOS>          ;* Pick the Arrangement Id
        IF ARR.ID[1,2] = "AA" ELSE
            ACCOUNT.ID = ARR.ID ;* Input is the account reference
        END
    END
    
    GOSUB ACCOUNT.VALIDATION

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= GET.INFO.BILL>
*** <desc>Read the info bill </desc>
ACCOUNT.VALIDATION:

    IF ARR.ID THEN
        AA.Reporting.ArrangementKeyValidate("GET",ACCOUNT.ID,ARR.ID,RETURN.ERROR)
    END
    
    IF ACCOUNT.ID THEN
        AA.Payoff.ValidateAccountClosure(ACCOUNT.ID,RET.ERROR)
    END

    ERROR.TO.RETURN = ""
    ERROR.CNT = DCOUNT(RET.ERROR,@VM)
    FOR ERR.CNT = 1 TO ERROR.CNT
        RETURN.ERROR = ""
        RETURN.ERROR = RET.ERROR<1,ERR.CNT>
        IF RETURN.ERROR[1,2] NE "E:" THEN
            GOSUB HANDLE.OVERRIDE                ;* format the override msg properly
            ERROR.TO.RETURN<1,-1> = RETURN.ERROR:" - ":"Override"  ;* add Override keyword for easy understanding
        END ELSE
            ERROR.TO.RETURN<1,-1> = RETURN.ERROR:" - ":"Error"  ;* add Error keyword for easy understanding
        END
    NEXT ERR.CNT

    RET.ERROR = ERROR.TO.RETURN
        
    CONVERT @VM TO @FM IN RET.ERROR
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= HANDLE.OVERRIDE>
*** <desc> Format the override msg </desc>

HANDLE.OVERRIDE:

    IF RETURN.ERROR THEN

* If override is coming from ACCOUNT.CLOSURE.OVERRIDE, the data is of the following format
* AC-ACCT.LINKED.LIMIT } Account 85235 linked to limit 8300.05 { 85235}8300.05
* The above will be formatted to Account 85235 linked to limit 8300.05 { 85235}8300.05
* Override from VALIDATE.ACCOUNT.CLOSURE , the data is of the below format
* ACL.FINAL.OPEN.ACCOUNT.FOR.CUSTOMER}FINAL OPEN ACCOUNT FOR A CUSTOMER
* The above will be formatted to FINAL OPEN ACCOUNT FOR A CUSTOMER
        
        FINDSTR '}' IN RETURN.ERROR SETTING O.POS THEN     ;* Use the flow only when the message is of the above format
            OVERRIDE.ID = FIELD(RETURN.ERROR,"}", 2,2)   ;* Store the Override ID
        END

        IF OVERRIDE.ID NE "" THEN
            RETURN.ERROR = OVERRIDE.ID
        END

    END

RETURN

***</region>
*------------------------------------------------------------------------------

END
