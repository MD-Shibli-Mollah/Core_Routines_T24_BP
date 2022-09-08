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
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctSecurityLending
    SUBROUTINE CONV.SC.DEPOT.POSITION.R07.SELECT

*------------------------------------------------------
* SELECT routine for the conversion SC.DEPOT.POSITION
*------------------------------------------------------
* 01/12/06 - GLOBUS_CI_10045393
*            Conversion SC.DEPOT.POSITION written as service record
*
*------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_CONV.SC.DEPOT.POSITION.R07.COMMON

    LOCATE 'SC' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING PROD.FOUND ELSE
        RETURN
    END

    SEC.POS.ARRAY = '' ;  SEC.POS.LIST = ''

    SEC.POS.ARRAY<1> = ''
    SEC.POS.ARRAY<2> = 'F.SECURITY.POSITION'
    SEC.POS.ARRAY<3> = "@ID LIKE '...":'"-999"...':"' OR WITH @ID LIKE '...":'"-777"...':"'"

    CALL BATCH.BUILD.LIST(SEC.POS.ARRAY,SEC.POS.LIST)

    RETURN
END
