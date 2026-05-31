# =========================
# Build stage (Hugo)
# =========================
FROM hugomods/hugo:exts-0.146.0 AS builder

WORKDIR /site

COPY . .

# Build production site
RUN hugo --minify -e production

# =========================
# Serve stage (Nginx)
# =========================
FROM nginx:alpine

RUN rm -rf /usr/share/nginx/html/*

COPY --from=builder /site/public /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]