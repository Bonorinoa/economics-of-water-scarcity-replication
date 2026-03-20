from .base import StageDefinition, make_stage


def build_stage() -> StageDefinition:
    return make_stage(
        stage_id="water_analysis_aquastat",
        display_name="Water Analysis Aquastat",
        category="analysis",
        stata_script="Water_analysis_Aquastat.do",
        description="Build the main water-use and water-stress figures.",
        dependencies=("format_aquastat", "format_wb"),
        expected_outputs=(
            "graphs/Fig2_daily_water_use_per_capita.png",
            "graphs/Fig3_WaterStress_SectorsSDG.png",
            "graphs/Fig4_WaterStress_WB.png",
            "graphs/Fig5_WaterStress_2000_2020_WB.png",
        ),
    )
