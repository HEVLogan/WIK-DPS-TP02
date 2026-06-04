FROM node:22-alpine

WORKDIR /app

# Copy package files first so this layer is cached unless deps change
COPY package*.json ./
RUN npm ci

# Copy source and compile
COPY tsconfig.json ./
COPY src/ ./src/
RUN npm run build

# Remove dev dependencies (no runtime deps in this project)
RUN npm prune --production

RUN chown -R node:node /app

USER node

EXPOSE 8080

CMD ["node", "dist/index.js"]
