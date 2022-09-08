* @ValidationCode : MjotMTI4MjcyMzAxODpDcDEyNTI6MTYxNTk3NjE0MDA1NzpnLm1hbGxpa2FyanVuYXJlZGR5Oi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMy4yMDIxMDMwMS0wNTU2Oi0xOi0x
* @ValidationInfo : Timestamp         : 17 Mar 2021 15:45:40
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : g.mallikarjunareddy
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210301-0556
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE LD.Schedules

SUBROUTINE LD.DEFAULT.RFR.MIGRATION.PROCESS (LD.ID,MAT R.CONTRACT, RFR.FIELDS, RESERVED2)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* This is a hook routine.
* This is used to migrate LIBOR to RFR contracts.
* Clients can write own logic here to assign RFR field values
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.LD.LOANS.AND.DEPOSITS
    
    RFR.FIELDS<1> ='LOOKBACK'  ;*Lookback
    RFR.FIELDS<2> ='NARROW'
    RFR.FIELDS<3> ='2'
    RFR.FIELDS<4> ='COMPOUND'
    RFR.FIELDS<5>='INCLUSIVE'
RETURN

END
