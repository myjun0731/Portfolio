package com.cbt.model;

public class StageRecommendation {
    private final String stage;
    private final String focus;
    private final String suggestion;

    public StageRecommendation(String stage, String focus, String suggestion) {
        this.stage = stage;
        this.focus = focus;
        this.suggestion = suggestion;
    }

    public String getStage() {
        return stage;
    }

    public String getFocus() {
        return focus;
    }

    public String getSuggestion() {
        return suggestion;
    }
}
