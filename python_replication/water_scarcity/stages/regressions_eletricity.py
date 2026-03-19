from .base import StageDefinition, make_stage


def build_stage() -> StageDefinition:
    return make_stage(
        stage_id="regressions_eletricity",
        display_name="Regressions Electricity",
        category="regression",
        stata_script="Regressions_eletricity.do",
        description="Estimate the hydroelectricity and power-loss regressions.",
        dependencies=("format_aquastat", "format_pwt", "format_wb", "format_wb2"),
        expected_outputs=("tables/Electricity.xls",),
    )
