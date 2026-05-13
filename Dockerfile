FROM oven/bun:latest AS base
WORKDIR /app

# Copy root workspace manifests and lockfile
COPY package.json bun.lock ./

# Copy all workspace package manifests so bun can resolve the workspace graph
COPY apps/web/package.json ./apps/web/package.json
COPY packages/agent/package.json ./packages/agent/package.json
COPY packages/sandbox/package.json ./packages/sandbox/package.json
COPY packages/shared/package.json ./packages/shared/package.json
COPY packages/tsconfig/package.json ./packages/tsconfig/package.json

# Install all dependencies using bun (understands catalog: and workspace: syntax)
RUN bun install --frozen-lockfile

# Copy the full source tree
COPY . .

# Build the Next.js app from the workspace root (turbo/bun resolves workspace deps)
WORKDIR /app/apps/web
RUN bun run build

# Runtime
EXPOSE 3000
CMD ["bun", "run", "start"]
