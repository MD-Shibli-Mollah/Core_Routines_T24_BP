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

* Version 2 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>93</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FD.Contract
      SUBROUTINE CONV.FD.FIDUCIARY.G7(YID, YREC, YFILE)
*************************************************************************
* This record routine is called from CONVERSION.DETAILS.RUN and is used
* to move the necesary fields around according to the new file layout of
* the principal change fields and to populate the ORDER.ID field.
*
* NB This conversion should be run BEFORE the pooling of notice contracts
* is introduced as the ORDER.ID field is taken from the first value of
* the ORDER.NOS field.
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
*************************************************************************
*
$INSERT I_COMMON
$INSERT I_EQUATE


* Do not process unless there are principal change fields present

      IF YREC<44> THEN


* Initialise the variables

         OLD.REC = YREC
         NO.OF.CHANGES = DCOUNT(OLD.REC<43+1>, VM)
         VALUE.POS = ''
         NEW.DATES = ''
         NEW.IDS = ''
         NEW.PRIN = ''
         NEW.STAT = ''
         IF NO.OF.CHANGES = 0 THEN NO.OF.CHANGES = 1

* Loop through each principal change

         LOOP
            VALUE.POS +=1
         WHILE VALUE.POS <= NO.OF.CHANGES

* Try and find the date in the new fields

            LOCATE OLD.REC<44+1, VALUE.POS> IN NEW.DATES<1> BY 'AR' SETTING INS.POS THEN

* If the date is found then add the change in at the end

               NEW.IDS<INS.POS, -1> = OLD.REC<35,1>
               NEW.PRIN<INS.POS, -1> = OLD.REC<43+1, VALUE.POS>
               NEW.STAT<INS.POS, -1> = OLD.REC<45+1, VALUE.POS>

            END ELSE

* Otherwise insert the new date

               INS OLD.REC<44+1, VALUE.POS> BEFORE NEW.DATES<INS.POS>
               INS OLD.REC<35,1> BEFORE NEW.IDS<INS.POS, 1>
               INS OLD.REC<45+1, VALUE.POS> BEFORE NEW.STAT<INS.POS, 1>
               INS OLD.REC<43+1, VALUE.POS> BEFORE NEW.PRIN<INS.POS,1>

            END

         REPEAT

* Once all changes have been processed copy the information

         YREC<43> = LOWER(NEW.DATES)
         YREC<44> = LOWER(NEW.IDS)
         YREC<45> = LOWER(NEW.PRIN)
         YREC<46> = LOWER(NEW.STAT)
      END


* Processing finished.

      RETURN
   END
