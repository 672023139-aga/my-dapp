// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract CertificateRegistry {
    address public owner;

    struct Certificate {
        string studentName;
        string major;
        uint256 issueDate;
        bool isValid;
    }

    mapping(bytes32 => Certificate) private certificates;

    event CertificateRegistered(bytes32 indexed certHash, string studentName, address indexed issuer);
    event CertificateRevoked(bytes32 indexed certHash, address indexed issuer);

    modifier onlyOwner() {
        require(msg.sender == owner, "Hanya pemilik kontrak yang dapat mengeksekusi");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Fungsi Write 1: Mendaftarkan Sertifikat Baru
    function registerCertificate(bytes32 _certHash, string memory _name, string memory _major) public onlyOwner {
        require(!certificates[_certHash].isValid, "Sertifikat sudah terdaftar");

        certificates[_certHash] = Certificate({
            studentName: _name,
            major: _major,
            issueDate: block.timestamp,
            isValid: true
        });

        emit CertificateRegistered(_certHash, _name, msg.sender);
    }

    // Fungsi Write 2: Mencabut Validitas Sertifikat
    function revokeCertificate(bytes32 _certHash) public onlyOwner {
        require(certificates[_certHash].isValid, "Sertifikat tidak aktif atau tidak ditemukan");
        certificates[_certHash].isValid = false;

        emit CertificateRevoked(_certHash, msg.sender);
    }

    // Fungsi Read: Verifikasi Data Sertifikat
    function getCertificate(bytes32 _certHash) public view returns (string memory name, string memory major, uint256 date, bool valid) {
        Certificate memory cert = certificates[_certHash];
        require(cert.issueDate != 0, "Sertifikat tidak ditemukan");
        return (cert.studentName, cert.major, cert.issueDate, cert.isValid);
    }
}
