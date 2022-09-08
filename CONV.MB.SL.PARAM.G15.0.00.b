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
* <Rating>-33</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SL.Config
 SUBROUTINE CONV.MB.SL.PARAM.G15.0.00

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_FIN.TO.INT.COMMON

    GOSUB INITIALISE
    GOSUB POPULATE.PARAM.LIST
    GOSUB PROCESS.CONVERSION
    RETURN

*----------
INITIALISE:
*----------
    PARAM.LIST = ''  ; ID.TYPE = '' ; FILE.NAME = ''
    F.COMPANY = '' ; FN.COMPANY = ''
    F.COMPANY.CHECK = '' ; FN.COMPANY.CHECK = ''
    COMPANY.LIST = ''
    MASTER.COMPANY.ID = '' ; MASTER.MNE = ''
    RETURN
*
*-------------------
POPULATE.PARAM.LIST:
*-------------------
* ID.TYPE =        The id format for the records

  PARAM.LIST:= 'SL.PARAMETER*SINGLE*SL':FM:'RE.SL.PARAMETER*SINGLE*SL':FM
  RETURN

*------------------
PROCESS.CONVERSION:
*------------------
*
* To get the File names to process
    LOOP
        REMOVE PARAM.FILE FROM PARAM.LIST SETTING END.OF.IDS
    WHILE PARAM.FILE
        FILE.NAME = FIELD(PARAM.FILE,'*',1)
        ID.TYPE = FIELD(PARAM.FILE,'*',2)
        PRODUCT.ID = FIELD(PARAM.FILE,'*',3)
        CALL EB.CONV.PARAM.FIN.TO.INT(FILE.NAME,ID.TYPE,PRODUCT.ID)
    REPEAT
    RETURN

END
