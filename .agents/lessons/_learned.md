# Lessons Learned

## LocalizeKit — printf `%c` handling

- **`%c` expects an integer code point, not a `Character`.** `String(format:)` reads
  `%c` as an `int` and prints its Unicode scalar (`65` → `"A"`). A Swift `Character`/`String`
  is encoded as an object pointer, so passing one to `%c` is a type mismatch, and a `Bool`
  renders an unprintable control glyph.
- **Dedicated `.character` type in both layers.** Runtime `SafeFormat`
  (`FormatArgumentType`) and the CLI linter (`ResolvedType`) each map `"c"` to a dedicated
  `.character` case that accepts integers only and rejects `Bool`/`String`/`Double`/object.
  Runtime falls back to the verbatim string; the linter flags mismatches (String/Double →
  error, Bool/object → warning).
- **Keep the two `FormatSpecifierParser` copies in sync.** There are two parsers — runtime
  (`Targets/LocalizeKit/Sources/Utils/`) and CLI (`Tools/LocalizeKit/Sources/LocalizeKitCore/Lint/`).
  Their `conversionTypes` tables must agree; changing one means changing the other.
- **Adding an enum case forces every exhaustive `switch`.** Adding `.character` to the CLI's
  shared `ResolvedType` required updating `isCompatible`, `describe`, and the
  `plural_count_type` switch (unreachable for `.character`, but needed for exhaustiveness).
- **Verify logic standalone when the full build is blocked.** `tuist test` fails on an
  unrelated Realm "Copy Module Map" step and `swift test` needs `indexstore-db` (network
  blocked). Compiling only the touched `Foundation`-only sources with a small stub for the
  `IndexStoreDB`-dependent `SemanticTypeResolver` gives a fast, reliable check.

## LocalizeKit — `%%` escaping on the empty-args path

- **A blanket `guard !arguments.isEmpty else { return format }` skips `%%` collapsing.**
  `SafeFormat.string` returned the format verbatim whenever no args were supplied, so
  `("100%% off", arguments: [])` yielded `"100%% off"` instead of `"100% off"`. Narrowed the
  fast path to `if arguments.isEmpty && !format.contains("%") { return format }` so a
  `%%`-only format still flows through `String(format:)`, while a format that references an
  argument slot with no args bails safely on the existing argument-count check (no crash).
- **`String(format:)` is the single mechanism for escaping too** — don't special-case `%%`
  with `replacingOccurrences`; route empty-args formats through the real formatter so escaping
  semantics stay consistent with the interpolating path.

## LocalizeKit — SafeFormat type-coverage tests

- **Cover every `matches` branch, not just the common ones.** The accept side had gaps:
  `Bool` → integer (asymmetric with `%c` rejecting `Bool`), all fixed-width int types, `%@`
  with `NSString` and with a genuine class instance (the `type(of:) is AnyClass` branch), and
  the `%p` → `.unknown` always-accept path. Added explicit tests for each, plus the matching
  reject tests (`%u`/`%@`/`%s` with wrong types).
- **Pin the `conversionTypes` map with a data-driven test.** `testParser_ConversionTypes_-`
  `EveryEntryParsesToItsMappedType` iterates `FormatSpecifier.conversionTypes` and asserts each
  key scans to one specifier of the mapped `expectedType`. This auto-covers aliases (`i`/`D`,
  `x`/`X`, `o`/`O`, uppercase float variants) so mistyping/dropping an entry fails a test —
  far better than enumerating 21 characters by hand. Paired with a check that
  `recognizedConversions == Set(conversionTypes.keys)`.
- **For non-deterministic or width-truncated accept cases, assert equality to native
  `String(format:)`.** A helper (`assertMatchesNative`) confirms SafeFormat forwarded rather
  than fell back, without hardcoding platform-dependent output (e.g. `%p` addresses). Only safe
  for known-non-crashing combinations — native `String(format:)` on a genuine mismatch traps.
- **Verify expected outputs with a throwaway `swift` script before hardcoding.** Ran a small
  `String(format:)` probe (`%d`+`Bool`→`"1"`, `%X`+255→`"FF"`, `%o`+8→`"10"`, etc.) to lock in
  exact expectations instead of guessing.
- **Running the suite:** `tuist generate --no-open` then
  `tuist test 'WhyNotSwiftUI Development' --test-targets LocalizeKitTests` runs green here
  (331+ tests). Add `--no-selective-testing` to force a full re-run when selective caching
  suppresses output for unchanged targets.

## LocalizeKit — documenting the `lint` command

- **README lives two levels under repo root.** `Tools/LocalizeKit/README.md` links to the
  shared docs with `../../docs/LocalizeKit/...`, not `docs/...`. The root `README.md` links to
  the tool with `Tools/LocalizeKit/README.md`.
- **Source is the authority for rule IDs, not the existing prose.** Pulled the exact rule set
  (`empty_key`, `format_arg_count_mismatch`, `format_missing_args`, `format_unused_args`,
  `format_arg_type_mismatch`, `format_arg_type_unverified`, `unescaped_percent`, `plural_empty`,
  `plural_missing_other`, `plural_form_inconsistent`, `plural_count_type`) and the
  `%@`/`%d`/`%f`/`%s`/`%c` compatibility matrix from `FormatLinter.swift` and `LintModels.swift`.
- **Document the full flag set from `LintCommand.swift`.** The CLI-guide options table had
  omitted `--warn-unverified` / `--no-warn-unverified` (default on) — the README now lists it
  alongside `--reporter`, `--strict`, `--index-store-path`, and `--verbose`.
- **Lint needs a fresh Xcode index.** Non-literal argument types come from IndexStoreDB, so the
  docs must call out building in Xcode (⌘B) first, the missing-index failure, and the
  "stale index" skip behaviour — added both to the command section and Troubleshooting.

