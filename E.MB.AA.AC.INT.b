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
* <Rating>-3</Rating>
*-----------------------------------------------------------------------------
* Subroutine Type : Subroutine

* Incoming        : O.DATA

* Outgoing        : O.DATA Common Variable

* Attached to     : AA.DETAILS.INT

* Attached as     :Conversion Routine

* Primary Purpose : To get the last multivalue from a list of multivalues

* Incoming        : Common variable O.DATA Which contains  the
*                 : enquiry field from where this routine gets a call.

* Change History  :

* Version         : First Version


************************************************************

    $PACKAGE AA.ModelBank
    SUBROUTINE E.MB.AA.AC.INT
    
    $USING EB.Reports
    

*Assinging a Data present in Common Variable O.DATA to a Varibale MULTI.VALUE

    MULTI.VALUE=EB.Reports.getOData()

*Count the data present in a Variable MULTI.VALUE Separated by Value Marker, and Store the result in MULTI.VALUE.COUNT

    MULTI.VALUE.COUNT=DCOUNT(MULTI.VALUE,@VM)

* Pick the last multi value from the variable MULTI.VALUE and assign the values to O.DATA

    LAST.MULTI.VALUE=FIELD(MULTI.VALUE,@VM,MULTI.VALUE.COUNT)

    EB.Reports.setOData(LAST.MULTI.VALUE)

    RETURN

END
