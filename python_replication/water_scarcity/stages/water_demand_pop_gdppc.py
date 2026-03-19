from .base import StageDefinition, make_stage


def build_stage() -> StageDefinition:
    return make_stage(
        stage_id="water_demand_pop_gdppc",
        display_name="Water Demand, Population, GDP per Capita",
        category="analysis",
        stata_script="Water_demand_pop_GDPpc.do",
        description="Estimate the water demand model and produce the 2050 demand projections.",
        dependencies=("format_aquastat", "format_pwt", "format_wb"),
        expected_outputs=(
            "StataData_other/Pop2050.dta",
            "tables/Water_pop_gdp.xls",
            "tables/Water_demand_2050.xlsx",
        ),
    )
