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
* <Rating>-56</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.CorporateActions
   SUBROUTINE CONV.DX.DIARY.G16(DX.DIARY.ID,R.DX.DIARY,F.DX.DIARY)
**********************************************************************************
*
* Created by: Mat Kusari 07/02/2005
* 
* It's a conversion rutine, goes throgh every record in the DX.DIARY app. 
* Clear the DX.DIA.NEW.CONT.SIZE for all the DX.DIARY records.  
* If all the required fields are populated then calculate the new DX.DIA.NEW.CONT.SIZE
* otherwise leave it blank.
*
**********************************************************************************
* Inserts
$INSERT I_COMMON
$INSERT I_EQUATE
*---------------------------------------------------------------------------------
* Equates
EQU DX.DIA.SECURITY.NO TO 1,
    DX.DIA.CONTRACT.CODE TO 2,
    DX.DIA.CONTRACT.SIZE TO 3,
    DX.DIA.OLD.RATIO TO 13,
    DX.DIA.NEW.RATIO TO 14,
    DX.DIA.EVENT.TYPE TO 6,
    DX.DIA.NEW.CONT.SIZE TO 21,
    SC.DRY.ROUNDING TO 23,
    SC.DRY.NOM.ROUNDING.METHD TO 41,
    SC.DRY.DENOM.LEVEL TO 40  
  
*-----------------------------------------------------------------------------------
MAIN.PROCESS: 
*----------
 
      GOSUB INITIALISE
   
      GOSUB MODIFY.DX.RECORD

      RETURN
*----------------------------------------------------------------------------------
INITIALISE:
*----------
      F.DIARY.TYPE = '' ; R.DIARY.TYPE = ''
      CALL OPF('F.DIARY.TYPE', F.DIARY.TYPE)
      
      RETURN
*----------------------------------------------------------------------------------
CALC.NEW.CONT.SIZE:
*------------------
      NOMINAL = R.DX.DIARY<DX.DIA.CONTRACT.SIZE>
      OLD.RATIO = R.DX.DIARY<DX.DIA.OLD.RATIO>
      NEW.RATIO = R.DX.DIARY<DX.DIA.NEW.RATIO>
      SEC.NUM = R.DX.DIARY<DX.DIA.SECURITY.NO>

      ROUNDING = R.DIARY.TYPE<SC.DRY.ROUNDING>
      ROUND.METHD = R.DIARY.TYPE<SC.DRY.NOM.ROUNDING.METHD>
      DENOM.LEVEL = R.DIARY.TYPE<SC.DRY.DENOM.LEVEL>

      ODD.LOT.REMAIN = ""
      NEW.NOM.AMOUNT = ""

      CALL CALC.NO.OF.SHARES(NOMINAL,NEW.RATIO,OLD.RATIO,SEC.NUM,NEW.NOM.AMOUNT,ROUNDING,ROUND.METHD,DENOM.LEVEL,ODD.LOT.REMAIN)

      RETURN
*----------------------------------------------------------------------------------
READ.DIARY.TYPE:
*---------------
      CALL CACHE.READ("F.DIARY.TYPE",R.DX.DIARY<DX.DIA.EVENT.TYPE>,R.DIARY.TYPE,ER)
      
      RETURN
*----------------------------------------------------------------------------------
MODIFY.DX.RECORD:
*----------------

      NEW.CONT.VALID = 0; * 0 for not valid, 1 for a valid calculation.  

*Check if any of the required fileds are empty
      REQ.FIELD1 = R.DX.DIARY<DX.DIA.CONTRACT.CODE> NE ''
      REQ.FIELD2 = R.DX.DIARY<DX.DIA.SECURITY.NO> NE ''
      REQ.FIELD3 = R.DX.DIARY<DX.DIA.OLD.RATIO> NE ''   
      REQ.FIELD4 = R.DX.DIARY<DX.DIA.NEW.RATIO> NE ''
      REQ.FIELD5 = R.DX.DIARY<DX.DIA.EVENT.TYPE> NE ''

*Check if the contract is valid for calculation      
      IF REQ.FIELD1 EQ 1 AND REQ.FIELD2 EQ 1 AND REQ.FIELD3 EQ 1 AND REQ.FIELD4 EQ 1 AND REQ.FIELD5 EQ 1 THEN      
         NEW.CONT.VALID = 1
      END ELSE
         NEW.CONT.VALID = 0  
      END 

*If none of the required fields are empty then 
*calculate and assign the newcontract size
*Otherwise set it to blank.
      IF NEW.CONT.VALID = 1 THEN
         GOSUB READ.DIARY.TYPE
         GOSUB CALC.NEW.CONT.SIZE
         R.DX.DIARY<DX.DIA.NEW.CONT.SIZE> = NEW.NOM.AMOUNT
      END ELSE
         R.DX.DIARY<DX.DIA.NEW.CONT.SIZE> = ''
      END
   
      RETURN
*----------------------------------------------------------------------------------
END
