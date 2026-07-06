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
│       ├── deployment.yaml
│       └── networkpolicy.yaml
├── src/
│   ├── index.js             # Entry point
│   └── utils.js             # Logic mẫu
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

Thêm **Repository secrets** trong GitHub:

| Secret | Mô tả |
|--------|-------|
| `SONAR_TOKEN` | Token từ SonarQube Server hoặc SonarCloud |
| `SONAR_HOST_URL` | URL server, ví dụ `https://sonarcloud.io` hoặc `https://sonar.your-company.com` |

**SonarCloud:** tạo project với `sonar.projectKey=ci-scan` (khớp `sonar-project.properties`).

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

## Security check

| Mục | Giá trị |
|-----|---------|
| Secret trong git | **Không** — dùng GitHub Secrets cho `SONAR_TOKEN` |
| File `.env` | Đã ignore — tham khảo `.env.example` |
| Token Sonar | Lưu trong GitHub Secrets, rotate khi cần |

## License

MIT
