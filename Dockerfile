FROM node:26

# corepack из образов Node 26 убран, pnpm ставится напрямую той версией,
# что указана в app/package.json (packageManager)
RUN npm install -g pnpm@12.6.0

WORKDIR /app
