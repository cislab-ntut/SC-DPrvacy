pragma solidity ^0.4.16;

contract DPSC {
    address public owner;
    string public service;
    uint public numberOfUsers;
    uint public numberOfServices;
    mapping (address => uint) public userId;
    mapping (address => uint) public ServiceId;
    User[] public users;
    Service[] public services;

    event UserAdded(address UserAddress);
    event DataAdded(address UserAddress, string UserMessage);
    event UserRemoved(address UserAddress);
    event ServiceAdded(address ServiceAddress);
    event ServiceRemoved(address ServiceAddress);
    event AuthorizationSeted(address ServiceAddress);
    event AuthorizationRevoked(address ServiceAddress);
    event DataHandled(address ServiceAddress, address UserAddress);
    event InfoGeted(address UserAddress, string UserMessage, uint UserSince);
    
    struct User {
        address user;
        string message;
        uint userSince;
    }

    struct Service {
        address service;
        bool permission;
        uint serviceSince;
    }

    modifier onlyUsers {
        require(userId[msg.sender] != 0);
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function DPSC () public {
        owner = msg.sender;
        addUser(0);
        addUser(owner);
        addData(owner, 'Creator and Owner of Smart Contract');
        numberOfUsers = 0;
        addService(0);
        numberOfServices = 0;
    }


    function addUser(address _userAddress) onlyOwner public {
        uint id = userId[_userAddress];
        if (id == 0) {
            userId[_userAddress] = users.length;
            id = users.length++;
        }
        users[id] = User({user: _userAddress, userSince: now, message: ""});
        UserAdded(_userAddress);
        numberOfUsers++;
    }

     function addData(address _userAddress, string _userMessage) onlyUsers public {
        uint id = userId[_userAddress];
        users[id].message = _userMessage;
        DataAdded(_userAddress, _userMessage);
    }

    function removeUser(address _userAddress) onlyOwner public {
        require(userId[_userAddress] != 0);
        for (uint i = userId[_userAddress]; i<users.length-1; i++){
            users[i] = users[i+1];
        }
        delete users[users.length-1];
        users.length--;
        UserRemoved(_userAddress);
        numberOfUsers--;
    }

    function addService(address _serviceAddress) onlyUsers public {
        uint eid = ServiceId[_serviceAddress];
        if (eid == 0) {
            ServiceId[_serviceAddress] = services.length;
            eid = services.length++;
        }
        services[eid] = Service({service: _serviceAddress, permission: false, serviceSince: now});
        ServiceAdded(_serviceAddress);
        numberOfServices++;
    }

    function removeService(address _serviceAddress) onlyUsers public {
        require(ServiceId[_serviceAddress] != 0); 
        for (uint i = ServiceId[_serviceAddress]; i<services.length-1; i++){
            services[i] = services[i+1];
        }
        delete services[services.length-1];
        services.length--;
        ServiceRemoved(_serviceAddress);
        numberOfServices--;
    }

    function setAuthorization(address _serviceAddress) onlyUsers public {
        require(ServiceId[_serviceAddress] != 0); 
        uint sid = ServiceId[_serviceAddress];
        services[sid].permission = true;
        AuthorizationSeted(_serviceAddress);
    }

    function revokeAuthorization(address _serviceAddress) onlyUsers public {
        require(ServiceId[_serviceAddress] != 0); 
        uint sid = ServiceId[_serviceAddress];
        services[sid].permission = false;
        AuthorizationRevoked(_serviceAddress);
    }

    function handleData(address _serviceAddress, address _userAddress) public constant returns (string) {
        require(ServiceId[_serviceAddress] != 0); 
        uint sid = ServiceId[_serviceAddress];
        uint id = userId[_userAddress];
        if(services[sid].permission == true)
            return (users[id].message);
        else
            return ("No Permission!");
        DataHandled(_serviceAddress, _userAddress);
    }

    function getInfo(address _userAddress) public constant returns (string, uint) {
        uint id = userId[_userAddress];
        string userMessage = users[id].message;
        uint userSin = users[id].userSince;
        return (userMessage, userSin);
        InfoGeted(_userAddress, userMessage, userSin);
   } 
}
