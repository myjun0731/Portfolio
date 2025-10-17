package com.cbt.service;

import com.cbt.model.Question;
import com.cbt.model.QOption;
import com.cbt.store.AppDataStore;

import java.util.List;
import java.util.Optional;

public class AdminService {
    private final AppDataStore store = AppDataStore.getInstance();

    public void submitDraft(Question question) {
        store.saveQuestion(question);
    }

    public Optional<Question> findQuestion(int questionId) {
        return store.findQuestion(questionId);
    }

    public boolean hasDuplicateStem(String stem) {
        return store.getQuestions().stream()
                .anyMatch(q -> q.getStem().equalsIgnoreCase(stem));
    }

    public boolean validateSingleAnswer(List<QOption> options) {
        return options.stream().filter(opt -> "Y".equals(opt.getIsAnswer())).count() == 1;
    }
}
