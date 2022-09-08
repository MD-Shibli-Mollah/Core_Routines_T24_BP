* @ValidationCode : MjotMjA3MTQ5MjE4OTpDcDEyNTI6MTU2NDU2MzIyMjcwNTpzcmF2aWt1bWFyOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDcuMjAxOTA2MTItMDMyMTotMTotMQ==
* @ValidationInfo : Timestamp         : 31 Jul 2019 14:23:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190612-0321
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-4</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.StmtPrinting
SUBROUTINE CONV.ACC.STMT.G13.1(ID,ACC.STMT.REC,YFILE)

* --------------------------------------------------------------------
* Description:
* ------------
*
* This is the CONVERSION routine for ACCOUNT.STATEMENT.
*
* --------------------------------------------------------------------
* Modification Log:
* -----------------
*
* 28/09/02 -  EN_10001345
*          - Conversion record for ACCOUNT.STATEMENT. Included 5 more fields
*
* 30/07/19 - Enhancement 3246717 / Task 3181742
*            TI Changes - Component moved from ST to AC.
*
* -----------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT.STATEMENT

*
* Assigning ACC.STMT.REC to TEMP.YREC, which will hold the old position
* of all the fields.
    TEMP.YREC = ACC.STMT.REC
    YREC = ''
*
* Re-assigning of data to appropriate fields(old) due to addition of new
* fields.
    YREC<1> = TEMP.YREC<1>
    YREC<2> = TEMP.YREC<4>
    YREC<3> = TEMP.YREC<5>
    YREC<4> = TEMP.YREC<6>
    YREC<5> = TEMP.YREC<7>
    YREC<6> = TEMP.YREC<8>
    YREC<7> = TEMP.YREC<9>
    YREC<8> = TEMP.YREC<10>
    YREC<9> = TEMP.YREC<11>
    YREC<10> = TEMP.YREC<12>
    YREC<11> = TEMP.YREC<15>
    YREC<12> = TEMP.YREC<17>
*
    YREC<21> = TEMP.YREC<16>
    YREC<22> = TEMP.YREC<18>
    YREC<23> = TEMP.YREC<19>
    YREC<24> = TEMP.YREC<20>
    YREC<25> = TEMP.YREC<21>
    YREC<26> = TEMP.YREC<22>
    YREC<27> = TEMP.YREC<23>
    YREC<28> = TEMP.YREC<24>
    YREC<29> = TEMP.YREC<25>
    YREC<30> = TEMP.YREC<26>
*
* Re-assigning data to the olds fields which are shifted further and also
* assigning values to new fields.
    IF TEMP.YREC<2> THEN
        IF TEMP.YREC<3> = 'SEPARATE' THEN
            YREC<13> = TEMP.YREC<2>
            YREC<14> = '2'
            YREC<16> = 'Y'
            YREC<19> = TEMP.YREC<15>
            YREC<20,1> = LOWER(TEMP.YREC<17>)
        END ELSE
            YREC<1,-1> = TEMP.YREC<2>
        END
    END
*
    YREC<15> = ''
    YREC<17> = TEMP.YREC<13>
    YREC<18> = TEMP.YREC<14>
*
* Re-assigning of data for AUDIT.FIELDS.
    YREC<31> = TEMP.YREC<27>
    YREC<32> = TEMP.YREC<28>
    YREC<33> = TEMP.YREC<29>
    YREC<34> = TEMP.YREC<30>
    YREC<35> = TEMP.YREC<31>
    YREC<36> = TEMP.YREC<32>
    YREC<37> = TEMP.YREC<33,1>
    YREC<38> = TEMP.YREC<33,2>
    YREC<39> = TEMP.YREC<35>
*
    ACC.STMT.REC = YREC
RETURN
END
