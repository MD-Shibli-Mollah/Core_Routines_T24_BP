* @ValidationCode : MjotMjEwMDk4MTg5NDpDcDEyNTI6MTYxNTIwNjA3MTEzMTpzYXJtZW5hczoxMTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMy4wOjY1OjYz
* @ValidationInfo : Timestamp         : 08 Mar 2021 17:51:11
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sarmenas
* @ValidationInfo : Nb tests success  : 11
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 63/65 (96.9%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
*-----------------------------------------------------------------------------
$PACKAGE PPTNCL.Foundation
SUBROUTINE PPTNCL.BULK.REF.API(iCompanyDetails,iClearingDetails,oFileRef)
*-----------------------------------------------------------------------------
* This API is to genarate the unique LotNumber which is mapped in Outgoing file
*-----------------------------------------------------------------------------
* Modification History :
*24/06/2020 - Enhancement 3538850/Task 3816876-Payments-BHTunsian-Issued Direct Debit / Received Direct Debit
*15/09/2020 - Enhancement 3579741/Task 3970816-Payments-BTunisia- CHEQUE OPERATIONS
*11/02/2021 - Defect 4220822/Task 4226399-Assigning lot number in bulkreference for clearingTxnType CC and CD.
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING PP.OutwardMappingFramework
    
    GOSUB initialise ; *
    GOSUB process ; *
RETURN
*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc> </desc>

    LockingId = ''
    SeqNo = ''
    fileRefIndicator = ''
    clearingTxnType = ''
    outgoingMsgType = ''
    fileRefIndicator = FIELD(iClearingDetails,'*',14)
    clearingTxnType = FIELD(iClearingDetails,'*',1)
    outgoingMsgType = FIELD(iClearingDetails,'*',2 )
    

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= process>
process:
*** <desc> </desc>
    IF fileRefIndicator NE '' THEN
        oFileRef = fileRefIndicator ;* returns the fileReference which is already generated.
        RETURN
    END
    
    BEGIN CASE
    
        CASE clearingTxnType EQ 'DD' AND outgoingMsgType EQ 'TUNCLGDD'
            LockingId = 'TUNCLG.DD.FILEREF'  ;* The locking id for generating file reference
        CASE outgoingMsgType EQ 'TNCGDDRJ'
            LockingId = 'TUNCLG.RJ.FILEREF'
        CASE clearingTxnType EQ 'CT' OR outgoingMsgType  EQ 'TUNCLGCT'
            LockingId = 'TUNCLG.CT.FILEREF'
        CASE clearingTxnType EQ 'RT' OR outgoingMsgType  EQ 'TUNCLGRT'
            LockingId = 'TUNCLG.RT.FILEREF'
        CASE clearingTxnType EQ 'CC' AND outgoingMsgType EQ 'TUCGCQ30'
            LockingId = 'TUNCLG.30.FILEREF'
        CASE clearingTxnType EQ 'CC' AND outgoingMsgType EQ 'TUCGCQ31'
            LockingId = 'TUNCLG.31.FILEREF'
        CASE clearingTxnType EQ 'CC' AND outgoingMsgType EQ 'TUCGCQ32'
            LockingId = 'TUNCLG.32.FILEREF'
        CASE clearingTxnType EQ 'CC' AND outgoingMsgType EQ 'TUCGCQ33'
            LockingId = 'TUNCLG.33.FILEREF'
        CASE clearingTxnType EQ 'CD' AND outgoingMsgType EQ 'TUCGCQ82'
            LockingId = 'TUNCLG.82.FILEREF'
        CASE clearingTxnType EQ 'CD' AND outgoingMsgType EQ 'TUCGCQ84'
            LockingId = 'TUNCLG.84.FILEREF'
            
        CASE 1
            RETURN ;* if clearing Txn type is not DD or RJ , the skip the sequence generation value
    END CASE
    
    GOSUB getLockingSeq
    IF rLocking EQ '' OR rLocking EQ '9999' THEN ;* if value if null or 9999, then start the value fron sequence 0001
        SeqNo = '0001'
    END ELSE
        SeqNo = rLocking<1> + 1
    END
    
    length = 4-LEN(SeqNo)
    FOR cnt =1 TO length
        SeqNo = '0':SeqNo ;* form the value as 4 digit value
    NEXT cnt
    rLocking<1> = SeqNo
   
    EB.SystemTables.LockingWrite(LockingId, rLocking, Suffix)
    
    oFileRef = rLocking<1>  ;* file reference
    IF clearingTxnType EQ 'CC' OR clearingTxnType EQ 'CD' THEN  ;*if clearingTxnType is CC or CD,then assign lot number in bulkreference
        oFileRef<PP.OutwardMappingFramework.ClrgReference.bulkFileReference> = rLocking<1> : ':@VM:' :  rLocking<1>
    END

RETURN
*** </region>

getLockingSeq:
*-------------
    FnLocking = 'F.LOCKING'
    FLocking = ''
    
    rLocking = ''
    RecEr = ''
    Suffix=''
    Retry = ''
    
    EB.DataAccess.FReadu(FnLocking, LockingId,rLocking, FLocking, RecEr,Retry)  ;* read the Locking table with the id formed
    
RETURN

END
