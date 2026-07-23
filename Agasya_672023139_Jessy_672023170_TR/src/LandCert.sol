// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LandCert {

    struct Land {
        string location;
        uint256 area;
        string ownerName;
        address registrant;
        bool dispute;
        bool exists;
        bool taxPaid;
    }

    uint256 private certificateCount;

    address public admin;

    mapping(uint256 => Land) private lands;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(
            msg.sender == admin,
            "Only admin can perform this action"
        );
        _;
    }

    // ============================================================
    // DAFTAR TANAH
    // ============================================================

    function registerLand(
        string memory _location,
        uint256 _area,
        string memory _ownerName
    ) public {

        require(
            _area > 0,
            "Area must be greater than zero"
        );

        certificateCount++;

        lands[certificateCount] = Land({
            location: _location,
            area: _area,
            ownerName: _ownerName,
            registrant: msg.sender,
            dispute: false,
            exists: true,
            taxPaid: false
        });
    }

    // ============================================================
    // AMBIL DATA TANAH
    // ============================================================

    function getLand(uint256 _id)
        public
        view
        returns (
            string memory,
            uint256,
            string memory,
            address,
            bool,
            bool,
            bool
        )
    {
        require(
            lands[_id].exists,
            "Land does not exist"
        );

        Land memory land = lands[_id];

        return (
            land.location,
            land.area,
            land.ownerName,
            land.registrant,
            land.dispute,
            land.exists,
            land.taxPaid
        );
    }

    // ============================================================
    // RIWAYAT TANAH USER
    // ============================================================

    function getMyCertificateIds()
        public
        view
        returns (uint256[] memory)
    {
        uint256 count = 0;

        for (
            uint256 i = 1;
            i <= certificateCount;
            i++
        ) {
            if (
                lands[i].exists &&
                lands[i].registrant == msg.sender
            ) {
                count++;
            }
        }

        uint256[] memory result =
            new uint256[](count);

        uint256 index = 0;

        for (
            uint256 i = 1;
            i <= certificateCount;
            i++
        ) {
            if (
                lands[i].exists &&
                lands[i].registrant == msg.sender
            ) {
                result[index] = i;
                index++;
            }
        }

        return result;
    }

    // ============================================================
    // SEMUA ID TANAH
    // ============================================================

    function getAllCertificateIds()
        public
        view
        returns (uint256[] memory)
    {
        uint256 count = 0;

        for (
            uint256 i = 1;
            i <= certificateCount;
            i++
        ) {
            if (lands[i].exists) {
                count++;
            }
        }

        uint256[] memory result =
            new uint256[](count);

        uint256 index = 0;

        for (
            uint256 i = 1;
            i <= certificateCount;
            i++
        ) {
            if (lands[i].exists) {
                result[index] = i;
                index++;
            }
        }

        return result;
    }

    // ============================================================
    // JUMLAH SERTIFIKAT
    // ============================================================

    function getCertificateCount()
        public
        view
        returns (uint256)
    {
        return certificateCount;
    }

    // ============================================================
    // PEMBAYARAN PBB
    // ============================================================

    function payTax(
        uint256 _id
    ) public {

        require(
            lands[_id].exists,
            "Land does not exist"
        );

        require(
            lands[_id].registrant == msg.sender,
            "Only registrant can pay tax"
        );

        require(
            !lands[_id].taxPaid,
            "Tax already paid"
        );

        lands[_id].taxPaid = true;
    }

    // ============================================================
    // STATUS SENGKETA
    // ============================================================

    function setDisputeStatus(
        uint256 _id,
        bool _status
    ) public onlyAdmin {

        require(
            lands[_id].exists,
            "Land does not exist"
        );

        lands[_id].dispute = _status;
    }

    // ============================================================
    // TRANSFER KEPEMILIKAN
    // ============================================================

    function transferOwnership(
        uint256 _id,
        string memory _newOwnerName
    ) public onlyAdmin {

        require(
            lands[_id].exists,
            "Land does not exist"
        );

        lands[_id].ownerName =
            _newOwnerName;
    }

    // ============================================================
    // CEK ADMIN
    // ============================================================

    function getAdmin()
        public
        view
        returns (address)
    {
        return admin;
    }
}
