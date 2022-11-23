 //SPDX-License-Identifier: MIT

 pragma solidity >= 0.7.0 < 0.9.0 ; 

 contract ChatApp
 {
    struct user
    {
        string name;
        friend[] friendList;

    }

    struct friend
    {
        address pubkey;
        string name;
    
    }

    struct message
    {
        address sender;
        uint256 timestamp;
        string msg;
    }

    struct AllusersStruct
    {
        string name;
        address accountAddress;
    }

    AllusersStruct[] getAllUsers;

    mapping(address => user) userList;
    mapping(bytes32 => message[]) allMessages;

    //Checking if user exist in our application

    function checkUserExists(address pubkey) public view returns(bool)
    {
        return bytes (userList[pubkey].name).length > 0;  
    }

    //Create account
    function createAccount(string calldata name) external
    {
        require(checkUserExists(msg.sender)== false, "User Exists");
        require(bytes(name).length>0, "Please provide a username");

    //Creating name of the user
        userList[msg.sender].name = name;

        getAllUsers.push(AllusersStruct(name,msg.sender));
    
    }

    function getUsername(address pubkey) external view returns(string memory)
    {
        require(checkUserExists(pubkey),"User isnt registered");
        return userList[pubkey].name;
    }

    function addFriend(address friend_key, string calldata name) external
    {
        require (checkUserExists(msg.sender) ,"Please Create an account");
        require(checkUserExists(friend_key), "User not found" );
        require(msg.sender != friend_key, "Users cannot add themeselves as friends");
        require(checkAlreadyFriends(msg.sender,friend_key) == false , "You are already a friend");

    //addFriend function being created internally
        _addFriend(msg.sender, friend_key,name);
        _addFriend(friend_key,msg.sender,userList[msg.sender].name);
 }
    
    function checkAlreadyFriends(address pubkey1, address pubkey2) internal view returns (bool)
     {
       if(userList[pubkey1].friendList.length > userList[pubkey2].friendList.length)
       {
        address tmp = pubkey1;
        pubkey1 = pubkey2;
        pubkey2 = tmp;
       }


    for(uint256 i = 0; i <userList[pubkey1].friendList.length; i++)
    {
        if (userList[pubkey1].friendList[i].pubkey == pubkey2) return true;
    }  
        return false;
     }

     function _addFriend(address me, address friend_key, string memory name) internal
     {
        friend memory newFriend = friend(friend_key, name);
        userList[me].friendList.push(newFriend);
     }

     //getting my friends, friends

     function getMyFriendList() external view returns(friend[] memory)
     {
        return userList[msg.sender].friendList;
     }

     //get chat code
     function _getChatCode(address pubkey1, address pubkey2) internal pure returns(bytes32)
     {
        if (pubkey1 < pubkey2)
        {
            return keccak256(abi.encodePacked(pubkey1,pubkey2));
        }
        else return keccak256(abi.encodePacked(pubkey2,pubkey1));
        }

        //message function

        function sendMessage(address friend_key, string calldata _msg) external
        {
            require(checkUserExists(msg.sender),"Create an account first");
            require(checkUserExists(friend_key),"The user is not registered");
            require(checkAlreadyFriends(msg.sender, friend_key), "Send friend request first");

            bytes32 chatCode = _getChatCode(msg.sender,friend_key);
            message memory newMsg = message(msg.sender,block.timestamp,_msg);
            allMessages[chatCode].push(newMsg);

        }

        //Read Messages
        function readMessage(address friend_key) external view returns (message[] memory)
        {
         bytes32 chatCode = _getChatCode(msg.sender,friend_key);
         return allMessages[chatCode]; 
        }

        //function to get all the users who were registered in the application
        function getAllAppUsers() public view returns(AllusersStruct[] memory)
        {
           return getAllUsers;

        }
     }
 

 


 

 