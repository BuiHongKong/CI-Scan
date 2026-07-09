FROM node:latest

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

COPY src ./src

# DEMO: no non-root user, no HEALTHCHECK — Dockerfile scan should fail
EXPOSE 3000

CMD ["node", "src/index.js"]
