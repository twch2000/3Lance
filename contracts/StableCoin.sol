// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import { ERC20 } from "./ERC20.sol"; 
import { DepositorCoin } from "./DepositorCoin.sol"; 
import { Oracle } from "./Oracle.sol";  

contract StableCoin is ERC20 {
    DepositorCoin public depositorCoin; 

    uint256 public feeRatePercentage; 
    Oracle public oracle; 
    
    constructor(uint256 _feeRatePercentage, Oracle _oracle) ERC20("StableCoin", "STC") { 
        feeRatePercentage = _feeRatePercentage; 
        oracle = _oracle; 

    } 

    function mint() external payable {
        uint256 fee = _getFee(msg.value); 
        uint256 remainingEth = msg.value - fee; 

        uint256 mintStableCoinAmount = msg.value * oracle.getPrice(); 
        _mint(msg.sender, mintStableCoinAmount);

    }

     function burn(uint256 burnStableCoinAmount) external payable {
        _burn(msg.sender, burnStableCoinAmount); 

        uint256 refundingEth = burnStableCoinAmount /  oracle.getPrice(); 
        uint256 fee = _getFee(refundingEth); 
        uint256 remainingRefundingEth = refundingEth - fee; 

        (bool success,) = msg.sender.call{value: remainingRefundingEth} (" "); 
        require(success, "STC: Burn refuund transaction failed"); 

    }

    function _getFee(uint256 ethAmount) private view returns (uint256) {
        bool hasDepositors = address (depositorCoin) != address(0) && depositorCoin.totalSupply() > 0; 
        if (!hasDepositors) {
            return 0; 
        }

        return (feeRatePercentage  * ethAmount) / 100; 
    }

    function depositCollaterBuffer() external payable {
        int256 deficitOrSurplusInUsd = _getDeficitOrSurplusInContractInUsd();

        if (deficitOrSurplusInUsd <= 0 ) {
            return; 
        }

        uint256 surplusInUsd = uint256(deficitOrSurplusInUsd); 
        uint256 dpcInUsdPrice = _getDPCinUsdPrice(surplusInUsd); 
    }

    function _getDeficitOrSurplusInContractInUsd() private view returns (uint256) {
        uint256 ethContractBalanceInUSD = (address(this).balance - msg.value) * 
            oracle.getPrice(); 
        uint256 totalStableCoinBalanceInUsd = totalSupply; 
        int256 deficitOrSurplus = int256(ethContractBalanceInUSD) - 
            int256(totalStableCoinBalanceInUsd); 

        return deficitOrSurplus; 

    }

    function _getDPCInUsdPrice(uint256 surplusInUsd) private view returns (uint256) {
        return depositorCoin.totalSupply() / surplusInUsd; 
    }
}

