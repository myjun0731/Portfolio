package com.cbt.service;

import com.cbt.model.*;
import com.cbt.store.AppDataStore;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import java.util.NavigableMap;
import java.util.stream.Collectors;

public class StudyService {
    private final AppDataStore store = AppDataStore.getInstance();

    public List<WrongNote> getWrongNotes(int userId) {
        return store.getWrongNotes(userId);
    }

    public void saveReview(int userId, int questionId, boolean starred, String memo) {
        ReviewNote note = new ReviewNote(userId, questionId, starred, memo, LocalDateTime.now());
        store.saveReview(note);
    }

    public Collection<ReviewNote> getReviewNotes(int userId) {
        return store.getReviewNotes(userId);
    }

    public GoalPlan getGoal(int userId) {
        return store.getGoal(userId);
    }

    public void updateGoal(int userId, int targetScore, LocalDate examDate, int dailyCnt) {
        GoalPlan goal = new GoalPlan(userId, targetScore, examDate, dailyCnt);
        store.saveGoal(goal);
    }

    public NavigableMap<LocalDate, Integer> getScoreHistory(int userId) {
        return store.getScoreHistory(userId);
    }

    public List<Question> buildRetrySet(int userId) {
        return store.getWrongNotes(userId).stream()
                .map(wn -> store.findQuestion(wn.getQuestionId()).orElse(null))
                .filter(q -> q != null)
                .distinct()
                .collect(Collectors.toList());
    }
}
