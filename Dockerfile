#build stage
FROM node:20-alpine AS build

WORKDIR /app

COPY package*.json .

RUN npm install

COPY . .

RUN npm run build


#prod
FROM node:20-alpine 

WORKDIR /app

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

COPY --from=build /app/dist ./dist

COPY package*.json ./
RUN npm pkg delete scripts.prepare
RUN npm install --only=production

RUN rm package*.json

EXPOSE 3000

CMD ["node", "dist/main.js"]

