pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./AllocationMetric.sol";

contract MpadToken is ERC20, Ownable, ReentrancyGuard {
    // token allocation
    uint256 private constant totalAllocation = 200e6 * 1e18;
    uint256 private constant seedSaleAllocation = 10e6 * 1e18;
    uint256 private constant privateSaleAllocation = 10e6 * 1e18;
    uint256 private constant preSaleAllocation = 30e6 * 1e18;
    uint256 private constant publicSaleAllocation = 10e6 * 1e18;
    uint256 private constant teamAllocation = 20e6 * 1e18;
    uint256 private constant advisorAllocation = 10e6 * 1e18;
    uint256 private constant liquidityAllocation = 60e6 * 1e18;
    uint256 private constant marketingAllocation = 30e6 * 1e18;
    uint256 private constant foundationReserveAllocation = 20e6 * 1e18;

    // TGE
    uint256 private constant seedSaleTGEAmount = 1e6 * 1e18;
    uint256 private constant privateSaleTGEAmount = 15e5 * 1e18;
    uint256 private constant preSaleTGEAmount = 6e6 * 1e18;
    uint256 private constant publicSaleTGEAmount = 5e6 * 1e18;

    // allocation metrics
    AllocationMetric private seedSaleMetric;
    AllocationMetric private privateSaleMetric;
    AllocationMetric private preSaleMetric;
    AllocationMetric private publicSaleMetric;
    AllocationMetric private teamMetric;
    AllocationMetric private advisorMetric;
    AllocationMetric private liquidityMetric;
    AllocationMetric private marketingMetric;
    AllocationMetric private foundationMetric;

    event ReleaseAllocation(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    constructor(
        string memory _name,
        string memory _symbol,
        address _seedSaleAddress,
        address _privateSaleAddress,
        address _preSaleAddress,
        address _publicSaleAddress,
        address _teamAddress,
        address _advisorAddress,
        address _liquidityAddress,
        address _marketingAddress,
        address _foundationReserveAddress
    ) public ERC20(_name, _symbol) {
        _mint(address(this), totalAllocation);

        _transfer(address(this), _seedSaleAddress, seedSaleTGEAmount);
        _transfer(address(this), _privateSaleAddress, privateSaleTGEAmount);
        _transfer(address(this), _preSaleAddress, preSaleTGEAmount);
        _transfer(address(this), _publicSaleAddress, publicSaleTGEAmount);

        seedSaleMetric = new AllocationMetric(
            _seedSaleAddress,
            seedSaleAllocation,
            seedSaleTGEAmount,
            (seedSaleAllocation * 15) / 1000,
            (seedSaleAllocation * 15) / 1000,
            now + 30 days,
            1 weeks,
            now + 30 days + 60 weeks
        );

        privateSaleMetric = new AllocationMetric(
            _privateSaleAddress,
            privateSaleAllocation,
            privateSaleTGEAmount,
            (privateSaleAllocation * 17) / 1000,
            (privateSaleAllocation * 17) / 1000,
            now + 30 days,
            1 weeks,
            now + 30 days + 50 weeks
        );

        preSaleMetric = new AllocationMetric(
            _preSaleAddress,
            preSaleAllocation,
            preSaleTGEAmount,
            (preSaleAllocation * 2) / 100,
            (preSaleAllocation * 2) / 100,
            now + 30 days,
            1 weeks,
            now + 30 days + 40 weeks
        );

        publicSaleMetric = new AllocationMetric(
            _publicSaleAddress,
            publicSaleAllocation,
            publicSaleTGEAmount,
            (publicSaleAllocation * 5) / 100,
            (publicSaleAllocation * 5) / 100,
            now + 30 days,
            1 weeks,
            now + 30 days + 10 weeks
        );

        teamMetric = new AllocationMetric(
            _teamAddress,
            teamAllocation,
            0,
            (teamAllocation * 10) / 100,
            (teamAllocation * 10) / 100,
            now + 360 days,
            30 days,
            now + 360 days + 300 days
        );

        advisorMetric = new AllocationMetric(
            _advisorAddress,
            advisorAllocation,
            0,
            (advisorAllocation * 10) / 100,
            (advisorAllocation * 10) / 100,
            now + 180 days,
            30 days,
            now + 480 days
        );

        liquidityMetric = new AllocationMetric(
            _liquidityAddress,
            liquidityAllocation,
            0,
            (liquidityAllocation * 10) / 100,
            (liquidityAllocation * 10) / 100,
            now + 30 days,
            30 days,
            now + 300 days
        );

        marketingMetric = new AllocationMetric(
            _marketingAddress,
            marketingAllocation,
            0,
            (liquidityAllocation * 15) / 100,
            (liquidityAllocation * 5) / 100,
            now + 1 weeks,
            30 days,
            now + 517 days
        );

        foundationMetric = new AllocationMetric(
            _foundationReserveAddress,
            foundationReserveAllocation,
            0,
            (foundationReserveAllocation * 10) / 100,
            (foundationReserveAllocation * 10) / 100,
            now + 30 days,
            30 days,
            now + 300 days
        );
    }

    function releaseAllocation(string memory _allocation) public {
        uint256 amount = 0;
        address walletOwner = address(0);

        if (
            keccak256(abi.encodePacked(_allocation)) ==
            keccak256(abi.encodePacked("Seed"))
        ) {
            (amount, walletOwner) = seedSaleMetric.releaseInfo(msg.sender);
        } else if (
            keccak256(abi.encodePacked(_allocation)) ==
            keccak256(abi.encodePacked("Private"))
        ) {
            (amount, walletOwner) = privateSaleMetric.releaseInfo(msg.sender);
        } else if (
            keccak256(abi.encodePacked(_allocation)) ==
            keccak256(abi.encodePacked("Pre"))
        ) {
            (amount, walletOwner) = preSaleMetric.releaseInfo(msg.sender);
        } else if (
            keccak256(abi.encodePacked(_allocation)) ==
            keccak256(abi.encodePacked("Public"))
        ) {
            (amount, walletOwner) = publicSaleMetric.releaseInfo(msg.sender);
        } else if (
            keccak256(abi.encodePacked(_allocation)) ==
            keccak256(abi.encodePacked("Team"))
        ) {
            (amount, walletOwner) = teamMetric.releaseInfo(msg.sender);
        } else if (
            keccak256(abi.encodePacked(_allocation)) ==
            keccak256(abi.encodePacked("Advisor"))
        ) {
            (amount, walletOwner) = advisorMetric.releaseInfo(msg.sender);
        } else if (
            keccak256(abi.encodePacked(_allocation)) ==
            keccak256(abi.encodePacked("Liquidity"))
        ) {
            (amount, walletOwner) = liquidityMetric.releaseInfo(msg.sender);
        } else if (
            keccak256(abi.encodePacked(_allocation)) ==
            keccak256(abi.encodePacked("Marketing"))
        ) {
            (amount, walletOwner) = marketingMetric.releaseInfo(msg.sender);
        } else if (
            keccak256(abi.encodePacked(_allocation)) ==
            keccak256(abi.encodePacked("Foundation"))
        ) {
            (amount, walletOwner) = foundationMetric.releaseInfo(msg.sender);
        }

        require(amount > 0 && walletOwner != address(0), "Invalid release");
        _transfer(address(this), walletOwner, amount);
        emit ReleaseAllocation(address(this), walletOwner, amount);
    }
}
