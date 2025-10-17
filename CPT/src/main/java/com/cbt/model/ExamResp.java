package com.cbt.model;

public class ExamResp {
    private int sessId;
    private int qId;
    private Integer chosenOptNo;
    private String isCorrect;
    private Integer elapsedSec;
    private String flag;
    
    public ExamResp() {}
    
    public int getSessId() { return sessId; }
    public void setSessId(int sessId) { this.sessId = sessId; }
    public int getQId() { return qId; }
    public void setQId(int qId) { this.qId = qId; }
    public Integer getChosenOptNo() { return chosenOptNo; }
    public void setChosenOptNo(Integer chosenOptNo) { this.chosenOptNo = chosenOptNo; }
    public String getIsCorrect() { return isCorrect; }
    public void setIsCorrect(String isCorrect) { this.isCorrect = isCorrect; }
    public Integer getElapsedSec() { return elapsedSec; }
    public void setElapsedSec(Integer elapsedSec) { this.elapsedSec = elapsedSec; }
    public String getFlag() { return flag; }
    public void setFlag(String flag) { this.flag = flag; }
}
