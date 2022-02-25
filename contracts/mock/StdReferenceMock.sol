// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IStdReference.sol";

contract StdReferenceMock is IStdReference {
    /// Returns the price data for the given base/quote pair. Revert if not available.
    function getReferenceData(string memory _base, string memory _quote)
        external
        view
        override
        returns (ReferenceData memory)
    {
        // Mock fixed values
        ReferenceData memory referenceData = ReferenceData({
            rate: uint256(2000 * 1e18),
            lastUpdatedBase: uint256(1645797279),
            lastUpdatedQuote: uint256(1645797279)
        });

        return referenceData;
    }

    /// Similar to getReferenceData, but with multiple base/quote pairs at once.
    function getReferenceDataBulk(
        string[] memory _bases,
        string[] memory _quotes
    ) external view override returns (ReferenceData[] memory) {
        ReferenceData[] memory referenceData = new ReferenceData[](0);
        return referenceData;
    }
}
