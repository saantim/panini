//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract QatarStickerPackageContract {
    struct StickerPackage {
        uint256 id;
        bool opened;
    }

    uint256 totalPackages;
    mapping(address => StickerPackage[]) walletToPackages;

    function buyPackage() public {
        uint256 packageId = totalPackages++;
        StickerPackage[] storage walletPackages = walletToPackages[msg.sender];
        StickerPackage memory newPackage = StickerPackage({
            id: packageId,
            opened: false
        });
        walletPackages.push(newPackage);
    }

    function listPackages() public view returns (StickerPackage[] memory) {
        StickerPackage[] memory walletPackages = walletToPackages[msg.sender];
        return walletPackages;
    }

    function openPackage(uint256 _packageId) public {
        StickerPackage[] storage walletPackages = walletToPackages[msg.sender];
        for (uint256 i = 0; i < walletPackages.length; i++) {
            StickerPackage storage package = walletPackages[i];
            if (package.id != _packageId) continue;

            _openPackage(package);
            break;
        }
    }

    function _openPackage(StickerPackage storage package) private {
        package.opened = true;
    }
}
