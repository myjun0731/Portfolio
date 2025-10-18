package com.cbt.model;

import java.time.LocalDate;

public class SrsCard {
    private final int questionId;
    private final String stem;
    private final LocalDate dueDate;
    private final int box;

    public SrsCard(int questionId, String stem, LocalDate dueDate, int box) {
        this.questionId = questionId;
        this.stem = stem;
        this.dueDate = dueDate;
        this.box = box;
    }

    public int getQuestionId() {
        return questionId;
    }

    public String getStem() {
        return stem;
    }

    public LocalDate getDueDate() {
        return dueDate;
    }

    public int getBox() {
        return box;
    }
}
