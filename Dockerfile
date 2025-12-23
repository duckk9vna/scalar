# Stage 1: Build
FROM node:20-slim AS builder

RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# Copy toàn bộ để đảm bảo link được workspace
COPY . .

# Cài đặt và build các package phụ thuộc
RUN pnpm install
RUN pnpm --filter "@scalar/*" build

# Build app NestJS
RUN pnpm --filter @scalar-examples/nestjs-api-reference-express build

# Stage 2: Runner
FROM node:20-slim AS runner

# Cài đặt pnpm ở stage runner để có lệnh thực thi
RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# Chỉ copy những gì cần thiết để chạy
COPY --from=builder /app /app

# Port mặc định
EXPOSE 3000

# Sử dụng shell form để gọi pnpm hoặc trỏ thẳng vào file main.js của NestJS
WORKDIR /app/examples/nestjs/nestjs-api-reference-express

# Sửa lỗi: Gọi trực tiếp node vào file đã build để ổn định nhất
CMD ["node", "dist/main.js"]
