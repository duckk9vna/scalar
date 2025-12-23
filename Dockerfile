# Stage 1: Build
FROM node:20-slim AS builder

# Cài đặt pnpm và các công cụ cần thiết
RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# Copy toàn bộ source code
COPY . .

# 1. Cài đặt toàn bộ dependencies
RUN pnpm install --frozen-lockfile

# 2. Build tất cả các packages lõi (theo tài liệu: pnpm build:packages)
# Bước này cực kỳ quan trọng để sửa lỗi "Cannot find module @scalar/..."
RUN pnpm build:packages

# 3. Build ứng dụng NestJS cụ thể
RUN pnpm --filter @scalar-examples/nestjs-api-reference-express build

# Stage 2: Run
FROM node:20-slim AS runner
WORKDIR /app

# Copy mọi thứ từ stage builder (bao gồm cả các gói đã build)
COPY --from=builder /app /app

# Thiết lập môi trường
ENV NODE_ENV=production
EXPOSE 3000

# Di chuyển vào thư mục ví dụ và chạy
WORKDIR /app/examples/nestjs/nestjs-api-reference-express
CMD ["pnpm", "run", "start:prod"]
