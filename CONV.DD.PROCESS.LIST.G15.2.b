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
* <Rating>49</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DD.Contract
    SUBROUTINE CONV.DD.PROCESS.LIST.G15.2

***********************************************************
* This Conversion routine converts DD.PROCESS.LIST to the
* new template format. The template of this Live file has been
* changed and field MANDATE.REF is removed from the application
* and been appended as part of ID of this template.
***********************************************************
*
* 11/02/05 - EN_10002415
*            CONCAT FILE CHANGES SAR - INITIAL VERSION
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE

    EQU DD.PL.MANDATE.REF TO 1, DD.PL.DD.ITEM TO 2, PL.DD.ITEM TO 1

*============
* INITIALISE:
*============
    R.DD.PROCESS = ''
    R.DD.PROCE = ''
    PROCESS.ID = ''
    PROCESS.DATE.LIST = ''
    NO.LIST = ''
    LIST.ERR = ''
    RTERR = ''

*============
* OPEN FILES:
*============
    FN.DD.PROCESS.LIST = 'F.DD.PROCESS.LIST'
    FV.DD.PROCESS.LIST = ''
    CALL OPF(FN.DD.PROCESS.LIST, FV.DD.PROCESS.LIST)

*=========
* PROCESS:
*=========
    SEL.CMD = 'SELECT ':FN.DD.PROCESS.LIST
    CALL EB.READLIST(SEL.CMD, PROCESS.DATE.LIST, '', NO.LIST, LIST.ERR)

    IF PROCESS.DATE.LIST NE '' THEN
        NO.LIST.ID = DCOUNT(PROCESS.DATE.LIST,@FM)
        FOR ID.LIST = 1 TO NO.LIST.ID
            IF NOT(INDEX(PROCESS.DATE.LIST<ID.LIST>,'-',2)) THEN
                PROCESS.ID = PROCESS.DATE.LIST<ID.LIST>
                CALL F.READ(FN.DD.PROCESS.LIST, PROCESS.ID, R.DD.PROCESS, FV.DD.PROCESS.LIST, RTERR)
                MAND.NO = DCOUNT(R.DD.PROCESS<DD.PL.MANDATE.REF>, @VM)
                FOR MAND.ID = 1 TO MAND.NO
                    TEMP.MAND = R.DD.PROCESS<DD.PL.MANDATE.REF,MAND.ID>
                    DD.ITEM = R.DD.PROCESS<DD.PL.DD.ITEM,MAND.ID>
                    CONVERT SM TO VM IN DD.ITEM
                    R.DD.PROCE<PL.DD.ITEM> = DD.ITEM
                    DD.PARAM.ID = FIELD(PROCESS.ID,'-',1)
                    DD.PROC.DATE = FIELD(PROCESS.ID,'-',2)
                    DD.MAND.REF = TEMP.MAND
                    DD.PROCESS.LIST.ID = DD.PARAM.ID:'-':DD.PROC.DATE:'-':DD.MAND.REF
                    WRITE R.DD.PROCE TO FV.DD.PROCESS.LIST, DD.PROCESS.LIST.ID
                NEXT MAND.ID
                DELETE FV.DD.PROCESS.LIST, PROCESS.ID
            END
        NEXT ID.LIST
    END
    RETURN
END
