package com.cbt.jsp.tag;

import java.io.IOException;
import java.io.StringWriter;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.tagext.JspFragment;
import javax.servlet.jsp.tagext.SimpleTagSupport;

/**
 * Minimal replacement for JSTL's c:set supporting var and scope.
 */
public class SetTag extends SimpleTagSupport {
    private String var;
    private Object value;
    private String scope;

    public void setVar(String var) {
        this.var = var;
    }

    public void setValue(Object value) {
        this.value = value;
    }

    public void setScope(String scope) {
        this.scope = scope;
    }

    @Override
    public void doTag() throws JspException, IOException {
        if (var == null || var.isEmpty()) {
            throw new JspException("'var' attribute is required for set tag");
        }
        PageContext pageContext = (PageContext) getJspContext();
        Object actualValue = value;
        if (actualValue == null) {
            JspFragment body = getJspBody();
            if (body != null) {
                StringWriter writer = new StringWriter();
                body.invoke(writer);
                actualValue = writer.toString();
            }
        }

        int scopeConstant = resolveScope(scope);
        if (actualValue == null) {
            pageContext.removeAttribute(var, scopeConstant);
        } else {
            pageContext.setAttribute(var, actualValue, scopeConstant);
        }
    }

    private int resolveScope(String scopeName) throws JspException {
        if (scopeName == null || scopeName.isEmpty()) {
            return PageContext.PAGE_SCOPE;
        }
        switch (scopeName) {
            case "page":
                return PageContext.PAGE_SCOPE;
            case "request":
                return PageContext.REQUEST_SCOPE;
            case "session":
                return PageContext.SESSION_SCOPE;
            case "application":
                return PageContext.APPLICATION_SCOPE;
            default:
                throw new JspException("Invalid scope '" + scopeName + "'");
        }
    }
}
