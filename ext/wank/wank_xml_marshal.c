#include <wank_xml_marshal.h>

static VALUE target_type(VALUE self)
{
  VALUE target = rb_iv_get(self, "@target");

  return ID2SYM(rb_intern("true"));
}

void init_wank_xml_marshal()
{
  rb_define_method(cWankXmlMarshal, "target_type", target_type, 0);
}
