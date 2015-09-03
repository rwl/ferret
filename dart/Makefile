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

EXP_FUNC = -s EXPORTED_FUNCTIONS="['_malloc',\
'_frjs_init',\
'_frt_intern',\
\
'_frt_open_ram_store_and_copy',\
'_frt_open_ram_store',\
'_frjs_dir_exists',\
\
'_frjs_iw_init',\
'_frjs_ir_is_deleted',\
'_frt_iw_close',\
'_frt_iw_doc_count',\
'_frt_iw_delete_term',\
'_frt_iw_add_doc',\
'_frt_iw_optimize',\
'_frt_iw_commit',\
'_frjs_iw_field_infos',\
'_frjs_iw_get_analyzer',\
'_frjs_iw_set_analyzer',\
'_frjs_iw_version',\
'_frjs_iw_get_chunk_size',\
'_frjs_iw_set_chunk_size',\
'_frjs_iw_get_max_buffer_memory',\
'_frjs_iw_set_max_buffer_memory',\
'_frjs_iw_get_index_interval',\
'_frjs_iw_set_index_interval',\
'_frjs_iw_get_skip_interval',\
'_frjs_iw_set_skip_interval',\
'_frjs_iw_get_merge_factor',\
'_frjs_iw_set_merge_factor',\
'_frjs_iw_get_max_buffered_docs',\
'_frjs_iw_set_max_buffered_docs',\
'_frjs_iw_get_max_merge_docs',\
'_frjs_iw_set_max_merge_docs',\
'_frjs_iw_get_max_field_length',\
'_frjs_iw_set_max_field_length',\
'_frjs_iw_get_use_compound_file',\
'_frjs_iw_set_use_compound_file',\
\
'_frt_ir_open',\
'_frt_ir_close',\
'_frt_ir_is_latest',\
'_frt_ir_term_docs_for',\
'_frjs_ir_num_docs',\
'_frjs_ir_get_lazy_doc',\
'_frjs_ir_max_doc',\
'_frjs_tde_next',\
\
'_frjs_standard_analyzer_init',\
\
'_frt_doc_new',\
'_frt_doc_get_field',\
'_frt_doc_add_field',\
'_frt_doc_destroy',\
'_frt_df_new',\
'_frt_df_add_data_len',\
'_frjs_doc_set_boost',\
'_frjs_df_set_boost',\
'_frjs_df_set_destroy_data']"

EM_FLAGS = $(EXP_NAME) $(EXP_FUNC) --pre-js pre.js

JS_DIR = ./lib/src/ext
JS_OBJS = $(JS_DIR)/js_store.o $(JS_DIR)/js_index.o $(JS_DIR)/js_analysis.o \
$(JS_DIR)/js_document.o

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
