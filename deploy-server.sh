#!/usr/bin/env bash
set -euo pipefail

# ─── Configuration ───────────────────────────────────────────
REMOTE_HOST="47.82.121.213"
REMOTE_USER="root"
REMOTE_APP_DIR="/server"                      # 远端项目 server 目录
REMOTE_BRANCH="main"                       # 拉取的分支
SSH_KEY=""                                 # 留空则使用默认 ssh key

# ─── Colors ──────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ─── SSH helper ──────────────────────────────────────────────
SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=10"
if [[ -n "$SSH_KEY" ]]; then
  SSH_OPTS="$SSH_OPTS -i $SSH_KEY"
fi
ssh_cmd() { ssh $SSH_OPTS ${REMOTE_USER}@${REMOTE_HOST} "$@"; }

# ─── Step 1: Push local changes ──────────────────────────────
info "Checking local git status..."
if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
  warn "You have uncommitted changes."
  read -rp "Commit and push before deploy? [y/N] " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    git add -A
    read -rp "Commit message: " msg
    git commit -m "${msg:-deploy: update server}"
    git push origin HEAD
    info "Pushed."
  else
    warn "Skipping push. Remote will use existing commit."
  fi
else
  info "No uncommitted changes."
  # Ensure latest is pushed
  local_hash=$(git rev-parse HEAD)
  remote_hash=$(git rev-parse "origin/${REMOTE_BRANCH}" 2>/dev/null || echo "")
  if [[ "$local_hash" != "$remote_hash" ]]; then
    warn "Local HEAD differs from origin/${REMOTE_BRANCH}."
    read -rp "Push now? [y/N] " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      git push origin HEAD
      info "Pushed."
    fi
  fi
fi

# ─── Step 2: Deploy on remote ────────────────────────────────
info "Connecting to ${REMOTE_USER}@${REMOTE_HOST}..."

ssh_cmd bash -s <<REMOTE_SCRIPT
set -euo pipefail

APP_DIR="${REMOTE_APP_DIR}"
BRANCH="${REMOTE_BRANCH}"

echo "====== Deploying serv-ease server ======"

# --- Check if project directory exists ---
if [ ! -d "\$APP_DIR" ]; then
  echo "Project not found at \$APP_DIR"
  echo "Cloning repository..."
  git clone https://github.com/spacewhisp-ux/serv_ease.git /root/serv_ease
  cd /root/serv_ease/server
fi

cd "\$APP_DIR"

# --- Git pull ---
echo "[1/6] Pulling latest code (branch: \$BRANCH)..."
git fetch origin
git reset --hard "origin/\$BRANCH"
echo "  -> Updated to \$(git rev-parse --short HEAD)"

# --- Install dependencies ---
echo "[2/6] Installing dependencies..."
yarn install --frozen-lockfile 2>/dev/null || npm ci 2>/dev/null || npm install

# --- Prisma ---
echo "[3/6] Generating Prisma client..."
npx prisma generate

# --- Build ---
echo "[4/6] Building project..."
npm run build

# --- Database migration ---
echo "[5/6] Running database migrations..."
npx prisma migrate deploy

# --- Restart service ---
echo "[6/6] Restarting service..."
if command -v pm2 &>/dev/null; then
  # PM2 管理
  if pm2 describe serv-ease-server &>/dev/null; then
    pm2 restart serv-ease-server
    echo "  -> PM2 process restarted"
  else
    pm2 start dist/main.js --name serv-ease-server
    echo "  -> PM2 process started"
  fi
  pm2 save
elif systemctl list-units --type=service | grep -q serv-ease; then
  # systemd 管理
  systemctl restart serv-ease
  echo "  -> systemd service restarted"
else
  # 无进程管理器，手动 kill + restart
  pkill -f "node dist/main" 2>/dev/null || true
  sleep 1
  nohup node dist/main.js > /server/logs/app.log 2>&1 &
  echo "  -> Process started (PID: \$!)"
  echo "  -> TIP: Install PM2 for production: npm i -g pm2"
fi

echo ""
echo "====== Deploy complete! ======"
echo "Checking process..."
sleep 2
if pgrep -f "node dist/main" &>/dev/null; then
  echo "✓ Server is running"
else
  echo "✗ Server may have failed to start. Check logs:"
  echo "  ssh ${REMOTE_USER}@${REMOTE_HOST} 'tail -50 \$APP_DIR/logs/app.log'"
fi

REMOTE_SCRIPT

info "Deploy finished!"
echo ""
echo "Useful commands:"
echo "  View logs:  ssh ${REMOTE_USER}@${REMOTE_HOST} 'tail -50 ${REMOTE_APP_DIR}/logs/app.log'"
echo "  PM2 logs:   ssh ${REMOTE_USER}@${REMOTE_HOST} 'pm2 logs serv-ease-server'"
echo "  PM2 status: ssh ${REMOTE_USER}@${REMOTE_HOST} 'pm2 status'"
