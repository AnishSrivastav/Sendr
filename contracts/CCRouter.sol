// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.9;

// Lz imports
import './interfaces/LayerZero/ILayerZeroEndpoint.sol';
import "./lzApp/NonblockingLzApp.sol";

// Axelar imports
import './interfaces/Axelar/IAxelarExecutable.sol';
import './interfaces/Axelar/IAxelarGasReceiver.sol';
import './interfaces/Axelar/IAxelarGateway.sol';

// import { IERC20 } from '@axelar-network/axelar-cgp-solidity/src/interfaces/IERC20.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// wormhole imports
import "./wormhole/ethereum/Implementation.sol";

contract CCRouter is Implementation, NonblockingLzApp, IAxelarExecutable {
	// vars
    IAxelarGasReceiver public gasReceiver;
    ILayerZeroEndpoint public endpoint;

    //axelar
    constructor(
        address gateway_, 
        address gasReceiver_,
        address endpoint_
    ) IAxelarExecutable(gateway_) NonblockingLzApp(endpoint_) {
        endpoint = ILayerZeroEndpoint(endpoint_);
        gasReceiver = IAxelarGasReceiver(gasReceiver_);
    }

    function initialize() initializer public {
        // this function needs to be exposed for an upgrade to pass
    }

    function testNewImplementationActive() external pure returns (bool) {
        return true;
    }

    function sendMsgViaL0(
        uint16 _dstChainId,                            // dst lz chain id
        bytes memory _l0payload,                 
        address payable _refundAddress,             // refund Address(LayerZero will refund any superfluos gas back to the caller of send())
        address _zroPaymentAddress,                 // zroPayment Address
        bytes calldata _adapterParams               // adapterParams
    ) external payable {
        // run gas fee estimate on destination
        (uint256 messageFee, ) = endpoint.estimateFees(
            _dstChainId,
            address(this),
            _l0payload,
            false,
            _adapterParams
        );

        require(msg.value >= messageFee, "Insuffcient message fee");

        // send LayerZero message
        // uint16 _dstChainId, bytes memory _payload, address payable _refundAddress, address _zroPaymentAddress, bytes memory _adapterParams
        _lzSend(
            _dstChainId, 
            _l0payload, 
            _refundAddress, 
            _zroPaymentAddress, 
            _adapterParams
        );
    }


    //Axelar


    function sendMsgViaAxelar(
        string memory dstChain,
        string memory dstAddress,
        bytes memory payload
    ) external payable {
        
        if(msg.value > 0) {
            gasReceiver.payNativeGasForContractCall{ value: msg.value }(
                address(this),
                dstChain,
                dstAddress,
                payload,
                msg.sender
            );
        }
        gateway.callContract(
            dstChain,
            dstAddress,
            payload
        );
    }

    
    // function _executeWithToken(
    //     string memory sourceChain,
    //     string memory sourceAddress,
    //     bytes calldata payload,
    //     string memory tokenSymbol,
    //     uint256 amount
    // ) internal virtual {
    //     // decode recipient
    //     address memory recipient = abi.decode(payload, (address));
    //     // get ERC-20 address from gateway
    //     address tokenAddress = gateway.tokenAddresses(tokenSymbol);

    //     // transfer received tokens to the recipient
    //     IERC20(tokenAddress).transfer(recipient, amount);

    // }


    // LZ Receiver
    function _nonblockingLzReceive(uint16, bytes memory, uint64, bytes memory) internal override {
        revert();
    }


}