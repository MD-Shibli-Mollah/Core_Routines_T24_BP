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

* Version 1 06/06/06  GLOBUS Release No : R07 10/10/06
* <Rating>-48</Rating>
    $PACKAGE AC.ValueDatedProcess
    SUBROUTINE CONV.CEF.ENTRY(ENT.REC,SUSPENSE.CATEGORY)
*********************************************************************************
* This routine will raise Suspense entries during conversion of CONSOL.ENT.FWD Entries
*********************************************************************************
* Modification History:
*
* 10/10/06 - EN_10003043 /REF: SAR-2006-05-30-0001
*            New Routine
*
* 01/12/08 - CI_10059196
*            Trans.Journal and GL-difference after upgrading R05 area to R7
*            Because of difference in suspense entries raised.
*
* 15/07/09 - CI_10064558(CSS REF:HD0921817)
*            Pass different PGM.TYPE to EB.ACCOUNTING.So,that SI/SO entries formed in
*            EB.PROCESS.SUSPENSE will not be dropped in EB.BALANCE.ENTRISE during conversion.
*<<----------------------------------------------------------------------------->>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.ACCOUNT.PARAMETER
    $INSERT I_F.COMPANY
*<<----------------------------------------------------------------------------->>

*** <region name= Main Para>
***
*
    GOSUB INITIALISATION
*
    GOSUB PROCESS
*
    RETURN
*
*** </region>

*<<----------------------------------------------------------------------------->>

*** <region name= INITIALISATION>
*
INITIALISATION:
*
    SUSP.PROCESS = ''
    MULTIPLIER = ''
    ENTRY.VALUE.DATE = ''
    SUSP.TXN.CODE = ''
    INTERNAL.ACCOUNT = ''
    SUSP.ENTRIES = ''
*
    RETURN
*
***</region>

*<<----------------------------------------------------------------------------->>

*** <region name= PROCESS>
PROCESS:
***
*
    IF ENT.REC<AC.STE.BOOKING.DATE> EQ TODAY THEN
        SUSP.PROCESS = "SI"   ;* Suspense in entry
        MULTIPLIER = 1
        ENTRY.VALUE.DATE = TODAY
        SUSP.TXN.CODE = R.ACCOUNT.PARAMETER<AC.PAR.SUSPENSE.TXN.IN>
        GOSUB BUILD.SUSPENSE.ENTRY      ;* Raise Suspense In entry
        SUSP.ENTRIES = LOWER(SUSP.ENTRY)
    END
*
    SUSP.PROCESS = "SO"       ;* Suspense in entry
    MULTIPLIER = -1
    ENTRY.VALUE.DATE = ENT.REC<AC.STE.VALUE.DATE>
    SUSP.TXN.CODE = R.ACCOUNT.PARAMETER<AC.PAR.SUSPENSE.TXN.OUT>
    GOSUB BUILD.SUSPENSE.ENTRY          ;* Raise Suspense Out entry
    SUSP.ENTRIES := @FM:LOWER(SUSP.ENTRY)
*
    V = 11
    CALL EB.ACCOUNTING('AC.VDCONV','SAO',SUSP.ENTRIES,"")
*
    RETURN
*** </region>

*<<----------------------------------------------------------------------------->>

*** <region name= BUILD.SUSPENSE.ENTRY>
BUILD.SUSPENSE.ENTRY:
***
    SUSP.ENTRY = ''
    SUSP.ENTRY<AC.STE.COMPANY.CODE> = ENT.REC<AC.STE.COMPANY.CODE>
    SUSP.ENTRY<AC.STE.CURRENCY> = LCCY
    SUSP.ENTRY<AC.STE.POSITION.TYPE> = "TR"
    SUSP.ENTRY<AC.STE.CURRENCY.MARKET> = 1
    SUSP.ENTRY<AC.STE.BOOKING.DATE> = TODAY
    SUSP.ENTRY<AC.STE.VALUE.DATE> = ENTRY.VALUE.DATE
    SUSP.ENTRY<AC.STE.PROCESSING.DATE> = ENTRY.VALUE.DATE
    SUSP.ENTRY<AC.STE.TRANSACTION.CODE> = SUSP.TXN.CODE

    INTERNAL.ACCOUNT = LCCY:SUSPENSE.CATEGORY:'0001'
    IF C$MULTI.BOOK THEN
*--      Append sub division code in case of multi-book.
        INTERNAL.ACCOUNT := R.COMPANY(EB.COM.SUB.DIVISION.CODE)
    END
*
    SUSP.ENTRY<AC.STE.ACCOUNT.NUMBER> = INTERNAL.ACCOUNT
    SUSP.ENTRY<AC.STE.PRODUCT.CATEGORY> = SUSPENSE.CATEGORY
    SUSP.ENTRY<AC.STE.NET.PARAM> = 'VDSUSP'

    SUSP.ENTRY<AC.STE.AMOUNT.LCY> = (ENT.REC<AC.STE.AMOUNT.LCY> + 0) * MULTIPLIER

    SUSP.ENTRY<AC.STE.SYSTEM.ID> = ENT.REC<AC.STE.SYSTEM.ID>:SUSP.PROCESS
    SUSP.ENTRY<AC.STE.TRANS.REFERENCE> = SUSP.PROCESS:ENTRY.VALUE.DATE:FMT(1,"3'0'R")
    SUSP.ENTRY<AC.STE.OUR.REFERENCE> = SUSP.ENTRY<AC.STE.TRANS.REFERENCE>

    RETURN
*** </region>

*<<----------------------------------------------------------------------------->>
END
