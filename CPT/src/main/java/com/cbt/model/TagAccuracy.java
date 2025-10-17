package com.cbt.model;

public class TagAccuracy {
    private Tag tag;
    private int answered;
    private int correct;

    public TagAccuracy() {}

    public TagAccuracy(Tag tag, int answered, int correct) {
        this.tag = tag;
        this.answered = answered;
        this.correct = correct;
    }

    public Tag getTag() {
        return tag;
    }

    public void setTag(Tag tag) {
        this.tag = tag;
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
