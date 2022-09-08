* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-29</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.CUSTOMER.RELATION.LIST(OUT.ARRAY)
*-----------------------------------------------------------------------------
* Modification History
* 13/01/14 - 886471
*            Enquiry routine to list Relation Customer Enquiry
*
* 09/01/15 - Defect - 1216853 / Task - 1220990
*            Use of keyword $INCLUDE replaced with $INSERT.
*
* 29/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*------------------------------------------------------------------------------
    $USING EB.Reports
    $USING ST.Customer
***
*Main Program
***

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN

*-----------------------------------------------------------------------------------
*</Region>
* Intialise all the neccessary variables
*<Region/>
*------------------------------------------------------------------------------------
INITIALISE:
*----------

    LOCATE 'CUSTOMER' IN EB.Reports.getDFields()<1> SETTING CUST.POS THEN
    CUSTOMER.ID = EB.Reports.getDRangeAndValue()<CUST.POS>
    END ELSE
    OUT.ARRAY = ''
    RETURN
    END

    R.CUSTOMER.REC = ''
    E.CUSTOMER = ''
    R.RELATION.CUSTOMER = ''
    E.RELATION.CUSTOMER = ''

    RETURN

*-----------------------------------------------------------------------------------
*</Region>
* Get the neccessary Values and send it to out array
*<Region/>
*------------------------------------------------------------------------------------
PROCESS:
*-------

    R.CUSTOMER.REC  = ST.Customer.tableCustomer(CUSTOMER.ID, E.CUSTOMER)
    R.RELATION.CUSTOMER = ST.Customer.tableRelationCustomer(CUSTOMER.ID, E.RELATION.CUSTOMER)

    IS.RELATION = R.RELATION.CUSTOMER<ST.Customer.RelationCustomer.EbRcuIsRelation>
    IS.CUSTOMER = R.RELATION.CUSTOMER<ST.Customer.RelationCustomer.EbRcuOfCustomer>
    IS.DEL.REF = R.CUSTOMER.REC<ST.Customer.Customer.EbCusRelDelivOpt>
    IS.ROLE = R.CUSTOMER.REC<ST.Customer.Customer.EbCusRole>
    IS.ROLE.INFO = R.CUSTOMER.REC<ST.Customer.Customer.EbCusRoleMoreInfo>
    IS.NOTES = R.CUSTOMER.REC<ST.Customer.Customer.EbCusRoleNotes>

    IS.INT = 1
    IS.CNT = DCOUNT(IS.RELATION,@VM)
    LOOP
    WHILE IS.INT LE IS.CNT

        IS.REL = IS.RELATION<1,IS.INT>
        IS.CUS = IS.CUSTOMER<1,IS.INT>
        IS.DEL = IS.DEL.REF<1,IS.INT>
        IS.RL = IS.ROLE<1,IS.INT>
        IS.RL.IN = IS.ROLE.INFO<1,IS.INT>
        IS.NT = IS.NOTES<1,IS.INT>
        OUT.ARRAY<-1> = IS.REL:'*':IS.CUS:'*':IS.DEL:'*':IS.RL:'*':IS.RL.IN:'*':IS.NT:'*':CUSTOMER.ID
        IS.INT++

    REPEAT


    RETURN
*-----------------------------------------------------------------------------

    END
