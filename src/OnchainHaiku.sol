// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title OnchainHaiku
/// @notice Fully on-chain generative haiku NFTs
/// @dev Each mint creates a unique, deterministic poem from curated word lists
/// @author Dragon Bot Z 🐉
contract OnchainHaiku {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    
    error MaxSupplyReached();
    error InsufficientPayment();
    error TransferFailed();
    error TokenDoesNotExist();
    
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event HaikuMinted(uint256 indexed tokenId, address indexed minter, string line1, string line2, string line3);
    
    /*//////////////////////////////////////////////////////////////
                                 STORAGE
    //////////////////////////////////////////////////////////////*/
    
    string public constant name = "Onchain Haiku";
    string public constant symbol = "HAIKU";
    
    uint256 public constant MAX_SUPPLY = 1000;
    uint256 public constant MINT_PRICE = 0.001 ether;
    
    uint256 public totalSupply;
    address public immutable owner;
    
    mapping(uint256 => address) private _ownerOf;
    mapping(address => uint256) private _balanceOf;
    mapping(uint256 => address) private _approvals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    
    // Seed storage for deterministic regeneration
    mapping(uint256 => uint256) private _seeds;
    
    /*//////////////////////////////////////////////////////////////
                              WORD LISTS
    //////////////////////////////////////////////////////////////*/
    
    // Line 1: 5 syllables - nature themes (subject/setting)
    string[20] private LINE1_WORDS = [
        "autumn leaves falling",      // 5
        "silent winter snow",         // 5
        "cherry blossoms drift",      // 5
        "morning dew glistens",       // 5
        "ancient oak tree stands",    // 5
        "moonlight on still lake",    // 5
        "wild geese fly southward",   // 5
        "bamboo bends gently",        // 5
        "mountain peak rises",        // 5
        "fireflies at dusk",          // 5
        "waves crash on dark shore",  // 5
        "spring rain awakens",        // 5
        "fog blankets the bay",       // 5
        "pine trees in twilight",     // 5
        "stone path through the wood", // 5
        "cold wind from the north",   // 5
        "seeds beneath the soil",     // 5
        "first light of morning",     // 5
        "storm clouds gathering",     // 5
        "river flows onward"          // 5
    ];
    
    // Line 2: 7 syllables - action/observation
    string[20] private LINE2_WORDS = [
        "dancing in the gentle breeze",    // 7
        "reflecting silver starlight",     // 7
        "carrying the scent of time",      // 7
        "whispering forgotten truths",     // 7
        "painting shadows on the wall",    // 7
        "searching for a place to rest",   // 7
        "echoing through empty halls",     // 7
        "weaving patterns in the air",     // 7
        "waiting for the sun to rise",     // 7
        "holding secrets in their depths", // 7
        "trembling at the edge of night",  // 7
        "spinning tales of days gone by",  // 7
        "breathing life into the earth",   // 7
        "reaching toward the endless sky", // 7
        "carrying memories away",          // 7
        "surrendering to the dark",        // 7
        "offering a moment's peace",       // 7
        "transforming into something new", // 7
        "embracing impermanence",          // 7
        "dissolving into nothingness"      // 7
    ];
    
    // Line 3: 5 syllables - reflection/closure
    string[20] private LINE3_WORDS = [
        "beauty fades away",          // 5
        "silence speaks the truth",    // 5
        "nothing lasts but change",    // 5
        "time flows like water",       // 5
        "peace within the storm",      // 5
        "life begins again",           // 5
        "all returns to dust",         // 5
        "the cycle repeats",           // 5
        "stillness in motion",         // 5
        "one breath at a time",        // 5
        "we are not alone",            // 5
        "this too shall pass",         // 5
        "eternity waits",              // 5
        "now is forever",              // 5
        "the void embraces",           // 5
        "dreams within dreams",        // 5
        "shadows tell no lies",        // 5
        "nature holds the key",        // 5
        "acceptance is peace",         // 5
        "impermanence blooms"          // 5
    ];
    
    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    
    constructor() {
        owner = msg.sender;
    }
    
    /*//////////////////////////////////////////////////////////////
                               ERC721
    //////////////////////////////////////////////////////////////*/
    
    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0), "Zero address");
        return _balanceOf[_owner];
    }
    
    function ownerOf(uint256 tokenId) public view returns (address) {
        address tokenOwner = _ownerOf[tokenId];
        require(tokenOwner != address(0), "Token does not exist");
        return tokenOwner;
    }
    
    function approve(address to, uint256 tokenId) public {
        address tokenOwner = ownerOf(tokenId);
        require(msg.sender == tokenOwner || _operatorApprovals[tokenOwner][msg.sender], "Not authorized");
        _approvals[tokenId] = to;
        emit Approval(tokenOwner, to, tokenId);
    }
    
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_ownerOf[tokenId] != address(0), "Token does not exist");
        return _approvals[tokenId];
    }
    
    function setApprovalForAll(address operator, bool approved) public {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }
    
    function isApprovedForAll(address _owner, address operator) public view returns (bool) {
        return _operatorApprovals[_owner][operator];
    }
    
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(to != address(0), "Transfer to zero address");
        address tokenOwner = ownerOf(tokenId);
        require(from == tokenOwner, "Not the owner");
        require(
            msg.sender == tokenOwner || 
            _approvals[tokenId] == msg.sender || 
            _operatorApprovals[tokenOwner][msg.sender],
            "Not authorized"
        );
        
        _balanceOf[from]--;
        _balanceOf[to]++;
        _ownerOf[tokenId] = to;
        delete _approvals[tokenId];
        
        emit Transfer(from, to, tokenId);
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        transferFrom(from, to, tokenId);
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata) public {
        transferFrom(from, to, tokenId);
    }
    
    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return interfaceId == 0x01ffc9a7 || // ERC165
               interfaceId == 0x80ac58cd || // ERC721
               interfaceId == 0x5b5e139f;   // ERC721Metadata
    }
    
    /*//////////////////////////////////////////////////////////////
                                 MINT
    //////////////////////////////////////////////////////////////*/
    
    function mint() external payable returns (uint256) {
        if (totalSupply >= MAX_SUPPLY) revert MaxSupplyReached();
        if (msg.value < MINT_PRICE) revert InsufficientPayment();
        
        uint256 tokenId = totalSupply + 1;
        totalSupply = tokenId;
        
        // Store seed for deterministic haiku generation
        _seeds[tokenId] = uint256(keccak256(abi.encodePacked(
            block.prevrandao,
            msg.sender,
            tokenId,
            block.timestamp
        )));
        
        _ownerOf[tokenId] = msg.sender;
        _balanceOf[msg.sender]++;
        
        (string memory l1, string memory l2, string memory l3) = getHaiku(tokenId);
        emit Transfer(address(0), msg.sender, tokenId);
        emit HaikuMinted(tokenId, msg.sender, l1, l2, l3);
        
        return tokenId;
    }
    
    /*//////////////////////////////////////////////////////////////
                            HAIKU GENERATION
    //////////////////////////////////////////////////////////////*/
    
    function getHaiku(uint256 tokenId) public view returns (
        string memory line1,
        string memory line2, 
        string memory line3
    ) {
        if (_ownerOf[tokenId] == address(0)) revert TokenDoesNotExist();
        
        uint256 seed = _seeds[tokenId];
        
        uint256 idx1 = seed % 20;
        uint256 idx2 = (seed >> 8) % 20;
        uint256 idx3 = (seed >> 16) % 20;
        
        return (LINE1_WORDS[idx1], LINE2_WORDS[idx2], LINE3_WORDS[idx3]);
    }
    
    /*//////////////////////////////////////////////////////////////
                              METADATA
    //////////////////////////////////////////////////////////////*/
    
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        if (_ownerOf[tokenId] == address(0)) revert TokenDoesNotExist();
        
        (string memory l1, string memory l2, string memory l3) = getHaiku(tokenId);
        
        string memory svg = _generateSVG(l1, l2, l3, tokenId);
        string memory json = _generateJSON(l1, l2, l3, tokenId, svg);
        
        return string(abi.encodePacked(
            "data:application/json;base64,",
            _base64Encode(bytes(json))
        ));
    }
    
    function _generateSVG(
        string memory l1, 
        string memory l2, 
        string memory l3,
        uint256 tokenId
    ) internal pure returns (string memory) {
        // Generate colors from tokenId for variety
        uint256 hue = (tokenId * 37) % 360;
        
        return string(abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 500">',
            '<defs><linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">',
            '<stop offset="0%" style="stop-color:hsl(', _toString(hue), ',15%,8%)"/>',
            '<stop offset="100%" style="stop-color:hsl(', _toString((hue + 30) % 360), ',20%,12%)"/>',
            '</linearGradient></defs>',
            '<rect width="400" height="500" fill="url(#bg)"/>',
            '<text x="200" y="160" text-anchor="middle" fill="hsl(', _toString(hue), ',40%,75%)" ',
            'font-family="Georgia,serif" font-size="18" font-style="italic">', l1, '</text>',
            '<text x="200" y="240" text-anchor="middle" fill="hsl(', _toString((hue + 120) % 360), ',40%,75%)" ',
            'font-family="Georgia,serif" font-size="18" font-style="italic">', l2, '</text>',
            '<text x="200" y="320" text-anchor="middle" fill="hsl(', _toString((hue + 240) % 360), ',40%,75%)" ',
            'font-family="Georgia,serif" font-size="18" font-style="italic">', l3, '</text>',
            '<text x="200" y="460" text-anchor="middle" fill="hsl(', _toString(hue), ',20%,40%)" ',
            'font-family="monospace" font-size="12">#', _toString(tokenId), '</text>',
            '</svg>'
        ));
    }
    
    function _generateJSON(
        string memory l1,
        string memory l2,
        string memory l3,
        uint256 tokenId,
        string memory svg
    ) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '{"name":"Haiku #', _toString(tokenId), '",',
            '"description":"', l1, ' / ', l2, ' / ', l3, '",',
            '"attributes":[',
            '{"trait_type":"Line 1","value":"', l1, '"},',
            '{"trait_type":"Line 2","value":"', l2, '"},',
            '{"trait_type":"Line 3","value":"', l3, '"}],',
            '"image":"data:image/svg+xml;base64,', _base64Encode(bytes(svg)), '"}'
        ));
    }
    
    /*//////////////////////////////////////////////////////////////
                               ADMIN
    //////////////////////////////////////////////////////////////*/
    
    function withdraw() external {
        require(msg.sender == owner, "Not owner");
        (bool success,) = owner.call{value: address(this).balance}("");
        if (!success) revert TransferFailed();
    }
    
    /*//////////////////////////////////////////////////////////////
                              UTILITIES
    //////////////////////////////////////////////////////////////*/
    
    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
    
    function _base64Encode(bytes memory data) internal pure returns (string memory) {
        string memory TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        
        if (data.length == 0) return "";
        
        uint256 encodedLen = 4 * ((data.length + 2) / 3);
        bytes memory result = new bytes(encodedLen + 32);
        bytes memory table = bytes(TABLE);
        
        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)
            
            for {
                let i := 0
            } lt(i, mload(data)) {
            } {
                i := add(i, 3)
                let input := and(mload(add(data, add(i, 32))), 0xffffff)
                
                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)
                
                mstore(resultPtr, out)
                
                resultPtr := add(resultPtr, 4)
            }
            
            switch mod(mload(data), 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
            
            mstore(result, encodedLen)
        }
        
        return string(result);
    }
}
