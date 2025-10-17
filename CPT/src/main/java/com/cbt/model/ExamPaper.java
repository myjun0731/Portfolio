package com.cbt.model;

public class ExamPaper {
    private int paperId;
    private String name;
    private String mode;
    private Integer examYear;
    private Integer examRound;
    private int timeLimitMin;
    private int questionCount;
    private boolean hasMissingQuestions;

    public ExamPaper() {}

    public int getPaperId() { return paperId; }
    public void setPaperId(int paperId) { this.paperId = paperId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getMode() { return mode; }
    public void setMode(String mode) { this.mode = mode; }
    public Integer getExamYear() { return examYear; }
    public void setExamYear(Integer examYear) { this.examYear = examYear; }
    public Integer getExamRound() { return examRound; }
    public void setExamRound(Integer examRound) { this.examRound = examRound; }
    public int getTimeLimitMin() { return timeLimitMin; }
    public void setTimeLimitMin(int timeLimitMin) { this.timeLimitMin = timeLimitMin; }
    public int getQuestionCount() { return questionCount; }
    public void setQuestionCount(int questionCount) { this.questionCount = questionCount; }
    public boolean isHasMissingQuestions() { return hasMissingQuestions; }
    public void setHasMissingQuestions(boolean hasMissingQuestions) { this.hasMissingQuestions = hasMissingQuestions; }
}
