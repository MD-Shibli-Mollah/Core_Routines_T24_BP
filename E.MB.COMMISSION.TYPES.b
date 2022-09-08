* @ValidationCode : MjoxMTgxNTkzOTUyOkNwMTI1MjoxNTgzOTIzMjYyMjM2OnJ2YXJhZGhhcmFqYW46LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAzLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 11 Mar 2020 16:11:02
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rvaradharajan
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-39</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.MB.COMMISSION.TYPES(RET.ARR)
*------------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------------
* DESCRIPTIION : This routine is attached to a NOFILE enquiry COMMISSION.TYPES.
* ------------
* This enquiry displays the FT.COMMISSION.TYPE & FT.CHARGE.TYPE records in the system
*
*------------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------------
* MODIFICATION HISTORY :
* --------------------
*
* VERSION : 1.0                DATE: 27 JUL 2009                 CD  : EN_10004268
*                                                                SAR : SAR-2009-01-14-0003
*
* 30/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 30/10/18 - Enhancement 2822520 / Task 2833705
*            Code changed done for componentisation and to avoid errors while compilation
*            using strict compile
*
* 30/01/20 - Enhancement 3265496  / Task 3382394
*            Changing reference of routines that have been moved from ST to CG*------------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------------

    $USING EB.Reports
    $USING CG.ChargeConfig
    $USING EB.DataAccess
    
    GOSUB INITIALISE

RETURN

*---------
INITIALISE:
*---------

    LOCATE "COMMISSION.TYPE" IN EB.Reports.getDFields() SETTING COMM.TYPE.POS THEN

        COMM.TYPE = EB.Reports.getDRangeAndValue()<COMM.TYPE.POS>

    END

    IF COMM.TYPE NE '' THEN

        GOSUB READ.COMMISSION.RECORD

    END ELSE

        GOSUB SELECT.COMMISSION.RECORDS

    END

RETURN


*---------------------
READ.COMMISSION.RECORD:
*---------------------

    R.COMMISSION.TYPE = CG.ChargeConfig.tableFtCommissionType(COMM.TYPE, ERR.COMMISSION.TYPE)

    IF NOT(ERR.COMMISSION.TYPE) THEN
        FT.COMM.DESC = R.COMMISSION.TYPE<CG.ChargeConfig.FtCommissionType.FtFouDescription>
        RET.ARR<-1> = COMM.TYPE:"*":FT.COMM.DESC:"*":"FT.COMMISSION.TYPE"
    END ELSE
        R.CHARGE.TYPE = CG.ChargeConfig.tableFtChargeType(COMM.TYPE, ERR.CHARGE.TYPE)

        IF NOT(ERR.CHARGE.TYPE) THEN
            FT.CHARGE.DESC = R.CHARGE.TYPE<CG.ChargeConfig.FtChargeType.FtFivDescription>
            RET.ARR<-1> = COMM.TYPE:"*":FT.CHARGE.DESC:"*":"FT.CHARGE.TYPE"
        END
    END

RETURN

*------------------------
SELECT.COMMISSION.RECORDS:
*------------------------

    TABLE.NAME    =  'FT.COMMISSION.TYPE'
    TABLE.SUFFIX  =  ''
    DAS.LIST      =  EB.DataAccess.DasAllIds
    ARGUMENTS     =  ''

    EB.DataAccess.Das(TABLE.NAME, DAS.LIST, ARGUMENTS, TABLE.SUFFIX)

    LOOP

        REMOVE FT.COMM.ID FROM DAS.LIST SETTING FT.COMM.ID.POS

    WHILE FT.COMM.ID:FT.COMM.ID.POS
        R.COMMISSION.TYPE = CG.ChargeConfig.tableFtCommissionType(FT.COMM.ID, ERR.COMMISSION.TYPE)

        FT.COMM.DESC = R.COMMISSION.TYPE<CG.ChargeConfig.FtCommissionType.FtFouDescription>

        RET.ARR<-1> = FT.COMM.ID:"*":FT.COMM.DESC:"*":"FT.COMMISSION.TYPE"

    REPEAT


    FCT.TABLE.NAME    = "FT.CHARGE.TYPE"
    FCT.TABLE.SUFFIX  = ''
    FCT.DAS.LIST      = EB.DataAccess.DasAllIds
    FCT.ARGUMENTS      = ''

    EB.DataAccess.Das(FCT.TABLE.NAME, FCT.DAS.LIST, FCT.ARGUMENTS, FCT.TABLE.SUFFIX)

    LOOP

        REMOVE FT.CHRG.ID FROM FCT.DAS.LIST SETTING FT.CHRG.ID.POS

    WHILE FT.CHRG.ID:FT.CHRG.ID.POS
        R.CHARGE.TYPE = CG.ChargeConfig.tableFtChargeType(FT.CHRG.ID, ERR.CHARGE.TYPE)

        FT.CHARGE.DESC = R.CHARGE.TYPE<CG.ChargeConfig.FtChargeType.FtFivDescription>

        RET.ARR<-1> = FT.CHRG.ID:"*":FT.CHARGE.DESC:"*":"FT.CHARGE.TYPE"

    REPEAT

RETURN
*-----------------------------------------------------------------------------
END
