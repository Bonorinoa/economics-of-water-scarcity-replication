from .base import StageDefinition, make_stage


def build_stage() -> StageDefinition:
    return make_stage(
        stage_id="regressions_growth_investment_water",
        display_name="Regressions Growth, Investment, Water",
        category="regression",
        stata_script="Regressions_growth_investment_water.do",
        description="Estimate the baseline macro regressions linking water scarcity to growth, investment, and inflation.",
        dependencies=("format_aquastat", "format_pwt", "format_wb"),
        expected_outputs=(
            "tables/Table3.tex",
            "tables/Table4.tex",
            "tables/Table5.tex",
            "tables/Table6.tex",
        ),
    )
