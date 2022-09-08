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

* Version 8 02/06/00  GLOBUS Release No. G11.0.00 29/06/00
*-----------------------------------------------------------------------------
* <Rating>-47</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctCapitalGains
      SUBROUTINE CONV.CG.TXN.RULES.G13.1
*-----------------------------------------------------------------------------
* This program will update the CG.TXN.RULES to the new format developed for
* Merrill Lynch Spain.
* The changes are to amend the key to add levels for sub-asset type and security
* code specialisation and to add fields to allow online/batch updates and other
* fields for the new EVENT.TYPES
* Program is run as the FILE.ROUTINE for CONVERSION.DETAILS>CONV.CG.TXN.RULES.G13.1
*-----------------------------------------------------------------------------
* Modification History
*
* 02/09/02 - GLOBUS_EN_10000785
*            New Program
*
* 10/12/08 - GLOBUS_CI_10059339
*            Conversion fails while running RUN.CONVERSION.PGMS
*
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
      
      GOSUB INITIALISE
      
* must process all three files
      YFN.FILE = FN.CG.TXN.RULES$NAU
      YF.FILE = F.CG.TXN.RULES$NAU
      GOSUB SELECT.FILE
      GOSUB PROCESS.RECORDS
      
      YFN.FILE = FN.CG.TXN.RULES
      YF.FILE = F.CG.TXN.RULES
      GOSUB SELECT.FILE
      GOSUB PROCESS.RECORDS

      YFN.FILE = FN.CG.TXN.RULES$HIS
      YF.FILE = F.CG.TXN.RULES$HIS
      GOSUB SELECT.FILE
      GOSUB PROCESS.RECORDS

      RETURN
      
*-----------------------------------------------------------------------------
PROCESS.RECORDS:
      
      LOOP
         REMOVE CG.TXN.RULES.ID FROM CG.TXN.RULES.LIST SETTING CG.TXN.RULES.LIST.MARK
      WHILE CG.TXN.RULES.ID:CG.TXN.RULES.LIST.MARK
         
         IF COUNT(CG.TXN.RULES.ID,".") = 0 THEN
            R.CG.TXN.RULES = ''
            YERR = ''
            CALL F.READ(YFN.FILE,CG.TXN.RULES.ID,R.CG.TXN.RULES,YF.FILE,YERR)

* set contents of field, part of multi-part key
            R.CG.TXN.RULES<1> = FIELD(CG.TXN.RULES.ID,';',1)

* set contents of UPDATE.METHOD
            IF R.CG.TXN.RULES<13> = '' THEN
               R.CG.TXN.RULES<13> = 'ONLINE'
            END

* write record with new key
            IF COUNT(CG.TXN.RULES.ID,";") THEN
* history record
               NEW.CG.TXN.RULES.ID = FIELD(CG.TXN.RULES.ID,';',1):'..;':FIELD(CG.TXN.RULES.ID,';',2)
            END ELSE
               NEW.CG.TXN.RULES.ID = CG.TXN.RULES.ID:'..'
            END
            CALL F.WRITE(YFN.FILE,NEW.CG.TXN.RULES.ID,R.CG.TXN.RULES)

* delete original key
            CALL F.DELETE(YFN.FILE,CG.TXN.RULES.ID)
            
         END
      REPEAT

      CALL JOURNAL.UPDATE(NEW.CG.TXN.RULES.ID)

      RETURN
      
*-----------------------------------------------------------------------------
SELECT.FILE:
      
      SELECT.STATEMENT = 'SELECT ':YFN.FILE
      CG.TXN.RULES.LIST = ''
      LIST.NAME = ''
      SELECTED = ''
      SYSTEM.RETURN.CODE = ''
      CALL EB.READLIST(SELECT.STATEMENT,CG.TXN.RULES.LIST,LIST.NAME,SELECTED,SYSTEM.RETURN.CODE)
      
      RETURN
      
*-----------------------------------------------------------------------------
INITIALISE:
      
      FN.CG.TXN.RULES = 'F.CG.TXN.RULES'
      F.CG.TXN.RULES = ''
      CALL OPF(FN.CG.TXN.RULES,F.CG.TXN.RULES)
      
      FN.CG.TXN.RULES$HIS = 'F.CG.TXN.RULES$HIS'
      F.CG.TXN.RULES$HIS = ''
      CALL OPF(FN.CG.TXN.RULES$HIS,F.CG.TXN.RULES$HIS)
      
      FN.CG.TXN.RULES$NAU = 'F.CG.TXN.RULES$NAU'
      F.CG.TXN.RULES$NAU = ''
      CALL OPF(FN.CG.TXN.RULES$NAU,F.CG.TXN.RULES$NAU)
      
      RETURN
      
   END
