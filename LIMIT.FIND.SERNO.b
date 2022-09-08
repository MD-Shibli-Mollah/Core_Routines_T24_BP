* @ValidationCode : MjoxODQyNDI0NDkzOmNwMTI1MjoxNTEwMzEzMjMxNjE4OmthcnRoaWt2Oi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMjAxNzA5MTUtMDAwODotMTotMQ==
* @ValidationInfo : Timestamp         : 10 Nov 2017 11:27:11
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : karthikv
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.20170915-0008
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE LI.ModelBank
SUBROUTINE LIMIT.FIND.SERNO
*-----------------------------------------------------------------------------
*
* This subroutine will be used to decode the Serial no of the LIMIT
* It is used in the standard enquiry system
* and therefore all the parameters required are
* passed in I_ENQUIRY.COMMON
*
* The fields used are as follows:-
*
* INPUT   ID              Id of the LIMIT record
*                         being processed.
*
*         R.RECORD        LIMIT record.
*
*         VC              Pointer to the current
*                         multi-value set being
*                         processed.
*
*         S               Pointer to the current
*                         sub-value set being
*                         processed.
*
*         O.DATA          Full limit reference key
*
*
* OUTPUT  O.DATA          Shortened limit reference key
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 06/11/17 - EN 2232234 / Task 2232237
*            Creation of this routine
*
*-----------------------------------------------------------------------------
    $USING EB.Reports
    $USING LI.Config
*
    LIMIT.ID = EB.Reports.getId()
    LIMIT.ID.COMPONENTS = ''
    LIMIT.ID.COMPOSED = ''
    LI.Config.LimitIdProcess(LIMIT.ID, LIMIT.ID.COMPONENTS, LIMIT.ID.COMPOSED, '', '')
    LIMIT.SER.NO = LIMIT.ID.COMPONENTS<3>
    EB.Reports.setOData(LIMIT.SER.NO)
RETURN
*-----------------------------------------------------------------------------
END
