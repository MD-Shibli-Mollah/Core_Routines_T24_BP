* @ValidationCode : Mjo2NDczNTA5NTM6Q3AxMjUyOjE0OTM3MTQ0MDgwMTE6YXJjaGFuYXJhZ2hhdmk6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTcwMy4yMDE3MDMzMS0wODA5OjExOjEx
* @ValidationInfo : Timestamp         : 02 May 2017 14:10:08
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : archanaraghavi
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 11/11 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201703.20170331-0809
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-28</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PV.ModelBank
    SUBROUTINE CALCULATE.ODDAYS(OVERDUE.DAYS)
* API which returns the Number of overdue days for an account.
* This routine internally calls EB.GET.OVERDUE.DATE with the required arguments
*
* Incoming:
* ********
* OVERDUE.DAYS - Arrangement id
*
* Outgoing:
* ********
* OVERDUE.DAYS - No. of overdue days for the arrangement.
*
*-----------------------------------------------------------------------------
*Modification history:
* *******************
* 25/01/13 - Enhancement - 400039/ Task - 418843
*            New routine created.
*
* 26/04/17 - Enhancement 1765879 / Task 2101165
*            Changes related to the movement of EB.GET.OVERDUE.DATE
*            routine from ST_Config component to AC_Config component
*
*-----------------------------------------------------------------------------
    
    $USING PV.ModelBank
    $USING AC.Config
    
    GOSUB INITIALISE
    GOSUB COMPUTE.ODDAYS
    RETURN
*-----------------------------------------------------------------------------    
INITIALISE:
***********

    ACCOUNT.ID = OVERDUE.DAYS  ; * Account id passed as incoming arguemnt
    ARRANGEMENT.ID = ''
    FIRST.OVERDUE.DATE = ''
    OVERDUE.DAYS = ''
    RETURN.ERR = ''

    RETURN
*-----------------------------------------------------------------------------    
COMPUTE.ODDAYS:
**************
* Call the routine EB.GET.OVERDUE.DATE to calculate the number of overdue days

    AC.Config.EbGetOverdueDate(ACCOUNT.ID, ARRANGEMENT.ID, FIRST.OVERDUE.DATE, OVERDUE.DAYS, RETURN.ERR)

    RETURN
*-----------------------------------------------------------------------------
    
    END
