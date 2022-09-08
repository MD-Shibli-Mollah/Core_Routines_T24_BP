* @ValidationCode : MjotNTc5Mjk0NjM6Q3AxMjUyOjE1MjI4MjgzNDk2MTY6cnRhbmFzZTo1OjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTgwNC4yMDE4MDMyMy0wMjAxOjE1MToxNDg=
* @ValidationInfo : Timestamp         : 04 Apr 2018 10:52:29
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rtanase
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 148/151 (98.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201804.20180323-0201
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------------------------------------------
$PACKAGE ST.Channels
SUBROUTINE E.NOFILE.TC.REL.CUSTOMER(custData)

*-----------------------------------------------------------------------------------------------------------------
* Nofile routine to get the related customers based on given customer Id and relation type
*-----------------------------------------------------------------------------------------------------------------
* Modification history:
*-----------------------------------------------------------------------------------------------------------------
* 08/12/2016 - Enhancement - 1825131 / Task - 1660111
*              IRIS Service Integration : Administration Home > Customer > Customer Search > View Customer Details
*
* 21/06/2017 - Defect - 2023432 / Task - 2039136
*              TCUA-change set-ST_Channels
*
* 15/03/2018 - Defect - 2501590 / Task - 2503885
*              Show related customer is not displaying when the relation customer type is blank in t24
*-----------------------------------------------------------------------------------------------------------------

    $USING EB.ARC
    $USING ST.Customer
    $USING EB.Reports
    $USING EB.SystemTables
    
    GOSUB Initialise
    GOSUB Process

RETURN
    
*-----------------------------------------------------------------------------------------------------------------
Initialise:
*-----------------------------------------------------------------------------------------------------------------

* Initialise all
    custData = ''
    custPos = ''
    relPos = ''
    typePos = ''
    customerId = ''
    relationType = ''
    excludeCustomerType = ''
    WDFields = ''
    WDRangeAndValue = ''
    WDLogicalOperands = ''
    
* Get input parameter values from enquiry selection
    LOCATE 'CUSTOMER.ID' IN EB.Reports.getDFields()<1> SETTING custPos THEN
* Check condition for getting Customer Id
        WDFields = EB.Reports.getDFields()<custPos>
        WDRangeAndValue = EB.Reports.getDRangeAndValue()<custPos>
        WDLogicalOperands = EB.Reports.getDLogicalOperands()<custPos>
        IF WDFields = 'CUSTOMER.ID' AND WDLogicalOperands = 1 THEN
            customerId = WDRangeAndValue
            IF customerId EQ '' THEN
                GOSUB ExitPoint
            END
        END
    END

    LOCATE 'RELATION.TYPE' IN EB.Reports.getDFields()<1> SETTING relPos THEN
* Check condition for getting Relation Type
        WDFields = EB.Reports.getDFields()<relPos>
        WDRangeAndValue = EB.Reports.getDRangeAndValue()<relPos>
        WDLogicalOperands = EB.Reports.getDLogicalOperands()<relPos>
        IF WDFields = 'RELATION.TYPE' AND WDLogicalOperands = 1 THEN
            relationType = WDRangeAndValue
        END
    END
    
    LOCATE 'EXCLUDE.CUSTOMER.TYPE' IN EB.Reports.getDFields()<1> SETTING typePos THEN
* Check condition for getting Customer Type
        WDFields = EB.Reports.getDFields()<typePos>
        WDRangeAndValue = EB.Reports.getDRangeAndValue()<typePos>
        WDLogicalOperands = EB.Reports.getDLogicalOperands()<typePos>
        IF WDFields = 'EXCLUDE.CUSTOMER.TYPE' AND WDLogicalOperands = 1 THEN
            excludeCustomerType = WDRangeAndValue
        END
    END

* Initialise all
    relCustList = ''
    relCodeList = ''
    relCustCnt = ''

    paramRelCodeList1 = ''
    paramRelCodeList2 = ''
    paramRelCodeList  = ''
    paramRelCodePos1 = ''
    paramRelCodePos2 = ''
    paramRelTypeList1 = ''
    paramRelTypeList2 = ''
    paramRelTypeList  = ''

    paramRelCode = ''
    paramRelCodeDsc = ''
    paramRelType = ''

    revRelCode = ''
    revRelCodeDsc = ''

    relCustId = ''
    relCustCustomerType = ''
    relCustTitle = ''
    relCustName = ''
    relCustStreet = ''
    relCustCountry = ''
    relCustTown = ''
    relCustPostCode = ''

    channelParameterRec = ''
    channelParameterErr = ''

    relationRec = ''
    relationErr = ''
    
    relationCustomerRec = ''
    relationCustomerErr = ''

    customerRec = ''
    customerErr = ''

RETURN

*-----------------------------------------------------------------------------------------------------------------
Process:
*-----------------------------------------------------------------------------------------------------------------

* Get the list of related customers for a given Customer Id
    relationCustomerRec = ST.Customer.RelationCustomer.Read(customerId, relationCustomerErr)
    relCustList = relationCustomerRec<ST.Customer.RelationCustomer.EbRcuOfCustomer>
    relCodeList = relationCustomerRec<ST.Customer.RelationCustomer.EbRcuIsRelation>
    relCustCnt  = DCOUNT(relCustList, @VM)
* Get the list of allowed Relations as defined in CHANNEL.PARAMETER table
    channelParameterRec = EB.ARC.ChannelParameter.Read('SYSTEM', channelParameterErr )
    
    IF relationType NE '' THEN
        LOCATE relationType IN channelParameterRec<EB.ARC.ChannelParameter.CprRelationType,1> SETTING paramRelCodePos THEN
            paramRelCodeList = CHANGE (channelParameterRec<EB.ARC.ChannelParameter.CprRelationCode, paramRelCodePos>, @SM, @VM)

            j = ''
            noOfCodes = ''
            noOfCodes  = DCOUNT(paramRelCodeList, @VM)
            FOR j = 1 TO noOfCodes
                paramRelTypeList<1,j>  = relationType
            NEXT j
        END
    END ELSE
* Get the list of 'CUSTOMER' relationship codes
        LOCATE 'CUSTOMER' IN channelParameterRec<EB.ARC.ChannelParameter.CprRelationType,1> SETTING paramRelCodePos1 THEN
            paramRelCodeList1 = CHANGE (channelParameterRec<EB.ARC.ChannelParameter.CprRelationCode, paramRelCodePos1>, @SM, @VM)
    
            j = ''
            noOfCodes = ''
            noOfCodes  = DCOUNT(paramRelCodeList1, @VM)
            FOR j = 1 TO noOfCodes
                paramRelTypeList1<1,j>  = 'CUSTOMER'
            NEXT j
        END
* Get the list of 'CORPORATE.USER' relationship codes
        LOCATE 'CORPORATE.USER' IN channelParameterRec<EB.ARC.ChannelParameter.CprRelationType,1> SETTING paramRelCodePos2 THEN
            paramRelCodeList2 = CHANGE (channelParameterRec<EB.ARC.ChannelParameter.CprRelationCode, paramRelCodePos2>, @SM, @VM)
        
            j = ''
            noOfCodes = ''
            noOfCodes  = DCOUNT(paramRelCodeList2, @VM)
            FOR j = 1 TO noOfCodes
                paramRelTypeList2<1,j>  = 'CORPORATE.USER'
            NEXT j
        END

        paramRelCodeList = paramRelCodeList1:@VM:paramRelCodeList2
        paramRelTypeList = paramRelTypeList1:@VM:paramRelTypeList2

    END

* Find the matching Reverse relation Code for allowed Relations
    GOSUB GetRelationCodes

RETURN

*-----------------------------------------------------------------------------------------------------------------
GetRelationCodes:
*-----------------------------------------------------------------------------------------------------------------

* Find the matching Reverse relation Code for allowed Relations
    LOOP
        REMOVE paramRelCode FROM paramRelCodeList SETTING paramRelCodePos
    WHILE paramRelCode:paramRelCodePos
        REMOVE paramRelType FROM paramRelTypeList SETTING Pos
* Read the reverse relation details for a given relation
        relationRec     = ST.Customer.Relation.Read(paramRelCode, relationErr)
        paramRelCodeDsc = relationRec<ST.Customer.Relation.EbRelDescription>
        revRelCode      = relationRec<ST.Customer.Relation.EbRelReverseRelation>
        revRelCodeDsc   = relationRec<ST.Customer.Relation.EbRelRevRelDesc>
* Loop over the relation customers and find me the code
        FOR i = 1 TO relCustCnt
            IF relCodeList<1,i> EQ paramRelCode THEN
                relCustId = relCustList<1,i>
                GOSUB BuildOutData
* Arrange the array(s) new by deleting a matching position
                DEL relCustList<1,i>
                DEL relCodeList<1,i>
* Set the array pointer back as we found a match and deleted a position within the array
                i -= 1  ; * VERY IMPORTANT !!!!
            END
        NEXT i
    REPEAT

RETURN

*-----------------------------------------------------------------------------------------------------------------
BuildOutData:
*-----------------------------------------------------------------------------------------------------------------
    customerRec = ''
    
* Read the related Customer record
    CALL CustomerService.getRecord(relCustId, customerRec)
    
    relCustCustomerType = customerRec<ST.Customer.Customer.EbCusCustomerType>
    IF excludeCustomerType = '' THEN
* Build the array of all related customers
        GOSUB BuildArray
    END ELSE
        LOCATE relCustCustomerType IN excludeCustomerType<1,1,1> SETTING p ELSE
* Build the array by removing from the list all customers having the given Exclude Customer Type
            GOSUB BuildArray
        END
    END

RETURN

*-----------------------------------------------------------------------------------------------------------------
BuildArray:
*-----------------------------------------------------------------------------------------------------------------
    relCustTitle    = customerRec<ST.Customer.Customer.EbCusTitle>
    relCustName     = customerRec<ST.Customer.Customer.EbCusNameOne>
    relCustStreet   = customerRec<ST.Customer.Customer.EbCusStreet>
    relCustTown     = customerRec<ST.Customer.Customer.EbCusTownCountry>
    relCustCountry  = customerRec<ST.Customer.Customer.EbCusCountry>
    relCustPostCode = customerRec<ST.Customer.Customer.EbCusPostCode>
* Build the array according to enquiry requirements
    custData<-1> = relCustId:'*':relCustTitle:'*':relCustName:'*':relCustStreet:'*':relCustTown:'*':relCustCountry:'*':relCustPostCode:'*':paramRelCode:'*':paramRelCodeDsc:'*':revRelCode:'*':revRelCodeDsc:'*':paramRelType:'*':relCustCustomerType

RETURN

*---------------------------------------------------------------------------
ExitPoint:
RETURN TO ExitPoint
    
END
