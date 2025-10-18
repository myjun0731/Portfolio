package com.cbt.jsp.fn;

import java.lang.reflect.Array;
import java.util.Collection;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.Map;

/**
 * Minimal set of EL functions used in JSP views.
 */
public final class Functions {
    private Functions() {
    }

    public static int length(Object value) {
        if (value == null) {
            return 0;
        }
        if (value instanceof String) {
            return ((String) value).length();
        }
        if (value instanceof Collection) {
            return ((Collection<?>) value).size();
        }
        if (value instanceof Map) {
            return ((Map<?, ?>) value).size();
        }
        if (value.getClass().isArray()) {
            return Array.getLength(value);
        }
        if (value instanceof Iterator) {
            int count = 0;
            Iterator<?> it = (Iterator<?>) value;
            while (it.hasNext()) {
                count++;
                it.next();
            }
            return count;
        }
        if (value instanceof Iterable) {
            int count = 0;
            for (Object ignored : (Iterable<?>) value) {
                count++;
            }
            return count;
        }
        if (value instanceof Enumeration) {
            int count = 0;
            Enumeration<?> enumeration = (Enumeration<?>) value;
            while (enumeration.hasMoreElements()) {
                count++;
                enumeration.nextElement();
            }
            return count;
        }
        return value.toString().length();
    }
}
