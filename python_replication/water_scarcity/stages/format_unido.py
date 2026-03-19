from .base import StageDefinition, make_stage


def build_stage() -> StageDefinition:
    return make_stage(
        stage_id="format_unido",
        display_name="Format UNIDO",
        category="formatting",
        stata_script="Format_UNIDO.do",
        description="Format the UNIDO INDSTAT Rev. 2 source files into the derived industry panels.",
        expected_outputs=(
            "StataData_other/INDSTAT2_natcur_sel.dta",
            "StataData_other/INDSTAT2_VA.dta",
            "StataData_other/UNIDO_OtherY.dta",
        ),
    )
