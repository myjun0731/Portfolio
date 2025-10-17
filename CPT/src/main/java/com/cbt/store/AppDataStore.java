package com.cbt.store;

import com.cbt.model.*;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;

public class AppDataStore {
    private static final AppDataStore INSTANCE = new AppDataStore();

    private final Map<Integer, Subject> subjects = new LinkedHashMap<>();
    private final Map<Integer, Unit> units = new LinkedHashMap<>();
    private final Map<Integer, Tag> tags = new LinkedHashMap<>();
    private final Map<Integer, Question> questions = new LinkedHashMap<>();
    private final Map<Integer, ExamPaper> papers = new LinkedHashMap<>();
    private final Map<Integer, List<Integer>> paperQuestions = new HashMap<>();
    private final Map<Integer, WrongNote> wrongNotes = new ConcurrentHashMap<>();
    private final Map<Integer, ReviewNote> reviewNotes = new ConcurrentHashMap<>();
    private final Map<Integer, GoalPlan> goals = new ConcurrentHashMap<>();
    private final Map<Integer, ExamSession> sessions = new ConcurrentHashMap<>();
    private final Map<Integer, Map<Integer, ExamResp>> responses = new ConcurrentHashMap<>();
    private final Map<Integer, NavigableMap<LocalDate, Integer>> scoreHistory = new ConcurrentHashMap<>();

    private final AtomicInteger sessionSeq = new AtomicInteger(1000);

    public static AppDataStore getInstance() {
        return INSTANCE;
    }

    private AppDataStore() {
        seedData();
    }

    private void seedData() {
        subjects.put(1, new Subject(1, "데이터베이스"));
        subjects.put(2, new Subject(2, "소프트웨어공학"));

        units.put(10, new Unit(10, 1, "200101", "데이터 모델링", null));
        units.put(11, new Unit(11, 1, "200102", "정규화", 10));
        units.put(12, new Unit(12, 1, "200103", "트랜잭션", 10));
        units.put(20, new Unit(20, 2, "300101", "요구사항 분석", null));

        tags.put(1, new Tag(1, "정규화"));
        tags.put(2, new Tag(2, "트랜잭션"));
        tags.put(3, new Tag(3, "자료구조"));
        tags.put(4, new Tag(4, "DB설계"));

        // Sample questions and options
        Question q1 = new Question();
        q1.setQId(1001);
        q1.setSubjectId(1);
        q1.setSubjectName(subjects.get(1).getName());
        q1.setUnitId(11);
        q1.setUnitName(units.get(11).getName());
        q1.setNcsCode(units.get(11).getNcsCode());
        q1.setExamYear(2023);
        q1.setExamRound(1);
        q1.setStem("제3정규형(3NF)에 대한 설명으로 옳은 것은?");
        q1.setCommentary("함수 종속성을 고려한 정규화 단계 설명");
        q1.setDiff(2);
        q1.setType("M");
        q1.getTags().add(tags.get(1));
        q1.getTags().add(tags.get(4));
        q1.getOptions().add(option(1, 1001, 1, "모든 결정자가 후보키인 정규형이다.", true));
        q1.getOptions().add(option(2, 1001, 2, "다치 종속성을 제거하는 단계이다.", false));
        q1.getOptions().add(option(3, 1001, 3, "부분 함수 종속을 제거한다.", false));
        q1.getOptions().add(option(4, 1001, 4, "모든 속성이 원자값을 갖는다.", false));
        questions.put(q1.getQId(), q1);

        Question q2 = new Question();
        q2.setQId(1002);
        q2.setSubjectId(1);
        q2.setSubjectName(subjects.get(1).getName());
        q2.setUnitId(12);
        q2.setUnitName(units.get(12).getName());
        q2.setNcsCode(units.get(12).getNcsCode());
        q2.setExamYear(2022);
        q2.setExamRound(2);
        q2.setStem("트랜잭션의 고립성 수준 중 REPEATABLE READ에 대한 설명으로 옳은 것은?");
        q2.setCommentary("고립성 수준 비교");
        q2.setDiff(3);
        q2.setType("M");
        q2.getTags().add(tags.get(2));
        q2.getOptions().add(option(5, 1002, 1, "팬텀 리드는 허용된다.", true));
        q2.getOptions().add(option(6, 1002, 2, "더티 리드는 허용된다.", false));
        q2.getOptions().add(option(7, 1002, 3, "직렬화와 동일하다.", false));
        q2.getOptions().add(option(8, 1002, 4, "읽기 커밋과 동일하다.", false));
        questions.put(q2.getQId(), q2);

        Question q3 = new Question();
        q3.setQId(1003);
        q3.setSubjectId(2);
        q3.setSubjectName(subjects.get(2).getName());
        q3.setUnitId(20);
        q3.setUnitName(units.get(20).getName());
        q3.setNcsCode(units.get(20).getNcsCode());
        q3.setExamYear(2023);
        q3.setExamRound(2);
        q3.setStem("요구사항 명세의 검증 기법으로 거리가 먼 것은?");
        q3.setCommentary("검토 기법");
        q3.setDiff(1);
        q3.setType("M");
        q3.getTags().add(tags.get(3));
        q3.getOptions().add(option(9, 1003, 1, "워크스루", false));
        q3.getOptions().add(option(10, 1003, 2, "프로토타이핑", false));
        q3.getOptions().add(option(11, 1003, 3, "검사", false));
        q3.getOptions().add(option(12, 1003, 4, "화이트박스 테스트", true));
        questions.put(q3.getQId(), q3);

        ExamPaper paper2023 = new ExamPaper();
        paper2023.setPaperId(501);
        paper2023.setName("2023년 1회");
        paper2023.setMode("G");
        paper2023.setExamYear(2023);
        paper2023.setExamRound(1);
        paper2023.setTimeLimitMin(90);
        paper2023.setQuestionCount(2);
        paper2023.setHasMissingQuestions(false);
        papers.put(paper2023.getPaperId(), paper2023);
        paperQuestions.put(paper2023.getPaperId(), new ArrayList<>(Arrays.asList(1001, 1002)));

        ExamPaper paper2022 = new ExamPaper();
        paper2022.setPaperId(502);
        paper2022.setName("2022년 2회");
        paper2022.setMode("G");
        paper2022.setExamYear(2022);
        paper2022.setExamRound(2);
        paper2022.setTimeLimitMin(90);
        paper2022.setQuestionCount(1);
        paper2022.setHasMissingQuestions(false);
        papers.put(paper2022.getPaperId(), paper2022);
        paperQuestions.put(paper2022.getPaperId(), new ArrayList<>(Collections.singletonList(1002)));

        GoalPlan defaultGoal = new GoalPlan(1, 70, LocalDate.now().plusMonths(1), 20);
        goals.put(1, defaultGoal);

        scoreHistory.computeIfAbsent(1, k -> new TreeMap<>()).put(LocalDate.of(2023, 1, 1), 68);
        scoreHistory.computeIfAbsent(1, k -> new TreeMap<>()).put(LocalDate.of(2023, 6, 1), 72);
    }

    private QOption option(int optId, int qId, int no, String text, boolean correct) {
        QOption opt = new QOption();
        opt.setOptId(optId);
        opt.setQId(qId);
        opt.setOptNo(no);
        opt.setText(text);
        opt.setIsAnswer(correct ? "Y" : "N");
        return opt;
    }

    public Collection<Subject> getSubjects() {
        return subjects.values();
    }

    public Collection<Unit> getUnits() {
        return units.values();
    }

    public Collection<Tag> getTags() {
        return tags.values();
    }

    public Collection<Question> getQuestions() {
        return questions.values();
    }

    public Optional<Question> findQuestion(int questionId) {
        return Optional.ofNullable(questions.get(questionId));
    }

    public void saveQuestion(Question question) {
        questions.put(question.getQId(), question);
    }

    public Collection<ExamPaper> getPapers() {
        return papers.values();
    }

    public List<Integer> getPaperQuestionIds(int paperId) {
        return paperQuestions.getOrDefault(paperId, Collections.emptyList());
    }

    public GoalPlan getGoal(int userId) {
        return goals.get(userId);
    }

    public void saveGoal(GoalPlan goal) {
        goals.put(goal.getUserId(), goal);
    }

    public WrongNote upsertWrong(int userId, int questionId) {
        int key = Objects.hash(userId, questionId);
        return wrongNotes.compute(key, (k, existing) -> {
            if (existing == null) {
                return new WrongNote(userId, questionId, LocalDateTime.now(), 1);
            }
            existing.setLastWrongAt(LocalDateTime.now());
            existing.setAttempts(existing.getAttempts() + 1);
            return existing;
        });
    }

    public List<WrongNote> getWrongNotes(int userId) {
        return wrongNotes.values().stream()
                .filter(wn -> wn.getUserId() == userId)
                .sorted(Comparator.comparing(WrongNote::getLastWrongAt).reversed())
                .collect(Collectors.toList());
    }

    public void saveReview(ReviewNote note) {
        int key = Objects.hash(note.getUserId(), note.getQuestionId());
        reviewNotes.put(key, note);
    }

    public Collection<ReviewNote> getReviewNotes(int userId) {
        return reviewNotes.values().stream()
                .filter(n -> n.getUserId() == userId)
                .collect(Collectors.toList());
    }

    public ExamSession createSession(int userId, int paperId, long seed, int timeLimitMin) {
        ExamSession session = new ExamSession();
        session.setSessId(sessionSeq.incrementAndGet());
        session.setUserId(userId);
        session.setPaperId(paperId);
        session.setSeed(seed);
        session.setTimeLimitMin(timeLimitMin);
        Timestamp now = Timestamp.from(LocalDateTime.now().atZone(TimeZone.getDefault().toZoneId()).toInstant());
        session.setStartAt(now);
        session.setEndAt(new Timestamp(now.getTime() + timeLimitMin * 60L * 1000L));
        session.setStatus("PLAY");
        sessions.put(session.getSessId(), session);
        responses.put(session.getSessId(), new ConcurrentHashMap<>());
        return session;
    }

    public Optional<ExamSession> findSession(int sessId) {
        return Optional.ofNullable(sessions.get(sessId));
    }

    public void markResume(ExamSession session) {
        session.setResumeCnt(session.getResumeCnt() + 1);
        session.setResumed(true);
    }

    public Map<Integer, ExamResp> getResponses(int sessId) {
        return responses.getOrDefault(sessId, new ConcurrentHashMap<>());
    }

    public void saveResponse(ExamResp resp) {
        responses.computeIfAbsent(resp.getSessId(), k -> new ConcurrentHashMap<>())
                .put(resp.getQId(), resp);
    }

    public void completeSession(ExamSession session, int score) {
        session.setScore(score);
        session.setStatus("DONE");
        session.setSubmitAt(new Timestamp(System.currentTimeMillis()));
        scoreHistory.computeIfAbsent(session.getUserId(), k -> new TreeMap<>())
                .put(LocalDate.now(), score);
    }

    public NavigableMap<LocalDate, Integer> getScoreHistory(int userId) {
        return scoreHistory.getOrDefault(userId, new TreeMap<>());
    }
}
