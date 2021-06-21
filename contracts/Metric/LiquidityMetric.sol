// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LiquidityMetric is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public token;

    uint256 public constant totalAllocation = 60e6 * 1e18;
    uint256 public constant tgeAmount = 0;
    uint256 public remainingAmount = totalAllocation - tgeAmount;
    uint256 public firstTimeReleaseAmount = (totalAllocation * 30) / 100;
    uint256 public eachReleaseAmount = (totalAllocation * 10) / 100;
    uint256 public nextTimeRelease = now;
    uint256 public releasePeriod = 30 days;
    uint256 public lastTimeRelease = now + 210 days;
    bool public firstTimeReleased;

    event ReleaseAllocation(
        address indexed _address,
        uint256 _releaseAmount,
        uint256 _remainingAmount
    );

    constructor(address _token) public {
        token = IERC20(_token);
        firstTimeReleased = false;
    }

    function balance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function release() external onlyOwner() {
        require(remainingAmount > 0, "All tokens were released");
        require(
            block.timestamp >= nextTimeRelease,
            "Please wait until release time"
        );
        uint256 amount = 0;
        if (block.timestamp >= lastTimeRelease) {
            amount = remainingAmount;
        } else if (!firstTimeReleased) {
            firstTimeReleased = true;
            amount = firstTimeReleaseAmount;
        } else {
            if (eachReleaseAmount <= remainingAmount) {
                amount = eachReleaseAmount;
            } else {
                amount = remainingAmount;
            }
        }
        remainingAmount = remainingAmount.sub(amount);
        nextTimeRelease = nextTimeRelease.add(releasePeriod);
        token.safeTransfer(msg.sender, amount);
        emit ReleaseAllocation(msg.sender, amount, remainingAmount);
    }
}
