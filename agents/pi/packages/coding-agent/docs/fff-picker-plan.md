# Extension Design: FFF Advanced File Picker for pi

## Overview
This extension overrides the default `@` file mention behavior in `pi`. It replaces the built-in fuzzy search with the high-performance `fff` algorithm (a Rust-based library) and adds visual enhancements like ANSI-based match highlighting.

## Core Requirements
1.  **Native Bindings**: Implement `ffi-napi` bindings for the `fff.dylib` (macOS).
2.  **UI Interception**: Subclass `CustomEditor` to inject a custom `AutocompleteProvider`.
3.  **Visual Highlighting**: Use ANSI escape codes (`\x1b[1;31m` for Bold Red) to highlight matching characters in the picker dropdown.
4.  **Expansion Logic**: Intercept the `input` event to expand `@path` into standard `<file>` XML blocks containing file content, matching `pi`'s CLI behavior.
5.  **Bootstrap**: Automatically download the `fff.dylib` if missing.

6.  **Package Structure**: Implement as a standalone package in `extensions/fff-picker` with `index.ts` as the entry point.
7.  **Architecture**: macOS (aarch64) only for initial implementation.

## Technical Architecture

### 0. Binary Bootstrap
The extension will download the macOS `fff` dylib from:
`https://github.com/dmtrKovalenko/fff.nvim/releases/download/7c2d46f/c-lib-aarch64-apple-darwin.dylib`
It will be stored in `extensions/fff-picker/bin/libfff.dylib`.


### 1. FFI Bridge (Node.js napi)
The library `fff-c` uses a result-pointer pattern. Every function returns a pointer to a result struct.

**FffResult Struct Definition (C):**
```c
struct FffResult {
    bool success;
    char* data;    // JSON string on success
    char* error;   // Error message on failure
    void* handle;  // Opaque instance handle
};
```

**Memory Layout (8-byte alignment):**
- Offset 0: `success` (bool, 1 byte + 7 padding)
- Offset 8: `data` pointer (8 bytes)
- Offset 16: `error` pointer (8 bytes)
- Offset 24: `handle` pointer (8 bytes)

### 2. Implementation Modules

#### A. fff-bindings.ts
Handles `dlopen` via `ffi-napi` and `ref-napi`.
- **Target Functions**:
    - `fff_create(optsJson: string) -> FffResult*`
    - `fff_destroy(handle: void*) -> void`
    - `fff_search(handle: void*, query: string, optsJson: string) -> FffResult*`
    - `fff_scan_files(handle: void*) -> FffResult*`
    - `fff_free_result(result: FffResult*) -> void`
    - `fff_live_grep(handle: void*, query: string, optsJson: string) -> FffResult*`
    - `fff_is_scanning(handle: void*) -> bool`
    - `fff_get_scan_progress(handle: void*) -> FffResult*`
    - `fff_wait_for_scan(handle: void*, timeoutMs: u64) -> FffResult*`
    - `fff_restart_index(handle: void*, optsJson: string) -> FffResult*`
    - `fff_track_access(handle: void*, path: string) -> FffResult*`
    - `fff_refresh_git_status(handle: void*) -> FffResult*`
    - `fff_track_query(handle: void*, query: string, optsJson: string) -> FffResult*`
    - `fff_get_historical_query(handle: void*, index: u64) -> FffResult*`
    - `fff_health_check(handle: void*, payload: string) -> FffResult*`
    - `fff_free_string(ptr: void*) -> void`
- **Logic**: Must wrap the raw FFI calls to parse the `FffResult` struct and convert C-strings/JSON data to JS objects.

- **ffi-napi Definition**:
  ```ts
  const fff = ffi.Library('libfff', {
    fff_create: ['pointer', ['string']],
    fff_destroy: ['void', ['pointer']],
    fff_search: ['pointer', ['pointer', 'string', 'string']],
    fff_live_grep: ['pointer', ['pointer', 'string', 'string']],
    fff_scan_files: ['pointer', ['pointer']],
    fff_is_scanning: ['bool', ['pointer']],
    fff_get_scan_progress: ['pointer', ['pointer']],
    fff_wait_for_scan: ['pointer', ['pointer', 'uint64']],
    fff_restart_index: ['pointer', ['pointer', 'string']],
    fff_track_access: ['pointer', ['pointer', 'string']],
    fff_refresh_git_status: ['pointer', ['pointer']],
    fff_track_query: ['pointer', ['pointer', 'string', 'string']],
    fff_get_historical_query: ['pointer', ['pointer', 'uint64']],
    fff_health_check: ['pointer', ['pointer', 'string']],
    fff_free_result: ['void', ['pointer']],
    fff_free_string: ['void', ['pointer']],
  });
  ```

#### B. fff-autocomplete.ts
Implement the `AutocompleteProvider` interface from `@mariozechner/pi-tui`.
- **Constructor**: Takes `originalProvider` (the `CombinedAutocompleteProvider` instance from `InteractiveMode`).
- **getSuggestions(lines, row, col)**:
    - If the current prefix starts with `/`, delegate immediately to `originalProvider`.
    - If the prefix starts with `@`:
        - Use `fff_search` with the current query.
        - The `fff` result typically returns a JSON array of matches including `indices` (where the query matched the path).
        - Construct `AutocompleteItem` where the `label` is the path string with `\x1b[1;31m` inserted around characters at the provided indices.
- **applyCompletion**: Delegate to `originalProvider` to maintain standard path insertion logic.

#### C. fff-editor.ts
Subclass `CustomEditor` (imported from `@mariozechner/pi-coding-agent`).
- **setAutocompleteProvider(provider)**: Override this method. When called (by `InteractiveMode`), wrap the provided instance:
  ```ts
  super.setAutocompleteProvider(new FffAutocompleteProvider(provider));
  ```
- This ensures the extension transparently upgrades the core autocomplete logic without needing to modify `InteractiveMode.ts` directly.

#### D. fff-picker.ts (Extension Entry Point)
- **on("session_start")**:
    - Check for `fff.dylib` in `~/.pi/agent/bin/` or extension dir. Download if missing.
    - Call `ctx.ui.setEditorComponent((tui, theme, kb) => new FffEditor(tui, theme, kb))`.
- **on("input")**:
    - Intercept user input before it reaches the agent.
    - Regex: `@([/.~a-zA-Z0-9_\-]+)`.
    - Transformation: For each valid file path found, read the file content from disk.
    - Return `{ action: "transform", text: ... }` where the mention is replaced by:
      ```xml
      <file name="ABSOLUTE_PATH">
      FILE_CONTENT
      </file>
      ```

## Dependencies
Add to `extensions/fff-picker/package.json`:
- `ffi-napi`: For loading the dylib.
- `ref-napi`: For C pointer/type handling.
- `ref-struct-napi`: For defining the `FffResult` struct.
Peer Dependencies:
- `@mariozechner/pi-coding-agent`: `*`
- `@mariozechner/pi-tui`: `*`
- `@mariozechner/pi-ai`: `*`

## Implementation Steps for the Agent

1.  **Initialize Package**: Create `extensions/fff-picker/package.json` with necessary dependencies and `pi` manifest.
2.  **Setup Bindings**: Create `extensions/fff-bindings.ts`. Define the `FffResult` struct using `ref-struct-napi` and map the library symbols using `ffi-napi`.
3.  **Download Utility**: Create `extensions/fff-downloader.ts`. Implement a helper to fetch the dylib from the GitHub release and store it in the package `bin/` directory.
4.  **Provider Wrapper**: Create `extensions/fff-autocomplete.ts`. Implement the `@` interception in `getSuggestions`. Use the `indices` from `fff` to apply ANSI red/bold formatting to the labels.
5.  **Editor Injection**: Create `extensions/fff-editor.ts`. Implement the `CustomEditor` subclass.
6.  **Entry Point**: Create `extensions/index.ts`. Register the editor in `session_start` and implement the `input` expansion handler. Ensure it resolves paths relative to `ctx.cwd` and correctly identifies the `<file>` block format expected by the agent.
