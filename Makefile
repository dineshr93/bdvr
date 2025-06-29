
ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
PROJ_DIST := ${ROOT_DIR}dist

ifeq ($(OS),Windows_NT)
	SHELL := powershell.exe
	.SHELLFLAGS := -NoProfile -Command
	RM_F_CMD = Remove-Item -erroraction silentlycontinue -Force
    RM_RF_CMD = ${RM_F_CMD} -Recurse
	HELP_CMD = Select-String "^[a-zA-Z_-]+:.*?\#\# .*$$" "./Makefile" | Foreach-Object { $$_data = $$_.matches -split ":.*?\#\# "; $$obj = New-Object PSCustomObject; Add-Member -InputObject $$obj -NotePropertyName ('Command') -NotePropertyValue $$_data[0]; Add-Member -InputObject $$obj -NotePropertyName ('Description') -NotePropertyValue $$_data[1]; $$obj } | Format-Table -HideTableHeaders @{Expression={ $$e = [char]27; "$$e[36m$$($$_.Command)$${e}[0m" }}, Description
else
	SHELL := bash
	RM_F_CMD = rm -f
	RM_RF_CMD = ${RM_F_CMD} -r
	HELP_CMD = grep -E '^[a-zA-Z_-]+:.*?\#\# .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?\#\# "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
endif

all: build test
.DEFAULT_GOAL := help
.PHONY: clean build test all git help

all: $(PROJ_DIR) ## performs clean build and test 
clean: $@ ## Clean the files in dist folder
build: $@ ## clean and Generate the distribution files
test: $@ ## uninstalls and installs new lib make test v=0.8.0 f=FILE
pubtest: $@ ## test the Published lib
git: $@ ## commits and push the changes if commit msg m is given without spaces ex m=added_files

build: clean
	poetry build

publish:
	poetry publish



pubtest: build publish
	echo "===========Testing... make sure command is ->make pubtest test v=0.8.0 f=FILE==============="
	pip uninstall -y bdvr
	pip install bdvr==${v}
	pip install bdvr==${v}
	bdvr -h
	# bdvr -p ${f}

testrem:
	echo "===========Testing... make sure command is ->make test v=0.8.0 f=FILE==============="
	pip uninstall -y bdvr
	pip install bdvr==${v}
	pip install bdvr==${v}
	bdvr -h
	# bdvr -p ${f}
test: build
	echo "===========Testing... make sure command is ->make test v=0.8.0 f=FILE==============="
	pip uninstall -y bdvr
	pip install dist/bdvr-${v}.tar.gz
	pip install dist/bdvr-${v}.tar.gz
	bdvr -h

# bdvr -p ${f}

clean:
	${RM_RF_CMD} ${PROJ_DIST}/*

mv:
	mv ${JSON_DIR}/* ${PROJ_DIR}/
	mv ${OSS_DIR}/* ${PROJ_DIR}/
	mv ${PROP_DIR}/* ${PROJ_DIR}/


git:
	git status
	git add .
	git status
	git commit -m ${m}
	git push

help: ## Show this help
	bdvr -h
	@${HELP_CMD}