#include "ferret.h"
#include "analysis.h"
#include "locale.h"

static VALUE cToken;
static VALUE cAsciiLetterTokenizer;
static VALUE cLetterTokenizer;
static VALUE cAsciiWhiteSpaceTokenizer;
static VALUE cWhiteSpaceTokenizer;
static VALUE cAsciiStandardTokenizer;
static VALUE cStandardTokenizer;

static VALUE cAsciiLowerCaseFilter;
static VALUE cLowerCaseFilter;
static VALUE cStopFilter;
static VALUE cStemFilter;

static VALUE cAnalyzer;
static VALUE cAsciiLetterAnalyzer;
static VALUE cLetterAnalyzer;
static VALUE cAsciiWhiteSpaceAnalyzer;
static VALUE cWhiteSpaceAnalyzer;
static VALUE cAsciiStandardAnalyzer;
static VALUE cStandardAnalyzer;
static VALUE cPerFieldAnalyzer;

//static VALUE cRegexAnalyzer;
static VALUE cTokenStream;

/* TokenStream Methods */
static ID id_next;
static ID id_reset;
static ID id_clone;

/* Analyzer Methods */
static ID id_token_stream;

static VALUE object_space;

/****************************************************************************
 *
 * Utility Methods
 *
 ****************************************************************************/

static char **
get_stopwords(VALUE rstop_words)
{
  char **stop_words;
  int i, len;
  VALUE rstr;
  Check_Type(rstop_words, T_ARRAY);
  len = RARRAY(rstop_words)->len;
  stop_words = ALLOC_N(char *, RARRAY(rstop_words)->len + 1);
  stop_words[len] = NULL;
  for (i = 0; i < len; i++) {
    rstr = rb_obj_as_string(RARRAY(rstop_words)->ptr[i]);
    stop_words[i] = RSTRING(rstr)->ptr;
  }
  return stop_words;
}

/****************************************************************************
 *
 * token methods
 *
 ****************************************************************************/

typedef struct RToken {
  VALUE text;
  int start;
  int end;
  int pos_inc;
} RToken;

static void
frt_token_free(void *p)
{
  free(p);
}
  
static void
frt_token_mark(void *p)
{
  RToken *token = (RToken *)p;
  rb_gc_mark(token->text);
}

static VALUE
frt_token_alloc(VALUE klass)
{
  return Data_Wrap_Struct(klass, &frt_token_mark, &frt_token_free, ALLOC(RToken));
}

static VALUE
get_token(Token *tk)
{
  RToken *token = ALLOC(RToken);

  token->text = rb_str_new2(tk->text);
  token->start = tk->start;
  token->end = tk->end;
  token->pos_inc = tk->pos_inc;
  return Data_Wrap_Struct(cToken, &frt_token_mark, &frt_token_free, token);
}

Token *
frt_set_token(Token *tk, VALUE rt)
{
  RToken *rtk;

  if (rt == Qnil) return NULL;

  Data_Get_Struct(rt, RToken, rtk);
  tk_set(tk, RSTRING(rtk->text)->ptr, RSTRING(rtk->text)->len,
      rtk->start, rtk->end, rtk->pos_inc);
  return tk;
}

#define GET_TK RToken *token; Data_Get_Struct(self, RToken, token);
static VALUE
frt_token_init(int argc, VALUE *argv, VALUE self) 
{
  GET_TK;
  VALUE rtext, rstart, rend, rpos_inc, rtype;
  token->pos_inc = 1;
  switch (rb_scan_args(argc, argv, "32", &rtext, &rstart, &rend, &rpos_inc, &rtype)) {
    case 5: /* type gets ignored at this stage */
    case 4: token->pos_inc = FIX2INT(rpos_inc);
  }
  token->text = rb_obj_as_string(rtext);
  token->start = FIX2INT(rstart);
  token->end = FIX2INT(rend);
  return self;
}

static VALUE
frt_token_cmp(VALUE self, VALUE rother)
{
  RToken *other;
  int cmp;
  GET_TK;
  Data_Get_Struct(rother, RToken, other);
  if (token->start > other->start) {
    cmp = 1;
  } else if (token->start < other->start) {
    cmp = -1;
  } else {
    if (token->end > other->end) {
      cmp = 1;
    } else if (token->end < other->end) {
      cmp = -1;
    } else {
      cmp = strcmp(RSTRING(token->text)->ptr, RSTRING(other->text)->ptr);
    }
  }
  return INT2FIX(cmp);
}

static VALUE
frt_token_get_text(VALUE self)
{
  GET_TK;
  return token->text;
}

static VALUE
frt_token_set_text(VALUE self, VALUE rtext)
{
  GET_TK;
  token->text = rtext;
  return rtext;
}

static VALUE
frt_token_get_start_offset(VALUE self)
{
  GET_TK;
  return INT2FIX(token->start);
}

static VALUE
frt_token_get_end_offset(VALUE self)
{
  GET_TK;
  return INT2FIX(token->end);
}

static VALUE
frt_token_get_pos_inc(VALUE self)
{
  GET_TK;
  return INT2FIX(token->pos_inc);
}

static VALUE
frt_token_to_s(VALUE self)
{
  GET_TK;
  char *buf = alloca(RSTRING(token->text)->len + 80);
  sprintf(buf, "token[\"%s\":%d:%d:%d]", RSTRING(token->text)->ptr, token->start,
      token->end, token->pos_inc);
  return rb_str_new2(buf);
}

/****************************************************************************
 *
 * TokenStream Methods
 *
 ****************************************************************************/

static void
frt_ts_mark(void *p)
{
  TokenStream *ts = (TokenStream *)p;
  if (ts->text) frt_gc_mark(&ts->text);
  if (ts->sub_ts) frt_gc_mark(&ts->sub_ts);
}

static void
frt_ts_free(void *p)
{
  TokenStream *ts = (TokenStream *)p;
  if (object_get(&ts->text) != Qnil) object_del(&ts->text);
  if (ts->sub_ts && (object_get(&ts->sub_ts) != Qnil)) object_del(&ts->sub_ts);
  object_del(ts);
  ts->destroy(ts);
}

static VALUE
get_token_stream(TokenStream *ts)
{
  VALUE rts = object_get(ts);
  if (rts == Qnil) {
    rts = Data_Wrap_Struct(cTokenStream, &frt_ts_mark, &frt_ts_free, ts);
    object_add(ts, rts);
  }
  return rts;
}

static inline VALUE
get_wrapped_ts(VALUE self, VALUE rstr, TokenStream *ts)
{
  rstr = rb_obj_as_string(rstr);
  ts->reset(ts, RSTRING(rstr)->ptr);
  Frt_Wrap_Struct(self, &frt_ts_mark, &frt_ts_free, ts);
  object_add(&ts->text, rstr);
  object_add(ts, self);
  return self;
}

static VALUE
frt_ts_set_text(VALUE self, VALUE rtext)
{
  TokenStream *ts; 
  Data_Get_Struct(self, TokenStream, ts);
  rtext = rb_obj_as_string(rtext);
  ts->reset(ts, RSTRING(rtext)->ptr);
  object_set(&ts->text, rtext);

  return rtext;
}

static VALUE
frt_ts_get_text(VALUE self)
{
  VALUE rtext = Qnil;
  TokenStream *ts; 
  Data_Get_Struct(self, TokenStream, ts);
  if (ts->text) {
    if ((rtext = object_get(&ts->text)) == Qnil) {
      rtext = rb_str_new2(ts->text);
      object_set(&ts->text, rtext);
    } 
  }
  return rtext;
}

static VALUE
frt_ts_next(VALUE self)
{
  TokenStream *ts; 
  Data_Get_Struct(self, TokenStream, ts);
  Token *next = ts->next(ts);
  if (next == NULL) {
    return Qnil;
  }

  return get_token(next);
}

/****************************************************************************
 * CWrappedTokenStream
 ****************************************************************************/

void cwrts_destroy(TokenStream *ts)
{
  rb_hash_delete(object_space, (VALUE)ts->data);
  free(ts->token);
  free(ts);
}

Token *cwrts_next(TokenStream *ts)
{
  VALUE rts = (VALUE)ts->data;
  VALUE rtoken = rb_funcall(rts, id_next, 0);
  return frt_set_token(ts->token, rtoken);
}

void cwrts_reset(TokenStream *ts, char *text)
{
  VALUE rts = (VALUE)ts->data;
  ts->t = ts->text = text;
  rb_funcall(rts, id_reset, 1, rb_str_new2(text));
}

void cwrts_clone_i(TokenStream *orig_ts, TokenStream *new_ts)
{
  VALUE rorig_ts = (VALUE)orig_ts->data;
  new_ts->data = (void *)rb_funcall(rorig_ts, id_clone, 0);
}

static TokenStream *
frt_get_cwrapped_rts(VALUE rts) 
{
  TokenStream *ts;
  switch (TYPE(rts)) {
    case T_DATA:
      Data_Get_Struct(rts, TokenStream, ts);
      ref(ts);
      break;
    default:
      ts = ALLOC(TokenStream);
      ts->token = ALLOC(Token);
      ts->data = (void *)rts;
      ts->next = &cwrts_next;
      ts->reset = &cwrts_reset;
      ts->clone_i = &cwrts_clone_i;
      ts->destroy = &cwrts_destroy;
      ts->sub_ts = NULL;
      // prevent from being garbage collected
      rb_hash_aset(object_space, rts, Qnil);
      ts->ref_cnt = 1;
      break;
  }
  return ts;
}

/****************************************************************************
 * Tokenizers
 ****************************************************************************/

#define TS_ARGS(dflt) \
  bool lower;\
  VALUE rlower, rstr;\
  rb_scan_args(argc, argv, "11", &rstr, &rlower);\
  lower = (argc ? RTEST(rlower) : dflt)

static VALUE
frt_a_letter_tokenizer_init(VALUE self, VALUE rstr) 
{
  return get_wrapped_ts(self, rstr, letter_tokenizer_create());
}

static VALUE
frt_letter_tokenizer_init(int argc, VALUE *argv, VALUE self) 
{
  TS_ARGS(false);
  return get_wrapped_ts(self, rstr, mb_letter_tokenizer_create(lower));
}

static VALUE
frt_a_whitespace_tokenizer_init(VALUE self, VALUE rstr) 
{
  return get_wrapped_ts(self, rstr, whitespace_tokenizer_create());
}

static VALUE
frt_whitespace_tokenizer_init(int argc, VALUE *argv, VALUE self) 
{
  TS_ARGS(false);
  return get_wrapped_ts(self, rstr, mb_whitespace_tokenizer_create(lower));
}

static VALUE
frt_a_standard_tokenizer_init(VALUE self, VALUE rstr) 
{
  return get_wrapped_ts(self, rstr, standard_tokenizer_create());
}

static VALUE
frt_standard_tokenizer_init(VALUE self, VALUE rstr) 
{
  return get_wrapped_ts(self, rstr, mb_standard_tokenizer_create());
}

/****************************************************************************
 * Filters
 ****************************************************************************/


static VALUE
frt_a_lowercase_filter_init(VALUE self, VALUE rsub_ts) 
{
  TokenStream *ts = frt_get_cwrapped_rts(rsub_ts);
  ts = lowercase_filter_create(ts);
  object_add(&ts->sub_ts, rsub_ts);

  Frt_Wrap_Struct(self, &frt_ts_mark, &frt_ts_free, ts);
  object_add(ts, self);
  return self;
}

static VALUE
frt_lowercase_filter_init(VALUE self, VALUE rsub_ts) 
{
  TokenStream *ts = frt_get_cwrapped_rts(rsub_ts);
  ts = mb_lowercase_filter_create(ts);
  object_add(&ts->sub_ts, rsub_ts);

  Frt_Wrap_Struct(self, &frt_ts_mark, &frt_ts_free, ts);
  object_add(ts, self);
  return self;
}

static VALUE
frt_stop_filter_init(int argc, VALUE *argv, VALUE self) 
{
  VALUE rsub_ts, rstop_words;
  TokenStream *ts;
  rb_scan_args(argc, argv, "11", &rsub_ts, &rstop_words);
  ts = frt_get_cwrapped_rts(rsub_ts);
  if (rstop_words != Qnil) {
    char **stop_words = get_stopwords(rstop_words);
    ts = stop_filter_create_with_words(ts, (const char **)stop_words);

    free(stop_words);
  } else {
    ts = stop_filter_create(ts);
  }
  object_add(&ts->sub_ts, rsub_ts);

  Frt_Wrap_Struct(self, &frt_ts_mark, &frt_ts_free, ts);
  object_add(ts, self);
  return self;
}

static VALUE
frt_stem_filter_init(int argc, VALUE *argv, VALUE self) 
{
  VALUE rsub_ts, ralgorithm, rcharenc;
  char *algorithm = "english";
  char *charenc = NULL;
  TokenStream *ts;
  rb_scan_args(argc, argv, "12", &rsub_ts, &ralgorithm, &rcharenc);
  ts = frt_get_cwrapped_rts(rsub_ts);
  switch (argc) {
    case 3: charenc = RSTRING(rb_obj_as_string(rcharenc))->ptr;
    case 2: algorithm = RSTRING(rb_obj_as_string(ralgorithm))->ptr;
  }
  ts = stem_filter_create(ts, algorithm, charenc);
  object_add(&ts->sub_ts, rsub_ts);

  Frt_Wrap_Struct(self, &frt_ts_mark, &frt_ts_free, ts);
  object_add(ts, self);
  return self;
}

/****************************************************************************
 *
 * Analyzer Methods
 *
 ****************************************************************************/

/****************************************************************************
 * CWrappedAnalyzer Methods
 ****************************************************************************/

static void
cwa_destroy(Analyzer *a)
{
  rb_hash_delete(object_space, (VALUE)a->data);
  a_standard_destroy(a);
}

static TokenStream *
cwa_get_ts(Analyzer *a, char *field, char *text)
{
  VALUE ranalyzer = (VALUE)a->data;
  VALUE rts = rb_funcall(ranalyzer, id_token_stream, 2,
      rb_str_new2(field), rb_str_new2(text));
  return frt_get_cwrapped_rts(rts);
} 

Analyzer *
frt_get_cwrapped_analyzer(ranalyzer)
{
  Analyzer *a = NULL;
  switch (TYPE(ranalyzer)) {
    case T_DATA:
      Data_Get_Struct(ranalyzer, Analyzer, a);
      ref(a);
      break;
    default:
      a = analyzer_create((void *)ranalyzer, NULL, &cwa_destroy, &cwa_get_ts);
      // prevent from being garbage collected
      rb_hash_aset(object_space, ranalyzer, Qnil);
      break;
  }
  return a;
}

static void
frt_analyzer_free(void *p)
{
  Analyzer *a = (Analyzer *)p;
  object_del(a);
  a->destroy(a);
}

VALUE
frt_get_analyzer(Analyzer *a)
{
  VALUE self = Data_Wrap_Struct(cAnalyzer, NULL, &frt_analyzer_free, a);
  object_add(a, self);
  return self;
}

static VALUE
frt_analyzer_token_stream(VALUE self, VALUE rfield, VALUE rstring)
{
  Analyzer *a = ((struct RData *)(self))->data;
  rfield = rb_obj_as_string(rfield);
  rstring = rb_obj_as_string(rstring);
  
  TokenStream *ts = a_get_new_ts(a, RSTRING(rfield)->ptr, RSTRING(rstring)->ptr);

  object_set(&ts->text, rstring); // Make sure that there is no entry already
  return get_token_stream(ts);
}

#define GET_LOWER(dflt) \
  bool lower;\
  VALUE rlower;\
  rb_scan_args(argc, argv, "01", &rlower);\
  lower = (argc ? RTEST(rlower) : dflt)

/*** AsciiWhiteSpaceAnalyzer ***/
static VALUE
frt_a_white_space_analyzer_init(int argc, VALUE *argv, VALUE self)
{
  GET_LOWER(false);
  Analyzer *a = whitespace_analyzer_create(lower);
  Frt_Wrap_Struct(self, NULL, &frt_analyzer_free, a);
  object_add(a, self);
  return self;
}

/*** WhiteSpaceAnalyzer ***/
static VALUE
frt_white_space_analyzer_init(int argc, VALUE *argv, VALUE self)
{
  GET_LOWER(false);
  Analyzer *a = mb_whitespace_analyzer_create(lower);
  Frt_Wrap_Struct(self, NULL, &frt_analyzer_free, a);
  object_add(a, self);
  return self;
}

/*** AsciiLetterAnalyzer ***/
static VALUE
frt_a_letter_analyzer_init(int argc, VALUE *argv, VALUE self)
{
  GET_LOWER(true);
  Analyzer *a = letter_analyzer_create(lower);
  Frt_Wrap_Struct(self, NULL, &frt_analyzer_free, a);
  object_add(a, self);
  return self;
}

/*** LetterAnalyzer ***/
static VALUE
frt_letter_analyzer_init(int argc, VALUE *argv, VALUE self)
{
  GET_LOWER(true);
  Analyzer *a = mb_letter_analyzer_create(lower);
  Frt_Wrap_Struct(self, NULL, &frt_analyzer_free, a);
  object_add(a, self);
  return self;
}

static VALUE
get_rstopwords(const char **stop_words)
{
  char **w = (char **)stop_words;
  VALUE rstopwords = rb_ary_new();

  while (*w) {
    rb_ary_push(rstopwords, rb_str_new2(*w));
    w++;
  }
  return rstopwords;
}

/*** AsciiStandardAnalyzer ***/
static VALUE
frt_a_standard_analyzer_init(int argc, VALUE *argv, VALUE self)
{
  bool lower;
  VALUE rlower, rstop_words;
  Analyzer *a;
  rb_scan_args(argc, argv, "02", &rlower, &rstop_words);
  lower = ((rlower == Qnil) ? true : RTEST(rlower));
  if (rstop_words != Qnil) {
    char **stop_words = get_stopwords(rstop_words);
    a = standard_analyzer_create_with_words((const char **)stop_words, lower);
    free(stop_words);
  } else {
    a = standard_analyzer_create(lower);
  }
  Frt_Wrap_Struct(self, NULL, &frt_analyzer_free, a);
  object_add(a, self);
  return self;
}

/*** StandardAnalyzer ***/
static VALUE
frt_standard_analyzer_init(int argc, VALUE *argv, VALUE self)
{
  bool lower;
  VALUE rlower, rstop_words;
  Analyzer *a;
  rb_scan_args(argc, argv, "02", &rstop_words, &rlower);
  lower = ((rlower == Qnil) ? true : RTEST(rlower));
  if (rstop_words != Qnil) {
    char **stop_words = get_stopwords(rstop_words);
    a = mb_standard_analyzer_create_with_words((const char **)stop_words, lower);
    free(stop_words);
  } else {
    a = mb_standard_analyzer_create(lower);
  }
  Frt_Wrap_Struct(self, NULL, &frt_analyzer_free, a);
  object_add(a, self);
  return self;
}

void
frt_h_mark_values_i(void *key, void *value, void *arg)
{
  frt_gc_mark(value);
}

void
frt_pfa_mark(void *p)
{
  Analyzer *a = (Analyzer *)p;
  PerFieldAnalyzer *pfa = (PerFieldAnalyzer *)a->data;
  frt_gc_mark(pfa->def);
  h_each(pfa->dict, &frt_h_mark_values_i, NULL);
}

/*** PerFieldAnalyzer ***/
static VALUE
frt_per_field_analyzer_init(VALUE self, VALUE ranalyzer)
{
  Analyzer *def = frt_get_cwrapped_analyzer(ranalyzer);
  Analyzer *a = per_field_analyzer_create(def);
  Frt_Wrap_Struct(self, &frt_pfa_mark, &frt_analyzer_free, a);
  object_add(a, self);
  return self;
}

static VALUE
frt_per_field_analyzer_add_field(VALUE self, VALUE rfield, VALUE ranalyzer)
{
  Analyzer *pfa, *a;
  Data_Get_Struct(self, Analyzer, pfa);
  a = frt_get_cwrapped_analyzer(ranalyzer);

  ref(a); /* make sure pfa won't destroy the analyzer */
  pfa_add_field(pfa, StringValuePtr(rfield), a);
  return self;
}


/** RegexAnalyzer **/
/*
static VALUE
frt_regex_analyzer_init(VALUE self)
{
  Analyzer *a = regex_analyzer_create();
  // keine Ahnung warum hier das Makro und nicht Data_Wrap_Struct:
  Frt_Wrap_Struct(self, NULL, &frt_analyzer_free, a);
  // wofuer?:
  object_add(a, self);
  return self;
}

// convenience method
// XXX this sets the locale for the entire program
static VALUE
frt_regex_analyzer_token_stream(VALUE self, VALUE field, VALUE string)
{
  Analyzer *a =((struct RData *)(self))->data;
  TokenStream *ts = a->get_ts( a, StringValuePtr(field), StringValuePtr(string) );
  // already freed via analyzer's free()
  VALUE token_stream = Data_Wrap_Struct(cTokenStream, NULL, NULL, ts);
  return token_stream;
}
*/
/** /RegexAnalyzer **/

/** TokenStream **/
/** /TokenStream **/

/****************************************************************************
 *
 * Locale stuff
 *
 ****************************************************************************/

static char *frt_locale = NULL;

static VALUE frt_getlocale(VALUE self, VALUE locale)
{
  return (frt_locale ? rb_str_new2(frt_locale) : Qnil);
}

static VALUE frt_setlocale(VALUE self, VALUE locale)
{
  char *l = ((locale == Qnil) ? NULL : RSTRING(rb_obj_as_string(locale))->ptr);
  frt_locale = setlocale(LC_ALL, l);
  return frt_locale ? rb_str_new2(frt_locale) : Qnil;
}

/****************************************************************************
 *
 * Init Function
 *
 ****************************************************************************/

void
Init_analysis(void)
{
  /* TokenStream Methods */
	id_next = rb_intern("next");
	id_reset = rb_intern("text=");
	id_clone = rb_intern("clone");

  /* Analyzer Methods */
	id_token_stream = rb_intern("token_stream");

  object_space = rb_hash_new();
  rb_define_const(mFerret, "OBJECT_SPACE", object_space);

  /*** * * Locale stuff * * ***/
  frt_locale = setlocale(LC_ALL, "");
  rb_define_singleton_method(mFerret, "locale=", frt_setlocale, 1);
  rb_define_singleton_method(mFerret, "locale", frt_getlocale, 0);

  /*********************/
  /*** * * Token * * ***/
  /*********************/
  cToken = rb_define_class_under(mAnalysis, "Token", rb_cObject);
  rb_define_alloc_func(cToken, frt_token_alloc);
  rb_include_module(cToken, rb_mComparable);

  rb_define_method(cToken, "initialize", frt_token_init, -1);
  rb_define_method(cToken, "<=>", frt_token_cmp, 1);
  rb_define_method(cToken, "text", frt_token_get_text, 0);
  rb_define_method(cToken, "text=", frt_token_set_text, 1);
  rb_define_method(cToken, "start_offset", frt_token_get_start_offset, 0);
  rb_define_method(cToken, "end_offset", frt_token_get_end_offset, 0);
  rb_define_method(cToken, "pos_inc", frt_token_get_pos_inc, 0);
  rb_define_method(cToken, "to_s", frt_token_to_s, 0);

  /****************************/
  /*** * * TokenStreams * * ***/
  /****************************/

  cTokenStream = rb_define_class_under(mAnalysis, "TokenStream", rb_cObject);
  rb_define_method(cTokenStream, "next", frt_ts_next, 0);
  rb_define_method(cTokenStream, "text=", frt_ts_set_text, 1);
  rb_define_method(cTokenStream, "text", frt_ts_get_text, 0);

  /******************/
  /*** Tokenizers ***/
  /******************/

  /*** * * AsciiLetterTokenizer * * ***/
  cAsciiLetterTokenizer =
    rb_define_class_under(mAnalysis, "AsciiLetterTokenizer", cTokenStream);
  rb_define_alloc_func(cAsciiLetterTokenizer, frt_data_alloc);
  rb_define_method(cAsciiLetterTokenizer, "initialize",
      frt_a_letter_tokenizer_init, 1);

  /*** * * LetterTokenizer * * ***/
  cLetterTokenizer =
    rb_define_class_under(mAnalysis, "LetterTokenizer", cTokenStream);
  rb_define_alloc_func(cLetterTokenizer, frt_data_alloc);
  rb_define_method(cLetterTokenizer, "initialize",
      frt_letter_tokenizer_init, -1);

  /*** * * AsciiWhiteSpaceTokenizer * * ***/
  cAsciiWhiteSpaceTokenizer =
    rb_define_class_under(mAnalysis, "AsciiWhiteSpaceTokenizer", cTokenStream);
  rb_define_alloc_func(cAsciiWhiteSpaceTokenizer, frt_data_alloc);
  rb_define_method(cAsciiWhiteSpaceTokenizer, "initialize",
      frt_a_whitespace_tokenizer_init, 1);

  /*** * * WhiteSpaceTokenizer * * ***/
  cWhiteSpaceTokenizer =
    rb_define_class_under(mAnalysis, "WhiteSpaceTokenizer", cTokenStream);
  rb_define_alloc_func(cWhiteSpaceTokenizer, frt_data_alloc);
  rb_define_method(cWhiteSpaceTokenizer, "initialize",
      frt_whitespace_tokenizer_init, -1);

  /*** * * AsciiStandardTokenizer * * ***/
  cAsciiStandardTokenizer =
    rb_define_class_under(mAnalysis, "AsciiStandardTokenizer", cTokenStream);
  rb_define_alloc_func(cAsciiStandardTokenizer, frt_data_alloc);
  rb_define_method(cAsciiStandardTokenizer, "initialize",
      frt_a_standard_tokenizer_init, 1);

  /*** * * StandardTokenizer * * ***/
  cStandardTokenizer =
    rb_define_class_under(mAnalysis, "StandardTokenizer", cTokenStream);
  rb_define_alloc_func(cStandardTokenizer, frt_data_alloc);
  rb_define_method(cStandardTokenizer, "initialize",
      frt_standard_tokenizer_init, 1);

  /***************/
  /*** Filters ***/
  /***************/
  rb_define_const(mAnalysis, "ENGLISH_STOP_WORDS",
      get_rstopwords(ENGLISH_STOP_WORDS));
  rb_define_const(mAnalysis, "FULL_ENGLISH_STOP_WORDS",
      get_rstopwords(FULL_ENGLISH_STOP_WORDS));
  rb_define_const(mAnalysis, "EXTENDED_ENGLISH_STOP_WORDS",
      get_rstopwords(EXTENDED_ENGLISH_STOP_WORDS));
  rb_define_const(mAnalysis, "FULL_FRENCH_STOP_WORDS",
      get_rstopwords(FULL_FRENCH_STOP_WORDS));
  rb_define_const(mAnalysis, "FULL_SPANISH_STOP_WORDS",
      get_rstopwords(FULL_SPANISH_STOP_WORDS));
  rb_define_const(mAnalysis, "FULL_PORTUGUESE_STOP_WORDS",
      get_rstopwords(FULL_PORTUGUESE_STOP_WORDS));
  rb_define_const(mAnalysis, "FULL_ITALIAN_STOP_WORDS",
      get_rstopwords(FULL_ITALIAN_STOP_WORDS));
  rb_define_const(mAnalysis, "FULL_GERMAN_STOP_WORDS",
      get_rstopwords(FULL_GERMAN_STOP_WORDS));
  rb_define_const(mAnalysis, "FULL_DUTCH_STOP_WORDS",
      get_rstopwords(FULL_DUTCH_STOP_WORDS));
  rb_define_const(mAnalysis, "FULL_SWEDISH_STOP_WORDS",
      get_rstopwords(FULL_SWEDISH_STOP_WORDS));
  rb_define_const(mAnalysis, "FULL_NORWEGIAN_STOP_WORDS",
      get_rstopwords(FULL_NORWEGIAN_STOP_WORDS));
  rb_define_const(mAnalysis, "FULL_DANISH_STOP_WORDS",
      get_rstopwords(FULL_DANISH_STOP_WORDS));
  rb_define_const(mAnalysis, "FULL_RUSSIAN_STOP_WORDS",
      get_rstopwords(FULL_RUSSIAN_STOP_WORDS));
  rb_define_const(mAnalysis, "FULL_FINNISH_STOP_WORDS",
      get_rstopwords(FULL_FINNISH_STOP_WORDS));
  
  cAsciiLowerCaseFilter =
    rb_define_class_under(mAnalysis, "AsciiLowerCaseFilter", cTokenStream);
  rb_define_alloc_func(cAsciiLowerCaseFilter, frt_data_alloc);
  rb_define_method(cAsciiLowerCaseFilter, "initialize",
      frt_a_lowercase_filter_init, 1);

  cLowerCaseFilter =
    rb_define_class_under(mAnalysis, "LowerCaseFilter", cTokenStream);
  rb_define_alloc_func(cLowerCaseFilter, frt_data_alloc);
  rb_define_method(cLowerCaseFilter, "initialize",
      frt_lowercase_filter_init, 1);

  cStopFilter =
    rb_define_class_under(mAnalysis, "StopFilter", cTokenStream);
  rb_define_alloc_func(cStopFilter, frt_data_alloc);
  rb_define_method(cStopFilter, "initialize",
      frt_stop_filter_init, -1);

  cStemFilter =
    rb_define_class_under(mAnalysis, "StemFilter", cTokenStream);
  rb_define_alloc_func(cStemFilter, frt_data_alloc);
  rb_define_method(cStemFilter, "initialize",
      frt_stem_filter_init, -1);


  /*************************/
  /*** * * Analyzers * * ***/
  /*************************/

  /*** * * Analyzer * * ***/
  cAnalyzer =
    rb_define_class_under(mAnalysis, "Analyzer", rb_cObject);
  rb_define_alloc_func(cAnalyzer, frt_data_alloc);
  rb_define_method(cAnalyzer, "initialize", frt_letter_analyzer_init, -1);
  rb_define_method(cAnalyzer, "token_stream", frt_analyzer_token_stream, 2);

  /*** * * AsciiLetterAnalyzer * * ***/
  cAsciiLetterAnalyzer =
    rb_define_class_under(mAnalysis, "AsciiLetterAnalyzer", cAnalyzer);
  rb_define_alloc_func(cAsciiLetterAnalyzer, frt_data_alloc);
  rb_define_method(cAsciiLetterAnalyzer, "initialize",
      frt_a_letter_analyzer_init, -1);

  /*** * * LetterAnalyzer * * ***/
  cLetterAnalyzer =
    rb_define_class_under(mAnalysis, "LetterAnalyzer", cAnalyzer);
  rb_define_alloc_func(cLetterAnalyzer, frt_data_alloc);
  rb_define_method(cLetterAnalyzer, "initialize",
        frt_letter_analyzer_init, -1);

  /*** * * AsciiWhiteSpaceAnalyzer * * ***/
  cAsciiWhiteSpaceAnalyzer =
    rb_define_class_under(mAnalysis, "AsciiWhiteSpaceAnalyzer", cAnalyzer);
  rb_define_alloc_func(cAsciiWhiteSpaceAnalyzer, frt_data_alloc);
  rb_define_method(cAsciiWhiteSpaceAnalyzer, "initialize",
      frt_a_white_space_analyzer_init, -1);

  /*** * * WhiteSpaceAnalyzer * * ***/
  cWhiteSpaceAnalyzer =
    rb_define_class_under(mAnalysis, "WhiteSpaceAnalyzer", cAnalyzer);
  rb_define_alloc_func(cWhiteSpaceAnalyzer, frt_data_alloc);
  rb_define_method(cWhiteSpaceAnalyzer, "initialize",
      frt_white_space_analyzer_init, -1);

  /*** * * AsciiStandardAnalyzer * * ***/
  cAsciiStandardAnalyzer =
    rb_define_class_under(mAnalysis, "AsciiStandardAnalyzer", cAnalyzer);
  rb_define_alloc_func(cAsciiStandardAnalyzer, frt_data_alloc);
  rb_define_method(cAsciiStandardAnalyzer, "initialize",
      frt_a_standard_analyzer_init, -1);

  /*** * * StandardAnalyzer * * ***/
  cStandardAnalyzer =
    rb_define_class_under(mAnalysis, "StandardAnalyzer", cAnalyzer);
  rb_define_alloc_func(cStandardAnalyzer, frt_data_alloc);
  rb_define_method(cStandardAnalyzer, "initialize",
      frt_standard_analyzer_init, -1);

  /*** * * PerFieldAnalyzer * * ***/
  cPerFieldAnalyzer =
    rb_define_class_under(mAnalysis, "PerFieldAnalyzer", cAnalyzer);
  rb_define_alloc_func(cPerFieldAnalyzer, frt_data_alloc);
  rb_define_method(cPerFieldAnalyzer, "initialize",
      frt_per_field_analyzer_init, 1);
  rb_define_method(cPerFieldAnalyzer, "add_field",
      frt_per_field_analyzer_add_field, 2);
  rb_define_method(cPerFieldAnalyzer, "[]=",
      frt_per_field_analyzer_add_field, 2);

  /** RegexAnalyzer **/
  /*
  cRegexAnalyzer =
    rb_define_class_under(mAnalysis, "RegexAnalyzer", cAnalyzer);
  rb_define_alloc_func(cRegexAnalyzer, frt_data_alloc);
  rb_define_method(cRegexAnalyzer, "initialize",
      frt_regex_analyzer_init, 0);
  rb_define_method(cRegexAnalyzer, "token_stream",
      frt_regex_analyzer_token_stream, 2);
  rb_define_method(cRegexAnalyzer, "setlocale",
      frt_regex_analyzer_setlocale, 1);
  */

}
