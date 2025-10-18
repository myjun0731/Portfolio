package com.cbt.model;

import java.time.LocalDate;

public class Announcement {
    private final LocalDate date;
    private final String title;
    private final String body;

    public Announcement(LocalDate date, String title, String body) {
        this.date = date;
        this.title = title;
        this.body = body;
    }

    public LocalDate getDate() {
        return date;
    }

    public String getTitle() {
        return title;
    }

    public String getBody() {
        return body;
    }
}
