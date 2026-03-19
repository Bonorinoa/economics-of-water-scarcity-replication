from .base import StageDefinition, make_stage


def build_stage() -> StageDefinition:
    return make_stage(
        stage_id="format_pwt",
        display_name="Format PWT",
        category="formatting",
        stata_script="format_PWT.do",
        description="Prepare the Penn World Tables inputs and the US CPI deflator bridge.",
        expected_outputs=(
            "StataData_other/US_CPIAUCSL.dta",
            "StataData_other/PWT_old.dta",
            "StataData_other/PWT_new.dta",
        ),
    )
