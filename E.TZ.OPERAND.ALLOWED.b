* @ValidationCode : MjotNzQzNTU2MjkxOmNwMTI1MjoxNTMxOTE4NzgyNDQwOnNhc2lrdW1hcnY6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTgwNy4yMDE4MDYyMS0wMjIxOjQwOjQw
* @ValidationInfo : Timestamp         : 18 Jul 2018 18:29:42
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : sasikumarv
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 40/40 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201807.20180621-0221
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE TZ.ModelBank
SUBROUTINE E.TZ.OPERAND.ALLOWED(AllowedOperand)
*-----------------------------------------------------------------------------
* NoFile Enquiry Routine to fetch and return only the Allowed Operands for an Attribute
* defined in the Transaction Stop Condition
*-----------------------------------------------------------------------------
*PARAMETER:
* AllowedOperand - IN/OUT   - IN    - Null
*                           - OUT   - Contains the Operands data to be displayed
*-----------------------------------------------------------------------------
* Modification History :
*
* 07-06-2018    - Enhancement 2580979 / Task 2623448
*                 No file enquiry changes for model configuration
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING TZ.Config
    $USING TZ.Contract
    $USING EB.Reports
*-----------------------------------------------------------------------------
    GOSUB Initialise
    GOSUB Process

RETURN
*-----------------------------------------------------------------------------
Initialise:
*Variable initialisation
    AllowedOperand=''
    Rnew = ''
    StopCondition=''
    stopCondRec=''
    readError=''
    Attribute=''
    attrName=''
    allowedOper=''
    
RETURN
*-----------------------------------------------------------------------------
Process:
    
    Rnew = EB.SystemTables.getDynArrayFromRNew()    ;*get the StopInstruction Record from R.NEW

    LOCATE "ATTRIBUTE" IN EB.Reports.getDFields()<1> SETTING AttrPos THEN   ;*find the incoming Attribute position
        Attribute = EB.Reports.getDRangeAndValue()<AttrPos> ;*get the Attribute value
    END ELSE
        RETURN
    END

    StopCondition = Rnew<TZ.Contract.TransactionStopInstruction.TsiStopCondition>   ;*get the Stop Condition
    IF StopCondition NE "" THEN ;*check to see whether Stop Condition Id has been entered or not
        stopCondRec = TZ.Config.TransactionStopCondition.Read(StopCondition, readError) ;*if id is entered, read the stop condition record with that Id
    END ELSE
        stopCondRec = TZ.Config.TransactionStopCondition.Read("DEFAULT", readError) ;*else read the stop condition record with id as 'DEFAULT'
    END

    attrName = stopCondRec<TZ.Config.TransactionStopCondition.tzTscAttributeName>   ;*get the Attributes defined in Stop Condition
    allowedOper = stopCondRec<TZ.Config.TransactionStopCondition.tzTscAllowedOperand>   ;*get the Allowed Operands defined in Stop Condition
    
    FIND Attribute IN attrName SETTING Fpos,Mpos,Spos THEN  ;*find the incoming Attribute position in StopCondition
        AllowedOperand = allowedOper<1,Mpos>                ;*get the list of allowed operands
        CHANGE @SM TO @FM IN AllowedOperand
        CHANGE 'EQ' TO 'EQ*Equal' IN AllowedOperand
        CHANGE 'NE' TO 'NE*Not Equal' IN AllowedOperand
        CHANGE 'LE' TO 'LE*Less or Equal' IN AllowedOperand
        CHANGE 'LT' TO 'LT*Less Than' IN AllowedOperand
        CHANGE 'GE' TO 'GE*Greater or Equal' IN AllowedOperand
        CHANGE 'GT' TO 'GT*Greater Than' IN AllowedOperand
        CHANGE 'RG' TO 'RG*Range' IN AllowedOperand
        CHANGE 'CT' TO 'CT*Contains' IN AllowedOperand
        CHANGE 'NC' TO 'NC*Not Contains' IN AllowedOperand
    END

RETURN
*-----------------------------------------------------------------------------
END
