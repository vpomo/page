// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import './interfaces/IStrategy.sol';
import './StringUtilsLib.sol';
import './Admin.sol';
abstract contract Strategy is IStrategy, Admin{
    using StringUtilsLib for *;

    /*
     *
     * EXAMPLE
     *
     */
    // function getJson(string memory _function, string memory _values) view public override returns (string memory) {

        // EXAMPLE HOW BUILD JSON ...
        // string memory tojson;

        // FIRST ELEMENT MAKING WITH : _JSONelement
        // tojson = JSON();
        /*
        tojson = '{';
        tojson = _JSONAddString(tojson, "test_2", _values, true);
        tojson = _JSONAddString(tojson, "test_3", _values, true);
        tojson = _JSONAddString(tojson, "test_4", _values, true);
        tojson = _JSONAddString(tojson, "test_5", _values, true);
        tojson = _JSONAddString(tojson, "test_6", _values, true);
        tojson = _JSONAddString(tojson, "test_7", _values, true);


        // TEST 1
        tojson = tojson.toSlice().concat(','.toSlice())
                       .toSlice().concat(_JSONelement("test_2", _values, true).toSlice());

        tojson = tojson.toSlice().concat(','.toSlice())
                       .toSlice().concat(_JSONelement("test_3", _values, true).toSlice());

        tojson = tojson.toSlice().concat(','.toSlice())
                       .toSlice().concat(_JSONelement("test_4", _values, true).toSlice());

        tojson = tojson.toSlice().concat(','.toSlice())
                       .toSlice().concat(_JSONelement("test_5", _values, true).toSlice());

        tojson = tojson.toSlice().concat(','.toSlice())
                       .toSlice().concat(_JSONelement("test_6", _values, true).toSlice());

        tojson = tojson.toSlice().concat(','.toSlice())
                       .toSlice().concat(_JSONelement("test_7", _values, true).toSlice());
*/

        // SECOND ELEMENT MAKING WITH : _JSONadd
        // tojson = _JSONadd(tojson, 'function_value', _values, true);

    /********
        // STRING TEST
        tojson = _JSONadd(tojson, 'simple_string', "123 42 this is string ... ??? !!!", true);

        // uint to string example:
        uint256 test_uint = 70000;
        tojson = _JSONadd(tojson, 'score', string(abi.encodePacked(test_uint)), false);

        // address test
        address TESTADDRESS = address(this);
        tojson = _JSONadd(tojson, 'address', string(abi.encodePacked(TESTADDRESS)), true);
    ********/

        // COMPILE UNIG JSONcompile FUNCTION
        // return JSONcompile(tojson);
    // }

    // bytes memory
    /*
     *
     * if quotes
     *      "key":"value"
     * else 
     *      "key":0 or "key":{...}
     *
     */
    function _JSONAddString(string memory prev, string memory key, string memory value, bool quotes) pure internal returns (string memory) {
        // if (prev.toSlice().equals("{".toSlice())) { 
        //     return prev.toSlice().concat(_JSONelement(key, value, quotes).toSlice());
        // } else {
            return prev.toSlice().concat(','.toSlice())
                        .toSlice().concat(_JSONelement(key, value, quotes).toSlice());
        // }
    }
    function _JSONelement(string memory key, string memory value, bool quotes) pure private returns (string memory) {
        // SET VALUE
        string memory _value;
        if (quotes) {
            _value = _quotes(value);
        } else {
            _value = value;
        }
        // ADD COLON
        string memory fin = _quotes(key).toSlice().concat(':'.toSlice());
        return fin.toSlice().concat(_value.toSlice());
    }
    function _quotes(string memory value) pure internal returns (string memory) {
        string memory _value = '"'.toSlice().concat(value.toSlice());
        return _value.toSlice().concat('"'.toSlice());
    }
    function JSONcompile(string memory elements) pure internal returns (string memory) {
        string memory fin = '{'.toSlice().concat(elements.toSlice());
        return fin.toSlice().concat('}'.toSlice());
    }

    // SEND
    function sendJson(string memory _function, string memory _values) public virtual override{
        // ++++
        // if ()
    }

}
