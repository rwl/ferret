default: all

include ../c/make.emscripten

DEP_DIR  = .deps
FERRET_DIR = ../c
FERRET_INC = $(FERRET_DIR)/include
FERRETLIB = $(FERRET_DIR)/libferret.a
LIBS = $(FERRETLIB)
CINCS = -I$(FERRET_INC)
CFLAGS += -std=c99 -pedantic -Wall -Wextra $(CINCS) -g -fno-common

EXP_NAME = -s "EXPORT_NAME='Ferret'"

include ./exp_inc/analysis.inc
include ./exp_inc/document.inc
include ./exp_inc/field_info.inc
include ./exp_inc/index_reader.inc
include ./exp_inc/index_writer.inc
include ./exp_inc/lazy_doc.inc
include ./exp_inc/term.inc
include ./exp_inc/search.inc
include ./exp_inc/store.inc
include ./exp_inc/query_parser.inc
include ./exp_inc/utils.inc

EXP_FUNC = -s EXPORTED_FUNCTIONS="[\
'_malloc',\
'_frjs_init',\
'_frt_hs_new_ptr',\
'_frt_hs_add',\
'_frjs_hash_get_first',\
'_frjs_hash_get_entry_next',\
'_frjs_hash_get_entry_elem',\
'_frt_intern',\
'_frjs_hash_get_size',\
'_frjs_hash_get_key',\
'_frjs_hash_get_value',\
'_frjs_bv_count',\
'_frjs_bv_extends_as_ones',\
'_frjs_bv_unset',\
'_frjs_bv_and_x',\
'_frjs_bv_and',\
'_frjs_bv_or_x',\
'_frjs_bv_or',\
'_frjs_bv_xor_x',\
'_frjs_bv_xor',\
'_frjs_bv_not_x',\
'_frjs_bv_not',\
'_frjs_bv_scan_next_unset',\
'_frjs_bv_scan_next_unset_from',\
'_frt_h_destroy',\
$(EXP_ANALYSIS),\
$(EXP_DOCUMENT),\
$(EXP_FIELD_INFO),\
$(EXP_INDEX_READER),\
$(EXP_INDEX_WRITER),\
$(EXP_LAZY_DOC),\
$(EXP_TERM),\
$(EXP_SEARCH),\
$(EXP_STORE),\
$(EXP_QUERY_PARSER),\
$(EXP_UTILS)]"

EM_FLAGS = $(EXP_NAME) $(EXP_FUNC) --pre-js pre.js

JS_DIR = ./lib/src/ext

JS_OBJS = \
$(JS_DIR)/store.o \
$(JS_DIR)/global.o \
$(JS_DIR)/index/field_info.o \
$(JS_DIR)/index/lazy_doc.o \
$(JS_DIR)/index/writer.o \
$(JS_DIR)/index/term.o \
$(JS_DIR)/index/reader.o \
$(JS_DIR)/search/search.o \
$(JS_DIR)/analysis/analysis.o \
$(JS_DIR)/document.o\
$(JS_DIR)/query_parser.o

all: module

module: ./lib/ferret.js

./lib/ferret.js: $(JS_OBJS) $(LIBS) Makefile pre.js
	@echo Generating module: $@ ...
	@$(CC) $(CFLAGS) $(JS_OBJS) $(LIBS) $(EM_FLAGS) -o $@

$(FERRETLIB):
	@( cd ../c ; $(MAKE) clean all )

clean:
	@rm -f $(JS_OBJS)
	@rm -rf $(DEP_DIR)
	@( cd lib ; $(RM) *ferret*.js* )

###
# Dependency build
# Ref: http://make.paulandlesley.org/autodep.html
###

%.o : %.c
	@mkdir -p `dirname $(DEP_DIR)/$*.P`
	@echo Compiling: $< ...
	@$(COMPILE.c) -MD -o $@ $<
	@cp $*.d $(DEP_DIR)/$*.P; \
            sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
                -e '/^$$/ d' -e 's/$$/ :/' < $*.d >> $(DEP_DIR)/$*.P; \
            rm -f $*.d
