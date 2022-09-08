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
* <Rating>-8</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE TT.Contract
    SUBROUTINE CONV.TELLER.G14.1(ID,TT.REC,YFILE)
****************************************************************
*
* 26/09/08 - EN_10002015
*            Field position has been changed for certain fields
*            for which the data record has to be mapped properly.
*
* 20/10/03 - BG_100005437
*            Bug fix for Multivalue Teller. Field position in side.1
*            of TELLER transaction is changed to support Multivalue.
*******************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
    OLD.TT.REC = TT.REC
    NEW.TT.REC = TT.REC
*
*Forming New Array
*
    NEW.TT.REC<5>  = OLD.TT.REC<6>      ;*CUSTOMER.1
    NEW.TT.REC<6>  = OLD.TT.REC<5>      ;*ACCOUNT.1 is moved down
    NEW.TT.REC<8>  = OLD.TT.REC<9>      ;*AMOUNT.FCY.1 is moved up
    NEW.TT.REC<9>  = OLD.TT.REC<14>     ;*NARRATIVE.1 is moved up
    NEW.TT.REC<10> = OLD.TT.REC<8>      ;*RATE.1
    NEW.TT.REC<11> = OLD.TT.REC<10>     ;*VALUE.DATE.1
    NEW.TT.REC<12> = OLD.TT.REC<11>     ;*EXPOSURE.DATE.1
    NEW.TT.REC<13> = OLD.TT.REC<12>     ;*CURR.MARKET.1
    NEW.TT.REC<14> = OLD.TT.REC<13>     ;*POS.TYPE.1

*
    IF OLD.TT.REC<57> AND OLD.TT.REC<58> THEN     ;*if EXP.SPT.DAT & EXP.SPT.AMT is not null,
    IF OLD.TT.REC<3>[1,1] ='D' THEN        ;*check for DR.CR.MARKER, if debit  ;*BG_100005437 S/E
        NEW.TT.REC<56>=OLD.TT.REC<18>   ;*assign ACCOUNT.2 to EXP.ACCOUNT
	*BG_100005437 S
	END ELSE ;*else  
	NEW.TT.REC<56>=OLD.TT.REC<5>    ;*assign ACCOUNT.1 to EXP.ACCOUNT   
	END       
	;*BG_100005437 E
        NEW.TT.REC<57>=LOWER(OLD.TT.REC<57>)
        NEW.TT.REC<58>=LOWER(OLD.TT.REC<58>)
    END
*
    TT.REC = NEW.TT.REC
    RETURN
END
