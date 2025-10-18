package com.cbt.jsp.tag;

import java.io.IOException;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.SimpleTagSupport;

import com.cbt.util.HtmlUtil;

/**
 * Minimal replacement for JSTL's c:out supporting HTML escaping and default values.
 */
public class OutTag extends SimpleTagSupport {
    private Object value;
    private String defaultValue;
    private boolean escapeXml = true;

    public void setValue(Object value) {
        this.value = value;
    }

    public void setDefault(String defaultValue) {
        this.defaultValue = defaultValue;
    }

    public void setEscapeXml(boolean escapeXml) {
        this.escapeXml = escapeXml;
    }

    @Override
    public void doTag() throws JspException, IOException {
        Object val = value != null ? value : defaultValue;
        if (val == null) {
            return;
        }
        String output = escapeXml ? HtmlUtil.escape(val.toString()) : val.toString();
        JspWriter out = getJspContext().getOut();
        out.write(output);
    }
}
