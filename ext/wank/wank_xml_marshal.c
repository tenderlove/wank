#include <wank_xml_marshal.h>

static VALUE target_type(VALUE self)
{
  VALUE target = rb_iv_get(self, "@target");
  if(target == Qtrue) return ID2SYM(rb_intern("true"));
  if(target == Qfalse) return ID2SYM(rb_intern("false"));
  if(target == Qnil) return ID2SYM(rb_intern("nil"));
  if(FIXNUM_P(target)) return ID2SYM(rb_intern("fixnum"));
  rb_raise(rb_eRuntimeError, "I can't handle that object");
}

void init_wank_xml_marshal()
{
  rb_define_method(cWankXmlMarshal, "target_type", target_type, 0);
}
