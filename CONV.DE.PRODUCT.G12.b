* @ValidationCode : MjoxODYyMjA1NzQyOkNwMTI1MjoxNTgwMzY3ODk0NTI4OnN0YW51c2hyZWU6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMjAwMS4yMDE5MTIyNC0xOTM1Oi0xOi0x
* @ValidationInfo : Timestamp         : 30 Jan 2020 12:34:54
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : stanushree
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202001.20191224-1935
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 1 15/05/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
$PACKAGE PF.Config
SUBROUTINE CONV.DE.PRODUCT.G12(YID,YREC,YFILE)

* 30-03-01 - GB0100933
*            Conversion program for DE.PRODUCT.
*
* 28/01/2020 - Enhancement 3384559 / Task 3559139
*              Changes done for Movement of contact preferences to a separate Master Data Module from Delivery
*
    $INSERT I_COMMON
    $INSERT I_EQUATE

    YREC<7> = ''
    YREC<8> = ''
    YREC<9> = ''
    YREC<10> = ''
    YREC<11> = ''
    YREC<12> = ''
    YREC<13> = ''

RETURN
END
