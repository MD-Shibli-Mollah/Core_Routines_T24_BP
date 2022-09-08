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
* <Rating>245</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE IC.InterestAndCapitalisation
    SUBROUTINE CONV.IC.CHARGE.FREQ.R06(ID, REC, FILE)

* REC<3> - CHARGE FREQUENCY
* REC<4> - CHARGE EFFECTIVE DATE
* REC<22> - COMPANY CODE
*******************************************************************************
* This conversion record routine will change the charge frequency
* format from M,Q,H,Y to <date><frequency>
*******************************************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE


    CALL LOAD.COMPANY(REC<22>) ;* Populate the TODAY value for that company

    IC.VALUE = 0

    LOOP
        IC.VALUE +=1
        CHRG.FREQ = REC<3,IC.VALUE> ;* Charge freq
    WHILE CHRG.FREQ

        IF INDEX("M_Q_H_Y",CHRG.FREQ,1) = 0 THEN
            CONTINUE
        END
        CHRG.EFFECTIVE.DATE = REC<4,IC.VALUE> ; * Charge effective date
        IF TODAY GT CHRG.EFFECTIVE.DATE THEN
            IC.CHARGE.MONTH = TODAY[5,2]
            IC.CHARGE.YEAR = TODAY[1,4]
        END ELSE
            IC.CHARGE.MONTH = CHRG.EFFECTIVE.DATE[5,2]
            IC.CHARGE.YEAR = CHRG.EFFECTIVE.DATE[1,4]
        END
        GOSUB GET.FREQ.CODE

        GOSUB GET.FREQ.DAY

        REC<3,IC.VALUE> = CHRG.FREQ:FREQCODE
        
    REPEAT

    RETURN
*-----------------------------------------------------------------------------

*** <region name= GET.FREQ.CODE>
GET.FREQ.CODE:
*** <desc> </desc>
    BEGIN CASE
        CASE CHRG.FREQ = 'M'
            FREQ.MM   = IC.CHARGE.MONTH
            FREQCODE = 'M0131'
        CASE CHRG.FREQ = 'Q'
            BEGIN CASE
                CASE IC.CHARGE.MONTH <= 3
                    FREQ.MM = '03'
                CASE IC.CHARGE.MONTH > 3 AND IC.CHARGE.MONTH <= 6
                    FREQ.MM = '06'
                CASE IC.CHARGE.MONTH > 6 AND IC.CHARGE.MONTH <= 9
                    FREQ.MM = '09'
                CASE 1
                    FREQ.MM = '12'
            END CASE
            FREQCODE = 'M0331'
        CASE CHRG.FREQ = 'H'
            IF IC.CHARGE.MONTH <= 6 THEN
                FREQ.MM = '06'
            END ELSE
                FREQ.MM = '12'
            END
            FREQCODE = 'M0631'
        CASE CHRG.FREQ = 'Y'
            FREQ.MM = '12'
            FREQCODE = 'M1231'
    END CASE
    
    RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.FREQ.DAY>
GET.FREQ.DAY:
*** <desc> </desc>

    CHRG.FREQ = IC.CHARGE.YEAR:FREQ.MM:'32'
    CALL CDT ('',CHRG.FREQ,'-1C')
    
    RETURN
*** </region>
*----------------------------------------------------------------------------

    END


