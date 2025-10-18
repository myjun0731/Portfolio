package com.cbt.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class ExamSession {
    private int sessId;
    private int userId;
    private int paperId;
    private long seed;
    private int timeLimitMin;
    private Timestamp startAt;
    private Timestamp endAt;
    private Timestamp submitAt;
    private String status;
    private Integer score;
    private int resumeCnt;
    private boolean resumed;
    private final List<Timestamp> focusOutEvents = new ArrayList<>();
    private String mode;
    private String originLabel;
    private boolean strictNavigation;
    private boolean shuffleQuestions = true;
    private int questionCount;

    public ExamSession() {}

    public int getSessId() { return sessId; }
    public void setSessId(int sessId) { this.sessId = sessId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public int getPaperId() { return paperId; }
    public void setPaperId(int paperId) { this.paperId = paperId; }
    public long getSeed() { return seed; }
    public void setSeed(long seed) { this.seed = seed; }
    public int getTimeLimitMin() { return timeLimitMin; }
    public void setTimeLimitMin(int timeLimitMin) { this.timeLimitMin = timeLimitMin; }
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
    public boolean isResumed() { return resumed; }
    public void setResumed(boolean resumed) { this.resumed = resumed; }
    public List<Timestamp> getFocusOutEvents() { return focusOutEvents; }
    public String getMode() { return mode; }
    public void setMode(String mode) { this.mode = mode; }
    public String getOriginLabel() { return originLabel; }
    public void setOriginLabel(String originLabel) { this.originLabel = originLabel; }
    public boolean isStrictNavigation() { return strictNavigation; }
    public void setStrictNavigation(boolean strictNavigation) { this.strictNavigation = strictNavigation; }
    public boolean isShuffleQuestions() { return shuffleQuestions; }
    public void setShuffleQuestions(boolean shuffleQuestions) { this.shuffleQuestions = shuffleQuestions; }
    public int getQuestionCount() { return questionCount; }
    public void setQuestionCount(int questionCount) { this.questionCount = questionCount; }
}
