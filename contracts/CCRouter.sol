// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "../lzApp/NonblockingLzApp.sol";


contract CCRouter is NonblockingLzApp {
	// vars


	// contructor


	// functions

	/**
     * @dev adding chain support by whitelisting bridge
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     * @param _chainId chain id which we want to send message
     * @param _srcERC721 contract address of ERC721 which we want to bridge
     * @param _srcERC721TokenId token id which we want to bridge
     * @param _refundAddress address where we want to recv excess gas
     * @param _zroPaymentAddress payment address
     * @param _adapterParams used to estimate fees
     */
    function sendMsgViaL0(
        uint16 _dstChainId,                            // dst lz chain id
        bytes memory _l0payload,                 
        address payable _refundAddress,             // refund Address(LayerZero will refund any superfluos gas back to the caller of send())
        address _zroPaymentAddress,                 // zroPayment Address
        bytes calldata _adapterParams               // adapterParams
    ) external {
        // run gas fee estimate on destination
        (uint256 messageFee, ) = endpoint.estimateFees(
            _chainId,
            address(this),
            _l0payload,
            false,
            _adapterParams
        );

        require(msg.value >= messageFee, "Insuffcient message fee");

        // send LayerZero message
        // uint16 _dstChainId, bytes memory _payload, address payable _refundAddress, address _zroPaymentAddress, bytes memory _adapterParams
        _lzSend(_dstChainId, payload, _refundAddress, _zroPaymentAddress, _adapterParams, msg.value);
    }


    //Axelar

    function callContract(
    string memory destinationChain,
    string memory contractAddress,
    bytes memory payload
	) external;

	function _execute(
    string memory sourceChain,
    string memory sourceAddress,
    bytes calldata payload
	) internal virtual {}

	function callContractWithToken(
    string memory destinationChain,
    string memory contractAddress,
    bytes memory payload,
    string memory symbol,
    uint256 amount
	) external;r

	function _executeWithToken(
    string memory sourceChain,
    string memory sourceAddress,
    bytes calldata payload,
    string memory tokenSymbol,
    uint256 amount
	) internal virtual {
    // decode recipient
    address memory recipient = abi.decode(payload, (address));
    // get ERC-20 address from gateway
    address tokenAddress = gateway.tokenAddresses(tokenSymbol);

    // transfer received tokens to the recipient
    IERC20(tokenAddress).transfer(recipient, amount);
	w}

}