* @ValidationCode : MjoxMTMxNzYzOTU4OkNwMTI1MjoxNDg3MDczNjIxNjcwOnJzdWRoYTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 14 Feb 2017 17:30:21
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rsudha
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE AO.Framework
    SUBROUTINE AA.ONLINE.SERVICES.CHECK.PRODUCT(VALID.PRODUCT)
*------------------------------------------------------------------------------------------
* This routine checks the availability of ONLINE.SERVICES Product Line in the Company
*-----------------------------------------------------------------------------
* Modification History:
*
* 03/10/16 - Enhancement 1812222 / Task 1905849
*            Tc Permissions property class
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING ST.CompanyCreation
    $USING AO.Framework
*-------------------------------------------------------------------------------------------
* Product code for ONLINE.SERVICES is AI
    PRODUCT.CODE  = 'AO'
    LOCATE PRODUCT.CODE IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING CODE.POS THEN
    VALID.PRODUCT = 1 ;* Yes! Valid product.
    END ELSE
    VALID.PRODUCT = '' ;* No! Not a valid product.
    END
*
    RETURN
*-----------------------------------------------------------------------------
    END
