SHELL       		:= bash
.SHELLFLAGS 		:= -eu -o pipefail -c
MAKEFLAGS   		+= --warn-undefined-variables
MAKEFLAGS   		+= --no-builtin-rules
LIGHTTPD_DIR		:= ./lighttpd
LIGHTTPD_CONF		:= $(LIGHTTPD_DIR)/lighttpd.conf
LIGHTTPD_DOCROOT	:= ./src
LIGHTTPD_PORT 		:= 1312
WAIT 				:= 0.2s
SCHEME				:= http
HOST				:= localhost
URL					?=

serve:
	LIGHTTPD_DIR=$(LIGHTTPD_DIR) \
		LIGHTTPD_PORT=$(LIGHTTPD_PORT) \
		LIGHTTPD_DOCROOT=$(LIGHTTPD_DOCROOT) \
		lighttpd-angel -D -f $(LIGHTTPD_CONF)

server_restart:
	kill -s HUP $$(pgrep lighttpd-angel)

server_reload:
	kill -s USR1 $$(pgrep lighttpd-angel)

browse:
	[[ -z "$$(pgrep surf)" ]] && \
		WEBKIT_DISABLE_DMABUF_RENDERER=1 \
		surf "http://localhost:$(LIGHTTPD_PORT)/$(URL)" &> /dev/null &

refresh:
	sleep $(WAIT)
	kill -s HUP $$(pgrep surf)

watch: browse
	fd -t f . $(LIGHTTPD_DOCROOT) | entr -p $(MAKE) --no-print-directory refresh

dump:
	@w3m -dump "http://localhost:$(LIGHTTPD_PORT)/$(URL)"

header:
	@curl -LI http://localhost:$(LIGHTTPD_PORT)/$(URL)

.PHONY := \
	serve \
	server_restart \
	server_reload \
	browse \
	refresh \
	watch \
	dump \
	header

.DEFAULT_GOAL := header
