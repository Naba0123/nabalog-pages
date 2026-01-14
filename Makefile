# Makefile for Jekyll local development using Docker
# Based on .github/workflows/jekyll-gh-pages.yml

# Settings
JEKYLL_VERSION = latest
DOCKER_IMAGE = jekyll/jekyll:$(JEKYLL_VERSION)
PORT = 4000
LIVERELOAD_PORT = 35729

# Directories
PWD = $(shell pwd)
SITE_DIR = _site

.PHONY: help serve build clean setup

help:
	@echo "Available commands:"
	@echo "  make setup   - Install dependencies (bundle install)"
	@echo "  make serve   - Start Jekyll server with Docker (livereload enabled)"
	@echo "  make build   - Build Jekyll site with Docker"
	@echo "  make post    - Create a new blog post"
	@echo "  make clean   - Remove generated files ($(SITE_DIR), .jekyll-cache, .bundle)"

setup:
	docker run --rm \
		--platform linux/amd64 \
		--volume="$(PWD):/srv/jekyll:Z" \
		-it $(DOCKER_IMAGE) \
		bundle install

serve:
	docker run --rm \
		--platform linux/amd64 \
		--volume="$(PWD):/srv/jekyll:Z" \
		--publish $(PORT):4000 \
		--publish $(LIVERELOAD_PORT):35729 \
		-it $(DOCKER_IMAGE) \
		sh -c "bundle install && bundle exec jekyll serve --watch --force_polling --livereload --host 0.0.0.0"

build:
	docker run --rm \
		--platform linux/amd64 \
		--volume="$(PWD):/srv/jekyll:Z" \
		-it $(DOCKER_IMAGE) \
		sh -c "bundle install && bundle exec jekyll build"

clean:
	rm -rf $(SITE_DIR) .jekyll-cache .bundle Gemfile.lock

post:
	@read -p "Enter post title: " title; \
	read -p "Enter directory (e.g., 2026/0115-my-post): " dir_name; \
	date=$$(date +%Y-%m-%d); \
	target_dir="_notes/$$dir_name"; \
	mkdir -p "$$target_dir"; \
	filename="$$target_dir/index.md"; \
	echo "---" > $$filename; \
	echo "layout: post" >> $$filename; \
	echo "title: \"$$title\"" >> $$filename; \
	echo "date: $$date" >> $$filename; \
	echo "image: " >> $$filename; \
	echo "---" >> $$filename; \
	echo "" >> $$filename; \
	echo "New post dir created: $$target_dir"
