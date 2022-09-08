* @ValidationCode : MjoxOTE0NDQwMTEyOkNwMTI1MjoxNTQ4OTk5NjAwOTE3Om5pbG9mYXJwYXJ2ZWVuOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwMS4yMDE4MTIyMy0wMzUzOi0xOi0x
* @ValidationInfo : Timestamp         : 01 Feb 2019 11:10:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nilofarparveen
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201901.20181223-0353
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>40</Rating>
*-----------------------------------------------------------------------------
$PACKAGE T2.ModelBank
SUBROUTINE V.TCIB.SET.MEM.DATA
*--------------------------------------------------------------------------------------------------------------------
* Routine type       : Auth routine
* Attached To        : VERSION>EB.EXTERNAL.USER,TCIB.NEW
* Purpose            : This routine used to set the random generated number in memorable data
*--------------------------------------------------------------------------------------------------------------------
* Modification History
*--------------------
* 23/06/14 - Enhancement - 957168 / Task: 1041528
*            TCIB Binding Process
*
* 05/05/2015 - Defect: 1333306 / Task : 1336160
*             Memorable Data for EB.EXTERNAL.USER does not contain any numeric.
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*            Incorporation of T components
*
* 30/01/2019 - Defect 2961675 / Task 2967111
*              Activation Code generated with 9 Digits
*----------------------------------------------------------------------------------------------------------------------
    $USING EB.ARC
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB SET.MEMWORD

RETURN
*--------------------------------------------------------------------------------------------------------------------------
INITIALISE:
*-----------

    Y.MEM.WORD = ''; MEM.COUNT = ''; YCONST = ''  ;* Variable initialise

RETURN

*---------------------------------------------------------------------------------------------------------------------------
SET.MEMWORD:
*-----------
* Ensure generate a Encrypted password Such that Encrypted value not Contains '/', because
* '/' behaves as seperator value in OFS.MESSAGES.

    MEM.COUNT =1    ;* Initialising to one
    LOOP WHILE MEM.COUNT DO   ;*looping the memorable count
        GOSUB RANDOM.NUMBER   ;*Select the random number
        Y.MEM.WORD = SALT     ;*assigning the salt value to the variable
        IF INDEX(Y.MEM.WORD, "/",1) THEN          ;*checking the "/" symbol is available.
            MEM.COUNT= MEM.COUNT + 1
        END ELSE
            MEM.COUNT=0       ;*setting the count to zero
        END
    REPEAT

    IF NOT(ISALPHA(Y.MEM.WORD)) AND NOT(ISDIGIT(Y.MEM.WORD)) THEN     ;* Check whether memorable word is alpha numeric
        EB.SystemTables.setRNew(EB.ARC.ExternalUser.XuMemorableData, Y.MEM.WORD);*setting the random data to the memorable data field
    END ELSE
        GOSUB SET.MEMWORD     ;* Recall the memorable word generation
    END

RETURN
*----------------------------------------------------------------------------------------------------------------------------
RANDOM.NUMBER:
*Generate the 10 digits Random number and Return, this value stored in USER table

* Initialising variables
    YCONST = "9999999999"           ;* Absolute number used to generate the Random number
    Y.RANDOM.NO=RND(YCONST);        ;* Generates random integer number between 0 and the Absolute number
    Y.LE.RAN=LEN(Y.RANDOM.NO)       ;* Finding the length of the random number generated
    Y.COUNTER=1                     ;* Counter variable used to traverse through the Random Number
    ASCI.VALUE='';                  ;* Array holding the characters used in the Memory word
    Y.VAR.COUNTER=1                 ;* Counter variable used to traverse through the ASCI array
    SALT.VALUE=''                   ;* Initalising the Memory word
    SALT.LENGTH = LEN(SALT.VALUE)   ;* Caluculating the Loop control variable

* Generating ASCI Array holding the characters that shall be used in the Memory word
    FOR RAN.POS=48 TO 57
        ASCI.VALUE<Y.VAR.COUNTER>=CHAR(RAN.POS) ;*Values from 0 to 9 is stored in variable ASCI.VALUE array
        Y.VAR.COUNTER = Y.VAR.COUNTER + 1       ;*increment the count by 1
    NEXT RAN.POS
    FOR RAN.POS=65 TO 90
        ASCI.VALUE<Y.VAR.COUNTER>=CHAR(RAN.POS) ;*Values from A to Z is stored in variable ASCI.VALUE array
        Y.VAR.COUNTER = Y.VAR.COUNTER + 1       ;*increment the count by 1
    NEXT RAN.POS
    FOR RAN.POS=97 TO 122
        ASCI.VALUE<Y.VAR.COUNTER>=CHAR(RAN.POS) ;*Values from a to z is stored in variable ASCI.VALUE array
        Y.VAR.COUNTER = Y.VAR.COUNTER + 1       ;*increment the count by 1
    NEXT RAN.POS

* Generating the Memory word
    LOOP
    UNTIL SALT.LENGTH EQ 10                     ;* Loop should not terminate until Memory word has 10 characteres
        GRP.POS = Y.RANDOM.NO[Y.COUNTER,2]      ;* Traversing through the random number in steps of two
        IF GRP.POS>62 THEN                      ;* If the position value is greater than the size of the ASCI Array
            GRP.POS=MOD(GRP.POS,62)             ;* Taking Modulus
        END
        IF GRP.POS EQ 0 THEN                    ;* If the position is extracted as 00 from the Random Number
            Y.COUNTER=Y.COUNTER+1               ;* Shift the counter by ONE
            CONTINUE                            ;* Continue the loop with the next digits
        END
        SALT.VALUE:=ASCI.VALUE<GRP.POS>         ;* Append the character at the GRP.POS position in ASCI Array to the Memory word
        IF Y.COUNTER>=Y.LE.RAN THEN             ;* If all the digits in the Random number is traversed
            Y.RANDOM.NO=RND(YCONST)             ;* Generating new Random Number
            Y.LE.RAN=LEN(Y.RANDOM.NO)           ;* Finding the length of the random number generated
            Y.COUNTER=1                         ;* Reinitialising the counter variable used to traverse through the Random Number
        END ELSE
            Y.COUNTER=Y.COUNTER+2               ;* Increment the counter value by two position
        END
        SALT.LENGTH = LEN(SALT.VALUE)           ;* Recaluculating the Loop control variable
    REPEAT
    
    SALT=SALT.VALUE                             ;* Generated Salt value Consists of 10 Digits

RETURN
*----------------------------------------------------------------------------------------------------------------------------
END
