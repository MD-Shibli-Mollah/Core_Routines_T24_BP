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
* <Rating>47</Rating>
*-----------------------------------------------------------------------------
      SUBROUTINE CONV.ENQUIRY.REPORT.G10.1(YID, YREC, YFILE)
*-----------------------------------------------------------------------------
* This routine simply converts the SM chars to spaces in the List field,
* to move them into one logn field.
*-----------------------------------------------------------------------------
*
* 23/04/03 - CI_100008505
*            Conversion for SELECTION, OPERAND, LIST
*
$INSERT I_COMMON
$INSERT I_EQUATE

*      CONVERT SM TO ' ' IN YREC<5>       ; * CI_10008505 Starts

      VM.COUNT = '' ; CNT = '' ; OLD.VAL = '' ; IS.PRESENT = ''

      VM.COUNT = DCOUNT(YREC<2>, VM)
      IF VM.COUNT = 1 THEN

* Convert the records only if the YREC<2> is not expanded
         CNT = DCOUNT(YREC<3>, VM)
         IF CNT > 1 THEN
            OLD.VAL = YREC<3,2>
            IS.PRESENT = INDEX(YREC<3,1>, OLD.VAL, 1)

* Remove the duplicate values for released records

            IF IS.PRESENT THEN
               FOR I = 2 TO CNT
                  DEL YREC<3,2>
                  DEL YREC<4,2>
                  DEL YREC<5,2>
                  DEL YREC<6,2>
               NEXT I
            END ELSE

               CONVERT VM TO SM IN YREC<3>
               CONVERT VM TO SM IN YREC<4>
               CONVERT VM TO SM IN YREC<5>
               CONVERT VM TO SM IN YREC<6>
            END
         END
      END                                ; * CI_100008505 Ends
      RETURN
   END
