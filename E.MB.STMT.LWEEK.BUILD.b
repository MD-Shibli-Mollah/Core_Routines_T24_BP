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
    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.STMT.LWEEK.BUILD(ENQ.DATA)
*************************************************************************************************
* Subroutine Type: Subroutine

* Incoming : ENQ.DATA Common Variable contains all the Enquiry Selection Criteria Details

* Outgoing : ENQ.DATA Common Variable

* Attached to : ENQUIRY STMT.ENT.BOOK.LWEEK

* Purpose  : To get the Selection Field values and passed to main routine

************************************************************************************************

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN
****************************************************************************************************

INITIALISE:
**************
    ACCT.POS = ""
    ACCT.NO = ""
    BOOK.VAL = ""
    DATE.FLAG = ""

    RETURN

*********************
PROCESS:
*********************

    LOCATE "ACCT.ID" IN ENQ.DATA<2,1> SETTING ACCT.POS THEN
    ACCT.NO = ENQ.DATA<4,ACCT.POS>
    END

    BOOK.VAL = "!TODAY-7W"
    DATE.FLAG = "BOOK"

    ENQ.DATA<2,1> = "ACCT.ID"
    ENQ.DATA<3,1> = "EQ"
    ENQ.DATA<4,1> = ACCT.NO

    ENQ.DATA<2,2> = "BOOKING.DATE"
    ENQ.DATA<3,2> = "GT"
    ENQ.DATA<4,2> = BOOK.VAL

    RETURN
*-----------------------------------------------------------------------------
    END
