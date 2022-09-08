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
* <Rating>-39</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RE.ModelBank
    SUBROUTINE E.PLCATEGORY.VAL(ENQUIRY.DATA)
*-----------------------------------------------------------------------------
*   MODIFICATION HISTORY
*   ********************
*
* 31/5/2010 - Defect - 50619, Task - 53786
*             Creation of BUILD.ROUTINE to be attached in the Enquiry
*             CATEG.ENT.BOOK.STD. This will validate the PL.CATEGORY inputted
*             so that only one category is supplied.
*             This will solve the indexing problem faced in Oracle environment when
*             the DUMMY records created in CATEG.ENTRY is referred by local developments.
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Insert files </desc>  
    $USING EB.Reports
    $USING RE.ModelBank
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main Process>
*** <desc>Main Process </desc>
    GOSUB INTIALISATION ; *Initialisation of variables
    GOSUB PROCESS ; *Process
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INTIALISATION>
INTIALISATION:
*** <desc>Initialisation of variables </desc>
    YCATEG.LIST = ""  ;* The list of categories entered.
    YCATEGORY.POS = 0 ;* The position of category values.
    EB.Reports.setEnqError("");*  Error if more than one category supplied.
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process>
PROCESS:
*** <desc>Process </desc>

    LOCATE "PL.CATEGORY" IN ENQUIRY.DATA<2,1> SETTING YCATEGORY.POS THEN
        YCATEG.LIST = ENQUIRY.DATA<4,YCATEGORY.POS>
        IF DCOUNT(YCATEG.LIST," ") GT 1 THEN
            EB.Reports.setEnqError("Only one category allowed")
        END
    END ELSE
        RETURN
    END
    RETURN
*** </region>
*-----------------------------------------------------------------------------

    END
