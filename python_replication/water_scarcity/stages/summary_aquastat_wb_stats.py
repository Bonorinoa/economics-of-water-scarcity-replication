from .base import StageDefinition, make_stage


def build_stage() -> StageDefinition:
    return make_stage(
        stage_id="summary_aquastat_wb_stats",
        display_name="Summary Aquastat and World Bank Stats",
        category="analysis",
        stata_script="Summary_aquastat_WB_stats.do",
        description="Create the summary-statistics table for the macro and water variables.",
        dependencies=("format_aquastat", "format_pwt", "format_wb"),
        expected_outputs=("tables/SummaryStats.xls",),
    )
