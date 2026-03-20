from __future__ import annotations

import csv
import sys
from pathlib import Path


RAW_DIR = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.cwd()
OUT_DIR = Path(sys.argv[2]) if len(sys.argv) > 2 else RAW_DIR.parent


ROW_LABELS = {
    "lagpop": "Lagged ln(population)",
    "lagGDPpc": "Lagged ln(GDP per capita)",
    "Constant": "Constant",
    "Freshwater_withdrawal_rIR": "Freshwater withdrawal (% of internal resources)",
    "FreshwaterWithdrawal_rtrwr": "Freshwater withdrawal (% of renewable resources)",
    "WaterStress": "Freshwater withdrawal (% of available freshwater)",
    "Total_water_withdrawal_pc": "ln(total water withdrawal per capita)",
    "lnGDP": "ln(GDP per capita)",
    "WSS_price": "Water supply and sanitation price",
    "c.Freshwater_withdrawal_rIR#c.WD": "FW (% internal resources) × water dependence",
    "c.FreshwaterWithdrawal_rtrwr#c.WD": "FW (% renewable resources) × water dependence",
    "c.WaterStress#c.WD": "FW (% available freshwater) × water dependence",
    "c.Total_water_withdrawal_pc#c.WD": "ln(total water withdrawal pc) × water dependence",
}

DEPVAR_LABELS = {
    "Country_water_withdrawal": "Country water withdrawal",
    "Freshwater_withdrawal_rIR": "FW (% internal resources)",
    "FreshwaterWithdrawal_rtrwr": "FW (% renewable resources)",
    "WaterStress": "FW (% available freshwater)",
    "Total_gr": "GDP growth",
    "GFCF_gr": "Investment growth",
    "CPI_inf": "Inflation",
    "AgricultureForestryFishing_rGDP": "Agriculture share of GDP",
    "Industry_rGDP": "Industry share of GDP",
    "Services_rGDP": "Services share of GDP",
    "growth_value": "Manufacturing growth",
    "M_Freshwater_withdrawal_rIR": "Mean FW (% internal resources)",
    "M_FreshwaterWithdrawal_rtrwr": "Mean FW (% renewable resources)",
    "M_WaterStress": "Mean FW (% available freshwater)",
    "ElecHydroSh": "Hydroelectricity share",
}

SUMMARY_LABELS = {
    "Total_gr": "Annual GDP growth (%)",
    "GFCF_gr": "Annual fixed investment growth (%)",
    "CPI_inf": "Annual CPI inflation (%)",
    "Freshwater_withdrawal_rIR": "FW (% of internal resources)",
    "FreshwaterWithdrawal_rtrwr": "FW (% of renewable resources)",
    "WaterStress": "FW (% of available freshwater)",
    "Total_water_withdrawal_pc": "ln(total water withdrawal per capita)",
    "WaterProductivity": "ln(water productivity)",
    "WaterUseEfficiency": "ln(water use efficiency)",
    "lnGDP": "ln(GDP per capita)",
}

MATRIX_LABELS = {
    "Total_water_withdrawal_pc": "ln(total water withdrawal per capita)",
    "Freshwater_withdrawal_rIR": "FW (% internal resources)",
    "FreshwaterWithdrawal_rtrwr": "FW (% renewable resources)",
    "WaterStress": "FW (% available freshwater)",
    "WSS_price": "Water supply and sanitation price",
}


def escape_tex(text: str) -> str:
    return (
        text.replace("\\", r"\textbackslash{}")
        .replace("&", r"\&")
        .replace("%", r"\%")
        .replace("$", r"\$")
        .replace("#", r"\#")
        .replace("_", r"\_")
    )


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


def fmt_number(value: str | float | None, digits: int = 2) -> str:
    if value in (None, ""):
        return ""
    if isinstance(value, str):
        value = value.replace(",", "").strip()
        if not value:
            return ""
    try:
        number = float(value)
    except (TypeError, ValueError):
        return escape_tex(str(value))
    return f"{number:.{digits}f}"


def parse_outreg2(path: Path) -> dict[str, object]:
    rows: list[list[str]] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        rows.append([cell.strip() for cell in line.split("\t")])

    columns = [cell for cell in rows[0] if cell]
    ncols = len(columns)
    depvars = (rows[1][1:] + [""] * ncols)[:ncols]
    body: list[dict[str, object]] = []
    stats: list[tuple[str, list[str]]] = []
    notes: list[str] = []

    i = 2
    while i < len(rows):
        cells = (rows[i] + [""] * (ncols + 1))[: ncols + 1]
        label = cells[0]
        values = cells[1:]
        lower = label.lower()
        if label in {"Observations", "R-squared"}:
            stats.append((label, values))
            i += 1
            continue
        if "standard errors" in lower or label.startswith("***"):
            notes.append(label)
            i += 1
            continue

        se_values: list[str] | None = None
        if i + 1 < len(rows):
            next_cells = (rows[i + 1] + [""] * (ncols + 1))[: ncols + 1]
            if not next_cells[0]:
                se_values = next_cells[1:]
                i += 1
        body.append({"label": label, "coef": values, "se": se_values})
        i += 1

    return {"columns": columns, "depvars": depvars, "body": body, "stats": stats, "notes": notes}


def table_block(lines: list[str], ncols: int) -> list[str]:
    if ncols > 5:
        return [r"\resizebox{\textwidth}{!}{%", *lines, "}"]
    return lines


def render_estimation_panel(parsed: dict[str, object], panel_title: str | None = None) -> list[str]:
    columns = parsed["columns"]
    depvars = [DEPVAR_LABELS.get(dep, dep) for dep in parsed["depvars"]]
    body = parsed["body"]
    stats = parsed["stats"]
    lines = []
    if panel_title:
        lines.append(rf"\textit{{{escape_tex(panel_title)}}}\\")

    tabular = [rf"\begin{{tabular}}{{l{'c' * len(columns)}}}", r"\hline"]
    tabular.append(" & " + " & ".join(escape_tex(col) for col in columns) + r" \\")
    tabular.append("Dependent variable & " + " & ".join(escape_tex(dep) for dep in depvars) + r" \\")
    tabular.append(r"\hline")
    for row in body:
        label = ROW_LABELS.get(row["label"], row["label"])
        tabular.append(
            escape_tex(label)
            + " & "
            + " & ".join(escape_tex(value) for value in row["coef"])
            + r" \\"
        )
        if row["se"] is not None:
            tabular.append(" & " + " & ".join(escape_tex(value) for value in row["se"]) + r" \\")
    tabular.append(r"\hline")
    for label, values in stats:
        tabular.append(escape_tex(label) + " & " + " & ".join(escape_tex(v) for v in values) + r" \\")
    tabular.append(r"\hline")
    tabular.append(r"\end{tabular}")
    lines.extend(table_block(tabular, len(columns)))
    return lines


def render_simple_panel(headers: list[str], rows: list[list[str]], panel_title: str | None = None, wide: bool = False) -> list[str]:
    lines = []
    if panel_title:
        lines.append(rf"\textit{{{escape_tex(panel_title)}}}\\")
    tabular = [rf"\begin{{tabular}}{{l{'c' * (len(headers) - 1)}}}", r"\hline"]
    tabular.append(" & ".join(escape_tex(header) for header in headers) + r" \\")
    tabular.append(r"\hline")
    for row in rows:
        tabular.append(" & ".join(escape_tex(cell) for cell in row) + r" \\")
    tabular.append(r"\hline")
    tabular.append(r"\end{tabular}")
    lines.extend(table_block(tabular, len(headers) - 1 if wide else 0))
    return lines


def write_table(filename: str, caption: str, sections: list[list[str]], notes: str) -> None:
    lines = [r"\begin{table}[htbp]", r"\centering", rf"\caption{{{escape_tex(caption)}}}", r"\small"]
    for index, section in enumerate(sections):
        if index:
            lines.append(r"\vspace{0.75em}")
        lines.extend(section)
    if notes:
        lines.append(r"\vspace{0.5em}")
        lines.append(rf"\parbox{{0.95\textwidth}}{{\footnotesize \textit{{Notes}}: {escape_tex(notes)}}}")
    lines.append(r"\end{table}")
    (OUT_DIR / filename).write_text("\n".join(lines) + "\n", encoding="utf-8")


def build_table1() -> None:
    regression = parse_outreg2(RAW_DIR / "Water_pop_gdp.txt")
    projection_rows = read_csv(RAW_DIR / "Table1_projection.csv")
    projection_headers = [
        "Scenario",
        "Country water withdrawal",
        "FW (% internal resources)",
        "FW (% renewable resources)",
        "FW (% available freshwater)",
    ]
    projection_body = []
    for row in projection_rows:
        projection_body.append(
            [
                row["scenario"] or "Population-weighted mean",
                fmt_number(row["Country_water_withdrawal_"], 2),
                fmt_number(row["Freshwater_withdrawal_rIR_"], 2),
                fmt_number(row["FreshwaterWithdrawal_rtrwr_"], 2),
                fmt_number(row["WaterStress_"], 2),
            ]
        )
    write_table(
        "Table1.tex",
        "Table 1. Water demand model and projected 2050 changes",
        [
            render_estimation_panel(regression, "Panel A. Water demand regressions"),
            render_simple_panel(projection_headers, projection_body, "Panel B. Projected 2050 changes", wide=True),
        ],
        "Panel B uses the UN median 2050 population projection and assumes 2% annual real GDP per capita growth from 2020 to 2050.",
    )


def build_table2() -> None:
    rows = []
    for row in read_csv(RAW_DIR / "Table2_summary.csv"):
        rows.append(
            [
                SUMMARY_LABELS.get(row["_varname"], row["_varname"]),
                fmt_number(row["min"], 2),
                fmt_number(row["max"], 2),
                fmt_number(row["median"], 2),
                fmt_number(row["mean"], 2),
                fmt_number(row["sd"], 2),
            ]
        )
    write_table(
        "Table2.tex",
        "Table 2. Summary statistics",
        [render_simple_panel(["Variable", "Min", "Max", "Median", "Mean", "SD"], rows, wide=True)],
        "Summary statistics for the panel sample used in the main macro regressions.",
    )


def build_table6() -> None:
    rows = []
    for row in read_csv(RAW_DIR / "Table6_effects.csv"):
        rows.append(
            [
                row["outcome"],
                fmt_number(row["fw_internal"], 2),
                fmt_number(row["fw_renewable"], 2),
                fmt_number(row["fw_available"], 2),
            ]
        )
    write_table(
        "Table6.tex",
        "Table 6. One-standard-deviation effects of water scarcity",
        [render_simple_panel(["Outcome", "FW (% internal resources)", "FW (% renewable resources)", "FW (% available freshwater)"], rows)],
        "Entries report the change in the outcome associated with a one-standard-deviation increase in each water scarcity measure.",
    )


def build_table_a1() -> None:
    raw_rows = read_csv(RAW_DIR / "TableA1_countries.csv")
    groups = {"1": [], "0": []}
    for row in raw_rows:
        groups[row["AE"]].append(f"{row['CountryName']} ({row['iso2']})")
    rows = [
        ["Advanced economies", ", ".join(groups["1"])],
        ["Emerging market and developing economies", ", ".join(groups["0"])],
    ]
    section = [
        r"\begin{tabular}{p{0.22\textwidth}p{0.70\textwidth}}",
        r"\hline",
        r"Region & Country list \\",
        r"\hline",
    ]
    section.extend(" & ".join(escape_tex(cell) for cell in row) + r" \\" for row in rows)
    section.extend([r"\hline", r"\end{tabular}"])
    write_table(
        "TableA1.tex",
        "Table A1. Country sample used in the empirical analysis",
        [section],
        "Country classification follows the author-supplied matching file used by the replication package.",
    )


def build_matrix_table(filename: str, caption: str, raw_name: str) -> None:
    raw_rows = read_csv(RAW_DIR / raw_name)
    headers = [""] + [MATRIX_LABELS.get(col, col) for col in raw_rows[0] if col != "variable"]
    rows = []
    for row in raw_rows:
        rows.append([MATRIX_LABELS.get(row["variable"], row["variable"])] + [fmt_number(row[col], 3) for col in row if col != "variable"])
    write_table(filename, caption, [render_simple_panel(headers, rows, wide=True)], "Pairwise correlations computed on the 2008 OECD water pricing sample.")


def build_single_estimation(filename: str, caption: str, raw_name: str, notes: str) -> None:
    parsed = parse_outreg2(RAW_DIR / raw_name)
    write_table(filename, caption, [render_estimation_panel(parsed)], notes)


def build_quantile_table(filename: str, caption: str, prefix: str, notes: str) -> None:
    sections = []
    for quantile in ("25", "50", "75"):
        parsed = parse_outreg2(RAW_DIR / f"{prefix}{quantile}.txt")
        sections.append(render_estimation_panel(parsed, f"Quantile {quantile}"))
    write_table(filename, caption, sections, notes)


def build_table8() -> None:
    sections = [
        render_estimation_panel(parse_outreg2(RAW_DIR / "Table8_total_manufacturing.txt"), "Panel A. Total manufacturing"),
        render_estimation_panel(parse_outreg2(RAW_DIR / "Table8_automotive.txt"), "Panel B. Automotive industry"),
    ]
    write_table(
        "Table8.tex",
        "Table 8. Manufacturing growth and water dependence",
        sections,
        "Panel A reports total manufacturing regressions. Panel B reports motor vehicles, trailers and semi-trailers.",
    )


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    build_table1()
    build_table2()
    build_single_estimation("Table3.tex", "Table 3. GDP growth regressions", "Table3_GDPgr.txt", "Country and year fixed effects included; standard errors clustered by country.")
    build_single_estimation("Table4.tex", "Table 4. Investment growth regressions", "Table4_Investment.txt", "Country and year fixed effects included; standard errors clustered by country.")
    build_single_estimation("Table5.tex", "Table 5. Inflation regressions", "Table5_CPI.txt", "Country and year fixed effects included; standard errors clustered by country.")
    build_table6()
    build_single_estimation("Table7.tex", "Table 7. Regressions for water and sectoral GDP shares", "Table7_sector_shares.txt", "Country and year fixed effects included; standard errors clustered by country.")
    build_table8()
    build_table_a1()
    build_matrix_table("TableA2.tex", "Table A2. Correlation between water scarcity and water pricing", "TableA2_correlation.csv")
    build_single_estimation("TableA3.tex", "Table A3. Water pricing regressions", "TableA3_freshwater_prices.txt", "Cross-sectional regressions for the 2008 OECD water pricing sample.")
    build_quantile_table("TableA4.tex", "Table A4. Panel quantile regressions for GDP growth", "GDPgr_QR", "Panel quantile regressions with country fixed effects.")
    build_quantile_table("TableA5.tex", "Table A5. Panel quantile regressions for investment growth", "Investment_QR", "Panel quantile regressions with country fixed effects.")
    build_quantile_table("TableA6.tex", "Table A6. Panel quantile regressions for inflation", "CPI_QR", "Panel quantile regressions with country fixed effects.")
    build_single_estimation("TableA7.tex", "Table A7. Hydroelectricity regressions", "TableA7_hydroelectricity.txt", "Country and year fixed effects included; standard errors clustered by country.")


if __name__ == "__main__":
    main()
