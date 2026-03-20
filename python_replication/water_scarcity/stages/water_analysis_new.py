from .base import StageDefinition, make_stage


def build_stage() -> StageDefinition:
    return make_stage(
        stage_id="water_analysis_new",
        display_name="Water Analysis New",
        category="analysis",
        stata_script="Water_analysis_New.do",
        description="Build appendix water-productivity figures based on the SDG 6 dataset.",
        dependencies=("format_wb",),
        expected_outputs=(
            "graphs/FigA1_USDm3.png",
            "graphs/FigA2_USDm3_Sectors.png",
        ),
    )
