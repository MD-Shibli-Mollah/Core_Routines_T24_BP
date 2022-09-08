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
* <Rating>-64</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Constraints
      SUBROUTINE CONV.DX.TC.FILE.G12201
      
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.DX.TRADING.CONSTRAINT
      
      GOSUB LIVE.FILE    
      
      GOSUB DOLLAR.NAU.FILE    
      
      GOSUB DOLLAR.HIS.FILE    
      
      RETURN
      
*================================================================================
LIVE.FILE:
      
      
      
      FN.DX.TRADING.CONSTRAINT = "F.DX.TRADING.CONSTRAINT"
      F.DX.TRADING.CONSTRAINT = ""
      CALL OPF(FN.DX.TRADING.CONSTRAINT,F.DX.TRADING.CONSTRAINT)
      
      THIS.FILE = FN.DX.TRADING.CONSTRAINT
      SELECT.STMT = "SELECT ":THIS.FILE
      CRT SELECT.STMT
      NO.RECORD.SELECTED = ""
      CALL EB.READLIST(SELECT.STMT,RECORD.LIST,"",NO.RECORD.SELECTED, RTN.CODE)
      CRT NO.RECORD.SELECTED:" Records selected"
      LOOP
         REMOVE RECORD.ID FROM RECORD.LIST SETTING RECORD.MARK
      WHILE RECORD.ID : RECORD.MARK AND NOT(E) AND ETEXT="" DO
         DELETE F.DX.TRADING.CONSTRAINT,RECORD.ID
         CRT RECORD.ID:" - Deleted from ":THIS.FILE
      REPEAT
      
      RETURN
*================================================================================
      
DOLLAR.NAU.FILE:
      
      
      
      FN.DX.TRADING.CONSTRAINT$NAU = "F.DX.TRADING.CONSTRAINT$NAU"
      F.DX.TRADING.CONSTRAINT$NAU = ""
      CALL OPF(FN.DX.TRADING.CONSTRAINT$NAU,F.DX.TRADING.CONSTRAINT$NAU)
      
      THIS.FILE = FN.DX.TRADING.CONSTRAINT$NAU
      SELECT.STMT = "SELECT ":THIS.FILE
      CRT SELECT.STMT
      NO.RECORD.SELECTED = ""
      CALL EB.READLIST(SELECT.STMT,RECORD.LIST,"",NO.RECORD.SELECTED, RTN.CODE)
      CRT NO.RECORD.SELECTED:" Records selected"
      LOOP
         REMOVE RECORD.ID FROM RECORD.LIST SETTING RECORD.MARK
      WHILE RECORD.ID : RECORD.MARK AND NOT(E) AND ETEXT="" DO
         DELETE F.DX.TRADING.CONSTRAINT$NAU,RECORD.ID
         CRT RECORD.ID:" - Deleted from ":THIS.FILE
      REPEAT
      
      
      RETURN
*================================================================================
      
DOLLAR.HIS.FILE:
      
      
      
      FN.DX.TRADING.CONSTRAINT$HIS = "F.DX.TRADING.CONSTRAINT$HIS"
      F.DX.TRADING.CONSTRAINT$HIS = ""
      CALL OPF(FN.DX.TRADING.CONSTRAINT$HIS,F.DX.TRADING.CONSTRAINT$HIS)
      
      THIS.FILE = FN.DX.TRADING.CONSTRAINT$HIS
      SELECT.STMT = "SELECT ":THIS.FILE
      CRT SELECT.STMT
      NO.RECORD.SELECTED = ""
      CALL EB.READLIST(SELECT.STMT,RECORD.LIST,"",NO.RECORD.SELECTED, RTN.CODE)
      CRT NO.RECORD.SELECTED:" Records selected"
      LOOP
         REMOVE RECORD.ID FROM RECORD.LIST SETTING RECORD.MARK
      WHILE RECORD.ID : RECORD.MARK AND NOT(E) AND ETEXT="" DO
         DELETE F.DX.TRADING.CONSTRAINT$HIS,RECORD.ID
         CRT RECORD.ID:" - Deleted from ":THIS.FILE
      REPEAT
      
      
      RETURN
*================================================================================
      
* <new subroutines>
      END
