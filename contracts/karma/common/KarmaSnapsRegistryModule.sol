// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../../base/Module.sol";

import "../../libs/KeyValueParser.sol";
import {Schema} from "../../libs/Structs.sol";
import {SnapsRegistry} from "../../metamask/SnapsRegistry.sol";

contract KarmaSnapsRegistryModule is Module {
    using KeyValueParser for KeyValueParser.KeyValueMap;
    KeyValueParser.KeyValueMap private keyValueMap;

    SnapsRegistry public $snapsRegistry;
    string constant SNAP_CHECKSUM = "snapChecksum";

    error snapChecksumNotFound();
    error InvalidSnapsRegistry();

    constructor(
        MasterRegistry _masterRegistry,
        SchemasRegistry _schemasRegistry,
        AttestorsRegistry _attestorsRegistry,
        SnapsRegistry _snapsRegistry
    ) Module(_masterRegistry, _schemasRegistry, _attestorsRegistry) {
        if (_snapsRegistry == SnapsRegistry(address(0))) {
            revert InvalidSnapsRegistry();
        }
        
        $snapsRegistry = _snapsRegistry;
    }

    function run(
        Attestation memory attestation,
        uint256 value,
        bytes memory data
    ) external override returns (Attestation memory, bytes memory) {
        Schema memory schema = $schemasRegistry.getSchema(attestation.schemaId);
        keyValueMap.parseKeyValue(schema.schema, attestation.attestationData);
        string memory checksum = keyValueMap.getValueByKey(SNAP_CHECKSUM);

        if (!$snapsRegistry.isSnapVersionAdded(checksum)) {
            revert snapChecksumNotFound();
        }

        // todo validate isActive, snadId

        return (attestation, bytes(""));
    }
}
