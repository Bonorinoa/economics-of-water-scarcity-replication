from water_scarcity.config import build_project_paths
from water_scarcity.stages import ALL_STAGES, STAGE_REGISTRY


def test_stage_registry_count():
    assert len(ALL_STAGES) == 18
    assert len(STAGE_REGISTRY) == 18


def test_stage_ids_are_unique():
    assert len({stage.stage_id for stage in ALL_STAGES}) == len(ALL_STAGES)


def test_all_stata_scripts_exist():
    paths = build_project_paths()
    missing = [stage.stata_script_path(paths.code_root) for stage in ALL_STAGES if not stage.stata_script_path(paths.code_root).exists()]
    assert not missing
