* @ValidationCode : MjotMTI2MTI4NzY3MTpDcDEyNTI6MTU4MTA3NjkwMzIxMTpic2F1cmF2a3VtYXI6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMi4yMDIwMDExNy0yMDI2OjI0OjE2
* @ValidationInfo : Timestamp         : 07 Feb 2020 17:31:43
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bsauravkumar
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 16/24 (66.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE LI.ModelBank

SUBROUTINE LIMIT.FIND.LIAB
*-------------------------------------------------
*
* This subroutine will be used to decode the Liability no of the LIMIT
* It is used in the standard enquiry system
* and therefore all the parameters required are
* passed in I_ENQUIRY.COMMON
*
* The fields used are as follows:-
*
* INPUT   ID              Id of the LIMIT record
*                         being processed.
*
*         R.RECORD        LIMIT record.
*
*         VC              Pointer to the current
*                         multi-value set being
*                         processed.
*
*         S               Pointer to the current
*                         sub-value set being
*                         processed.
*
*         O.DATA          Full limit reference key
*
*
* OUTPUT  O.DATA          Shortened limit reference key
*
*---------------------------------------------------------
* Modification History :
*
* 06/11/17 - EN 2232234 / Task 2232237
*            Creation of this routine
*
* 22/04/18 - Enhancement 2448622 / Task 2560419
*            RELATIONSHIP.CUST.GROUP can have both Risk and Non-Risk groups.
*            Changes done to fetch only the risk group.
*
* 07/02/20 - Enhancement 3498204 / Task 3498206
*            Support for new limits for FX
*-----------------------------------------------------------------------------
    $USING EB.Reports
    $USING LI.Config
    $USING ST.Customer
*
    LIMIT.ID = EB.Reports.getId()
    LIMIT.ID.COMPONENTS = ''
    LIMIT.ID.COMPOSED = ''
    CUST.GROUP.ID = ''
    R.CUST.GROUP = ''
    IF LIMIT.ID[1,2]= "LI" AND FIELD(LIMIT.ID,'.',2) THEN   ;* For LIMIT.DAILY.OS id will be LI19093WL64R....20091222. So make sure use FIELD and check customer
        LIMIT.LIAB = FIELD(LIMIT.ID,'.',2)
    END ELSE
        LI.Config.LimitIdProcess(LIMIT.ID, LIMIT.ID.COMPONENTS, LIMIT.ID.COMPOSED, '', '')
        
        IF INDEX(LIMIT.ID.COMPONENTS<6>,"*",1) THEN ;* if we have multiple customer limit / joint limit return liab as group id
            LIMIT.LIAB = LIMIT.ID.COMPONENTS<1>
            R.CUST.GROUP = ST.Customer.RelationshipCustGroup.Read(LIMIT.ID.COMPONENTS<1>, Error)
            LOCATE 'RISK' IN R.CUST.GROUP<ST.Customer.RelationshipCustGroup.RcgSystemUse,1> SETTING RISK.GRP.POS THEN
                CUST.GROUP.ID = R.CUST.GROUP<ST.Customer.RelationshipCustGroup.RcgCustomerGroup,RISK.GRP.POS>   ;* Get the Risk group id
            END
            IF CUST.GROUP.ID THEN
                LIMIT.LIAB = CUST.GROUP.ID ;* Risk Group id
            END
        END ELSE
            LIMIT.LIAB = LIMIT.ID.COMPONENTS<1>
        END
    END
    EB.Reports.setOData(LIMIT.LIAB)
RETURN
*-----------------------------------------------------------------------------
END
