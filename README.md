# marcgeremias.com

Source code of my personal blog, **[marcgeremias.com](https://marcgeremias.com)**, where I write about backend development, system design and my homelab.

The site is built with [Hugo](https://gohugo.io/) and the [PaperMod](https://github.com/adityatelange/hugo-PaperMod) theme. It's packaged as a Docker image and self-hosted on a home server.

## Tech stack

| Layer          | Tool                                               |
| -------------- | -------------------------------------------------- |
| Static site    | Hugo + PaperMod theme (git submodule)              |
| Container      | Multi-stage Docker build (Hugo → `nginx:alpine`)   |
| Hosting        | Ubuntu home server                                 |
| Reverse proxy  | Nginx Proxy Manager                                |
| DNS / TLS      | Cloudflare (proxy + SSL/TLS) with ddclient for DDNS |
| Remote access  | WireGuard VPN                                      |

## Local development

Requirements: [Hugo extended](https://gohugo.io/installation/) (v0.146.0 or later) and Git.

```bash
git clone --recurse-submodules git@github.com:marcgeremias/marcgeremias.com.git
cd marcgeremias.com
hugo server -e development
```

The site is then available at <http://localhost:1313>.

If you already cloned without submodules, fetch the theme with:

```bash
git submodule update --init --recursive
```

### Writing a new post

```bash
hugo new content posts/my-new-post.md
```

## Build and run with Docker

The `dockerfile` builds the site with Hugo in a first stage and serves the generated `public/` folder with nginx in a second stage.

```bash
docker build -t marcgeremias-blog .
docker run --rm -p 8080:80 marcgeremias-blog
```

Then open <http://localhost:8080>.

## Project structure

```
.
├── archetypes/        # Front matter template for new content
├── config/
│   ├── _default/      # Shared Hugo config (menu, theme params, socials)
│   ├── development/   # Local overrides (baseURL = localhost)
│   └── production/    # Production overrides (baseURL = marcgeremias.com)
├── content/
│   ├── about/         # About page
│   └── posts/         # Blog posts (Markdown)
├── static/            # Images, diagrams (draw.io SVGs), favicon, resume
├── themes/PaperMod/   # Theme (git submodule)
└── dockerfile         # Multi-stage build: Hugo → nginx
```

## License

- **Code and configuration** are licensed under the [MIT License](LICENSE).
- **Blog content** (posts, images, diagrams and resume under `content/` and `static/`) is © Marc Geremias Serra, all rights reserved, unless stated otherwise.
- The PaperMod theme is licensed under its own [MIT License](https://github.com/adityatelange/hugo-PaperMod/blob/master/LICENSE).
