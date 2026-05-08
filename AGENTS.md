# qcom-build-utils — Agent Guidelines

## Purpose

`qcom-build-utils` is the shared CI/CD backbone for Qualcomm Linux Debian packaging.
It centralizes reusable GitHub workflows, composite actions, and helper scripts used by
many external repositories (especially `pkg-*` repos and upstream source repos).

When editing this repository, optimize for:

- interface stability,
- backward compatibility,
- minimal and reviewable diffs,
- docs that stay in sync with behavior.

## Repository Layout

- `.github/workflows/`: reusable workflows called via `workflow_call`
- `.github/actions/`: composite actions used by reusable workflows
- `scripts/`: Python and shell helpers (ABI/APT/promotion helpers)
- `kernel/scripts/`: kernel image and `.deb` build scripts
- `bootloader/`: EFI/ESP image build script
- `rootfs/scripts/`: rootfs build script
- `docs/`: workflow/action/integration documentation

## Treat These as Public Interfaces

Changes in these paths can affect many downstream repos and should be handled carefully:

- `.github/workflows/*.yml`
- `.github/actions/*/action.yml`
- `scripts/deb_abi_checker.py`
- `scripts/ppa_interface.py`
- `scripts/ppa_organizer.py`
- `scripts/merge_debian_packaging_upstream`

For interface paths above, avoid breaking changes unless the request explicitly calls for one.

## Working Rules for Agents

1. Keep scope tight to the user request; avoid opportunistic refactors.
2. Preserve existing workflow/action inputs, outputs, secrets, and env names when possible.
3. Prefer additive changes over renames/removals for workflow contracts.
4. Keep shell/YAML changes easy to diff; avoid reformatting unrelated blocks.
5. If behavior changes, update docs in the same change set.
6. Call out compatibility impact explicitly in your handoff.

## Workflow & Action Conventions

- Reusable workflows are consumed through `workflow_call`; input names are contract surface.
- Most package builds are ARM64-targeted and run in `ghcr.io/qualcomm-linux/pkg-builder:*` containers.
- `build_package` supports both source and prebuilt modes (via `upstream.conf`); maintain both paths.
- Source builds rely on Debian packaging conventions (`debian/changelog`, `gbp`, `sbuild`).
- Promotion/release workflows rely on branch/tag naming patterns (`debian/*`, `upstream/*`, `<distro>/<version>`).

## Script Conventions

### Python (`scripts/*.py`)

- Keep existing CLI flags/defaults stable unless explicitly requested.
- Preserve return/exit semantics where consumers may depend on them.
- For ABI checker work, preserve bitmask meanings in `deb_abi_checker.py`.
- Keep logging actionable and consistent with `color_logger` patterns.

### Shell (`scripts/*`, `kernel/scripts/*`, `bootloader/*`, `rootfs/scripts/*`)

- Keep scripts fail-fast with clear error text.
- Preserve required environment variable names and command-line interfaces.
- Avoid introducing bash-specific features into scripts that are intended to be portable unless already bash-based.

## Documentation Sync Expectations

When functionality changes, update matching docs:

- Reusable workflows: `docs/reusable-workflows.md`
- Composite actions: `docs/github-actions.md` and `docs/actions/*.md`
- High-level behavior/integration: `README.md`, `docs/workflow-architecture.md`, `docs/package-repo-integration.md`
- Script CLI behavior: `scripts/README.md`

If docs are intentionally deferred, state that clearly in the final handoff.

## Validation Checklist

Run the smallest relevant checks for touched files:

- YAML/workflow/action edits:
  - verify syntax/indentation,
  - verify referenced input/secret/env names stay consistent.
- Python edits:
  - `python3 -m py_compile scripts/*.py`
- Shell edits:
  - `bash -n <script>` for each modified shell script.
- Docs-only edits:
  - verify file paths, workflow/action names, and examples remain accurate.

If end-to-end CI cannot be run locally, explicitly list what was validated and what remains unverified.

## Common Pitfalls

- Breaking reusable workflow inputs consumed by external repositories.
- Modifying ABI checker return semantics without coordinating consumers.
- Updating behavior but leaving docs/examples stale.
- Assuming x86-only behavior in ARM64-targeted workflow paths.
- Mixing unrelated cleanups into contract-sensitive files.

## PR/Change Handoff Guidance

When handing off changes, include:

- what interface (if any) changed,
- downstream impact/risk,
- validation performed,
- any required repository variables/secrets relevant to the change
  (for example `PKG_REPO_GITHUB_NAME`, `UPSTREAM_REPO_GITHUB_NAME`, PAT/token expectations).