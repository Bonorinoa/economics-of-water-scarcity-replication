from .base import StageDefinition, make_stage


def build_stage() -> StageDefinition:
    return make_stage(
        stage_id="format_aquastat",
        display_name="Format Aquastat",
        category="formatting",
        stata_script="format_Aquastat.do",
        description="Select and normalize the Aquastat bulk variables used throughout the replication.",
        expected_outputs=(
            "StataData_other/Aquastat_Bulk.dta",
            "StataData_other/Aquastat_Selected.dta",
        ),
    )
