from .base import StageDefinition, make_stage


def build_stage() -> StageDefinition:
    return make_stage(
        stage_id="graph1_example",
        display_name="Graph 1 Example",
        category="analysis",
        stata_script="Graph1_example.do",
        description="Build Graph 1 for total renewable water resources per capita.",
        dependencies=("format_aquastat", "format_wb"),
        expected_outputs=("graphs/Fig1_water_pc.png",),
    )
