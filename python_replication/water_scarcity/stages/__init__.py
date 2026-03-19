from __future__ import annotations

from .format_aquastat import build_stage as build_format_aquastat
from .format_pwt import build_stage as build_format_pwt
from .format_unido import build_stage as build_format_unido
from .format_wb import build_stage as build_format_wb
from .format_wb2 import build_stage as build_format_wb2
from .graph1_example import build_stage as build_graph1_example
from .list_countries_aquastat_wb import build_stage as build_list_countries_aquastat_wb
from .qr_regressions_growth_investment import build_stage as build_qr_regressions_growth_investment
from .regressions_eletricity import build_stage as build_regressions_eletricity
from .regressions_growth_investment_water import build_stage as build_regressions_growth_investment_water
from .regressions_pwt import build_stage as build_regressions_pwt
from .regressions_water_pricing import build_stage as build_regressions_water_pricing
from .summary_aquastat_wb_stats import build_stage as build_summary_aquastat_wb_stats
from .water_analysis_aquastat import build_stage as build_water_analysis_aquastat
from .water_analysis_more_regressions import build_stage as build_water_analysis_more_regressions
from .water_analysis_new import build_stage as build_water_analysis_new
from .water_demand_pop_gdppc import build_stage as build_water_demand_pop_gdppc
from .water_unido import build_stage as build_water_unido

ALL_STAGES = (
    build_format_unido(),
    build_format_aquastat(),
    build_format_pwt(),
    build_format_wb(),
    build_format_wb2(),
    build_water_demand_pop_gdppc(),
    build_summary_aquastat_wb_stats(),
    build_graph1_example(),
    build_water_analysis_aquastat(),
    build_list_countries_aquastat_wb(),
    build_water_analysis_new(),
    build_regressions_growth_investment_water(),
    build_water_analysis_more_regressions(),
    build_water_unido(),
    build_regressions_water_pricing(),
    build_regressions_pwt(),
    build_qr_regressions_growth_investment(),
    build_regressions_eletricity(),
)

STAGE_REGISTRY = {stage.stage_id: stage for stage in ALL_STAGES}


def select_stages(stage_id: str):
    if stage_id == "all":
        return ALL_STAGES
    return (STAGE_REGISTRY[stage_id],)
