package com.cbt.dao;

import com.cbt.model.User;
import com.cbt.util.DBUtil;
import java.sql.*;
import java.security.MessageDigest;

public class UserDAO {
    
    public User login(String email, String password) throws SQLException {
        String sql = "SELECT USER_ID, EMAIL, NAME, ROLE FROM USER_ACCT WHERE EMAIL = ? AND PWD_HASH = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, email);
            pstmt.setString(2, hashPassword(password));
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("USER_ID"));
                user.setEmail(rs.getString("EMAIL"));
                user.setName(rs.getString("NAME"));
                user.setRole(rs.getString("ROLE"));
                return user;
            }
            return null;
        } finally {
            DBUtil.closeAll(conn, pstmt, rs);
        }
    }
    
    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("비밀번호 해싱 실패", e);
        }
    }
    
    public void logAudit(int userId, String action, String target, String ip) throws SQLException {
        String sql = "INSERT INTO AUDIT (AUDIT_ID, USER_ID, ACTION, TARGET, IP) " +
                     "VALUES (SEQ_AUDIT.NEXTVAL, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setString(2, action);
            pstmt.setString(3, target);
            pstmt.setString(4, ip);
            pstmt.executeUpdate();
        } catch (SQLException ex) {
            if (isIgnorableAuditFailure(ex)) {
                System.err.println("[AUDIT] 로깅을 건너뜁니다: " + ex.getMessage());
                return;
            }
            throw ex;
        }
    }

    private boolean isIgnorableAuditFailure(SQLException ex) {
        SQLException current = ex;
        while (current != null) {
            int errorCode = current.getErrorCode();
            // ORA-00903(903): invalid table name, ORA-00942(942): table or view does not exist,
            // ORA-02289(2289): sequence does not exist
            if (errorCode == 903 || errorCode == 942 || errorCode == 2289) {
                return true;
            }
            current = current.getNextException();
        }
        return false;
    }
}
