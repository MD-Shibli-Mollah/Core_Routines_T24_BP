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
* <Rating>781</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.Config
      SUBROUTINE CONV.DATE.CHANGE.BATCH.G14.0
*
*****************************************************************************
*Modifications
*
* 26/08/03 - BG_100005037
*            If record already exists in UNAUTHORISED file then don't do anything
*************************************************************************



$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.BATCH
$INSERT I_F.COMPANY
*
* This convrsion will create DATE.CHANGE batch records
* in each company in a multi-co site. The job has moved
* from INT to FIN.
*
      F.BATCH = ''
      CALL OPF("F.BATCH", F.BATCH)
      F.BATCH$HIS = ""
      CALL OPF("F.BATCH$HIS", F.BATCH$HIS)
* BG_100005037 S
      F.BATCH$NAU = ''
      CALL OPF("F.BATCH$NAU",F.BATCH$NAU)

* BG_100005037 E

      F.COMPANY = ''
      CALL OPF("F.COMPANY", F.COMPANY)
*
      TIME.STAMP = TIMEDATE()
      X = OCONV(DATE(),"D-")
      X = X[9,2]:X[1,2]:X[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]         ; * Date time for Write
*
      MAIN.BATCH = ''

*
      READ R.MAIN.BATCH FROM F.BATCH, "DATE.CHANGE" THEN     ; * Single record exists so convert
*
         SEL.STMT = "SELECT F.COMPANY"
         CO.LIST = ""
         NO.SEL = ''
         CALL EB.READLIST(SEL.STMT, CO.LIST, "", NO.SEL, "")
*
         IF NO.SEL GT 1 THEN             ; * If 1 it is single company
            LOOP
               REMOVE CO.CODE FROM CO.LIST SETTING YD
            WHILE CO.CODE:YD
               IF CO.CODE NE ID.COMPANY THEN
                  READ COMP.REC FROM F.COMPANY, CO.CODE THEN ELSE COMP.REC = ''
               END ELSE
                  MATBUILD COMP.REC FROM R.COMPANY
               END
               COMP.MNE = COMP.REC<3>    ; * Company mnemonic
               IF COMP.REC<33> = COMP.MNE THEN     ; * Only create for non shared FIN files FINAN.FINAN.MNE
                  IF COMP.MNE THEN


                     NEW.COMP.ID = COMP.MNE:"/DATE.CHANGE"

*BG_100005037 S
* If there is an existing unauthorised record the  don't do anything
                     R.NAU.BATCH = ""
                     READ R.NAU.BATCH FROM F.BATCH$NAU, NEW.COMP.ID ELSE R.NAU.BATCH = ""

                     IF R.NAU.BATCH = "" THEN

* BG_100005037 E
                        NEW.BATCH.REC = R.MAIN.BATCH
                        NEW.BATCH.REC<17> = 1      ; * Curr No
                        NEW.BATCH.REC<18> = "SY_CONV.BATCH.DATES.G14.0"          ; * Inputter
                        NEW.BATCH.REC<19> = X      ; * Date Time
                        NEW.BATCH.REC<20> = TNO:"_":OPERATOR           ; * Author
                        NEW.BATCH.REC<21> = CO.CODE          ; * Company Code
                        WRITE NEW.BATCH.REC TO F.BATCH, NEW.COMP.ID

                     END                 ; * BG_100005037

                  END
               END
            REPEAT
*
** Write to History old record and then delete
*
            WRITE R.MAIN.BATCH TO F.BATCH$HIS, "DATE.CHANGE;":R.MAIN.BATCH<17>
            R.MAIN.BATCH<16> = "REVE"
            R.MAIN.BATCH<17> += 1
            R.MAIN.BATCH<18> = "SY_CONV.BATCH.DATES.G14.0"
            R.MAIN.BATCH<19> = X
            R.MAIN.BATCH<20> = TNO:"_":OPERATOR
            WRITE R.MAIN.BATCH TO F.BATCH$HIS, "DATE.CHANGE;":R.MAIN.BATCH<17>
            DELETE F.BATCH, "DATE.CHANGE"
*
         END
*
      END

      *
      RETURN
*
   END
