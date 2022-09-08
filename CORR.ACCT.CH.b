* @ValidationCode : MjotMTg3MDc4ODgxODpDcDEyNTI6MTU5OTY0MDU2NjI2MDpzYWlrdW1hci5tYWtrZW5hOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMy4wOi0xOi0x
* @ValidationInfo : Timestamp         : 09 Sep 2020 14:06:06
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : saikumar.makkena
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
*  <Rating>239</Rating>
*-----------------------------------------------------------------------------
$PACKAGE IC.InterestAndCapitalisation
SUBROUTINE CORR.ACCT.CH
REM "CORR.ACCT.CH",850725-001,"MAINPGM"
*
* GB9400210- 09-05-94
*            Allow equivalent currencies, initially for ZAR/ZAL processing
*
* GB9900332 - 19/03/99
*             ADDITION OF FIELDS FOR HIGHEST DEBIT CHARGE
*             ON CHARGE FREQUENCY.
*
* 18/09/02 - GLOBUS_EN_10001159
*          Conversion Of all Error Messages to Error Codes
*
* 04/10/10 - Task - 84420
*            Replace the enterprise(customer service api)code into  Banking framework related
*            routines which reads CUSTOMER.
*
* 08/08/19 - Enhancement 3266291 / Task 3266271
*            Changing reference of routines that have been moved from ST to CG********************************************************************

    $USING AC.AccountOpening
    $USING IC.Config
    $USING ST.Config
    $USING ST.Customer
    $USING CG.ChargeConfig
    $USING ST.CurrencyConfig
    $USING EB.Display
    $USING EB.TransactionControl
    $USING EB.ErrorProcessing
    $USING EB.Utility
    $USING EB.SystemTables
    $INSERT I_CustomerService_NameAddress

*************************************************************************
REM "DEFINE PGM NAME (BY USING 'C/CORR.ACCT.CH/.../G9999')
*========================================================================

    DIM F(EB.SystemTables.SysDim)
    DIM N(EB.SystemTables.SysDim)
    DIM T(EB.SystemTables.SysDim)
    DIM CHECKFILE(EB.SystemTables.SysDim)
    DIM CONCATFILE(EB.SystemTables.SysDim)

    MAT F = "" ; MAT N = "" ; MAT T = "" ; ID.T = ""
    MAT CHECKFILE = "" ; MAT CONCATFILE = ""
    ID.CHECKFILE = "" ; ID.CONCATFILE = ""
*========================================================================
REM "DEFINE PARAMETERS - SEE 'I_RULES'-DESCRIPTION:
    ID.F = "ACCT.NO.YEAR.MONTH" ; ID.N = "26.2" ; ID.T = "A"
    ID.T<4> = "R################ # ####-##" ; ID.T<2> = "ND" ; ID.T<7> = 2

    EB.SystemTables.SetIdProperties(ID.F,ID.N,ID.T,ID.CONCATFILE,ID.CHECKFILE)

* checkfile "ACCOUNT":FM:AC.CUSTOMER:FM:FM:"CUSTOMER":FM:EB.CUS.SHORT.NAME separately
    F(1) = "PERIOD.YEARM.FROM" ; N(1) = "7" ; T(1) = "YM"
    T(1)<4> = "R####-##"
    F(2) = "PERIOD.YEARM.TO" ; N(2) = "7" ; T(2) = "YM"
    T(2)<4> = "R####-##"
*------------------------------------------------------------------------
    F(3) = "BAL.REQU.CODE" ; N(3) = "2"
    CHECKFILE(3) = "BALANCE.REQUIREMENT":@FM:IC.Config.BalanceRequirement.BrqDescription:@FM:"L...YM"
    F(4) = "XX<BAL.REQU.YR.MTH" ; N(4) = "7" ; T(4) = "YM"
    T(4)<4> = "R####-##"
    F(5) = "XX-BAL.REQU.BAL" ; N(5) = "19" ; T(5) = "AMT":@FM:"-"
    F(6) = "XX>BAL.REQU.AMT" ; N(6) = "19"
    T(6) = "AMT":@FM:"-":@FM:@FM:@FM:"R"
    F(7) = "BAL.REQU.CATEG" ; N(7) = "6"
    T(7)<4> = "R##-###"
    CHECKFILE(7) = "CATEGORY":@FM:ST.Config.Category.EbCatDescription:@FM:"L"
    F(8) = "BAL.REQU.TRSDR" ; N(8) = "3"
    CHECKFILE(8) = "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
    F(9) = "BAL.REQU.TRSCR" ; N(9) = "3"
    CHECKFILE(9) = "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
*------------------------------------------------------------------------
    
    F(10) = "B.REQU.TAX.CODE" ; N(10) = "2"
    CHECKFILE(10) = "TAX":@FM:CG.ChargeConfig.Tax.EbTaxDescription:@FM:"L...D"
    F(11) = "XX<B.REQU.TAX.RATE" ; N(11) = "11" ; T(11) = "R"
    F(12) = "XX-B.REQU.TAX.AMT" ; N(12) = "19"
    T(12) = "AMT":@FM:"-":@FM:@FM:@FM:"R"
    F(13) = "XX-B.REQU.TAXCATEG" ; N(13) = "6"
    T(13)<4> = "R##-###"
    CHECKFILE(13) = "CATEGORY":@FM:ST.Config.Category.EbCatDescription:@FM:"L"
    F(14) = "XX-B.REQU.TAXTRSDR" ; N(14) = "3"
    CHECKFILE(14) = "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
    F(15) = "XX>B.REQU.TAXTRSCR" ; N(15) = "3"
    CHECKFILE(15) = "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
*------------------------------------------------------------------------
    F(16) = "NO.OF.CREDIT.CODE" ; N(16) = "2"
    CHECKFILE(16) = "NUMBER.OF.CREDIT":@FM:IC.Config.NumberOfCredit.NocDescription:@FM:"L...YM"
    F(17) = "XX<NO.CRED.YR.MTH" ; N(17) = "7" ; T(17) = "YM"
    T(17)<4> = "R####-##"
    F(18) = "XX-NO.CR.TRANSACT" ; N(18) = "6"
    F(19) = "XX-NO.CR.CHARGE" ; N(19) = "19" ; T(19) = "AMT":@FM:"-"
    F(20) = "XX-NO.CR.FREE" ; N(20) = "19" ; T(20) = "AMT":@FM:"-"
    F(21) = "XX-NO.CR.MIN.MAX" ; N(21) = "7"
    T(21) = @FM:"MAXIMUM_MINIMUM"
    F(22) = "XX>NO.CR.AMT" ; N(22) = "19"
    T(22) = "AMT":@FM:"-":@FM:@FM:@FM:"R"
    F(23) = "NO.CRED.CATEG" ; N(23) = "6"
    T(23)<4> = "R##-###"
    CHECKFILE(23) = "CATEGORY":@FM:ST.Config.Category.EbCatDescription:@FM:"L"
    F(24) = "NO.CRED.TRSDR" ; N(24) = "3"
    CHECKFILE(24) = "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
    F(25) = "NO.CRED.TRSCR" ; N(25) = "3"
    CHECKFILE(25) = "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
*------------------------------------------------------------------------
    F(26) = "NO.CR.TAX.CODE" ; N(26) = "2"
    CHECKFILE(26) = "TAX":@FM:CG.ChargeConfig.Tax.EbTaxDescription:@FM:"L...D"
    F(27) = "XX<NO.CR.TAX.RATE" ; N(27) = "11" ; T(27) = "R"
    F(28) = "XX-NO.CR.TAX.AMT" ; N(28) = "19"
    T(28) = "AMT":@FM:"-":@FM:@FM:@FM:"R"
    F(29) = "XX-NO.CR.TAXCATEG" ; N(29) = "6"
    T(29)<4> = "R##-###"
    CHECKFILE(29) = "CATEGORY":@FM:ST.Config.Category.EbCatDescription:@FM:"L"
    F(30) = "XX-NO.CR.TAXTRSDR" ; N(30) = "3"
    CHECKFILE(30) = "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
    F(31) = "XX>NO.CR.TAXTRSCR" ; N(31) = "3"
    CHECKFILE(31) = "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
*------------------------------------------------------------------------
    F(32) = "NO.OF.DEBIT.CODE" ; N(32) = "2"
    CHECKFILE(32) = "NUMBER.OF.DEBIT":@FM:IC.Config.NumberOfDebit.NodDescription:@FM:"L...YM"
    F(33) = "XX<NO.DEBIT.YR.MTH" ; N(33) = "7" ; T(33) = "YM"
    T(33)<4> = "R####-##"
    F(34) = "XX-NO.DR.TRANSACT" ; N(34) = "7"
    F(35) = "XX-NO.DR.CHARGE" ; N(35) = "18" ; T(35) = "AMT":@FM:"-"
    F(36) = "XX-NO.DR.FREE" ; N(36) = "19" ; T(36) = "AMT":@FM:"-"
    F(37) = "XX-NO.DR.MIN.MAX" ; N(37) = "7"
    T(37) = @FM:"MAXIMUM_MINIMUM"
    F(38) = "XX>NO.DR.AMT" ; N(38) = "19"
    T(38) = "AMT":@FM:"-":@FM:@FM:@FM:"R"
    F(39) = "NO.DEBIT.CATEG" ; N(39) = "6"
    T(39)<4> = "R##-###"
    CHECKFILE(39) = "CATEGORY":@FM:ST.Config.Category.EbCatDescription:@FM:"L"
    F(40) = "NO.DEBIT.TRSDR" ; N(40) = "3"
    CHECKFILE(40) = "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
    F(41) = "NO.DEBIT.TRSCR" ; N(41) = "3"
    CHECKFILE(41) = "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
*------------------------------------------------------------------------
    F(42) = "NO.DR.TAX.CODE" ; N(42) = "2"
    CHECKFILE(42) = "TAX":@FM:CG.ChargeConfig.Tax.EbTaxDescription:@FM:"L...D"
    F(43) = "XX<NO.DR.TAX.RATE" ; N(43) = "11" ; T(43) = "R"
    F(44) = "XX-NO.DR.TAX.AMT" ; N(44) = "19"
    T(44) = "AMT":@FM:"-":@FM:@FM:@FM:"R"
    F(45) = "XX-NO.DR.TAXCATEG" ; N(45) = "6"
    T(45)<4> = "R##-###"
    CHECKFILE(45) = "CATEGORY":@FM:ST.Config.Category.EbCatDescription:@FM:"L"

    F(46) = "XX-NO.DR.TAXTRSDR" ; N(46) = "3"
    CHECKFILE(46) = "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
    F(47) = "XX>NO.DR.TAXTRSCR" ; N(47) = "3"
    CHECKFILE(47) = "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
*------------------------------------------------------------------------
    F(48) = "TURNOVER.CR.CODE" ; N(48) = "2"
    CHECKFILE(48) = "TURNOVER.CREDIT":@FM:IC.Config.TurnoverCredit.TcrDescription:@FM:"L...YM"
    F(49) = "XX<TURN.CR.YR.MTH" ; N(49) = "7" ; T(49) = "YM"
    T(49)<4> = "R####-##"
    F(50) = "XX-TURN.CR.TOTAL" ; N(50) = "19" ; T(50) = "AMT":@FM:"-"
    F(51) = "XX-TURN.CR.PERCT" ; N(51) = "11" ; T(51) = "R"
    F(52) = "XX-TURN.CR.FREE" ; N(52) = "19" ; T(52) = "AMT":@FM:"-"
    F(53) = "XX-TURN.CR.MIN.MAX" ; N(53) = "7"
    T(53) = @FM:"MAXIMUM_MINIMUM"
    F(54) = "XX>TURN.CREDIT.AMT" ; N(54) = "19"
    T(54) = "AMT":@FM:"-":@FM:@FM:@FM:"R"
    F(55) = "TURN.CREDIT.CATEG" ; N(55) = "6"
    T(55)<4> = "R##-###"
    CHECKFILE(55) = "CATEGORY":@FM:ST.Config.Category.EbCatDescription:@FM:"L"
    F(56) = "TURN.CREDIT.TRSDR" ; N(56) = "3"
    CHECKFILE(56) = "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
    F(57) = "TURN.CREDIT.TRSCR" ; N(57) = "3"
    CHECKFILE(57) = "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
*------------------------------------------------------------------------
    F(58) = "TURN.CR.TAX.CODE" ; N(58) = "2"
    CHECKFILE(58) = "TAX":@FM:CG.ChargeConfig.Tax.EbTaxDescription:@FM:"L...D"
    F(59) = "XX<TURN.CR.TAX.RTE" ; N(59) = "11" ; T(59) = "R"
    F(60) = "XX-TURN.CR.TAX.AMT" ; N(60) = "19"
    T(60) = "AMT":@FM:"-":@FM:@FM:@FM:"R"
    F(61) = "XX-TRN.CR.TAXCATEG" ; N(61) = "6"
    T(61)<4> = "R##-###"
    CHECKFILE(61) = "CATEGORY":@FM:ST.Config.Category.EbCatDescription:@FM:"L"
    F(62) = "XX-TRN.CR.TAXTRSDR" ; N(62) = "3"
    CHECKFILE(62) = "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
    F(63) = "XX>TRN.CR.TAXTRSCR" ; N(63) = "3"
    CHECKFILE(63) = "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
*------------------------------------------------------------------------
    F(64) = "TURNOVER.DR.CODE" ; N(64) = "2"
    CHECKFILE(64) = "TURNOVER.DEBIT":@FM:IC.Config.TurnoverDebit.TdeDescription:@FM:"L...YM"
    F(65) = "XX<TURN.DR.YR.MTH" ; N(65) = "7" ; T(65) = "YM"
    T(65)<4> = "R####-##"
    F(66) = "XX-TURN.DR.TOTAL" ; N(66) = "19" ; T(66) = "AMT":@FM:"-"
    F(67) = "XX-TURN.DR.PERCT" ; N(67) = "11" ; T(67) = "R"
    F(68) = "XX-TURN.DR.FREE" ; N(68) = "19" ; T(68) = "AMT":@FM:"-"
    F(69) = "XX-TURN.DR.MIN.MAX" ; N(69) = "7"
    T(69) = @FM:"MAXIMUM_MINIMUM"
    F(70) = "XX>TURN.DEBIT.AMT" ; N(70) = "19"
    T(70) = "AMT":@FM:"-":@FM:@FM:@FM:"R"
    F(71) = "TURN.DEBIT.CATEG" ; N(71) = "6"
    T(71)<4> = "R##-###"
    CHECKFILE(71) = "CATEGORY":@FM:ST.Config.Category.EbCatDescription:@FM:"L"
    F(72) = "TURN.DEBIT.TRSDR" ; N(72) = "3"
    CHECKFILE(72) = "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
    F(73) = "TURN.DEBIT.TRSCR" ; N(73) = "3"
    CHECKFILE(73) = "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
*------------------------------------------------------------------------
    F(74) = "TURN.DR.TAX.CODE" ; N(74) = "2"
    CHECKFILE(74) = "TAX":@FM:CG.ChargeConfig.Tax.EbTaxDescription:@FM:"L...D"
    F(75) = "XX<TURN.DR.TAX.RTE" ; N(75) = "11" ; T(75) = "R"
    F(76) = "XX-TURN.DR.TAX.AMT" ; N(76) = "19"
    T(76) = "AMT":@FM:"-":@FM:@FM:@FM:"R"
    F(77) = "XX-TRN.DR.TAXCATEG" ; N(77) = "6"
    T(77)<4> = "R##-###"
    CHECKFILE(77) = "CATEGORY":@FM:ST.Config.Category.EbCatDescription:@FM:"L"
    F(78) = "XX-TRN.DR.TAXTRSDR" ; N(78) = "3"
    CHECKFILE(78) = "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
    F(79) = "XX>TRN.DR.TAXTRSCR" ; N(79) = "3"
    CHECKFILE(79) = "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
*------------------------------------------------------------------------
    F(80) = "XX<TRCHARGE.YR.MTH" ; N(80) = "7" ; T(80) = "YM"
    T(80)<4> = "R####-##"
    F(81) = "XX-XX<TRCH.CODE" ; N(81) = "3"
    CHECKFILE(81) = "TRANSACTION.CHARGE":@FM:IC.Config.TransactionCharge.TchDescription:@FM:"L...D"
    F(82) = "XX-XX-NO.TRANSACT" ; N(82) = "6"
    F(83) = "XX-XX-TRANS.CHARGE" ; N(83) = "19" ; T(83) = "AMT":@FM:"-"
    F(84) = "XX-XX-TRCH.PERCTG" ; N(84) = "11" ; T(84) = "R"
    F(85) = "XX-XX-TRANS.TURNOV" ; N(85) = "19" ; T(85) = "AMT":@FM:"-"
    F(86) = "XX-XX-TRCH.FREE" ; N(86) = "19" ; T(86) = "AMT":@FM:"-"
    F(87) = "XX-XX-TRCH.MIN.MAX" ; N(87) = "7"
    T(87) = @FM:"MAXIMUM_MINIMUM"
    F(88) = "XX-XX-TRCHARGE.AMT" ; N(88) = "19"
    T(88) = "AMT":@FM:"-":@FM:@FM:@FM:"R"
    F(89) = "XX-XX-TRCH.CATEG" ; N(89) = "6"
    T(89)<4> = "R##-###"
    CHECKFILE(89) = "CATEGORY":@FM:ST.Config.Category.EbCatDescription:@FM:"L"
    F(90) = "XX-XX-TRCH.TRSDR" ; N(90) = "3"
    CHECKFILE(90) = "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
    F(91) = "XX>XX>TRCH.TRSCR" ; N(91) = "3"
    CHECKFILE(91) = "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
*------------------------------------------------------------------------
    F(92) = "COMTRS.CHARGE.CODE" ; N(92) = "3"
    CHECKFILE(92) = "TRANSACTION.CHARGE":@FM:IC.Config.TransactionCharge.TchDescription:@FM:"L...D"
    F(93) = "XX<COMTRS.YR.MTH" ; N(93) = "7" ; T(93) = "YM"
    T(93)<4> = "R####-##"
    F(94) = "XX-COMTRS.FREE" ; N(94) = "19" ; T(94) = "AMT":@FM:"-"
    F(95) = "XX-COMTRS.MIN.MAX" ; N(95) = "7"
    T(95) = @FM:"MAXIMUM_MINIMUM"
    F(96) = "XX>COMTRS.AMT" ; N(96) = "19"
    T(96) = "AMT":@FM:"-":@FM:@FM:@FM:"R"
    F(97) = "COMTRANSACT.CATEG" ; N(97) = "6"
    T(97)<4> = "R##-###"
    CHECKFILE(97) = "CATEGORY":@FM:ST.Config.Category.EbCatDescription:@FM:"L"
    F(98) = "COMTRANSACT.TRSDR" ; N(98) = "3"
    CHECKFILE(98) = "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
    F(99) = "COMTRANSACT.TRSCR" ; N(99) = "3"
    CHECKFILE(99) = "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
*------------------------------------------------------------------------
    F(100)= "XX<TRCH.TAX.CODE" ; N(100)= "2"
    CHECKFILE(100)= "TAX":@FM:CG.ChargeConfig.Tax.EbTaxDescription:@FM:"L...D"
    F(101)= "XX-XX<TR.TAX.RATE" ; N(101)= "11" ; T(101)= "R"
    F(102)= "XX-XX-TR.TAX.AMT" ; N(102)= "19"
    T(102)= "AMT":@FM:"-":@FM:@FM:@FM:"R"
    F(103)= "XX-XX-TR.TAXCATEG" ; N(103)= "6"
    T(103)<4> = "R##-###"
    CHECKFILE(103)= "CATEGORY":@FM:ST.Config.Category.EbCatDescription:@FM:"L"
    F(104)= "XX-XX-TR.TAXTRSDR" ; N(104)= "3"
    CHECKFILE(104)= "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
    F(105)= "XX>XX>TR.TAXTRSCR" ; N(105)= "3"
    CHECKFILE(105)= "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
*------------------------------------------------------------------------
    F(106)= "XX<TOTAL.CH.YR.MTH" ; N(106)= "7" ; T(106)= "YM"
    T(106)<4> = "R####-##"
    F(107)= "XX>TOTAL.CH.AMT" ; N(107)= "19"
    T(107)= "AMT":@FM:"-":@FM:@FM:@FM:"R"
    F(108)= "TOTAL.CH.CATEG" ; N(108)= "6"
    T(108)<4> = "R##-###"
    CHECKFILE(108)= "CATEGORY":@FM:ST.Config.Category.EbCatDescription:@FM:"L"
    F(109)= "TOTAL.CH.TRSDR" ; N(109)= "3"
    CHECKFILE(109)= "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
    F(110)= "TOTAL.CH.TRSCR" ; N(110)= "3"
    CHECKFILE(110)= "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
*------------------------------------------------------------------------
    F(111)= "TOTAL.CH.TAX.CODE" ; N(111)= "2"
    CHECKFILE(111)= "TAX":@FM:CG.ChargeConfig.Tax.EbTaxDescription:@FM:"L...D"
    F(112)= "XX<TOT.CH.TAX.RATE" ; N(112)= "11" ; T(112)= "R"
    F(113)= "XX-TOT.CH.TAX.AMT" ; N(113)= "19"
    T(113)= "AMT":@FM:"-":@FM:@FM:@FM:"R"
    F(114)= "XX-TOT.CH.TAXCATEG" ; N(114)= "6"
    T(114)<4> = "R##-###"
    CHECKFILE(114)= "CATEGORY":@FM:ST.Config.Category.EbCatDescription:@FM:"L"
    F(115)= "XX-TOT.CH.TAXTRSDR" ; N(115)= "3"
    CHECKFILE(115)= "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
    F(116)= "XX>TOT.CH.TAXTRSCR" ; N(116)= "3"
    CHECKFILE(116)= "TRANSACTION":@FM:ST.Config.Transaction.AcTraNarrative:@FM:"L"
*------------------------------------------------------------------------
    F(117)= "CHARGE.CODE.LEVEL" ; N(117)= "3" ; T(117)= @FM:"COM_IND"
    F(118)= "OFFSET.RATE" ; N(118)= "11" ; T(118)= "R"
    F(119)= "XX<OFFSET.YR.MTH" ; N(119)= "7" ; T(119)= "YM"
    T(119)<4> = "R####-##"
    F(120)= "XX-BALANCE.OFFSET" ; N(120)= "19" ; T(120)= "AMT":@FM:"-"
    F(121)= "XX>AMOUNT.OFFSET" ; N(121)= "19" ; T(121)= "AMT":@FM:"-"
*------------------------------------------------------------------------
* GB9900332+698 (Starts)
*
    Z = 121
*
    Z+=1 ; F(Z) = "HIGHEST.DR.CODE" ; N(Z) = "2" ; T(Z) = ""
    Z+=1 ; F(Z) = "XX<HI.DR.YR.MTH" ; N(Z) = "8" ; T(Z) = ""
    Z+=1 ; F(Z) = "XX-HIGHEST.DR.BAL" ; N(Z) = "19" ; T(Z) = "AMT"
    Z+=1 ; F(Z) = "XX>HIGHEST.DR.AMT" ; N(Z) = "19" ; T(Z) = "AMT"
    Z+=1 ; F(Z) = "HIGH.DR.CATEG" ; N(Z) = "5" ; T(Z) = ""
    Z+=1 ; F(Z) = "HIGH.DR.TRSDR" ; N(Z) = "3" ; T(Z) = ""
    Z+=1 ; F(Z) = "HIGH.DR.TRSCR" ; N(Z) = "3" ; T(Z) = ""
    Z+=1 ; F(Z) = "HIGHEST.DR.PERC" ; N(Z) = '11' ; T(Z) = 'R'
    Z+=1 ; F(Z) = "HIGHEST.DR.FREE" ; N(Z) = "19" ; T(Z) = "AMT"
    Z+=1 ; F(Z) = "HIGH.DR.MIN.MAX" ; N(Z) = "7" ; T(Z) = "A"
    Z+=1 ; F(Z) = "HI.DR.TAX.CODE" ; N(Z) = "2" ; T(Z) = ""
    Z+=1 ; F(Z) = "XX<HI.DR.TAX.RATE" ; N(Z) = "11" ; T(Z) = "R"
    Z+=1 ; F(Z) = "XX>HI.DR.TAX.AMT" ; N(Z) = "19" ; T(Z) = "AMT"
    Z+=1 ; F(Z) = "HI.DR.TAXCATEG" ; N(Z) = "5" ; T(Z) = ""
    Z+=1 ; F(Z) = "HI.DR.TAX.TRSDR" ; N(Z) = "3" ; T(Z) = ""
    Z+=1 ; F(Z) = "HI.DR.TAX.TRSCR" ; N(Z) = "3" ; T(Z) = ""
*
* GB9900332+698 (Ends)
*
    Z+=1 ; F(Z)= "LIQUIDITY.ACCOUNT" ; N(Z)= "16" ; T(Z)= "ACC"
    CHECKFILE(Z)= "ACCOUNT":@FM:AC.AccountOpening.Account.Customer:@FM:@FM:"CUSTOMER":@FM:ST.Customer.Customer.EbCusShortName
    Z+=1 ; F(Z)= "XX.COMPENS.ACCOUNT" ; N(Z)= "16" ; T(Z)= "ACC"
    CHECKFILE(Z)= "ACCOUNT":@FM:AC.AccountOpening.Account.Customer:@FM:@FM:"CUSTOMER":@FM:ST.Customer.Customer.EbCusShortName
    Z+=1 ; F(Z)= "INT.NO.BOOKING" ; N(Z)= "8" ; T(Z)= @FM:"SUSPENSE_Y"
    Z+=1 ; F(Z)= "USED.MIDDLE.RATE" ; N(Z)= "11" ; T(Z)= "R"
*------------------------------------------------------------------------
    Z+=1 ; F(Z)= "TOTAL.CHARGE" ; N(Z)="19"
    T(Z)= "AMT":@FM:"-":@FM:@FM:@FM:"R"
    Z+=1 ; F(Z)= "TOTAL.TAX" ; N(Z)="19"
    T(Z)= "AMT":@FM:"-":@FM:@FM:@FM:"R"
    Z+=1 ; F(Z)= "GRAND.TOTAL" ; N(Z)="19"
    T(Z)= "AMT":@FM:"-":@FM:@FM:@FM:"R"
    Z+=1 ; F(Z)= "LAST.CORRECTION.NO" ; N(Z)= "3"
* GB9400210
* GB9800300 (Starts)
    Z+=1 ; F(Z) = "DEFERRED.DATE" ; N(Z) = "11"
    T(Z)<1> = "D"
* GB9800300 (Ends)
*
    Z += 1 ; F(Z) = 'LIQUIDITY.CCY' ; N(Z) = '03'
    T(Z) = 'CCY'
    CHECKFILE(Z) = "CURRENCY":@FM:ST.CurrencyConfig.Currency.EbCurCcyName:@FM:'L.A'
    V = Z

    EB.SystemTables.SetFieldProperties(MAT F, MAT N, MAT T,MAT CONCATFILE,MAT CHECKFILE, V)

    EB.SystemTables.setPrefix("IC.CORCH")
*========================================================================
    V$FUNCTION.VAL = EB.SystemTables.getVFunction()
    IF LEN(V$FUNCTION.VAL) > 1 THEN
        ID.R.VAL = ''
        ID.R.VAL = "aa) Input 2-16 numeric char. (incl. checkdigit) "
        ID.R.VAL = ID.R.VAL:"ACCOUNT.NUMBER or":@FM
        ID.R.VAL = ID.R.VAL:"ab) Input 3-10 MNEMONIC char. (will "
        ID.R.VAL = ID.R.VAL:"be converted to ACCOUNT.NUMBER) and":@FM
        ID.R.VAL = ID.R.VAL:"b) '/' and":@FM
        ID.R.VAL = ID.R.VAL:"c) 1-9 date char. and":@FM
        ID.R.VAL = ID.R.VAL:"d) current number (00)1...999":@FM
        ID.R.VAL = ID.R.VAL:"No input b,c) = today's date":@FM
        ID.R.VAL = ID.R.VAL:"No input b,c,d) = current number 1":@FM
        ID.R.VAL = ID.R.VAL:"ACCOUNT.NUMBER must be an ID of ACCOUNT-record "
        ID.R.VAL = ID.R.VAL:"and relate to an ID of a CUSTOMER-record"
        EB.SystemTables.setIdR(ID.R.VAL)
        EB.SystemTables.setR(6, "Amount for information only, when field TOTAL.CH.AMT ")
        EB.SystemTables.setR(6, EB.SystemTables.getR(6):"used")
        EB.SystemTables.setR(22, "Amount for information only, when field TOTAL.CH.AMT ")
        EB.SystemTables.setR(22, EB.SystemTables.getR(22):"used")
        EB.SystemTables.setR(38, "Amount for information only, when field TOTAL.CH.AMT ")
        EB.SystemTables.setR(38, EB.SystemTables.getR(38):"used")
        EB.SystemTables.setR(54, "Amount for information only, when field TOTAL.CH.AMT ")
        EB.SystemTables.setR(54, EB.SystemTables.getR(54):"used")
        EB.SystemTables.setR(70, "Amount for information only, when field TOTAL.CH.AMT ")
        EB.SystemTables.setR(70, EB.SystemTables.getR(70):"used")
        EB.SystemTables.setR(88, "Amount for information only, when field COMTRS.AMT ")
        EB.SystemTables.setR(88, EB.SystemTables.getR(88):"or TOTAL.CH.AMT used")
        EB.SystemTables.setR(96, "Amount for information only, when field TOTAL.CH.AMT ")
        EB.SystemTables.setR(96, EB.SystemTables.getR(96):"used")
        RETURN
* RETURN when pgm used to get parameters only
    END
*------------------------------------------------------------------------
    EB.Display.MatrixUpdate()
*------------------------------------------------------------------------
ID.INPUT:
    EB.TransactionControl.RecordidInput()
    IF EB.SystemTables.getMessage() = "RET" THEN RETURN
* return to PGM.SELECTION
    IF EB.SystemTables.getMessage() = "NEW FUNCTION" THEN
*========================================================================
REM "CHECK FUNCTION:
        IF EB.SystemTables.getVFunction() = "V" THEN
            EB.SystemTables.setE("IC.RTN.NO.FUNT.APP.1"); EB.SystemTables.setVFunction("")
ID.ERROR:
            EB.ErrorProcessing.Err() ; GOTO ID.INPUT
        END
*========================================================================
        IF EB.SystemTables.getVFunction() = "E" OR EB.SystemTables.getVFunction() = "L" THEN
            EB.Display.FunctionDisplay() ; EB.SystemTables.setVFunction("")
        END
        GOTO ID.INPUT
    END
*========================================================================
REM "CHECK ID OR CHANGE STANDARD ID:
    COMI.VAL = EB.SystemTables.getComi()
    CONVERT "-" TO "" IN COMI.VAL
    EB.SystemTables.setComi(COMI.VAL)
* cancel '-' (part of mask only)
    COMI2 = FIELD(COMI.VAL,"-",2,99) ; EB.SystemTables.setComi(FIELD(COMI.VAL,"-",1))
    AC.AccountOpening.InTwoacc(16.2,"ACC")
    IF EB.SystemTables.getEtext()<> "" THEN EB.SystemTables.setE(EB.SystemTables.getEtext()); GOTO ID.ERROR
    YACCOUNT = EB.SystemTables.getComi() ; EB.SystemTables.setIdNew(EB.SystemTables.getComi():"-"); EB.SystemTables.setComi(COMI2)
    IF EB.SystemTables.getComi() = "" THEN
        YDATE = EB.SystemTables.getToday() ; YNO = 1
    END ELSE
        COMI.VAL = EB.SystemTables.getComi()
        X = LEN(COMI.VAL)
        IF X < 4 THEN
            YNO = COMI.VAL ; YDATE = EB.SystemTables.getToday()
        END ELSE
            EB.SystemTables.setComi(COMI.VAL : '01')
            EB.Utility.InTwod(8,"D")
            COMI.VAL = EB.SystemTables.getComi()
            EB.SystemTables.setComi(COMI.VAL[1,(LEN(COMI.VAL)-2)])
            IF EB.SystemTables.getEtext()<> "" THEN EB.SystemTables.setE(EB.SystemTables.getEtext()); GOTO ID.ERROR
        END
    END
    COMI.VAL = EB.SystemTables.getComi()
    ID.NEW.VAL = EB.SystemTables.getIdNew()
    EB.SystemTables.setVDisplay(TRIMF(FMT(ID.NEW.VAL,"R################ # "):COMI.VAL[7,2]:" ":FIELD(EB.SystemTables.getTRemtext(19)," ",COMI.VAL[5,2]):" ":COMI.VAL[1,4]))
    EB.SystemTables.setIdNew(ID.NEW.VAL:COMI.VAL)
    CUSTOMER.NO = ''
    ERR = ''
    R.REC = ''
    R.REC = AC.AccountOpening.Account.Read(YACCOUNT, ERR)
    CUSTOMER.NO = R.REC<AC.AccountOpening.Account.Customer>
    EB.SystemTables.setEtext(ERR)
* get the SHORT.NAME of customer related to account
    customerId = CUSTOMER.NO
    customerName = ''
    prefLang = EB.SystemTables.getLngg()
    CALL CustomerService.getNameAddress(customerId, prefLang, customerName)

    IF EB.SystemTables.getEtext()<> "" THEN
        EB.SystemTables.setE(EB.SystemTables.getEtext())
        GOTO ID.ERROR
    END
* assigned customer's short name to ID.ENRI varible to get enrichment to id.
    EB.SystemTables.setIdEnri(customerName<NameAddress.shortName>)

    YCCY = ""
    ERR = ''
    R.REC = ''
    R.REC = AC.AccountOpening.Account.Read(YACCOUNT, ERR)
    YCCY = R.REC<AC.AccountOpening.Account.Currency>
    EB.SystemTables.setEtext(ERR)
    LINE.CNT = DCOUNT(YCCY,@VM)
    FULL.STR = ''
    FOR CNT = 1 TO LINE.CNT
        LNGG.CODE = EB.SystemTables.getLngg()
        IF LNGG.CODE > 1 THEN IF YCCY<1,CNT,LNGG.CODE> = "" THEN LNGG.CODE = 1
        FULL.STR = FULL.STR:' ':YCCY<1,CNT,LNGG.CODE>
    NEXT CNT
    YCCY = TRIM(FULL.STR)
    IF ERR <> "" THEN
        EB.SystemTables.setE(ERR)
        GOTO ID.ERROR
    END
    tmp=EB.SystemTables.getT(5); tmp<2,2>=YCCY; EB.SystemTables.setT(5, tmp); tmp=EB.SystemTables.getT(6); tmp<2,2>=YCCY; EB.SystemTables.setT(6, tmp); tmp=EB.SystemTables.getT(12); tmp<2,2>=YCCY; EB.SystemTables.setT(12, tmp)
    tmp=EB.SystemTables.getT(19); tmp<2,2>=YCCY; EB.SystemTables.setT(19, tmp); tmp=EB.SystemTables.getT(20); tmp<2,2>=YCCY; EB.SystemTables.setT(20, tmp); tmp=EB.SystemTables.getT(22); tmp<2,2>=YCCY; EB.SystemTables.setT(22, tmp)
    tmp=EB.SystemTables.getT(28); tmp<2,2>=YCCY; EB.SystemTables.setT(28, tmp); tmp=EB.SystemTables.getT(35); tmp<2,2>=YCCY; EB.SystemTables.setT(35, tmp); tmp=EB.SystemTables.getT(36); tmp<2,2>=YCCY; EB.SystemTables.setT(36, tmp)
    tmp=EB.SystemTables.getT(38); tmp<2,2>=YCCY; EB.SystemTables.setT(38, tmp); tmp=EB.SystemTables.getT(44); tmp<2,2>=YCCY; EB.SystemTables.setT(44, tmp); tmp=EB.SystemTables.getT(50); tmp<2,2>=YCCY; EB.SystemTables.setT(50, tmp)
    tmp=EB.SystemTables.getT(52); tmp<2,2>=YCCY; EB.SystemTables.setT(52, tmp); tmp=EB.SystemTables.getT(54); tmp<2,2>=YCCY; EB.SystemTables.setT(54, tmp); tmp=EB.SystemTables.getT(60); tmp<2,2>=YCCY; EB.SystemTables.setT(60, tmp)
    tmp=EB.SystemTables.getT(66); tmp<2,2>=YCCY; EB.SystemTables.setT(66, tmp); tmp=EB.SystemTables.getT(68); tmp<2,2>=YCCY; EB.SystemTables.setT(68, tmp); tmp=EB.SystemTables.getT(70); tmp<2,2>=YCCY; EB.SystemTables.setT(70, tmp)
    tmp=EB.SystemTables.getT(76); tmp<2,2>=YCCY; EB.SystemTables.setT(76, tmp); tmp=EB.SystemTables.getT(83); tmp<2,2>=YCCY; EB.SystemTables.setT(83, tmp); tmp=EB.SystemTables.getT(85); tmp<2,2>=YCCY; EB.SystemTables.setT(85, tmp)
    tmp=EB.SystemTables.getT(86); tmp<2,2>=YCCY; EB.SystemTables.setT(86, tmp); tmp=EB.SystemTables.getT(88); tmp<2,2>=YCCY; EB.SystemTables.setT(88, tmp); tmp=EB.SystemTables.getT(94); tmp<2,2>=YCCY; EB.SystemTables.setT(94, tmp)
    tmp=EB.SystemTables.getT(96); tmp<2,2>=YCCY; EB.SystemTables.setT(96, tmp); tmp=EB.SystemTables.getT(102); tmp<2,2>=YCCY; EB.SystemTables.setT(102, tmp); tmp=EB.SystemTables.getT(107); tmp<2,2>=YCCY; EB.SystemTables.setT(107, tmp)
    tmp=EB.SystemTables.getT(113); tmp<2,2>=YCCY; EB.SystemTables.setT(113, tmp); tmp=EB.SystemTables.getT(120); tmp<2,2>=YCCY; EB.SystemTables.setT(120, tmp); tmp=EB.SystemTables.getT(121); tmp<2,2>=YCCY; EB.SystemTables.setT(121, tmp)
    tmp=EB.SystemTables.getT(126); tmp<2,2>=YCCY; EB.SystemTables.setT(126, tmp); tmp=EB.SystemTables.getT(127); tmp<2,2>=YCCY; EB.SystemTables.setT(127, tmp); tmp=EB.SystemTables.getT(128); tmp<2,2>=YCCY; EB.SystemTables.setT(128, tmp)
* update 'AMT'-Type with Currency
*========================================================================
    EB.TransactionControl.RecordRead()
    IF EB.SystemTables.getMessage() = "REPEAT" THEN GOTO ID.INPUT
    EB.Display.MatrixAlter()
*========================================================================
REM "SPECIAL CHECKS OR CHANGE FIELDS AFTER READING RECORD(S):
*========================================================================
FIELD.DISPLAY.OR.INPUT:
    IF EB.SystemTables.getScreenMode() = "MULTI" THEN EB.Display.FieldMultiDisplay()
    ELSE EB.Display.FieldDisplay()
*------------------------------------------------------------------------
    GOTO ID.INPUT
*************************************************************************
END
