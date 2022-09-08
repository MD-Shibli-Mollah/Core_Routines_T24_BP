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

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoSecurityPositionUpdate
      SUBROUTINE CONV.SECURITY.TRANS.G10.1(ID,YREC,FILE)

$INSERT I_EQUATE
$INSERT I_COMMON

*
** Open files
*
      F.SEC.TRADE = "F.SEC.TRADE"
      CALL OPF("F.SEC.TRADE",F.SEC.TRADE)
*
      F.SECURITY.TRANSFER = "F.SECURITY.TRANSFER"
      CALL OPF("F.SECURITY.TRANSFER",F.SECURITY.TRANSFER)
*
      REC.ID = FIELD(ID,".",1)
*
      TRADE.TIME = ""

      BEGIN CASE

         CASE ID[1,4] = "SCTR"           ; * A SEC.TRADE
            CALL F.READ("F.SEC.TRADE",
               REC.ID,
               R.SEC.TRADE,
               F.SEC.TRADE,
               READ.ERR)

            IF R.SEC.TRADE THEN
               IF R.SEC.TRADE<110> THEN
                  TRADE.TIME = R.SEC.TRADE<110>
               END ELSE
                  TRADE.TIME = R.SEC.TRADE<128>[7,2]:":":R.SEC.TRADE<128>[9,2]
               END
            END

         CASE ID[1,4] = "SECT"

            CALL F.READ("F.SECURITY.TRANSFER",
               REC.ID,
               R.SECURITY.TRANSFER,
               F.SECURITY.TRANSFER,
               READ.ERR)

            IF R.SECURITY.TRANSFER THEN
               TRADE.TIME = R.SECURITY.TRANSFER<64>[7,2]:":":R.SECURITY.TRANSFER<64>[9,2]
            END

      END CASE

      YREC<62> = TRADE.TIME

      RETURN
   END
