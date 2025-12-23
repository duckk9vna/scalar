FROM node:20-slim AS builder

# 1. Cài đặt các công cụ cần thiết cho việc build native modules (nếu có)
RUN apt-get update && apt-get install -y python3 make g++ && rm -rf /var/lib/apt/lists/*

RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# 2. Copy file cấu hình trước để tối ưu cache
COPY pnpm-lock.yaml pnpm-workspace.yaml package.json ./

# 3. Copy toàn bộ source code
# (Bắt buộc phải copy hết để pnpm nhận diện các package trong folder /packages)
COPY . .

# 4. Cài đặt dependencies
# Sử dụng --no-frozen-lockfile nếu pnpm-lock.yaml của bạn đang bị lệch version
RUN pnpm install

# 5. BUILD CÁC PACKAGE NỘI BỘ TRƯỚC
# Đây là bước quan trọng nhất để tạo ra thư mục 'dist' và types cho @scalar/nestjs-api-reference
RUN pnpm --filter "@scalar/*" build

# 6. BUILD APP CHÍNH
# Lúc này các package @scalar/... đã có sẵn trong node_modules/ hoặc dist/
RUN pnpm --filter @scalar-examples/nestjs-api-reference-express build

# Stage 2: Runner
FROM node:20-slim AS runner
WORKDIR /app

# Copy toàn bộ kết quả đã build thành công
COPY --from=builder /app /app

ENV NODE_ENV=production
EXPOSE 3000

WORKDIR /app/examples/nestjs/nestjs-api-reference-express
CMD ["pnpm", "run", "start:prod"]
