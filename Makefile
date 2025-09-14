SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

###############
# Entry points
###############
format: out/.format.lua.sentinel out/.format.yaml.sentinel
.PHONY: format

lint: out/.lint.shell.sentinel
.PHONY: lint

###############
# Sentinels
###############

out/.format.lua.sentinel: $(shell find ./ -name "*.lua")
	find ./ -name "*.lua" | xargs stylua
	mkdir -p $(@D)
	touch $@

out/.format.yaml.sentinel: $(shell find ops/arch -name "*.yml")
	find ops/arch -name "*.yml" | xargs yamlfmt
	mkdir -p $(@D)
	touch $@

out/.lint.shell.sentinel: $(shell find ./ -name "tmux" -prune -o -name "*.sh" -print)
	find ./ -name "tmux" -prune -o -name "*.sh" -print | xargs shellcheck
	mkdir -p $(@D)
	touch $@
