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
* <Rating>256</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctSecurityLending
    SUBROUTINE CONV.SC.BOND.LENT.MASTER.G15.0(ID.BLM, R.BLM, FN.BLM)
*
*-------------------------------------------------------------------------
* Conversion routine that reads all BOND.LENT.MASTER records and updates
* the relevant DEPOSITORY position for the portfolio, with the
* amount of stock lent, in the field NO.NOM.BOND.LENT. It also updates
* the LENDING.TYPE as 'PORTFOLIO' for existing contracts.
*-------------------------------------------------------------------------
* Modification History :
*
* 05/05/2004 - GLOBUS_EN_10002577
*              Conversion routine.
*
*-------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SECURITY.POSITION
*-------------------------------------------------------------------------

    GOSUB INITIALISE

    GOSUB UPDATE.POSITION

    RETURN

*-------------------------------------------------------------------------
UPDATE.POSITION:

* Transaction in history
    IF FIELD(ID.BLM,';',2) THEN RETURN

* Unauthorised txns does not hit Security positions
    IF R.BLM<35>[2,3] = 'NAU' THEN RETURN

* Loan returned.
    IF R.BLM<15> THEN RETURN

    R.SEC.POS = ''
    READ R.SEC.POS FROM FV.SECURITY.POSITION, DEPO.ID THEN
        R.SEC.POS<SC.SCP.NO.NOM.BOND.LENT> += R.BLM<8>
        WRITE R.SEC.POS TO FV.SECURITY.POSITION, DEPO.ID
    END

    RETURN

*-------------------------------------------------------------------------
INITIALISE:

    FN.SECURITY.POSITION = 'F.SECURITY.POSITION'
    FV.SECURITY.POSITION = ''
    CALL OPF(FN.SECURITY.POSITION, FV.SECURITY.POSITION)

    DEPO.ID = R.BLM<4>:'-':'999':'.'
    DEPO.ID := R.BLM<3>:'.'
    DEPO.ID := R.BLM<4>
    DEPO.ID := '....'

* Default Lending type to Portfolio for existing txns.
    R.BLM<1> = 'PORTFOLIO'

    RETURN

*-------------------------------------------------------------------------

END
