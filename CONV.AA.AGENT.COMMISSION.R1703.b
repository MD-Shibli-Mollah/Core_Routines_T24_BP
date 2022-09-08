* @ValidationCode : MjotMTI1NDE1Mjc0NTpDcDEyNTI6MTQ4NTg2Mjg0NTgxMzpicmluZGhhcjoxOjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTcwMi4yMDE3MDEyOC0wMTM5OjMzOjMz
* @ValidationInfo : Timestamp         : 31 Jan 2017 17:10:45
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : brindhar
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 33/33 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.20170128-0139
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE AA.AgentCommission
    SUBROUTINE CONV.AA.AGENT.COMMISSION.R1703(Id, Record,File)
*-----------------------------------------------------------------------------
*  Conversion Routine to update the correct marker for new fields RESERVED5, RESERVED4, COMMISSION.TYPE,AGENT ROLE.
*-----------------------------------------------------------------------------
* @package Retaillending.AA
* @stereotype subroutine
* @ author ygayatri@temenos.com
*-----------------------------------------------------------------------------

* Modification History :
*
* 03/01/17 - Enhancement : 1931144
*            Task        : 1962245
*            Conversion Routine to update the correct marker for new fields RESERVED5, RESERVED4, COMMISSION.TYPE.  
*
* 05/01/17 - Enhancement : 1911014
*            Task        : 1911021
*            Conversion Routine to update the correct marker for new field AGENT ROLE.
*
*-----------------------------------------------------------------------------

*** <region name= Process Logic>
*** <desc>Program Control</desc>

    GOSUB Initialise

    GOSUB NewFieldReserved5        ;* updating markers for Reserved5.
    GOSUB NewFieldReserved4        ;* updating markers for Reserved4.
    GOSUB NewFieldCommissionType  ;* updating markers for CommissionType.
    GOSUB NewFieldAgentRole

    RETURN
*** </region>
*-----------------------------------------------------------------------------------

Initialise:

    StartPosition = '3'         ;* Multi-value start ie AgentId
    EndPosition = '15'          ;* Mutli-value end ie AmortEnd

    AgcommAmortEnd = '14'        ;* AmortEnd field having exact values seprated by corresponding markers. 'A]B'
    AgcommReserved5 = '15'       ;* new fileds
    AgcommReserved4 = '16'       ;* new fileds
    AgcommCommissionType = '17'  ;* new fileds

    AmortEnd = Record<AgcommAmortEnd>

    RETURN

*----------------------------------------------------------------------------------------

NewFieldReserved5:

    Reserved5 = ""   ;* make reserved as null.

**Concat empty value with AmortEnd.
    Reserved5.MergedFieldValue = SPLICE(AmortEnd,"-",REUSE(Reserved5))  ;*  A-]B-

**Splite the merged values by "-" and get the second position of the string
    Reserved5 = FIELDS(Reserved5.MergedFieldValue,"-",2)                 ;* ]

    Record<AgcommReserved5> = Reserved5                        ;* updated marker for reserverd5 as ']'

    RETURN

*------------------------------------------------------------------------------------------

NewFieldReserved4:

    Reserved4 = ""

**Concat empty value with AmortEnd.
    Reserved4.MergedFieldValue = SPLICE(AmortEnd,"-",REUSE(Reserved4))  ;*  A-]B-

**Splite the merged values by "-" and get the second position of the string
    Reserved4 = FIELDS(Reserved4.MergedFieldValue,"-",2)                ;* ]

    Record<AgcommReserved4> = Reserved4                                 ;* updated marker for reserved4 as ']'

    RETURN

*------------------------------------------------------------------------------------------

NewFieldCommissionType:

    CommissionType = ""

**Concat empty value with AmortEnd.
    CommissionType.MergedFieldValue = SPLICE(AmortEnd,"-",REUSE(CommissionType))       ;* A-]B-

**Splite the merged values by "-" and get the second position of the string
    CommissionType = FIELDS(CommissionType.MergedFieldValue,"-",2)                     ;* ]

    Record<AgcommCommissionType> = CommissionType                                      ;* updated marker for CommissionType as ']'

    RETURN

NewFieldAgentRole:

    FOR FieldPosition = StartPosition TO EndPosition
        Record<FieldPosition> = CHANGE(Record<FieldPosition>,@VM,@SM) ;* Got the marker and update!
    NEXT

    RETURN

    END
