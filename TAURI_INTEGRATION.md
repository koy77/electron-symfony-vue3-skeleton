# Integrating Tauri into Your Web Application

This guide shows how to add Tauri to an existing web application so you can build a native desktop app (Windows, macOS, Linux) using your current web UI. It covers prerequisites, initialization, configuration, dev workflow, packaging, and common tips.

## Prerequisites

- Node.js and your project's package manager (npm, yarn, pnpm).
- Rust toolchain installed via `rustup` (stable toolchain). Example:

  ```bash
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  rustup default stable
  ```

- Build tools for your platform (Linux: `build-essential`, libgtk dev packages; macOS: Xcode; Windows: Visual Studio Build Tools).
- (Optional) `@tauri-apps/cli` or `tauri` cargo CLI. You can use `npx` or install via `cargo`.

## High-level Approaches

- New project: use the official scaffold: `npm create tauri-app@latest` and follow prompts.
- Existing web app: initialize Tauri inside your project. You can either run the interactive init or add the `src-tauri` folder manually and configure it.

This guide focuses on integrating Tauri into an existing web app.

## Step-by-step (Existing Project)

1. From your project root, install the Tauri JS API and (optionally) the CLI dev dependency:

   ```bash
   # using npm
   npm install --save @tauri-apps/api
   npm install --save-dev @tauri-apps/cli

   # or with pnpm/yarn
   pnpm add @tauri-apps/api
   pnpm add -D @tauri-apps/cli
   ```

   The `@tauri-apps/api` package exposes JavaScript bindings for filesystem, dialogs, IPC (invoke), and more.

2. Initialize Tauri in the project. Two ways:

   - Interactive init (recommended):
     ```bash
     npx @tauri-apps/cli init
     ```
     This will create a `src-tauri/` folder with a Rust app skeleton and a `tauri.conf.json` config.

   - Scaffold a new Tauri app into the folder (if you prefer the full scaffold):
     ```bash
     npm create tauri-app@latest
     ```

3. Configure Tauri to use your web build output or dev server.

   - When using a production build (static files): set the `distDir` in `src-tauri/tauri.conf.json` to your web build folder (relative to `src-tauri`), e.g.:

     ```json
     {
       "build": {
         "distDir": "../dist",
         "devPath": "http://localhost:3000"
       }
     }
     ```

     - `distDir` is the path Tauri will bundle into the native app.
     - `devPath` is used while developing with a web dev server.

   - Alternatively, keep the default config and adjust the `beforeDevCommand` and `beforeBuildCommand` so Tauri runs your dev server or builds your web app automatically.

4. Add scripts to `package.json` for convenience (example):

   ```json
   {
     "scripts": {
       "dev": "vite",                    // or your dev server
       "build": "vite build",            // or your build command
       "tauri:dev": "npx tauri dev",
       "tauri:build": "npx tauri build"
     }
   }
   ```

   Then run during development:
   ```bash
   npm run dev        # start your web dev server
   npm run tauri:dev  # starts Tauri dev, or run together if configured
   ```

   Or a single command when `tauri.conf.json` has `beforeDevCommand` set:
   ```bash
   npx tauri dev
   ```

5. Use Tauri APIs in your frontend code.

   Example: call a Rust command (invoke) or use filesystem:

   ```js
   import { invoke } from '@tauri-apps/api/tauri'
   import { readTextFile, writeFile } from '@tauri-apps/api/fs'

   // invoke a Rust command
   const res = await invoke('my_custom_command', { someArg: 1 })

   // read/write files
   await writeFile({ path: 'notes.txt', contents: 'Hello from Tauri' })
   const contents = await readTextFile('notes.txt')
   ```

   You will add Rust commands in `src-tauri/src/main.rs` (or in other Rust modules) and expose them to JS via the `tauri::invoke_handler!` macro.

6. Build the native app (production)

   - First, produce your web app build (if not using `beforeBuildCommand`):
     ```bash
     npm run build
     ```
   - Then run Tauri build:
     ```bash
     npx tauri build
     ```
   - The final installers/binaries will be in `src-tauri/target/release/bundle` (or similar, depending on platform and bundle settings).

## Common Tips & Notes

- Dev workflow: During dev you usually run your web dev server (e.g. `npm run dev`) and then `npx tauri dev` so the Tauri window loads from your local dev server (`devPath`).
- Security: be mindful of the webview's Content Security Policy and Tauri `allowlist` settings. Limit native APIs you enable in `tauri.conf.json`.
- Cross-platform builds: macOS requires signing/notarization for distribution; Windows builds may require Visual Studio Build Tools; Linux might need additional dependencies for target GUI toolkits.
- CI: install Rust and platform toolchains on CI, run `npm ci`, `npm run build`, then `npx tauri build`.
- Using `cargo install tauri-cli --locked` installs a global `tauri` cargo binary; you can alternatively rely on `npx` so you don't need a global install.

## Example: Minimal tauri.conf.json fragment

```json
{
  "build": {
    "distDir": "../dist",
    "devPath": "http://localhost:3000",
    "beforeBuildCommand": "npm run build",
    "beforeDevCommand": "npm run dev"
  }
}
```

Adjust paths and commands to match your project's structure and dev server port.

## Where to learn more

- Official Tauri docs: https://tauri.app
- API reference: https://tauri.app/v1/api/js/

---

If you want, I can:
- Create example `tauri.conf.json` tuned to this repo, or
- Initialize `src-tauri/` for you and wire up `package.json` scripts.

Just tell me which you'd like next.
