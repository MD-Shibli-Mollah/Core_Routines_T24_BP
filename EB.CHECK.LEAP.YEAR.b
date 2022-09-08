* @ValidationCode : MjoxNjkyNTEyODE2OkNwMTI1MjoxNTMxNzM5MzAzMDU4OnJhdmluYXNoOjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MDcuMjAxODA2MjEtMDIyMToxMzoxMw==
* @ValidationInfo : Timestamp         : 16 Jul 2018 16:38:23
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ravinash
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 13/13 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201807.20180621-0221
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE EB.API
SUBROUTINE EB.CHECK.LEAP.YEAR(inDate, isLeapYear)
*-----------------------------------------------------------------------------
*
* DESCRIPTION -  Routine to check if the given date is a leap year or not.
* IN PARAMETER - inDate(YYYYMMDD format)
* OUT PARAMETER - isLeapYear which checks if the InDate is a leap year or not
*               - Returns 1 if leap year
*               - Returns 0 if not a leap year
*-----------------------------------------------------------------------------
* Modification History :
*
* 21/06/18 - Task 2643289 / Defect 2641187
*            Routine to check if the given date is a leap year or not.
*-----------------------------------------------------------------------------

    isLeapYear = 0 ;* Default case which is not a leap year.
   
    IF MOD(inDate[1,4],400) EQ 0  THEN  ;* If the year is a multiple of 400 (example : 2000)
        isLeapYear = 1  ;* Set to 1 as it is a leap year.
        RETURN
    END
     
    IF MOD(inDate[1,4],100) EQ 0 THEN  ;* If the year is a multiple of 100 (example : 1900)
        RETURN  ;* Will return as it is not a leap year
    END
        
    IF MOD(inDate[1,4],4) EQ 0 THEN ;* If the year is a multiple of 4 but not 100 and 400 (example: 2016)
        isLeapYear = 1 ;* Set to 1 as it is a leap year.
        RETURN
    END
    
RETURN
    
END
