package com.cbt.model;

public class UnitAccuracy {
    private Unit unit;
    private int answered;
    private int correct;

    public UnitAccuracy() {}

    public UnitAccuracy(Unit unit, int answered, int correct) {
        this.unit = unit;
        this.answered = answered;
        this.correct = correct;
    }

    public Unit getUnit() {
        return unit;
    }

    public void setUnit(Unit unit) {
        this.unit = unit;
    }

    public int getAnswered() {
        return answered;
    }

    public void setAnswered(int answered) {
        this.answered = answered;
    }

    public int getCorrect() {
        return correct;
    }

    public void setCorrect(int correct) {
        this.correct = correct;
    }

    public int getAccuracy() {
        if (answered == 0) {
            return 0;
        }
        return (int) Math.round((correct * 100.0) / answered);
    }
}
