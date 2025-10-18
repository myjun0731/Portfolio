package com.cbt.model;

import java.time.LocalDateTime;

public class QuestionFeedback {
    private final int userId;
    private final int questionId;
    private final String type;
    private final String message;
    private final LocalDateTime createdAt;

    public QuestionFeedback(int userId, int questionId, String type, String message, LocalDateTime createdAt) {
        this.userId = userId;
        this.questionId = questionId;
        this.type = type;
        this.message = message;
        this.createdAt = createdAt;
    }

    public int getUserId() {
        return userId;
    }

    public int getQuestionId() {
        return questionId;
    }

    public String getType() {
        return type;
    }

    public String getMessage() {
        return message;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
}
