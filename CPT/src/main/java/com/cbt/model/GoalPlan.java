package com.cbt.model;

import java.time.LocalDate;

public class GoalPlan {
    private int userId;
    private int targetScore;
    private LocalDate examDate;
    private int dailyQuestionCount;

    public GoalPlan() {}

    public GoalPlan(int userId, int targetScore, LocalDate examDate, int dailyQuestionCount) {
        this.userId = userId;
        this.targetScore = targetScore;
        this.examDate = examDate;
        this.dailyQuestionCount = dailyQuestionCount;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getTargetScore() {
        return targetScore;
    }

    public void setTargetScore(int targetScore) {
        this.targetScore = targetScore;
    }

    public LocalDate getExamDate() {
        return examDate;
    }

    public void setExamDate(LocalDate examDate) {
        this.examDate = examDate;
    }

    public int getDailyQuestionCount() {
        return dailyQuestionCount;
    }

    public void setDailyQuestionCount(int dailyQuestionCount) {
        this.dailyQuestionCount = dailyQuestionCount;
    }
}
