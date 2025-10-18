package com.cbt.jsp.tag;

import java.io.IOException;
import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.tagext.JspFragment;
import javax.servlet.jsp.tagext.SimpleTagSupport;

/**
 * Minimal replacement for JSTL's c:forEach supporting lists, arrays, maps, and numeric ranges.
 */
public class ForEachTag extends SimpleTagSupport {
    private Object items;
    private Integer begin;
    private Integer end;
    private Integer step;
    private String var;
    private String varStatus;

    public void setItems(Object items) {
        this.items = items;
    }

    public void setBegin(Integer begin) {
        this.begin = begin;
    }

    public void setEnd(Integer end) {
        this.end = end;
    }

    public void setStep(Integer step) {
        this.step = step;
    }

    public void setVar(String var) {
        this.var = var;
    }

    public void setVarStatus(String varStatus) {
        this.varStatus = varStatus;
    }

    @Override
    public void doTag() throws JspException, IOException {
        List<Object> values = buildValues();
        if (values.isEmpty()) {
            return;
        }
        int actualStep = (step == null || step <= 0) ? 1 : step;
        int start = begin != null ? Math.max(0, begin) : 0;
        int lastIndex = end != null ? Math.min(end, values.size() - 1) : values.size() - 1;
        if (start > lastIndex) {
            return;
        }

        PageContext pageContext = (PageContext) getJspContext();
        JspFragment body = getJspBody();
        if (body == null) {
            return;
        }

        LoopStatus status = new LoopStatus(start, lastIndex, actualStep);
        for (int idx = start; idx <= lastIndex; idx += actualStep) {
            Object value = values.get(idx);
            if (var != null && !var.isEmpty()) {
                pageContext.setAttribute(var, value, PageContext.PAGE_SCOPE);
            }
            if (varStatus != null && !varStatus.isEmpty()) {
                status.update(idx);
                pageContext.setAttribute(varStatus, status, PageContext.PAGE_SCOPE);
            }
            body.invoke(null);
        }
        if (var != null && !var.isEmpty()) {
            pageContext.removeAttribute(var, PageContext.PAGE_SCOPE);
        }
        if (varStatus != null && !varStatus.isEmpty()) {
            pageContext.removeAttribute(varStatus, PageContext.PAGE_SCOPE);
        }
    }

    private List<Object> buildValues() {
        List<Object> list = new ArrayList<>();
        if (items == null) {
            if (begin != null && end != null) {
                int actualStep = (step == null || step <= 0) ? 1 : step;
                if (actualStep > 0) {
                    if (begin <= end) {
                        for (int i = begin; i <= end; i += actualStep) {
                            list.add(i);
                        }
                    } else {
                        for (int i = begin; i >= end; i -= actualStep) {
                            list.add(i);
                        }
                    }
                }
            }
            return list;
        }
        if (items instanceof Collection) {
            list.addAll((Collection<?>) items);
            return list;
        }
        if (items.getClass().isArray()) {
            int length = Array.getLength(items);
            for (int i = 0; i < length; i++) {
                list.add(Array.get(items, i));
            }
            return list;
        }
        if (items instanceof Map) {
            list.addAll(((Map<?, ?>) items).entrySet());
            return list;
        }
        if (items instanceof Iterator) {
            Iterator<?> iterator = (Iterator<?>) items;
            while (iterator.hasNext()) {
                list.add(iterator.next());
            }
            return list;
        }
        if (items instanceof Iterable) {
            for (Object value : (Iterable<?>) items) {
                list.add(value);
            }
            return list;
        }
        if (items instanceof Enumeration) {
            Enumeration<?> enumeration = (Enumeration<?>) items;
            while (enumeration.hasMoreElements()) {
                list.add(enumeration.nextElement());
            }
            return list;
        }
        list.add(items);
        return list;
    }

    public static class LoopStatus {
        private final int begin;
        private final int end;
        private final int step;
        private int index;
        private int count;

        LoopStatus(int begin, int end, int step) {
            this.begin = begin;
            this.end = end;
            this.step = step;
            this.index = begin - step;
            this.count = 0;
        }

        void update(int currentIndex) {
            this.index = currentIndex;
            this.count++;
        }

        public int getIndex() {
            return index;
        }

        public int getCount() {
            return count;
        }

        public boolean isFirst() {
            return count == 1;
        }

        public boolean isLast() {
            return index >= end || index + step > end;
        }

        public int getBegin() {
            return begin;
        }

        public int getEnd() {
            return end;
        }

        public int getStep() {
            return step;
        }
    }
}
