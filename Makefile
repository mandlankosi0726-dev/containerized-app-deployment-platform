PYTHON ?= python3
APP_IMAGE ?= platformops-deployment-platform:dev

.PHONY: app-check validate run compose-up compose-down kind-create kind-delete k8s-deploy status

app-check:
	$(PYTHON) -m ruff check app/src app/tests
	$(PYTHON) -m ruff format --check app/src app/tests
	$(PYTHON) -m pytest app/tests

validate: app-check
	./scripts/validate.sh

run:
	$(PYTHON) -m uvicorn platformops.main:app --app-dir app/src --host 127.0.0.1 --port 8000

compose-up:
	docker compose -f docker/compose.yaml up --build

compose-down:
	docker compose -f docker/compose.yaml down

kind-create:
	./scripts/create-cluster.sh

kind-delete:
	./scripts/delete-cluster.sh

k8s-deploy:
	./scripts/deploy.sh

status:
	./scripts/status.sh
