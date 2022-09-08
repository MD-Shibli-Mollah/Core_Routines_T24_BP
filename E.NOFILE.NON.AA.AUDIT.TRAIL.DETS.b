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

    $PACKAGE EB.ModelBank

    SUBROUTINE E.NOFILE.NON.AA.AUDIT.TRAIL.DETS(FINAL.ARRAY)
*-----------------------------------------------------------------------------
*
* @author psviji@temenos.com
* @stereotype subroutine
* @package infra.eb 
*!
*-----------------------------------------------------------------------------
*** <region name= PROGRAM DESCRIPTION>
*** <desc>Program description</desc>
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MODIFICATION HISTORY>
*** <desc>Modification history</desc>
*    
*  14/04/2014 - Defect 969638 / Task 969640
*               Nofile enquiry routine to provide Audit trail details for Non AA application
*               records.
*
*  16/03/15  - Defect: 971984 / Task: 1279345
*              LOCAL.REF.FIELD of CUSTOMER not updating in the enquiry result
*
* 10/05/16 - Enhancement 1499014
*          - Task 1626129
*          - Routine incorporated
*** </region>            
*-----------------------------------------------------------------------------
*** </region>
*** <region name= Main section>
    
    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.ModelBank
    $USING EB.API
    $USING EB.DataAccess
    
    GOSUB Initialise
    GOSUB Process
    
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc> Initialisation </desc>
Initialise:
    
    SEL.APP.NAME = ''
    LOCATE 'APPLICATION.ID' IN EB.Reports.getDFields()<1> SETTING Y.APP.POS THEN
        SEL.APP.NAME = EB.Reports.getDRangeAndValue()<Y.APP.POS>
    END
    SEL.CONTRACT.ID = ''
    LOCATE 'RECORD.ID' IN EB.Reports.getDFields()<1> SETTING Y.REC.POS THEN
        SEL.CONTRACT.ID = EB.Reports.getDRangeAndValue()<Y.REC.POS>
    END
    ENTERED.SEL.ORDER.VAL = ''
    LOCATE 'ORDER' IN EB.Reports.getDFields()<1> SETTING Y.ORD.POS THEN
        ENTERED.SEL.ORDER.VAL = EB.Reports.getDRangeAndValue()<Y.ORD.POS>
    END
    R.APPLN.HIS.REC = ''
    R.APPLN.REC = ''
    R.SS = ''
    YAF = ''
    YAV = ''
    YAS = ''
    DATA.TYPE = ''
    ERR.MSG = ''
    FN.APPLN = 'F.':SEL.APP.NAME
    F.APPLN = ''
    F.APPLN.HIS = ''
    F.APPLN.NAU = ''
    FN.APPLN.HIS = 'F.':SEL.APP.NAME:'$HIS'
    FN.APPLN.NAU = 'F.':SEL.APP.NAME:'$NAU'
    EB.DataAccess.Opf(FN.APPLN,F.APPLN)
    EB.DataAccess.Opf(FN.APPLN.HIS,F.APPLN.HIS)
    EB.DataAccess.Opf(FN.APPLN.NAU,F.APPLN.NAU)
    EB.API.GetStandardSelectionDets(SEL.APP.NAME,R.SS)
    IF ENTERED.SEL.ORDER.VAL MATCHES 'ascending':@VM:'ASND' THEN
        SEL.ORDER.FLAG.VAL =  1         ;* indicates ascending 
    END ELSE  
        SEL.ORDER.FLAG.VAL = ''     ;* indicates descending by default
    END
    
    AUDIT.FLD.POS = ''
    CHNGED.FIELD.ARRAY = ''
    LATEST.REC.ARRAY = ''
    CHANGED.FIELD.FINAL.ARRAY = ''
    CONT.INPUT.FIELD.VAL = ''
    NEW.REC.INPUT.FIELD.VAL = ''
    R.PREV.REC.VALUES = ''
    
    RETURN
*-----------------------------------------------------------------------------
*** <region name= Process>
Process:
*** <desc> Get old and new value comparision output </desc>

    GOSUB GetAuditFieldPositions
    GOSUB CheckLatestRecordValues
    GOSUB FormFinalComparisonOutput
    
    RETURN
    
*** </region>
    
*-----------------------------------------------------------------------------  

*** <region name= GetAuditFieldPositions>
GetAuditFieldPositions:
*** <desc>Get audit field positions </desc>

    AUDIT.FIELD.NAME.LIST = 'OVERRIDE':@FM:'RECORD.STATUS':@FM:'CURR.NO':@FM:'INPUTTER':@FM:'DATE.TIME':@FM:'AUTHORISER':@FM:'CO.CODE':@FM:
    AUDIT.FIELD.NAME.LIST:= 'DEPT.CODE':@FM:'AUDITOR.CODE':@FM:'AUDIT.DATE.TIME'
    AUDIT.FLD.START.CNT = 1
    TOTAL.AUDIT.FLD.CNT = DCOUNT(AUDIT.FIELD.NAME.LIST,@FM)
    LOOP
        REMOVE AUDIT.FLD.NAME FROM AUDIT.FIELD.NAME.LIST SETTING Y.CONT.FIELD.POS
    WHILE AUDIT.FLD.START.CNT LE TOTAL.AUDIT.FLD.CNT
        FLD.NUM = '' ;  YAF = '' ;  YAV = '' ; YAS = '' ; DATA.TYPE = '' ; ERR.MSG = ''
        EB.API.FieldNamesToNumbers(AUDIT.FLD.NAME,R.SS,FLD.NUM,YAF,YAV,YAS,DATA.TYPE,ERR.MSG)
        BEGIN CASE
        CASE AUDIT.FLD.NAME EQ 'OVERRIDE'
            CONT.OVERRIDE.FIELD.POS = FLD.NUM
        CASE AUDIT.FLD.NAME EQ 'RECORD.STATUS'
            CONT.RECORD.STATUS.FIELD.POS = FLD.NUM
        CASE AUDIT.FLD.NAME EQ 'CURR.NO'
            CONT.CURR.NUM.POS = FLD.NUM
        CASE AUDIT.FLD.NAME EQ 'INPUTTER'
            CONT.INPUT.FIELD.POS = FLD.NUM
        CASE AUDIT.FLD.NAME EQ 'DATE.TIME'
            CONT.DATE.TIME.POS = FLD.NUM
        CASE AUDIT.FLD.NAME EQ 'AUTHORISER'
            CONT.AUTH.POS = FLD.NUM
        CASE AUDIT.FLD.NAME EQ 'CO.CODE'
            CONT.CO.CODE.POS = FLD.NUM
        CASE AUDIT.FLD.NAME EQ 'DEPT.CODE'
            CONT.DEPT.CODE.POS = FLD.NUM
        CASE AUDIT.FLD.NAME EQ 'AUDITOR.CODE'
            CONT.AUDITOR.CODE.POS = FLD.NUM
        CASE AUDIT.FLD.NAME EQ 'AUDIT.DATE.TIME'
            CONT.AUDIT.DATE.TIME.POS = FLD.NUM
        END CASE
        AUDIT.FLD.POS<-1> = FLD.NUM
        AUDIT.FLD.START.CNT+=1
    REPEAT
    CHANGE @FM TO @VM IN AUDIT.FLD.POS

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= CheckLatestRecordValues>
CheckLatestRecordValues:
*** <desc> Check latest record values and compare with previous one till end of history </desc>

    NAU.CONTRACT = ''
    SEL.FLD.CURR.NO = FIELD(SEL.CONTRACT.ID,';',2)
    SEL.FLD.CONTRACT.ID = FIELD(SEL.CONTRACT.ID,';',1)
    GOSUB GetLatestRecordValues
    IF SEL.FLD.CURR.NO THEN
        LATEST.CURR.NO.VAL = SEL.FLD.CURR.NO
    END ELSE
        LATEST.CURR.NO.VAL = R.LATEST.REC<CONT.CURR.NUM.POS>
    END
    R.CURRENT.REC = R.LATEST.REC
    CURRENT.REC.ID = REC.ID
    CURR.NO.INIT.VAL = 1
    LOOP
    WHILE LATEST.CURR.NO.VAL GE CURR.NO.INIT.VAL
        IF LATEST.CURR.NO.VAL NE CURR.NO.INIT.VAL THEN
            IF NAU.CONTRACT AND CURR.NO.INIT.VAL EQ 1 THEN
                REC.ID = SEL.FLD.CONTRACT.ID
                GOSUB GetLiveRecordValues
            END ELSE
                PREV.CURR.NO.VAL = LATEST.CURR.NO.VAL - CURR.NO.INIT.VAL
                REC.ID = SEL.FLD.CONTRACT.ID:';':PREV.CURR.NO.VAL
                GOSUB GetPreviousRecordValues
            END
            IF (R.CURRENT.REC NE '' AND R.PREV.REC.VALUES NE '') THEN
                CONT.CURR.NUM.VAL = R.CURRENT.REC<CONT.CURR.NUM.POS>
                CONT.INPUT.FLD.VAL = R.CURRENT.REC<CONT.INPUT.FIELD.POS>
                INPUTTER.TOTAL.CNT = DCOUNT(CONT.INPUT.FLD.VAL,@VM)
                FOR INP.CNT = 1 TO INPUTTER.TOTAL.CNT
                    CONT.INPUT.FIELD.VAL<1,INP.CNT> = FIELD(CONT.INPUT.FLD.VAL<1,INP.CNT>,'_',2,1)
                NEXT INP.CNT
                CONT.DATE.TIME.VAL = R.CURRENT.REC<CONT.DATE.TIME.POS>
                CONT.AUTH.VAL = R.CURRENT.REC<CONT.AUTH.POS>
                CONT.AUTH.VAL = FIELD(CONT.AUTH.VAL,'_',2,1)
                CONT.CO.CODE.VAL = R.CURRENT.REC<CONT.CO.CODE.POS>
                CONT.DEPT.CODE.VAL = R.CURRENT.REC<CONT.DEPT.CODE.POS>
                COMPARISON.OUTPUT = EQS(R.CURRENT.REC,R.PREV.REC.VALUES)
                GOSUB CompareCurrentAndPreviousRecord
                GOSUB CollectChangedFieldValues
            END
        END ELSE
            NEW.REC.CURR.NUM = 'New Record'
            NEW.REC.ID = REC.ID
            NEW.REC.INPUT.FLD.VAL = R.CURRENT.REC<CONT.INPUT.FIELD.POS>
            INPUTTER.TOTAL.CNT = DCOUNT(NEW.REC.INPUT.FLD.VAL,@VM)
            FOR INP.CNT = 1 TO INPUTTER.TOTAL.CNT 
                NEW.REC.INPUT.FIELD.VAL<1,INP.CNT> = FIELD(NEW.REC.INPUT.FLD.VAL<1,INP.CNT>,'_',2,1)
            NEXT INP.CNT
            
            NEW.REC.DATE.TIME.VAL = R.CURRENT.REC<CONT.DATE.TIME.POS>
            NEW.REC.AUTH.VAL = R.CURRENT.REC<CONT.AUTH.POS>
            NEW.REC.AUTH.VAL = FIELD(NEW.REC.AUTH.VAL,'_',2,1)
            NEW.REC.CO.CODE.VAL = R.CURRENT.REC<CONT.CO.CODE.POS>
            NEW.REC.DEPT.CODE.VAL = R.CURRENT.REC<CONT.DEPT.CODE.POS>
            NEW.REC.CHANGED.FIELD.NAME = ''
            OLD.REC.VALUE = ''
            NEW.REC.VALUE = ''
            LATEST.REC.ARRAY<-1> = NEW.REC.CURR.NUM:'*':NEW.REC.ID:'*':NEW.REC.INPUT.FIELD.VAL:'*':NEW.REC.AUTH.VAL:'*':
            LATEST.REC.ARRAY := NEW.REC.DATE.TIME.VAL:'*':NEW.REC.CO.CODE.VAL:'*':NEW.REC.DEPT.CODE.VAL:'*':NEW.REC.CHANGED.FIELD.NAME:'*':
            LATEST.REC.ARRAY := OLD.REC.VALUE:'*':NEW.REC.VALUE:'*':SEL.APP.NAME
        END
        R.CURRENT.REC = R.PREV.REC.VALUES
        CURRENT.REC.ID = REC.ID
        CURR.NO.INIT.VAL+=1
    REPEAT
    
    RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GetLatestRecordValues>
GetLatestRecordValues:
*** <desc> </desc>

    IF SEL.FLD.CURR.NO EQ '' THEN
        R.APPLN.NAU = '' 
        REC.ID = SEL.FLD.CONTRACT.ID
        EB.DataAccess.FRead(FN.APPLN.NAU,REC.ID,R.APPLN.NAU,F.APPLN.NAU,Y.APPLN.NAU.ERR)
        IF R.APPLN.NAU EQ '' THEN
            R.APPLN.REC = '' 
            EB.DataAccess.FRead(FN.APPLN,REC.ID,R.APPLN.REC,F.APPLN,Y.APPLN.REC.ERR)
            IF R.APPLN.REC THEN
                R.LATEST.REC = R.APPLN.REC
            END
        END ELSE
            R.LATEST.REC = R.APPLN.NAU
            NAU.CONTRACT = 1
        END
    END ELSE
        REC.ID = SEL.CONTRACT.ID ; R.PPLN.HIS = '' 
        EB.DataAccess.FRead(FN.APPLN.HIS,REC.ID,R.APPLN.HIS,F.APPLN.HIS,APPLN.HIS.ERR)
        IF R.APPLN.HIS THEN
            R.LATEST.REC =  R.APPLN.HIS
        END
    END
    
    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= GetLiveRecordValues>
GetLiveRecordValues:
*** <desc> </desc>

    R.APPLN.REC = '' 
    EB.DataAccess.FRead(FN.APPLN,REC.ID,R.APPLN.REC,F.APPLN,Y.APPLN.REC.ERR)
    IF R.APPLN.REC THEN
        R.PREV.REC.VALUES = R.APPLN.REC
    END
    
    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= GetPreviousRecordValues>
GetPreviousRecordValues:
*** <desc>Get previous record content </desc>

    R.APPLN.HIS = '' 
    EB.DataAccess.FRead(FN.APPLN.HIS,REC.ID,R.APPLN.HIS,F.APPLN.HIS,APPLN.HIS.ERR)
    IF R.APPLN.HIS THEN
        R.PREV.REC.VALUES = R.APPLN.HIS
    END

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= CompareCurrentAndPreviousRecord>
CompareCurrentAndPreviousRecord:
*** <desc>Compare current and previous record content </desc>

    CHANGED.FIELD.NAME = '' 
    OLD.REC.VALUE = '' 
    NEW.REC.VALUE = ''
    COMPARE.INIT.VAL = 1
      SAVE.COMPARISON.OUTPUT = COMPARISON.OUTPUT
      CONVERT @VM TO ' ' IN SAVE.COMPARISON.OUTPUT
      CONVERT @SM TO ' ' IN SAVE.COMPARISON.OUTPUT
    COMPARE.OUT.FM.CNT = DCOUNT(COMPARISON.OUTPUT,@FM)
    LOOP
        REMOVE COMPARE.OUT.VAL FROM SAVE.COMPARISON.OUTPUT SETTING Y.COMPARE.OUT.POS
    WHILE COMPARE.OUT.FM.CNT GE COMPARE.INIT.VAL
        IF COMPARE.INIT.VAL MATCHES AUDIT.FLD.POS ELSE
            GOSUB CompareAndGetValues
        END
        COMPARE.INIT.VAL+=1
    REPEAT
    
    RETURN
*** </region> 

*-----------------------------------------------------------------------------

*** <region name= CompareAndGetValues>
CompareAndGetValues:
*** <desc>Compare and get values </desc>

    localRefFldComparison = ''
    IF INDEX(COMPARE.OUT.VAL,'0',1) THEN
        IN.FIELD.NUMBER = COMPARE.INIT.VAL 
        FIELD.NAME = '' 
        DATA.TYPE = '' 
        ERR.MSG = ''
        EB.API.FieldNumbersToNames(IN.FIELD.NUMBER,R.SS,FIELD.NAME,DATA.TYPE,ERR.MSG)
        IF FIELD.NAME EQ 'LOCAL.REF' THEN
            localRefFldComparison = 1
            GOSUB CompareLocalReferenceFieldValues
        END ELSE
            GOSUB GetChangedFieldNameAndValues
        END
    END
   
    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= CompareLocalReferenceFieldValues>
CompareLocalReferenceFieldValues:
*** <desc>Comparison for local reference fields </desc>
    
    LOCAL.REF.CHK.VALUES = COMPARISON.OUTPUT<COMPARE.INIT.VAL>
    CHANGE @VM TO @FM IN LOCAL.REF.CHK.VALUES
    CHANGE @SM TO ' ' IN LOCAL.REF.CHK.VALUES
    LOCAL.REF.INIT.VAL = 1
    LOCAL.REF.CHK.CNT.VAL = DCOUNT(LOCAL.REF.CHK.VALUES,@FM)
    LOOP
        REMOVE LOCAL.REF.CHK.VAL FROM LOCAL.REF.CHK.VALUES SETTING Y.LOCAL.REF.CHK.POS
    WHILE LOCAL.REF.CHK.CNT.VAL GE LOCAL.REF.INIT.VAL
        
        IN.FIELD.NUMBER = COMPARE.INIT.VAL:'.':LOCAL.REF.INIT.VAL
        FIELD.NAME = '' 
        DATA.TYPE = ''
        ERR.MSG = ''
        EB.API.FieldNumbersToNames(IN.FIELD.NUMBER,R.SS,FIELD.NAME,DATA.TYPE,ERR.MSG)
        GOSUB GetExactLocalRefFldName ; *Get exact Localreference field name 
        GOSUB SaveComparisonVariables 
        GOSUB LoadComprisonVariables ; * 
        GOSUB GetChangedFieldNameAndValues
        GOSUB RestoreComparisonVariables 
        
        LOCAL.REF.INIT.VAL+=1
    REPEAT
   
    
    RETURN
*** </region> 
*-----------------------------------------------------------------------------

*** <region name= GetChangedFieldNameAndValues>
GetChangedFieldNameAndValues:
*** <desc>Get changed field name and its compared values </desc>

   IF INDEX(COMPARE.OUT.VAL,'0',1) THEN 
   
       CHANGED.FIELD.NAME<-1> = FIELD.NAME
       
       IF localRefFldComparison THEN
           FLD.OLD.VALUE = R.PREV.REC.VALUES<SAVE.COMPARE.INIT.VAL,COMPARE.INIT.VAL>
           FLD.NEW.VALUE = R.CURRENT.REC<SAVE.COMPARE.INIT.VAL,COMPARE.INIT.VAL>
          
           CONVERT @SM TO @VM IN FLD.OLD.VALUE
           CONVERT @SM TO @VM IN FLD.NEW.VALUE
           
           OLD.REC.VALUE<-1> = FLD.OLD.VALUE
           NEW.REC.VALUE<-1> = FLD.NEW.VALUE
           
           GOSUB FieldValueAlignment ; * 
           
       END ELSE
           CHANGE @SM TO @VM IN R.PREV.REC.VALUES<COMPARE.INIT.VAL>
           CHANGE @SM TO @VM IN R.CURRENT.REC<COMPARE.INIT.VAL>
   
           FLD.OLD.VALUE = R.PREV.REC.VALUES<COMPARE.INIT.VAL>
           FLD.NEW.VALUE = R.CURRENT.REC<COMPARE.INIT.VAL>
           
           OLD.REC.VALUE<-1> = FLD.OLD.VALUE
           NEW.REC.VALUE<-1> = FLD.NEW.VALUE
           
           GOSUB FieldValueAlignment ; * 
             
       END 
    END
    
  RETURN
*** </region>
 
*-----------------------------------------------------------------------------

*** <region name= CollectChangedFieldValues>
CollectChangedFieldValues:
*** <desc> Collect changed field value contents </desc>

    CHANGE @FM TO @VM IN CHANGED.FIELD.NAME
    CHANGE @FM TO @VM IN OLD.REC.VALUE
    CHANGE @FM TO @VM IN NEW.REC.VALUE
  *  CHANGE SM TO VM IN NEW.REC.VALUE
   * CHANGE SM TO VM IN OLD.REC.VALUE 
    
    CHNGED.FIELD.ARRAY<-1> = CONT.CURR.NUM.VAL:'*':CURRENT.REC.ID:'*':CONT.INPUT.FIELD.VAL:'*':CONT.AUTH.VAL:'*':CONT.DATE.TIME.VAL:'*':
    CHNGED.FIELD.ARRAY := CONT.CO.CODE.VAL:'*':CONT.DEPT.CODE.VAL:'*':CHANGED.FIELD.NAME:'*':OLD.REC.VALUE:'*':NEW.REC.VALUE:'*':SEL.APP.NAME

    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= FormFinalComparisonOutput>
FormFinalComparisonOutput:
*** <desc> Form final comparision output as per ORDER given in selection criteria </desc>

    IF SEL.ORDER.FLAG.VAL EQ '' THEN
        IF CHNGED.FIELD.ARRAY NE '' THEN
            FINAL.ARRAY = CHNGED.FIELD.ARRAY:@FM:LATEST.REC.ARRAY
        END ELSE
            FINAL.ARRAY = LATEST.REC.ARRAY
        END
    END ELSE
        CHANGED.FIELD.FINAL.ARRAY<-1> = LATEST.REC.ARRAY
        IF CHNGED.FIELD.ARRAY NE '' THEN
            CHANGED.FIELD.ARRAY.CNT.VAL = DCOUNT(CHNGED.FIELD.ARRAY,@FM)
            CHANGED.FIELD.INIT.VAL = 1
            LOOP
            WHILE CHANGED.FIELD.ARRAY.CNT.VAL GE CHANGED.FIELD.INIT.VAL
                CHANGED.FIELD.FINAL.ARRAY<-1> = CHNGED.FIELD.ARRAY<CHANGED.FIELD.ARRAY.CNT.VAL>
                CHANGED.FIELD.ARRAY.CNT.VAL-=1
            REPEAT
        END
        FINAL.ARRAY = CHANGED.FIELD.FINAL.ARRAY
    END
    
    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= SaveComparisonVariables>
SaveComparisonVariables:
*** <desc>save variables used for core fields comparison </desc>

    SAVE.COMPARE.OUT.VAL = COMPARE.OUT.VAL
    SAVE.COMPARE.INIT.VAL = COMPARE.INIT.VAL
    
    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= RestoreComparisonVariables>
RestoreComparisonVariables:
*** <desc> restore variables used for core field comparison after completion of local field comparison</desc>

    COMPARE.OUT.VAL = SAVE.COMPARE.OUT.VAL 
    COMPARE.INIT.VAL = SAVE.COMPARE.INIT.VAL
    
    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= LoadComprisonVariables>
LoadComprisonVariables:
*** <desc> Load variables required for local reference field comparison </desc>

    COMPARE.OUT.VAL = LOCAL.REF.CHK.VAL
    COMPARE.INIT.VAL = LOCAL.REF.INIT.VAL
    
    RETURN
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetExactLocalRefFldName>
GetExactLocalRefFldName:
*** <desc>Get exact Localreference field name </desc>
    
    TEMP.LOCAL.REF.NUM = FIELD(FIELD.NAME,'-',1):'<1,':FIELD(FIELD.NAME,'-',2,1):'>'
    LOCATE TEMP.LOCAL.REF.NUM IN R.SS<EB.SystemTables.StandardSelection.SslSysFieldNo,1> SETTING LOCREF.POS THEN
        FIELD.NAME = R.SS<EB.SystemTables.StandardSelection.SslSysFieldName,LOCREF.POS>
    END
    
    RETURN
*** </region>
*-----------------------------------------------------------------------------


*** <region name= FieldValueAlignment>
FieldValueAlignment:
*** <desc> </desc>
         
           delim = @VM
           VM.CNT.ARRAY = ''
           VM.CNT.ARRAY<-1> = DCOUNT(FLD.OLD.VALUE,delim)
           VM.CNT.ARRAY<-1> = DCOUNT(FLD.NEW.VALUE,delim)
           DATA.VM.CNT = MAXIMUM(VM.CNT.ARRAY)                    ;* maximum data count can be taken to add space in field name array
              FOR DAT.CNT = 1 TO DATA.VM.CNT
                  IF FLD.OLD.VALUE<1,DAT.CNT> AND FLD.NEW.VALUE<1,DAT.CNT> = '' THEN
                      NEW.VAL.FM.CNT = DCOUNT(OLD.REC.VALUE,@FM)   ;* get old rec value FM count to get current field position in NEW.REC.VALUE array to add space
                      NEW.REC.VALUE<NEW.VAL.FM.CNT,DAT.CNT> = ' '
                  END
                  IF FLD.OLD.VALUE<1,DAT.CNT> = '' AND FLD.NEW.VALUE<1,DAT.CNT> THEN
                     OLD.VAL.FM.CNT = DCOUNT(NEW.REC.VALUE,@FM)    ;* get new rec value FM count to get current field position in OLD.REC.VALUE array to add space
                     OLD.REC.VALUE<OLD.VAL.FM.CNT,DAT.CNT> = ' '
                  END
                  IF FLD.OLD.VALUE<1,DAT.CNT> = '' AND FLD.NEW.VALUE<1,DAT.CNT> = '' THEN   ;* only applicable for associated set
                    NEW.VAL.FM.CNT = DCOUNT(OLD.REC.VALUE,@FM)       
                    NEW.REC.VALUE<NEW.VAL.FM.CNT,DAT.CNT> = ' '
                    
                    OLD.VAL.FM.CNT = DCOUNT(NEW.REC.VALUE,@FM)       
                    OLD.REC.VALUE<OLD.VAL.FM.CNT,DAT.CNT> = ' '
                  END                                                                                                                          
                  IF DAT.CNT GT '1' THEN
                      CHANGED.FIELD.NAME<-1> = ' '
                  END
             NEXT DAT.CNT
     RETURN

*** </region>

*-----------------------------------------------------------------------------

END

