* @ValidationCode : MTotMzYyMDA4MTg4OkNwMTI1MjoxNDc0ODg3OTUyNjI1OnNyZWVqYWd1bmRhbGE6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTYxMC4w
* @ValidationInfo : Timestamp         : 26 Sep 2016 16:35:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sreejagundala
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201610.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
    $PACKAGE SC.SccEventNotification
    SUBROUTINE CONV.SC.PRE.DIARY.201610(ID,RECORD,FILENAME)
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/09/16 - Enhancements-1775056 & 1781054/Task-1856996
*            1775056 - Corporate actions functionality - Capital Increase - Managing oversubscription of rights (FP 23162)
*            1781054 - Dividends with currency election (FP 23161)
*            Conversion in SC.PRE.DIARY to move OPTION.DESC & CASH.CCY to 8,9 positions.
*
* 26/09/16 - Task-1867495
*            RETURN is added
*-----------------------------------------------------------------------------

*After Conversion values - old positions
    EQU OLD.SC.PRD.OPTION.DESC TO 51
    EQU OLD.SC.PRD.CASH.CCY TO 52
*After Conversion values - new positions
    EQU NEW.SC.PRD.OPTION.DESC TO 8
    EQU NEW.SC.PRD.CASH.CCY TO 9

*Move fields OPTION.DESC and CASH.CCY to position 8 and 11
    RECORD<NEW.SC.PRD.OPTION.DESC> = RECORD<OLD.SC.PRD.OPTION.DESC>
    RECORD<NEW.SC.PRD.CASH.CCY> = RECORD<OLD.SC.PRD.CASH.CCY>

*old positions as reserved field therby setting it as null.
    RECORD<OLD.SC.PRD.OPTION.DESC> = ''
    RECORD<OLD.SC.PRD.CASH.CCY> = ''
    RETURN
    END
