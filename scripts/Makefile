# YouTube Clone Docker Management

.PHONY: help build run stop clean dev logs health

# Default target
help:
	@echo "YouTube Clone Docker Commands:"
	@echo "  build     - Build production Docker image"
	@echo "  run       - Run production container"
	@echo "  dev       - Run development container"
	@echo "  stop      - Stop all containers"
	@echo "  clean     - Remove containers and images"
	@echo "  logs      - Show container logs"
	@echo "  health    - Check container health"
	@echo "  shell     - Access container shell"

# Build production image
build:
	@echo "Building YouTube Clone production image..."
	docker-compose build youtube-clone-prod

# Run production container
run:
	@echo "Starting YouTube Clone in production mode..."
	docker-compose up -d youtube-clone-prod
	@echo "Application running at http://localhost:80"

# Run development container
dev:
	@echo "Starting YouTube Clone in development mode..."
	docker-compose --profile dev up -d youtube-clone-dev
	@echo "Development server running at http://localhost:5173"

# Stop all containers
stop:
	@echo "Stopping all containers..."
	docker-compose down

# Clean up containers and images
clean:
	@echo "Cleaning up containers and images..."
	docker-compose down --rmi all --volumes --remove-orphans
	docker system prune -f

# Show logs
logs:
	docker-compose logs -f

# Check health
health:
	@echo "Checking container health..."
	docker-compose ps
	@echo "\nHealth check:"
	curl -f http://localhost:80/health || echo "Health check failed"

# Access container shell
shell:
	docker-compose exec youtube-clone-prod sh

# Build and run in one command
up: build run

# Restart containers
restart: stop run
