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

*----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* <Rating>-34</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctSettlement
    SUBROUTINE CONV.SC.SETTLE.CUST.200706(ID,RECORD,FILENAME)
*-----------------------------------------------------------------------------
* Correction/conversion routine for SC.SETTLE.CUST
* the data in this record needs to be built so that we can drop
* the i-descriptors.
*-----------------------------------------------------------------------------
* Record routine for conversion details CONV.SC.SETTLE.CUST.200706
* will populate field if it's not set
* all the files are opened by a pre routine and passed in the common
*-----------------------------------------------------------------------------
* Modification History :
*
* 05/02/08 - GLOBUS_CI_10053569
*            Common variables defined in PRE.ROUTINE is not distributed
*            across multiple threads as PRE.ROUTINE is run only in a single thread,
*            hence system crashes while using these common variables.
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE

    GOSUB INITIALISE

    GOSUB PROCESS

    RETURN

*------------
INITIALISE:
*------------

    FN.SC.SETTLEMENT = 'F.SC.SETTLEMENT'
    F.SC.SETTLEMENT = ''
    CALL OPF(FN.SC.SETTLEMENT,F.SC.SETTLEMENT)

    FN.SC.SETTLEMENT$NAU = 'F.SC.SETTLEMENT$NAU'
    F.SC.SETTLEMENT$NAU = ''
    CALL OPF(FN.SC.SETTLEMENT$NAU,F.SC.SETTLEMENT$NAU)

    FN.SC.SETTLEMENT$HIS = 'F.SC.SETTLEMENT$HIS'
    F.SC.SETTLEMENT$HIS = ''
    CALL OPF(FN.SC.SETTLEMENT$HIS,F.SC.SETTLEMENT$HIS)

    RETURN

*--------
PROCESS:
*--------

    SC.SETTLEMENT.ID = ID
    R.SC.SETTLEMENT = ''
    YERR = ''
    CALL F.READ(FN.SC.SETTLEMENT$NAU,SC.SETTLEMENT.ID,R.SC.SETTLEMENT,F.SC.SETTLEMENT$NAU,YERR)
    IF YERR NE '' THEN
        R.SC.SETTLEMENT = ''
        YERR = ''
        CALL F.READ(FN.SC.SETTLEMENT,SC.SETTLEMENT.ID,R.SC.SETTLEMENT,F.SC.SETTLEMENT,YERR)
    END
    IF YERR NE '' THEN
        SC.SETTLEMENT.ID.HIS = SC.SETTLEMENT.ID: ';1'
        R.SC.SETTLEMENT = ''
        YERR = ''
        CALL F.READ(FN.SC.SETTLEMENT$HIS,SC.SETTLEMENT.ID.HIS,R.SC.SETTLEMENT,F.SC.SETTLEMENT$HIS,YERR)
* as it's in history it must have settled, but record 1 may not have the date set
* so lets makes sure it's set to force the flag to Y
        R.SC.SETTLEMENT<77> = TODAY
    END

    IF RECORD<8> = "" THEN
* settled.y.n
        IF R.SC.SETTLEMENT<77> = '' THEN
            RECORD<8> = 'N'
        END ELSE
            RECORD<8> = 'Y'
        END
    END

    IF RECORD<9> = "" THEN
* Security number
        RECORD<9> = R.SC.SETTLEMENT<1>
    END

    IF RECORD<10> = "" THEN
* value date
        RECORD<10> = R.SC.SETTLEMENT<4>
    END

    RETURN

END
