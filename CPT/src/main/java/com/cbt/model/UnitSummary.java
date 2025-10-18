package com.cbt.model;

public class UnitSummary {
    private final Unit unit;
    private final long totalQuestions;
    private final long favoriteQuestions;
    private final long wrongAttempts;

    public UnitSummary(Unit unit, long totalQuestions, long favoriteQuestions, long wrongAttempts) {
        this.unit = unit;
        this.totalQuestions = totalQuestions;
        this.favoriteQuestions = favoriteQuestions;
        this.wrongAttempts = wrongAttempts;
    }

    public Unit getUnit() {
        return unit;
    }

    public long getTotalQuestions() {
        return totalQuestions;
    }

    public long getFavoriteQuestions() {
        return favoriteQuestions;
    }

    public long getWrongAttempts() {
        return wrongAttempts;
    }
}
