* @ValidationCode : MjoxNzQyMjk3MDYxOkNwMTI1MjoxNDkyNDA2MDc5OTM2OmJpa2FzaHJhbmphbjoxOjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTcwMi4wOjI0OjI0
* @ValidationInfo : Timestamp         : 17 Apr 2017 10:44:39
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bikashranjan
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 24/24 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* <Rating>-19</Rating>
*-----------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------

    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.BUILD.GRP.CREDIT.INT(ENQ.DATA)

*---------------------------------------------------------------------------------------------------------
*
* DESCRIPTION :
* -----------
* This is a build routine that is attched to a enquiry GROUP.CREDIT.INTEREST.CONDS.
* The Enquiry displays the list of Group Credit Interest conditions set across the system for a customer
*
*---------------------------------------------------------------------------------------------------------
*
* REVESION HISTORY :
* ----------------
*
*  VERSION : 1.1               DATE : 10 AUG 2009          CD  : BG_100024451
*   
*
* 30/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*                                                       TTS : TTS0908934
*
* 17/04/2017 - Defect : 2082009 / Task : 2085737
*                       fix for  expected listing of Group credit interest enq.
*----------------------------------------------------------------------------------------------------------
    $INSERT I_DAS.GROUP.CREDIT.INT

    $USING EB.DataAccess

    GOSUB READ.GCI

    RETURN

*-------
READ.GCI:
*-------


    TABLE.NAME   = "GROUP.CREDIT.INT"
    DAS.LIST     = dasGroupCreditIntIdByDsnd
    ARGUMENTS    = ENQ.DATA<4,1>
    TABLE.SUFFIX = ''

    EB.DataAccess.Das(TABLE.NAME, DAS.LIST, ARGUMENTS, TABLE.SUFFIX)

    IF DAS.LIST NE '' THEN

        LOOP
            REMOVE GCI.ID FROM DAS.LIST SETTING GCI.ID.POS
        WHILE GCI.ID:GCI.ID.POS

            Y.GCI.TEMP = GCI.ID[1, LEN(GCI.ID) - 8]


            LOCATE Y.GCI.TEMP IN Y.TEMP.ARR SETTING Y.GCI.TEMP.POS ELSE

            Y.TEMP.ARR<-1> = Y.GCI.TEMP

            Y.RET.VAL<-1> = GCI.ID

        END

    REPEAT

    CONVERT @FM TO ' ' IN Y.RET.VAL

    ENQ.DATA<2> = '@ID'
    ENQ.DATA<3> = 'EQ'
    ENQ.DATA<4> = Y.RET.VAL


    END

    RETURN
