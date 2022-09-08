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

* Version 3 02/06/00  GLOBUS Release No. G15.0.01 31/08/04
*-----------------------------------------------------------------------------
* <Rating>-31</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Pricing
      SUBROUTINE CONV.MARKET.PRICE
*-----------------------------------------------------------------------------
* It is a file routine that converts the old MARKET.PRICE records into the new format. 
*-----------------------------------------------------------------------------
* Modification History :
* 19/06/2006 - GLOBUS_CI_10041946
*              Replace F.WRITE and F.DELETE with WRITE and DELETE respectively.
*
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.MARKET.PRICE
*-----------------------------------------------------------------------------

      GOSUB INITIALISE
      
      GOSUB PROCESS

      RETURN

*
*-----------------------------------------------------------------------------
*
PROCESS:
      NO.PROCESSED = ''
      NO.CREATED = ''
    
      LOOP 
        REMOVE MP.ID FROM MP.ID.LIST SETTING MP.POS
      WHILE MP.ID:MP.POS DO
        R.MP.OLD = ''
        ERR = ''
        CALL F.READ(FN.MARKET.PRICE,MP.ID,R.MP.OLD,F.MARKET.PRICE,ERR)
        IF NOT(ERR) THEN
            NO.MULTIVALUES = DCOUNT(R.MP.OLD<1>,VM) 
            FOR INDX = 1 TO NO.MULTIVALUES
                NEW.MP.ID = ''
                R.MP.NEW = ''
                COMPANY.KEY = FIELD(MP.ID,".",1)
                DATE.KEY = FIELD(MP.ID,".",2)
                SEC.CODE.KEY = R.MP.OLD<1,INDX>
                GOSUB BUILD.NEW.MP.REC
                NO.CREATED+=1
            NEXT INDX 
            DELETE F.MARKET.PRICE, MP.ID
            NO.PROCESSED+=1
        END
      REPEAT 

      CRT "No. Records Processed : ":NO.PROCESSED 
      CRT "No. Records Created : ":NO.CREATED
RETURN     
*
*-----------------------------------------------------------------------------
*
BUILD.NEW.MP.REC:


      IF DATE.KEY EQ '' THEN
          NEW.MP.ID = MP.ID:".":SEC.CODE.KEY
      END ELSE
          NEW.MP.ID = COMPANY.KEY:".":SEC.CODE.KEY:".":DATE.KEY
      END
                
      R.MP.NEW<SC.MP.COMPANY> = COMPANY.KEY
      R.MP.NEW<SC.MP.SECURITY.CODE> = SEC.CODE.KEY
      R.MP.NEW<SC.MP.PRICE.DATE> = DATE.KEY
      R.MP.NEW<SC.MP.LAST.PRICE> = R.MP.OLD<2,INDX>
      R.MP.NEW<SC.MP.TK.CONTROL> = R.MP.OLD<3,INDX>
      R.MP.NEW<SC.MP.TEXT> = R.MP.OLD<4,INDX>
      R.MP.NEW<SC.MP.PRICE.TWO> = R.MP.OLD<5,INDX>
      R.MP.NEW<SC.MP.LAST.UP.PRICE> = R.MP.OLD<6,INDX>

      WRITE R.MP.NEW TO F.MARKET.PRICE, NEW.MP.ID

RETURN     
*
*-----------------------------------------------------------------------------
*
INITIALISE:

      FN.MARKET.PRICE = 'F.MARKET.PRICE'
      F.MARKET.PRICE = ''
      CALL OPF(FN.MARKET.PRICE,F.MARKET.PRICE)
      
      SEL.STMT = "SELECT ":FN.MARKET.PRICE
      MP.ID.LIST = ''
      CALL EB.READLIST(SEL.STMT, MP.ID.LIST,'',SELECTED,SYS.RET.CODE)


      RETURN

*
*-----------------------------------------------------------------------------
*
END
