package com.cbt.model;

import java.sql.Timestamp;

public class ExamSession {
    private int sessId;
    private int userId;
    private int paperId;
    private long seed;
    private Timestamp startAt;
    private Timestamp endAt;
    private Timestamp submitAt;
    private String status;
    private Integer score;
    private int resumeCnt;
    
    public ExamSession() {}
    
    public int getSessId() { return sessId; }
    public void setSessId(int sessId) { this.sessId = sessId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public int getPaperId() { return paperId; }
    public void setPaperId(int paperId) { this.paperId = paperId; }
    public long getSeed() { return seed; }
    public void setSeed(long seed) { this.seed = seed; }
    public Timestamp getStartAt() { return startAt; }
    public void setStartAt(Timestamp startAt) { this.startAt = startAt; }
    public Timestamp getEndAt() { return endAt; }
    public void setEndAt(Timestamp endAt) { this.endAt = endAt; }
    public Timestamp getSubmitAt() { return submitAt; }
    public void setSubmitAt(Timestamp submitAt) { this.submitAt = submitAt; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Integer getScore() { return score; }
    public void setScore(Integer score) { this.score = score; }
    public int getResumeCnt() { return resumeCnt; }
    public void setResumeCnt(int resumeCnt) { this.resumeCnt = resumeCnt; }
}
