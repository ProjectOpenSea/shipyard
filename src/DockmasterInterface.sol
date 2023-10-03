// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title DockmasterInterface
 * @notice Interface for the Dockmaster contract. This was generated with
 *         `cast interface out/Dockmaster.sol/Dockmaster.json` and is provided
 *         here just for reference and to give a quick sense of what Dockmaster
 *         inherits from AbstractNFT.
 */
interface DockmasterInterface {
    event Approval(address indexed owner, address indexed account, uint256 indexed id);
    event ApprovalForAll(address indexed owner, address indexed operator, bool isApproved);
    event OwnershipHandoverCanceled(address indexed pendingOwner);
    event OwnershipHandoverRequested(address indexed pendingOwner);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    event PreapprovalForAll(address indexed operator, bool indexed approved);
    event TraitLabelsURIUpdated(string uri);
    event TraitUpdated(bytes32 indexed traitKey, uint256 indexed tokenId, bytes32 trait);
    event TraitUpdatedBulkConsecutive(bytes32 indexed traitKeyPattern, uint256 fromTokenId, uint256 toTokenId);
    event TraitUpdatedBulkList(bytes32 indexed traitKeyPattern, uint256[] tokenIds);
    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    struct FullTraitValue {
        bytes32 traitValue;
        string fullTraitValue;
    }

    struct TraitLabel {
        string fullTraitKey;
        string traitLabel;
        string[] acceptableValues;
        FullTraitValue[] fullTraitValues;
        uint8 displayType;
        uint8 editors;
        bool required;
    }

    function approve(address account, uint256 id) external payable;
    function balanceOf(address owner) external view returns (uint256 result);
    function cancelOwnershipHandover() external payable;
    function completeOwnershipHandover(address pendingOwner) external payable;
    function currentId() external view returns (uint256);
    function deleteTrait(bytes32 traitKey, uint256 tokenId) external;
    function getApproved(uint256 id) external view returns (address result);
    function getCustomEditorAt(uint256 index) external view returns (address);
    function getCustomEditors() external view returns (address[] memory);
    function getCustomEditorsLength() external view returns (uint256);
    function getShipIsIn(uint256 tokenId) external view returns (bool);
    function getTotalTraitKeys() external view returns (uint256);
    function getTraitKeyAt(uint256 index) external view returns (bytes32 traitKey);
    function getTraitKeys() external view returns (bytes32[] memory traitKeys);
    function getTraitLabelsURI() external view returns (string memory);
    function getTraitValue(bytes32 traitKey, uint256 tokenId) external view returns (bytes32);
    function getTraitValues(bytes32 traitKey, uint256[] memory tokenIds)
        external
        view
        returns (bytes32[] memory traitValues);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function isCustomEditor(address editor) external view returns (bool);
    function mint(address to) external;
    function name() external view returns (string memory);
    function owner() external view returns (address result);
    function ownerOf(uint256 id) external view returns (address result);
    function ownershipHandoverExpiresAt(address pendingOwner) external view returns (uint256 result);
    function ownershipHandoverValidFor() external view returns (uint64);
    function renounceOwnership() external payable;
    function requestOwnershipHandover() external payable;
    function safeTransferFrom(address from, address to, uint256 id) external payable;
    function safeTransferFrom(address from, address to, uint256 id, bytes memory data) external payable;
    function setApprovalForAll(address operator, bool isApproved) external;
    function setShipIsIn(uint256 tokenId, bool _shipIsIn) external;
    function setTrait(bytes32 traitKey, uint256 tokenId, bytes32 trait) external;
    function setTraitLabel(bytes32 traitKey, TraitLabel memory _traitLabel) external;
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
    function traitLabelStorage(bytes32 traitKey)
        external
        view
        returns (uint8 allowedEditors, bool required, bool valuesRequireValidation, address storedLabel);
    function transferFrom(address from, address to, uint256 id) external payable;
    function transferOwnership(address newOwner) external payable;
    function updateCustomEditor(address editor, bool insert) external;
}
