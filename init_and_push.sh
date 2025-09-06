#!/usr/bin/env bash
# init_and_push.sh
set -euo pipefail

git init
git add .
git commit -m "Initial commit: POS ETL public showcase"
git branch -M main
echo "Now run: git remote add origin <your_repo_url> && git push -u origin main"
