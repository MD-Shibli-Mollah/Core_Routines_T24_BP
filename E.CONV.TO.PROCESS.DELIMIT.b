* @ValidationCode : MjotNTYyMjI4MDU3OkNwMTI1MjoxNTM5MDYxNzU1OTE2Om5pbG9mYXJwYXJ2ZWVuOjE6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxODEwLjIwMTgwOTE0LTAyMzk6MTE6MTE=
* @ValidationInfo : Timestamp         : 09 Oct 2018 10:39:15
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nilofarparveen
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 11/11 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201810.20180914-0239
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AI.ModelBank
SUBROUTINE E.CONV.TO.PROCESS.DELIMIT
*-----------------------------------------------------------------------------
* Conversion Routine written to change ~ to VM in O.DATA
* Format the enquiry output and convert to VM
* Routine attached to Enquiry AI.MANAGE.INTERNET.ARRANGEMENT, AI.MANAGE.INTERNET.ARRANGEMENT.SEE
*-----------------------------------------------------------------------------
* Modification History :
*
* 06/10/2018 - Def-2788599 / Task 2799853
*              2799853: Optimisation of AI.MANAGE.INTERNET.ARRANGEMENT enquiry
*
*-----------------------------------------------------------------------------
    $USING EB.Reports
    
    GOSUB INITIALIZE    ;* Intialise the vaiables used
    GOSUB PROCESS       ;* Format the enquiry output and convert to VM
RETURN
*------------------------------------------------------------------------------
INITIALIZE:
*-------
    tmp.O.DATA = ""
RETURN
*------------------------------------------------------------------------------
PROCESS:
*-------
    tmp.O.DATA = EB.Reports.getOData() ;* Getting the O.DATA
    CONVERT '~' TO @VM IN tmp.O.DATA    ;* Converting the ~ symblol to process @VM
    EB.Reports.setVmCount(DCOUNT(tmp.O.DATA, @VM))  ;* Count the number of VM in tmp.O.DATA and assign VM.COUNT
    EB.Reports.setOData(tmp.O.DATA) ;* Assign the value to O.DATA
    EB.Reports.setOData(EB.Reports.getOData()<1,EB.Reports.getVc()>)
RETURN
END
*-----------------------------------------------------------------------------

 
