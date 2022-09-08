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
    $PACKAGE DE.ModelBank
    SUBROUTINE TCIB.LC.PREVIEW.MESSAGE(FINAL.ARRAY)
*-------------------------------------------------------------------------------------------------------
* Developed By : Temenos Application Management
* Program Name : TCIB.LC.PREVIEW.MESSAGE
*-----------------------------------------------------------------------------------------------------------------
* Description   : It's a  nofile enquiry to display the preview message
* Linked With   : Standard.Selection for the Enquiry
* @Author       : manikandant@temenos.com
* In Parameter  : NILL
* Out Parameter : FINAL.ARRAY
* Enhancement   : 696318
*-----------------------------------------------------------------------------------
* Modification Details:
*=====================
*
* 14/07/15 - Enhancement 1326996 / Task 1399947
*			 Incorporation of T components
*
* 28/10/15 - Enhancement 1270337 / Task 1457642
*            Trade - Export LC Amendment 
* 11/11/15 - Defect 1528682 / Task 1528687
*			 Componentisation Incorporation 
*-----------------------------------------------------------------------------------

    $USING DE.ModelBank
    $USING EB.Reports

    GOSUB INIT
    GOSUB PROCESS

    RETURN

*****
INIT:
*****

    RETURN

********
PROCESS:
********


    LOCATE "PRV.MSG" IN EB.Reports.getDFields()<1> SETTING MSG.POS THEN
    MSG.ID= EB.Reports.getDRangeAndValue()<MSG.POS>
    END

    IF MSG.ID NE '' THEN

        R.DE.PREVIEW.MSG = '' ;  Y.MSG.ERR = ''
        R.DE.PREVIEW.MSG = DE.ModelBank.PreviewMsg.Read(MSG.ID, Y.MSG.ERR)

        Y.COUNT = DCOUNT(R.DE.PREVIEW.MSG,@FM)

        Y.START = 1

        LOOP

        WHILE Y.START LE Y.COUNT

            Y.LINE = R.DE.PREVIEW.MSG<Y.START>
            SPACE.TAG = "<S>"
            CHANGE ' ' TO SPACE.TAG IN Y.LINE

            IF Y.LINE NE ' ' THEN
                BLINE = "<br>"
                Y.LINE = Y.LINE : BLINE
                FINAL.ARRAY = FINAL.ARRAY:Y.LINE
            END
            Y.START = Y.START + 1
        REPEAT
    END

    RETURN
    END
