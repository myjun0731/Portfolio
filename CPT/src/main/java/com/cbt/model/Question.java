package com.cbt.model;

import java.util.List;

public class Question {
    private int qId;
    private int unitId;
    private String unitName;
    private Integer examYear;
    private Integer examRound;
    private String stem;
    private String commentary;
    private int diff;
    private List<QOption> options;
    
    public Question() {}
    
    public int getQId() { return qId; }
    public void setQId(int qId) { this.qId = qId; }
    public int getUnitId() { return unitId; }
    public void setUnitId(int unitId) { this.unitId = unitId; }
    public String getUnitName() { return unitName; }
    public void setUnitName(String unitName) { this.unitName = unitName; }
    public Integer getExamYear() { return examYear; }
    public void setExamYear(Integer examYear) { this.examYear = examYear; }
    public Integer getExamRound() { return examRound; }
    public void setExamRound(Integer examRound) { this.examRound = examRound; }
    public String getStem() { return stem; }
    public void setStem(String stem) { this.stem = stem; }
    public String getCommentary() { return commentary; }
    public void setCommentary(String commentary) { this.commentary = commentary; }
    public int getDiff() { return diff; }
    public void setDiff(int diff) { this.diff = diff; }
    public List<QOption> getOptions() { return options; }
    public void setOptions(List<QOption> options) { this.options = options; }
}
