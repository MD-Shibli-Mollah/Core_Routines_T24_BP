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
* <Rating>-6</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.ModelBank

    SUBROUTINE E.CONV.IB.CHECK

*-----------------------------------------------------------------------------
* PURPOSE     : Routine to check whether the Internet Banking exist for the customer
* AUTHOR      : Abinanthan K B
* CREATED ON  : 11/02/2011
*
*------------------------------------------------------------------------------
* Modification History:
* ---------------------
*
* 23/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*------------------------------------------------------------------------------
    $INSERT I_DAS.EB.EXTERNAL.USER

    $USING EB.Reports
    $USING EB.DataAccess

    TABLE.NAME   = "EB.EXTERNAL.USER"
    TABLE.SUFFIX = ""
    DAS.LIST     = DAS.EXT$CUSTOMER
    ARGUMENTS = EB.Reports.getOData()

    EB.DataAccess.Das(TABLE.NAME, DAS.LIST, ARGUMENTS, TABLE.SUFFIX)

    IF DAS.LIST NE "" THEN
        EB.Reports.setOData(1)
    END ELSE
        EB.Reports.setOData('')
    END

    RETURN
*-----------------------------------------------------------------------------

    END
