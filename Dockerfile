FROM node:8-alpine

WORKDIR /app

COPY . /app

RUN ["npm", "install"]

CMD ["npm", "start"]