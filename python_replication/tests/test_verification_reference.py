from water_scarcity.verification.reference import EXHIBITS, KNOWN_ALIAS_ANOMALIES, validate_reference_manifest


def test_reference_manifest_is_valid():
    assert validate_reference_manifest() == ()


def test_canonical_paths_are_unique_and_normalized():
    seen: set[str] = set()
    for exhibit in EXHIBITS:
        for artifact in exhibit.actual_artifacts:
            assert artifact.normalized_path == artifact.relative_path
            assert not artifact.normalized_path.startswith("/")
            assert ".." not in artifact.normalized_path.split("/")
            assert artifact.normalized_path not in seen
            seen.add(artifact.normalized_path)


def test_report_aliases_are_direct_or_cataloged():
    for exhibit in EXHIBITS:
        canonical_basenames = {artifact.basename for artifact in exhibit.actual_artifacts}
        for alias in exhibit.report_aliases:
            alias_name = alias.split("/")[-1]
            if alias_name in canonical_basenames:
                continue
            assert (exhibit.exhibit_id, alias_name) in KNOWN_ALIAS_ANOMALIES
