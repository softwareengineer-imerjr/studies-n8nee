# PowerShell script to create tenant users

# Navigate to the CLI package directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path (Join-Path $scriptDir "..")

# Install dependencies if needed
if (-not (Test-Path "node_modules")) {
    Write-Host "Installing dependencies..."
    npm install
}

# Run the tenant user creation script
Write-Host "Creating tenant users..."
npx ts-node -r tsconfig-paths/register scripts/create-tenant-users.ts

Write-Host "Tenant users created successfully!"
