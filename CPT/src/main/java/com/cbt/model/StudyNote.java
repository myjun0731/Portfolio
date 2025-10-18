package com.cbt.model;

import java.time.LocalDateTime;

public class StudyNote {
    private int userId;
    private int questionId;
    private String memo;
    private LocalDateTime updatedAt;

    public StudyNote(int userId, int questionId, String memo, LocalDateTime updatedAt) {
        this.userId = userId;
        this.questionId = questionId;
        this.memo = memo;
        this.updatedAt = updatedAt;
    }

    public int getUserId() {
        return userId;
    }

    public int getQuestionId() {
        return questionId;
    }

    public String getMemo() {
        return memo;
    }

    public void setMemo(String memo) {
        this.memo = memo;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
