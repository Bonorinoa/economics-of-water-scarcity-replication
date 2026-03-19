from .base import StageDefinition, make_stage


def build_stage() -> StageDefinition:
    return make_stage(
        stage_id="regressions_pwt",
        display_name="Regressions PWT",
        category="regression",
        stata_script="Regressions_PWT.do",
        description="Estimate the Penn World Tables robustness regressions.",
        dependencies=("format_aquastat", "format_pwt", "format_wb", "format_wb2"),
        expected_outputs=(
            "tables/PWT_level.xls",
            "tables/PWT_growth.xls",
            "tables/GDPgr_PWT.xls",
            "tables/Investmentgr_PWT.xls",
        ),
    )
