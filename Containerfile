FROM debian:trixie-slim as build

ARG DEBIAN_FRONTEND=noninteractive

#SHELL ["/bin/bash", "-c"]
RUN rm /bin/sh \
  && ln -s /bin/bash /bin/sh

# install dependencies
RUN apt update && apt upgrade -y \
  && apt install -y --no-install-recommends --no-install-suggests ca-certificates git curl libssl-dev zlib1g-dev \
  && rm -rf "/var/lib/apt/lists/*" \
  && rm -rf /var/cache/apt/archives

# install Node.js
ENV NODE_VERSION=24.12.0
ENV HOME="/root"
ENV PATH="$HOME/.nvm/versions/node/v$NODE_VERSION/bin/:$PATH"
RUN git clone --depth 1 https://github.com/nvm-sh/nvm.git ~/.nvm \
  && source $HOME/.nvm/nvm.sh \
  #&& echo "\nexport NVM_DIR=\"$HOME/.nvm\"\n[ -s \"$NVM_DIR/nvm.sh\" ] && \. \"$NVM_DIR/nvm.sh\"\n[ -s \"$NVM_DIR/bash_completion\" ] && \. \"$NVM_DIR/bash_completion\"" >> ~/.bash_rc \
  && nvm --version \
  && nvm install $NODE_VERSION \
  && which node \
  && node --version \
  && npm --version \
  && npm install --global yarn \
  && which yarn \
  && yarn --version \
  && npm update -g npm

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

RUN cat src/app/app.routes.ts

COPY app/app.component.ts src/app/
COPY app/app.component.html src/app/

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

FROM docker.io/nginx:stable-trixie

COPY --from=build /angular-app/hello-angular/dist/hello-angular/browser /usr/share/nginx/html

EXPOSE 80
