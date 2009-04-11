#include <wank_xml_marshal.h>

#ifndef RFLOAT_VALUE
#define RFLOAT_VALUE(f) (RFLOAT(f)->value)
#endif

#ifndef RREGEXP_SRC_PTR
#define RREGEXP_SRC_PTR(f) (RREGEXP(f)->str)
#endif

#ifndef RREGEXP_SRC_LEN
#define RREGEXP_SRC_LEN(f) (RREGEXP(f)->len)
#endif

#define PUSH(node_name) \
  rb_funcall(self, rb_intern("push"), 1, rb_str_new2(node_name));

#define POP \
  rb_funcall(self, rb_intern("pop"), 0);

#define SET_ATTRIBUTE(node, attr, value) \
  rb_funcall(node, rb_intern("[]="), 2, rb_str_new2(attr), value);

#define ADD_TEXT(text) \
  rb_funcall(self, rb_intern("text"), 1, rb_str_new2(text));

#define SET_CLASS(class) \
  rb_funcall(self, rb_intern("set_class"), 1, rb_class_path(class));

static int hash_each(VALUE key, VALUE value, VALUE self);

static VALUE dump(VALUE self, VALUE target)
{
  VALUE div = PUSH("div");

  if (target == Qnil) {
    SET_CLASS(rb_class_of(target));
    PUSH("span");
    ADD_TEXT("nil");
    POP;
  } else if (target == Qtrue) {
    SET_CLASS(rb_class_of(target));
    PUSH("span");
    ADD_TEXT("true");
    POP;
  } else if (target == Qfalse) {
    SET_CLASS(rb_class_of(target));
    PUSH("span");
    ADD_TEXT("true");
    POP;
  } else if (FIXNUM_P(target)) {
    SET_CLASS(rb_class_of(target));
    PUSH("span");
    rb_funcall(self, rb_intern("text"), 1, rb_fix2str(target, 10));
    POP;
  } else if (SYMBOL_P(target)) {
    SET_CLASS(rb_class_of(target));
    PUSH("span");
    ADD_TEXT(rb_id2name(SYM2ID(target)))
    POP;
  } else {
	  switch (BUILTIN_TYPE(target)) {
	    case T_FLOAT:
        SET_CLASS(rb_class_of(target));
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

	    case T_STRING:
        SET_CLASS(rb_class_of(target));
        PUSH("span");
        rb_funcall(self, rb_intern("text"), 1,
            rb_str_new(RSTRING_PTR(target), RSTRING_LEN(target)));
        POP;
        break;

	    case T_CLASS:
        SET_CLASS(target);
        SET_ATTRIBUTE(div, "class", rb_str_new2("Class"));
        SET_ATTRIBUTE(div, "name", rb_class_path(target));
        PUSH("span");
        rb_funcall(self, rb_intern("text"), 1,
            rb_class_path(target));
        POP;
        break;

	    case T_MODULE:
        SET_CLASS(rb_class_of(target));
        PUSH("span");
        rb_funcall(self, rb_intern("text"), 1, rb_class_path(target));
        POP;
        break;

	    case T_ARRAY:
        SET_CLASS(rb_class_of(target));
        PUSH("ol");
        long i;
		    for (i = 0; i < RARRAY_LEN(target); i++) {
          PUSH("li");
          dump(self, RARRAY_PTR(target)[i]);
          POP;
        }
        POP;
        break;

	    case T_HASH:
        SET_CLASS(rb_class_of(target));
        PUSH("dl");
	      rb_hash_foreach(target, hash_each, self);
        POP;
        break;

	    case T_STRUCT:
        {
          SET_CLASS(rb_class_of(target));
          SET_ATTRIBUTE(div, "class", rb_str_new2("Struct"));
          SET_ATTRIBUTE(div, "name", rb_class_path(rb_class_of(target)));
          PUSH("dl");
		      long i;
		      VALUE mem = rb_struct_members(target);
		      for (i = 0; i < RSTRING_LEN(target); i++) {
            PUSH("dt");
            dump(self, RARRAY_PTR(mem)[i]);
            POP;
            PUSH("dd");
            dump(self, RSTRUCT_PTR(target)[i]);
            POP;
		      }
          POP;
        }
        break;

      case T_OBJECT:
        SET_CLASS(rb_class_of(target));
        break;

      default:
	      rb_raise(rb_eTypeError, "I can't handle %s", rb_obj_classname(target));
    }
  }

  VALUE ivars = rb_obj_instance_variables(target);
  rb_funcall(self, rb_intern("__dump_ivars"), 1, ivars);


  return POP;
}

static int hash_each(VALUE key, VALUE value, VALUE self)
{
  PUSH("dt");
  dump(self, key);
  POP;
  PUSH("dd");
  dump(self, value);
  POP;
  return ST_CONTINUE;
}

static VALUE dump_ivar(VALUE self, VALUE target, VALUE ivar_name)
{
  VALUE ivar = rb_ivar_get(target, SYM2ID(ivar_name));
  return dump(self, ivar);
}

void init_wank_xml_marshal()
{
  rb_define_private_method(cWankXmlMarshal, "dump", dump, 1);
  rb_define_private_method(cWankXmlMarshal, "__dump_ivar", dump_ivar, 2);
}
