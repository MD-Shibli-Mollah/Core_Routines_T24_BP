* @ValidationCode : Mjo0NzMzOTI3ODQ6Q3AxMjUyOjE0OTI0MDYwNzk4Njk6YmlrYXNocmFuamFuOjE6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxNzAyLjA6Mjc6Mjc=
* @ValidationInfo : Timestamp         : 17 Apr 2017 10:44:39
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bikashranjan
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 27/27 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-29</Rating>
*-----------------------------------------------------------------------------

    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.BUILD.GRP.DEBIT.INT(ENQ.DATA)

*---------------------------------------------------------------------------------------------------------
*
* DESCRIPTION :
* -----------
* This is a build routine that is attched to the enquiry GROUP.DEBIT.INTEREST.CONDS.
* The Enquiry displays the list of Group Debit Interest conditions set across the system for a customer
*
* 17/04/2017 - Defect : 2082009 / Task : 2085737
*                       fix for  expected listing of Group debit interest enq.
*
*---------------------------------------------------------------------------------------------------------
*
* REVESION HISTORY :
* ----------------
*
*  VERSION : 1.0               DATE : 10 AUG 2009          CD  : BG_100024451
*                                                          TTS : TTS0908934
*
* 30/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*----------------------------------------------------------------------------------------------------------

    $INSERT I_DAS.GROUP.DEBIT.INT

    $USING EB.DataAccess

    GOSUB INITIALISE
    GOSUB READ.GDI

    RETURN

*---------
INITIALISE:
*---------


    RETURN

*-------
READ.GDI:
*-------


    Y.TEMP.ARR = ''

    TABLE.NAME   = "GROUP.DEBIT.INT"
    DAS.LIST     = dasGroupDebitIntIdLikeByIdDsnd
    ARGUMENTS    = ENQ.DATA<4,1>
    TABLE.SUFFIX = ''


    EB.DataAccess.Das(TABLE.NAME, DAS.LIST, ARGUMENTS, TABLE.SUFFIX)

    IF DAS.LIST NE '' THEN

        LOOP

            REMOVE GDI.ID FROM DAS.LIST SETTING GDI.ID.POS

        WHILE GDI.ID:GDI.ID.POS


            Y.GDI.TEMP = GDI.ID[1, LEN(GDI.ID) - 8]


            LOCATE Y.GDI.TEMP IN Y.TEMP.ARR SETTING Y.GDI.TEMP.POS ELSE

            Y.TEMP.ARR<-1> = Y.GDI.TEMP

            Y.RET.VAL<-1> = GDI.ID

        END

    REPEAT

    CONVERT @FM TO ' ' IN Y.RET.VAL

    ENQ.DATA<2> = '@ID'
    ENQ.DATA<3> = 'EQ'
    ENQ.DATA<4> = Y.RET.VAL


    END

    RETURN
