FROM debian:trixie-slim as build

ARG DEBIAN_FRONTEND=noninteractive

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

RUN npm install -g @angular/cli \
  && ng version \
  && ng analytics disable --global true

RUN ng new --style=css --strict --skip-git hello-angular \
  && ls -lisah hello-angular

WORKDIR /angular-app/hello-angular

# Replace the app component to read ?name=... and display Angular version
RUN set -eux; \
  cat > src/app/app.component.ts <<'TS'\
import { Component, VERSION } from '@angular/core';

@Component({
  selector: 'app-root',
  standalone: true,
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent {
  name: string;
  angularVersion = VERSION.full;

  constructor() {
    const params = new URLSearchParams(window.location.search);
    this.name = params.get('name') || 'World';
  }
}
TS \
  && cat > src/app/app.component.html <<'HTML'\
<h1>Hello {{ name }}!</h1>
<p>Angular {{ angularVersion }}</p>
HTML

RUN ng build --configuration=production \
  && ls -lisah dist \
  && ls -lisah dist/hello-angular \
  && ls -lisah dist/hello-angular/browser

FROM docker.io/nginx:stable-bookworm

COPY --from=build /angular-app/hello-angular/dist/hello-angular/browser /usr/share/nginx/html

EXPOSE 80
