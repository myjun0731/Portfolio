package com.cbt.jsp.tag;

import java.io.IOException;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.JspFragment;
import javax.servlet.jsp.tagext.SimpleTagSupport;

/**
 * Minimal replacement for JSTL's c:otherwise.
 */
public class OtherwiseTag extends SimpleTagSupport {
    @Override
    public void doTag() throws JspException, IOException {
        ChooseTag parent = (ChooseTag) findAncestorWithClass(this, ChooseTag.class);
        if (parent == null) {
            throw new JspException("c:otherwise must be nested inside c:choose");
        }
        if (!parent.isMatched()) {
            parent.markMatched();
            JspFragment body = getJspBody();
            if (body != null) {
                body.invoke(null);
            }
        }
    }
}
