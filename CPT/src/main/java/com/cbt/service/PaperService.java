package com.cbt.service;

import com.cbt.dao.PaperDAO;
import com.cbt.model.ExamPaper;

import java.sql.SQLException;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

public class PaperService {

    private final PaperDAO paperDAO;

    public PaperService() {
        this(new PaperDAO());
    }

    public PaperService(PaperDAO paperDAO) {
        this.paperDAO = Objects.requireNonNull(paperDAO, "paperDAO");
    }

    public List<ExamPaper> fetchRecentPapers() throws SQLException {
        List<ExamPaper> papers = paperDAO.getPastPapers();
        return papers == null ? Collections.emptyList() : papers;
    }

    public ExamPaper findPaper(int paperId) throws SQLException {
        return paperDAO.getPaper(paperId);
    }
}
