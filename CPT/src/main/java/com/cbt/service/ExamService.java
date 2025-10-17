package com.cbt.service;

import com.cbt.model.*;
import com.cbt.store.AppDataStore;

import java.sql.Timestamp;
import java.time.Duration;
import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

public class ExamService {
    private final AppDataStore store = AppDataStore.getInstance();

    public ExamSession startSession(User user, int paperId) {
        ExamPaper paper = store.getPapers().stream()
                .filter(p -> p.getPaperId() == paperId)
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("회차를 찾을 수 없습니다."));
        long seed = System.currentTimeMillis();
        return store.createSession(user.getUserId(), paperId, seed, paper.getTimeLimitMin());
    }

    public ExamSession resumeSession(int sessId) {
        ExamSession session = store.findSession(sessId)
                .orElseThrow(() -> new IllegalArgumentException("세션을 찾을 수 없습니다."));
        if (!session.isResumed()) {
            session.setResumed(true);
            return session;
        }
        if (session.getResumeCnt() >= 1) {
            throw new IllegalStateException("재개 가능 횟수를 초과했습니다.");
        }
        store.markResume(session);
        return session;
    }

    public List<Question> loadQuestionsForSession(ExamSession session) {
        List<Integer> questionIds = store.getPaperQuestionIds(session.getPaperId());
        List<Question> questions = questionIds.stream()
                .map(store::findQuestion)
                .flatMap(Optional::stream)
                .map(this::cloneQuestion)
                .collect(Collectors.toList());
        applyShuffle(session, questions);
        disableUnsupportedTypes(questions);
        return questions;
    }

    private void applyShuffle(ExamSession session, List<Question> questions) {
        Collections.shuffle(questions, new Random(session.getSeed()));
        for (int i = 0; i < questions.size(); i++) {
            Question q = questions.get(i);
            List<QOption> options = q.getOptions().stream()
                    .map(this::cloneOption)
                    .collect(Collectors.toList());
            Collections.shuffle(options, new Random(session.getSeed() + i));
            for (int idx = 0; idx < options.size(); idx++) {
                options.get(idx).setOptNo(idx + 1);
            }
            q.setOptions(options);
        }
    }

    private Question cloneQuestion(Question src) {
        Question copy = new Question();
        copy.setQId(src.getQId());
        copy.setSubjectId(src.getSubjectId());
        copy.setSubjectName(src.getSubjectName());
        copy.setUnitId(src.getUnitId());
        copy.setUnitName(src.getUnitName());
        copy.setNcsCode(src.getNcsCode());
        copy.setExamYear(src.getExamYear());
        copy.setExamRound(src.getExamRound());
        copy.setStem(src.getStem());
        copy.setCommentary(src.getCommentary());
        copy.setDiff(src.getDiff());
        copy.setType(src.getType());
        copy.setTags(new ArrayList<>(src.getTags()));
        copy.setAssets(new ArrayList<>(src.getAssets()));
        copy.setOptions(new ArrayList<>(src.getOptions()));
        return copy;
    }

    private QOption cloneOption(QOption option) {
        QOption copy = new QOption();
        copy.setOptId(option.getOptId());
        copy.setQId(option.getQId());
        copy.setOptNo(option.getOptNo());
        copy.setText(option.getText());
        copy.setIsAnswer(option.getIsAnswer());
        copy.setActive(option.isActive());
        return copy;
    }

    private void disableUnsupportedTypes(List<Question> questions) {
        questions.stream()
                .filter(q -> !"M".equalsIgnoreCase(q.getType()))
                .forEach(q -> q.getOptions().forEach(opt -> opt.setActive(false)));
    }

    public void recordAnswer(int sessId, int qId, Integer choice, boolean flag, int elapsedSec) {
        ExamResp resp = new ExamResp();
        resp.setSessId(sessId);
        resp.setQId(qId);
        resp.setChosenOptNo(choice);
        resp.setElapsedSec(elapsedSec);
        resp.setFlag(flag ? "Y" : "N");
        store.saveResponse(resp);
    }

    public ExamReport submit(int sessId) {
        ExamSession session = store.findSession(sessId)
                .orElseThrow(() -> new IllegalArgumentException("세션을 찾을 수 없습니다."));
        Map<Integer, ExamResp> responses = store.getResponses(sessId);
        List<Question> questions = loadQuestionsForSession(session);
        int correct = 0;
        for (Question question : questions) {
            ExamResp resp = responses.get(question.getQId());
            boolean isCorrect = resp != null && resp.getChosenOptNo() != null &&
                    question.getOptions().stream()
                            .filter(opt -> "Y".equals(opt.getIsAnswer()))
                            .anyMatch(opt -> opt.getOptNo() == resp.getChosenOptNo());
            if (resp != null) {
                resp.setIsCorrect(isCorrect ? "Y" : "N");
            }
            if (isCorrect) {
                correct++;
            } else {
                store.upsertWrong(session.getUserId(), question.getQId());
            }
        }
        int total = questions.size();
        int score = (int) Math.round(correct * 100.0 / Math.max(total, 1));
        store.completeSession(session, score);
        return buildReport(session, questions, responses);
    }

    public ExamReport buildReport(ExamSession session, List<Question> questions, Map<Integer, ExamResp> responses) {
        ExamReport report = new ExamReport();
        report.setSession(session);
        report.setTotalQuestions(questions.size());
        int correct = (int) responses.values().stream()
                .filter(r -> "Y".equals(r.getIsCorrect()))
                .count();
        report.setCorrectCount(correct);
        report.setScore(session.getScore() == null ? 0 : session.getScore());
        report.setUnitAccuracies(aggregateUnitAccuracy(questions, responses));
        report.setTagWeaknesses(aggregateTagAccuracy(questions, responses));
        return report;
    }

    private List<UnitAccuracy> aggregateUnitAccuracy(List<Question> questions, Map<Integer, ExamResp> responses) {
        Map<Integer, UnitAccuracy> map = new LinkedHashMap<>();
        for (Question question : questions) {
            ExamResp resp = responses.get(question.getQId());
            UnitAccuracy accuracy = map.computeIfAbsent(question.getUnitId(),
                    id -> new UnitAccuracy(new Unit(question.getUnitId(), question.getSubjectId(), question.getNcsCode(), question.getUnitName(), null), 0, 0));
            accuracy.setAnswered(accuracy.getAnswered() + 1);
            if (resp != null && "Y".equals(resp.getIsCorrect())) {
                accuracy.setCorrect(accuracy.getCorrect() + 1);
            }
        }
        return new ArrayList<>(map.values());
    }

    private List<TagAccuracy> aggregateTagAccuracy(List<Question> questions, Map<Integer, ExamResp> responses) {
        Map<Integer, TagAccuracy> map = new LinkedHashMap<>();
        for (Question question : questions) {
            for (Tag tag : question.getTags()) {
                ExamResp resp = responses.get(question.getQId());
                TagAccuracy accuracy = map.computeIfAbsent(tag.getTagId(),
                        id -> new TagAccuracy(tag, 0, 0));
                accuracy.setAnswered(accuracy.getAnswered() + 1);
                if (resp != null && "Y".equals(resp.getIsCorrect())) {
                    accuracy.setCorrect(accuracy.getCorrect() + 1);
                }
            }
        }
        return map.values().stream()
                .sorted(Comparator.comparing(TagAccuracy::getAccuracy))
                .limit(5)
                .collect(Collectors.toList());
    }

    public long remainingSeconds(ExamSession session) {
        Instant end = session.getEndAt().toInstant();
        long diff = Duration.between(Instant.now(), end).getSeconds();
        return Math.max(0, diff);
    }
}
