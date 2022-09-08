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

*-----------------------------------------------------------------------------

* <Rating>-34</Rating>

*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.CONVERT.ARR.ACCOUNT(ENQ.DATA)

*----------------------------------------------------------------------------



* The main purpose of this routine is used to convert Arrangement key to Account number



*--------------------------------------------------------------------------------

*Modification History:



*--------------------------------------------------------------------------------



    $USING AA.Framework
    $USING EB.DataAccess



    GOSUB INITIALISE

    GOSUB PROCESS

    RETURN



*------------

INITIALISE:

*------------

*Initialise the variables and open the respective files




    F.AA.ARRANGEMENT = ''


    ARR.ID = ENQ.DATA<4,1>



    RETURN



*--------

PROCESS:

*---------

* Check if the selection criteria is not specified and then form the selection criteria

* that has to be passed to the enquiry.



    IF ARR.ID[1,2] NE 'AA' THEN

        RETURN

    END

    ELSE

    GOSUB PROCESS.ARRANGEMENT

    END

    RETURN



*---------------

PROCESS.ARRANGEMENT:

*--------------

    R.ARRANGEMENT = AA.Framework.Arrangement.Read(ARR.ID, ERR.IO)



    ACCOUNT.ID = R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkedApplId,1>



    ENQ.DATA<2,1> = "@ID"

    ENQ.DATA<3,1> = "EQ"

    ENQ.DATA<4,1> = ACCOUNT.ID



    RETURN



    END

