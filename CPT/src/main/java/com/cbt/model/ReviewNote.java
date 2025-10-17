package com.cbt.model;

import java.time.LocalDateTime;

public class ReviewNote {
    private int userId;
    private int questionId;
    private boolean starred;
    private String memo;
    private LocalDateTime createdAt;

    public ReviewNote() {}

    public ReviewNote(int userId, int questionId, boolean starred, String memo, LocalDateTime createdAt) {
        this.userId = userId;
        this.questionId = questionId;
        this.starred = starred;
        this.memo = memo;
        this.createdAt = createdAt;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getQuestionId() {
        return questionId;
    }

    public void setQuestionId(int questionId) {
        this.questionId = questionId;
    }

    public boolean isStarred() {
        return starred;
    }

    public void setStarred(boolean starred) {
        this.starred = starred;
    }

    public String getMemo() {
        return memo;
    }

    public void setMemo(String memo) {
        this.memo = memo;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
