* @ValidationCode : MTozMzc3MTU3NDk6Q3AxMjUyOjE0NzYzNDI1NzgyNDE6c2luZGh1czoxOjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTYxMC4w
* @ValidationInfo : Timestamp         : 13 Oct 2016 12:39:38
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sindhus
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201610.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
    $PACKAGE LC.ModelBank

    SUBROUTINE DR.DEFAULT.ASSN.AMOUNT
*-----------------------------------------------------------------------------
* This routine defaults the assignment amount in Drawings
* based on the percentage calculated from lc assgn amount to lc amount
*-----------------------------------------------------------------------------
**** <region name= Modification History>
* 03/10/16 Task : 1877852
*          System is not defaulting total assignment amount and providing a blocking message related to reference.
*          REF : 1850676
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INSERTS>
    $USING EB.SystemTables
    $USING LC.Contract
    $USING LC.Foundation
    $USING EB.API
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main Processing>
*** <desc> </desc>

    GOSUB INITIALISE ;* Initialise Variables
    GOSUB PROCESS ;* Process the Assignment

*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise the Variables </desc>
INITIALISE:
*===============
    LC.AMOUNT = LC.Foundation.getLcRec(LC.Contract.LetterOfCredit.TfLcLcAmount) ;* get the lc amount
    DOC.AMOUNT = EB.SystemTables.getRNew(LC.Contract.Drawings.TfDrDocumentAmount) ;* get the drawings amount
    ASSN.ARRAY = EB.SystemTables.getRNew(LC.Contract.Drawings.TfDrAssnAmount) ;* get the drawings assn amount
    ASSN.REF = EB.SystemTables.getRNew(LC.Contract.Drawings.TfDrAssignmentRef) ;* get the drawings assignment ref
    DR.CCY = EB.SystemTables.getRNew(LC.Contract.Drawings.TfDrDrawCurrency) ;* get the draw currency
    DR.ASSGN.AMT = ''

    RETURN
*** </region>
*----------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>Main Process</desc>
PROCESS:
*==============

    NO.OF.ASSIGN = DCOUNT(ASSN.REF,@VM) ;* count the drawings assignment ref.
    FOR ASSN.CNT = 1 TO NO.OF.ASSIGN
        CURR.ASSN.REF = ASSN.REF<1,ASSN.CNT> ;* get the assignment ref to be processed
        ASSN.POS = ''
        ASSN.PERCENT = ''
        LOCATE CURR.ASSN.REF IN LC.Foundation.getLcRec(LC.Contract.LetterOfCredit.TfLcAssnReference)<1,1> SETTING ASSN.POS THEN ;* locate the current assignment ref in lc
        ASSN.PERCENT = (LC.Foundation.getLcRec(LC.Contract.LetterOfCredit.TfLcAssnAmount)<1,ASSN.POS> * 100)/LC.AMOUNT ;* find the percentage of current lc assn amount to the lc amount
        DR.ASSGN.AMT = (DOC.AMOUNT*ASSN.PERCENT)/100 ;* find the drawings assn amount based on calculated percentage
        IF ASSN.ARRAY<1,ASSN.CNT> EQ '' THEN
            EB.API.RoundAmount(DR.CCY, DR.ASSGN.AMT, '1', '') ;* Roundoff decimal values
            ASSN.ARRAY<1,ASSN.CNT> = DR.ASSGN.AMT
        END
    END
    NEXT ASSN.CNT
    EB.SystemTables.setRNew(LC.Contract.Drawings.TfDrAssnAmount,ASSN.ARRAY) ;* set the drawings assn amount
    RETURN
*** </region>
    END
*-----------------------------------------------------------------------------

