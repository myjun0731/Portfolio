package com.cbt.jsp.tag;

import java.io.IOException;
import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
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
        JspFragment body = getJspBody();
        if (body == null) {
            return;
        }

        IterationPlan plan = resolvePlan();
        if (!plan.hasWork()) {
            return;
        }

        PageContext pageContext = (PageContext) getJspContext();
        boolean exposeVar = hasText(var);
        boolean exposeStatus = hasText(varStatus);
        LoopStatus status = exposeStatus
                ? new LoopStatus(plan.statusBegin, plan.statusEnd, plan.step, plan.totalIterations)
                : null;

        int iteration = 0;
        try {
            for (int idx = plan.startIndex; idx <= plan.endIndex; idx += plan.step) {
                Object value = plan.values.get(idx);
                if (exposeVar) {
                    pageContext.setAttribute(var, value, PageContext.PAGE_SCOPE);
                }
                if (exposeStatus && status != null) {
                    status.update(idx, iteration);
                    pageContext.setAttribute(varStatus, status, PageContext.PAGE_SCOPE);
                }
                body.invoke(null);
                iteration++;
            }
        } finally {
            if (exposeVar) {
                pageContext.removeAttribute(var, PageContext.PAGE_SCOPE);
            }
            if (exposeStatus) {
                pageContext.removeAttribute(varStatus, PageContext.PAGE_SCOPE);
            }
        }
    }

    private IterationPlan resolvePlan() {
        IterationSource source = resolveSource();
        if (source.isEmpty()) {
            return IterationPlan.empty();
        }

        int resolvedStep = resolveStep();
        if (source.usesIndexBounds()) {
            int size = source.values.size();
            int startIndex = begin != null ? clamp(begin, 0, size - 1) : 0;
            int endIndex = end != null ? clamp(end, 0, size - 1) : size - 1;
            if (startIndex > endIndex) {
                return IterationPlan.empty();
            }
            int totalIterations = computeTotalIterations(startIndex, endIndex, resolvedStep);
            if (totalIterations <= 0) {
                return IterationPlan.empty();
            }
            return IterationPlan.of(source.values, startIndex, endIndex, resolvedStep, totalIterations, startIndex, endIndex);
        }

        int endIndex = source.values.size() - 1;
        int totalIterations = computeTotalIterations(0, endIndex, resolvedStep);
        if (totalIterations <= 0) {
            return IterationPlan.empty();
        }
        return IterationPlan.of(source.values, 0, endIndex, resolvedStep, totalIterations, source.statusBegin, source.statusEnd);
    }

    private IterationSource resolveSource() {
        if (items == null) {
            return resolveNumericSource();
        }

        List<Object> list = new ArrayList<>();
        if (items instanceof Collection) {
            list.addAll((Collection<?>) items);
        } else if (items.getClass().isArray()) {
            int length = Array.getLength(items);
            for (int i = 0; i < length; i++) {
                list.add(Array.get(items, i));
            }
        } else if (items instanceof Map) {
            list.addAll(((Map<?, ?>) items).entrySet());
        } else if (items instanceof Iterator) {
            Iterator<?> iterator = (Iterator<?>) items;
            while (iterator.hasNext()) {
                list.add(iterator.next());
            }
        } else if (items instanceof Iterable) {
            for (Object value : (Iterable<?>) items) {
                list.add(value);
            }
        } else if (items instanceof Enumeration) {
            Enumeration<?> enumeration = (Enumeration<?>) items;
            while (enumeration.hasMoreElements()) {
                list.add(enumeration.nextElement());
            }
        } else {
            list.add(items);
        }

        if (list.isEmpty()) {
            return IterationSource.empty();
        }
        return IterationSource.forCollection(list);
    }

    private IterationSource resolveNumericSource() {
        if (begin == null && end == null) {
            return IterationSource.empty();
        }
        int startValue = begin != null ? begin : 0;
        int endValue = end != null ? end : startValue;
        int actualStep = resolveStep();
        int direction = startValue <= endValue ? 1 : -1;
        int stepWithDirection = actualStep * direction;
        List<Object> values = new ArrayList<>();
        for (int current = startValue; direction > 0 ? current <= endValue : current >= endValue; current += stepWithDirection) {
            values.add(current);
        }
        if (values.isEmpty()) {
            return IterationSource.empty();
        }
        return IterationSource.forRange(values, startValue, endValue);
    }

    private int resolveStep() {
        if (step == null || step == 0) {
            return 1;
        }
        return Math.abs(step);
    }

    private int computeTotalIterations(int startIndex, int endIndex, int stepSize) {
        if (startIndex > endIndex || stepSize <= 0) {
            return 0;
        }
        return ((endIndex - startIndex) / stepSize) + 1;
    }

    private int clamp(int value, int min, int max) {
        if (value < min) {
            return min;
        }
        if (value > max) {
            return max;
        }
        return value;
    }

    private boolean hasText(String candidate) {
        return candidate != null && !candidate.trim().isEmpty();
    }

    private static final class IterationSource {
        private static final IterationSource EMPTY = new IterationSource(Collections.emptyList(), true, 0, -1);

        private final List<Object> values;
        private final boolean indexBounds;
        private final int statusBegin;
        private final int statusEnd;

        private IterationSource(List<Object> values, boolean indexBounds, int statusBegin, int statusEnd) {
            this.values = values;
            this.indexBounds = indexBounds;
            this.statusBegin = statusBegin;
            this.statusEnd = statusEnd;
        }

        static IterationSource empty() {
            return EMPTY;
        }

        static IterationSource forCollection(List<Object> values) {
            return new IterationSource(values, true, 0, values.size() - 1);
        }

        static IterationSource forRange(List<Object> values, int begin, int end) {
            return new IterationSource(values, false, begin, end);
        }

        boolean isEmpty() {
            return values.isEmpty();
        }

        boolean usesIndexBounds() {
            return indexBounds;
        }
    }

    private static final class IterationPlan {
        private static final IterationPlan EMPTY = new IterationPlan(Collections.emptyList(), 0, -1, 1, 0, 0, -1);

        private final List<Object> values;
        private final int startIndex;
        private final int endIndex;
        private final int step;
        private final int totalIterations;
        private final int statusBegin;
        private final int statusEnd;

        private IterationPlan(List<Object> values, int startIndex, int endIndex, int step, int totalIterations,
                int statusBegin, int statusEnd) {
            this.values = values;
            this.startIndex = startIndex;
            this.endIndex = endIndex;
            this.step = step;
            this.totalIterations = totalIterations;
            this.statusBegin = statusBegin;
            this.statusEnd = statusEnd;
        }

        static IterationPlan of(List<Object> values, int startIndex, int endIndex, int step, int totalIterations,
                int statusBegin, int statusEnd) {
            return new IterationPlan(values, startIndex, endIndex, step, totalIterations, statusBegin, statusEnd);
        }

        static IterationPlan empty() {
            return EMPTY;
        }

        boolean hasWork() {
            return totalIterations > 0 && startIndex <= endIndex;
        }
    }

    public static class LoopStatus {
        private final int begin;
        private final int end;
        private final int step;
        private final int totalIterations;
        private int index;
        private int iteration;

        LoopStatus(int begin, int end, int step, int totalIterations) {
            this.begin = begin;
            this.end = end;
            this.step = step;
            this.totalIterations = Math.max(totalIterations, 0);
            this.index = begin;
            this.iteration = -1;
        }

        void update(int currentIndex, int iterationIndex) {
            this.index = currentIndex;
            this.iteration = iterationIndex;
        }

        public int getIndex() {
            return index;
        }

        public int getCount() {
            return iteration < 0 ? 0 : iteration + 1;
        }

        public boolean isFirst() {
            return iteration == 0;
        }

        public boolean isLast() {
            return iteration >= 0 && iteration + 1 == totalIterations;
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
