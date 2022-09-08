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
* <Rating>-21</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.Customer
    SUBROUTINE CONV.CUSTOMER.REVIEW.FQU(DATE.ID,RECORD1,Y.FILE)
*
* 12/4/10 - 40965
*          The CUSTOMER.FQU Concat file ID as date and its record
*          contains list of Customer ID’s to be review falling under the ID date,
*          During COB delete the Customer id from the Old Date ID and update
*          it into new frequency date record on the Concat File FXXX.CUSTOMER.FQU, this leads
*          performance problem. Process modified to change the Key file structure.
**--------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE

    GOSUB INITIALISE
    GOSUB UPDATE.KEY.FILE
    RETURN


INITIALISE:
    TEMP.DATE = DATE.ID
    REC1= ''
    CALL F.DELETE(Y.FILE,DATE.ID)       ;* Delete the original
    CUSTOMER.LIST.COUNT = DCOUNT(RECORD1,FM)
    RETURN


UPDATE.KEY.FILE:
    FOR ITEM.POS = 1 TO CUSTOMER.LIST.COUNT
        IF ITEM.POS EQ CUSTOMER.LIST.COUNT THEN
            DATE.ID = TEMP.DATE:'*':RECORD1<ITEM.POS>
            RECORD1 = ''
        END ELSE
            DATE.ID = TEMP.DATE:'*':RECORD1<ITEM.POS>
            CALL F.WRITE(Y.FILE,DATE.ID,REC1)
        END
    NEXT ITEM.POS
    RETURN
    END
