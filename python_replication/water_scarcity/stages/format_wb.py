from .base import StageDefinition, make_stage


def build_stage() -> StageDefinition:
    return make_stage(
        stage_id="format_wb",
        display_name="Format World Bank",
        category="formatting",
        stata_script="format_WB.do",
        description="Prepare the macro and governance World Bank data panels.",
        expected_outputs=(
            "StataData_other/WGI.dta",
            "StataData_other/Data_WB.dta",
        ),
    )
