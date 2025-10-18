package com.cbt.model;

import java.time.LocalDateTime;

public class LoginActivity {
    private final LocalDateTime timestamp;
    private final String ip;
    private final String userAgent;

    public LoginActivity(LocalDateTime timestamp, String ip, String userAgent) {
        this.timestamp = timestamp;
        this.ip = ip;
        this.userAgent = userAgent;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public String getIp() {
        return ip;
    }

    public String getUserAgent() {
        return userAgent;
    }
}
