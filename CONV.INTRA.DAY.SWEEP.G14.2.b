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

* Version 6 07/09/00  GLOBUS Release No. G14.0.00 26/06/03
*-----------------------------------------------------------------------------
* <Rating>146</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PO.Cashpooling
      SUBROUTINE CONV.INTRA.DAY.SWEEP.G14.2
*
* Populate description from AC.CP.GROUP.PARAM and Audit fields
*
*************************************************************************

$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY
$INSERT I_F.USER
$INSERT I_F.INTRA.DAY.SWEEP
$INSERT I_F.AC.CP.GROUP.PARAM
*************************************************************************
      GOSUB INITIALISE
      GOSUB MAIN.PROCESS
      RETURN
*========================================================================
SUB.PROCESS:
      SELE.CMD = "SSELECT ":FN.INTRA.DAY.SWEEP
      CALL EB.READLIST(SELE.CMD,IDS.LIST,'','','')
      LOOP
         REMOVE IDS.ID FROM IDS.LIST SETTING IDS.POS
      WHILE IDS.ID:IDS.POS
         READV GP.DESCRIPTION FROM FV.AC.CP.GROUP.PARAM,IDS.ID,AC.GP.DESCRIPTION THEN
            R.INTRA.DAY.SWEEP<AC.IDS.DESCRIPTION> = GP.DESCRIPTION
            R.INTRA.DAY.SWEEP<AC.IDS.CO.CODE> = K.COMPANY
            WRITE R.INTRA.DAY.SWEEP TO FV.INTRA.DAY.SWEEP, IDS.ID
         END
      REPEAT
      RETURN
*========================================================================
MAIN.PROCESS:
*
      SELE.COMP = "SSELECT " :FN.COMPANY
      COMP.LIST = ''
      CALL EB.READLIST(SELE.COMP,COMP.LIST,'','','')
* Perform the conversion for each company
      LOOP
         REMOVE K.COMPANY FROM COMP.LIST SETTING END.OF.COMPANIES
      WHILE K.COMPANY:END.OF.COMPANIES
         READV COMP.MNEMONIC FROM FV.COMPANY,K.COMPANY,EB.COM.MNEMONIC THEN
            FN.INTRA.DAY.SWEEP = "F":COMP.MNEMONIC:".INTRA.DAY.SWEEP"
            FN.AC.CP.GROUP.PARAM = "F":COMP.MNEMONIC:".AC.CP.GROUP.PARAM"
* Open files for each company
            FV.INTRA.DAY.SWEEP =''
            FV.AC.CP.GROUP.PARAM = ''
            OPEN FN.INTRA.DAY.SWEEP TO FV.INTRA.DAY.SWEEP ELSE OPEN.EXE.ERR = 1
            OPEN FN.AC.CP.GROUP.PARAM TO FV.AC.CP.GROUP.PARAM ELSE OPEN.EXE.ERR = 1
            GOSUB SUB.PROCESS
         END
      REPEAT
      RETURN
*========================================================================
INITIALISE:

      FN.COMPANY = "F.COMPANY"
      FV.COMPANY = ''
      CALL OPF(FN.COMPANY,FV.COMPANY)

      R.INTRA.DAY.SWEEP= ''
      DTS = OCONV(DATE(),"D-")
      DTS = DTS[9,2]:DTS[1,2]:DTS[4,2]:TIMEDATE()[1,2]:TIMEDATE()[4,2]
      R.INTRA.DAY.SWEEP<AC.IDS.DATE.TIME> = DTS
      R.INTRA.DAY.SWEEP<AC.IDS.AUTHORISER> = 'SY_CONV.INTRA.DAY.SWEEP.G14.2'
      R.INTRA.DAY.SWEEP<AC.IDS.DEPT.CODE> = R.USER<EB.USE.DEPARTMENT.CODE>
      R.INTRA.DAY.SWEEP<AC.IDS.AUDITOR.CODE> = ''
      R.INTRA.DAY.SWEEP<AC.IDS.AUDIT.DATE.TIME> = ''

      RETURN
*========================================================================

   END
