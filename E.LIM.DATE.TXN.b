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

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-13</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LI.ModelBank

    SUBROUTINE E.LIM.DATE.TXN
*-------------------------------------------------
*
* This subroutine will be used to
* reformat the date as used in the enquiry system
* in the parameter TODAY in I_ENQUIRY.COMMON.
*
* The fields used are as follows:-
*
* INPUT   ID              Id of the record
*                         being processed.
*
*         R.RECORD        record being processed
*
*         VC              Pointer to the current
*                         multi-value set being
*                         processed.
*
*         S               Pointer to the current
*                         sub-value set being
*                         processed.
*         O.DATA          TODAY or expiry date or time code
*
*
* OUTPUT O.DATA           Reformatted date
*
*-------------------------------------------------Insert statements

    $USING EB.Reports
    $USING EB.SystemTables

    O.DATA.VALUE = EB.Reports.getOData()
    T.REM.TEXT = EB.SystemTables.getTRemtext(19)
    IF O.DATA.VALUE > '999' THEN
        O.DATA.VALUE = O.DATA.VALUE[7,2]:" ":FIELD(T.REM.TEXT," ",O.DATA.VALUE[5,2]):" ":O.DATA.VALUE[1,4]
        EB.Reports.setOData(O.DATA.VALUE)
    END

    RETURN
*-----------------------------------------------------------------------------
    END
