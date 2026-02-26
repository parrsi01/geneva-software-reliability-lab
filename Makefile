SHELL := /bin/bash
PYTHON ?= python3
VENV ?= .venv
ACTIVATE = source $(VENV)/bin/activate

.PHONY: help setup test node-test lint run reset tree validate validate-quick pycheck

help:
	@echo "Targets: setup, test, node-test, lint, pycheck, validate, validate-quick, run, reset, tree"

setup:
	$(PYTHON) -m venv $(VENV)
	$(ACTIVATE) && pip install --upgrade pip && pip install -r requirements.txt
	@if command -v npm >/dev/null 2>&1; then npm install; else echo "npm not installed"; fi

test:
	$(ACTIVATE) && pytest -q tests/failing_tests || true

node-test:
	@if command -v node >/dev/null 2>&1; then node --test labs/lab4_api_failure/tests/test_api_failure.js || true; else echo "node not installed"; fi

lint:
	@bash -n run_course.sh
	@bash -n validate_repo.sh

pycheck:
	@find src tests labs -type f -name '*.py' -exec $(PYTHON) -m py_compile {} \;

validate:
	@./validate_repo.sh

validate-quick:
	@./validate_repo.sh --quick

run:
	@./run_course.sh --interactive

reset:
	@./run_course.sh --reset

tree:
	@find . -maxdepth 4 | sort
