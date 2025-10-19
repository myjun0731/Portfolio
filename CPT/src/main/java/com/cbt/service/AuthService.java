package com.cbt.service;

import com.cbt.dao.UserDAO;
import com.cbt.model.User;

import java.sql.SQLException;
import java.util.Objects;

public class AuthService {

    private final UserDAO userDAO;

    public AuthService() {
        this(new UserDAO());
    }

    public AuthService(UserDAO userDAO) {
        this.userDAO = Objects.requireNonNull(userDAO, "userDAO");
    }

    public User authenticate(String email, String password) throws SQLException {
        if (email == null || password == null) {
            return null;
        }
        return userDAO.login(email.trim(), password);
    }

    public void auditLogin(User user, String action, String target, String ip) throws SQLException {
        if (user == null) {
            return;
        }
        userDAO.logAudit(user.getUserId(), action, target, ip);
    }
}
