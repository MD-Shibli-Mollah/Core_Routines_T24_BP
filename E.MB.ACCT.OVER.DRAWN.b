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

*-------------------------------------------------------------------------
* <Rating>-11</Rating>
*-------------------------------------------------------------------------
      $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.ACCT.OVER.DRAWN(ENQUIRY.SELECTION)
*------------------------------------------------------------------------

    GOSUB PROCESS

    RETURN
*--------
PROCESS:
*--------

    IF NOT(ENQUIRY.SELECTION<4,1>) THEN
*
* BUILD array to insert

        ENQ.OPEN = '' ; ENQ.FLDS = '' ;
        ENQ.OPR = '' ; ENQ.DATA = ''
        ENQ.REL.OPR = '' ; ENQ.CLOSE = ''

        CNT = 1

        ENQ.OPEN<CNT> = '('
        ENQ.FLDS<CNT> = '@ID'
        ENQ.OPR<CNT> = 'LK'
        ENQ.DATA<CNT> = "...'0100.'..."
        ENQ.REL.OPR<CNT> = 'OR'
        ENQ.CLOSE<CNT> = ')'

        CNT +=1

        ENQ.OPEN<CNT> = '('
        ENQ.FLDS<CNT> = 'LIMIT.NARRATIVE'
        ENQ.OPR<CNT> = 'EQ'
        ENQ.DATA<CNT> = "''"
        ENQ.CLOSE<CNT> = ')'
        ENQ.REL.OPR<CNT> = ''


        CONVERT @FM TO @VM IN ENQ.OPEN
        CONVERT @FM TO @VM IN ENQ.FLDS
        CONVERT @FM TO @VM IN ENQ.OPR
        CONVERT @FM TO @VM IN ENQ.DATA
        CONVERT @FM TO @VM IN ENQ.REL.OPR
        CONVERT @FM TO @VM IN ENQ.CLOSE



        ENQUIRY.SELECTION<2,1> = ENQ.FLDS
        ENQUIRY.SELECTION<3,1> = ENQ.OPR
        ENQUIRY.SELECTION<4,1> = ENQ.DATA
        ENQUIRY.SELECTION<15,1> = ENQ.REL.OPR
        ENQUIRY.SELECTION<13,1> = ENQ.OPEN
        ENQUIRY.SELECTION<14,1> = ENQ.CLOSE

    END
    RETURN
*-----------------------------------------------------------------------------

END
