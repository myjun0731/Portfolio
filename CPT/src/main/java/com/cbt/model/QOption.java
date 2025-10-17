package com.cbt.model;

public class QOption {
    private int optId;
    private int qId;
    private int optNo;
    private String text;
    private String isAnswer;
    private boolean active = true;

    public QOption() {}

    public int getOptId() { return optId; }
    public void setOptId(int optId) { this.optId = optId; }
    public int getQId() { return qId; }
    public void setQId(int qId) { this.qId = qId; }
    public int getOptNo() { return optNo; }
    public void setOptNo(int optNo) { this.optNo = optNo; }
    public String getText() { return text; }
    public void setText(String text) { this.text = text; }
    public String getIsAnswer() { return isAnswer; }
    public void setIsAnswer(String isAnswer) { this.isAnswer = isAnswer; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}
