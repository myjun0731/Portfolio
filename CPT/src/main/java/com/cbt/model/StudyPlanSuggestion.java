package com.cbt.model;

public class StudyPlanSuggestion {
    private final String label;
    private final String focus;
    private final int questionCount;
    private final String note;

    public StudyPlanSuggestion(String label, String focus, int questionCount, String note) {
        this.label = label;
        this.focus = focus;
        this.questionCount = questionCount;
        this.note = note;
    }

    public String getLabel() {
        return label;
    }

    public String getFocus() {
        return focus;
    }

    public int getQuestionCount() {
        return questionCount;
    }

    public String getNote() {
        return note;
    }
}
