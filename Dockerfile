FROM oven/bun:1.2.14 AS builder

WORKDIR /app

# Copy root workspace manifests and lockfile
COPY package.json bun.lock ./
COPY turbo.json ./

# Copy all package manifests before installing
COPY packages/agent/package.json ./packages/agent/
COPY packages/sandbox/package.json ./packages/sandbox/
COPY packages/shared/package.json ./packages/shared/
COPY packages/tsconfig/package.json ./packages/tsconfig/
COPY apps/web/package.json ./apps/web/

# Install all dependencies
RUN bun install --frozen-lockfile

# Copy full source
COPY . .

# Build the Next.js app via turbo
RUN bun run build --filter=web

# ---- Runtime stage ----
FROM oven/bun:1.2.14-slim

# Set working directory to the Next.js app so `bun run start` resolves
# package.json and the .next build output without any cd gymnastics.
WORKDIR /app/apps/web

# Copy the entire built monorepo (node_modules are hoisted to root in Bun workspaces)
COPY --from=builder /app /app

CMD ["bun", "run", "start"]
