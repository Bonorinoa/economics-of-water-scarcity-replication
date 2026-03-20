from .base import StageDefinition, make_stage


def build_stage() -> StageDefinition:
    return make_stage(
        stage_id="list_countries_aquastat_wb",
        display_name="List Countries Aquastat/WB",
        category="analysis",
        stata_script="List_countries_aquastat_WB.do",
        description="Create the advanced-economy and EMDE country list used in Table A.1.",
        dependencies=("format_aquastat", "format_pwt", "format_wb", "water_demand_pop_gdppc"),
        expected_outputs=("tables/TableA1.tex",),
    )
