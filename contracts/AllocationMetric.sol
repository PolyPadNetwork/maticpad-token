pragma solidity ^0.6.6;

contract AllocationMetric {
    address private walletOwner;
    uint256 private maxAllocation;
    uint256 private nextTimeRelease;
    uint256 private initAllocation;
    uint256 private firstTimeRelease;
    uint256 private eachReleaseAmount;
    uint256 private remainingAmount;
    uint256 private releasePeriod;
    uint256 private firstTimeReleaseAmount;
    uint256 private lastTimeRelease;
    bool private firstTimeReleased;

    constructor(
        address _walletOwner,
        uint256 _maxAllocation,
        uint256 _initAllocation,
        uint256 _firstTimeReleaseAmount,
        uint256 _eachReleaseAmount,
        uint256 _nextTimeRelease,
        uint256 _releasePeriod,
        uint256 _lastTimeRelease
    ) public {
        walletOwner = _walletOwner;
        maxAllocation = _maxAllocation;
        initAllocation = _initAllocation;
        firstTimeReleaseAmount = _firstTimeReleaseAmount;
        eachReleaseAmount = _eachReleaseAmount;
        nextTimeRelease = _nextTimeRelease;
        releasePeriod = _releasePeriod;
        lastTimeRelease = _lastTimeRelease;
        remainingAmount = _maxAllocation - _initAllocation;
        firstTimeReleased = false;
    }

    function releaseInfo(address _requester) public returns (uint256, address) {
        require(_requester == walletOwner, "Not authorized");
        require(remainingAmount > 0, "All tokens are released already");
        require(
            block.timestamp >= nextTimeRelease,
            "Please wait until release time"
        );

        uint256 amount = 0;
        if (block.timestamp >= lastTimeRelease) {
            amount = remainingAmount;
        } else if (!firstTimeReleased) {
            amount = firstTimeReleaseAmount;
            firstTimeReleased = true;
        } else {
            if (eachReleaseAmount <= remainingAmount) {
                amount = eachReleaseAmount;
            } else {
                amount = remainingAmount;
            }
        }

        remainingAmount = remainingAmount - amount;
        nextTimeRelease = nextTimeRelease + releasePeriod;

        return (amount, walletOwner);
    }
}
