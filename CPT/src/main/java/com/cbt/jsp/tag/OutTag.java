package com.cbt.jsp.tag;

import java.io.IOException;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.SimpleTagSupport;

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
        String output = val.toString();
        if (escapeXml) {
            output = escapeXml(output);
        }
        JspWriter out = getJspContext().getOut();
        out.write(output);
    }

    private String escapeXml(String input) {
        StringBuilder sb = new StringBuilder(input.length());
        for (int i = 0; i < input.length(); i++) {
            char ch = input.charAt(i);
            switch (ch) {
                case '&':
                    sb.append("&amp;");
                    break;
                case '<':
                    sb.append("&lt;");
                    break;
                case '>':
                    sb.append("&gt;");
                    break;
                case '"':
                    sb.append("&quot;");
                    break;
                case '\'':
                    sb.append("&#39;");
                    break;
                default:
                    sb.append(ch);
            }
        }
        return sb.toString();
    }
}
