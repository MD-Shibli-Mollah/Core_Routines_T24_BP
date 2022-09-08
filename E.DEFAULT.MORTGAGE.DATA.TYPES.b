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
    $PACKAGE OP.ModelBank
    SUBROUTINE E.DEFAULT.MORTGAGE.DATA.TYPES

* Subroutine to extract the data types associated with Mortgage Score Card and default them into the version
*
* TASK 295073
*  Separate score cards for PL, AL and Mortgage  - Routine modification
* modified for generic to work for all Versions
* 04-03-16 - 1653120
*            Incorporation of components
*----------------------------------------------------------------------------------------

    $USING SA.Foundation
    $USING EB.Versions
    $USING EB.SystemTables


    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN

PROCESS:

    R.VERSION.RECORD = EB.Versions.Version.Read(Y.VERSION.ID, READ.ERR.1)
* Before incorporation : CALL F.READ(FN.VERSION, Y.VERSION.ID, R.VERSION.RECORD, F.VERSION, READ.ERR.1)
    Y.SCORE.DATA = EB.SystemTables.getRNew(SA.Foundation.ScoreTxn.StScoreData)

    R.SA.SCORE.DATA.RECORD = SA.Foundation.ScoreData.Read(Y.SCORE.DATA, READ.ERR.2)
* Before incorporation : CALL F.READ(FN.SA.SCORE.DATA,Y.SCORE.DATA,R.SA.SCORE.DATA.RECORD,F.SA.SCORE.DATA,READ.ERR.2)
    EB.SystemTables.setRNew(SA.Foundation.ScoreTxn.StDataTypes, R.SA.SCORE.DATA.RECORD<SA.Foundation.ScoreData.SdSaDataTypes>)

    RETURN

INITIALISE:

    RETURN
    END
