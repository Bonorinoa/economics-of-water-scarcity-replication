import json

from water_scarcity.run import main


def test_cli_writes_manifest(tmp_path, capsys):
    manifest_path = tmp_path / "manifest.json"
    exit_code = main(["--stage", "all", "--manifest", str(manifest_path), "--json"])
    captured = capsys.readouterr()

    assert exit_code == 0
    assert manifest_path.exists()

    stdout_payload = json.loads(captured.out)
    file_payload = json.loads(manifest_path.read_text(encoding="utf-8"))

    assert stdout_payload["stages"]
    assert file_payload["stages"]
    assert stdout_payload["stages"][0]["stage_id"] == "format_unido"
