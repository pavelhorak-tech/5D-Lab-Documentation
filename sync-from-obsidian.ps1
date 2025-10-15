# 5D Lab Documentation Sync Script
# Syncs documentation from Obsidian vault (master) to GitHub repo (public)
# Usage: Run this script manually or via Beeftext shortcut

$ObsidianSource = "C:\Users\pavel\Documents\Obsidian-Vaults\MyObsidianVault\5D-Lab\Documentation"
$GitHubRepo = "C:\GitHub\5D-Lab-Documentation"

Write-Host "🔄 Syncing 5D Lab Documentation..." -ForegroundColor Cyan
Write-Host "Source: $ObsidianSource" -ForegroundColor Gray
Write-Host "Target: $GitHubRepo" -ForegroundColor Gray
Write-Host ""

# Check if source exists
if (-not (Test-Path $ObsidianSource)) {
    Write-Host "❌ ERROR: Obsidian source not found!" -ForegroundColor Red
    Write-Host "Expected: $ObsidianSource" -ForegroundColor Yellow
    exit 1
}

# Navigate to GitHub repo
Set-Location $GitHubRepo

# Copy files from Obsidian to GitHub (excluding .obsidian folder)
Write-Host "📁 Copying files from Obsidian..." -ForegroundColor Yellow
Copy-Item -Path "$ObsidianSource\*" -Destination $GitHubRepo -Recurse -Force -Exclude ".obsidian"

# Git operations
Write-Host "📊 Checking git status..." -ForegroundColor Yellow
git add -A

$status = git status --porcelain
if ($status) {
    Write-Host "✏️  Changes detected, creating commit..." -ForegroundColor Yellow

    # Create commit with timestamp
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    $commitMessage = @"
Update documentation: $timestamp

Synced from Obsidian vault (master source)

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>
"@

    git commit -m $commitMessage

    Write-Host "🚀 Pushing to GitHub..." -ForegroundColor Yellow
    git push origin main

    Write-Host ""
    Write-Host "✅ Documentation synced successfully!" -ForegroundColor Green
    Write-Host "📍 Live at: https://github.com/pavelhorak-tech/5D-Lab-Documentation" -ForegroundColor Cyan
} else {
    Write-Host "✅ No changes detected - documentation already up to date!" -ForegroundColor Green
}

Write-Host ""
