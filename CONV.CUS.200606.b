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
* <Rating>47</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.Customer
    SUBROUTINE CONV.CUS.200606(CUS.ID,R.CUST,FILE)
*
*-----------------------------------------------------------------------------
* Program Description:
* ====== Record routine for CUSTOMER template=========
* Extract TITLE,GIVEN.NAME and FAMILY.NAME from NAME.1
* Move country and product code after ADDRESS fields
*
*-----------------------------------------------------------------------------
*      MODIFICATION LOG
*      ----------------
*
* 21/08/06 - BG_100011847
*            Splitting NAME.1 and populating the TITLE,GIVEN.NAMES and
*            FAMILY.NAME is stopped.
*-------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
    GOSUB INITIALISE
*
*  para commented! - CRM changes.
*    GOSUB EXTRACT.NAME
*
    GOSUB MOVE.COUNTRY.AND.PRODUCT
*   
   RETURN
*---------------------------------------------------
INITIALISE:
*

    EQU EB.CUS.NAME.1 TO 3,
    EB.CUS.TITLE TO 46,
    EB.CUS.GIVEN.NAMES TO 47,
    EB.CUS.FAMILY.NAMES TO 48   

* Name title
*  
   TITLE.LIST = 'MR':VM:'MRS':VM:'MS':VM:'MISS':VM:'DR':VM:'REV'
*
   GIVEN.NAMES = ''
   FAMILY.NAME = ''
   
   RETURN
*---------------------------------------------------
EXTRACT.NAME:
* 
*
    NAME = R.CUST<EB.CUS.NAME.1>
*
    NO.OF.STRING = DCOUNT(NAME,' ')
*
    IF NO.OF.STRING EQ 1 THEN
       R.CUST<EB.CUS.GIVEN.NAMES> = NAME
       RETURN
    END
*
    POS = 1
    PROCESSED.LENGTH = 0
*
    LOOP
    WHILE (POS <= NO.OF.STRING) DO
*
      IF PROCESSED.LENGTH THEN
         PARSE.STR = NAME[PROCESSED.LENGTH + 1,LEN(NAME)-PROCESSED.LENGTH]       
      END ELSE
         PARSE.STR = NAME
      END   
*         
      END.POS = INDEX(PARSE.STR,' ',1)
      STR.VALUE = PARSE.STR[1,END.POS-1]
      IF NOT(PROCESSED.LENGTH) THEN
         GOSUB GET.TITLE
      END ELSE
         IF POS NE NO.OF.STRING THEN 
         
         IF GIVEN.NAMES THEN
            GIVEN.NAMES := ' ':STR.VALUE
         END ELSE
            GIVEN.NAMES = STR.VALUE            
         END
         
         END
      END
*       
      PROCESSED.LENGTH += END.POS
*     
      POS += 1
   
    REPEAT
   
    IF STR.VALUE THEN
       R.CUST<EB.CUS.FAMILY.NAMES> = STR.VALUE
    END
    R.CUST<EB.CUS.GIVEN.NAMES> = GIVEN.NAMES
*
    RETURN
*----------------------------------------------------
MOVE.COUNTRY.AND.PRODUCT:
*
    R.CUST<8> = R.CUST<32>
    R.CUST<9> = R.CUST<33>
*
    DEL R.CUST<32>
    DEL R.CUST<32>
*
    RETURN
*----------------------------------------------------
GET.TITLE:
*
    IF STR.VALUE MATCHES TITLE.LIST THEN
       R.CUST<EB.CUS.TITLE> = STR.VALUE
    END ELSE
       GIVEN.NAMES = STR.VALUE   
    END
*
    RETURN
*----------------------------------------------------
END
