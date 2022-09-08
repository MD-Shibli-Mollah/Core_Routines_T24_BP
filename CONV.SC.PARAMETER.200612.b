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
* <Rating>-46</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.Config
    SUBROUTINE CONV.SC.PARAMETER.200612(ID,RECORD,FILENAME)
*-----------------------------------------------------------------------------
* Correction/conversion routine for SC.PARAMETER
* the data in this record was wrong and is corrected here.
*-----------------------------------------------------------------------------
* Record routine for conversion details CONV.SC.PARAMETER.200612
* will populate field SM.PARAMETER (9) if any of the SC.PARAMETER records
* have a YES for location 67.
*-----------------------------------------------------------------------------
* Modification History :
*
* 14/12/06 - GLOBUS_BG_100012595
*            New subroutine
*
* 23/01/2007 - BG_100012831
*              New program
*
* 13/02/08 - GLOBUS_CI_10053569
*            Common variables defined in PRE.ROUTINE is not distributed
*            across multiple threads as PRE.ROUTINE is run only in a single thread,
*            hence system crashes while using these common variables.
*
* 10/12/08 - GLOBUS_CI_10059339
*            Conversion fails while running RUN.CONVERSION.PGMS
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
*----------------------------------------------------------------------------

* Correct the field name from I.S.I.N to I.S.I.N. to match the correct field
* name in security.master

    LAST.FOUR = FILENAME[4]   ;* BG_100012831 S
    IF LAST.FOUR = "$HIS" OR LAST.FOUR = "$NAU" THEN
* WE IGNORE THESE AS WE ONLY CARRY OVER THE LIVE RECORD SETTINGS
        NULL
    END ELSE
        GOSUB UPD.SM.PARAMETER
    END

    GOSUB UPD.SC.PARAMETER

    RETURN

*-----------------
UPD.SM.PARAMETER:
*-----------------

    GOSUB READ.SM.PARAMETER
    IF NOT(SM.ER) AND R.SM.PARAMETER<5> <> 'YES' AND RECORD<67> = 'YES' THEN
        R.SM.PARAMETER<5> = 'YES'
        IF R.SM.PARAMETER<21> = '' THEN
* No record set up yet, so add audit files
            X = OCONV(DATE(),'D4-')
            TIME.STAMP = TIMEDATE()
            DATE.TIME = X[9,2]:X[1,2]:X[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]
            R.SM.PARAMETER<17> = 1
            R.SM.PARAMETER<18> = TNO:'_CONV.SC.PARAMETER.200612'
            R.SM.PARAMETER<19> = DATE.TIME
            R.SM.PARAMETER<21> = ID.COMPANY
            R.SM.PARAMETER<22> = R.USER<6>
        END
        CALL F.WRITE(FN.SM.PARAMETER, "SYSTEM", R.SM.PARAMETER)
    END ELSE
        CALL F.RELEASE(FN.SM.PARAMETER, "SYSTEM", F.SM.PARAMETER)
    END

* Update the unauthorised file
    IF NOT(SM.NAU.ER) AND R.SM.PARAMETER<5> <> 'YES' AND RECORD<67> = 'YES' THEN
        R.SM.PARAMETER$NAU<5> = 'YES'
        CALL F.WRITE(FN.SM.PARAMETER$NAU, "SYSTEM", R.SM.PARAMETER$NAU)
    END ELSE
        CALL F.RELEASE(FN.SM.PARAMETER$NAU, "SYSTEM", F.SM.PARAMETER$NAU)
    END
    CALL JOURNAL.UPDATE("SYSTEM")

    RETURN

*-------------------
READ.SM.PARAMETER:
*-------------------

* Open the current company SM.PARAMETER file
    FN.SM.PARAMETER = 'F.SM.PARAMETER'
    F.SM.PARAMETER = ''
    CALL OPF(FN.SM.PARAMETER,F.SM.PARAMETER)

    R.SM.PARAMETER = ''; SM.ER = ''; RETRY = ''
    CALL F.READU(FN.SM.PARAMETER , "SYSTEM" , R.SM.PARAMETER , F.SM.PARAMETER, SM.ER, RETRY)

* Open the current company SM.PARAMETER$NAU file
    FN.SM.PARAMETER$NAU = 'F.SM.PARAMETER$NAU'
    F.SM.PARAMETER$NAU = ''
    CALL OPF(FN.SM.PARAMETER$NAU,F.SM.PARAMETER$NAU)

    R.SM.PARAMETER$NAU = ''; SM.NAU.ER = ''; RETRY = ''
    CALL F.READU(FN.SM.PARAMETER$NAU , "SYSTEM" , R.SM.PARAMETER$NAU , F.SM.PARAMETER$NAU, SM.NAU.ER, RETRY)

    RETURN

*------------------
UPD.SC.PARAMETER:
*------------------

    IF RECORD<25> = "I.S.I.N" THEN
        RECORD<25> = "I.S.I.N."
    END

    RECORD<67> = ''

    RETURN

END
