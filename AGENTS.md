# How this project is developed

## Git

Use self-contained commits.  While refining the output of one step, use
fixup commits for each refinement, until the developer validates the step.

Use git notes (in `refs/notes/commits`) to store the interactions that led
to each commit.  Set `notes.rewriteRef=refs/notes/commits` so notes follow
commits through `git rebase --autosquash`.

Before squashing, keep a local ref of the iterations
(e.g. `refs/iterations/<step>/<n>`).

## Design

Use the arclang MCP to establish a design before starting to code.

In cooperation with the developer, go through the following steps, moving to
the next one only when the current one is validated:

1. operational analysis
2. requirements
3. system analysis
4. logical architecture
5. physical architecture

In addition, an arclang design must pass the following checks:

* export to SysML v2, and validation of the result with
  `sysml -validate -strict <exported files>`
* export to Capella, and validation of the result with py-capellambse's
  `model.validate()` (stricter than `capellambse validate`), extended with
  the project rules of `checks/capella_rules.py`:

  ```sh
  python checks/validate-capella <directory holding the exported model>
  ```

  with `python` being the interpreter py-capellambse is installed for.

`make check` runs all of these (set `CAPELLAMBSE_PYTHON` to that
interpreter), as CI does.

## Element IDs

arclang forbids reusing an element ID.  The MCP enforces this, so to change an
element while refining, restore the previous model and apply the refined
instructions to it rather than editing in place.  Since we squash before
publication, only the succession of final commits needs to follow this rule
strictly.
