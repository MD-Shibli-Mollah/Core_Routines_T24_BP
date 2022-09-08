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
* <Rating>-25</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FR.TradeAndHedge
    SUBROUTINE CONV.FRA.CONSOL.TO.CRF.R09(FRA.CON.ID,FRA.CON.REC,FN.FRA.CON)
*
* This conversion is used to create CRF entry from the workfile
* FRA.CONSOL.ENTRY. After creating CRF entry, FRA.CONSOL.ENTRY file is deleted.
*
******************************************************************************
* MODIFICATIONS:
****************
* 04/04/08 - EN_10003615
*            FRA accounting changes to raise balanced entries and
*            making FRA multibook compliance
*
* 28/04/08 - BG_100018281
*            Incorrect company code updation during conversion process
*
******************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.STMT.ENTRY
*
    GOSUB BUILD.BASE.CRF.ENTRY
    GOSUB SETUP.CRF.ENTRY
*
    IF FRA.ENTRY THEN
        CALL EB.ACCOUNTING(SYSTEM.ID,UPD.MODE, FRA.ENTRY, '')
    END
*
    CALL F.DELETE(FN.FRA.CON,FRA.CON.ID)          ;* Delete the file after conversion
*
    RETURN
*
*********************
BUILD.BASE.CRF.ENTRY:
*********************
*
    ENTRY = ''
    FRA.ENTRY = ''
    ENTRY<AC.STE.ACCOUNT.NUMBER> = ""
* Take company id from consol key in case of multi book
    REC.COM.ID = FIELD(FRA.CON.REC<1,1>,'.',17)[1,12]
    IF NOT(REC.COM.ID) THEN
        REC.COM.ID = ID.COMPANY         ;* Else store id company
    END
    ENTRY<AC.STE.COMPANY.CODE> = REC.COM.ID
    ENTRY<AC.STE.TRANSACTION.CODE> = ''
    ENTRY<AC.STE.NARRATIVE> = ""
    ENTRY<AC.STE.PL.CATEGORY> = ""
    ENTRY<AC.STE.POSITION.TYPE> = 'TR'
    ENTRY<AC.STE.CURRENCY.MARKET> = '1'
    ENTRY<AC.STE.BOOKING.DATE> = TODAY
*
    RETURN
*
****************
SETUP.CRF.ENTRY:
****************
*
    ENTRY<AC.STE.CONSOL.KEY> = FRA.CON.REC<1,1>   ;* Updating CRF with existing consol key
    ENTRY<AC.STE.CRF.CURRENCY> = FRA.CON.REC<1,2>
    ENTRY<AC.STE.CURRENCY> = FRA.CON.REC<1,2>
    IF ENTRY<AC.STE.CURRENCY> # LCCY THEN
        ENTRY<AC.STE.AMOUNT.LCY> = FRA.CON.REC<1,6>
        IF ENTRY<AC.STE.AMOUNT.LCY> = "" THEN
            ENTRY<AC.STE.AMOUNT.LCY> = FRA.CON.REC<1,7>
        END
    END
    IF FRA.CON.REC<1,4> OR FRA.CON.REC<1,6> THEN
        ENTRY<AC.STE.AMOUNT.FCY> = FRA.CON.REC<1,4>
        IF ENTRY<AC.STE.CURRENCY> = LCCY THEN
            ENTRY<AC.STE.AMOUNT.LCY> = FRA.CON.REC<1,4>
        END
    END ELSE        ;* Cr. (Liability)
        ENTRY<AC.STE.AMOUNT.FCY> = FRA.CON.REC<1,5>
        IF ENTRY<AC.STE.CURRENCY> = LCCY THEN
            ENTRY<AC.STE.AMOUNT.LCY> = FRA.CON.REC<1,5>
        END
    END
    ENTRY<AC.STE.CRF.TYPE> = FRA.CON.REC<1,3>
    ENTRY<AC.STE.OUR.REFERENCE> = FRA.CON.REC<1,17>[1,12]
    ENTRY<AC.STE.CUSTOMER.ID> = FRA.CON.REC<1,18>
    ENTRY<AC.STE.CRF.TXN.CODE> = FRA.CON.REC<1,19>
    ENTRY<AC.STE.EXCHANGE.RATE> = FRA.CON.REC<1,20>
    ENTRY<AC.STE.ACCOUNT.OFFICER> = FRA.CON.REC<1,21>
    ENTRY<AC.STE.PRODUCT.CATEGORY> = FRA.CON.REC<1,22>
    ENTRY<AC.STE.VALUE.DATE> = FRA.CON.REC<1,8>
    ENTRY<AC.STE.CRF.MAT.DATE> = FRA.CON.REC<1,9>
    ENTRY<AC.STE.SYSTEM.ID> = 'FR'
    SYSTEM.ID = ENTRY<AC.STE.SYSTEM.ID>
    UPD.MODE = 'SAO'
    FRA.ENTRY<-1> = LOWER(ENTRY)
*
    RETURN
*
END

