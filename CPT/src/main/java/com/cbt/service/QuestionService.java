package com.cbt.service;

import com.cbt.model.Question;
import com.cbt.model.Subject;
import com.cbt.model.Tag;
import com.cbt.model.Unit;
import com.cbt.store.AppDataStore;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

public class QuestionService {
    private final AppDataStore store = AppDataStore.getInstance();

    public List<Question> search(Map<String, String[]> params, int page, int size) {
        List<Question> filtered = new ArrayList<>(store.getQuestions());

        if (params.containsKey("subject") && !empty(params.get("subject")[0])) {
            int subjectId = Integer.parseInt(params.get("subject")[0]);
            filtered = filtered.stream()
                    .filter(q -> q.getSubjectId() == subjectId)
                    .collect(Collectors.toList());
        }

        if (params.containsKey("unit") && !empty(params.get("unit")[0])) {
            int unitId = Integer.parseInt(params.get("unit")[0]);
            filtered = filtered.stream()
                    .filter(q -> q.getUnitId() == unitId)
                    .collect(Collectors.toList());
        }

        if (params.containsKey("ncs") && !empty(params.get("ncs")[0])) {
            String ncs = params.get("ncs")[0];
            filtered = filtered.stream()
                    .filter(q -> ncs.equals(q.getNcsCode()))
                    .collect(Collectors.toList());
        }

        if (params.containsKey("year") && !empty(params.get("year")[0])) {
            int year = Integer.parseInt(params.get("year")[0]);
            filtered = filtered.stream()
                    .filter(q -> q.getExamYear() != null && q.getExamYear() == year)
                    .collect(Collectors.toList());
        }

        if (params.containsKey("round") && !empty(params.get("round")[0])) {
            int round = Integer.parseInt(params.get("round")[0]);
            filtered = filtered.stream()
                    .filter(q -> q.getExamRound() != null && q.getExamRound() == round)
                    .collect(Collectors.toList());
        }

        if (params.containsKey("diff") && !empty(params.get("diff")[0])) {
            int diff = Integer.parseInt(params.get("diff")[0]);
            filtered = filtered.stream()
                    .filter(q -> q.getDiff() == diff)
                    .collect(Collectors.toList());
        }

        if (params.containsKey("q") && !empty(params.get("q")[0])) {
            String keyword = params.get("q")[0].toLowerCase();
            filtered = filtered.stream()
                    .filter(q -> q.getStem().toLowerCase().contains(keyword))
                    .collect(Collectors.toList());
        }

        if (params.containsKey("tags")) {
            String[] tagIds = params.get("tags");
            Set<Integer> selected = toIntSet(tagIds);
            if (!selected.isEmpty()) {
                boolean useAnd = "AND".equalsIgnoreCase(param(params, "tagMode", "AND"));
                filtered = filtered.stream()
                        .filter(q -> {
                            Set<Integer> questionTagIds = q.getTags().stream().map(Tag::getTagId).collect(Collectors.toSet());
                            if (useAnd) {
                                return questionTagIds.containsAll(selected);
                            }
                            return selected.stream().anyMatch(questionTagIds::contains);
                        })
                        .collect(Collectors.toList());
            }
        }

        filtered.sort(Comparator.comparing(Question::getExamYear, Comparator.nullsLast(Comparator.reverseOrder()))
                .thenComparing(Question::getExamRound, Comparator.nullsLast(Comparator.reverseOrder())));

        int from = Math.min(page * size, filtered.size());
        int to = Math.min(from + size, filtered.size());
        return filtered.subList(from, to);
    }

    public long count(Map<String, String[]> params) {
        return search(params, 0, Integer.MAX_VALUE).size();
    }

    public List<Unit> getUnits() {
        return new ArrayList<>(store.getUnits());
    }

    public List<Tag> getTags() {
        return new ArrayList<>(store.getTags());
    }

    public List<Subject> getSubjects() {
        return new ArrayList<>(store.getSubjects());
    }

    private boolean empty(String value) {
        return value == null || value.trim().isEmpty();
    }

    private String param(Map<String, String[]> params, String key, String def) {
        String[] values = params.get(key);
        if (values == null || values.length == 0 || values[0] == null) {
            return def;
        }
        return values[0];
    }

    private Set<Integer> toIntSet(String[] ids) {
        return ids == null ? Set.of() :
                java.util.Arrays.stream(ids)
                        .filter(id -> id != null && !id.isBlank())
                        .map(Integer::parseInt)
                        .collect(Collectors.toSet());
    }
}
