* @ValidationCode : MjotNzczNzQ2MTM2OkNwMTI1MjoxNTk5NTY1NjM0MDgzOmpnb2R3aW46OTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNi4yMDIwMDUyNy0wNDM1OjYwOjQw
* @ValidationInfo : Timestamp         : 08 Sep 2020 17:17:14
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jgodwin
* @ValidationInfo : Nb tests success  : 9
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 40/60 (66.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-60</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE AA.GET.EXTERNAL.APPLICATION(SystemId,ContractId,ApplicationId)
*-----------------------------------------------------------------------------
*** <region name= Synopsis of the method>
***
* Program Description
*
* This subroutine will give the version name / application name for an external application
* if we provide system id and contract id for the external application(Moved the logic from E.CONV.AA.TXN.VER).
* Its will map the AAA>SYSTEM.ID & AAA>CONTRACT.ID to the corresponding application
*** </region>
*-----------------------------------------------------------------------------
* @uses         : CacheRead
* @access       : Punlic
* @stereotype   : subroutine
* @author       : hariprasath@temenos.com
*-----------------------------------------------------------------------------

*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
* Input
* SystemId      - System id for an external application.
* ContractId    - External application key
* Output
* ApplicationId - External application name / version name
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History
*
* 15/10/12 - Enhancement : 1434844
*            Task : 1466414
*            Get cashflow details required for PM
*
* 30/11/15 - Defect : 1544718 / Task : 1549689
*            Phase2 - Can't View DD Transactions in Arrangement Overview
*
* 27/05/16 - Task : 1745424
*            Defect : 1744420
*            For AC.ACCOUNT.LINK and AC.CASH.POOL transaction we should open AAA record to view/Reverse
*
* 07/09/18 - Task : 2758117
*            Defect : 2753681
*            Unable to view DD records from Overview screen activity log
*
*   22/01/20 - Enhancement : 3503807
*              Task : 3548870
*              To return give the version name / application name for an external financial arrangement
*
* 05/07/20 - Task : 3838785
*            Defect : 3829549
*            Incorrect reversal of activity which is linked with payment order.
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
***
    $USING EB.DataAccess
    $USING EB.SystemTables

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main Process>
***

    GOSUB Init
    GOSUB Process
    
RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc> Initialise the varibles</desc>
Init:

    ApplicationId = ""
*** </region>

*-----------------------------------------------------------------------------
*** <region name= Process>
*** <desc>Get the application name</desc>
Process:

    IF SystemId EQ 'AC' AND FIELD(ContractId,'-',1) EQ 'AZ' THEN
        SystemId = 'AZ'
    END
     
    IF SystemId EQ '' AND ContractId[1,2] EQ 'MD' THEN
        SystemId = 'MD'
    END

    IF SystemId EQ '' AND ContractId[1,2] EQ 'TF' THEN
        SystemId = 'TF'
    END
    
    EB.DataAccess.CacheRead('F.EB.SYSTEM.ID',SystemId,REbSystemRecord,ER)
    ApplicationId = REbSystemRecord<EB.SystemTables.SystemId.SidApplication>  ;* Just read and get the application

    IF (SystemId EQ 'IC1' OR SystemId EQ 'IC2' OR SystemId EQ 'IC3' OR SystemId EQ 'IC4' OR SystemId EQ 'IC5') THEN
        IF NOT(FIELD(ContractId,'-',2)) THEN
            ApplicationId= ""
        END
    END

    GOSUB GetApplinBasedTransaction

RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= Get Applin Based Transaction>
*** <desc>Some tricky applications that will not get the application name direcly form EB.SYSTEM.ID</desc>
GetApplinBasedTransaction:


    BEGIN CASE

        CASE SystemId EQ 'AC'
            ApplicationId = 'AC.CHARGE.REQUEST'

        CASE SystemId MATCHES 'AA':@VM:'ACCP':@VM:'ACSW'
            ApplicationId = 'AA.ARRANGEMENT.ACTIVITY,AA'

        CASE SystemId EQ 'AAAA'
            ApplicationId = 'AA.ARRANGEMENT.ACTIVITY,AA.TXN'

        CASE SystemId EQ 'CC'
            ApplicationId = 'CARD.ISSUE'

        CASE SystemId EQ 'DD'
            IF INDEX(ContractId,'.',1) THEN
                ApplicationId = "DD.DDI,STANDALONE"
            END ELSE
                ApplicationId = "DD.ITEM,DETAILS"
            END

        CASE SystemId EQ "PD" AND ContractId[1,4] EQ "PDCA"
            ApplicationId = "PD.CAPTURE"

        CASE SystemId EQ 'SC' AND ContractId[1,4] EQ 'OPOD'
            ApplicationId = "SEC.OPEN.ORDER"

        CASE SystemId EQ 'CQ' AND ContractId[1,2] EQ 'CC'
            ApplicationId = 'CHEQUE.COLLECTION'

        CASE SystemId EQ 'CQ' AND INDEX(ContractId,'.',1)
            ApplicationId = 'CHEQUE.ISSUE'

        CASE SystemId EQ 'SCCA'
            IF (DCOUNT(ContractId,'.') = 1) THEN
                ApplicationId = "DIARY"
            END
        
        CASE SystemId EQ 'MD'
            ApplicationId = "MD.DEAL"
        
        CASE SystemId EQ "TF"
            ApplicationId = "LETTER.OF.CREDIT"
** When the payment order is been present then it has to be processed instead of AAA.
        CASE SystemId EQ "PP"
            ApplicationId = "POR.POSTING.REVERSAL"
    END CASE

    IF ApplicationId EQ '' THEN
        ApplicationId = 'AA.ARRANGEMENT.ACTIVITY,AA'
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------
END
