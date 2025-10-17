package com.cbt.model;

public class Unit {
    private int unitId;
    private int subjectId;
    private String ncsCode;
    private String name;
    private Integer parentId;

    public Unit() {}

    public Unit(int unitId, int subjectId, String ncsCode, String name, Integer parentId) {
        this.unitId = unitId;
        this.subjectId = subjectId;
        this.ncsCode = ncsCode;
        this.name = name;
        this.parentId = parentId;
    }

    public int getUnitId() {
        return unitId;
    }

    public void setUnitId(int unitId) {
        this.unitId = unitId;
    }

    public int getSubjectId() {
        return subjectId;
    }

    public void setSubjectId(int subjectId) {
        this.subjectId = subjectId;
    }

    public String getNcsCode() {
        return ncsCode;
    }

    public void setNcsCode(String ncsCode) {
        this.ncsCode = ncsCode;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getParentId() {
        return parentId;
    }

    public void setParentId(Integer parentId) {
        this.parentId = parentId;
    }
}
