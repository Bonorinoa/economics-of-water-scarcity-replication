from .base import StageDefinition, make_stage


def build_stage() -> StageDefinition:
    return make_stage(
        stage_id="regressions_water_pricing",
        display_name="Regressions Water Pricing",
        category="regression",
        stata_script="Regressions_Water_pricing.do",
        description="Estimate the OECD water pricing regressions and correlations.",
        dependencies=("format_aquastat", "format_pwt", "format_wb"),
        expected_outputs=(
            "tables/TableA2.tex",
            "tables/TableA3.tex",
        ),
    )
