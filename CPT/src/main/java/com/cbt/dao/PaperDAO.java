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

    /**
     * 발행된 기출 시험지 목록을 조회한다.
     */
    public List<ExamPaper> getPastPapers() throws SQLException {
        String sql = "SELECT PAPER_ID, NAME, MODE, EXAM_YEAR, EXAM_ROUND, TIME_LIMIT_MIN " +
                     "FROM EXAM_PAPER WHERE STATUS = 'PUBLISHED' " +
                     "ORDER BY EXAM_YEAR DESC NULLS LAST, EXAM_ROUND DESC NULLS LAST, PAPER_ID DESC";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            List<ExamPaper> papers = new ArrayList<>();
            while (rs.next()) {
                ExamPaper paper = new ExamPaper();
                paper.setPaperId(rs.getInt("PAPER_ID"));
                paper.setName(rs.getString("NAME"));
                paper.setMode(rs.getString("MODE"));
                paper.setExamYear((Integer) rs.getObject("EXAM_YEAR"));
                paper.setExamRound((Integer) rs.getObject("EXAM_ROUND"));
                paper.setTimeLimitMin(rs.getInt("TIME_LIMIT_MIN"));
                papers.add(paper);
            }
            return papers;
        } finally {
            DBUtil.closeAll(conn, pstmt, rs);
        }
    }

    /**
     * 시험지를 단건 조회한다.
     */
    public ExamPaper getPaper(int paperId) throws SQLException {
        String sql = "SELECT PAPER_ID, NAME, MODE, EXAM_YEAR, EXAM_ROUND, TIME_LIMIT_MIN " +
                     "FROM EXAM_PAPER WHERE PAPER_ID = ?";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, paperId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                ExamPaper paper = new ExamPaper();
                paper.setPaperId(rs.getInt("PAPER_ID"));
                paper.setName(rs.getString("NAME"));
                paper.setMode(rs.getString("MODE"));
                paper.setExamYear((Integer) rs.getObject("EXAM_YEAR"));
                paper.setExamRound((Integer) rs.getObject("EXAM_ROUND"));
                paper.setTimeLimitMin(rs.getInt("TIME_LIMIT_MIN"));
                return paper;
            }
            return null;
        } finally {
            DBUtil.closeAll(conn, pstmt, rs);
        }
    }
}
