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
RUN ng new --style=css --strict --skip-git hello-angular \
  && ls -lisah hello-angular

WORKDIR /angular-app/hello-angular

RUN cat src/app/app.component.html
RUN cat src/app/app.component.ts
RUN cat src/app/app.routes.ts

#RUN ng generate module app-routing --flat --module=app.routes.ts --routing \
#  && ng generate component greeting \
#  && ng generate component home \
#  && ng generate component about \
#  && ng generate module feature --route=feature --module=app.routes.ts

#EXPOSE 4200

#CMD ng serve --host 0.0.0.0

RUN ng build --configuration=production \
  && ls -lisah dist \
  && ls -lisah dist/hello-angular \
  && ls -lisah dist/hello-angular/browser

FROM docker.io/nginx:stable-bookworm

COPY --from=build /angular-app/hello-angular/dist/hello-angular/browser /usr/share/nginx/html

EXPOSE 80
