from .base import StageDefinition, make_stage


def build_stage() -> StageDefinition:
    return make_stage(
        stage_id="qr_regressions_growth_investment",
        display_name="QR Regressions Growth and Investment",
        category="regression",
        stata_script="QR_Regressions_growth_investment.do",
        description="Estimate the panel quantile regressions for growth, inflation, and investment.",
        dependencies=("format_aquastat", "format_pwt", "format_wb"),
        expected_outputs=(
            "tables/GDPgr_QR25.xls",
            "tables/GDPgr_QR50.xls",
            "tables/GDPgr_QR75.xls",
            "tables/Food_NatResR_QR25.xls",
            "tables/Food_NatResR_QR50.xls",
            "tables/Food_NatResR_QR75.xls",
            "tables/Investment_QR25.xls",
            "tables/Investment_QR50.xls",
            "tables/Investment_QR75.xls",
        ),
        notes=("This is the hardest stage to reproduce exactly in Python because the Stata package uses xtqreg.",),
    )
