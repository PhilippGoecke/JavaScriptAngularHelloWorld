FROM docker.io/node:lts-bookworm-slim as build

WORKDIR /angular-app

RUN node -v
RUN npm -v

#COPY package*.json .

#RUN npm install

RUN npm install -g @angular/cli \
  && ng version

#COPY . .
RUN ng new --routing --style=css --strict --skip-git hello-angular \
  && ls -lisah hello-angular

WORKDIR /angular-app/hello-angular

EXPOSE 4200

CMD ng serve
