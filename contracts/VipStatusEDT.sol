// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
/**
 * @title VipStatusEDT
 * @author Niccolo' Petti
 * @dev A simple ERC1155 that extends IERC2981, that supports 4 different ids
 * holding it gives important advantages on the EDT ecosystem, more on this at https://www.edrivetoken.io/
 */
contract VipStatusEDT is ERC1155, IERC2981, Ownable {

    using Strings for uint256;
    string constant public name= "EDT VIP NFT";
    string constant public symbol= "EDT_VIP";
    uint256 constant public total_supply = 4;//only Diamond, Gold, Silver and Bronze
    address private _recipient;
    string internal constant _uriBase = "ipfs://bafybeibbgax66i5tmitjlgg4dofvk5f7hifbxxnxoro6bbdg5zw4r2t4uu/";

    constructor() ERC1155("") {
        _recipient = _msgSender();
    }

function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )  internal virtual override{
        uint256 len = ids.length;
        for(uint256 i=0; i<len;)
        {
            require(ids[i]<total_supply,"id must be between 0 and 3");
            unchecked {
                ++i;
            }
        }

    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        onlyOwner
    {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    function uri(uint256 tokenId) override public view returns (string memory) {
        // Tokens minted above the supply cap will not have associated metadata.
        require(tokenId < total_supply, "ERC1155Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(_uriBase, Strings.toString(tokenId), ".json"));
    }

    /** @dev EIP2981 royalties implementation. */

    // Maintain flexibility to modify royalties recipient (could also add basis points).
    function _setRoyalties(address newRecipient) internal {
        require(newRecipient != address(0), "Royalties: new recipient is the zero address");
        _recipient = newRecipient;
    }

    function setRoyalties(address newRecipient) external onlyOwner {
        _setRoyalties(newRecipient);
    }

    // EIP2981 standard royalties return.
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view override
        returns (address receiver, uint256 royaltyAmount)
    {
        return (_recipient, (_salePrice * 1000) / 10000);
    }

    // EIP2981 standard Interface return. Adds to ERC1155 and ERC165 Interface returns.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155, IERC165)
        returns (bool)
    {
        return (
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId)
        );
    }

}