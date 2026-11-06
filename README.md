# nvim-xcode

LazyVim-based Neovim config for iOS development (built around FighterHUD), separate from `~/.config/nvim`.

Start it with `nvim-xcode` (wrapper in `~/.local/bin`) or `NVIM_APPNAME=nvim-xcode nvim`.
Plugins, parsers and state live in `~/.local/share/nvim-xcode`, `~/.local/state/nvim-xcode`.

| Feature | Provided by |
| --- | --- |
| Build / run / test on simulator | [xcodebuild.nvim](https://github.com/wojciech-kulik/xcodebuild.nvim) + `xcbeautify` |
| Debugging | nvim-dap + nvim-dap-ui (LazyVim `dap.core` extra) + Xcode's `lldb-dap` |
| Autocomplete / go-to-def | `sourcekit-lsp` (Xcode) + `xcode-build-server` + blink.cmp |
| Lint | nvim-lint + `swiftlint` |
| Format | conform.nvim + `swiftformat` (on demand: `<leader>cf`; toggle on-save: `<leader>uf`) |
| Syntax highlighting | nvim-treesitter `swift` parser |

## Install on a new Mac

Accept the Xcode license first: init.lua points tools at Xcode, and until the license is
accepted even `git` fails, so the plugin download breaks.

```sh
sudo /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -license accept
sudo /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -runFirstLaunch

brew install neovim xcp xcode-build-server xcbeautify swiftlint swiftformat tree-sitter-cli ripgrep jq coreutils

git clone git@github.com:vcsabi/nvim-xcode.git ~/.config/nvim-xcode
mkdir -p ~/.local/bin && ln -s ~/.config/nvim-xcode/bin/nvim-xcode ~/.local/bin/nvim-xcode
```

Then start `nvim-xcode` and let the plugins install (versions are pinned by `lazy-lock.json`),
and run `:checkhealth xcodebuild`. Needs a Nerd Font in the terminal.

Optional: `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer` (init.lua sets
`DEVELOPER_DIR` anyway).

Then, per project:

```sh
cd ~/Work/FighterHUD
nvim-xcode
:XcodebuildSetup     # pick FighterHUD.xcodeproj, scheme FighterHUD, Debug, a simulator
```

`:XcodebuildSetup` writes `buildServer.json` and `.nvim/` into the project (both are local, consider
adding them to `.gitignore`). Do one build (`<leader>ib`) so sourcekit-lsp gets the index;
after that completion and diagnostics work across files.

## Keys (`<leader>` = space)

| Key | Action |
| --- | --- |
| `<leader>X` | all xcodebuild actions (picker) |
| `<leader>ib` / `ir` / `iR` | build / build & run / run without build |
| `<leader>is` | cancel running action |
| `<leader>it` / `iT` / `i.` | run tests / current class / repeat (visual `it`: selected tests) |
| `<leader>ie` / `il` | test explorer / build logs |
| `<leader>id` / `ip` | select simulator / scheme |
| `<leader>ic` / `iC` | code coverage marks / report |
| `<leader>io` | open in Xcode |
| `<leader>iK` / `iD` / `iu` | clean build / delete DerivedData / resolve packages |
| `<leader>dd` / `dD` / `dT` | build & debug / debug without build / debug tests |
| `<leader>db` / `dm` | toggle breakpoint (persisted) / log breakpoint |
| `<leader>dc`, `di`, `dO`, `do` | continue, step into, over, out (LazyVim dap) |
| `<leader>du` / `dX` | toggle DAP UI / stop debugging |
| `<leader>xx` | diagnostics (Trouble; opens automatically on build failure) |

## Physical device debugging (iOS 17+)

Needs `pipx install pymobiledevice3`, then set `integrations.pymobiledevice.enabled = true`
in `lua/plugins/xcodebuild.lua` and follow
https://github.com/wojciech-kulik/xcodebuild.nvim/wiki/Integrations#-debugging-on-ios-17
(replace `~/.local/share/nvim/` with `~/.local/share/nvim-xcode/` in that script).
