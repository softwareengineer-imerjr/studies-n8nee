#!/bin/bash
set -e

# Navigate to the CLI package directory
cd "$(dirname "$0")/.."

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
  echo "Installing dependencies..."
  npm install
fi

# Run the tenant user creation script
echo "Creating tenant users..."
npx ts-node -r tsconfig-paths/register scripts/create-tenant-users.ts

echo "Tenant users created successfully!"
