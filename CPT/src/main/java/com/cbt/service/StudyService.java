package com.cbt.service;

import com.cbt.model.*;
import com.cbt.store.AppDataStore;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

public class StudyService {
    private final AppDataStore store = AppDataStore.getInstance();

    public List<WrongNote> getWrongNotes(int userId) {
        return store.getWrongNotes(userId);
    }

    public void saveReview(int userId, int questionId, boolean starred, String memo) {
        ReviewNote note = new ReviewNote(userId, questionId, starred, memo, LocalDateTime.now());
        store.saveReview(note);
        store.setFavorite(userId, questionId, starred);
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

    public List<StudyReminder> getReminders(int userId) {
        return store.getReminders(userId);
    }

    public List<StudyPlanSuggestion> buildStudyPlan(int userId) {
        return store.buildStudyPlan(userId);
    }

    public List<UnitSummary> getUnitSummaries(int userId) {
        return store.buildUnitSummaries(userId);
    }

    public List<ConceptSummary> getConceptSummaries() {
        return store.getConceptSummaries();
    }

    public List<StageRecommendation> buildStageRecommendations(int userId) {
        List<UnitSummary> summaries = store.buildUnitSummaries(userId);
        List<StageRecommendation> stages = new ArrayList<>();
        if (summaries.isEmpty()) {
            stages.add(new StageRecommendation("기초", "기출 전 범위 회독", "회차별 핵심 개념 요약을 먼저 정리하세요."));
            stages.add(new StageRecommendation("심화", "태그 집중 훈련", "태그 필터에서 취약 개념을 선택해 10문항씩 풀이하세요."));
            stages.add(new StageRecommendation("실전", "모의고사", "실전 모드로 40분 모의고사를 주 2회 진행하세요."));
            return stages;
        }
        UnitSummary topWrong = summaries.stream()
                .max(Comparator.comparing(UnitSummary::getWrongAttempts))
                .orElse(null);
        UnitSummary topFavorite = summaries.stream()
                .max(Comparator.comparing(UnitSummary::getFavoriteQuestions))
                .orElse(null);
        if (topWrong != null) {
            stages.add(new StageRecommendation("기초", topWrong.getUnit().getName(),
                    "최근 오답이 많은 단원입니다. 해설과 개념 요약을 먼저 확인하세요."));
        }
        if (topFavorite != null) {
            stages.add(new StageRecommendation("심화", topFavorite.getUnit().getName(),
                    "즐겨찾기해 둔 문제를 복습하고 변형 문제를 풀어보세요."));
        }
        stages.add(new StageRecommendation("실전", "랜덤 모의", "실전 모드 + 셔플 옵션으로 주 1회 이상 응시하세요."));
        return stages;
    }

    public List<SrsCard> buildSrsQueue(int userId) {
        LocalDate today = LocalDate.now();
        List<SrsCard> cards = new ArrayList<>();
        for (WrongNote wrong : store.getWrongNotes(userId)) {
            int attempts = Math.max(1, wrong.getAttempts());
            int box = Math.min(3, attempts);
            int interval;
            switch (box) {
                case 1 -> interval = 1;
                case 2 -> interval = 3;
                default -> interval = 7;
            }
            LocalDate due = wrong.getLastWrongAt().toLocalDate().plusDays(interval);
            if (!due.isAfter(today.plusDays(7))) {
                String stem = store.findQuestion(wrong.getQuestionId())
                        .map(Question::getStem)
                        .orElse("문항 정보를 찾을 수 없습니다.");
                cards.add(new SrsCard(wrong.getQuestionId(), stem, due, box));
            }
        }
        cards.sort(Comparator.comparing(SrsCard::getDueDate));
        return cards;
    }

    public List<Badge> buildBadges(int userId) {
        List<Badge> badges = new ArrayList<>();
        int wrongCount = store.getWrongNotes(userId).size();
        int favoriteCount = store.getFavorites(userId).size();
        boolean firstExam = !store.getSessionsForUser(userId).isEmpty();
        badges.add(new Badge("첫 응시 완료", "CBT를 1회 이상 응시하면 획득", firstExam));
        badges.add(new Badge("오답 정복", "오답 노트 5문항 이상 누적", wrongCount >= 5));
        badges.add(new Badge("큐레이션 전문가", "즐겨찾기 3문항 이상 등록", favoriteCount >= 3));
        return badges;
    }
}
