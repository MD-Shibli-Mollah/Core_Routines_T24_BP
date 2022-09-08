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
* <Rating>-5</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RE.ModelBank
    SUBROUTINE E.BLD.COMP.ID(ENQ.DATA)

*-----------------------------------------------------------------------------
* PURPOSE     : Routine to display Current company and Latest Date.
*               When selection criteria for Comaany and Date is not given.
* AUTHOR      : Abinanthan K B
* CREATED ON  : 08/12/2010
*
*------------------------------------------------------------------------------
* Modification History:
* ---------------------
*------------------------------------------------------------------------------
   
    $USING EB.SystemTables
    $USING ST.CompanyCreation
    $USING EB.Reports
    $USING RE.ModelBank

    ID.COMPANY.LOCAL = EB.SystemTables.getIdCompany()
    TODAY.LOCAL = EB.SystemTables.getToday()
    IF ENQ.DATA<2> EQ '' THEN
        ENQ.DATA<2,1> = 'COMP.CODE'
        ENQ.DATA<3,1> = 'EQ'
        ENQ.DATA<4,1> = ID.COMPANY.LOCAL

        ENQ.DATA<2,1> = 'SYS.DATE'
        ENQ.DATA<3,1> = 'EQ'
        ENQ.DATA<4,1> = TODAY.LOCAL
    END ELSE
        Y.DATA = ENQ.DATA<2> 
        LOCATE 'COMP.CODE' IN Y.DATA<1,1> SETTING POS ELSE
            ENQ.DATA<2,-1> = 'COMP.CODE'
            ENQ.DATA<3,-1> = 'EQ'
            ENQ.DATA<4,-1> = ID.COMPANY.LOCAL
        END
        LOCATE 'SYS.DATE' IN Y.DATA<1,1> SETTING POS ELSE
            ENQ.DATA<2,-1> = 'SYS.DATE'
            ENQ.DATA<3,-1> = 'EQ'
            ENQ.DATA<4,-1> = TODAY.LOCAL
        END
    END

    RETURN
END
