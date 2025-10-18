package com.cbt.model;

public class ConceptSummary {
    private final String title;
    private final String description;
    private final String tags;

    public ConceptSummary(String title, String description, String tags) {
        this.title = title;
        this.description = description;
        this.tags = tags;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public String getTags() {
        return tags;
    }
}
