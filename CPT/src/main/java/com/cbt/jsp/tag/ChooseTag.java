package com.cbt.jsp.tag;

import java.io.IOException;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.JspFragment;
import javax.servlet.jsp.tagext.SimpleTagSupport;

/**
 * Minimal replacement for JSTL's c:choose container.
 */
public class ChooseTag extends SimpleTagSupport {
    private boolean matched;

    boolean isMatched() {
        return matched;
    }

    void markMatched() {
        this.matched = true;
    }

    @Override
    public void doTag() throws JspException, IOException {
        matched = false;
        JspFragment body = getJspBody();
        if (body != null) {
            body.invoke(null);
        }
    }
}
