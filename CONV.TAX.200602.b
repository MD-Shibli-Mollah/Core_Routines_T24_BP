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
* <Rating>46</Rating>
*-----------------------------------------------------------------------------
* Version n dd/mm/yy  GLOBUS Release No. 200508 30/06/05
*
    $PACKAGE ST.ChargeConfig
    SUBROUTINE CONV.TAX.200602
*-----------------------------------------------------------------------------
* Template file routine, to be used as a basis for building a FILE.ROUTINE
* to be run as part of the CONVERSION.DETAILS record.
* This routine should only be used to do such things as change record keys etc
* where ever possible use the RECORD.ROUTINE to convert/populate record data fields.
*-----------------------------------------------------------------------------
* Modification History:
* ====================
*
* 06/01/06 - EN_10002716
*            The field TAX.ROUNDING in TAX has been changed to ROUNDING.RULE.
*            This conversion will check if TAX.ROUNDING was previously set to
*            'DOWN' it will now point to the 'TAX.DOWN' record in EB.ROUNDING.RULE
* 24/03/06 - BG_100010722
*            Conversion crashes in Multi-book area
* 10/04/06 - BG_100010901
*            Missing mnemonic
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY.CHECK ;* BG_100010722

    GOSUB INITIALISE

    GOSUB GET.MNEMONIC.LIST

    GOSUB MODIFY.FILE


    RETURN



***********************************************************************************

*---------*
INITIALISE:


*
    EQUATE EB.TAX.ROUNDING.RULE TO 26

    RETURN

**************************************************************************************
*----------------*
GET.MNEMONIC.LIST:
*-----------------
*
* Loop through each company


*  BG_100010722 S
    CALL CACHE.READ("F.COMPANY.CHECK","FINANCIAL",R.COMPANY.CHECK,ER)
    MNEMONIC.LIST = R.COMPANY.CHECK<EB.COC.COMPANY.MNE>
* BG_100010722 E

    RETURN
************************************************************************
MODIFY.FILE:
    FILE.TO.CNT = DCOUNT(MNEMONIC.LIST, VM)        ; * BG_100010901

    FOR FILE.NUMBER = 1 TO FILE.TO.CNT

        FILE.MNE = MNEMONIC.LIST<1,FILE.NUMBER>    ; * BG_100010901


        FOR FILE.TYPE = 1 TO 3
            BEGIN CASE
            CASE FILE.TYPE EQ 1
                SUFFIX = ""
            CASE FILE.TYPE EQ 2
                SUFFIX = "$NAU"
            CASE FILE.TYPE EQ 3
                SUFFIX = "$HIS"
            END CASE

            FN.TAX.FILE = 'F':FILE.MNE:'.TAX':SUFFIX
            F.TAX.FILE = ''
            CALL OPF(FN.TAX.FILE,F.TAX.FILE)
            GOSUB SELECT.TAX

            IF SEL.LIST # '' THEN
                GOSUB PROCESS.RECORD
            END

        NEXT FILE.TYPE

    NEXT FILE.NUMBER
    RETURN
****************************************************************************

SELECT.TAX:

*--------------------*

    SEL.STMT = 'SELECT ':FN.TAX.FILE
    SEL.LIST = ""
    SELECTED = ""
    RET.CODE = ""
    CALL EB.READLIST(SEL.STMT, SEL.LIST, '', SELECTED, RET.CODE)
    RETURN

*---------------------*
PROCESS.RECORD:
*---------------------*

    LOOP
        REMOVE TAX.ID FROM SEL.LIST SETTING MORE
    WHILE TAX.ID:MORE

        TAX.REC = ''
        YERR = ''
        RETRY = ""
        READ TAX.REC FROM F.TAX.FILE,TAX.ID THEN
            IF TAX.REC<EB.TAX.ROUNDING.RULE> EQ 'DOWN'
            THEN TAX.REC<EB.TAX.ROUNDING.RULE> = 'TAX.DOWN'

        END
        WRITE TAX.REC ON F.TAX.FILE, TAX.ID
    REPEAT


    RETURN

*-------------------------------------------------------------
END
