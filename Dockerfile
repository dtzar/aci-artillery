FROM node:8-alpine

WORKDIR /app

COPY package* /app/

RUN ["npm", "install"]

CMD ["npm", "start"]