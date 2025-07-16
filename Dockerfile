FROM node:18
WORKDIR /app
COPY . .
RUN npm install || true
EXPOSE 8000
CMD ["node", "index.js"]
