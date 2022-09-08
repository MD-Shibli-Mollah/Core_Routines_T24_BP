* @ValidationCode : MjoxNDgzNTM2NDUwOkNwMTI1MjoxNjA4MDQ0NzY4NzMzOnN1ZGhhbms6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDExLjIwMjAxMDI5LTE3NTQ6LTE6LTE=
* @ValidationInfo : Timestamp         : 15 Dec 2020 20:36:08
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sudhank
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-141</Rating>
*-----------------------------------------------------------------------------
$PACKAGE ST.RateParameters
SUBROUTINE SETTLEMENT.RATES.FIELD.DEFINITIONS
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 14/09/10 - Task 76280
*            Change the reads to Customer to use the Customer
*            Service api calls
*
* 04/05/2017 - Enhancement-1765879/Task-2113898 - sathiyavendan@temenos.com
*              Remove dependency of code in ST products
*
* 25/06/20 - Enhancement 3916482 / Task 4036976
*            Removing fields for checkfile for MDAL api
*-----------------------------------------------------------------------------

    $USING EB.SystemTables

*
* 10/01/02 - BG_100000346
*            Increase of ID length from 12 to 35
*
*-----------------------------------------------------------------------------
    GOSUB INITIALISE
    GOSUB DEFINE.FIELDS
RETURN
*
*-----------------------------------------------------------------------------
*
DEFINE.FIELDS:

    ID.F = "CONTRACT.NO" ; ID.N = "35" ; ID.T = "A"        ; * BG_100000346

    EB.SystemTables.SetIdProperties(ID.F,ID.N,ID.T,ID.CONCATFILE,ID.CHECKFILE)
*
    Z=0
*
    Z+=1 ; F(Z) = "CONTRACT.CCY" ; N(Z) = "3.1.C" ; T(Z) = "CCY" ; T(Z)<3> = "NOCHANGE"
    CHECKFILE(Z) = CHK.CURRENCY
    Z+=1 ; F(Z) = "SETTLEMENT.MARKET" ; N(Z) = "2.1.C" ; T(Z) = "DEF" ; T(Z)<3> = 'NOINPUT'
    CHECKFILE(Z)=CHK.MARKET
    Z += 1 ; F(Z) = 'CONVERSION.TYPE' ; N(Z) = '4.1' ; T(Z) = "" ; T(Z)<2> = "BUY_MID_SELL" ; T(Z)<3> = 'NOINPUT'
    Z += 1 ; F(Z) = 'PROTECTION.CLAUSE' ; N(Z) = '3.1' ; T(Z) = "" ; T(Z)<2> = "YES_NO"
    Z += 1 ; F(Z) = 'XX<EVENT.DATE' ; N(Z) = '11..C' ; T(Z) = "D" ; T(Z)<3> = "NOCHANGE" ; T(Z)<8> = "NOMODIFY"
    Z+=1 ; F(Z) = 'XX-XX<EVENT.CCY' ; N(Z) = "3..C" ; T(Z) = "CCY":@FM:@FM:"NOINPUT"
    Z += 1 ; F(Z) = 'XX-XX-EV.SYS.RATE' ; N(Z) = '16' ; T(Z) = "R" ; T(Z)<3> = "NOCHANGE"
    Z += 1 ; F(Z) = 'XX-XX-EV.APPL.RATE' ; N(Z) = '16..C' ; T(Z) = "R"
    Z += 1 ; F(Z) = "XX-XX-RESERVED.2" ; N(Z) = '12' ; T(Z) = 'A':@FM:@FM:"NOINPUT"
    Z += 1 ; F(Z) = "XX>XX>RESERVED.1" ; N(Z) = "12" ; T(Z) = "A":@FM:@FM:"NOINPUT"
    Z+=1 ; F(Z) = 'XX<AMOUNT.TYPE' ; N(Z) = '2' ; T(Z)<3> = 'NOCHANGE'
    Z += 1 ; F(Z) = 'XX-EXCG.RATE' ; N(Z) = "16" ; T(Z) = "R" ; T(Z)<3> = 'NOCHANGE'
    Z += 1 ; F(Z) = 'XX>ACCOUNT' ; N(Z) = '16' ; T(Z)<3> = 'NOCHANGE'
    Z += 1 ; F(Z) = "RESERVED5" ; N(Z) = "12" ; T(Z) = "A":@FM:@FM:"NOINPUT"
    Z += 1 ; F(Z) = "RESERVED4" ; N(Z) = "12" ; T(Z) = "A":@FM:@FM:"NOINPUT"
    Z += 1 ; F(Z) = "RESERVED3" ; N(Z) = "12" ; T(Z) = "A":@FM:@FM:"NOINPUT"
    Z += 1 ; F(Z) = "RESERVED2" ; N(Z) = "12" ; T(Z) = "A":@FM:@FM:"NOINPUT"
    Z += 1 ; F(Z) = "RESERVED1" ; N(Z) = "12" ; T(Z) = "A":@FM:@FM:"NOINPUT"
*
    V = Z + 9

    EB.SystemTables.SetFieldProperties(MAT F, MAT N, MAT T,MAT CONCATFILE,MAT CHECKFILE, V)

RETURN
*
*-----------------------------------------------------------------------------
*
INITIALISE:

    DIM F(EB.SystemTables.SysDim)
    DIM N(EB.SystemTables.SysDim)
    DIM T(EB.SystemTables.SysDim)
    DIM CHECKFILE(EB.SystemTables.SysDim)
    DIM CONCATFILE(EB.SystemTables.SysDim)

    MAT F = "" ; MAT N = "" ; MAT T = ""
    MAT CHECKFILE = "" ; MAT CONCATFILE = ""
    ID.CHECKFILE = "" ; ID.CONCATFILE = ""
*
* Define often used checkfile variables
*
    CHK.CURRENCY = "CURRENCY":@FM:'':@FM:'.A'
    CHK.MARKET= "CURRENCY.MARKET":@FM:'':@FM:'L.A'

RETURN
*
*-----------------------------------------------------------------------------
*
END
