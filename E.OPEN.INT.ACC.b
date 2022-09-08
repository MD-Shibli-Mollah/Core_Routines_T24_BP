* @ValidationCode : MjotODYwOTA0OTI5OkNwMTI1MjoxNjE3Nzg2NDAwMDc4OmNtYW5pdmFubmFuOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwNC4yMDIxMDMzMC0wNTAxOi0xOi0x
* @ValidationInfo : Timestamp         : 07 Apr 2021 14:36:40
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : cmanivannan
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202104.20210330-0501
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
*-----------------------------------------------------------------------------
* <Rating>-32</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.ModelBank
SUBROUTINE E.OPEN.INT.ACC(RETURN.DATA)
*-----------------------------------------------------------------------------
*Subroutine Type   :  Nofile Enquiry Routine
*Attached to       :  As a Nofile Enquiry Routine to the Enquiry OPEN.INT.ACC
*
*Incoming : RETURN.DATA
*-------------------------
*
*Outgoing  : RETURN.DATA
*--------------------------
*
*Primary Purpose : 07/10/15   - Task ID 1493051
*
*        To display the Internal Account based on the User Input. It gets the Currency, Category and
*        Sequence Number (Optional) from the user and validate through appropriate application. It opens
*        concern application and match with the user input, if the values are correct one it retuns the data
*        to the enquiry else it throws Error trough ENQ.ERROR.
*------------------------------------------------------------------------------------------------------------
* 3/03/17 - 2035464
*            Temenos Infrastrucure remove unused dependencies
*            I_F.ACCOUNT
* 14/10/20 - Enhancement - 4033448 / Task - 4033449
*          - Read the category record by calling MDAL api's.
*------------------------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CURRENCY
    $INSERT I_ENQUIRY.COMMON
    
    $USING MDLREF.ReferenceData
    
    GOSUB INIT
    GOSUB OPEN.FILES
    GOSUB PROCESS
    
RETURN
    
*-----------------------------------------------------------
INIT:
*-------------------------------------------------------------
    FN.CURRENCY = 'F.CURRENCY'
    F.CURRENCY = ''

    CURRENCY.POS = ''
    CATEGORY.POS = ''
    SEQUENCE.POS = ''
    R.CUR.REC = ''
    R.CAT.REC = ''

RETURN
*-----------------------------------------------------------------
OPEN.FILES:
*------------------------------------------------------------------

    CALL OPF(FN.CURRENCY,F.CURRENCY)

RETURN
*------------------------------------------------------------------
PROCESS:
*------------------------------------------------------------------

    LOCATE "CURRENCY.CODE" IN D.FIELDS<1> SETTING CURRENCY.POS THEN
        CURRENCY.CODE = D.RANGE.AND.VALUE<CURRENCY.POS>
    END

    CALL F.READ(FN.CURRENCY,CURRENCY.CODE,R.CUR.REC,F.CURRENCY,CUR.ERR1)

    IF CUR.ERR1 NE '' THEN
        ENQ.ERROR<-1> = 'EB-INVALID.CCY'
    END
* READ THE CURRENCY WITH CURRENCY APPLICATION AND THROUGH AN ERROR -> EB.ERROR CODE EB-INVALID.CCY


    LOCATE "CATEGORY.CODE" IN D.FIELDS<1> SETTING CATEGORY.POS THEN
        CATEGORY.CODE =  D.RANGE.AND.VALUE<CATEGORY.POS>
    END
    
    R.CAT.REC = MDLREF.ReferenceData.getCategoryDetails(CATEGORY.CODE)

    IF ETEXT THEN
        ENQ.ERROR<-1> = 'AC-INVALID.AC.CATEG.ID'
    END

    IF CATEGORY.CODE LT 10000 OR CATEGORY.CODE GT 19999 THEN
        ENQ.ERROR<-1> = 'AC-CAT.RG.10.19'
    END

* IF CATEGORY CODE NOT IN RG 10000 AND 19999 THROUGH AN ERROR AC-CAT.RG.10.19

    LOCATE "SEQUENCE.CODE" IN D.FIELDS<1> SETTING SEQUENCE.POS THEN
        SEQUENCE.CODE = D.RANGE.AND.VALUE<SEQUENCE.POS>
    END

    IF SEQUENCE.CODE EQ '' THEN
        SEQUENCE.CODE = '0001'
    END

    IF SEQUENCE.CODE GT 9999 OR LEN(SEQUENCE.CODE) GT 4 THEN
        ENQ.ERROR<-1> = 'EB-INVALID.SEQUENCE'
    END
*    RETURN
    RETURN.DATA<-1> = CURRENCY.CODE:"*":CATEGORY.CODE:"*":SEQUENCE.CODE
RETURN

END
