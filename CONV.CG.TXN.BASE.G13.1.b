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
* <Rating>-98</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctCapitalGains
      SUBROUTINE CONV.CG.TXN.BASE.G13.1
*-----------------------------------------------------------------------------
* This program will update the CG.TXN.BASE to the new format developed for
* Merrill Lynch Spain.
* The changes are to amend the key for PORTFOLIO.GROUPING, add fields to record
* the transaction matching details, add a field for SOURCE/LOCAL tax indicator,
* add a field for adjustments to the nominal and a field to record the last update
* date and time.
* Program is run as the FILE.ROUTINE for CONVERSION.DETAILS>CONV.CG.TXN.BASE.G13.1
* As the CONVERSION.DETAILS.RUN program cannot handle converting Live files to $HIS
* files this program will also INSERT new fields.
*-----------------------------------------------------------------------------
* Modification History
*
* 29/08/02 - GLOBUS_EN_10000785
*            New Program
*
* 22/10/02 - GLOBUS_BG_100002463
*            Add fields that the conversion details cannot do.
*
* 20/02/03 - GLOBUS_BG_100003483
*            Converted '$' to '_' in routine name.
*
* 04/06/03 - GLOBUS_BG_100004358
*            Conversion "$" & "_"  to "."  in routine name.
*            (overwrite/ignore the previous conversion of  "$" to "_").
*            This is to ensure that routines will compile and work in
*            jBASE 4.1 and on non ASCII platforms.
*
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
      
      GOSUB INITIALISE
      GOSUB SELECT.FILE
      GOSUB PROCESS.RECORDS
      
      RETURN
      
*-----------------------------------------------------------------------------
PROCESS.RECORDS:
      
      LOOP
         REMOVE CG.TXN.BASE.ID FROM CG.TXN.BASE.LIST SETTING CG.TXN.BASE.LIST.MARK
      WHILE CG.TXN.BASE.ID:CG.TXN.BASE.LIST.MARK
         
         IF COUNT(CG.TXN.BASE.ID,".") = 1 THEN
            SEC.ACC.MASTER.ID = FIELD(CG.TXN.BASE.ID,'.',1)
            SECURITY.MASTER.ID = FIELD(CG.TXN.BASE.ID,'.',2)
            
            R.CG.TXN.BASE = ""
            YERR = ''
            CALL F.READ(FN.CG.TXN.BASE,CG.TXN.BASE.ID,R.CG.TXN.BASE,F.CG.TXN.BASE,YERR)

            GOSUB ADD.NEW.FIELDS ; * add new fields
            
            GOSUB TRANSACTION.LEVEL.UPDATES    ; * Update details associated with each transaction
            
            GOSUB RECORD.LEVEL.UPDATES    ; * Update details associated with the record
            
            GOSUB AUDIT.UPDATE    ; * Create the audit fields
            
            GOSUB PORTFOLIO.GROUPING.PROCESSING ; * Update PORTFOLIO.GROUPING details & get new id
            
* write record out with new key
            NEW.CG.TXN.BASE.ID = FIELD(SEC.ACC.MASTER.ID,'-',1):'.':GROUP.NAME:'.':SECURITY.MASTER.ID
            CALL F.WRITE(FN.CG.TXN.BASE,NEW.CG.TXN.BASE.ID,R.CG.TXN.BASE)
* delete the record with the original key
            CALL F.DELETE(FN.CG.TXN.BASE,CG.TXN.BASE.ID)
            
            CALL JOURNAL.UPDATE('')
            
         END
         
      REPEAT
      RETURN
      
*-----------------------------------------------------------------------------
SELECT.FILE:
      
      SELECT.STATEMENT = 'SELECT ':FN.CG.TXN.BASE
      CG.TXN.BASE.LIST = ''
      LIST.NAME = ''
      SELECTED = ''
      SYSTEM.RETURN.CODE = ''
      CALL EB.READLIST(SELECT.STATEMENT,CG.TXN.BASE.LIST,LIST.NAME,SELECTED,SYSTEM.RETURN.CODE)
      
      RETURN
      
*-----------------------------------------------------------------------------
INITIALISE:
      
      FN.STMT.ENTRY = 'F.STMT.ENTRY'
      F.STMT.ENTRY = ''
      CALL OPF(FN.STMT.ENTRY,F.STMT.ENTRY)
      
      FN.PORTFOLIO.GROUPING = 'F.PORTFOLIO.GROUPING'
      F.PORTFOLIO.GROUPING = ''
      CALL OPF(FN.PORTFOLIO.GROUPING,F.PORTFOLIO.GROUPING)
      
      FN.CG.TXN.BASE = 'F.CG.TXN.BASE'
      F.CG.TXN.BASE = ''
      CALL OPF(FN.CG.TXN.BASE,F.CG.TXN.BASE)
      
      RETURN
      
*-----------------------------------------------------------------------------
AUDIT.UPDATE:
* Create the audit fields
      
* CURR.NO
      IF R.CG.TXN.BASE<51> = '' THEN
         R.CG.TXN.BASE<51> = 1
      END
* INPUTTER
      IF R.CG.TXN.BASE<52> = '' THEN
         R.CG.TXN.BASE<52> = TNO:"_":APPLICATION
      END
* DATE.TIME
      IF R.CG.TXN.BASE<53> = '' THEN
         R.CG.TXN.BASE<53> = R.CG.TXN.BASE<41>[3,99]
      END
* AUTHORISER
      IF R.CG.TXN.BASE<54> = '' THEN
         R.CG.TXN.BASE<54> = TNO:"_":APPLICATION
      END
* CO.CODE
      IF R.CG.TXN.BASE<55> = '' THEN
         R.CG.TXN.BASE<55> = ID.COMPANY
      END
* DEPT.CODE
      IF R.CG.TXN.BASE<56> = '' THEN
         R.CG.TXN.BASE<56> = R.USER<6>
      END
      
      RETURN
      
*-----------------------------------------------------------------------------
TRANSACTION.LEVEL.UPDATES:
* Update details associated with each transaction
      
      NO.TXNS = DCOUNT(R.CG.TXN.BASE<2>,VM)
      FOR TXN.CNT = 1 TO NO.TXNS
         
* set field ORIG.SAM
         IF R.CG.TXN.BASE<4,TXN.CNT> = '' THEN
            R.CG.TXN.BASE<4,TXN.CNT> = SEC.ACC.MASTER.ID
         END
         
* set field SRC.LCL.CGT
         IF R.CG.TXN.BASE<32,TXN.CNT> = '' THEN
            R.CG.TXN.BASE<32,TXN.CNT> = 'LOCAL'
         END
         
* convert field STMT.NOS to new format
         IF LEN(R.CG.TXN.BASE<33,TXN.CNT,1>) = 22 THEN
            STMT.ENTRY.ID = R.CG.TXN.BASE<33,TXN.CNT,1>
            R.STMT.ENTRY = ""
            YERR = ''
            CALL F.READ(FN.STMT.ENTRY, STMT.ENTRY.ID,R.STMT.ENTRY,F.STMT.ENTRY,YERR)
            IF YERR = '' THEN
               R.CG.TXN.BASE<33,TXN.CNT> = LOWER(R.STMT.ENTRY<26>)
            END
         END
         
      NEXT TXN.CNT
      
      RETURN
      
*-----------------------------------------------------------------------------
RECORD.LEVEL.UPDATES:
* Update details associated with the record
      
* set field DATE.TIME.CGUPDT
      IF R.CG.TXN.BASE<41> = '' THEN
         DATE.TIME = OCONV(DATE(),"D-")
         DATE.TIME = DATE.TIME[7,4]:DATE.TIME[1,2]:DATE.TIME[4,2]:TIMEDATE()[1,2]:TIMEDATE()[4,2]
         R.CG.TXN.BASE<41> = DATE.TIME
      END
      
      RETURN
      
*-----------------------------------------------------------------------------
PORTFOLIO.GROUPING.PROCESSING:
* Update PORTFOLIO.GROUPING details & get new id
      
      PORTFOLIO.GROUPING.ID = FIELD(SEC.ACC.MASTER.ID,"-",1)
      R.PORTFOLIO.GROUPING = ''
      YERR = ''
      CALL F.READ(FN.PORTFOLIO.GROUPING, PORTFOLIO.GROUPING.ID,R.PORTFOLIO.GROUPING,F.PORTFOLIO.GROUPING,YERR)
      WRITE.REQD = @FALSE
      
      IF R.PORTFOLIO.GROUPING = '' THEN
         WRITE.REQD = @TRUE
* record does not exist so set up audit fields
* CURR.NO
         R.PORTFOLIO.GROUPING<11> = 1
* INPUTTER
         R.PORTFOLIO.GROUPING<12> = TNO:'_':APPLICATION
* DATE.TIME
         DATE.TIME = OCONV(DATE(),"D-")
         DATE.TIME = DATE.TIME[9,2]:DATE.TIME[1,2]:DATE.TIME[4,2]:TIMEDATE()[1,2]:TIMEDATE()[4,2]
         R.PORTFOLIO.GROUPING<13> = DATE.TIME
* AUTHORISER
         R.PORTFOLIO.GROUPING<14> = TNO:'_':APPLICATION
* CO.CODE
         R.PORTFOLIO.GROUPING<15> = ID.COMPANY
* DEPT.CODE
         R.PORTFOLIO.GROUPING<16> = R.USER<6>
      END
      
      SEC.ACC.MASTER.LIST = R.PORTFOLIO.GROUPING<2>
      FIND SEC.ACC.MASTER.ID IN SEC.ACC.MASTER.LIST SETTING DUMMY,VM.POS,SV.POS THEN
         GROUP.NAME = R.PORTFOLIO.GROUPING<1,VM.POS>
      END ELSE
         WRITE.REQD = @TRUE
         R.PORTFOLIO.GROUPING<1,-1> = SEC.ACC.MASTER.ID
         R.PORTFOLIO.GROUPING<2,-1> = SEC.ACC.MASTER.ID
         GROUP.NAME = SEC.ACC.MASTER.ID
      END
      
      IF WRITE.REQD THEN
         CALL F.WRITE(FN.PORTFOLIO.GROUPING,PORTFOLIO.GROUPING.ID,R.PORTFOLIO.GROUPING)
      END
      
      RETURN

*-----------------------------------------------------------------------------
ADD.NEW.FIELDS:
* add new fields
* BG_100002463

      INS "" BEFORE R.CG.TXN.BASE<26>
      INS "" BEFORE R.CG.TXN.BASE<23>
      FOR INS.CNT = 1 TO 8
         INS "" BEFORE R.CG.TXN.BASE<13>
      NEXT INS.CNT
      INS "" BEFORE R.CG.TXN.BASE<4>

      RETURN

   END
