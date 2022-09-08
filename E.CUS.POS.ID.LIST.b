* @ValidationCode : MjotNzMxMzA4NzIyOkNwMTI1MjoxNDkxNDYzODMyNDc5Om1hbmlzZWthcmFua2FyOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDIuMDozOjM=
* @ValidationInfo : Timestamp         : 06 Apr 2017 13:00:32
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : manisekarankar
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 3/3 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-15</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.ModelBank

    SUBROUTINE E.CUS.POS.ID.LIST(Y.ID.LIST)
*
*
*-------------------------------------------------------------------------
* This routine is called by Standard Selection CUSTOMER.POSITION
* to retrun the list of customer numbers held in C$CUST.POS.ENQ.IDS
*
*
* Modification Details
* ====================
*
* 28/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*
* 29/12/16 - Defect 1969454 / Task 1969456
*			 Delivering the private changes
*
* 29/12/16 - Defect 1969454 / Task 2079924
*            Making the routine public
*
*------------------------------------------------------------------------
*
    $USING ST.Customer

*
MAIN.PARA:
*--------

*
    Y.ID.LIST = ''
    Y.ID.LIST = ST.Customer.getCCustPosEnqIds()

    RETURN
*-----------------------------------------------------------------------------

    END
