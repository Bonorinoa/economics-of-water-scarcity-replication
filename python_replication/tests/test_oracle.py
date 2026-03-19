from water_scarcity.oracle import check_stage_outputs
from water_scarcity.stages import STAGE_REGISTRY


def test_oracle_reports_missing_outputs_for_empty_directory(tmp_path):
    stage = STAGE_REGISTRY["format_unido"]
    check = check_stage_outputs(stage, tmp_path)

    assert not check.ok
    assert len(check.missing) == len(stage.expected_outputs)
    assert not check.supplementary_missing


def test_oracle_passes_when_outputs_exist(tmp_path):
    stage = STAGE_REGISTRY["format_wb2"]
    target = tmp_path / stage.expected_outputs[0]
    target.parent.mkdir(parents=True, exist_ok=True)
    target.touch()

    check = check_stage_outputs(stage, tmp_path)

    assert check.ok
    assert len(check.existing) == 1


def test_oracle_treats_missing_supplementary_outputs_as_non_failing(tmp_path):
    stage = STAGE_REGISTRY["graph1_example"]
    target = tmp_path / stage.expected_outputs[0]
    target.parent.mkdir(parents=True, exist_ok=True)
    target.touch()

    check = check_stage_outputs(stage, tmp_path)

    assert check.ok
    assert not check.missing
    assert len(check.supplementary_missing) == 1
