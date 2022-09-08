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
* <Rating>122</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.Customer
      SUBROUTINE CONV.CUSTOMER.ACT.G13.2
*
** This subroutine will convert the existing CUSTOMER.ACT file to be
** FIN level from CUS. It will move all records from the original cus
** level into the fin file.
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY.CHECK
*
      F.COMPANY.CHECK = ""
      CALL OPF("F.COMPANY.CHECK", F.COMPANY.CHECK)
*
      READ COMP.CHECK.REC FROM F.COMPANY.CHECK, "CUSTOMER" ELSE COMP.CHECK.REC = ""
*
      CUS.COMPANY.LIST = COMP.CHECK.REC<EB.COC.COMPANY.MNE>
      USING.LIST = COMP.CHECK.REC<EB.COC.USING.MNE>
*
      CO.CNT = ""
      LOOP
         CO.CNT +=1
      WHILE CUS.COMPANY.LIST<CO.CNT>
*
** Get a list of all companies that share the customer file
** plus the customer company itself
*
         MNE.LIST = CUS.COMPANY.LIST<CO.CNT>:VM:RAISE(USING.LIST<CO.CNT>)
         MNEMONIC = CUS.COMPANY.LIST<CO.CNT>
         ORIG.CUSTOMER.ACT = "F":MNEMONIC:".CUSTOMER.ACT"
*
         OPEN "", ORIG.CUSTOMER.ACT TO F.ORIG.CUSTOMER.ACT THEN
*
            SEL.STMT = "SELECT ":ORIG.CUSTOMER.ACT
            CUS.ACT.LIST = ""
            CALL EB.READLIST(SEL.STMT, CUS.ACT.LIST, "", "", "")
*
            IF CUS.ACT.LIST THEN
*
               F.NEW.CUSTOMER.ACT = ""
               FN.NEW.CUSTOMER.ACT = "F":MNEMONIC:".CUSTOMER.ACT.HIST"
               CALL OPF(FN.NEW.CUSTOMER.ACT, F.NEW.CUSTOMER.ACT)
*
               CUS.ACT.LIST = CUS.ACT.LIST
               LOOP
                  REMOVE CUS.ACT.ID FROM CUS.ACT.LIST SETTING YD
               WHILE CUS.ACT.ID:YD
*
** Write out one record per customer, history numbers in the
** main record
*
                  CUST.ID = CUS.ACT.ID[";",1,1]
                  HIST.NO = CUS.ACT.ID[";",2,1]
                  NEW.CUS.REC = ""
                  WRITE NEW.CUS.REC TO F.NEW.CUSTOMER.ACT, CUST.ID:";":HIST.NO
*
*
** Now delete the old style key from the old file
** There will now be records in the new format in the main
** CUS company
*
                  DELETE F.ORIG.CUSTOMER.ACT, CUS.ACT.ID
*
               REPEAT
*
            END
*
         END
*
      REPEAT
*
      RETURN
*
   END
