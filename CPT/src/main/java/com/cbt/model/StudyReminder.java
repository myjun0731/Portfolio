package com.cbt.model;

import java.time.LocalDate;

public class StudyReminder {
    private final LocalDate dueDate;
    private final String title;
    private final String description;

    public StudyReminder(LocalDate dueDate, String title, String description) {
        this.dueDate = dueDate;
        this.title = title;
        this.description = description;
    }

    public LocalDate getDueDate() {
        return dueDate;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }
}
