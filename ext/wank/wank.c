#include <wank.h>

VALUE mWank;
VALUE mWankXml;
VALUE mWankHtml;
VALUE cWankXmlMarshal;
VALUE cWankHtmlMarshal;

void Init_wank()
{
  mWank             = rb_define_module("Wank");
  mWankXml          = rb_define_module_under(mWank, "XML");
  mWankHtml         = rb_define_module_under(mWank, "HTML");
  cWankXmlMarshal   = rb_define_class_under(mWankXml, "Marshal", rb_cObject);
  cWankHtmlMarshal  = rb_define_class_under(mWankHtml, "Marshal", rb_cObject);

  init_wank_xml_marshal();
  //init_wank_html_marshal();
}
