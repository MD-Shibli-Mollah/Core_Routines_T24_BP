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
* <Rating>-105</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RP.Contract
      SUBROUTINE CONV.REPO.POSITION.G13.1.PRE
*-----------------------------------------------------------------------------
* A new lookup key has been created on REPO.POSITION. To update this field all REPO's that have not
* matured need to be selected & then update the REPO.POSITION.
* This routine will provide an array populated with items that need updating & pass them into the
* record conversion routine.
*-----------------------------------------------------------------------------
* M O D I F I C A T I O N S
*-----------------------------------------------------------------------------
* 08/10/02 - GLOBUS_BG_100002318 - REPO Prices Fields
*            Create this program.
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE

$INSERT I_CONV.REPO.G13.1

$INSERT I_F.SECURITY.MASTER
$INSERT I_F.SECURITY.TRANSFER
$INSERT I_F.SUB.ASSET.TYPE
$INSERT I_F.REPO
$INSERT I_F.REPO.TYPE
$INSERT I_F.VAULT.PARAMETER
*-----------------------------------------------------------------------------

      GOSUB INITIALISE

      GOSUB SELECT.RECORDS

      GOSUB PROCESS.RECORDS

      RETURN

*-----------------------------------------------------------------------------
* S U B R O U T I N E S
*-----------------------------------------------------------------------------
INITIALISE:

      FN.REPO = 'F.REPO'
      F.REPO = ''
      CALL OPF(FN.REPO, F.REPO)

      FN.SECURITY.MASTER = 'F.SECURITY.MASTER'
      F.SECURITY.MASTER = ''
      CALL OPF(FN.SECURITY.MASTER, F.SECURITY.MASTER)

      FN.SUB.ASSET.TYPE = 'F.SUB.ASSET.TYPE'
      F.SUB.ASSET.TYPE = ''
      CALL OPF(FN.SUB.ASSET.TYPE, F.SUB.ASSET.TYPE)

      FN.VAULT.PARAMETER = 'F.VAULT.PARAMETER'
      F.VAULT.PARAMETER = ''
      CALL OPF(FN.VAULT.PARAMETER, F.VAULT.PARAMETER)

      FN.REPO.TYPE = 'F.REPO.TYPE'
      F.REPO.TYPE = ''
      CALL OPF(FN.REPO.TYPE, F.REPO.TYPE)

      FN.SECURITY.TRANSFER = 'F.SECURITY.TRANSFER'
      F.SECURITY.TRANSFER = ''
      CALL OPF(FN.SECURITY.TRANSFER, F.SECURITY.TRANSFER)

      ERR = ''
      R.VAULT.PARAMETER = ''
      CALL F.READ('F.VAULT.PARAMETER', ID.COMPANY, R.VAULT.PARAMETER, F.VAULT.PARAMETER, ERR)

      RP.CONV.ARRAY = ''                 ; * Common Variable to store list
      NEW.MV.POS = 0

      RETURN

*-----------------------------------------------------------------------------
SELECT.RECORDS:
* This will select all records which have not matured & are DEPOSIT's (REPO)

      COMMAND = 'SELECT ':FN.REPO:' WITH MATURITY.DATE >= ':TODAY:' AND WITH TRANSACTION.INDEX = "DEPOSIT"'
      REPO.LIST = ''
      SELECTED = ''
      SRC = ''

      CALL EB.READLIST(COMMAND, REPO.LIST, '', SELECTED, SRC)

      RETURN

*-----------------------------------------------------------------------------
PROCESS.RECORDS:
* This will build the array with the values ready for the next record routine.

      LOOP                               ; * Loop through each REPO that needs to be updated
         REMOVE REPO.ID FROM REPO.LIST SETTING MORE.REPOS
      WHILE REPO.ID:MORE.REPOS
         R.REPO = ''
         ERR = ''
         CALL F.READ(FN.REPO, REPO.ID, R.REPO, F.REPO, ERR)

         SECURITY.LIST = R.REPO<RP.NEW.SEC.CODE>
         IF ERR = '' THEN
            SEC.POS = 0
            LOOP                         ; * Loop through each security on the REPO record
               REMOVE SECURITY.ID FROM SECURITY.LIST SETTING MORE.SECURITIES
            WHILE SECURITY.ID:MORE.SECURITIES
               SEC.POS += 1
               GOSUB CREATE.POSITION.KEY
               GOSUB UPDATE.ARRAY
            REPEAT
         END
      REPEAT

      RETURN

*-----------------------------------------------------------------------------
CREATE.POSITION.KEY:
* This will create the key that can be used to update the REPO.POSITION file.

*     Read SECURITY.MASTER
      R.SEC.MASTER = ''
      CALL F.READ(FN.SECURITY.MASTER, SECURITY.ID, R.SEC.MASTER, F.SECURITY.MASTER, '')
      SUB.ASSET.TYPE = R.SEC.MASTER<SC.SCM.SUB.ASSET.TYPE>
      INTEREST.RATE = R.SEC.MASTER<SC.SCM.INTEREST.RATE>
      ACCRUAL.START.DATE = R.SEC.MASTER<SC.SCM.ACCRUAL.START.DATE>

*     Look up Kassenobligationen
      KO.FLAG = ''
      CALL DBR('SUB.ASSET.TYPE':FM:SC.CSG.KASSENOBLIGATIONEN, SUB.ASSET.TYPE, KO.FLAG)
      IF (KO.FLAG = 'YES') AND (ACCRUAL.START.DATE EQ '') THEN
         KO.PROCESSING = 1               ; * Kassenobligationen
      END ELSE
         KO.PROCESSING = 0               ; * All other processing.
      END

      NEW.BASE.POS.KEY = ".":SECURITY.ID:"."
      K.NOMINEE.CODE = ''

*     Look up Nominee Code
      LOCATE R.REPO<RP.NEW.DEPO, SEC.POS> IN R.VAULT.PARAMETER<SC.VPR.DEPOSITORY, 1> SETTING VAULT.POS THEN
         IF R.VAULT.PARAMETER<SC.VPR.NOMINEE, VAULT.POS> = 'YES' THEN
            K.NOMINEE.CODE = R.VAULT.PARAMETER<SC.VPR.NOMINEE.CODE, VAULT.POS>
         END
      END

      IF KO.PROCESSING THEN
         INT.RATE = ''
         NEW.BASE.POS.KEY := R.REPO<RP.NEW.DEPO, SEC.POS>:".":K.NOMINEE.CODE:'.':R.REPO<RP.MATURITY.DATE>:'..'
      END ELSE
         NEW.BASE.POS.KEY := R.REPO<RP.NEW.DEPO, SEC.POS>:".":K.NOMINEE.CODE:".."
      END

*     Set the correct portfolio
      K.REPO.TYPE = ''
      CALL DBR('REPO.TYPE':FM:RP.TYP.CUSTOMER.REPO, R.REPO<RP.REPO.TYPE>, K.REPO.TYPE)
      IF K.REPO.TYPE[1,1] = 'Y' THEN
         NEW.REPO.PORT = R.REPO<RP.CUST.PORTFOLIO>
      END ELSE
         NEW.REPO.PORT = R.REPO<RP.BANK.PORTFOLIO>
      END

      NEW.POS.KEY = NEW.REPO.PORT:NEW.BASE.POS.KEY

      SUB.ACCOUNT = R.REPO<RP.SUB.ACCOUNT, SEC.POS>

      NEW.POS.KEY := '.':SUB.ACCOUNT

      RETURN

*-----------------------------------------------------------------------------
UPDATE.ARRAY:

      LOCATE NEW.POS.KEY IN RP.CONV.ARRAY<1, 1> SETTING MV.POS THEN
         RP.CONV.ARRAY<2, MV.POS, -1> = REPO.ID
*        If no CLEAN.PRICE then look up price from SECURITY.TRANSFER
         IF R.REPO<RP.CLEAN.PRICE, SEC.POS> = '' THEN
            K.PRICE = ''
            CALL DBR('SECURITY.TRANSFER':FM:SC.STR.PRICE, R.REPO<RP.ST.CONTRACT.ID, SEC.POS>, K.PRICE)
            RP.CONV.ARRAY<3, MV.POS, -1> = K.PRICE
         END ELSE
            RP.CONV.ARRAY<3, MV.POS, -1> = R.REPO<RP.CLEAN.PRICE, SEC.POS>
         END
         RP.CONV.ARRAY<4, MV.POS, -1> = R.REPO<RP.NEW.NOMINAL, SEC.POS> * -1
      END ELSE
         NEW.MV.POS += 1
         RP.CONV.ARRAY<1, NEW.MV.POS> = NEW.POS.KEY
         RP.CONV.ARRAY<2, NEW.MV.POS, -1> = REPO.ID
         RP.CONV.ARRAY<3, NEW.MV.POS, -1> = R.REPO<RP.CLEAN.PRICE, SEC.POS>
         RP.CONV.ARRAY<4, NEW.MV.POS, -1> = R.REPO<RP.NEW.NOMINAL, SEC.POS> * -1
      END

      RETURN

*-----------------------------------------------------------------------------
   END
