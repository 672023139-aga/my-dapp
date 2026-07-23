// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "../src/LandCert.sol";

contract DeployLandRegistry {

    function deploy() external returns (address) {
        LandCert landCert = new LandCert();
        return address(landCert);
    }
}
