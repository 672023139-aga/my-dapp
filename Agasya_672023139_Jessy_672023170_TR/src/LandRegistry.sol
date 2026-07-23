// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract LandRegistry {
    address public governmentOwner;

    struct LandCertificate {
        string location;
        uint256 areaSize;
        string currentOwner;
        bool isRegistered;
        bool isDisputed;      // Fitur 1: Status Sengketa (true = terkunci)
        bool isTaxPaid;       // Fitur 3: Status Lunas Pajak PBB
        string[] ownerHistory; // Fitur 2: Riwayat Kepemilikan
    }

    mapping(bytes32 => LandCertificate) private certificates;

    event LandRegistered(bytes32 indexed certId, string owner, string location);
    event LandTransferred(bytes32 indexed certId, string oldOwner, string newOwner);
    event DisputeStatusChanged(bytes32 indexed certId, bool isDisputed);
    event TaxStatusUpdated(bytes32 indexed certId, bool isTaxPaid);

    modifier onlyGovernment() {
        require(msg.sender == governmentOwner, "Hanya Badan Pertanahan yang diizinkan");
        _;
    }

    constructor() {
        governmentOwner = msg.sender;
    }

    // FUNGSI WRITE 1: Registrasi Awal
    function registerLand(
        bytes32 _certId, 
        string memory _location, 
        uint256 _areaSize, 
        string memory _ownerName
    ) public onlyGovernment {
        require(!certificates[_certId].isRegistered, "ID Sertifikat sudah terdaftar!");

        LandCertificate storage newLand = certificates[_certId];
        newLand.location = _location;
        newLand.areaSize = _areaSize;
        newLand.currentOwner = _ownerName;
        newLand.isRegistered = true;
        newLand.isDisputed = false;
        newLand.isTaxPaid = false; // Default: Belum bayar pajak baru
        newLand.ownerHistory.push(_ownerName); // Pemilik pertama masuk riwayat

        emit LandRegistered(_certId, _ownerName, _location);
    }

    // FUNGSi WRITE 2: Transfer Kepemilikan (Jual Beli)
function transferOwnership(bytes32 _certId, string memory _newOwner) public onlyGovernment {
    LandCertificate storage land = certificates[_certId];
    require(land.isRegistered, "Sertifikat tidak ditemukan");
    // require(land.isDisputed, "Transaksi ditolak: Pajak PBB tahun ini belum dilunasi!");

    string memory oldOwner = land.currentOwner;
    land.currentOwner = _newOwner;
    land.ownerHistory.push(_newOwner); // Tambahkan pemilik baru ke riwayat
    land.isTaxPaid = false; // Reset status pajak untuk pemilik baru

    emit LandTransferred(_certId, oldOwner, _newOwner);
}

    // FUNGSI WRITE 3: Set Status Sengketa (Kunci/Buka)
    function setDisputeStatus(bytes32 _certId, bool _status) public onlyGovernment {
        require(certificates[_certId].isRegistered, "Sertifikat tidak ditemukan");
        certificates[_certId].isDisputed = _status;
        emit DisputeStatusChanged(_certId, _status);
    }

    // FUNGSI WRITE 4: Bayar Pajak PBB
    function payTax(bytes32 _certId) public onlyGovernment {
        require(certificates[_certId].isRegistered, "Sertifikat tidak ditemukan");
        certificates[_certId].isTaxPaid = true;
        emit TaxStatusUpdated(_certId, true);
    }

    // FUNGSI READ: Cek Detail Informasi Tanah
    function getLand(bytes32 _certId) public view returns (
        string memory location, 
        uint256 areaSize, 
        string memory owner, 
        bool registered,
        bool disputed,
        bool taxPaid
    ) {
        LandCertificate memory land = certificates[_certId];
        require(land.isRegistered, "Sertifikat tidak terdaftar");
        return (land.location, land.areaSize, land.currentOwner, land.isRegistered, land.isDisputed, land.isTaxPaid);
    }

    // FUNGSI READ: Ambil Riwayat Pemilik
    function getOwnerHistory(bytes32 _certId) public view returns (string[] memory) {
        require(certificates[_certId].isRegistered, "Sertifikat tidak terdaftar");
        return certificates[_certId].ownerHistory;
    }
}
