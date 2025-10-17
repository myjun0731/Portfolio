package com.cbt.model;

import java.util.List;

public class ExamReport {
    private ExamSession session;
    private int totalQuestions;
    private int correctCount;
    private int score;
    private List<UnitAccuracy> unitAccuracies;
    private List<TagAccuracy> tagWeaknesses;

    public ExamReport() {}

    public ExamSession getSession() {
        return session;
    }

    public void setSession(ExamSession session) {
        this.session = session;
    }

    public int getTotalQuestions() {
        return totalQuestions;
    }

    public void setTotalQuestions(int totalQuestions) {
        this.totalQuestions = totalQuestions;
    }

    public int getCorrectCount() {
        return correctCount;
    }

    public void setCorrectCount(int correctCount) {
        this.correctCount = correctCount;
    }

    public int getScore() {
        return score;
    }

    public void setScore(int score) {
        this.score = score;
    }

    public List<UnitAccuracy> getUnitAccuracies() {
        return unitAccuracies;
    }

    public void setUnitAccuracies(List<UnitAccuracy> unitAccuracies) {
        this.unitAccuracies = unitAccuracies;
    }

    public List<TagAccuracy> getTagWeaknesses() {
        return tagWeaknesses;
    }

    public void setTagWeaknesses(List<TagAccuracy> tagWeaknesses) {
        this.tagWeaknesses = tagWeaknesses;
    }
}
