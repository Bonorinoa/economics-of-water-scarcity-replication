from .base import StageDefinition, make_stage


def build_stage() -> StageDefinition:
    return make_stage(
        stage_id="water_unido",
        display_name="Water UNIDO",
        category="regression",
        stata_script="Water_UNIDO.do",
        description="Estimate the manufacturing growth regressions that merge UNIDO with the water datasets.",
        dependencies=("format_unido", "format_aquastat", "format_pwt", "format_wb"),
        expected_outputs=("tables/Table8.tex",),
    )
