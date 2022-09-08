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
* <Rating>-7</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE IC.InterestAndCapitalisation
    SUBROUTINE CONV.ACCT.INTERIM.CHG.G14.2(ID, REC, FILE)
*===================================================================
* 19/01/2004 - EN_10002148
*              Conversion routine to shift down the data from 2nd position
*              to 3rd position and 3rd position to 4th position due to
*              the addition of new field CUSTOMER.NUMBER in
*              ACCT.INTERIM.CHG template.
*
*====================================================================
*               Insert files
*====================================================================
    $INSERT I_COMMON
    $INSERT I_EQUATE
*====================================================================
*               Main Section
*====================================================================
    OLD.REC = REC
    NEW.REC = ''

    *--- Re-assigning of data to the respective fields due to the addition of a new
    * field CUSTOMER.NUMBER.
    NEW.REC<1> = OLD.REC<1>   ;* ACCOUNT.NUMBER's position remains unchanged.
    *--- CUSTOMER.NUMBER is an associated multi-value field, so the null value
    * should be added with value marker dependiong upon the number of value marker
    * in ACCOUNT.NUMBER field.
    CNT = COUNT(NEW.REC<1>, VM) + 1
    FOR I = 1 TO CNT
        NEW.REC<2,I> = ''     ;* New field CUSTOMER.NUMBER in the 2nd position
    NEXT I
    NEW.REC<3> = OLD.REC<2>   ;* IC.CHARGE.CODE's position changed from 2 to 3
    NEW.REC<4> = OLD.REC<3>   ;* CHG.PRODUCTS's position changed from 3 to 4

    *--- Re-assigning of data for AUDIT.FIELDS.
    FOR I = 14 TO 22
        NEW.REC<I+1> = OLD.REC<I>
    NEXT I
    REC = NEW.REC
    RETURN
*====================================================================
END
