FROM docker.io/node:lts-bookworm-slim as build

ARG NG_CLI_ANALYTICS="false"

WORKDIR /angular-app

RUN node -v
RUN npm --version

#COPY package*.json .

#RUN npm install

RUN npm install -g @angular/cli \
  && ng version \
  && ng analytics disable --global true

#COPY . .
RUN ng new --routing --style=css --strict --ssr --server-routing --skip-git hello-angular \
  && ls -lisah hello-angular

WORKDIR /angular-app/hello-angular

RUN ng generate component greeting

#EXPOSE 4200

#CMD ng serve --host 0.0.0.0

#RUN ng build --configuration=production --index \
RUN ng build -e=prod --prod --no-sourcemap --aot \
  && ls -lisah dist \
  && ls -lisah dist/hello-angular

FROM docker.io/nginx:stable-bookworm

COPY --from=build /angular-app/hello-angular/dist/hello-angular /usr/share/nginx/html

EXPOSE 80
