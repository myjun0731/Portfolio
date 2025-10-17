package com.cbt.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.cbt.model.ExamResp;
import com.cbt.model.ExamSession;
import com.cbt.util.DBUtil;

public class ExamDAO {
    
    /**
     * 세션 생성
     */
    public int createSession(int userId, int paperId, int timeLimitMin) throws SQLException {
        String insertSql = "INSERT INTO EXAM_SESSION (SESS_ID, USER_ID, PAPER_ID, SEED, START_AT, END_AT, STATUS) " +
                           "VALUES (SEQ_SESSION.NEXTVAL, ?, ?, ?, SYSTIMESTAMP, SYSTIMESTAMP + ?/1440, 'ACTIVE')";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            
            long seed = System.currentTimeMillis();
            pstmt = conn.prepareStatement(insertSql, new String[]{"SESS_ID"});
            pstmt.setInt(1, userId);
            pstmt.setInt(2, paperId);
            pstmt.setLong(3, seed);
            pstmt.setInt(4, timeLimitMin);
            
            pstmt.executeUpdate();
            
            rs = pstmt.getGeneratedKeys();
            if (rs.next()) {
                int sessId = rs.getInt(1);
                
                // 시험지 문항으로 응답 레코드 초기화
                initResponses(sessId, paperId, conn);
                
                return sessId;
            }
            throw new SQLException("세션 ID 생성 실패");
        } finally {
            DBUtil.close(rs);
            DBUtil.close(pstmt);
            DBUtil.close(conn);
        }
    }
    
    /**
     * 응답 레코드 초기화
     */
    private void initResponses(int sessId, int paperId, Connection conn) throws SQLException {
        String sql = "INSERT INTO EXAM_RESP (SESS_ID, Q_ID, FLAG) " +
                     "SELECT ?, Q_ID, 'N' FROM PAPER_Q WHERE PAPER_ID = ?";
        
        PreparedStatement pstmt = null;
        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, sessId);
            pstmt.setInt(2, paperId);
            pstmt.executeUpdate();
        } finally {
            DBUtil.close(pstmt);
        }
    }
    
    /**
     * 세션 조회
     */
    public ExamSession getSession(int sessId) throws SQLException {
        String sql = "SELECT SESS_ID, USER_ID, PAPER_ID, SEED, START_AT, END_AT, SUBMIT_AT, STATUS, SCORE, RESUME_CNT " +
                     "FROM EXAM_SESSION WHERE SESS_ID = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, sessId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                ExamSession sess = new ExamSession();
                sess.setSessId(rs.getInt("SESS_ID"));
                sess.setUserId(rs.getInt("USER_ID"));
                sess.setPaperId(rs.getInt("PAPER_ID"));
                sess.setSeed(rs.getLong("SEED"));
                sess.setStartAt(rs.getTimestamp("START_AT"));
                sess.setEndAt(rs.getTimestamp("END_AT"));
                sess.setSubmitAt(rs.getTimestamp("SUBMIT_AT"));
                sess.setStatus(rs.getString("STATUS"));
                sess.setScore((Integer) rs.getObject("SCORE"));
                sess.setResumeCnt(rs.getInt("RESUME_CNT"));
                return sess;
            }
            return null;
        } finally {
            DBUtil.closeAll(conn, pstmt, rs);
        }
    }
    
    /**
     * 응답 저장
     */
    public void saveAnswer(int sessId, int qId, int chosenOptNo, int elapsedSec) throws SQLException {
        String sql = "UPDATE EXAM_RESP SET CHOSEN_OPT_NO = ?, ELAPSED_SEC = ? " +
                     "WHERE SESS_ID = ? AND Q_ID = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, chosenOptNo);
            pstmt.setInt(2, elapsedSec);
            pstmt.setInt(3, sessId);
            pstmt.setInt(4, qId);
            pstmt.executeUpdate();
        } finally {
            DBUtil.close(pstmt);
            DBUtil.close(conn);
        }
    }
    
    /**
     * 플래그 토글
     */
    public void toggleFlag(int sessId, int qId) throws SQLException {
        String sql = "UPDATE EXAM_RESP SET FLAG = CASE WHEN FLAG = 'Y' THEN 'N' ELSE 'Y' END " +
                     "WHERE SESS_ID = ? AND Q_ID = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, sessId);
            pstmt.setInt(2, qId);
            pstmt.executeUpdate();
        } finally {
            DBUtil.close(pstmt);
            DBUtil.close(conn);
        }
    }
    
    /**
     * 시험 제출 및 채점
     */
    public void submitExam(int sessId) throws SQLException {
        Connection conn = null;
        
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);
            
            // 1. 채점
            QuestionDAO qDao = new QuestionDAO();
            String selectSql = "SELECT Q_ID, CHOSEN_OPT_NO FROM EXAM_RESP WHERE SESS_ID = ?";
            PreparedStatement selectPstmt = conn.prepareStatement(selectSql);
            selectPstmt.setInt(1, sessId);
            ResultSet rs = selectPstmt.executeQuery();
            
            int correctCnt = 0;
            int totalCnt = 0;
            
            while (rs.next()) {
                int qId = rs.getInt("Q_ID");
                Integer chosenOptNo = (Integer) rs.getObject("CHOSEN_OPT_NO");
                
                if (chosenOptNo != null) {
                    int answerOptNo = qDao.getAnswerOptNo(qId);
                    boolean isCorrect = (chosenOptNo == answerOptNo);
                    
                    String updateSql = "UPDATE EXAM_RESP SET IS_CORRECT = ? WHERE SESS_ID = ? AND Q_ID = ?";
                    PreparedStatement updatePstmt = conn.prepareStatement(updateSql);
                    updatePstmt.setString(1, isCorrect ? "Y" : "N");
                    updatePstmt.setInt(2, sessId);
                    updatePstmt.setInt(3, qId);
                    updatePstmt.executeUpdate();
                    updatePstmt.close();
                    
                    if (isCorrect) correctCnt++;
                }
                totalCnt++;
            }
            rs.close();
            selectPstmt.close();
            
            // 2. 점수 계산
            int score = (int) Math.round(((double) correctCnt / totalCnt) * 100);
            
            // 3. 세션 상태 업데이트
            String sessSql = "UPDATE EXAM_SESSION SET STATUS = 'SUBMIT', SUBMIT_AT = SYSTIMESTAMP, SCORE = ? WHERE SESS_ID = ?";
            PreparedStatement sessPstmt = conn.prepareStatement(sessSql);
            sessPstmt.setInt(1, score);
            sessPstmt.setInt(2, sessId);
            sessPstmt.executeUpdate();
            sessPstmt.close();
            
            // 4. 오답노트 추가 (MERGE 사용)
            String wrongSql = "MERGE INTO WRONG_NOTE W " +
                              "USING (SELECT ES.USER_ID, ER.Q_ID FROM EXAM_RESP ER " +
                              "       JOIN EXAM_SESSION ES ON ER.SESS_ID = ES.SESS_ID " +
                              "       WHERE ER.SESS_ID = ? AND ER.IS_CORRECT = 'N') SRC " +
                              "ON (W.USER_ID = SRC.USER_ID AND W.Q_ID = SRC.Q_ID) " +
                              "WHEN MATCHED THEN UPDATE SET CNT = W.CNT + 1, LAST_WRONG_AT = SYSTIMESTAMP " +
                              "WHEN NOT MATCHED THEN INSERT (USER_ID, Q_ID, CNT) VALUES (SRC.USER_ID, SRC.Q_ID, 1)";
            
            PreparedStatement wrongPstmt = conn.prepareStatement(wrongSql);
            wrongPstmt.setInt(1, sessId);
            wrongPstmt.executeUpdate();
            wrongPstmt.close();
            
            conn.commit();
        } catch (Exception e) {
            if (conn != null) conn.rollback();
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                DBUtil.close(conn);
            }
        }
    }
    
    /**
     * 응답 조회
     */
    public List<ExamResp> getResponses(int sessId) throws SQLException {
        String sql = "SELECT SESS_ID, Q_ID, CHOSEN_OPT_NO, IS_CORRECT, ELAPSED_SEC, FLAG " +
                     "FROM EXAM_RESP WHERE SESS_ID = ? ORDER BY Q_ID";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, sessId);
            rs = pstmt.executeQuery();
            
            List<ExamResp> resps = new ArrayList<>();
            while (rs.next()) {
                ExamResp resp = new ExamResp();
                resp.setSessId(rs.getInt("SESS_ID"));
                resp.setQId(rs.getInt("Q_ID"));
                resp.setChosenOptNo((Integer) rs.getObject("CHOSEN_OPT_NO"));
                resp.setIsCorrect(rs.getString("IS_CORRECT"));
                resp.setElapsedSec((Integer) rs.getObject("ELAPSED_SEC"));
                resp.setFlag(rs.getString("FLAG"));
                resps.add(resp);
            }
            return resps;
        } finally {
            DBUtil.closeAll(conn, pstmt, rs);
        }
    }
}