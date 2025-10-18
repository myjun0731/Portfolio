package com.cbt.model;

import java.util.ArrayList;
import java.util.List;

public class Question {
    private int qId;
    private int subjectId;
    private String subjectName;
    private int unitId;
    private String unitName;
    private String ncsCode;
    private Integer examYear;
    private Integer examRound;
    private String stem;
    private String commentary;
    private String hint;
    private String videoUrl;
    private int diff;
    private String type;
    private List<QOption> options = new ArrayList<>();
    private List<Tag> tags = new ArrayList<>();
    private List<Asset> assets = new ArrayList<>();

    public Question() {}

    public int getQId() { return qId; }
    public void setQId(int qId) { this.qId = qId; }
    public int getSubjectId() { return subjectId; }
    public void setSubjectId(int subjectId) { this.subjectId = subjectId; }
    public String getSubjectName() { return subjectName; }
    public void setSubjectName(String subjectName) { this.subjectName = subjectName; }
    public int getUnitId() { return unitId; }
    public void setUnitId(int unitId) { this.unitId = unitId; }
    public String getUnitName() { return unitName; }
    public void setUnitName(String unitName) { this.unitName = unitName; }
    public String getNcsCode() { return ncsCode; }
    public void setNcsCode(String ncsCode) { this.ncsCode = ncsCode; }
    public Integer getExamYear() { return examYear; }
    public void setExamYear(Integer examYear) { this.examYear = examYear; }
    public Integer getExamRound() { return examRound; }
    public void setExamRound(Integer examRound) { this.examRound = examRound; }
    public String getStem() { return stem; }
    public void setStem(String stem) { this.stem = stem; }
    public String getCommentary() { return commentary; }
    public void setCommentary(String commentary) { this.commentary = commentary; }
    public String getHint() { return hint; }
    public void setHint(String hint) { this.hint = hint; }
    public String getVideoUrl() { return videoUrl; }
    public void setVideoUrl(String videoUrl) { this.videoUrl = videoUrl; }
    public int getDiff() { return diff; }
    public void setDiff(int diff) { this.diff = diff; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public List<QOption> getOptions() { return options; }
    public void setOptions(List<QOption> options) { this.options = options; }
    public List<Tag> getTags() { return tags; }
    public void setTags(List<Tag> tags) { this.tags = tags; }
    public List<Asset> getAssets() { return assets; }
    public void setAssets(List<Asset> assets) { this.assets = assets; }
}
