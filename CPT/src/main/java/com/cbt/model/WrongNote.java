package com.cbt.model;

import java.time.LocalDateTime;

public class WrongNote {
    private int userId;
    private int questionId;
    private LocalDateTime lastWrongAt;
    private int attempts;

    public WrongNote() {}

    public WrongNote(int userId, int questionId, LocalDateTime lastWrongAt, int attempts) {
        this.userId = userId;
        this.questionId = questionId;
        this.lastWrongAt = lastWrongAt;
        this.attempts = attempts;
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

    public LocalDateTime getLastWrongAt() {
        return lastWrongAt;
    }

    public void setLastWrongAt(LocalDateTime lastWrongAt) {
        this.lastWrongAt = lastWrongAt;
    }

    public int getAttempts() {
        return attempts;
    }

    public void setAttempts(int attempts) {
        this.attempts = attempts;
    }
}
