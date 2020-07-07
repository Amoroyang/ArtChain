pragma solidity ^0.4.14;

//import "github.com/Arachnid/solidity-stringutils/strings.sol";

/**
 * @title IdGenerate
 * @dev  & retreive value in a variable
 */
contract IdGenerate {
    //using strings for *;

    //合约拥有者
    address public owner;
    
    //id
    uint id; 
    
    //二维码ID
    bytes1[10] qrcode;
    
    //进制试算表
    uint[10] dig36num;

    //这是构造函数，只有当合约创建时运行
    function IdGenerate() public {
        owner = msg.sender;
        
        id=0;
        
        //init ascii "0"
        for (uint i=0; i<qrcode.length ; i++) {
            qrcode[i] = bytes1(48);
        }
        
        //init 进制试算表
        uint dignum=36;
        dig36num[0] = 1;
        for( uint j=1; j<dig36num.length; j++){
            dig36num[j] = dignum;
            dignum *=36;
        }
    }
    
    /**
     * @dev get current id
    */
    function getCurrentId() public view returns (string){
        //byte[] convert string
        bytes memory names = new bytes(10);
        for(uint i = 0; i < qrcode.length; i++) {
           names[i] = qrcode[i];
        }
        
        return string(names);
    }
    
    /**
     * @dev generateId 
    */
    // function generateId(uint8 num) public isOwner returns (bytes){
    //     bytes result;
        
    //     for(uint8 i =0; i<num; i++){
    //         bytes1[10] addResult = generateId();
            
    //         for(uint8 j=0 ; j<qrcode.length ;i++) {
    //           result.push(qrcode[i]);
    //         }
    //     }
        
        
    //     result.push(bytes1(44));

    //     return result;
    // }
    
    /**
     * @dev generateId 
    */
    function generateId() public isOwner returns (bytes1[10]){
        bytes1[10] result;
        
        //init add parameters
        bytes1 carry = bytes1(48);
        uint8 addnum = 1;
        uint8 position = 9;
        
        uint8 srcnum = charToUint(qrcode[9]);

        do{
            //add num
            bytes1[2] memory addResult = numAdd(srcnum,addnum);
            
            //save result;
            qrcode[position] = addResult[1];
            
            //get carry
            carry = addResult[0];
            addnum = charToUint(addResult[0]);
            
            //change position
            position--;
        }while(uint(carry) != uint(48));
        
        for(uint i=0 ; i<qrcode.length ;i++) {
           result[i] = qrcode[i];
        }
        
        return result;
    }

    /**
     * @dev add code,36进制0-Z大写 
     * @return 相加结果,是否进位
    */ 
    function numAdd(uint8 num, uint8 addnum) public validateNum(num) validateNum(addnum) returns (bytes1[2]){
        bytes1[2] memory result = [bytes1(48),bytes1(48)];
        
        //add num
        uint8 numres = num + addnum;
        
        //判断是否需要进位
        if(numres > 35){
            result[0] = bytes1(49);
        }
        
        //计算低位数
        uint8 lownum = numres % 36;
        
        //switch to char
        if(lownum >=0 && lownum < 10){
            result[1] = bytes1(48 + lownum);
        }
        else{
            result[1] = bytes1(65 + lownum -10);
        }
        
        return result;
    }
    
    /**
     * @dev char to uint
    */
    function charToUint(bytes1 char) public view returns (uint8){
        uint8 result;
        
        uint8 num = uint8(char);
        
        if(num >=48 && num <= 57){
            result = num - 48;
        }
        else{
            result = num - 65 + 10;
        }

        return result;
    }
    
    /**
     * @dev 16进制转36进制
    */
    function hexTo36() public view returns (bytes1[10]){
        bytes1[10] memory result;
        
        bytes20 hash = bytes20(100);//ripemd160(qrcode);
        
        uint num = uint(hash);
        
        //计算位数
        uint digits = 1;//位数,1 start
        while(num>=dig36num[digits]){
            digits++;
        }
        
        //转换进制
        for(uint modnum=num; digits>0; digits--){
            uint dignum = modnum/dig36num[digits-1];
            
            result[10-digits] = bytes1(dignum);
            
            modnum = modnum % dig36num[digits-1];
        }
        
        return result;
        
    }
    
    /**
     * 类似于AOP
     * validate num in range 1-35;
    */ 
    modifier validateNum(uint8 num) {
        require(
            num >=0 && num < 36,
            "num range is 0-35"
        );
        
        //继续执行修饰的方法
        _;
   }
   
    /**
     * validate char in range 0-9 OR A-Z;
     * "0" = bytes1[48]
     * "9" = bytes1[57]
     * "A" = bytes1[65]
     * "Z" = bytes1[90]
    */ 
    modifier validateChar(bytes1 char) {
        require(
            uint(char) >= uint(48) && uint(char) <= uint(57)
        || uint(char) >= uint(65) && uint(char) <= uint(90)
        , "charnum range is 0-Z"
        );
        _;
    }
   
    modifier isOwner() {
        require(msg.sender == owner,
        "Caller is not owner");
        _;
    }
}