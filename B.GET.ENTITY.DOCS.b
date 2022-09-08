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

    $PACKAGE ST.ModelBank
    SUBROUTINE B.GET.ENTITY.DOCS(ENQ.DATA)

* Build routine which will decided to display the documents
* based on the entity type selected.
* Enquiry Name : PERSON.ENTITY.DOCS
*
* MODIFICATION HISTORY:
***********************
*
* 08/10/15 - Defect 1267956 / Task 1494079
*			 Moving the routine from Data to Source
*
****************************************************************

    $USING EB.Template
 

    Y.LOOKUP.ID = ''
    LIST.DATA = 'CUS.LEGAL.DOC.NAME'
    EB.Template.LookupList(LIST.DATA)
    LOOKUP.DATA = LIST.DATA<2>
    CONVERT '_' TO @FM IN LOOKUP.DATA

    ENTITY.TYPE = ''
    ENQ.DATA.FIELDS = ENQ.DATA<2,1>
    ENQ.DATA.OPER = ENQ.DATA<3,1>
    ENQ.DATA.VALUES = ENQ.DATA<4,1>

    LOCATE "DATA.VALUE" IN ENQ.DATA.FIELDS SETTING POS THEN
        ENTITY.TYPE = ENQ.DATA.VALUES<POS>
    END
    IF ENTITY.TYPE = 'PERSON' THEN
        FOR II = 1 TO DCOUNT(LOOKUP.DATA,@FM)
            IF LOOKUP.DATA<II> NE 'INCORP.CERT' THEN
                Y.LOOKUP.ID<-1> = 'CUS.LEGAL.DOC.NAME*':LOOKUP.DATA<II>
            END
        NEXT II
    END ELSE
        FOR II = 1 TO DCOUNT(LOOKUP.DATA,@FM)
            IF LOOKUP.DATA<II> EQ 'INCORP.CERT' THEN
                Y.LOOKUP.ID<-1> = 'CUS.LEGAL.DOC.NAME*':LOOKUP.DATA<II>
            END
        NEXT II
    END
    CONVERT @FM TO ' ' IN Y.LOOKUP.ID
    ENQ.DATA<2,1> = "@ID"
    ENQ.DATA<3,1> = "EQ"
    ENQ.DATA<4,1> = Y.LOOKUP.ID

    RETURN
