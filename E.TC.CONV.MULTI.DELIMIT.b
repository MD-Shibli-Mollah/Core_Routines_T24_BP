* @ValidationCode : MTotMTM3MTg4MjI2NjpDcDEyNTI6MTQ3MjEyNDE0MjkyMzpzYXRoaXNoa3VtYXJqOi0xOi0xOjE4MzoxOmZhbHNlOk4vQTpERVZfMjAxNjA4LjA=
* @ValidationInfo : Timestamp         : 25 Aug 2016 16:52:22
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sathishkumarj
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 183
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201608.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-21</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.Channels
    SUBROUTINE E.TC.CONV.MULTI.DELIMIT
*-----------------------------------------------------------------------------
* Routine type       : Conversion routine
* Attached To        : Every TC enquiry
* Purpose            : To convert the space between the multi valued fields into pipe symbol
*
*-----------------------------------------------------------------------------
* Modification History :
* 18/08/15 - Enhancement - 1270295 / Task:
*            Convert the space between the multi valued fields into pipe symbol
* 03/08/16 - Enhancement - 1735197 / Task: 1777327
*            Retail Payment Order Application
*-----------------------------------------------------------------------------
    $USING EB.Reports
*-----------------------------------------------------------------------------
    GOSUB INITIALIZE
    GOSUB PROCESS
    RETURN
*------------------------------------------------------------------------------
INITIALIZE:
*-------
    FIELD.VALUE = '';*Initialising variable
    RETURN
*------------------------------------------------------------------------------
PROCESS:
*-------
    FIELD.VALUE = EB.Reports.getOData() ;*current field value
    CONVERT @VM TO '|' IN FIELD.VALUE
    CONVERT @SM TO '~' IN FIELD.VALUE
    EB.Reports.setOData(FIELD.VALUE);*output.
    RETURN

    END
