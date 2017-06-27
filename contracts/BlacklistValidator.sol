pragma solidity ^0.4.10;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Validator.sol";

contract BlacklistValidator is Validator, Ownable {

    mapping (address => bool) blacklist;

    function ban(address adversary) onlyOwner {
       blacklist[adversary] = true; 
    }

    function unban(address goodguy) onlyOwner {
        blacklist[goodguy] = false;
    }

    function validate(address _from, address _to, uint _value) 
        constant
        returns (bool valid) 
    { 
        if (blacklist[_from]) {
            valid = false;
        } else {
            valid = true;
        }
        Decision(_from, _to, valid, _value);
    }

}
