from .base import StageDefinition, make_stage


def build_stage() -> StageDefinition:
    return make_stage(
        stage_id="format_wb2",
        display_name="Format World Bank Electricity",
        category="formatting",
        stata_script="format_WB2.do",
        description="Prepare the electricity and energy-source World Bank panel data.",
        expected_outputs=("StataData_other/WB_eletricity.dta",),
    )
