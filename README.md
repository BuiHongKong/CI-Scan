# CI-Scan

Dự án mẫu để chạy các công cụ security scan trên **GitHub Actions**. Code local chỉ phục vụ cho các bài scan — không cần chạy scanner trên máy.

## Stack scan

| Công cụ | Mục đích | Thư mục / file liên quan |
|---------|----------|--------------------------|
| [Checkov](https://www.checkov.io/) | Scan IaC (Terraform, Docker, K8s, Compose/YAML) | `infra/` |
| [Gitleaks](https://github.com/gitleaks/gitleaks) | Phát hiện secret trong git | Toàn repo |
| [ESLint](https://eslint.org/) | Lint JavaScript | `src/`, `eslint.config.js` |
| [CodeQL](https://codeql.github.com/) | Phân tích bảo mật mã nguồn | `src/` |
| [SonarQube](https://www.sonarsource.com/products/sonarqube/) | Chất lượng & bảo mật code | `src/`, `sonar-project.properties` |

Workflow chạy tất cả scan: [`.github/workflows/security-scan.yml`](.github/workflows/security-scan.yml)

## Cấu trúc thư mục

```
CI-Scan/
├── .github/workflows/
│   └── security-scan.yml    # GitHub Actions — chạy 5 stack scan
├── infra/
│   ├── terraform/           # Checkov — Terraform (AWS S3, VPC, SG)
│   │   ├── main.tf
│   │   ├── s3_compliance.tf
│   │   ├── network.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   ├── Dockerfile           # Checkov — Docker best practices
│   ├── docker-compose.yml   # Checkov — Compose
│   └── kubernetes/
│       ├── namespace.yaml
│       └── deployment.yaml
├── src/
│   ├── index.js             # Entry point
│   └── utils.js             # Logic mẫu
├── catalog-info.yaml        # Backstage Component
├── catalog/
│   └── system-security-tooling.yaml
├── eslint.config.js
├── sonar-project.properties
├── package.json
└── .gitleaks.toml
```

## Thiết lập GitHub

### 1. Push repo lên GitHub

Workflow tự chạy khi push/PR vào nhánh `main` hoặc `master`.

### 2. Bật CodeQL (khuyến nghị)

Vào **Settings → Code security and analysis → Code scanning** và bật **CodeQL analysis** nếu repo yêu cầu.

### 3. Cấu hình SonarQube / SonarCloud

Thêm **Repository secret**:

| Secret | Mô tả |
|--------|-------|
| `SONAR_TOKEN` | Access token từ SonarCloud (My Account → Access Token) |

`SONAR_HOST_URL` đã hardcode `https://sonarcloud.io` trong workflow — không cần secret.

**SonarCloud:** project key `BuiHongKong_CI-Scan`, organization `buihongkong` (trong `sonar-project.properties`).

**Tắt Automatic Analysis** (bắt buộc khi scan qua GitHub Actions):

1. [SonarCloud](https://sonarcloud.io) → project **CI-Scan**
2. **Project Settings** → **Analysis Method**
3. Tắt **SonarCloud Automatic Analysis**
4. Giữ analysis qua **GitHub Actions / CI**

Nếu không tắt, scanner báo lỗi: *"CI analysis while Automatic Analysis is enabled"*.

**SonarQube Server:** cài scanner agent hoặc dùng action hiện tại với URL server nội bộ.

### 4. Gitleaks

Dùng `GITHUB_TOKEN` mặc định — không cần secret thêm.

### 5. Checkov & ESLint

Không cần secret.

## Local (tùy chọn)

Chỉ cần khi muốn kiểm tra code trước khi push:

```bash
npm install
npm run lint
npm start
```

**Không** chạy Checkov, Gitleaks, CodeQL, SonarQ trên local — các tool này chạy trên GitHub Actions.

## Backstage (repo khác)

File catalog trong repo này:

| File | Mục đích |
|------|----------|
| [`catalog-info.yaml`](catalog-info.yaml) | Component `ci-scan` + annotation SonarQ |
| [`catalog/system-security-tooling.yaml`](catalog/system-security-tooling.yaml) | System `security-tooling` |

### 1. Đăng ký catalog trong Backstage

Thêm vào `app-config.yaml` của repo Backstage:

```yaml
catalog:
  locations:
    - type: url
      target: https://github.com/BuiHongKong/CI-Scan/blob/main/catalog-info.yaml
    - type: url
      target: https://github.com/BuiHongKong/CI-Scan/blob/main/catalog/system-security-tooling.yaml
```

Hoặc dùng `type: file` nếu clone local.

### 2. Plugin SonarQube — `app-config.yaml`

Annotation dùng `default/BuiHongKong_CI-Scan` → instance tên **`default`**:

```yaml
sonarqube:
  instances:
    - name: default
      baseUrl: https://sonarcloud.io
      apiKey: ${SONAR_TOKEN}
```

Đặt `SONAR_TOKEN` trong env hoặc `app-config.local.yaml` (không commit).

Nếu chỉ cấu hình single instance (không `instances`), đổi annotation thành:

```yaml
sonarqube.org/project-key: BuiHongKong_CI-Scan
```

### 3. Plugin cần cài (repo Backstage)

```bash
yarn --cwd packages/app add @backstage-community/plugin-sonarqube
yarn --cwd packages/backend add @backstage-community/plugin-sonarqube-backend
```

Backend `packages/backend/src/index.ts`:

```typescript
backend.add(import('@backstage-community/plugin-sonarqube-backend'));
```

Frontend: thêm `EntitySonarQubeCard` vào `EntityPage.tsx` (tab Overview).

### 4. Kiểm tra

Mở **Software Catalog → CI-Scan** → card SonarQube hiển thị Quality Gate và metrics từ SonarCloud.

## Security check

| Mục | Giá trị |
|-----|---------|
| Secret trong git | **Không** — dùng GitHub Secrets cho `SONAR_TOKEN` |
| File `.env` | Đã ignore — tham khảo `.env.example` |
| Token Sonar | Lưu trong GitHub Secrets, rotate khi cần |

## License

MIT
