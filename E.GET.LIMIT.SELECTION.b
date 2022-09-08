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

* Version n dd/mm/yy  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>-15</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LI.ModelBank

    SUBROUTINE E.GET.LIMIT.SELECTION(ENQ)
************************************************************
* MODIFICATION.LOG:
*******************
* 04/07/03 - BG_100004722
*		Choice of Multiple limit references.
*
* This build routine will give the list of product references
* available for a particular customer for a particular product.
* This allows the user to choose the limit reference of his choice
* instead of defaulting the first limit reference specified in the
* LIMIT.PARAMETER file.
* This has to attached to a Version of an Application.
*
* 18/10/10 - Task - 84420
*            Replace the enterprise(customer service api)code into  Banking framework related
*            routines which reads CUSTOMER.
***********************************************************
*
*** <region name= Components>
*** <desc> </desc>
    $INSERT I_CustomerService_Parent

    $USING LD.Contract
    $USING EB.SystemTables

*** </region>

*
    CUSTOMER = EB.SystemTables.getRNew(LD.Contract.LoansAndDeposits.CustomerId)
*
* Filter Product References for a particular product.
*
    ENQ<2,-1> = "REF.SEQ.NO"
    ENQ<3,-1> = "EQ"
    VALID.LIMIT.REFS = ''
    IF EB.SystemTables.getT(LD.Contract.LoansAndDeposits.LimitReference)<2> THEN
        VALID.LIMIT.REFS = EB.SystemTables.getT(LD.Contract.LoansAndDeposits.LimitReference)<2>
        ENQ<4,-1> = VALID.LIMIT.REFS
        CONVERT '_' TO ' ' IN ENQ<4,1>
    END
*
* Filter by liablility no.
*
    LIABILITY.NO = ''
    custId = CUSTOMER
    custParent = ''
    CALL CustomerService.getParent(custId, custParent)
    LIABILITY.NO = custParent<Parent.customerLiability>
    IF LIABILITY.NO ELSE
        LIABILITY.NO = CUSTOMER
        CUSTOMER = ''
    END
    ENQ<2,-1> = "LIAB.NO"
    ENQ<3,-1> = "EQ"
    ENQ<4,-1> = LIABILITY.NO
*
    RETURN
*
**************************************************************
*
    END
