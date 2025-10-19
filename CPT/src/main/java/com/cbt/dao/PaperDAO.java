package com.cbt.dao;

import com.cbt.model.ExamPaper;
import com.cbt.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class PaperDAO {

    public List<ExamPaper> getPastPapers() throws SQLException {
        String sql = "SELECT PAPER_ID, NAME, MODE, EXAM_YEAR, EXAM_ROUND, TIME_LIMIT_MIN " +
                     "FROM EXAM_PAPER ORDER BY EXAM_YEAR DESC NULLS LAST, " +
                     "EXAM_ROUND DESC NULLS LAST, PAPER_ID DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            List<ExamPaper> papers = new ArrayList<>();
            while (rs.next()) {
                papers.add(mapPaper(rs));
            }
            return papers;
        }
    }

    public ExamPaper getPaper(int paperId) throws SQLException {
        String sql = "SELECT PAPER_ID, NAME, MODE, EXAM_YEAR, EXAM_ROUND, TIME_LIMIT_MIN " +
                     "FROM EXAM_PAPER WHERE PAPER_ID = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, paperId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapPaper(rs);
                }
            }
            return null;
        }
    }

    private ExamPaper mapPaper(ResultSet rs) throws SQLException {
        ExamPaper paper = new ExamPaper();
        paper.setPaperId(rs.getInt("PAPER_ID"));
        paper.setName(rs.getString("NAME"));
        paper.setMode(rs.getString("MODE"));
        paper.setExamYear((Integer) rs.getObject("EXAM_YEAR"));
        paper.setExamRound((Integer) rs.getObject("EXAM_ROUND"));
        paper.setTimeLimitMin(rs.getInt("TIME_LIMIT_MIN"));
        return paper;
    }
}
