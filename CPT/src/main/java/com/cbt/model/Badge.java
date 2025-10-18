package com.cbt.model;

public class Badge {
    private final String title;
    private final String description;
    private final boolean earned;

    public Badge(String title, String description, boolean earned) {
        this.title = title;
        this.description = description;
        this.earned = earned;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public boolean isEarned() {
        return earned;
    }
}
