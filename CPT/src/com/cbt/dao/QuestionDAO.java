package com.cbt.dao;

import com.cbt.model.*;
import com.cbt.util.DBUtil;
import java.sql.*;
import java.util.*;

public class QuestionDAO {
    
    public List<Question> getQuestions(Integer unitId, Integer year, Integer round, 
                                       Integer diff, String keyword, int page, int size) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT Q.Q_ID, Q.UNIT_ID, U.NAME AS UNIT_NAME, Q.EXAM_YEAR, Q.EXAM_ROUND, " +
            "       Q.STEM, Q.DIFF " +
            "FROM QUESTION Q " +
            "JOIN UNIT U ON Q.UNIT_ID = U.UNIT_ID " +
            "WHERE Q.STATUS = 'APPROVED' "
        );
        
        List<Object> params = new ArrayList<>();
        if (unitId != null) { sql.append("AND Q.UNIT_ID = ? "); params.add(unitId); }
        if (year != null) { sql.append("AND Q.EXAM_YEAR = ? "); params.add(year); }
        if (round != null) { sql.append("AND Q.EXAM_ROUND = ? "); params.add(round); }
        if (diff != null) { sql.append("AND Q.DIFF = ? "); params.add(diff); }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND DBMS_LOB.INSTR(Q.STEM, ?) > 0 ");
            params.add(keyword);
        }
        
        sql.append("ORDER BY Q.EXAM_YEAR DESC, Q.EXAM_ROUND DESC, Q.Q_ID ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * size);
        params.add(size);
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }
            rs = pstmt.executeQuery();
            List<Question> questions = new ArrayList<>();
            while (rs.next()) {
                Question q = new Question();
                q.setQId(rs.getInt("Q_ID"));
                q.setUnitId(rs.getInt("UNIT_ID"));
                q.setUnitName(rs.getString("UNIT_NAME"));
                q.setExamYear((Integer) rs.getObject("EXAM_YEAR"));
                q.setExamRound((Integer) rs.getObject("EXAM_ROUND"));
                q.setStem(rs.getString("STEM"));
                q.setDiff(rs.getInt("DIFF"));
                questions.add(q);
            }
            return questions;
        } finally {
            DBUtil.closeAll(conn, pstmt, rs);
        }
    }
    
    public Question getQuestion(int qId, boolean includeAnswer) throws SQLException {
        String sql = "SELECT Q.Q_ID, Q.UNIT_ID, U.NAME AS UNIT_NAME, Q.EXAM_YEAR, Q.EXAM_ROUND, " +
                     "       Q.STEM, Q.COMMENTARY, Q.DIFF " +
                     "FROM QUESTION Q JOIN UNIT U ON Q.UNIT_ID = U.UNIT_ID WHERE Q.Q_ID = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, qId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Question q = new Question();
                q.setQId(rs.getInt("Q_ID"));
                q.setUnitId(rs.getInt("UNIT_ID"));
                q.setUnitName(rs.getString("UNIT_NAME"));
                q.setExamYear((Integer) rs.getObject("EXAM_YEAR"));
                q.setExamRound((Integer) rs.getObject("EXAM_ROUND"));
                q.setStem(rs.getString("STEM"));
                q.setCommentary(rs.getString("COMMENTARY"));
                q.setDiff(rs.getInt("DIFF"));
                q.setOptions(getOptions(qId, includeAnswer, conn));
                return q;
            }
            return null;
        } finally {
            DBUtil.close(rs);
            DBUtil.close(pstmt);
            DBUtil.close(conn);
        }
    }
    
    private List<QOption> getOptions(int qId, boolean includeAnswer, Connection conn) throws SQLException {
        String sql = "SELECT OPT_ID, Q_ID, OPT_NO, TEXT" +
                     (includeAnswer ? ", IS_ANSWER" : "") +
                     " FROM Q_OPTION WHERE Q_ID = ? ORDER BY OPT_NO";
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, qId);
            rs = pstmt.executeQuery();
            List<QOption> options = new ArrayList<>();
            while (rs.next()) {
                QOption opt = new QOption();
                opt.setOptId(rs.getInt("OPT_ID"));
                opt.setQId(rs.getInt("Q_ID"));
                opt.setOptNo(rs.getInt("OPT_NO"));
                opt.setText(rs.getString("TEXT"));
                if (includeAnswer) opt.setIsAnswer(rs.getString("IS_ANSWER"));
                options.add(opt);
            }
            return options;
        } finally {
            DBUtil.close(rs);
            DBUtil.close(pstmt);
        }
    }
    
    public int getAnswerOptNo(int qId) throws SQLException {
        String sql = "SELECT OPT_NO FROM Q_OPTION WHERE Q_ID = ? AND IS_ANSWER = 'Y'";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, qId);
            rs = pstmt.executeQuery();
            if (rs.next()) return rs.getInt("OPT_NO");
            return -1;
        } finally {
            DBUtil.closeAll(conn, pstmt, rs);
        }
    }
}
