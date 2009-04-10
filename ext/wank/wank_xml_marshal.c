#include <wank_xml_marshal.h>

#ifndef RFLOAT_VALUE
#define RFLOAT_VALUE(f) (RFLOAT(f)->value)
#endif

#define PUSH(node_name) \
  rb_funcall(self, rb_intern("push"), 1, rb_str_new2(node_name));

#define POP \
  rb_funcall(self, rb_intern("pop"), 0);

#define SET_ATTRIBUTE(node, attr, value) \
  rb_funcall(node, rb_intern("[]="), 2, rb_str_new2(attr), value);

#define ADD_TEXT(text) \
  rb_funcall(self, rb_intern("text"), 1, rb_str_new2(text));

static VALUE dump(VALUE self, VALUE target)
{
  VALUE div = PUSH("div");

  SET_ATTRIBUTE(div, "class", rb_class_path(rb_class_of(target)));

  if (target == Qnil) {
    PUSH("span");
    ADD_TEXT("nil");
    POP;
  } else if (target == Qtrue) {
    PUSH("span");
    ADD_TEXT("true");
    POP;
  } else if (target == Qfalse) {
    PUSH("span");
    ADD_TEXT("true");
    POP;
  } else if (FIXNUM_P(target)) {
    PUSH("span");
    rb_funcall(self, rb_intern("text"), 1, rb_fix2str(target, 10));
    POP;
  } else if (SYMBOL_P(target)) {
    PUSH("span");
    ADD_TEXT(rb_id2name(SYM2ID(target)))
    POP;
  } else {
	  switch (BUILTIN_TYPE(target)) {
	    case T_FLOAT:
        PUSH("span");
        char buf[32];
        double value = RFLOAT_VALUE(target);
        if(isinf(value)) {
          ADD_TEXT(value < 0 ? "-Infinity" : "Infinity");
        } else if(isnan(value)) {
          ADD_TEXT("NaN");
        } else {
          sprintf(buf, "%#.15g", RFLOAT_VALUE(target));
          ADD_TEXT(buf);
        }
        POP;
        break;

      default:
        rb_raise(rb_eRuntimeError, "I can't handle that object");
    }
  }


  return POP;
}

void init_wank_xml_marshal()
{
  rb_define_private_method(cWankXmlMarshal, "dump", dump, 1);
}
