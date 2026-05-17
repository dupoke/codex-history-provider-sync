# Codex API Fast Mode Patch Note

> Public-safe note. Machine names, usernames, device paths, tokens, local logs, and account-specific values have been removed.

This note records a manual patch approach for enabling Codex Fast/Speed mode when Codex Desktop is used with API key or OpenAI-compatible relay mode instead of ChatGPT OAuth login. It is independent from Codex History Provider Sync and is not executed by the history sync tool.

## Risk Notice

- This modifies local Codex Desktop application files.
- Codex updates can change bundled JavaScript filenames and patch patterns.
- Always keep a backup of `app.asar`.
- Prefer testing against an extracted copy before changing the live app.
- Do not publish `auth.json`, `config.toml`, app logs, local database files, or any API keys.

## What Gets Patched

| Area | Goal |
| --- | --- |
| Fast mode auth gate | Allow Fast/Speed mode outside ChatGPT OAuth mode |
| Fast model availability gate | Avoid relying on relay model metadata such as `additionalSpeedTiers` |
| Plugins sidebar gate | Avoid hiding Plugins only because auth mode is `apikey` |
| Plugin connector gate | Avoid marking connectors unavailable only because API key mode is active |

## Windows Outline

Close Codex Desktop first, then run commands from an elevated or writable shell only if the install directory is writable.

```powershell
$resources = Join-Path $env:LOCALAPPDATA 'Programs\Codex\resources'
Set-Location $resources

if (-not (Test-Path app.asar.bak)) {
  Copy-Item app.asar app.asar.bak
}

Remove-Item -Recurse -Force app -ErrorAction SilentlyContinue
npx @electron/asar e .\app.asar app
Rename-Item app.asar app.asar1
```

Patch targets are usually under:

```text
app\webview\assets
```

Search for current bundle names instead of assuming hashes:

```powershell
Select-String -Path .\app\webview\assets\*.js -Pattern 'authMethod','fast_mode','modelsByType','pluginsDisabledTooltip','connector-unavailable','apikey'
```

After patching an extracted app folder, Electron may need fuses adjusted:

```powershell
$codexExe = Join-Path $env:LOCALAPPDATA 'Programs\Codex\Codex.exe'
npx @electron/fuses write --app $codexExe OnlyLoadAppFromAsar=off
npx @electron/fuses write --app $codexExe EnableEmbeddedAsarIntegrityValidation=off
npx @electron/fuses write --app $codexExe GrantFileProtocolExtraPrivileges=off
```

Rollback:

```powershell
$resources = Join-Path $env:LOCALAPPDATA 'Programs\Codex\resources'
Set-Location $resources
Remove-Item -Recurse -Force app -ErrorAction SilentlyContinue
if (Test-Path app.asar1) { Rename-Item app.asar1 app.asar }
if (Test-Path app.asar.bak) { Copy-Item app.asar.bak app.asar -Force }
```

## macOS Outline

```bash
cd /Applications/Codex.app/Contents/Resources

[ ! -f app.asar.bak ] && cp app.asar app.asar.bak
rm -rf app
npx @electron/asar e ./app.asar app
mv ./app.asar ./app.asar1
```

After editing the extracted JavaScript files:

```bash
npx @electron/fuses write --app /Applications/Codex.app OnlyLoadAppFromAsar=off
npx @electron/fuses write --app /Applications/Codex.app EnableEmbeddedAsarIntegrityValidation=off
npx @electron/fuses write --app /Applications/Codex.app GrantFileProtocolExtraPrivileges=off
codesign --force --deep --sign - /Applications/Codex.app
```

Rollback:

```bash
cd /Applications/Codex.app/Contents/Resources
rm -rf app
[ -f app.asar1 ] && mv app.asar1 app.asar
[ -f app.asar.bak ] && cp app.asar.bak app.asar
codesign --force --deep --sign - /Applications/Codex.app
```

## Pattern Guide

Use these searches to locate the current bundle after Codex updates:

```bash
# Fast mode auth gate
grep -rl "authMethod" app/webview/assets/*.js | xargs grep -l "fast_mode"

# Fast mode model metadata gate
grep -rl "modelsByType.models.some" app/webview/assets/*.js

# Plugins disabled sidebar gate
grep -rl "pluginsDisabledTooltip" app/webview/assets/*.js

# API key auth helper gate
grep -rl 'apikey' app/webview/assets/*.js | grep -v locale

# Connector unavailable gate
grep -rl "connector-unavailable" app/webview/assets/*.js
```

Typical edits from the private note were:

- change the Fast auth check return value to `true`
- change the Fast model availability expression to `true`
- change the Plugins disabled ternary gate from `X ? ...` to `0 ? ...`
- change an `apikey` detection helper to return `false`
- prefix the connector unavailable assignment with `false &&`

Treat these as version-specific hints, not stable APIs.
