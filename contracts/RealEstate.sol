pragma solidity ^0.5.1;

contract EtherReceiver {

    function () external  payable {}
}
contract Sender {

    function send(address payable _addr, uint amount) payable public {
        require(msg.value >= amount);
        _addr.transfer(msg.value);
    }
}
contract RealEstate {

        enum Type  {Apartment, MultiFamilyHouse, TerracedHouse, Condominium, Cooperative, Vilas, Plot,Other }

    //// Proprty structure
        struct Property
    {
        address  ownerAddress;
        string location;
        uint propertyId;
        bool isAvailableForSale;
        string propertyType;
        uint cost;
    }

    address public owner;
    uint public totalPropertyCounter;

    string[] myArray;

    function RegisterUser() public
    {
        owner = msg.sender;
        totalPropertyCounter = 0;
    }

    //Blockchain events start

    event Add(address _owner, uint _propertyId);
    event UpdateStatus(string _msg,uint _cost);
    event Transfer(address indexed _from, address indexed _to, uint _propertyId);
    event EtherTransfer(address indexed _from, address indexed _to, uint _cost);

    //Blockchain events end


    mapping (address => Property[]) public _ownedProperty;
    mapping (address => uint) balance;



    //owner can add Property to the Blockchain using this method

    function addProperty(address payable  propertyOwner,string memory _location, uint _cost, string memory _propertyType) public
    {
        require(msg.sender == owner);
        totalPropertyCounter = totalPropertyCounter + 1;
        Property memory property = Property(
            {
                ownerAddress: propertyOwner,
                location: _location,
                cost: _cost,
                propertyType: _propertyType,
                propertyId: totalPropertyCounter,
                isAvailableForSale: true

            });
        _ownedProperty[msg.sender].push(property);

        //emit is used to with events
       emit Add(msg.sender, totalPropertyCounter);
    }

        EtherReceiver private receiverAdr = new EtherReceiver();



  /// This method is used to transfer ether from caller accout to some other account
    function transferEther(address payable rec,uint _amount) public payable {
                require(msg.value >= 1 ether);

Sender s = new Sender();
s.send(rec,_amount);
    }



    //This method is used to transfer property from caller account to some other account
    function transferProperty(address payable  _landBuyer, uint _propertyId) payable public returns (bool)
    {
        for(uint i=0; i < (_ownedProperty[msg.sender].length);i++)
        {
            if (_ownedProperty[msg.sender][i].propertyId == _propertyId)
            {
                    Property memory property = Property(
                    {
                        ownerAddress:_landBuyer,
                        location: _ownedProperty[msg.sender][i].location,
                        cost: _ownedProperty[msg.sender][i].cost,
                        propertyType: _ownedProperty[msg.sender][i].propertyType,
                        propertyId: _propertyId,
                        isAvailableForSale: _ownedProperty[msg.sender][i].isAvailableForSale
                    });
                _ownedProperty[_landBuyer].push(property);



               //  EtherTransfer(msg.sender,_landBuyer,_ownedLands[msg.sender][i].cost);
                //remove land from current ownerAddress
                delete _ownedProperty[msg.sender][i];


                //inform the world
               emit Transfer(msg.sender, _landBuyer, _propertyId);

                return true;
            }
        }
                return false;
    }



    //get land details of any account
    function getProperty(address _propertyHolder, uint _index) public view returns (string memory, uint, address,string memory,uint, bool)
    {
        return (_ownedProperty[_propertyHolder][_index].location,
                _ownedProperty[_propertyHolder][_index].cost,
                _ownedProperty[_propertyHolder][_index].ownerAddress,
                _ownedProperty[_propertyHolder][_index].propertyType,
                _ownedProperty[_propertyHolder][_index].propertyId,
                _ownedProperty[_propertyHolder][_index].isAvailableForSale
                );
    }


      //get land details of caller account
    function getOwnerProperty( uint _index) public view returns (string memory, uint, address,string memory,uint, bool)
    {
        address _propertyHolder = msg.sender;
        return (_ownedProperty[_propertyHolder][_index].location,
                _ownedProperty[_propertyHolder][_index].cost,
                _ownedProperty[_propertyHolder][_index].ownerAddress,
                _ownedProperty[_propertyHolder][_index].propertyType,
                _ownedProperty[_propertyHolder][_index].propertyId,
                _ownedProperty[_propertyHolder][_index].isAvailableForSale
                );
    }

//    function withdraw() public {
  //      msg.sender.transfer(address(this).balance);
    //}



    // remove pproperty from sale
    function RemoveFromSale(uint property_id) public returns (string memory){

        uint indexer;
        address _propertyHolder =msg.sender;

        for(indexer=0; indexer < (_ownedProperty[_propertyHolder].length);indexer++){
             if ( _ownedProperty[_propertyHolder][indexer].propertyId == property_id ){
                     _ownedProperty[_propertyHolder][indexer].isAvailableForSale=false;
                     return "REMOVED FROM SALE";
             }
         }
        return "INVALID LAND ID";
    }


    /// Add a property for sale
    function AddForSale(uint property_id) public returns (string memory){

        uint indexer;
        address _propertyHolder =msg.sender;

        for(indexer=0; indexer < (_ownedProperty[_propertyHolder].length);indexer++){
             if ( _ownedProperty[_propertyHolder][indexer].propertyId == property_id ){
                     _ownedProperty[_propertyHolder][indexer].isAvailableForSale=true;
                     return "ADDED FOR SALE";
             }
         }
        return "INVALID LAND ID";
    }


    // get total no of property owned by an account
    function getNoOfProperty(address _propertyHolder) public view returns (uint)
    {
        return _ownedProperty[_propertyHolder].length;
    }


    //buying the approved property
    function buyProperty(address _propertyHolder,uint property)public payable{

                uint indexer;
      //  require(msg.value >= (_ownedProperty[_propertyHolder][property].cost+((_ownedProperty[_propertyHolder][property].cost)/10)));
        for(indexer=0; indexer < (_ownedProperty[_propertyHolder].length);indexer++){
             if ( _ownedProperty[_propertyHolder][indexer].propertyId == property ){


        //_ownedProperty[_propertyHolder][indexer].ownerAddress.transfer(_ownedProperty[_propertyHolder][indexer].cost);

                 Property memory propertyNew = Property(
                    {
                        ownerAddress:msg.sender,
                        location: _ownedProperty[_propertyHolder][indexer].location,
                        cost: _ownedProperty[_propertyHolder][indexer].cost,
                        propertyType: _ownedProperty[_propertyHolder][indexer].propertyType,
                        propertyId: _ownedProperty[_propertyHolder][indexer].propertyId,
                        isAvailableForSale: _ownedProperty[_propertyHolder][indexer].isAvailableForSale
                    });

        _ownedProperty[msg.sender].push(propertyNew);
        delete _ownedProperty[_propertyHolder][indexer];

             }
    }
    }
}
