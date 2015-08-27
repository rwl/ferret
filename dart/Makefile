default: all

include ../c/make.emscripten

FERRETLIB = ../c/libferret.a

LIBS = $(FERRETLIB)

EXP_NAME = -s "EXPORT_NAME='Ferret'"

EXP_FUNC = -s EXPORTED_FUNCTIONS="['_malloc',\
'_frt_whitespace_analyzer_new',\
'_frt_fis_new',\
'_frt_index_create',\
'_frt_iw_open',\
'_frt_doc_new',\
'_frt_doc_add_field',\
'_frt_iw_add_doc',\
'_frt_doc_destroy',\
'_frt_open_fs_store',\
'_frt_sort_new',\
'_frt_tq_new',\
'_frt_isea_new',\
'_frt_sort_add_sort_field',\
'_frt_td_destroy',\
'_frt_q_deref',\
'_frt_sort_destroy',\
'_frt_rq_new',\
'_frt_store_deref',\
'_frt_qp_new',\
'_frt_qp_add_field',\
'_frt_qp_destroy',\
'_frt_qp_parse']"

EM_FLAGS = $(EXP_NAME) $(EXP_FUNC) --pre-js pre.js

all: module

module: ./lib/ferret.js

./lib/ferret.js: $(LIBS) Makefile pre.js
	@echo Generating module: $@ ...
	@$(CC) $(CFLAGS) $(LIBS) $(EM_FLAGS) -o $@

$(FERRETLIB):
	@( cd ../c ; $(MAKE) clean all )

clean:
	@( cd lib ; $(RM) *ferret*.js* )

