FROM oven/bun:1.2.14 AS base

WORKDIR /app

# Copy workspace manifests and lockfile first for better layer caching
COPY package.json bun.lock ./
COPY apps/web/package.json ./apps/web/package.json
COPY packages/agent/package.json ./packages/agent/package.json
COPY packages/sandbox/package.json ./packages/sandbox/package.json
COPY packages/shared/package.json ./packages/shared/package.json
COPY packages/tsconfig/package.json ./packages/tsconfig/package.json

# Install all workspace dependencies from the root
RUN bun install --frozen-lockfile

# Copy the rest of the source
COPY . .

# Build the web app (runs db:migrate:apply + next build inside apps/web)
RUN bun --cwd apps/web run build

# Run the Next.js server from the apps/web directory context
# using --cwd so bun resolves the start script from apps/web/package.json
CMD ["bun", "--cwd", "apps/web", "run", "start"]
