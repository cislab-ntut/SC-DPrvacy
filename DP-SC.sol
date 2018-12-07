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

    event UserAdded(address UserAddress, string UserMessage);
    event UserRemoved(address UserAddress);
    event ServiceAdded(address ServiceAddress);
    event ServiceRemoved(address ServiceAddress);

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
        addUser(0, "");
        addUser(owner, 'Creator and Owner of Smart Contract');
        numberOfUsers = 0;
        addService(0);
        numberOfServices = 0;
    }


    function addUser(address _userAddress, string _userMessage) onlyOwner public {
        uint id = userId[_userAddress];
        if (id == 0) {
            userId[_userAddress] = users.length;
            id = users.length++;
        }
        users[id] = User({user: _userAddress, userSince: now, message: _userMessage});
        UserAdded(_userAddress, _userMessage);
        numberOfUsers++;
        //加密数据
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
    }

    function revokeAuthorization(address _serviceAddress) onlyUsers public {
        require(ServiceId[_serviceAddress] != 0); 
        uint sid = ServiceId[_serviceAddress];
        services[sid].permission = false;
    }

    function handleData(address _serviceAddress, address _userAddress) public {
        require(ServiceId[_serviceAddress] != 0); 
        uint sid = ServiceId[_serviceAddress];
        uint id = userId[_userAddress];
        if(services[sid].permission == true) {
            throw;
            //解密数据users[id].message
        }
    }

}