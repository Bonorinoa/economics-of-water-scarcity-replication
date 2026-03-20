from .base import StageDefinition, make_stage


def build_stage() -> StageDefinition:
    return make_stage(
        stage_id="water_analysis_more_regressions",
        display_name="Water Analysis More Regressions",
        category="regression",
        stata_script="Water_analysis_More_regressions.do",
        description="Estimate the sector-share regressions used for Table 7.",
        dependencies=("format_aquastat", "format_pwt", "format_wb"),
        expected_outputs=("tables/Table7.tex",),
    )
