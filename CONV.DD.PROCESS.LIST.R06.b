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
* <Rating>200</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DD.Contract
    SUBROUTINE CONV.DD.PROCESS.LIST.R06
*********************************************************
* 25/04/05 - EN_10002478
*            Allow DD's to be processed in other currencies as well.
*            SAR-2004-08-23-0002
*        
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*   
* Selects DD.PROCESS.LIST.
* Processes IDs that does not have currency field in ID.
* Currency is the fourth parameter in ID delimited by hyphen.
* Appends the local currency to the ID if not present.
*
*********************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE

    FN.DD.PROCESS.LIST = 'F.DD.PROCESS.LIST'
    F.DD.PROCESS.LIST = ''
    CALL OPF(FN.DD.PROCESS.LIST,F.DD.PROCESS.LIST)
    SEL.CMD =    "SELECT ": FN.DD.PROCESS.LIST
    EXECUTE SEL.CMD

    LOOP
        READNEXT DDPR.ID ELSE DDPR.ID = ''

    WHILE DDPR.ID

        MN.CCY = FIELD(DDPR.ID,"-",4,1)

        IF NOT(MN.CCY) THEN
            CHG.ID = DDPR.ID:"-":LCCY
            READ R.REC FROM F.DD.PROCESS.LIST,DDPR.ID ELSE R.REC = ''
            DELETE F.DD.PROCESS.LIST,DDPR.ID
            WRITE R.REC TO F.DD.PROCESS.LIST,CHG.ID
        END

    REPEAT


    RETURN
END
