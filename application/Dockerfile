FROM node:22-alpine AS deps

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev

FROM node:22-alpine

ENV NODE_ENV=production

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules

COPY package*.json ./
COPY src ./src
USER node

EXPOSE 3000

CMD ["node", "src/index.js"]

# Observações:
# - Não há HEALTHCHECK aqui de propósito. No ECS o health check é configurado
#   na task definition (ou no Cloud Map/API Gateway), e imagens Alpine não
#   trazem curl. Use a rota "/", que não depende do banco.
# - Nenhuma variável de ambiente de banco fica na imagem. DB_HOST, DB_USER,
#   DB_PASSWORD etc. são injetadas em tempo de execução (docker run, compose
#   ou task definition do ECS), nunca gravadas aqui.